//
//  MGMSIPAccount.m
//  VoiceBase
//
//  Created by Mr. Gecko on 9/10/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
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
const int MGMSIPAccountDefaultProxyPort = 5060;

const int MGMSIPAccountReregisterTimeoutMin = 60;
const int MGMSIPAccountReregisterTimeoutMax = 3600;
const int MGMSIPAccountReregisterTimeoutDefault = 300;

@implementation MGMSIPAccount
- (id)initWithSettings:(NSDictionary *)theSettings {
	if (self = [self init]) {
		if ([theSettings objectForKey:MGMSIPAccountUserName]==nil || [[theSettings objectForKey:MGMSIPAccountUserName] isEqual:@""] || [theSettings objectForKey:MGMSIPAccountDomain]==nil || [[theSettings objectForKey:MGMSIPAccountDomain] isEqual:@""]) {
			[self release];
			self = nil;
		} else {
			if ([theSettings objectForKey:MGMSIPAccountFullName]!=nil && ![[theSettings objectForKey:MGMSIPAccountFullName] isEqual:@""])
				fullName = [[theSettings objectForKey:MGMSIPAccountFullName] copy];
			userName = [[theSettings objectForKey:MGMSIPAccountUserName] copy];
			domain = [[theSettings objectForKey:MGMSIPAccountDomain] copy];
			if ([theSettings objectForKey:MGMSIPAccountRegistrar]!=nil && ![[theSettings objectForKey:MGMSIPAccountRegistrar] isEqual:@""])
				registrar = [[theSettings objectForKey:MGMSIPAccountRegistrar] copy];
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
		}
	}
	return self;
}
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName domain:(NSString *)theDomain {
	return [self initWithFullName:theFullName userName:theUserName domain:theDomain SIPAddress:nil];
}
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName domain:(NSString *)theDomain SIPAddress:(NSString *)theSIPAddress {
	return [self initWithFullName:theFullName userName:theUserName domain:theDomain SIPAddress:theSIPAddress registrar:nil];
}
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName domain:(NSString *)theDomain SIPAddress:(NSString *)theSIPAddress registrar:(NSString *)theRegistrar {
	if (theUserName==nil || theDomain==nil) return nil;
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	if (theFullName!=nil)
		[settings setObject:theFullName forKey:MGMSIPAccountFullName];
	[settings setObject:theUserName forKey:MGMSIPAccountUserName];
	[settings setObject:theDomain forKey:MGMSIPAccountDomain];
	if (theSIPAddress!=nil)
		[settings setObject:theSIPAddress forKey:MGMSIPAccountSIPAddress];
	if (theRegistrar!=nil)
		[settings setObject:theRegistrar forKey:MGMSIPAccountRegistrar];
	return [self initWithSettings:settings];
}
- (id)init {
	if (self = [super init]) {
		reregisterTimeout = MGMSIPAccountReregisterTimeoutDefault;
		identifier = PJSUA_INVALID_ID;
		calls = [NSMutableArray new];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnected:) name:MGMNetworkConnectedNotification object:nil];
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self logout];
	if (calls!=nil)
		[calls release];
	if (fullName!=nil)
		[fullName release];
	if (userName!=nil)
		[userName release];
	if (domain!=nil)
		[domain release];
	if (registrar!=nil)
		[registrar release];
	if (SIPAddress!=nil)
		[SIPAddress release];
	if (proxy!=nil)
		[proxy release];
	[super dealloc];
}

- (BOOL)informationComplete {
	return ((delegate!=nil && [delegate respondsToSelector:@selector(password)]) && userName!=nil && (domain!=nil || [self SIPAddress]!=nil));
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
	if (fullName!=nil) [fullName release];
	fullName = [theFullName copy];
}
- (NSString *)userName {
	return userName;
}
- (void)setUserName:(NSString *)theUserName {
	if (theUserName==nil || [theUserName isEqual:@""]) return;
	if (userName!=nil) [userName release];
	userName = [theUserName copy];
}
- (NSString *)domain {
	return domain;
}
- (void)setDomain:(NSString *)theDomain {
	if (domain!=nil) [domain release];
	domain = [theDomain copy];
}
- (NSString *)registrar {
	if (registrar==nil && domain!=nil) return domain;
	return registrar;
}
- (void)setRegistrar:(NSString *)theRegistrar {
	if (registrar!=nil) [registrar release];
	registrar = [theRegistrar copy];
}
- (NSString *)SIPAddress {
	if (SIPAddress==nil && domain!=nil && userName!=nil)
		return [NSString stringWithFormat:@"%@@%@", userName, domain];
	return SIPAddress;
}
- (void)setSIPAddress:(NSString *)theSIPAddress {
	if (SIPAddress!=nil) [SIPAddress release];
	SIPAddress = [theSIPAddress copy];
}
- (NSString *)proxy {
	return proxy;
}
- (void)setProxy:(NSString *)theProxy {
	if (proxy!=nil) [proxy release];
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
- (int)identifier {
	return identifier;
}
- (void)setIdentifier:(int)theIdentifier {
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
	return settings;
}

- (void)setLastError:(NSString *)theError {
	if (lastError!=nil) [lastError release];
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

- (BOOL)isRegistered {
	return (([self registrationStatus]/100)==2 && [self registrationExpireTime]>0);
}
- (void)reregister {
	[self setRegistered:YES];
}
- (void)setRegistered:(BOOL)isRegistered {
	if (identifier==PJSUA_INVALID_ID)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_acc_set_registration(identifier, (isRegistered ? PJ_TRUE : PJ_FALSE));
	[self setOnline:isRegistered];
}
- (void)networkConnected:(NSNotification *)theNotification {
	if ([self isLoggedIn])
		[self performSelector:@selector(reregister) withObject:nil afterDelay:1.0];
}
- (int)registrationStatus {
	if (identifier==PJSUA_INVALID_ID)
		return 0;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	if (status!=PJ_SUCCESS)
		return 0;
	return accountInfo.status;
}
- (NSString *)registrationStatusText {
	if (identifier==PJSUA_INVALID_ID)
		return nil;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	if (status!=PJ_SUCCESS)
		return nil;
	return [NSString stringWithPJString:accountInfo.status_text];
}
- (int)registrationExpireTime {
	if (identifier==PJSUA_INVALID_ID)
		return -1;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	if (status!=PJ_SUCCESS)
		return -1;
	return accountInfo.expires;
}

- (BOOL)isOnline {
	if (identifier==PJSUA_INVALID_ID)
		return NO;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
	if (status!=PJ_SUCCESS)
		return NO;
	return (accountInfo.online_status==PJ_TRUE);
}
- (void)setOnline:(BOOL)isOnline {
	if ([self identifier]==PJSUA_INVALID_ID)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_status_t status = pjsua_acc_set_online_status(identifier, (isOnline ? PJ_TRUE : PJ_FALSE));
	if (status==PJ_SUCCESS) {
		if (reregisterTimer!=nil) {
			[reregisterTimer invalidate];
			[reregisterTimer release];
			reregisterTimer = nil;
		}
		if (isOnline)
			reregisterTimer = [[NSTimer scheduledTimerWithTimeInterval:(float)reregisterTimeout target:self selector:@selector(reregister) userInfo:nil repeats:YES] retain];
	}
}
- (NSString *)onlineStatusText {
	if (identifier==PJSUA_INVALID_ID)
		return nil;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_acc_info accountInfo;
	pj_status_t status = pjsua_acc_get_info(identifier, &accountInfo);
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
	MGMSIPURL *SIPURL = [MGMSIPURL URLWithFullName:nil userName:theNumber host:domain];
	return [self makeCallToSIPURL:SIPURL];
}
- (MGMSIPCall *)makeCallToSIPURL:(MGMSIPURL *)theURL {
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_call_id callIdentifier;
	pj_str_t url = [[theURL SIPID] PJString];
	pj_status_t status = pjsua_call_make_call(identifier, &url, 0, NULL, NULL, &callIdentifier);
	MGMSIPCall *call = nil;
	if (status!=PJ_SUCCESS) {
		NSLog(@"Unable to make call to %@ with account %@", theURL, self);
	} else {
		call = [self callWithIdentifier:callIdentifier];
	}
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