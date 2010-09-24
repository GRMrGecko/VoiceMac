//
//  MGMInstance.m
//  VoiceBase
//
//  Created by Mr. Gecko on 8/15/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMInstance.h"
#import "MGMInbox.h"
#import "MGMContacts.h"
#import "MGMAddressBook.h"
#import "MGMAddons.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMVoiceBaseCopyright = @"Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/";

NSString * const MGMVoiceIndexURL = @"https://www.google.com/voice/#inbox";
NSString * const MGMLoginURL = @"https://www.google.com/accounts/ServiceLoginAuth";
NSString * const MGMXPCPath = @"/voice/xpc/?xpc=%7B%22cn%22%3A%22i70avDIMsA%22%2C%22tp%22%3Anull%2C%22pru%22%3A%22https%3A%2F%2Fwww.google.com%2Fvoice%2Fxpc%2Frelay%22%2C%22ppu%22%3A%22https%3A%2F%2Fwww.google.com%2Fvoice%2Fxpc%2Fblank%2F%22%2C%22lpu%22%3A%22https%3A%2F%2Fclients4.google.com%2Fvoice%2Fxpc%2Fblank%2F%22%7D";
NSString * const MGMCheckPath = @"/voice/xpc/checkMessages?r=%@";
NSString * const MGMCreditURL = @"https://www.google.com/voice/settings/billingcredit/";
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
	if (self = [super init]) {
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
		[connectionManager connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MGMVoiceIndexURL]] delegate:self didFailWithError:@selector(index:didFailWithError:) didFinish:@selector(indexDidFinish:) invisible:MGMInstanceInvisible object:nil];
	}
	return self;
}
- (void)dealloc {
	if (connectionManager!=nil) {
		[connectionManager cancelAll];
		[connectionManager release];
	}
	if (user!=nil)
		[user release];
	if (cookeStorage!=nil)
		[cookeStorage release];
	if (inbox!=nil)
		[inbox release];
	if (contacts!=nil)
		[contacts release];
	if (XPCURL!=nil)
		[XPCURL release];
	if (XPCCD!=nil)
		[XPCCD release];
	if (rnr_se!=nil)
		[rnr_se release];
	if (userName!=nil)
		[userName release];
	if (userNumber!=nil)
		[userNumber release];
	if (userAreacode!=nil)
		[userAreacode release];
	if (userPhoneNumbers!=nil)
		[userPhoneNumbers release];
	if (checkTimer!=nil) {
		[checkTimer invalidate];
		[checkTimer release];
		checkTimer = nil;
	}
	if (unreadCounts!=nil)
		[unreadCounts release];
	if (creditTimer!=nil) {
		[creditTimer invalidate];
		[creditTimer release];
		creditTimer = nil;
	}
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
	if (checkTimer!=nil) {
		[checkTimer invalidate];
		[checkTimer release];
		checkTimer = nil;
	}
	if (creditTimer!=nil) {
		[creditTimer invalidate];
		[creditTimer release];
		creditTimer = nil;
	}
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

- (void)index:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
		[delegate loginError:theError];
	} else {
		NSLog(@"Login Error: %@", theError);
	}
}
- (void)indexDidFinish:(NSDictionary *)theInfo {
	NSString *returnedString = [[[NSString alloc] initWithData:[theInfo objectForKey:MGMConnectionData] encoding:NSUTF8StringEncoding] autorelease];
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
		[connectionManager connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:redirectURL]] delegate:self didFailWithError:@selector(index:didFailWithError:) didFinish:@selector(indexDidFinish:) invisible:MGMInstanceInvisible object:nil];
	} else if ([returnedString containsString:@"<div id=\"gaia_loginbox\">"]) {
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
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMLoginURL]];
		[request setHTTPMethod:MGMPostMethod];
		[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
		NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
		[parameters setObject:(webLoginTries==2 ? [[user settingForKey:MGMUserName] stringByAppendingString:@"@gmail.com"] : [user settingForKey:MGMUserName]) forKey:@"Email"];
		[parameters setObject:[user password] forKey:@"Passwd"];
		[parameters setObject:@"yes" forKey:@"PersistentCookie"];
		NSString *nameValue = @"name=\"%@\"";
		NSString *valueStart = @"value=\"";
		NSString *valueEnd = @"\"";
		NSString *valueStartQ = @"value='";
		NSString *valueEndQ = @"'";
		NSArray *names = [NSArray arrayWithObjects:@"ltmpl", @"continue", @"followup", @"service", @"dsh", @"GALX", @"rmShown", nil];
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
				[parameters setObject:[[[string substringWithRange:NSMakeRange(0, range.location)] copy] autorelease] forKey:[names objectAtIndex:i]];
			}
			[pool drain];
		}
		
#if MGMInstanceDebug
		NSMutableDictionary *parametersDebug = [[parameters mutableCopy] autorelease];
		[parametersDebug removeObjectForKey:@"Passwd"];
		NSLog(@"%@", parametersDebug);
#endif
		
		NSArray *parametersKeys = [parameters allKeys];
		NSMutableString *bodyString = [NSMutableString string];
		for (int i=0; i<[parametersKeys count]; i++) {
			if (i!=0)
				[bodyString appendString:@"&"];
			[bodyString appendFormat:@"%@=%@", [[parametersKeys objectAtIndex:i] addPercentEscapes], [[parameters objectForKey:[parametersKeys objectAtIndex:i]] addPercentEscapes]];
		}
		
		[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
		[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(index:didFailWithError:) didFinish:@selector(indexDidFinish:) invisible:MGMInstanceInvisible object:nil];
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
				if (rnr_se!=nil) [rnr_se release];
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
					if (userName!=nil) [userName release];
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
					if (userNumber!=nil) [userNumber release];
					userNumber = [[[string substringWithRange:NSMakeRange(0, range.location)] phoneFormat] copy];
				}
			}
		}
		if (![returnedString containsString:@"gc-header-did-display"] && ![userNumber isPhoneComplete]) {
			NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInstance.Login" code:2 userInfo:[NSDictionary dictionaryWithObject:@"Your Google Account does not appear to have a Google Number, please visit voice.google.com and setup one before continuing." forKey:NSLocalizedDescriptionKey]];
			if (delegate!=nil && [delegate respondsToSelector:@selector(loginError:)]) {
				[delegate loginError:error];
			} else {
				NSLog(@"Login Error: %@", error);
			}
			return;
		}
		if (userAreacode!=nil) [userAreacode release];
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
		NSDictionary *phones = [phonesInfo parseJSON];
		//NSLog(@"%@", phones);
		NSArray *phoneKeys = [phones allKeys];
		if (userPhoneNumbers!=nil) [userPhoneNumbers release];
		userPhoneNumbers = [NSMutableArray new];
		for (int i=0; i<[phoneKeys count]; i++) {
			NSDictionary *phoneInfo = [phones objectForKey:[phoneKeys objectAtIndex:i]];
			if ([[phoneInfo objectForKey:@"telephonyVerified"] intValue]==1) {
				NSMutableDictionary *phone = [NSMutableDictionary dictionary];
				[phone setObject:[[phoneInfo objectForKey:MGMPhoneNumber] phoneFormat] forKey:MGMPhoneNumber];
				[phone setObject:[[phoneInfo objectForKey:MGMName] flattenHTML] forKey:MGMName];
				[phone setObject:[phoneInfo objectForKey:MGMType] forKey:MGMType];
				[userPhoneNumbers addObject:phone];
			}
		}
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
				if (XPCURL!=nil) [XPCURL release];
				XPCURL = [[string substringWithRange:NSMakeRange(0, range.location)] copy];
			}
		}
#if MGMInstanceDebug
		NSLog(@"XPCURL = %@", XPCURL);
#endif
		loggedIn = YES;
		if (delegate!=nil && [delegate respondsToSelector:@selector(loginSuccessful)]) [delegate loginSuccessful];
		if (!checkingAccount) {
			[contacts updateContacts];
			if (checkTimer!=nil) {
				[checkTimer invalidate];
				[checkTimer release];
			}
			checkTimer = [[NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkTimer) userInfo:nil repeats:YES] retain];
			[checkTimer fire];
			if (creditTimer!=nil) {
				[creditTimer invalidate];
				[creditTimer release];
			}
			creditTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(creditTimer) userInfo:nil repeats:YES] retain];
			[creditTimer fire];
		}
	}
}
- (BOOL)isLoggedIn {
	return loggedIn;
}

- (void)xpcFinished:(NSDictionary *)theInfo {
	NSString *returnedString = [[[NSString alloc] initWithData:[theInfo objectForKey:MGMConnectionData] encoding:NSUTF8StringEncoding] autorelease];
	NSRange range = [returnedString rangeOfString:@"new _cd('"];
	if (range.location!=NSNotFound) {
		NSString *string = [returnedString substringFromIndex:range.location+range.length];
		
		range = [string rangeOfString:@"'"];
		if (range.location==NSNotFound) NSLog(@"failed 0009");
		if (XPCCD!=nil) [XPCCD release];
		XPCCD = [[[string substringWithRange:NSMakeRange(0, range.location)] addPercentEscapes] copy];
	}
#if MGMInstanceDebug
	NSLog(@"XPCCD = %@", XPCCD);
#endif
	[checkTimer fire];
}
- (void)checkTimer {
	if (XPCCD)
		[connectionManager connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:[XPCURL stringByAppendingString:MGMCheckPath], XPCCD]]] delegate:self didFailWithError:NULL didFinish:@selector(checkFinished:) invisible:MGMInstanceInvisible object:nil];
	else
		[connectionManager connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[XPCURL stringByAppendingString:MGMXPCPath]]] delegate:self didFailWithError:NULL didFinish:@selector(xpcFinished:) invisible:MGMInstanceInvisible object:nil];
}
- (void)checkFinished:(NSDictionary *)theInfo {
	NSDictionary *returnDic = [[theInfo objectForKey:MGMConnectionData] parseJSON];
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
			if (unreadCounts!=nil) [unreadCounts release];
			unreadCounts = [currentUnreadCounts copy];
		}
	}
}
- (void)creditTimer {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMCreditURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	[request setHTTPBody:[[NSString stringWithFormat:@"_rnr_se=%@", rnr_se] dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:NULL didFinish:@selector(creditFinished:) invisible:MGMInstanceInvisible object:nil];
}
- (void)creditFinished:(NSDictionary *)theInfo {
	NSString *credit = [[[theInfo objectForKey:MGMConnectionData] parseJSON] objectForKey:@"formattedCredit"];
#if MGMInstanceDebug
	NSLog(@"Credit = %@", credit);
#endif
	if (delegate!=nil && [delegate respondsToSelector:@selector(updateCredit:)]) [delegate updateCredit:credit];
}

- (void)placeCall:(NSString *)thePhoneNumber usingPhone:(int)thePhone delegate:(id)theDelegate {
	[self placeCall:thePhoneNumber usingPhone:thePhone delegate:theDelegate didFailWithError:@selector(call:didFailWithError:) didFinish:@selector(callDidFinish:)];
}
- (void)placeCall:(NSString *)thePhoneNumber usingPhone:(int)thePhone delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	if (thePhoneNumber!=nil)
		[info setObject:thePhoneNumber forKey:MGMPhoneNumber];
	[info setObject:[userPhoneNumbers objectAtIndex:thePhone] forKey:MGMPhone];
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
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(call:didFailWithError:) didFinish:@selector(callDidFinish:) invisible:MGMInstanceInvisible object:info];
}
- (void)cancelCallWithDelegate:(id)theDelegate {
	[self cancelCallWithDelegate:theDelegate didFailWithError:@selector(callCancel:didFailWithError:) didFinish:@selector(callCancelDidFinish:)];
}
- (void)cancelCallWithDelegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMCallCancelURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	[request setHTTPBody:[[NSString stringWithFormat:@"outgoingNumber=undefined&forwardingNumber=undefined&cancelType=C2C&_rnr_se=%@", rnr_se] dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(call:didFailWithError:) didFinish:@selector(callDidFinish:) invisible:MGMInstanceInvisible object:info];
}
- (void)call:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSDictionary *info = [theInfo objectForKey:MGMConnectionObject];
	if ([info objectForKey:MGMIDidFailWithError]!=nil) {
		SEL selector = NSSelectorFromString([info objectForKey:MGMIDidFailWithError]);
		id theDelegate = [info objectForKey:MGMIDelegate];
		NSMethodSignature *signature = [theDelegate methodSignatureForSelector:selector];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation setArgument:&theInfo atIndex:2];
			[invocation setArgument:&theError atIndex:3];
			[invocation invokeWithTarget:theDelegate];
		} else {
			NSLog(@"MGMInstance Call Error: %@", theError);
		}
	} else {
		NSLog(@"MGMInstance Call Error: %@", theError);
	}
}
- (void)callDidFinish:(NSDictionary *)theInfo {
	NSDictionary *infoDic = [[theInfo objectForKey:MGMConnectionData] parseJSON];
	if ([[infoDic objectForKey:@"ok"] boolValue]) {
#if MGMInstanceDebug
		NSLog(@"MGMInstance Did Call %@", infoDic);
#endif
		NSDictionary *thisInfo = [theInfo objectForKey:MGMConnectionObject];
		if ([thisInfo objectForKey:MGMIDidFinish]!=nil) {
			SEL selector = NSSelectorFromString([thisInfo objectForKey:MGMIDidFinish]);
			id theDelegate = [thisInfo objectForKey:MGMIDelegate];
			NSMethodSignature *signature = [theDelegate methodSignatureForSelector:selector];
			if (signature!=nil) {
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:selector];
				[invocation setArgument:&theInfo atIndex:2];
				[invocation invokeWithTarget:theDelegate];
			}
		}
	} else {
		NSDictionary *info = [NSDictionary dictionaryWithObject:[infoDic objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.VoiceBase.Call" code:1 userInfo:info];
		NSDictionary *thisInfo = [theInfo objectForKey:MGMConnectionObject];
		if ([thisInfo objectForKey:MGMIDidFailWithError]!=nil) {
			SEL selector = NSSelectorFromString([thisInfo objectForKey:MGMIDidFailWithError]);
			id theDelegate = [thisInfo objectForKey:MGMIDelegate];
			NSMethodSignature *signature = [theDelegate methodSignatureForSelector:selector];
			if (signature!=nil) {
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:selector];
				[invocation setArgument:&theInfo atIndex:2];
				[invocation setArgument:&error atIndex:3];
				[invocation invokeWithTarget:theDelegate];
			} else {
				NSLog(@"MGMInstance Call Error: %@", error);
			}
		} else {
			NSLog(@"MGMInstance Call Error: %@", error);
		}
	}
}
@end