//
//  MGMSIP.h
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
#import <SystemConfiguration/SystemConfiguration.h>
#endif
#import <pjsua-lib/pjsua.h>

@class MGMSIPAccount, MGMSIPCall;

extern NSString * const MGMSIPOutboundProxy;
extern NSString * const MGMSIPOutboundProxyPort;
extern NSString * const MGMSIPSTUN;
extern NSString * const MGMSIPSTUNPort;
extern NSString * const MGMSIPLogFile;
extern NSString * const MGMSIPLogLevel;
extern NSString * const MGMSIPConsoleLogLevel;
extern NSString * const MGMSIPVoiceActivityDetection;
extern NSString * const MGMSIPInteractiveConnectivityEstablishment;
extern NSString * const MGMSIPNameServersEnabled;
extern NSString * const MGMSIPEchoCacnellationEnabled;
extern NSString * const MGMSIPPort;
extern NSString * const MGMSIPPublicAddress;

extern NSString * const MGMNetworkConnectedNotification;
extern NSString * const MGMNetworkDisconnectedNotification;

extern NSString * const MGMSIPVolume;
extern NSString * const MGMSIPMicVolume;
extern NSString * const MGMSIPVolumeChangedNotification;
extern NSString * const MGMSIPMicVolumeChangedNotification;

extern NSString * const MGMSIPADeviceIdentifier;
extern NSString * const MGMSIPADeviceIndex;
extern NSString * const MGMSIPADeviceUID;
extern NSString * const MGMSIPADeviceName;
extern NSString * const MGMSIPADeviceInputCount;
extern NSString * const MGMSIPADeviceOutputCount;
extern NSString * const MGMSIPADeviceIsDefaultInput;
extern NSString * const MGMSIPADeviceIsDefaultOutput;

extern NSString * const MGMSIPACurrentInputDevice;
extern NSString * const MGMSIPACurrentOutputDevice;
extern NSString * const MGMSIPASystemDefault;
extern NSString * const MGMSIPAudioChangedNotification;

@protocol MGMSIPDelegate <NSObject>
- (void)SIPStarted;
- (void)SIPStopped;
- (void)accountLoggedIn:(MGMSIPAccount *)theAccount;
- (void)accountLoggedOut:(MGMSIPAccount *)theAccount;
- (void)receivedNewCall:(MGMSIPCall *)theCall;
- (void)startingNewCall:(MGMSIPCall *)theCall;
- (void)gotNewCall:(MGMSIPCall *)theCall;
@end

typedef enum {
	MGMSIPNULLState = -1,
	MGMSIPStoppedState = 0,
	MGMSIPStartingState = 1,
	MGMSIPStartedState = 2,
	MGMSIPStoppingState = 3
} MGMSIPState;

typedef enum {
	MGMSIPNATUnknownType = PJ_STUN_NAT_TYPE_UNKNOWN,
	MGMSIPNATErrorUnknownType = PJ_STUN_NAT_TYPE_ERR_UNKNOWN,
	MGMSIPNATOpen = PJ_STUN_NAT_TYPE_OPEN,
	MGMSIPNATBlocked = PJ_STUN_NAT_TYPE_BLOCKED,
	MGMSIPNATSymmetricUDP = PJ_STUN_NAT_TYPE_SYMMETRIC_UDP,
	MGMSIPNATFullCone = PJ_STUN_NAT_TYPE_FULL_CONE,
	MGMSIPNATSymmetric = PJ_STUN_NAT_TYPE_SYMMETRIC,
	MGMSIPNATRestricted = PJ_STUN_NAT_TYPE_RESTRICTED,
	MGMSIPNATPortRestricted = PJ_STUN_NAT_TYPE_PORT_RESTRICTED
} MGMSIPNATType;

@interface MGMSIP : NSObject {
	id<MGMSIPDelegate> delegate;
	NSLock *lock;
	MGMSIPState state;
	
	pj_pool_t *PJPool;
	int port;
	pjsua_media_config mediaConfig;
	pjmedia_port *ringbackPort;
	pjsua_conf_port_id ringbackSlot;
	pjsua_transport_id UDPTransport;
	pjsua_transport_id TCPTransport;
	MGMSIPNATType NATType;
	
	BOOL shouldRestart;
	NSTimer *restartTimer;
	
	NSMutableArray *accounts;
	NSMutableArray *restartAccounts;
#if !TARGET_OS_IPHONE
	NSArray *audioDevices;
	int lastInputDevice;
	int lastOutputDevice;
#endif
	
	int ringbackCount;
	
#if !TARGET_OS_IPHONE
	SCDynamicStoreRef store;
	CFRunLoopSourceRef storeRunLoop;
#endif
}
+ (MGMSIP *)sharedSIP;

- (void)registerDefaults;

- (id<MGMSIPDelegate>)delegate;
- (void)setDelegate:(id)theDelegate;

- (MGMSIPState)state;
- (BOOL)isStarted;
- (pj_pool_t *)PJPool;
- (int)port;
- (void)setPort:(int)thePort;
- (pjsua_media_config)mediaConfig;
- (pjmedia_port *)ringbackPort;
- (pjsua_conf_port_id)ringbackSlot;
- (MGMSIPNATType)NATType;
- (void)setNATType:(MGMSIPNATType)theNATType;

- (void)start;
- (void)stop;
- (void)restart;
- (void)computerSleep;
- (void)computerWake;

- (void)registerThread:(pj_thread_desc *)thePJThreadDesc;

- (void)loginToAccount:(MGMSIPAccount *)theAccount;
- (void)logoutOfAccount:(MGMSIPAccount *)theAccount;

- (NSArray *)accounts;
- (MGMSIPAccount *)accountWithIdentifier:(int)theIdentifier;

- (int)ringbackCount;
- (void)setRingbackCount:(int)theRingbackCount;

- (void)hangUpAllCalls;

- (float)volume;
- (void)setVolume:(float)theVolume;
- (float)micVolume;
- (void)setMicVolume:(float)theVolume;

#if !TARGET_OS_IPHONE
- (BOOL)setInputSoundDevice:(int)theInputDevice outputSoundDevice:(int)theOutputDevice;
- (BOOL)stopAudio;
- (void)updateAudioDevices;
- (NSArray *)audioDevices;
#endif

- (void)receivedNewCall:(MGMSIPCall *)theCall;
- (void)startingNewCall:(MGMSIPCall *)theCall;
- (NSArray *)calls;
- (MGMSIPCall *)callWithIdentifier:(int)theIdentifier;
@end
#endif