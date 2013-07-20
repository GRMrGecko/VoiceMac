//
//  MGMSIPAccount.m
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
#import "MGMSIPAccount.h"
#import "MGMSIP.h"
#import "MGMSIPCall.h"
#import "MGMSIPURL.h"
#import "MGMAddons.h"

NSString * const MGMSIPAccountFullName = @"MGMSIPAccountFullName";
NSString * const MGMSIPAccountUserName = @"MGMSIPAccountUserName";
NSString * const MGMSIPAccountDomain = @"MGMSIPAccountDomain";
NSString * const MGMSIPAccountRegistrar = @"MGMSIPAccountRegistrar";
NSString * const MGMSIPAccountSIPAddress = @"MGMSIPAccountSIPAddress";
NSString * const MGMSIPAccountProxy = @"MGMSIPAccountProxy";
NSString * const MGMSIPAccountProxyPort = @"MGMSIPAccountProxyPort";
NSString * const MGMSIPAccountRegisterTimeout = @"MGMSIPAccountRegisterTimeout";
NSString * const MGMSIPAccountTransport = @"MGMSIPAccountTransport";
NSString * const MGMSIPAccountDTMFToneType = @"MGMSIPAccountDTMFToneType";

const int MGMSIPAccountDefaultProxyPort = 5060;

const int MGMSIPAccountReregisterTimeoutMin = 60;
const int MGMSIPAccountReregisterTimeoutMax = 3600;
const int MGMSIPAccountReregisterTimeoutDefault = 300;

@implementation MGMSIPAccount
- (id)initWithSettings:(NSDictionary *)theSettings {
	if ((self = [self init])) {
		if ([theSettings objectForKey:MGMSIPAccountUserName]==nil || [[theSettings objectForKey:MGMSIPAccountUserName] isEqual:@""] || [theSettings objectForKey:MGMSIPAccountRegistrar]==nil || [[theSettings objectForKey:MGMSIPAccountRegistrar] isEqual:@""]) {
			[self release];
			self = nil;
		} else {
			if ([theSettings objectForKey:MGMSIPAccountFullName]!=nil && ![[theSettings objectForKey:MGMSIPAccountFullName] isEqual:@""])
				fullName = [[theSettings objectForKey:MGMSIPAccountFullName] copy];
			userName = [[theSettings objectForKey:MGMSIPAccountUserName] copy];
			registrar = [[theSettings objectForKey:MGMSIPAccountRegistrar] copy];
			if ([theSettings objectForKey:MGMSIPAccountDomain]!=nil && ![[theSettings objectForKey:MGMSIPAccountDomain] isEqual:@""])
				domain = [[theSettings objectForKey:MGMSIPAccountDomain] copy];
			if ([theSettings objectForKey:MGMSIPAccountSIPAddress]!=nil && ![[theSettings objectForKey:MGMSIPAccountSIPAddress] isEqual:@""])
				SIPAddress = [[theSettings objectForKey:MGMSIPAccountSIPAddress] copy];
			if ([theSettings objectForKey:MGMSIPAccountProxy]!=nil && ![[theSettings objectForKey:MGMSIPAccountProxy] isEqual:@""])
				proxy = [[theSettings objectForKey:MGMSIPAccountProxy] copy];
			if ([theSettings objectForKey:MGMSIPAccountProxyPort]!=nil && [[theSettings objectForKey:MGMSIPAccountProxyPort] intValue]!=0)
				proxyPort = [[theSettings objectForKey:MGMSIPAccountProxyPort] intValue];
			else
				proxyPort = 0;
			if ([theSettings objectForKey:MGMSIPAccountRegisterTimeout]!=nil && [[theSettings objectForKey:MGMSIPAccountRegisterTimeout] intValue]!=0)
				reregisterTimeout = [[theSettings objectForKey:MGMSIPAccountRegisterTimeout] intValue];
			if ([theSettings objectForKey:MGMSIPAccountTransport]!=nil)
				transport = [[theSettings objectForKey:MGMSIPAccountTransport] intValue];
#if TARGET_OS_IPHONE
			else
				transport = 1;
#endif
			if ([theSettings objectForKey:MGMSIPAccountDTMFToneType]!=nil)
				dtmfToneType = [[theSettings objectForKey:MGMSIPAccountDTMFToneType] intValue];
		}
	}
	return self;
}
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName registrar:(NSString *)theRegistrar {
	return [self initWithFullName:theFullName userName:theUserName registrar:theRegistrar SIPAddress:nil];
}
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName registrar:(NSString *)theRegistrar SIPAddress:(NSString *)theSIPAddress {
	return [self initWithFullName:theFullName userName:theUserName registrar:theRegistrar SIPAddress:theSIPAddress domain:nil];
}
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName registrar:(NSString *)theRegistrar SIPAddress:(NSString *)theSIPAddress domain:(NSString *)theDomain {
	if (theUserName==nil || theRegistrar==nil) return nil;
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	if (theFullName!=nil)
		[settings setObject:theFullName forKey:MGMSIPAccountFullName];
	[settings setObject:theUserName forKey:MGMSIPAccountUserName];
	[settings setObject:theRegistrar forKey:MGMSIPAccountRegistrar];
	if (theSIPAddress!=nil)
		[settings setObject:theSIPAddress forKey:MGMSIPAccountSIPAddress];
	if (theDomain!=nil)
		[settings setObject:theDomain forKey:MGMSIPAccountDomain];
	return [self initWithSettings:settings];
}
- (id)init {
	if ((self = [super init])) {
		reregisterTimeout = MGMSIPAccountReregisterTimeoutDefault;
		identifier = PJSUA_INVALID_ID;
		registered = NO;
		calls = [NSMutableArray new];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnected:) name:MGMNetworkConnectedNotification object:nil];
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[calls release];
	[fullName release];
	[userName release];
	[domain release];
	[registrar release];
	[SIPAddress release];
	[proxy release];
	[super dealloc];
}

- (BOOL)informationComplete {
	return ((delegate!=nil && [delegate respondsToSelector:@selector(password)]) && userName!=nil && (registrar!=nil || [self SIPAddress]!=nil));
}
- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@", [super description], [self SIPAddress]];
}
- (id<MGMSIPAccountDelegate>)delegate {
	return delegate;
}
- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}
- (NSString *)fullName {
	return fullName;
}
- (void)setFullName:(NSString *)theFullName {
	[fullName release];
	fullName = [theFullName copy];
}
- (NSString *)userName {
	return userName;
}
- (void)setUserName:(NSString *)theUserName {
	if (theUserName==nil || [theUserName isEqual:@""]) return;
	[userName release];
	userName = [theUserName copy];
}
- (NSString *)domain {
	if ((domain==nil || [domain isEqual:@""]) && registrar!=nil) return registrar;
	return domain;
}
- (void)setDomain:(NSString *)theDomain {
	[domain release];
	domain = [theDomain copy];
}
- (NSString *)registrar {
	return registrar;
}
- (void)setRegistrar:(NSString *)theRegistrar {
	[registrar release];
	registrar = [theRegistrar copy];
}
- (NSString *)SIPAddress {
	if (SIPAddress==nil && registrar!=nil && userName!=nil)
		return [NSString stringWithFormat:@"%@@%@", userName, registrar];
	return SIPAddress;
}
- (void)setSIPAddress:(NSString *)theSIPAddress {
	[SIPAddress release];
	SIPAddress = [theSIPAddress copy];
}
- (NSString *)proxy {
	return proxy;
}
- (void)setProxy:(NSString *)theProxy {
	[proxy release];
	proxy = [theProxy copy];
}
- (int)proxyPort {
	if (proxyPort==0) return MGMSIPAccountDefaultProxyPort;
	return proxyPort;
}
- (void)setProxyPort:(int)theProxyPort {
	proxyPort = theProxyPort;
}
- (int)reregisterTimeout {
	return reregisterTimeout;
}
- (void)setReregisterTimeout:(int)theReregisterTimeout {
	if (theReregisterTimeout==0)
		reregisterTimeout = MGMSIPAccountReregisterTimeoutDefault;
	else if (theReregisterTimeout < MGMSIPAccountReregisterTimeoutMin)
		reregisterTimeout = MGMSIPAccountReregisterTimeoutMin;
	else if (theReregisterTimeout > MGMSIPAccountReregisterTimeoutMax)
		reregisterTimeout = MGMSIPAccountReregisterTimeoutMax;
	else
		reregisterTimeout = theReregisterTimeout;
}
- (int)transport {
	return transport;
}
- (void)setTransport:(int)theTransport {
	transport = theTransport;
}
- (int)dtmfToneType {
	return dtmfToneType;
}
- (void)setDTMFToneType:(int)theType {
	dtmfToneType = theType;
}
- (pjsua_acc_id)identifier {
	return identifier;
}
- (void)setIdentifier:(pjsua_acc_id)theIdentifier {
	identifier = theIdentifier;
}
- (NSString *)password {
	NSString *password = nil;
	if (delegate!=nil && [delegate respondsToSelector:@selector(password)])
		password = [delegate password];
	return password;
}
- (NSDictionary *)settings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	if (fullName!=nil)
		[settings setObject:fullName forKey:MGMSIPAccountFullName];
	if (userName!=nil)
		[settings setObject:userName forKey:MGMSIPAccountUserName];
	if (domain!=nil)
		[settings setObject:domain forKey:MGMSIPAccountDomain];
	if (registrar!=nil)
		[settings setObject:registrar forKey:MGMSIPAccountRegistrar];
	if (SIPAddress!=nil)
		[settings setObject:SIPAddress forKey:MGMSIPAccountSIPAddress];
	if (proxy!=nil)
		[settings setObject:proxy forKey:MGMSIPAccountProxy];
	if (proxyPort!=0)
		[settings setObject:[NSNumber numberWithInt:proxyPort] forKey:MGMSIPAccountProxyPort];
	if (reregisterTimeout!=0)
		[settings setObject:[NSNumber numberWithInt:reregisterTimeout] forKey:MGMSIPAccountRegisterTimeout];
	[settings setObject:[NSNumber numberWithInt:transport] forKey:MGMSIPAccountTransport];
	[settings setObject:[NSNumber numberWithInt:dtmfToneType] forKey:MGMSIPAccountDTMFToneType];
	return settings;
}

- (void)setLastError:(NSString *)theError {
	[lastError release];
	lastError = [theError copy];
}
- (NSString *)lastError {
	return (lastError!=nil ? lastError : @"");
}

- (BOOL)isLoggedIn {
	return (identifier!=PJSUA_INVALID_ID);
}
- (void)login {
	[[MGMSIP sharedSIP] loginToAccount:self];
}
- (void)loginErrored {
	if (delegate!=nil && [delegate respondsToSelector:@selector(loginErrored)]) [delegate loginErrored];
}
- (void)logout {
	[[MGMSIP sharedSIP] logoutOfAccount:self];
}
- (void)logoutErrored {
	if (delegate!=nil && [delegate respondsToSelector:@selector(logoutErrored)]) [delegate logoutErrored];
}

- (void)registrationStateChanged {
	registered = (([self registrationStatus]/100)==2 && [self registrationExpireTime]>0);
}
- (BOOL)isRegistered {
	return registered;
}
- (void)reregister {
	[self setRegistered:YES];
}
- (void)setRegistered:(BOOL)isRegistered {
	if (identifier==PJSUA_INVALID_ID)
		return;
	
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pjsua_acc_set_registration(identifier, (isRegistered ? PJ_TRUE : PJ_FALSE));
	[self setOnline:isRegistered];
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
}
- (void)networkConnected:(NSNotification *)theNotification {
	if ([self isLoggedIn])
		[self performSelector:@selector(reregister) withObject:nil afterDelay:1.0];
}
- (int)registrationStatus {
	if (identifier==PJSUA_INVALID_ID)
		return 0;
	
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	if (status!=PJ_SUCCESS)
		return 0;
	return accountInfo.status;
}
- (NSString *)registrationStatusText {
	if (identifier==PJSUA_INVALID_ID)
		return nil;
	
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	if (status!=PJ_SUCCESS)
		return nil;
	return [NSString stringWithPJString:accountInfo.status_text];
}
- (int)registrationExpireTime {
	if (identifier==PJSUA_INVALID_ID)
		return -1;
	
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	if (status!=PJ_SUCCESS)
		return -1;
	return accountInfo.expires;
}

- (BOOL)isOnline {
	if (identifier==PJSUA_INVALID_ID)
		return NO;
	
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	if (status!=PJ_SUCCESS)
		return NO;
	return (accountInfo.online_status==PJ_TRUE);
}
- (void)setOnline:(BOOL)isOnline {
	if ([self identifier]==PJSUA_INVALID_ID)
		return;
	
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pj_status_t status = pjsua_acc_set_online_status(identifier, (isOnline ? PJ_TRUE : PJ_FALSE));
	if (status==PJ_SUCCESS) {
		[reregisterTimer invalidate];
		[reregisterTimer release];
		reregisterTimer = nil;
		if (isOnline)
			reregisterTimer = [[NSTimer scheduledTimerWithTimeInterval:(float)reregisterTimeout target:self selector:@selector(reregister) userInfo:nil repeats:YES] retain];
	}
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
}
- (NSString *)onlineStatusText {
	if (identifier==PJSUA_INVALID_ID)
		return nil;
	
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	if (status!=PJ_SUCCESS)
		return nil;
	return [NSString stringWithPJString:accountInfo.online_status_text];
}

- (MGMSIPCall *)addCallWithIdentifier:(int)theIndentifier {
	MGMSIPCall *call = [[[MGMSIPCall alloc] initWithIdentifier:theIndentifier account:self] autorelease];
	[calls addObject:call];
	return call;
}
- (MGMSIPCall *)makeCallToNumber:(NSString *)theNumber {
	MGMSIPURL *SIPURL = [MGMSIPURL URLWithSIPAddress:theNumber];
	if ([[SIPURL host] isEqual:theNumber]) {
		[SIPURL setHost:registrar];
		[SIPURL setUserName:theNumber];
	}
	return [self makeCallToSIPURL:SIPURL];
}
- (MGMSIPCall *)makeCallToSIPURL:(MGMSIPURL *)theURL {
	pj_thread_desc PJThreadDesc;
	[[MGMSIP sharedSIP] registerThread:&PJThreadDesc];
	
	pjsua_call_id callIdentifier;
	pj_str_t url = [[theURL SIPID] PJString];
	pj_status_t status = pjsua_call_make_call(identifier, &url, 0, NULL, NULL, &callIdentifier);
	MGMSIPCall *call = nil;
	if (status!=PJ_SUCCESS) {
		NSLog(@"Unable to make call to %@ with account %@", theURL, self);
	} else {
		call = [self callWithIdentifier:callIdentifier];
	}
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	return call;
}
- (NSArray *)calls {
	return calls;
}
- (MGMSIPCall *)callWithIdentifier:(int)theIdentifier {
	for (int i=0; i<[calls count]; i++) {
		if ([(MGMSIPCall *)[calls objectAtIndex:i] identifier]==theIdentifier)
			return [calls objectAtIndex:i];
	}
	return nil;
}
- (void)removeCall:(MGMSIPCall *)theCall {
	[calls removeObject:theCall];
}
@end
#endif