//
//  MGMInbox.h
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

#import <Foundation/Foundation.h>

@class MGMDelegateInfo, MGMInstance, MGMURLConnectionManager;

#define MGMInboxDebug 0

extern NSString * const MGMIVoiceMailDownloadURL;

extern NSString * const MGMIPhoneNumber;
extern NSString * const MGMIID;
extern NSString * const MGMIUniqueId;
extern NSString * const MGMIText;
extern NSString * const MGMIYou;
extern NSString * const MGMITime;
extern NSString * const MGMIStartTime;
extern NSString * const MGMIInfo;
extern NSString * const MGMIMessages;
extern NSString * const MGMIUseful;
extern NSString * const MGMIRead;
extern NSString * const MGMIType;
extern NSString * const MGMIStarred;
extern NSString * const MGMISpam;
extern NSString * const MGMITrash;

extern const int MGMIMissedType;
extern const int MGMIReceivedType;
extern const int MGMIVoicemailType;
extern const int MGMIRecordedType;
extern const int MGMIPlacedType;
extern const int MGMISMSInType;
extern const int MGMISMSOutType;

@interface MGMInbox : NSObject {
	MGMInstance *instance;
	MGMURLConnectionManager *connectionManager;
}
+ (id)inboxWithInstance:(MGMInstance *)theInstance;
- (id)initWithInstance:(MGMInstance *)theInstance;

- (void)stop;

- (void)getInboxForPage:(int)thePage delegate:(id)theDelegate;
- (void)getInboxForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getStarredForPage:(int)thePage delegate:(id)theDelegate;
- (void)getStarredForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getSpamForPage:(int)thePage delegate:(id)theDelegate;
- (void)getSpamForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getTrashForPage:(int)thePage delegate:(id)theDelegate;
- (void)getTrashForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getVoicemailForPage:(int)thePage delegate:(id)theDelegate;
- (void)getVoicemailForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getSMSForPage:(int)thePage delegate:(id)theDelegate;
- (void)getSMSForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getRecordedCallsForPage:(int)thePage delegate:(id)theDelegate;
- (void)getRecordedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getPlacedCallsForPage:(int)thePage delegate:(id)theDelegate;
- (void)getPlacedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getReceivedCallsForPage:(int)thePage delegate:(id)theDelegate;
- (void)getReceivedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)getMissedCallsForPage:(int)thePage delegate:(id)theDelegate;
- (void)getMissedCallsForPage:(int)thePage delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didReceiveInfo:(SEL)didReceiveInfo;

- (void)retrieveURL:(NSString *)theURL page:(int)thePage info:(MGMDelegateInfo *)theInfo;
- (NSDictionary *)parseMessageWithHTML:(NSString *)theHTML info:(NSDictionary *)theInfo;

- (void)deleteEntriesForever:(NSArray *)theEntries delegate:(id)theDelegate;
- (void)deleteEntriesForever:(NSArray *)theEntries delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;
- (void)deleteEntries:(NSArray *)theEntries delegate:(id)theDelegate;
- (void)deleteEntries:(NSArray *)theEntries delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;

- (void)markEntries:(NSArray *)theEntries read:(BOOL)isRead delegate:(id)theDelegate;
- (void)markEntries:(NSArray *)theEntries read:(BOOL)isRead delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;

- (void)reportEntries:(NSArray *)theEntries delegate:(id)theDelegate;
- (void)reportEntries:(NSArray *)theEntries delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;

- (void)starEntries:(NSArray *)theEntries starred:(BOOL)isStarred delegate:(id)theDelegate;
- (void)starEntries:(NSArray *)theEntries starred:(BOOL)isStarred delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;

- (void)sendMessage:(NSString *)theMessage phoneNumbers:(NSArray *)thePhoneNumbers smsID:(NSString *)theID delegate:(id)theDelegate;
- (void)sendMessage:(NSString *)theMessage phoneNumbers:(NSArray *)thePhoneNumbers smsID:(NSString *)theID delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;
@end