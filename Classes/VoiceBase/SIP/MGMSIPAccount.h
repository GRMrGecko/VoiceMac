//
//  MGMSIPAccount.h
//  VoiceBase
//
//  Created by Mr. Gecko on 9/10/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import <pjsua-lib/pjsua.h>

extern NSString * const MGMSIPAccountFullName;
extern NSString * const MGMSIPAccountUserName;
extern NSString * const MGMSIPAccountDomain;
extern NSString * const MGMSIPAccountRegistrar;
extern NSString * const MGMSIPAccountSIPAddress;
extern NSString * const MGMSIPAccountProxy;
extern NSString * const MGMSIPAccountProxyPort;
extern NSString * const MGMSIPAccountRegisterTimeout;
extern const int MGMSIPAccountDefaultProxyPort;

@class MGMSIPCall, MGMSIPURL;

@protocol MGMSIPAccountDelegate <NSObject>
- (NSString *)password;
- (void)loggedIn;
- (void)loginErrored;
- (void)loggedOut;
- (void)logoutErrored;
- (void)registrationChanged;
- (void)receivedNewCall:(MGMSIPCall *)theCall;
- (void)startingNewCall:(MGMSIPCall *)theCall;
- (void)gotNewCall:(MGMSIPCall *)theCall;
@end

@interface MGMSIPAccount : NSObject {
	id<MGMSIPAccountDelegate> delegate;
	NSString *fullName;
	NSString *userName;
	NSString *domain;
	NSString *registrar;
	NSString *SIPAddress;
	NSString *proxy;
	int proxyPort;
	int reregisterTimeout;
	NSTimer *reregisterTimer;
	
	pjsua_acc_id identifier;
	
	NSMutableArray *calls;
	
	NSString *lastError;
}
- (id)initWithSettings:(NSDictionary *)theSettings;
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName domain:(NSString *)theDomain;
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName domain:(NSString *)theDomain SIPAddress:(NSString *)theSIPAddress;
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName domain:(NSString *)theDomain SIPAddress:(NSString *)theSIPAddress registrar:(NSString *)theRegistrar;
- (BOOL)informationComplete;
- (id<MGMSIPAccountDelegate>)delegate;
- (void)setDelegate:(id)theDelegate;
- (NSString *)fullName;
- (void)setFullName:(NSString *)theFullName;
- (NSString *)userName;
- (void)setUserName:(NSString *)theUserName;
- (NSString *)domain;
- (void)setDomain:(NSString *)theDomain;
- (NSString *)registrar;
- (void)setRegistrar:(NSString *)theRegistrar;
- (NSString *)SIPAddress;
- (void)setSIPAddress:(NSString *)theSIPAddress;
- (NSString *)proxy;
- (void)setProxy:(NSString *)theProxy;
- (int)proxyPort;
- (void)setProxyPort:(int)theProxyPort;
- (int)reregisterTimeout;
- (void)setReregisterTimeout:(int)theReregisterTimeout;
- (pjsua_acc_id)identifier;
- (void)setIdentifier:(pjsua_acc_id)theIdentifier;
- (NSString *)password;
- (NSDictionary *)settings;

- (void)setLastError:(NSString *)theError;
- (NSString *)lastError;

- (BOOL)isLoggedIn;
- (void)login;
- (void)loginErrored;
- (void)logout;
- (void)logoutErrored;

- (BOOL)isRegistered;
- (void)reregister;
- (void)setRegistered:(BOOL)isRegistered;
- (int)registrationStatus;
- (NSString *)registrationStatusText;
- (int)registrationExpireTime;

- (BOOL)isOnline;
- (void)setOnline:(BOOL)isOnline;
- (NSString *)onlineStatusText;

- (MGMSIPCall *)addCallWithIdentifier:(int)theIndentifier;
- (MGMSIPCall *)makeCallToNumber:(NSString *)theNumber;
- (MGMSIPCall *)makeCallToSIPURL:(MGMSIPURL *)theURL;
- (NSArray *)calls;
- (MGMSIPCall *)callWithIdentifier:(int)theIdentifier;
- (void)removeCall:(MGMSIPCall *)theCall;
@end
#endif