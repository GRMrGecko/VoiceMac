//
//  MGMSIPAccount.h
//  VoiceBase
//
//  Created by Mr. Gecko on 9/10/10.
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

#if MGMSIPENABLED
#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>

extern NSString * const MGMSIPAccountFullName;
extern NSString * const MGMSIPAccountUserName;
extern NSString * const MGMSIPAccountDomain;
extern NSString * const MGMSIPAccountRegistrar;
extern NSString * const MGMSIPAccountSIPAddress;
extern NSString * const MGMSIPAccountProxy;
extern NSString * const MGMSIPAccountProxyPort;
extern NSString * const MGMSIPAccountRegisterTimeout;
extern NSString * const MGMSIPAccountTransport;
extern NSString * const MGMSIPAccountDTMFToneType;
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
	int transport;
	int dtmfToneType;
	
	pjsua_acc_id identifier;
	BOOL registered;
	
	NSMutableArray *calls;
	
	NSString *lastError;
}
- (id)initWithSettings:(NSDictionary *)theSettings;
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName registrar:(NSString *)theRegistrar;
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName registrar:(NSString *)theRegistrar SIPAddress:(NSString *)theSIPAddress;
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName registrar:(NSString *)theRegistrar SIPAddress:(NSString *)theSIPAddress domain:(NSString *)theDomain;
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
- (int)transport;
- (void)setTransport:(int)theTransport;
- (int)dtmfToneType;
- (void)setDTMFToneType:(int)theType;
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

- (void)registrationStateChanged;
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