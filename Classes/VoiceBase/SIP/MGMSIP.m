//
//  MGMSIP.m
//  VoiceBase
//
//  Created by Mr. Gecko on 9/10/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIP.h"
#import "MGMSIPAccount.h"
#import "MGMSIPCall.h"
#import "MGMAddons.h"
#import <SystemConfiguration/SystemConfiguration.h>
#if !TARGET_OS_IPHONE
#import <CoreAudio/CoreAudio.h>
#endif

NSString * const MGMSIPCopyright = @"Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/";

const int MGMSIPMaxCalls = 8;
const int MGMSIPDefaultOutboundProxyPort = 5060;
const int MGMSIPDefaultSTUNPort = 3478;

NSString * const MGMSIPOutboundProxy = @"MGMSIPOutboundProxy";
NSString * const MGMSIPOutboundProxyPort = @"MGMSIPOutboundProxyPort";
NSString * const MGMSIPSTUN = @"MGMSIPSTUN";
NSString * const MGMSIPSTUNPort = @"MGMSIPSTUNPort";
NSString * const MGMSIPLogFile = @"MGMSIPLogFile";
NSString * const MGMSIPLogLevel = @"MGMSIPLogLevel";
NSString * const MGMSIPConsoleLogLevel = @"MGMSIPConsoleLogLevel";
NSString * const MGMSIPVoiceActivityDetection = @"MGMSIPVoiceActivityDetection";
NSString * const MGMSIPInteractiveConnectivityEstablishment = @"MGMSIPInteractiveConnectivityEstablishment";
NSString * const MGMSIPNameServersEnabled = @"MGMSIPNameServersEnabled";
NSString * const MGMSIPEchoCacnellationEnabled = @"MGMSIPEchoCacnellationEnabled";
NSString * const MGMSIPPort = @"MGMSIPPort";
NSString * const MGMSIPPublicAddress = @"MGMSIPPublicAddress";

NSString * const MGMNetworkConnectedNotification = @"MGMNetworkConnectedNotification";
NSString * const MGMNetworkDisconnectedNotification = @"MGMNetworkDisconnectedNotification";

NSString * const MGMSIPVolume = @"MGMSIPVolume";
NSString * const MGMSIPMicVolume = @"MGMSIPMicVolume";
NSString * const MGMSIPVolumeChangedNotification = @"MGMSIPVolumeChangedNotification";
NSString * const MGMSIPMicVolumeChangedNotification = @"MGMSIPMicVolumeChangedNotification";

NSString * const MGMSIPADeviceIdentifier = @"MGMSIPADeviceIdentifier";
NSString * const MGMSIPADeviceIndex = @"MGMSIPADeviceIndex";
NSString * const MGMSIPADeviceUID = @"MGMSIPADeviceUID";
NSString * const MGMSIPADeviceName = @"MGMSIPADeviceName";
NSString * const MGMSIPADeviceInputCount = @"MGMSIPADeviceInputCount";
NSString * const MGMSIPADeviceOutputCount = @"MGMSIPADeviceOutputCount";
NSString * const MGMSIPADeviceIsDefaultInput = @"MGMSIPADeviceIsDefaultInput";
NSString * const MGMSIPADeviceIsDefaultOutput = @"MGMSIPADeviceIsDefaultOutput";

NSString * const MGMSIPACurrentInputDevice = @"MGMSIPACurrentInputDevice";
NSString * const MGMSIPACurrentOutputDevice = @"MGMSIPACurrentOutputDevice";
NSString * const MGMSIPASystemDefault = @"System Default";
NSString * const MGMSIPAudioChangedNotification = @"MGMSIPAudioChangedNotification";

static MGMSIP *MGMSIPSingleton = nil;

#define THIS_FILE "MGMSIP.m"

static void MGMSIPIncomingCallReceived(pjsua_acc_id accountIdentifier, pjsua_call_id callIdentifier, pjsip_rx_data *messageData) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	PJ_LOG(3, (THIS_FILE, "Incoming call for account %d!", accountIdentifier));
	MGMSIPAccount *account = [[MGMSIP sharedSIP] accountWithIdentifier:accountIdentifier];
	MGMSIPCall *call = [account addCallWithIdentifier:callIdentifier];
	[[MGMSIP sharedSIP] receivedNewCall:call];
	id<MGMSIPDelegate> delegate = [[MGMSIP sharedSIP] delegate];
	if (delegate!=nil && [delegate respondsToSelector:@selector(gotNewCall:)]) [delegate gotNewCall:call];
	if ([account delegate]!=nil && [[account delegate] respondsToSelector:@selector(receivedNewCall:)]) [[account delegate] receivedNewCall:call];
	if ([account delegate]!=nil && [[account delegate] respondsToSelector:@selector(gotNewCall:)]) [[account delegate] gotNewCall:call];
	[pool drain];
}

static void MGMSIPCallStateChanged(pjsua_call_id callIdentifier, pjsip_event *sipEvent) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMSIPCall *call = [[MGMSIP sharedSIP] callWithIdentifier:callIdentifier];
	pjsua_call_info callInfo;
	pjsua_call_get_info(callIdentifier, &callInfo);
	
	if (call==nil && callInfo.state==MGMSIPCallCallingState) {
		MGMSIPAccount *account = [[MGMSIP sharedSIP] accountWithIdentifier:callInfo.acc_id];
		MGMSIPCall *call = [account addCallWithIdentifier:callIdentifier];
		[[MGMSIP sharedSIP] startingNewCall:call];
		id<MGMSIPDelegate> delegate = [[MGMSIP sharedSIP] delegate];
		if (delegate!=nil && [delegate respondsToSelector:@selector(gotNewCall:)]) [delegate gotNewCall:call];
		if ([account delegate]!=nil && [[account delegate] respondsToSelector:@selector(startingNewCall:)]) [[account delegate] startingNewCall:call];
		if ([account delegate]!=nil && [[account delegate] respondsToSelector:@selector(gotNewCall:)]) [[account delegate] gotNewCall:call];
	} else {
		[call setState:callInfo.state];
		[call setStateText:[NSString stringWithPJString:callInfo.state_text]];
		[call setLastStatus:callInfo.last_status];
		[call setLastStatusText:[NSString stringWithPJString:callInfo.last_status_text]];
		if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(stateChanged:)]) [[call delegate] stateChanged:call];
	}
	
	if (callInfo.state==MGMSIPCallDisconnectedState) {
		[call stopRingback];
		NSLog(@"%@ Disconnected", call);
		if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(disconnected:)]) [[call delegate] disconnected:call];
		[call setIdentifier:PJSUA_INVALID_ID];
		[[call account] removeCall:call];
		
		PJ_LOG(3, (THIS_FILE, "Call %d disconnected reason %d (%s)", callIdentifier, callInfo.last_status, callInfo.last_status_text.ptr));
	} else if (callInfo.state==MGMSIPCallEarlyState) {
		if (sipEvent->type!=PJSIP_EVENT_TSX_STATE) {
			[pool drain];
			return;
		}
		
		pjsip_msg *msg;
		if (sipEvent->body.tsx_state.type==PJSIP_EVENT_RX_MSG)
			msg = sipEvent->body.tsx_state.src.rdata->msg_info.msg;
		else
			msg = sipEvent->body.tsx_state.src.tdata->msg;
		
		pj_str_t reason = msg->line.status.reason;
		int code = msg->line.status.code;
		
		if (callInfo.role==PJSIP_ROLE_UAC && code==180 && msg->body==NULL && callInfo.media_status==PJSUA_CALL_MEDIA_NONE)
			[call startRingback];
		
		PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s %d (%.*s)", callIdentifier, callInfo.state_text.ptr, code, (int)reason.slen, reason.ptr));
		
		if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(early:code:reason:)]) [[call delegate] early:call code:code reason:[NSString stringWithPJString:reason]];
	} else {
		PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s", callIdentifier, callInfo.state_text.ptr));
		
		switch (callInfo.state) {
			case MGMSIPCallCallingState:
				if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(calling:)]) [[call delegate] calling:call];
				break;
			case MGMSIPCallConnectingState:
				if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(connecting:)]) [[call delegate] connecting:call];
				break;
			case MGMSIPCallConfirmedState:
				if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(confirmed:)]) [[call delegate] confirmed:call];
				break;
			default:
				break;
		}
	}
	[pool drain];
}

static void MGMSIPCallMediaStateChanged(pjsua_call_id callIdentifier) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMSIPCall *call = [[MGMSIP sharedSIP] callWithIdentifier:callIdentifier];
	[call stopRingback];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(callIdentifier, &callInfo);
	if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(mediaStateChanged:)]) [[call delegate] mediaStateChanged:call];
	
	if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
		pjsua_conf_connect(callInfo.conf_slot, 0);
		pjsua_conf_connect(0, callInfo.conf_slot);
		
		PJ_LOG(3, (THIS_FILE, "Media for call %d is active", callIdentifier));
		
		if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(becameActive:)]) [[call delegate] becameActive:call];
	} else if (callInfo.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD) {
		PJ_LOG(3, (THIS_FILE, "Media for call %d is placed on hold by local", callIdentifier));
		
		if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(localPlacedHold:)]) [[call delegate] becameActive:call];
	} else if (callInfo.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) {
		PJ_LOG(3, (THIS_FILE, "Media for call %d is placed on hold by remote", callIdentifier));
		
		if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(remotePlacedHold:)]) [[call delegate] becameActive:call];
	} else if (callInfo.media_status == PJSUA_CALL_MEDIA_ERROR) {
		PJ_LOG(1, (THIS_FILE, "Media has reported error, disconnecting call"));
		
		pj_str_t reason = pj_str("ICE negotiation failed");
		pjsua_call_hangup(callIdentifier, 500, &reason, NULL);
	} else {
		PJ_LOG(3, (THIS_FILE, "Media for call %d is inactive", [call identifier]));
	}
	[pool drain];
}

static void MGMSIPCallTransferStatusChanged(pjsua_call_id callIdentifier, int statusCode, const pj_str_t *statusText, pj_bool_t isFinal, pj_bool_t *pCont) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMSIPCall *call = [[MGMSIP sharedSIP] callWithIdentifier:callIdentifier];
	[call setTransferStatus:statusCode];
	[call setTransferStatusText:[NSString stringWithPJString:*statusText]];
	if ([call delegate]!=nil && [[call delegate] respondsToSelector:@selector(transferStatusCahgned:)]) [[call delegate] transferStatusCahgned:call];
	[pool drain];
}

static void MGMSIPAccountRegistrationStateChanged(pjsua_acc_id accountIdentifier) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMSIPAccount *account = [[MGMSIP sharedSIP] accountWithIdentifier:accountIdentifier];
	if ([account delegate]!=nil && [[account delegate] respondsToSelector:@selector(registrationChanged)]) [[account delegate] registrationChanged];
	[pool drain];
}

static void MGMSIPDetectedNAT(const pj_stun_nat_detect_result *result) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	if (result->status!=PJ_SUCCESS) {
		pjsua_perror(THIS_FILE, "NAT detection failed", result->status);
	} else {
		PJ_LOG(3, (THIS_FILE, "NAT detected as %s", result->nat_type_name));
		[[MGMSIP sharedSIP] setNATType:result->nat_type];
	}
	[pool drain];
}

#if !TARGET_OS_IPHONE
static void MGMNetworkNotification(SCDynamicStoreRef store, NSArray *changedKeys, void *info) {
	for (int i=0; i<[changedKeys count]; ++i) {
		NSString *key = [changedKeys objectAtIndex:i];
		if ([key isEqual:@"State:/Network/Global/IPv4"]) {
			NSDictionary *value = (NSDictionary *)SCDynamicStoreCopyValue(store, (CFStringRef)key);
			if (value!=nil)
				[[NSNotificationCenter defaultCenter] postNotificationName:MGMNetworkConnectedNotification object:[value autorelease]];
			else
				[[NSNotificationCenter defaultCenter] postNotificationName:MGMNetworkDisconnectedNotification object:nil];
		}
	}
}

static OSStatus MGMAudioDevicesChanged(AudioHardwarePropertyID propertyID, void *clientData) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	if (propertyID==kAudioHardwarePropertyDevices || propertyID==kAudioHardwarePropertyDefaultInputDevice || propertyID==kAudioHardwarePropertyDefaultOutputDevice) {
		[NSObject cancelPreviousPerformRequestsWithTarget:(MGMSIP *)clientData selector:@selector(updateAudioDevices) object:nil];
		[(MGMSIP *)clientData performSelector:@selector(updateAudioDevices) withObject:nil afterDelay:0.2];
	}
	[pool drain];
	return noErr;
}
#endif

@interface MGMSIP (MGMPrivate)

@end

@implementation MGMSIP
+ (MGMSIP *)sharedSIP {
	if (MGMSIPSingleton==nil)
		MGMSIPSingleton = [MGMSIP new];
	return MGMSIPSingleton;
}
- (id)init {
	if (self = [super init]) {
		[self registerDefaults];
		port = [[NSUserDefaults standardUserDefaults] integerForKey:MGMSIPPort];
		lock = [NSLock new];
		state = MGMSIPStoppedState;
		NATType = MGMSIPNATUnknownType;
		accounts = [NSMutableArray new];
		shouldRestart = NO;
		
#if !TARGET_OS_IPHONE
		store = SCDynamicStoreCreate(kCFAllocatorDefault, CFBundleGetIdentifier(CFBundleGetMainBundle()), (SCDynamicStoreCallBack)MGMNetworkNotification, NULL);
		if (!store) {
			NSLog(@"Unable to create store for system configuration %s", SCErrorString(SCError()));
		} else {
			NSArray *keys = [NSArray arrayWithObjects:@"State:/Network/Global/IPv4", nil];
			if (!SCDynamicStoreSetNotificationKeys(store, (CFArrayRef)keys, NULL)) {
				NSLog(@"Faild to set the store for notifications %s", SCErrorString(SCError()));
				CFRelease(store);
				store = NULL;
			} else {
				storeRunLoop = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, store, 0);
				CFRunLoopAddSource(CFRunLoopGetCurrent(), storeRunLoop, kCFRunLoopDefaultMode);
				CFRelease(storeRunLoop);
			}
		}
#endif
	}
	return self;
}
- (void)dealloc {
	[self stop];
	if (storeRunLoop!=NULL)
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), storeRunLoop, kCFRunLoopDefaultMode);
	if (store!=NULL)
		CFRelease(store);
	if (lock!=nil)
		[lock release];
	if (accounts!=nil)
		[accounts release];
	[super dealloc];
}

- (void)registerDefaults {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:MGMSIPLogLevel];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:MGMSIPConsoleLogLevel];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:MGMSIPVoiceActivityDetection];
	[defaults setObject:[NSNumber numberWithBool:NO] forKey:MGMSIPInteractiveConnectivityEstablishment];
	[defaults setObject:[NSNumber numberWithBool:NO] forKey:MGMSIPNameServersEnabled];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:MGMSIPEchoCacnellationEnabled];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:MGMSIPPort];
	[defaults setObject:[NSNumber numberWithFloat:1.0] forKey:MGMSIPVolume];
	[defaults setObject:[NSNumber numberWithFloat:1.0] forKey:MGMSIPMicVolume];
	[defaults setObject:MGMSIPASystemDefault forKey:MGMSIPACurrentInputDevice];
	[defaults setObject:MGMSIPASystemDefault forKey:MGMSIPACurrentOutputDevice];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id<MGMSIPDelegate>)delegate {
	return delegate;
}
- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}

- (MGMSIPState)state {
	return state;
}
- (BOOL)isStarted {
	return (state==MGMSIPStartedState);
}
- (pj_pool_t *)PJPool {
	return PJPool;
}
- (int)port {
	return port;
}
- (void)setPort:(int)thePort {
	port = thePort;
}
- (pjmedia_port *)ringbackPort {
	return ringbackPort;
}
- (pjsua_conf_port_id)ringbackSlot {
	return ringbackSlot;
}
- (MGMSIPNATType)NATType {
	return NATType;
}
- (void)setNATType:(MGMSIPNATType)theNATType {
	NATType = theNATType;
}

- (void)start {
	if (state>MGMSIPStoppedState)
		return;
	
	if (restartTimer!=nil) {
		[restartTimer invalidate];
		[restartTimer release];
		restartTimer = nil;
	}
    
	[NSThread detachNewThreadSelector:@selector(startBackground) toTarget:self withObject:nil];
}
- (void)startBackground {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[lock lock];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	pj_status_t status;
	
	state = MGMSIPStartingState;
	status = pjsua_create();
	if (status!=PJ_SUCCESS) {
		NSLog(@"Unable to create PJSUA.");
		state = MGMSIPNULLState;
		[pool drain];
		return;
	}
	
	PJPool = pjsua_pool_create("MGMSIP-pjsua", 1000, 1000);
	
	pjsua_logging_config loggingConfig;
	pjsua_logging_config_default(&loggingConfig);
	if ([defaults objectForKey:MGMSIPLogFile]!=nil && ![[defaults objectForKey:MGMSIPLogFile] isEqual:@""])
		loggingConfig.log_filename = [[[defaults objectForKey:MGMSIPLogFile] stringByExpandingTildeInPath] PJString];
	loggingConfig.level = [defaults integerForKey:MGMSIPLogLevel];
	loggingConfig.console_level = [defaults integerForKey:MGMSIPConsoleLogLevel];
	
	pjsua_media_config mediaConfig;
	pjsua_media_config_default(&mediaConfig);
	mediaConfig.no_vad = ![defaults boolForKey:MGMSIPVoiceActivityDetection];
	mediaConfig.enable_ice = [defaults boolForKey:MGMSIPInteractiveConnectivityEstablishment];
	mediaConfig.snd_auto_close_time = 1;
	if (![defaults boolForKey:MGMSIPEchoCacnellationEnabled])
		mediaConfig.ec_tail_len = 0;
	
	pjsua_config sipConfig;
	pjsua_config_default(&sipConfig);
	
	sipConfig.user_agent = [[NSString stringWithFormat:@"%@ %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey], [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]] PJString];
	
	sipConfig.cb.on_incoming_call = &MGMSIPIncomingCallReceived;
	sipConfig.cb.on_call_media_state = &MGMSIPCallMediaStateChanged;
	sipConfig.cb.on_call_state = &MGMSIPCallStateChanged;
	sipConfig.cb.on_call_transfer_status = &MGMSIPCallTransferStatusChanged;
	sipConfig.cb.on_reg_state = &MGMSIPAccountRegistrationStateChanged;
	sipConfig.cb.on_nat_detect = &MGMSIPDetectedNAT;
	
	sipConfig.max_calls = MGMSIPMaxCalls;
	
#if !TARGET_OS_IPHONE
	if ([defaults boolForKey:MGMSIPNameServersEnabled]) {
		SCDynamicStoreRef dynamicStore = SCDynamicStoreCreate(NULL, CFBundleGetIdentifier(CFBundleGetMainBundle()), NULL, NULL);
		CFPropertyListRef DNSSettings = SCDynamicStoreCopyValue(dynamicStore, CFSTR("State:/Network/Global/DNS"));
		NSArray *nameServers = nil;
		if (DNSSettings!=NULL) {
			nameServers = [[[(NSDictionary *)DNSSettings objectForKey:@"ServerAddresses"] retain] autorelease];
			CFRelease(DNSSettings);
		}
		CFRelease(dynamicStore);
		
		if ([nameServers count]>=0) {
			sipConfig.nameserver_count = ([nameServers count]>4 ? 4 : [nameServers count]);
			for (int i=0; i<[nameServers count] && i<4; i++)
				sipConfig.nameserver[i] = [[nameServers objectAtIndex:i] PJString];
		}
	}
#endif
	
	if ([defaults objectForKey:MGMSIPOutboundProxy]!=nil && ![[defaults objectForKey:MGMSIPOutboundProxy] isEqual:@""]) {
		sipConfig.outbound_proxy_cnt = 1;
		if ([defaults integerForKey:MGMSIPOutboundProxyPort]==0 || [defaults integerForKey:MGMSIPOutboundProxyPort]==MGMSIPDefaultOutboundProxyPort)
			sipConfig.outbound_proxy[0] = [[NSString stringWithFormat:@"sip:%@", [defaults objectForKey:MGMSIPOutboundProxy]] PJString];
		else
			sipConfig.outbound_proxy[0] = [[NSString stringWithFormat:@"sip:%@:%d", [defaults objectForKey:MGMSIPOutboundProxy], [defaults integerForKey:MGMSIPOutboundProxyPort]] PJString];
	}
	
	
	if ([defaults objectForKey:MGMSIPSTUN]!=nil && ![[defaults objectForKey:MGMSIPSTUN] isEqual:@""]) {
		int STUNPort = [defaults integerForKey:MGMSIPSTUNPort];
		if (STUNPort==0) STUNPort = MGMSIPDefaultSTUNPort;
		sipConfig.stun_host = [[NSString stringWithFormat:@"%@:%d", [defaults objectForKey:MGMSIPSTUN], STUNPort] PJString];
	}
	
	status = pjsua_init(&sipConfig, &loggingConfig, &mediaConfig);
	if (status!=PJ_SUCCESS) {
		NSLog(@"Error initializing PJSUA");
		[self stop];
		[lock unlock];
		[pool drain];
		return;
	}
	
	unsigned int samplesPerFrame = mediaConfig.audio_frame_ptime * mediaConfig.clock_rate * mediaConfig.channel_count / 1000;
	pj_str_t name = pj_str("ringback");
	status = pjmedia_tonegen_create2(PJPool, &name, mediaConfig.clock_rate, mediaConfig.channel_count, samplesPerFrame, 16, PJMEDIA_TONEGEN_LOOP, &ringbackPort);
	if (status!=PJ_SUCCESS) {
		NSLog(@"Error creating ringback tones");
		[self stop];
		[lock unlock];
		[pool drain];
		return;
	}
	
	pjmedia_tone_desc tone[1];
	pj_bzero(&tone, sizeof(tone));
	tone[0].freq1 = 440;
	tone[0].freq2 = 480;
	tone[0].on_msec = 2000;
	tone[0].off_msec = 4000;
	tone[0].off_msec = 4000;
	
	pjmedia_tonegen_play(ringbackPort, 1, tone, PJMEDIA_TONEGEN_LOOP);
	status = pjsua_conf_add_port(PJPool, ringbackPort, &ringbackSlot);
	if (status!=PJ_SUCCESS) {
		NSLog(@"Error adding ringback tone");
		[self stop];
		[lock unlock];
		[pool drain];
		return;
	}
	
	pjsua_transport_config transportConfig;
	pjsua_transport_config_default(&transportConfig);
	transportConfig.port = port;
	if ([defaults objectForKey:MGMSIPPublicAddress]!=nil && ![[defaults objectForKey:MGMSIPPublicAddress] isEqual:@""])
		transportConfig.public_addr = [[defaults objectForKey:MGMSIPPublicAddress] PJString];
	status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, &UDPTransport);
	if (status!=PJ_SUCCESS) {
		NSLog(@"Error creating transport");
		[self stop];
		[lock unlock];
		[pool drain];
		return;
	}
	if (port == 0) {
		pjsua_transport_info transportInfo;
		status = pjsua_transport_get_info(UDPTransport, &transportInfo);
		if (status!=PJ_SUCCESS)
			NSLog(@"Unable to get transport info");
		
		port = transportInfo.local_name.port;
		transportConfig.port = port;
	}
	
	status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transportConfig, &TCPTransport);
	if (status!=PJ_SUCCESS)
		NSLog(@"Error creating TCP transport");
	
	status = pjsua_start();
	if (status!=PJ_SUCCESS) {
		NSLog(@"Error starting PJSUA");
		[self stop];
		[lock unlock];
		[pool drain];
		return;
	}
	
	state = MGMSIPStartedState;
	
	pjsua_conf_adjust_tx_level(0, [defaults floatForKey:MGMSIPVolume]);
	pjsua_conf_adjust_rx_level(0, [defaults floatForKey:MGMSIPMicVolume]);
#if !TARGET_OS_IPHONE
	AudioHardwareAddPropertyListener(kAudioHardwarePropertyDevices, &MGMAudioDevicesChanged, self);
	AudioHardwareAddPropertyListener(kAudioHardwarePropertyDefaultInputDevice, &MGMAudioDevicesChanged, self);
	AudioHardwareAddPropertyListener(kAudioHardwarePropertyDefaultOutputDevice, &MGMAudioDevicesChanged, self);
	[self updateAudioDevices];
#endif
	
	[accounts makeObjectsPerformSelector:@selector(login)];
	
	if (delegate!=nil && [delegate respondsToSelector:@selector(SIPStarted)]) [delegate SIPStarted];
	
	NSLog(@"MGMSIP Started");
	
	[lock unlock];
	[pool drain];
}
- (void)stop {
	if (state==MGMSIPStoppingState || state==MGMSIPStoppedState)
		return;
	
    [NSThread detachNewThreadSelector:@selector(stopBackground) toTarget:self withObject:nil];
}
- (void)stopBackground {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[lock lock];
	
	pj_status_t status;
	
	state = MGMSIPStoppingState;
	
	[accounts makeObjectsPerformSelector:@selector(logout)];
	
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	if (ringbackPort!=NULL && ringbackSlot!=PJSUA_INVALID_ID) {
		pjsua_conf_remove_port(ringbackSlot);
		ringbackSlot = PJSUA_INVALID_ID;
		pjmedia_port_destroy(ringbackPort);
		ringbackPort = NULL;
	}
	
	if (PJPool!=NULL) {
		pj_pool_release(PJPool);
		PJPool = NULL;
	}
	pjsua_transport_close(UDPTransport, PJ_FALSE);
	pjsua_transport_close(TCPTransport, PJ_FALSE);
	
	status = pjsua_destroy();
	if (status!=PJ_SUCCESS)
		NSLog(@"Error stopping SIP");
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	
	state = MGMSIPStoppedState;
	
#if !TARGET_OS_IPHONE
	AudioHardwareRemovePropertyListener(kAudioHardwarePropertyDevices, &MGMAudioDevicesChanged);
	AudioHardwareRemovePropertyListener(kAudioHardwarePropertyDefaultInputDevice, &MGMAudioDevicesChanged);
	AudioHardwareRemovePropertyListener(kAudioHardwarePropertyDefaultOutputDevice, &MGMAudioDevicesChanged);
#endif
	
	if (delegate!=nil && [delegate respondsToSelector:@selector(SIPStopped)]) [delegate SIPStopped];
	
	NSLog(@"MGMSIP Stopped");
	
	if (shouldRestart) {
		if (restartAccounts!=nil) {
			for (int i=0; i<[restartAccounts count]; i++) {
				if (![accounts containsObject:[restartAccounts objectAtIndex:i]])
					[accounts addObject:[restartAccounts objectAtIndex:i]];
			}
			[restartAccounts release];
			restartAccounts = nil;
		}
		
		shouldRestart = NO;
		[self start];
		//[self performSelectorOnMainThread:@selector(startRestartTimer) withObject:nil waitUntilDone:NO];
	}
	
	[lock unlock];
	[pool drain];
}
- (void)startRestartTimer {
	if (restartTimer!=nil) {
		[restartTimer invalidate];
		[restartTimer release];
		restartTimer = nil;
	}
	restartTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(start) userInfo:nil repeats:NO] retain];
}
- (void)restart {
	if (shouldRestart)
		return;
	restartAccounts = [accounts copy];
	shouldRestart = YES;
	[self stop];
}

- (void)registerThread:(pj_thread_desc *)thePJThreadDesc {
	if (!pj_thread_is_registered()) {
		pj_thread_t *PJThread;
		pj_status_t status = pj_thread_register(NULL, *thePJThreadDesc, &PJThread);
		if (status!=PJ_SUCCESS)
			NSLog(@"Error registering thread for PJSUA with status %d", status);
	}
}

- (void)loginToAccount:(MGMSIPAccount *)theAccount {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	if (![theAccount informationComplete]) {
		[theAccount setLastError:@"The Account Information is not complete."];
		[theAccount loginErrored];
		NSLog(@"Error With Account %@: %@", theAccount, [theAccount lastError]);
		[pool drain];
		return;
	}
	if (![accounts containsObject:theAccount]) [accounts addObject:theAccount];
	if (state!=MGMSIPStartedState) {
		[pool drain];
		return;
	}
	if ([theAccount identifier]!=PJSUA_INVALID_ID) {
		[pool drain];
		return;
	}
	
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	pjsua_acc_config accountConfig;
	pjsua_acc_config_default(&accountConfig);
	
	accountConfig.cred_count = 1;
	if ([theAccount domain]!=nil && ![[theAccount domain] isEqual:@""])
		accountConfig.cred_info[0].realm = [[theAccount domain] PJString];
	else
		accountConfig.cred_info[0].realm = pj_str("*");
	accountConfig.cred_info[0].scheme = pj_str("digest");
	accountConfig.cred_info[0].username = [[theAccount userName] PJString];
	accountConfig.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
	accountConfig.cred_info[0].data = [[theAccount password] PJString];
	
	if ([theAccount fullName]!=nil)
		accountConfig.id = [[NSString stringWithFormat:@"%@ <sip:%@>", [theAccount fullName], [theAccount SIPAddress]] PJString];
	else
		accountConfig.id = [[NSString stringWithFormat:@"<sip:%@>", [theAccount SIPAddress]] PJString];
	accountConfig.reg_uri = [[NSString stringWithFormat:@"sip:%@", [theAccount registrar]] PJString];
	
	if ([theAccount proxy]!=nil && ![[theAccount proxy] isEqual:@""]) {
		accountConfig.proxy_cnt = 1;
		accountConfig.proxy[0] = [[NSString stringWithFormat:@"sip:%@:%d", [theAccount proxy], [theAccount proxyPort]] PJString];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:MGMSIPInteractiveConnectivityEstablishment] && [defaults objectForKey:MGMSIPSTUN]!=nil && ![[defaults objectForKey:MGMSIPSTUN] isEqual:@""])
		accountConfig.allow_contact_rewrite = PJ_TRUE;
	else
		accountConfig.allow_contact_rewrite = PJ_FALSE;
	
	accountConfig.reg_timeout = [theAccount reregisterTimeout];
	
	pjsua_acc_id identifier;
	pj_status_t status = pjsua_acc_add(&accountConfig, PJ_FALSE, &identifier);
	if (status!=PJ_SUCCESS) {
		[theAccount setLastError:[NSString stringWithFormat:@"Unable to login with status %d.", status]];
		[theAccount loginErrored];
		NSLog(@"Error With Account %@: %@", theAccount, [theAccount lastError]);
		[accounts removeObject:theAccount];
		bzero(&PJThreadDesc, sizeof(pj_thread_desc));
		[pool drain];
		return;
	}
	[theAccount setIdentifier:identifier];
	[theAccount setOnline:YES];
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	if (delegate!=nil && [delegate respondsToSelector:@selector(accountLoggedIn:)]) [delegate accountLoggedIn:theAccount];
	if ([theAccount delegate]!=nil && [[theAccount delegate] respondsToSelector:@selector(loggedIn)]) [[theAccount delegate] loggedIn];
	[pool drain];
}
- (void)logoutOfAccount:(MGMSIPAccount *)theAccount {
	if (state<MGMSIPStartedState) return;
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	if ([theAccount identifier]==PJSUA_INVALID_ID) {
		[theAccount setLastError:@"Unable to logout due to missing information."];
		[theAccount logoutErrored];
		NSLog(@"Error With Account %@: %@", theAccount, [theAccount lastError]);
		[pool drain];
		return;
	}
	
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	pj_status_t status = pjsua_acc_del([theAccount identifier]);
	if (status!=PJ_SUCCESS) {
		[theAccount setLastError:[NSString stringWithFormat:@"Unable to logout with status %d.", status]];
		[theAccount logoutErrored];
		NSLog(@"Error With Account %@: %@", theAccount, [theAccount lastError]);
		[pool drain];
		return;
	}
	[theAccount setIdentifier:PJSUA_INVALID_ID];
	if (delegate!=nil && [delegate respondsToSelector:@selector(accountLoggedOut:)]) [delegate accountLoggedOut:theAccount];
	if ([theAccount delegate]!=nil && [[theAccount delegate] respondsToSelector:@selector(loggedOut)]) [[theAccount delegate] loggedOut];
	[accounts removeObject:theAccount];
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	[pool drain];
}

- (NSArray *)accounts {
	return accounts;
}
- (MGMSIPAccount *)accountWithIdentifier:(int)theIdentifier {
	for (int i=0; i<[accounts count]; i++) {
		if ([(MGMSIPAccount *)[accounts objectAtIndex:i] identifier]==theIdentifier)
			return [accounts objectAtIndex:i];
	}
	return nil;
}

- (int)ringbackCount {
	return ringbackCount;
}
- (void)setRingbackCount:(int)theRingbackCount {
	ringbackCount = theRingbackCount;
}

- (void)hangUpAllCalls {
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	pjsua_call_hangup_all();
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
}

- (float)volume {
	return [[NSUserDefaults standardUserDefaults] floatForKey:MGMSIPVolume];
}
- (void)setVolume:(float)theVolume {
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	[[NSUserDefaults standardUserDefaults] setFloat:theVolume forKey:MGMSIPVolume];
	pjsua_conf_adjust_tx_level(0, theVolume);
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMSIPVolumeChangedNotification object:[NSNumber numberWithFloat:theVolume]];
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
}
- (float)micVolume {
	return [[NSUserDefaults standardUserDefaults] floatForKey:MGMSIPMicVolume];
}
- (void)setMicVolume:(float)theVolume {
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	[[NSUserDefaults standardUserDefaults] setFloat:theVolume forKey:MGMSIPMicVolume];
	pjsua_conf_adjust_rx_level(0, theVolume);
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMSIPMicVolumeChangedNotification object:[NSNumber numberWithFloat:theVolume]];
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
}

#if !TARGET_OS_IPHONE
- (BOOL)setInputSoundDevice:(int)theInputDevice outputSoundDevice:(int)theOutputDevice {
	if (state!=MGMSIPStartedState)
		return NO;
	
	NSString *inputDeviceUID = nil;
	if (theInputDevice==-1) {
		inputDeviceUID = MGMSIPASystemDefault;
		for (int i=0; i<[audioDevices count]; i++) {
			if ([[[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceIsDefaultInput] boolValue]) {
				theInputDevice = [[[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceIndex] intValue];
				break;
			}
		}
	} else {
		for (int i=0; i<[audioDevices count]; i++) {
			if ([[[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceIndex] intValue]==theInputDevice) {
				inputDeviceUID = [[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceUID];
				break;
			}
		}
	}
	NSString *outputDeviceUID = nil;
	if (theOutputDevice==-1) {
		outputDeviceUID = MGMSIPASystemDefault;
		for (int i=0; i<[audioDevices count]; i++) {
			if ([[[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceIsDefaultOutput] boolValue]) {
				theOutputDevice = [[[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceIndex] intValue];
				break;
			}
		}
	} else {
		for (int i=0; i<[audioDevices count]; i++) {
			if ([[[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceIndex] intValue]==theOutputDevice) {
				outputDeviceUID = [[audioDevices objectAtIndex:i] objectForKey:MGMSIPADeviceUID];
				break;
			}
		}
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:inputDeviceUID forKey:MGMSIPACurrentInputDevice];
	[defaults setObject:outputDeviceUID forKey:MGMSIPACurrentOutputDevice];
	
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	pj_status_t status = pjsua_set_snd_dev(theInputDevice, theOutputDevice);
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	return (status==PJ_SUCCESS);
}
- (BOOL)stopSound {
	if (state!=MGMSIPStartedState)
		return NO;
	
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	pj_status_t status = pjsua_set_null_snd_dev();
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	return (status==PJ_SUCCESS);
}
- (void)updateAudioDevices {
	if (state!=MGMSIPStartedState)
		return;
	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	OSStatus error = noErr;
	UInt32 size = 0;
	AudioBufferList *bufferList = NULL;
	
	NSMutableArray *devicesArray = [NSMutableArray array];
	AudioDeviceID *devices = NULL;
	int deviceCount = 0;
	Boolean writable;
	
	error = AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &size, &writable);
	if (error!=noErr) {
		[pool drain];
		return;
	}
	
	deviceCount = size / sizeof(AudioDeviceID);
	if (deviceCount>=1) {
		devices = malloc(size);
		memset(devices, 0, size);
		
		AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &size, (void *)devices);
	}
	size = 0;
	
	size = sizeof(AudioDeviceID);
	AudioDeviceID defaultInput = 0;
	AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice, &size, &defaultInput);
	size = sizeof(AudioDeviceID);
	AudioDeviceID defaultOutput = 0;
	AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &size, &defaultOutput);
	
	NSMutableDictionary *defaultDevice = [NSMutableDictionary dictionary];
	[defaultDevice setObject:[NSNumber numberWithUnsignedInt:0] forKey:MGMSIPADeviceIdentifier];
	[defaultDevice setObject:[NSNumber numberWithUnsignedInt:-1] forKey:MGMSIPADeviceIndex];
	[defaultDevice setObject:MGMSIPASystemDefault forKey:MGMSIPADeviceName];
	[defaultDevice setObject:MGMSIPASystemDefault forKey:MGMSIPADeviceUID];
	[devicesArray addObject:defaultDevice];
	
	int currentInput = -1;
	int currentOutput = -1;
	
	for (int d=0; d<deviceCount; d++) {
		NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];
		[deviceInfo setObject:[NSNumber numberWithUnsignedLong:devices[d]] forKey:MGMSIPADeviceIdentifier];
		[deviceInfo setObject:[NSNumber numberWithInt:d] forKey:MGMSIPADeviceIndex];
		
		if (devices[d]==defaultInput)
			[deviceInfo setObject:[NSNumber numberWithBool:YES] forKey:MGMSIPADeviceIsDefaultInput];
		if (devices[d]==defaultOutput)
			[deviceInfo setObject:[NSNumber numberWithBool:YES] forKey:MGMSIPADeviceIsDefaultOutput];
		
		CFStringRef UIDString = NULL;
		size = sizeof(CFStringRef);
		error = AudioDeviceGetProperty(devices[d], 0, 0, kAudioDevicePropertyDeviceUID, &size, &UIDString);
		if (error==noErr && UIDString!=NULL)
			[deviceInfo setObject:[(NSString *)UIDString autorelease] forKey:MGMSIPADeviceUID];
		
		CFStringRef nameString = NULL;
		size = sizeof(CFStringRef);
		error = AudioDeviceGetProperty(devices[d], 0, 0, kAudioDevicePropertyDeviceNameCFString, &size, &nameString);
		if (error==noErr && nameString!=NULL)
			[deviceInfo setObject:[(NSString *)nameString autorelease] forKey:MGMSIPADeviceName];
		
		size = 0;
		unsigned int inputChannelCount = 0;
		error = AudioDeviceGetPropertyInfo(devices[d], 0, 1, kAudioDevicePropertyStreamConfiguration, &size, NULL);
		if (error==noErr && size!=0) {
			bufferList = malloc(size);
			if (bufferList!=NULL) {
				error = AudioDeviceGetProperty(devices[d], 0, 1, kAudioDevicePropertyStreamConfiguration, &size, bufferList);
				if (error==noErr) {
					for (unsigned int i=0; i<bufferList->mNumberBuffers; i++)
						inputChannelCount += bufferList->mBuffers[i].mNumberChannels;
				}
				free(bufferList);
				[deviceInfo setObject:[NSNumber numberWithUnsignedInt:inputChannelCount] forKey:MGMSIPADeviceInputCount];
			}
		}
		
		size = 0;
		unsigned int outputChannelCount = 0;
		error = AudioDeviceGetPropertyInfo(devices[d], 0, 0, kAudioDevicePropertyStreamConfiguration, &size, NULL);
		if(error==noErr && size!=0) {
			bufferList = malloc(size);
			if (bufferList!=NULL) {
				error = AudioDeviceGetProperty(devices[d], 0, 0, kAudioDevicePropertyStreamConfiguration, &size, bufferList);
				if (error==noErr) {
					for (unsigned int i = 0; i < bufferList->mNumberBuffers; ++i)
						outputChannelCount += bufferList->mBuffers[i].mNumberChannels;
				}
				free(bufferList);
				[deviceInfo setObject:[NSNumber numberWithUnsignedInt:outputChannelCount] forKey:MGMSIPADeviceOutputCount];
			}
		}
		
		if ([[deviceInfo objectForKey:MGMSIPADeviceInputCount] unsignedIntValue]!=0 && [[deviceInfo objectForKey:MGMSIPADeviceUID] isEqual:[defaults objectForKey:MGMSIPACurrentInputDevice]])
			currentInput = d;
		if ([[deviceInfo objectForKey:MGMSIPADeviceOutputCount] unsignedIntValue]!=0 && [[deviceInfo objectForKey:MGMSIPADeviceUID] isEqual:[defaults objectForKey:MGMSIPACurrentOutputDevice]])
			currentOutput = d;
		
		if ([[deviceInfo objectForKey:MGMSIPADeviceInputCount] unsignedIntValue]!=0 || [[deviceInfo objectForKey:MGMSIPADeviceOutputCount] unsignedIntValue]!=0)
			[devicesArray addObject:deviceInfo];
	}
	free(devices);
	
	if (audioDevices!=nil) [audioDevices release];
	audioDevices = [devicesArray copy];
	
	pj_thread_desc PJThreadDesc;
	[self registerThread:&PJThreadDesc];
	
	pjsua_set_null_snd_dev();
	pjmedia_snd_deinit();
	pjmedia_snd_init(pjsua_get_pool_factory());
	
	[self setInputSoundDevice:currentInput outputSoundDevice:currentOutput];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMSIPAudioChangedNotification object:audioDevices];
	bzero(&PJThreadDesc, sizeof(pj_thread_desc));
	[pool drain];
}
- (NSArray *)audioDevices {
	return audioDevices;
}
#endif

- (void)receivedNewCall:(MGMSIPCall *)theCall {
	if (delegate!=nil && [delegate respondsToSelector:@selector(receivedNewCall:)]) [delegate receivedNewCall:theCall];
}
- (void)startingNewCall:(MGMSIPCall *)theCall {
	if (delegate!=nil && [delegate respondsToSelector:@selector(startingNewCall:)]) [delegate startingNewCall:theCall];
}
- (NSArray *)calls {
	NSMutableArray *calls = [NSMutableArray array];
	for (int i=0; i<[accounts count]; i++)
		[calls addObjectsFromArray:[[accounts objectAtIndex:i] calls]];
	return calls;
}
- (MGMSIPCall *)callWithIdentifier:(int)theIdentifier {
	for (int i=0; i<[accounts count]; i++) {
		MGMSIPCall *call = [[accounts objectAtIndex:i] callWithIdentifier:theIdentifier];
		if (call!=nil)
			return call;
	}
	return nil;
}
@end
#endif