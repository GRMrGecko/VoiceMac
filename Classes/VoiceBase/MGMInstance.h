//
//  MGMInstance.h
//  VoiceBase
//
//  Created by Mr. Gecko on 8/15/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@class MGMInstance, MGMUser, MGMHTTPCookieStorage, MGMURLConnectionManager, MGMWhitePages, MGMInbox, MGMContacts;

#define MGMInstanceDebug 0

extern NSString * const MGMVoiceIndexURL;
extern NSString * const MGMLoginURL;
extern NSString * const MGMLoginBody;
extern NSString * const MGMXPCPath;
extern NSString * const MGMCheckPath;
extern NSString * const MGMCreditURL;
extern NSString * const MGMCallURL;
extern NSString * const MGMCallCancelURL;

extern NSString * const MGMPostMethod;
extern NSString * const MGMURLForm;
extern NSString * const MGMContentType;

extern NSString * const MGMPhoneNumber;
extern NSString * const MGMPhone;
extern NSString * const MGMName;
extern NSString * const MGMType;

extern NSString * const MGMSContactsSourceKey;
extern NSString * const MGMSContactsActionKey;

extern NSString * const MGMUCAll;
extern NSString * const MGMUCInbox;
extern NSString * const MGMUCMissed;
extern NSString * const MGMUCPlaced;
extern NSString * const MGMUCReceived;
extern NSString * const MGMUCRecorded;
extern NSString * const MGMUCSMS;
extern NSString * const MGMUCSpam;
extern NSString * const MGMUCStarred;
extern NSString * const MGMUCTrash;
extern NSString * const MGMUCUnread;
extern NSString * const MGMUCVoicemail;

@protocol MGMInstanceDelegate <NSObject>
- (void)loginError:(NSError *)theError;
- (void)loginSuccessful;
- (void)updatedContacts;
- (void)updateUnreadCount:(int)theCount;
- (void)updateVoicemail;
- (void)updateSMS;
- (void)updateCredit:(NSString *)credit;
@end

@interface MGMInstance : NSObject {
	id<MGMInstanceDelegate> delegate;
	MGMUser *user;
	MGMHTTPCookieStorage *cookeStorage;
	MGMURLConnectionManager *connectionManager;
	MGMInbox *inbox;
	MGMContacts *contacts;
	
	int webLoginTries;
	BOOL loggedIn;
	NSString *GALX;
	
	NSString *XPCURL;
	NSString *XPCCD;
	NSString *rnr_se;
	
	NSString *userName;
	NSString *userNumber;
	NSString *userAreacode;
	NSMutableArray *userPhoneNumbers;
	
	NSTimer *checkTimer;
	NSDictionary *unreadCounts;
	NSTimer *creditTimer;
	
	BOOL checkingAccount;
}
+ (id)instanceWithUser:(MGMUser *)theUser delegate:(id)theDelegate;
+ (id)instanceWithUser:(MGMUser *)theUser delegate:(id)theDelegate isCheck:(BOOL)isCheck;
- (id)initWithUser:(MGMUser *)theUser delegate:(id)theDelegate isCheck:(BOOL)isCheck;

- (void)registerSettings;

- (void)stop;

- (void)setDelegate:(id)theDelegate;
- (id<MGMInstanceDelegate>)delegate;
- (MGMUser *)user;
- (MGMHTTPCookieStorage *)cookieStorage;
- (MGMURLConnectionManager *)connectionManager;
- (MGMInbox *)inbox;
- (MGMContacts *)contacts;

- (NSString *)XPCURL;
- (NSString *)XPCCD;
- (NSString *)rnr_se;

- (NSString *)userName;
- (NSString *)userNumber;
- (NSString *)userAreaCode;
- (NSArray *)userPhoneNumbers;
- (NSDictionary *)unreadCounts;

- (void)login;
- (BOOL)isLoggedIn;
- (void)checkTimer;
- (void)creditTimer;

- (void)placeCall:(NSString *)thePhoneNumber usingPhone:(int)thePhone delegate:(id)theDelegate;
- (void)placeCall:(NSString *)thePhoneNumber usingPhone:(int)thePhone delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;
- (void)cancelCallWithDelegate:(id)theDelegate;
- (void)cancelCallWithDelegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish;
@end