//
//  MGMInbox.m
//  VoiceBase
//
//  Created by Mr. Gecko on 8/15/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMInbox.h"
#import "MGMInstance.h"
#import "MGMAddons.h"
#import "MGMXML.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMIDelegate = @"delegate";
NSString * const MGMIDidReceiveInfo = @"didReceiveInfo";
NSString * const MGMIDidFinish = @"didFinish";
NSString * const MGMIDidFailWithError = @"didFailWithError";
NSString * const MGMIEntries = @"entries";
NSString * const MGMIPhoneNumbers = @"phoneNumbers";
NSString * const MGMIMessage = @"message";

NSString * const MGMIInboxURL = @"https://www.google.com/voice/inbox/recent/";
NSString * const MGMIStarredURL = @"https://www.google.com/voice/inbox/recent/starred/";
NSString * const MGMIStarURL = @"https://www.google.com/voice/inbox/star/";
NSString * const MGMISpamURL = @"https://www.google.com/voice/inbox/recent/spam/";
NSString * const MGMITrashURL = @"https://www.google.com/voice/inbox/recent/trash/";

NSString * const MGMIVoiceMailURL = @"https://www.google.com/voice/inbox/recent/voicemail/";
NSString * const MGMIVoiceMailDownloadURL = @"https://www.google.com/voice/media/send_voicemail/%@";
NSString * const MGMISMSURL = @"https://www.google.com/voice/inbox/recent/sms/";
NSString * const MGMISMSSendURL = @"https://www.google.com/voice/sms/send/";
NSString * const MGMIRecordedURL = @"https://www.google.com/voice/inbox/recent/recorded/";
NSString * const MGMIPlacedURL = @"https://www.google.com/voice/inbox/recent/placed/";
NSString * const MGMIReceivedURL = @"https://www.google.com/voice/inbox/recent/received/";
NSString * const MGMIMissedURL = @"https://www.google.com/voice/inbox/recent/missed/";

NSString * const MGMIMarkURL = @"https://www.google.com/voice/inbox/mark/";
NSString * const MGMIDeleteURL = @"https://www.google.com/voice/inbox/deleteMessages/";
NSString * const MGMIDeleteForeverURL = @"https://www.google.com/voice/inbox/deleteForeverMessages/";
NSString * const MGMIReportURL = @"https://www.google.com/voice/inbox/spam/";

NSString * const MGMIPhoneNumber = @"phoneNumber";
NSString * const MGMIID = @"id";
NSString * const MGMIUniqueId = @"uniqueId";
NSString * const MGMIText = @"text";
NSString * const MGMIYou = @"you";
NSString * const MGMITime = @"time";
NSString * const MGMIStartTime = @"startTime";
NSString * const MGMIInfo = @"info";
NSString * const MGMIMessages = @"messages";
NSString * const MGMIUseful = @"useful";
NSString * const MGMIRead = @"isRead";
NSString * const MGMIType = @"type";
NSString * const MGMIStarred = @"star";
NSString * const MGMISpam = @"isSpam";
NSString * const MGMITrash = @"isTrash";

const int MGMIMissedType = 0;
const int MGMIReceivedType = 1;
const int MGMIVoicemailType = 2;
const int MGMIRecordedType = 4;
const int MGMIPlacedType = 8;
const int MGMISMSInType = 10;
const int MGMISMSOutType = 11;

NSString * const MGMIPage = @"%@?page=p%d";

const BOOL MGMInboxInvisible = YES;

@implementation MGMInbox
+ (id)inboxWithInstance:(MGMInstance *)theInstance {
	return [[[self alloc] initWithInstance:theInstance] autorelease];
}
- (id)initWithInstance:(MGMInstance *)theInstance {
	if ((self = [super init])) {
		instance = theInstance;
		connectionManager = [[MGMURLConnectionManager managerWithCookieStorage:[theInstance cookieStorage]] retain];
	}
	return self;
}
- (void)dealloc {
	[connectionManager cancelAll];
	[connectionManager release];
	[super dealloc];
}

- (void)stop {
	[connectionManager cancelAll];
}

- (void)getInboxForPage:(int)thePage delegate:(id)theDelegate {
	[self getInboxForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getInboxForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMIInboxURL page:thePage info:info];
}

- (void)getStarredForPage:(int)thePage delegate:(id)theDelegate {
	[self getStarredForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getStarredForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMIStarredURL page:thePage info:info];
}

- (void)getSpamForPage:(int)thePage delegate:(id)theDelegate {
	[self getSpamForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getSpamForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMISpamURL page:thePage info:info];
}

- (void)getTrashForPage:(int)thePage delegate:(id)theDelegate {
	[self getTrashForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getTrashForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMITrashURL page:thePage info:info];
}

- (void)getVoicemailForPage:(int)thePage delegate:(id)theDelegate {
	[self getVoicemailForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getVoicemailForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMIVoiceMailURL page:thePage info:info];
}

- (void)getSMSForPage:(int)thePage delegate:(id)theDelegate {
	[self getSMSForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getSMSForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMISMSURL page:thePage info:info];
}

- (void)getRecordedCallsForPage:(int)thePage delegate:(id)theDelegate {
	[self getRecordedCallsForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getRecordedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMIRecordedURL page:thePage info:info];
}

- (void)getPlacedCallsForPage:(int)thePage delegate:(id)theDelegate {
	[self getPlacedCallsForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getPlacedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMIPlacedURL page:thePage info:info];
}

- (void)getReceivedCallsForPage:(int)thePage delegate:(id)theDelegate {
	[self getPlacedCallsForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getReceivedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMIReceivedURL page:thePage info:info];
}

- (void)getMissedCallsForPage:(int)thePage delegate:(id)theDelegate {
	[self getPlacedCallsForPage:thePage delegate:theDelegate didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
}
- (void)getMissedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didReceiveInfo!=NULL)
		[info setObject:NSStringFromSelector(didReceiveInfo) forKey:MGMIDidReceiveInfo];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[self retrieveURL:MGMIMissedURL page:thePage info:info];
}

- (void)retrieveURL:(NSString *)theURL page:(int)thePage info:(NSDictionary *)theInfo {
	NSString *url = nil;
	if (thePage<=1)
		url = theURL;
	else
		url = [NSString stringWithFormat:MGMIPage, theURL, thePage];
#if MGMInboxDebug
	NSLog(@"MGMInbox Will load %@", url);
#endif
	[connectionManager connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self didFailWithError:@selector(request:didFailWithError:) didFinish:@selector(requestDidFinish:) invisible:MGMInboxInvisible object:theInfo];
}
- (void)request:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSDictionary *info = [theInfo objectForKey:MGMConnectionObject];
	if ([info objectForKey:MGMIDidFailWithError]!=nil) {
		SEL selector = NSSelectorFromString([info objectForKey:MGMIDidFailWithError]);
		id delegate = [info objectForKey:MGMIDelegate];
		NSMethodSignature *signature = [delegate methodSignatureForSelector:selector];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation setArgument:&theInfo atIndex:2];
			[invocation setArgument:&theError atIndex:3];
			[invocation setArgument:&instance atIndex:4];
			[invocation invokeWithTarget:delegate];
		} else {
			NSLog(@"MGMInbox Error: %@", theError);
		}
	} else {
		NSLog(@"MGMInbox Error: %@", theError);
	}
}
- (void)requestDidFinish:(NSDictionary *)theInfo {
	MGMXMLElement *XML = [(MGMXMLDocument *)[[[MGMXMLDocument alloc] initWithData:[theInfo objectForKey:MGMConnectionData] options:MGMXMLDocumentTidyXML error:nil] autorelease] rootElement];
	NSDictionary *infoDic = [[[[XML elementsForName:@"json"] objectAtIndex:0] stringValue] parseJSON];
	NSDictionary *messagesInfo = [infoDic objectForKey:@"messages"];
	NSArray *messagesInfoKeys = [messagesInfo allKeys];
	MGMXMLElement *html = [(MGMXMLDocument *)[[[MGMXMLDocument alloc] initWithXMLString:[[[XML elementsForName:@"html"] objectAtIndex:0] stringValue] options:MGMXMLDocumentTidyHTML error:nil] autorelease] rootElement];
	NSArray *messages = [(MGMXMLElement *)[html childAtIndex:0] elementsForName:@"div"];
	NSMutableArray *info = [NSMutableArray array];
	for (unsigned int i=0; i<[messages count]; i++) {
		MGMXMLElement *message = [messages objectAtIndex:i];
		NSString *messageID = [[message attributeForName:MGMIID] stringValue];
		if (messageID) {
			for (unsigned int m=0; m<[messagesInfoKeys count]; m++) {
				NSDictionary *messageInfo = [messagesInfo objectForKey:[messagesInfoKeys objectAtIndex:m]];
				if ([[messageInfo objectForKey:MGMIID] isEqualToString:messageID]) {
					NSMutableDictionary *thisInfo = [NSMutableDictionary dictionary];
					[thisInfo setObject:[[messageInfo objectForKey:MGMIPhoneNumber] phoneFormatWithAreaCode:[instance userAreaCode]] forKey:MGMIPhoneNumber];
					[thisInfo setObject:messageID forKey:MGMIID];
					[thisInfo setObject:[NSDate dateWithTimeIntervalSince1970:[[NSDecimalNumber decimalNumberWithString:[messageInfo objectForKey:MGMIStartTime]] longLongValue]/1000] forKey:MGMITime];
					[thisInfo setObject:[messageInfo objectForKey:MGMIRead] forKey:MGMIRead];
					[thisInfo setObject:[messageInfo objectForKey:MGMIStarred] forKey:MGMIStarred];
					[thisInfo setObject:[messageInfo objectForKey:MGMISpam] forKey:MGMISpam];
					[thisInfo setObject:[messageInfo objectForKey:MGMITrash] forKey:MGMITrash];
					
					[thisInfo setObject:[messageInfo objectForKey:MGMIType] forKey:MGMIType];
					int type = [[thisInfo objectForKey:MGMIType] intValue];
					if (type==MGMIVoicemailType) {
						[thisInfo setObject:[NSNumber numberWithBool:[[message XMLString] containsString:@"gc-message-transcript-rate-up-active"]] forKey:MGMIUseful];
						NSMutableString *transcript = [NSMutableString string];
						NSArray *words = [[[[message childAtIndex:0] nodesForXPath:[NSString stringWithFormat:@"/html[1]/body[1]/div[%d]/div[1]/div[2]/table[1]/tr[1]/td[3]/div[1]/table[1]/tr[2]/td[2]/table[1]/tr[2]/td[1]/div[1]/div[1]/table[1]/tr[1]/td[2]/div[1]/div[1]/table[1]/tr[1]/td[1]/div[1]", i+1] error:nil] objectAtIndex:0] elementsForName:@"span"];
						for (unsigned int w=0; w<[words count]; w++) {
							if (w==0)
								[transcript appendString:[[words objectAtIndex:w] stringValue]];
							else
								[transcript appendFormat:@" %@", [[words objectAtIndex:w] stringValue]];
						}
						[thisInfo setObject:transcript forKey:MGMIText];
					} else if (type==MGMISMSInType || type==MGMISMSOutType) {
						NSArray *messagesXML = [[message childAtIndex:0] nodesForXPath:[NSString stringWithFormat:@"/html[1]/body[1]/div[%d]/div[1]/div[2]/table[1]/tr[1]/td[3]/div[1]/table[1]/tr[2]/td[2]/table[1]/tr[2]/td[1]/div[1]/div[1]/table[1]/tr[1]/td[2]/div[1]/div[1]/div[1]/div", i+1] error:nil];
						NSMutableArray *messagesArray = [NSMutableArray array];
						for (unsigned int m=0; m<[messagesXML count]; m++) {
							NSAutoreleasePool *pool = [NSAutoreleasePool new];
							NSString *messageString = [[messagesXML objectAtIndex:m] XMLString];
							if (![messageString hasPrefix:@"<div class=\"gc-message-sms-more\">"]) {
								[messagesArray addObject:[self parseMessageWithHTML:messageString info:thisInfo]];
							} else {
								m++;
								NSArray *moreMessages = [(MGMXMLElement *)[messagesXML objectAtIndex:m] elementsForName:@"div"];
								for (unsigned int ms=0; ms<[moreMessages count]; ms++) {
									NSAutoreleasePool *pool = [NSAutoreleasePool new];
									NSString *messageString = [[moreMessages objectAtIndex:ms] XMLString];
									[messagesArray addObject:[self parseMessageWithHTML:messageString info:thisInfo]];
									[pool drain];
								}
							}
							[pool drain];
						}
						[thisInfo setObject:messagesArray forKey:MGMIMessages];
					}
					
					[info addObject:thisInfo];
					break;
				}
			}
		}
	}
	[info sortUsingFunction:dateSort context:nil];
	
	NSDictionary *thisInfo = [theInfo objectForKey:MGMConnectionObject];
	if ([thisInfo objectForKey:MGMIDidReceiveInfo]!=nil) {
		SEL selector = NSSelectorFromString([thisInfo objectForKey:MGMIDidReceiveInfo]);
		id delegate = [thisInfo objectForKey:MGMIDelegate];
		NSMethodSignature *signature = [delegate methodSignatureForSelector:selector];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation setArgument:&info atIndex:2];
			[invocation setArgument:&instance atIndex:3];
			[invocation invokeWithTarget:delegate];
		} else {
			NSLog(@"MGMInbox Info: %@", info);
		}
	} else {
		NSLog(@"MGMInbox Info: %@", info);
	}
}
- (NSDictionary *)parseMessageWithHTML:(NSString *)theHTML info:(NSDictionary *)theInfo {
	NSMutableDictionary *message = [NSMutableDictionary dictionary];
	NSRange range;
	range = [theHTML rangeOfString:@"<span class=\"gc-message-sms-from\">"];
	if (range.location!=NSNotFound) {
		NSString *string = [theHTML substringFromIndex:range.location+range.length];
		
		range = [string rangeOfString:@"</span>"];
		if (range.location==NSNotFound) NSLog(@"failed 0010");
		[message setObject:[NSNumber numberWithBool:[[string substringWithRange:NSMakeRange(0, range.location)] containsString:@"Me:"]] forKey:MGMIYou];
	}
	range = [theHTML rangeOfString:@"<span class=\"gc-message-sms-text\">"];
	if (range.location!=NSNotFound) {
		NSString *string = [theHTML substringFromIndex:range.location + range.length];
		
		range = [string rangeOfString:@"</span>"];
		if (range.location==NSNotFound) NSLog(@"failed 0011");
		NSString *messageText = [[string substringWithRange:NSMakeRange(0, range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		messageText = [messageText replace:@"\n" with:@"<br />"];
		messageText = [messageText replace:@"\r" with:@""];
		[message setObject:messageText forKey:MGMIText];
	}
	range = [theHTML rangeOfString:@"<span class=\"gc-message-sms-time\">"];
	if (range.location!=NSNotFound) {
		NSString *string = [theHTML substringFromIndex:range.location+range.length];
		
		range = [string rangeOfString:@"</span>"];
		if (range.location==NSNotFound) NSLog(@"failed 0012");
		[message setObject:[[string substringWithRange:NSMakeRange(0, range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:MGMITime];
	}
	return message;
}

- (void)deleteEntriesForever:(NSArray *)theEntries delegate:(id)theDelegate {
	[self deleteEntriesForever:theEntries delegate:theDelegate didFailWithError:@selector(delete:didFailWithError:instance:) didFinish:@selector(deleteDidFinish:instance:)];
}
- (void)deleteEntriesForever:(NSArray *)theEntries delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
#if MGMInboxDebug
	NSLog(@"MGMInbox Will delete %@", theEntries);
#endif
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[info setObject:theEntries forKey:MGMIEntries];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMIDeleteForeverURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	NSMutableString *body = [NSMutableString string];
	for (int i=0; i<[theEntries count]; i++) {
		[body appendFormat:@"messages=%@&", [theEntries objectAtIndex:i]];
	}
	[body appendFormat:@"_rnr_se=%@", [instance rnr_se]];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(sendRequest:didFailWithError:) didFinish:@selector(sendRequestDidFinish:) invisible:MGMInboxInvisible object:info];
}
- (void)deleteEntries:(NSArray *)theEntries delegate:(id)theDelegate {
	[self deleteEntries:theEntries delegate:theDelegate didFailWithError:@selector(delete:didFailWithError:instance:) didFinish:@selector(deleteDidFinish:instance:)];
}
- (void)deleteEntries:(NSArray *)theEntries delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
#if MGMInboxDebug
	NSLog(@"MGMInbox Will delete %@", theEntries);
#endif
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[info setObject:theEntries forKey:MGMIEntries];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMIDeleteURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	NSMutableString *body = [NSMutableString string];
	for (int i=0; i<[theEntries count]; i++) {
		[body appendFormat:@"messages=%@&", [theEntries objectAtIndex:i]];
	}
	[body appendFormat:@"trash=1&_rnr_se=%@", [instance rnr_se]];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(sendRequest:didFailWithError:) didFinish:@selector(sendRequestDidFinish:) invisible:MGMInboxInvisible object:info];
}

- (void)markEntries:(NSArray *)theEntries read:(BOOL)isRead delegate:(id)theDelegate {
	[self markEntries:theEntries read:isRead delegate:theDelegate didFailWithError:@selector(mark:didFailWithError:instance:) didFinish:@selector(markDidFinish:instance:)];
}
- (void)markEntries:(NSArray *)theEntries read:(BOOL)isRead delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
#if MGMInboxDebug
	NSLog(@"MGMInbox Will delete %@", theEntries);
#endif
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[info setObject:theEntries forKey:MGMIEntries];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMIMarkURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	NSMutableString *body = [NSMutableString string];
	for (int i=0; i<[theEntries count]; i++) {
		[body appendFormat:@"messages=%@&", [theEntries objectAtIndex:i]];
	}
	[body appendFormat:@"read=%d&_rnr_se=%@", (isRead ? 1 : 0), [instance rnr_se]];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(sendRequest:didFailWithError:) didFinish:@selector(sendRequestDidFinish:) invisible:MGMInboxInvisible object:info];
}

- (void)reportEntries:(NSArray *)theEntries delegate:(id)theDelegate {
	[self reportEntries:theEntries delegate:theDelegate didFailWithError:@selector(report:didFailWithError:instance:) didFinish:@selector(reportDidFinish:instance:)];
}
- (void)reportEntries:(NSArray *)theEntries delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
#if MGMInboxDebug
	NSLog(@"MGMInbox Will delete %@", theEntries);
#endif
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[info setObject:theEntries forKey:MGMIEntries];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMIReportURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	NSMutableString *body = [NSMutableString string];
	for (int i=0; i<[theEntries count]; i++) {
		[body appendFormat:@"messages=%@&", [theEntries objectAtIndex:i]];
	}
	[body appendFormat:@"spam=1&_rnr_se=%@", [instance rnr_se]];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(sendRequest:didFailWithError:) didFinish:@selector(sendRequestDidFinish:) invisible:MGMInboxInvisible object:info];
}

- (void)starEntries:(NSArray *)theEntries starred:(BOOL)isStarred delegate:(id)theDelegate {
	[self starEntries:theEntries starred:isStarred delegate:theDelegate didFailWithError:@selector(star:didFailWithError:instance:) didFinish:@selector(starDidFinish:instance:)];
}
- (void)starEntries:(NSArray *)theEntries starred:(BOOL)isStarred delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
#if MGMInboxDebug
	NSLog(@"MGMInbox Will delete %@", theEntries);
#endif
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	[info setObject:theEntries forKey:MGMIEntries];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMIStarURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	NSMutableString *body = [NSMutableString string];
	for (int i=0; i<[theEntries count]; i++) {
		[body appendFormat:@"messages=%@&", [theEntries objectAtIndex:i]];
	}
	[body appendFormat:@"star=%d&_rnr_se=%@", (isStarred ? 1 : 0), [instance rnr_se]];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(sendRequest:didFailWithError:) didFinish:@selector(sendRequestDidFinish:) invisible:MGMInboxInvisible object:info];
}

- (void)sendMessage:(NSString *)theMessage phoneNumbers:(NSArray *)thePhoneNumbers smsID:(NSString *)theID delegate:(id)theDelegate {
	[self sendMessage:theMessage phoneNumbers:thePhoneNumbers smsID:theID delegate:theDelegate didFailWithError:@selector(message:didFailWithError:instance:) didFinish:@selector(messageDidFinish:instance:)];
}
- (void)sendMessage:(NSString *)theMessage phoneNumbers:(NSArray *)thePhoneNumbers smsID:(NSString *)theID delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish {
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:theDelegate forKey:MGMIDelegate];
	if (didFinish!=NULL)
		[info setObject:NSStringFromSelector(didFinish) forKey:MGMIDidFinish];
	if (didFailWithError!=NULL)
		[info setObject:NSStringFromSelector(didFailWithError) forKey:MGMIDidFailWithError];
	if (theMessage!=nil)
		[info setObject:theMessage forKey:MGMIMessage];
	if (thePhoneNumbers!=nil)
		[info setObject:thePhoneNumbers forKey:MGMIPhoneNumbers];
	if (theID==nil) theID = @"";
	[info setObject:theID forKey:MGMIID];
	if (thePhoneNumbers==nil || [thePhoneNumbers count]==0 || theMessage==nil || [theMessage isEqual:@""]) {
		NSMethodSignature *signature = [theDelegate methodSignatureForSelector:didFailWithError];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:didFailWithError];
			[invocation setArgument:&info atIndex:2];
			NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.MGMInbox.SendMessage" code:1 userInfo:nil];
			[invocation setArgument:&error atIndex:3];
			[invocation invokeWithTarget:theDelegate];
		}
		return;
	}
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMISMSSendURL]];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	NSMutableString *body = [NSMutableString stringWithFormat:@"id=%@&phoneNumber=", theID];
	for (int i=0; i<[thePhoneNumbers count]; i++) {
		if ([thePhoneNumbers count]!=1)
			[body appendFormat:@"%@%%2C%%20", [[thePhoneNumbers objectAtIndex:i] addPercentEscapes]];
		else
			[body appendString:[[thePhoneNumbers objectAtIndex:i] addPercentEscapes]];
	}
	[body appendFormat:@"&text=%@&sendErrorSms=0&_rnr_se=%@", [theMessage addPercentEscapes], [instance rnr_se]];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(sendRequest:didFailWithError:) didFinish:@selector(sendRequestDidFinish:) invisible:MGMInboxInvisible object:info];
}

- (void)sendRequest:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSDictionary *info = [theInfo objectForKey:MGMConnectionObject];
	if ([info objectForKey:MGMIDidFailWithError]!=nil) {
		SEL selector = NSSelectorFromString([info objectForKey:MGMIDidFailWithError]);
		id delegate = [info objectForKey:MGMIDelegate];
		NSMethodSignature *signature = [delegate methodSignatureForSelector:selector];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation setArgument:&theInfo atIndex:2];
			[invocation setArgument:&theError atIndex:3];
			[invocation setArgument:&instance atIndex:4];
			[invocation invokeWithTarget:delegate];
		} else {
			NSLog(@"MGMInbox Send Request Error: %@", theError);
		}
	} else {
		NSLog(@"MGMInbox Send Request Error: %@", theError);
	}
}
- (void)sendRequestDidFinish:(NSDictionary *)theInfo {
#if MGMInboxDebug
	NSLog(@"MGMInbox Did Send Request %@", [[[NSString alloc] initWithData:[theInfo objectForKey:MGMConnectionData] encoding:NSUTF8StringEncoding] autorelease]);
#endif
	NSMutableDictionary *thisInfo = [NSMutableDictionary dictionaryWithDictionary:[theInfo objectForKey:MGMConnectionObject]];
	[thisInfo setObject:[theInfo objectForKey:MGMConnectionData] forKey:MGMConnectionData];
	if ([thisInfo objectForKey:MGMIDidFinish]!=nil) {
		SEL selector = NSSelectorFromString([thisInfo objectForKey:MGMIDidFinish]);
		id delegate = [thisInfo objectForKey:MGMIDelegate];
		NSMethodSignature *signature = [delegate methodSignatureForSelector:selector];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation setArgument:&thisInfo atIndex:2];
			[invocation setArgument:&instance atIndex:3];
			[invocation invokeWithTarget:delegate];
		}
	}
}
@end