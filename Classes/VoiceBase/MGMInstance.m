//
//  MGMInstance.m
//  VoiceBase
//
//  Created by Mr. Gecko on 8/15/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose
//  with or without fee is hereby granted, provided that the above copyright notice
//  and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT,
//  OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
//  DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
//  ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

#import "MGMInstance.h"
#import "MGMDelegateInfo.h"
#import "MGMInbox.h"
#import "MGMContacts.h"
#import "MGMAddressBook.h"
#import "MGMAddons.h"
#import "MGMXML.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMVoiceBaseCopyright = @"Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/";

NSString * const MGMVoiceIndexURL = @"https://www.google.com/voice/";
NSString * const MGMLoginURL = @"https://accounts.google.com/ServiceLoginAuth";
NSString * const MGMLoginVerifyURL = @"https://www.google.com/accounts/SmsAuth?persistent=yes";
NSString * const MGMXPCPath = @"/voice/xpc/?xpc=%7B%22cn%22%3A%22i70avDIMsA%22%2C%22tp%22%3Anull%2C%22pru%22%3A%22https%3A%2F%2Fwww.google.com%2Fvoice%2Fxpc%2Frelay%22%2C%22ppu%22%3A%22https%3A%2F%2Fwww.google.com%2Fvoice%2Fxpc%2Fblank%2F%22%2C%22lpu%22%3A%22https%3A%2F%2Fclients4.google.com%2Fvoice%2Fxpc%2Fblank%2F%22%7D";
NSString * const MGMCheckPath = @"/voice/xpc/checkMessages?r=%@";
NSString * const MGMCreditURL = @"https://www.google.com/voice/settings/billingcredit/";
NSString * const MGMPhonesURL = @"https://www.google.com/voice/settings/tab/phones";
NSString * const MGMCallURL = @"https://www.google.com/voice/call/connect/";
NSString * const MGMCallCancelURL = @"https://www.google.com/voice/call/cancel/";

NSString * const MGMPostMethod = @"POST";
NSString * const MGMURLForm = @"application/x-www-form-urlencoded";
NSString * const MGMContentType = @"content-type";

NSString * const MGMPhoneNumber = @"phoneNumber";
NSString * const MGMPhone = @"phone";
NSString * const MGMName = @"name";
NSString * const MGMType = @"type";

NSString * const MGMSContactsSourceKey = @"MGMContactsSource";
NSString * const MGMSContactsActionKey = @"MGMContactsAction";

NSString * const MGMUCAll = @"all";
NSString * const MGMUCInbox = @"inbox";
NSString * const MGMUCMissed = @"missed";
NSString * const MGMUCPlaced = @"placed";
NSString * const MGMUCReceived = @"received";
NSString * const MGMUCRecorded = @"recorded";
NSString * const MGMUCSMS = @"sms";
NSString * const MGMUCSpam = @"spam";
NSString * const MGMUCStarred = @"starred";
NSString * const MGMUCTrash = @"trash";
NSString * const MGMUCUnread = @"unread";
NSString * const MGMUCVoicemail = @"voicemail";

const BOOL MGMInstanceInvisible = YES;

@implementation MGMInstance
+ (id)instanceWithUser:(MGMUser *)theUser delegate:(id)theDelegate {
	return [[[self alloc] initWithUser:theUser  delegate:theDelegate isCheck:NO] autorelease];
}
+ (id)instanceWithUser:(MGMUser *)theUser delegate:(id)theDelegate isCheck:(BOOL)isCheck {
	return [[[self alloc] initWithUser:theUser  delegate:theDelegate isCheck:isCheck] autorelease];
}
- (id)initWithUser:(MGMUser *)theUser delegate:(id)theDelegate isCheck:(BOOL)isCheck {
	if ((self = [super init])) {
		checkingAccount = isCheck;
		loggedIn = NO;
		webLoginTries = 0;
		delegate = theDelegate;
		user = [theUser retain];
		cookeStorage = [[theUser cookieStorage] retain];
		connectionManager = [[MGMURLConnectionManager managerWithCookieStorage:cookeStorage] retain];
		[self registerSettings];
		inbox = [[MGMInbox inboxWithInstance:self] retain];
		if (!checkingAccount)
			contacts = [[MGMContacts contactsWithClass:NSClassFromString([user settingForKey:MGMSContactsSourceKey]) delegate:self] retain];
		MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MGMVoiceIndexURL]] delegate:self];
		[handler setFailWithError:@selector(index:didFailWithError:)];
		[handler setFinish:@selector(indexDidFinish:)];
		[handler setInvisible:MGMInstanceInvisible];
		[connectionManager addHandler:handler];
	}
	return self;
}
- (void)dealloc {
	[connectionManager cancelAll];
	[connectionManager release];
	[user release];
	[cookeStorage release];
	[inbox release];
	[contacts release];
	[XPCURL release];
	[XPCCD release];
	[rnr_se release];
	[userName release];
	[userNumber release];
	[userAreacode release];
	[userPhoneNumbers release];
	[checkTimer invalidate];
	[checkTimer release];
	checkTimer = nil;
	[unreadCounts release];
	[creditTimer invalidate];
	[creditTimer release];
	creditTimer = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ Number: %@ Account: %@", [super description], userNumber, userName];
}

- (void)stop {
	if (!checkingAccount)
		[contacts stop];
	[inbox stop];
	[connectionManager cancelAll];
	[checkTimer invalidate];
	[checkTimer release];
	checkTimer = nil;
	[creditTimer invalidate];
	[creditTimer release];
	creditTimer = nil;
}

- (void)registerSettings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setObject:NSStringFromClass([MGMAddressBook class]) forKey:MGMSContactsSourceKey];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMSContactsActionKey];
	[user registerSettings:settings];
}

- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}
- (id<MGMInstanceDelegate>)delegate {
	return delegate;
}
- (MGMUser *)user {
	return user;
}
- (MGMHTTPCookieStorage *)cookieStorage {
	return cookeStorage;
}
- (MGMURLConnectionManager *)connectionManager {
	return connectionManager;
}
- (MGMInbox *)inbox {
	return inbox;
}
- (MGMContacts *)contacts {
	return contacts;
}
- (void)updatedContacts {
	if (delegate!=nil && [delegate respondsToSelector:@selector(updatedContacts)]) [delegate updatedContacts];
}

- (NSString *)XPCURL {
	return XPCURL;
}
- (NSString *)XPCCD {
	return XPCCD;
}
- (NSString *)rnr_se {
	return rnr_se;
}

- (NSString *)userName {
	return userName;
}
- (NSString *)userNumber {
	return userNumber;
}
- (NSString *)userAreaCode {
	return userAreacode;
}
- (NSString *)areaCode {
	return userAreacode;
}
- (NSArray *)userPhoneNumbers {
	return userPhoneNumbers;
}
- (NSDictionary *)unreadCounts {
	return unreadCounts;
}

- (void)index:(MGMURLBasicHandler *)theHandler didFailWithError:(NSError *)theError {
	if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
		[delegate loginError:theError];
	} else {
		NSLog(@"Login Error: %@", theError);
	}
}
- (void)indexDidFinish:(MGMURLBasicHandler *)theHandler {
	NSString *returnedString = [theHandler string];
	if ([returnedString containsString:@"<title>Redirecting</title>"]) {
		NSRange range;
		NSString *redirectURL = MGMVoiceIndexURL;
		range = [returnedString rangeOfString:@"http-equiv="];
		if (range.location!=NSNotFound) {
			NSString *string = [returnedString substringFromIndex:range.location + range.length];
			range = [string rangeOfString:@"url="];
			if (range.location==NSNotFound) {
				NSLog(@"failed 683476");
			} else {
				string = [string substringFromIndex:range.location + range.length];
				range = [string rangeOfString:@"\""];
				if (range.location==NSNotFound) {
					range = [string rangeOfString:@"'"];
				}
				if (range.location==NSNotFound) {
					NSLog(@"failed 683476");
				} else {
					string = [string substringWithRange:NSMakeRange(0, range.location)];
					string = [string flattenHTML];
					string = [string replace:@"\"" with:@""];
					string = [string replace:@"'" with:@""];
					//string = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					redirectURL = [string replace:@"&amp;amp;" with:@"&"];
				}
			}
		}
		//NSLog(@"Redirecting to %@", redirectURL);
		MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:redirectURL]] delegate:self];
		[handler setFailWithError:@selector(index:didFailWithError:)];
		[handler setFinish:@selector(indexDidFinish:)];
		[handler setInvisible:MGMInstanceInvisible];
		[connectionManager addHandler:handler];
	} else if ([returnedString containsString:@"verification code"]) {
		[verificationParameters release];
		verificationParameters = [NSMutableDictionary new];
		[verificationParameters setObject:@"yes" forKey:@"PersistentCookie"];
		NSString *nameValue = @"name=\"%@\"";
		NSString *valueStart = @"value=\"";
		NSString *valueEnd = @"\"";
		NSString *valueStartQ = @"value='";
		NSString *valueEndQ = @"'";
		NSArray *names = [NSArray arrayWithObjects:@"timeStmp", @"secTok", @"smsToken", @"email", nil];
		for (int i=0; i<[names count]; i++) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSString *nameString = [NSString stringWithFormat:nameValue, [names objectAtIndex:i]];
			NSRange range = [returnedString rangeOfString:nameString];
			if (range.location==NSNotFound) {
				nameString = [nameString replace:@"\"" with:@"'"];
				range = [returnedString rangeOfString:nameString];
			}
			if (range.location==NSNotFound) {
				NSLog(@"Unable to find %@", [names objectAtIndex:i]);
			} else {
				NSString *string = [returnedString substringFromIndex:range.location+range.length];
				range = [string rangeOfString:valueStart];
				if (range.location==NSNotFound) {
					range = [string rangeOfString:valueStartQ];
					if (range.location==NSNotFound) {
						NSLog(@"Unable to find value for %@", [names objectAtIndex:i]);
						[pool drain];
						continue;
					}
					string = [string substringFromIndex:range.location+range.length];
					range = [string rangeOfString:valueEndQ];
				} else {
					string = [string substringFromIndex:range.location+range.length];
					range = [string rangeOfString:valueEnd];
				}
				if (range.location==NSNotFound) NSLog(@"failed 532");
				[verificationParameters setObject:[[[string substringWithRange:NSMakeRange(0, range.location)] copy] autorelease] forKey:[names objectAtIndex:i]];
			}
			[pool drain];
		}
		if ([delegate respondsToSelector:@selector(loginVerificationRequested)]) {
#if MGMInstanceDebug
			NSLog(@"%@", verificationParameters);
#endif
			[delegate loginVerificationRequested];
		} else {
			NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInstance.Login" code:54 userInfo:[NSDictionary dictionaryWithObject:@"Unable to login. The application does not implument with 2 step verification." forKey:NSLocalizedDescriptionKey]];
			if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
				[delegate loginError:error];
			} else {
				NSLog(@"Login Error: %@", error);
			}
			return;
		}
	} else if ([returnedString containsString:@"onload=\"autoSubmit()\""]) {
		NSRange actionRange = [returnedString rangeOfString:@"<form"];
		NSString *loginURL = [MGMLoginURL copy];
		if (actionRange.location!=NSNotFound) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSString *string = [returnedString substringFromIndex:actionRange.location+actionRange.length];
			actionRange = [string rangeOfString:@"action="];
			if (actionRange.location!=NSNotFound) {
				NSString *end = [string substringWithRange:NSMakeRange(actionRange.location+actionRange.length, 1)];
				actionRange.location += 1;
				string = [string substringFromIndex:actionRange.location+actionRange.length];
				actionRange = [string rangeOfString:end];
				[loginURL release];
				loginURL = [[string substringWithRange:NSMakeRange(0, actionRange.location)] copy];
			}
			[pool drain];
		}
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginURL]];
		[loginURL release];
		[request setHTTPMethod:MGMPostMethod];
		[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
		NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
		
		NSRange range = NSMakeRange(0, [returnedString length]);
		while (range.length>1) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSRange inputRange = [returnedString rangeOfString:@"<input " options:NSCaseInsensitiveSearch range:range];
			if (inputRange.location!=NSNotFound) {
				range.location = inputRange.location+inputRange.length;
				range.length = [returnedString length]-range.location;
				NSRange endInputRange = [returnedString rangeOfString:@">" options:NSCaseInsensitiveSearch range:range];
				if (endInputRange.location==NSNotFound)
					endInputRange.length = range.length;
				else
					endInputRange.length = endInputRange.location-range.location;
				endInputRange.location = range.location;
				NSRange nameRange = [returnedString rangeOfString:@"name=" options:NSCaseInsensitiveSearch range:endInputRange];
				if (nameRange.location==NSNotFound)
					continue;
				NSString *end = [returnedString substringWithRange:NSMakeRange(nameRange.location+nameRange.length, 1)];
				nameRange.location += 1;
				NSRange endRange = nameRange;
				endRange.location = nameRange.location+nameRange.length;
				endRange.length = [returnedString length]-endRange.location;
				endRange = [returnedString rangeOfString:end options:NSCaseInsensitiveSearch range:endRange];
				if (endRange.location==NSNotFound)
					continue;
				NSString *name = [returnedString substringWithRange:NSMakeRange(nameRange.location+nameRange.length, endRange.location-(nameRange.location+nameRange.length))];
				
				range.location = inputRange.location+inputRange.length;
				range.length = [returnedString length]-range.location;
				NSRange valueRange = [returnedString rangeOfString:@"value=" options:NSCaseInsensitiveSearch range:endInputRange];
				if (valueRange.location==NSNotFound)
					continue;
				end = [returnedString substringWithRange:NSMakeRange(valueRange.location+valueRange.length, 1)];
				valueRange.location += 1;
				endRange = valueRange;
				endRange.location = valueRange.location+valueRange.length;
				endRange.length = [returnedString length]-endRange.location;
				endRange = [returnedString rangeOfString:end options:NSCaseInsensitiveSearch range:endRange];
				if (endRange.location==NSNotFound)
					continue;
				NSString *value = [returnedString substringWithRange:NSMakeRange(valueRange.location+valueRange.length, endRange.location-(valueRange.location+valueRange.length))];
				
				[parameters setObject:value forKey:name];
			} else {
				break;
			}
			[pool drain];
		}
		
#if MGMInstanceDebug
		NSLog(@"%@", parameters);
#endif
		
		NSArray *parametersKeys = [parameters allKeys];
		NSMutableString *bodyString = [NSMutableString string];
		for (int i=0; i<[parametersKeys count]; i++) {
			if (i!=0)
				[bodyString appendString:@"&"];
			[bodyString appendFormat:@"%@=%@", [[parametersKeys objectAtIndex:i] addPercentEscapes], [[parameters objectForKey:[parametersKeys objectAtIndex:i]] addPercentEscapes]];
		}
		
		[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
		MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:request delegate:self];
		[handler setFailWithError:@selector(index:didFailWithError:)];
		[handler setFinish:@selector(indexDidFinish:)];
		[handler setInvisible:MGMInstanceInvisible];
		[connectionManager addHandler:handler];
	} else if ([returnedString containsString:@"<div class=\"sign-in\""]) {
		if (webLoginTries>2) {
			NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInstance.Login" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Unable to login. Please check your Credentials." forKey:NSLocalizedDescriptionKey]];
			if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
				[delegate loginError:error];
			} else {
				NSLog(@"Login Error: %@", error);
			}
			return;
		}
		webLoginTries++;
		NSRange actionRange = [returnedString rangeOfString:@"<form"];
		NSString *loginURL = [MGMLoginURL copy];
		if (actionRange.location!=NSNotFound) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSString *string = [returnedString substringFromIndex:actionRange.location+actionRange.length];
			actionRange = [string rangeOfString:@"action="];
			if (actionRange.location!=NSNotFound) {
				NSString *end = [string substringWithRange:NSMakeRange(actionRange.location+actionRange.length, 1)];
				actionRange.location += 1;
				string = [string substringFromIndex:actionRange.location+actionRange.length];
				actionRange = [string rangeOfString:end];
				[loginURL release];
				loginURL = [[string substringWithRange:NSMakeRange(0, actionRange.location)] copy];
			}
			[pool drain];
		}
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginURL]];
		[loginURL release];
		[request setHTTPMethod:MGMPostMethod];
		[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
		NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
		
		NSRange range = NSMakeRange(0, [returnedString length]);
		while (range.length>1) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSRange inputRange = [returnedString rangeOfString:@"<input " options:NSCaseInsensitiveSearch range:range];
			if (inputRange.location!=NSNotFound) {
				range.location = inputRange.location+inputRange.length;
				range.length = [returnedString length]-range.location;
				NSRange endInputRange = [returnedString rangeOfString:@">" options:NSCaseInsensitiveSearch range:range];
				if (endInputRange.location==NSNotFound)
					endInputRange.length = range.length;
				else
					endInputRange.length = endInputRange.location-range.location;
				endInputRange.location = range.location;
				NSRange nameRange = [returnedString rangeOfString:@"name=" options:NSCaseInsensitiveSearch range:endInputRange];
				if (nameRange.location==NSNotFound)
					continue;
				NSString *end = [returnedString substringWithRange:NSMakeRange(nameRange.location+nameRange.length, 1)];
				nameRange.location += 1;
				NSRange endRange = nameRange;
				endRange.location = nameRange.location+nameRange.length;
				endRange.length = [returnedString length]-endRange.location;
				endRange = [returnedString rangeOfString:end options:NSCaseInsensitiveSearch range:endRange];
				if (endRange.location==NSNotFound)
					continue;
				NSString *name = [returnedString substringWithRange:NSMakeRange(nameRange.location+nameRange.length, endRange.location-(nameRange.location+nameRange.length))];
				
				range.location = inputRange.location+inputRange.length;
				range.length = [returnedString length]-range.location;
				NSRange valueRange = [returnedString rangeOfString:@"value=" options:NSCaseInsensitiveSearch range:endInputRange];
				if (valueRange.location==NSNotFound)
					continue;
				end = [returnedString substringWithRange:NSMakeRange(valueRange.location+valueRange.length, 1)];
				valueRange.location += 1;
				endRange = valueRange;
				endRange.location = valueRange.location+valueRange.length;
				endRange.length = [returnedString length]-endRange.location;
				endRange = [returnedString rangeOfString:end options:NSCaseInsensitiveSearch range:endRange];
				if (endRange.location==NSNotFound)
					continue;
				NSString *value = [returnedString substringWithRange:NSMakeRange(valueRange.location+valueRange.length, endRange.location-(valueRange.location+valueRange.length))];
				
				[parameters setObject:value forKey:name];
			} else {
				break;
			}
			[pool drain];
		}
		
		if ([parameters objectForKey:@"PersistentCookie"]!=nil)
			[parameters setObject:@"yes" forKey:@"PersistentCookie"];
		
		if ([[parameters objectForKey:@"Email"] isEqual:@""])
			[parameters setObject:(webLoginTries==2 ? [[user settingForKey:MGMUserName] stringByAppendingString:@"@gmail.com"] : [user settingForKey:MGMUserName]) forKey:@"Email"];
		
#if MGMInstanceDebug
		NSLog(@"%@", parameters);
#endif
		
		[parameters setObject:[user password] forKey:@"Passwd"];
		
		NSArray *parametersKeys = [parameters allKeys];
		NSMutableString *bodyString = [NSMutableString string];
		for (int i=0; i<[parametersKeys count]; i++) {
			if (i!=0)
				[bodyString appendString:@"&"];
			[bodyString appendFormat:@"%@=%@", [[parametersKeys objectAtIndex:i] addPercentEscapes], [[parameters objectForKey:[parametersKeys objectAtIndex:i]] addPercentEscapes]];
		}
		
		[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
		MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:request delegate:self];
		[handler setFailWithError:@selector(index:didFailWithError:)];
		[handler setFinish:@selector(indexDidFinish:)];
		[handler setInvisible:MGMInstanceInvisible];
		[connectionManager addHandler:handler];
	} else {
		NSString *string, *guser = @"", *phonesInfo = @"";
		NSRange range;
		
#if MGMInstanceDebug
		NSLog(@"Parsing rnr_se");
#endif
		range = [returnedString rangeOfString:@"'_rnr_se': '"];
		if (range.location!=NSNotFound) {
			string = [returnedString substringFromIndex:range.location+range.length];
			
			range = [string rangeOfString:@"',"];
			if (range.location==NSNotFound) {
				NSLog(@"failed 0001");
			} else {
				[rnr_se release];
				rnr_se = [[[string substringWithRange:NSMakeRange(0, range.location)] addPercentEscapes] copy];
			}
		}
#if MGMInstanceDebug
		NSLog(@"rnr_se = %@", rnr_se);
		NSLog(@"Parsing Right Header");
#endif
		range = [returnedString rangeOfString:@"<div id=guser"];
		if (range.location!=NSNotFound) {
			string = [returnedString substringFromIndex:range.location+range.length];
			
			range = [string rangeOfString:@">"];
			if (range.location==NSNotFound) {
				NSLog(@"failed 0002");
			} else {
				string = [string substringFromIndex:range.location+range.length];
				range = [string rangeOfString:@"</div>"];
				if (range.location==NSNotFound) {
					NSLog(@"failed 0002.1");
				} else {
					guser = [string substringWithRange:NSMakeRange(0, range.location)];
				}
			}
		}
#if MGMInstanceDebug
		NSLog(@"Parsing User Name");
#endif
		range = [guser rangeOfString:@"<b"];
		if (range.location!=NSNotFound) {
			string = [guser substringFromIndex:range.location+range.length];
			
			range = [string rangeOfString:@">"];
			if (range.location==NSNotFound) {
				NSLog(@"failed 0003");
			} else {
				string = [string substringFromIndex:range.location+range.length];
				range = [string rangeOfString:@"</b>"];
				if (range.location==NSNotFound) {
					NSLog(@"failed 0003.1");
				} else {
					[userName release];
					userName = [[string substringWithRange:NSMakeRange(0, range.location)] copy];
				}
			}
		}
#if MGMInstanceDebug
		NSLog(@"User Name = %@", userName);
		NSLog(@"Parsing Google Number Header");
#endif
		range = [returnedString rangeOfString:@"gc-header-info"];
		if (range.location!=NSNotFound) {
			string = [returnedString substringFromIndex:range.location+range.length];
			
			range = [string rangeOfString:@">"];
			if (range.location==NSNotFound) {
				NSLog(@"failed 0002");
			} else {
				string = [string substringFromIndex:range.location+range.length];
				range = [string rangeOfString:@"</div>"];
				if (range.location==NSNotFound) {
					NSLog(@"failed 0002.1");
				} else {
					guser = [string substringWithRange:NSMakeRange(0, range.location)];
				}
			}
		}
#if MGMInstanceDebug
		NSLog(@"Parsing Google Number");
#endif
		range = [guser rangeOfString:@"href=\"#phones\""];
		if (range.location!=NSNotFound) {
			string = [guser substringFromIndex:range.location+range.length];
			
			range = [string rangeOfString:@">"];
			if (range.location==NSNotFound) {
				NSLog(@"failed 0004");
			} else {
				string = [string substringFromIndex:range.location+range.length];
				range = [string rangeOfString:@"</a>"];
				if (range.location==NSNotFound) {
					NSLog(@"failed 0004.1");
				} else {
					[userNumber release];
					userNumber = [[[string substringWithRange:NSMakeRange(0, range.location)] phoneFormat] copy];
				}
			}
		}
		if ([returnedString containsString:@"cookie functionality"]) {
			NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInstance.Login" code:3 userInfo:[NSDictionary dictionaryWithObject:@"There is a problem with VoiceMac's Cookie system, please contact the developer via the help menu." forKey:NSLocalizedDescriptionKey]];
			if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
				[delegate loginError:error];
			} else {
				NSLog(@"Login Error: %@", error);
			}
			return;
		} else if (![returnedString containsString:@"gc-header-did-display"] && ![userNumber isPhoneComplete]) {
			NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInstance.Login" code:2 userInfo:[NSDictionary dictionaryWithObject:@"Your Google Account does not appear to have a Google Number, please visit voice.google.com and setup one before continuing." forKey:NSLocalizedDescriptionKey]];
			if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
				[delegate loginError:error];
			} else {
				NSLog(@"Login Error: %@", error);
			}
			return;
		}
		[userAreacode release];
		userAreacode = [[userNumber areaCode] copy];
#if MGMInstanceDebug
		NSLog(@"Google Number = %@", userNumber);
		NSLog(@"Areacode = %@", userAreacode);
		NSLog(@"Parsing User Phones");
#endif
		range = [returnedString rangeOfString:@"'phones': "];
		if (range.location!=NSNotFound) {
			string = [returnedString substringFromIndex:range.location+range.length];
			
			range = [string rangeOfString:@",\n"];
			if (range.location==NSNotFound) {
				NSLog(@"failed 0005");
			} else {
				phonesInfo = [string substringWithRange:NSMakeRange(0, range.location)];
			}
		}
		[self parseUserPhones:[phonesInfo parseJSON]];
#if MGMInstanceDebug
		NSLog(@"User Phones = %@", userPhoneNumbers);
		NSLog(@"Parsing XPCURL");
#endif
		range = [returnedString rangeOfString:@"'xpcUrl': '"];
		if (range.location!=NSNotFound) {
			string = [returnedString substringFromIndex:range.location+range.length];
			
			range = [string rangeOfString:@"'"];
			if (range.location==NSNotFound) {
				NSLog(@"failed 0008");
			} else {
				[XPCURL release];
				XPCURL = [[string substringWithRange:NSMakeRange(0, range.location)] copy];
			}
		}
#if MGMInstanceDebug
		NSLog(@"XPCURL = %@", XPCURL);
#endif
		loggedIn = YES;
		if (!checkingAccount) {
			[contacts updateContacts];
			[checkTimer invalidate];
			[checkTimer release];
			checkTimer = [[NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkTimer) userInfo:nil repeats:YES] retain];
			[checkTimer fire];
			[creditTimer invalidate];
			[creditTimer release];
			creditTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(creditTimer) userInfo:nil repeats:YES] retain];
			[creditTimer fire];
		}
		if (delegate!=nil && [delegate respondsToSelector:@selector(loginSuccessful)]) [delegate loginSuccessful];
	}
}
- (void)cancelVerification {
	[verificationParameters release];
	verificationParameters = nil;
	NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInstance.Login" code:54 userInfo:[NSDictionary dictionaryWithObject:@"Unable to login. Verification was canceled." forKey:NSLocalizedDescriptionKey]];
	if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
		[delegate loginError:error];
	} else {
		NSLog(@"Login Error: %@", error);
	}
}
- (void)verifyWithCode:(NSString *)theCode {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMLoginVerifyURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	[verificationParameters setObject:theCode forKey:@"smsUserPin"];
	NSArray *parametersKeys = [verificationParameters allKeys];
	NSMutableString *bodyString = [NSMutableString string];
	for (int i=0; i<[parametersKeys count]; i++) {
		if (i!=0)
			[bodyString appendString:@"&"];
		[bodyString appendFormat:@"%@=%@", [[parametersKeys objectAtIndex:i] addPercentEscapes], [[verificationParameters objectForKey:[parametersKeys objectAtIndex:i]] addPercentEscapes]];
	}
	
	[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
	MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:request delegate:self];
	[handler setFailWithError:@selector(index:didFailWithError:)];
	[handler setFinish:@selector(indexDidFinish:)];
	[handler setInvisible:MGMInstanceInvisible];
	[connectionManager addHandler:handler];
	[verificationParameters release];
	verificationParameters = nil;
}
- (BOOL)isLoggedIn {
	return loggedIn;
}

- (void)checkPhones {
	MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MGMPhonesURL]] delegate:self];
	[handler setFinish:@selector(phonesFinished:)];
	[handler setInvisible:MGMInstanceInvisible];
	[connectionManager addHandler:handler];
}
- (void)phonesFinished:(MGMURLBasicHandler *)theHandler {
	MGMXMLElement *XML = [(MGMXMLDocument *)[[[MGMXMLDocument alloc] initWithData:[theHandler data] options:MGMXMLDocumentTidyXML error:nil] autorelease] rootElement];
	NSDictionary *info = [[[[XML elementsForName:@"json"] objectAtIndex:0] stringValue] parseJSON];
	[self parseUserPhones:[info objectForKey:@"phones"]];
	if ([delegate respondsToSelector:@selector(updatedUserPhones)]) [delegate updatedUserPhones];
}
- (void)parseUserPhones:(NSDictionary *)thePhones {
	if (thePhones==nil)
		return;
	NSArray *phones = [thePhones allKeys];
	[userPhoneNumbers release];
	userPhoneNumbers = [NSMutableArray new];
	for (int i=0; i<[phones count]; i++) {
		NSDictionary *phoneInfo = [thePhones objectForKey:[phones objectAtIndex:i]];
		if ([[phoneInfo objectForKey:@"verified"] intValue]==1) {
			NSMutableDictionary *phone = [NSMutableDictionary dictionary];
			[phone setObject:[[phoneInfo objectForKey:MGMPhoneNumber] phoneFormat] forKey:MGMPhoneNumber];
			[phone setObject:[[phoneInfo objectForKey:MGMName] flattenHTML] forKey:MGMName];
			[phone setObject:[phoneInfo objectForKey:MGMType] forKey:MGMType];
			[userPhoneNumbers addObject:phone];
		}
	}
}

- (void)xpcFinished:(MGMURLBasicHandler *)theHandler {
	NSString *returnedString = [theHandler string];
	NSRange range = [returnedString rangeOfString:@"new _cd('"];
	if (range.location!=NSNotFound) {
		NSString *string = [returnedString substringFromIndex:range.location+range.length];
		
		range = [string rangeOfString:@"'"];
		if (range.location==NSNotFound) NSLog(@"failed 0009");
		[XPCCD release];
		XPCCD = [[[string substringWithRange:NSMakeRange(0, range.location)] addPercentEscapes] copy];
	}
#if MGMInstanceDebug
	NSLog(@"XPCCD = %@", XPCCD);
#endif
	[checkTimer fire];
}
- (void)checkTimer {
	if (XPCCD) {
		MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:[XPCURL stringByAppendingString:MGMCheckPath], XPCCD]]] delegate:self];
		[handler setFinish:@selector(checkFinished:)];
		[handler setInvisible:MGMInstanceInvisible];
		[connectionManager addHandler:handler];
	} else {
		MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[XPCURL stringByAppendingString:MGMXPCPath]]] delegate:self];
		[handler setFinish:@selector(xpcFinished:)];
		[handler setInvisible:MGMInstanceInvisible];
		[connectionManager addHandler:handler];
	}
}
- (void)checkFinished:(MGMURLBasicHandler *)theHandler {
	NSDictionary *returnDic = [[theHandler data] parseJSON];
	if (returnDic!=nil) {
		if ([[returnDic objectForKey:@"ok"] intValue]!=0) {
			NSDictionary *currentUnreadCounts = [[returnDic objectForKey:@"data"] objectForKey:@"unreadCounts"];
#if MGMInstanceDebug
			NSLog(@"unreadCounts = %@", currentUnreadCounts);
#endif
			int inboxCount = [[currentUnreadCounts objectForKey:MGMUCInbox] intValue];
			//int recordedCount = [[currentUnreadCounts objectForKey:MGMUCRecorded] intValue];
			int voicemailCount = [[currentUnreadCounts objectForKey:MGMUCVoicemail] intValue];
			int smsCount = [[currentUnreadCounts objectForKey:MGMUCSMS] intValue];
			if ([[unreadCounts objectForKey:MGMUCInbox] intValue]!=inboxCount)
				if (delegate!=nil && [delegate respondsToSelector:@selector(updateUnreadCount:)]) [delegate updateUnreadCount:inboxCount];
			if (voicemailCount>0)
				if (delegate!=nil && [delegate respondsToSelector:@selector(updateVoicemail)]) [delegate updateVoicemail];
			if (smsCount>0)
				if (delegate!=nil && [delegate respondsToSelector:@selector(updateSMS)]) [delegate updateSMS];
			[unreadCounts release];
			unreadCounts = [currentUnreadCounts copy];
		}
	}
}
- (void)creditTimer {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMCreditURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	[request setHTTPBody:[[NSString stringWithFormat:@"_rnr_se=%@", rnr_se] dataUsingEncoding:NSUTF8StringEncoding]];
	MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:request delegate:self];
	[handler setFinish:@selector(creditFinished:)];
	[handler setInvisible:MGMInstanceInvisible];
	[connectionManager addHandler:handler];
}
- (void)creditFinished:(MGMURLBasicHandler *)theHandler {
	NSString *credit = [[[theHandler data] parseJSON] objectForKey:@"formattedCredit"];
#if MGMInstanceDebug
	NSLog(@"Credit = %@", credit);
#endif
	if (delegate!=nil && [delegate respondsToSelector:@selector(updateCredit:)]) [delegate updateCredit:credit];
}

- (void)placeCall:(NSString *)thePhoneNumber usingPhone:(int)thePhone delegate:(id)theDelegate {
	[self placeCall:thePhoneNumber usingPhone:thePhone delegate:theDelegate didFailWithError:@selector(call:didFailWithError:) didFinish:@selector(callDidFinish:)];
}
- (void)placeCall:(NSString *)thePhoneNumber usingPhone:(int)thePhone delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
	MGMDelegateInfo *info = [MGMDelegateInfo infoWithDelegate:theDelegate];
	[info setFinish:didFinish];
	[info setFailWithError:didFailWithError];
	[info setPhoneNumbers:[NSArray arrayWithObject:thePhoneNumber]];
	[info setPhone:[userPhoneNumbers objectAtIndex:thePhone]];
	if (thePhoneNumber==nil || [thePhoneNumber isEqual:@""]) {
		NSMethodSignature *signature = [theDelegate methodSignatureForSelector:didFailWithError];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:didFailWithError];
			[invocation setArgument:&info atIndex:2];
			NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInstance.Call" code:1 userInfo:nil];
			[invocation setArgument:&error atIndex:3];
			[invocation invokeWithTarget:theDelegate];
		}
		return;
	}
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMCallURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	[request setHTTPBody:[[NSString stringWithFormat:@"outgoingNumber=%@&forwardingNumber=%@&subscriberNumber=undefined&phoneType=%@&remember=1&_rnr_se=%@", thePhoneNumber, [[userPhoneNumbers objectAtIndex:thePhone] objectForKey:MGMPhoneNumber], [[userPhoneNumbers objectAtIndex:thePhone] objectForKey:MGMType], rnr_se] dataUsingEncoding:NSUTF8StringEncoding]];
	MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:request delegate:self];
	[handler setFailWithError:@selector(call:didFailWithError:)];
	[handler setFinish:@selector(callDidFinish:)];
	[handler setInvisible:MGMInstanceInvisible];
	[handler setObject:info];
	[connectionManager addHandler:handler];
}
- (void)cancelCallWithDelegate:(id)theDelegate {
	[self cancelCallWithDelegate:theDelegate didFailWithError:@selector(callCancel:didFailWithError:) didFinish:@selector(callCancelDidFinish:)];
}
- (void)cancelCallWithDelegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
	MGMDelegateInfo *info = [MGMDelegateInfo infoWithDelegate:theDelegate];
	[info setFinish:didFinish];
	[info setFailWithError:didFailWithError];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMCallCancelURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	[request setHTTPBody:[[NSString stringWithFormat:@"outgoingNumber=undefined&forwardingNumber=undefined&cancelType=C2C&_rnr_se=%@", rnr_se] dataUsingEncoding:NSUTF8StringEncoding]];
	MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:request delegate:self];
	[handler setFailWithError:@selector(call:didFailWithError:)];
	[handler setFinish:@selector(callDidFinish:)];
	[handler setInvisible:MGMInstanceInvisible];
	[handler setObject:info];
	[connectionManager addHandler:handler];
}
- (void)call:(MGMURLBasicHandler *)theHandler didFailWithError:(NSError *)theError {
	MGMDelegateInfo *info = [theHandler object];
	BOOL displayError = YES;
	if ([info failWithError]!=nil) {
		NSMethodSignature *signature = [[info delegate] methodSignatureForSelector:[info failWithError]];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:[info failWithError]];
			[invocation setArgument:&info atIndex:2];
			[invocation setArgument:&theError atIndex:3];
			[invocation invokeWithTarget:[info delegate]];
			displayError = NO;
		}
	}
	if (displayError)
		NSLog(@"MGMInstance Call Error: %@", theError);
}
- (void)callDidFinish:(MGMURLBasicHandler *)theHandler {
	NSDictionary *infoDic = [[theHandler data] parseJSON];
	MGMDelegateInfo *thisInfo = [theHandler object];
	if ([[infoDic objectForKey:@"ok"] boolValue]) {
#if MGMInstanceDebug
		NSLog(@"MGMInstance Did Call %@", infoDic);
#endif
		if ([thisInfo finish]!=nil) {
			NSMethodSignature *signature = [[thisInfo delegate] methodSignatureForSelector:[thisInfo finish]];
			if (signature!=nil) {
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:[thisInfo finish]];
				[invocation setArgument:&thisInfo atIndex:2];
				[invocation invokeWithTarget:[thisInfo delegate]];
			}
		}
	} else {
		NSDictionary *info = nil;
		if ([infoDic objectForKey:@"error"]!=nil)
			info = [NSDictionary dictionaryWithObject:[infoDic objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.VoiceBase.Call" code:1 userInfo:info];
		if ([thisInfo failWithError]!=nil) {
			NSMethodSignature *signature = [[thisInfo delegate] methodSignatureForSelector:[thisInfo failWithError]];
			if (signature!=nil) {
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:[thisInfo failWithError]];
				[invocation setArgument:&thisInfo atIndex:2];
				[invocation setArgument:&error atIndex:3];
				[invocation invokeWithTarget:[thisInfo delegate]];
			} else {
				NSLog(@"MGMInstance Call Error: %@", error);
			}
		} else {
			NSLog(@"MGMInstance Call Error: %@", error);
		}
	}
}
@end