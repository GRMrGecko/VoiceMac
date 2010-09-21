//
//  MGMSIPCall.m
//  VoiceBase
//
//  Created by Mr. Gecko on 9/10/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIPCall.h"
#import "MGMSIPAccount.h"
#import "MGMSIPURL.h"
#import "MGMSIP.h"
#import "MGMAddons.h"

@implementation MGMSIPCall
- (id)initWithIdentifier:(int)theIdentifier account:(MGMSIPAccount *)theAccount {
	if (self = [super init]) {
		account = theAccount;
		identifier = theIdentifier;
		
		[[MGMSIP sharedSIP] registerThread];
		
		pjsua_call_info callInfo;
		pj_status_t status = pjsua_call_get_info(identifier, &callInfo);
		if (status!=PJ_SUCCESS) {
			[self release];
			self = nil;
		} else {
			remoteURL = [[MGMSIPURL URLWithSIPID:[NSString stringWithPJString:callInfo.remote_info]] retain];
			localURL = [[MGMSIPURL URLWithSIPID:[NSString stringWithPJString:callInfo.local_info]] retain];
			state = callInfo.state;
			stateText = [[NSString stringWithPJString:callInfo.state_text] copy];
			lastStatus = callInfo.last_status;
			lastStatusText = [[NSString stringWithPJString:callInfo.last_status_text] copy];
			onHold = NO;
			holdMusicPlayer = PJSUA_INVALID_ID;
			recorderID = PJSUA_INVALID_ID;
			
			incoming = (state==MGMSIPCallIncomingState);
			muted = NO;
		}
	}
	return self;
}
- (void)dealloc {
	if (isRingbackOn)
		[self stopRingback];
	[self hangUp];
	if (remoteURL!=nil)
		[remoteURL release];
	if (localURL!=nil)
		[localURL release];
	if (stateText!=nil)
		[stateText release];
	if (lastStatusText!=nil)
		[lastStatusText release];
	if (transferStatusText!=nil)
		[transferStatusText release];
	if (holdMusicPath!=nil)
		[holdMusicPath release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Remote: %@ Local: %@", remoteURL, localURL];
}

- (id<MGMSIPCallDelegate>)delegate {
	return delegate;
}
- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}
- (MGMSIPAccount *)account {
	return account;
}
- (int)identifier {
	return identifier;
}
- (void)setIdentifier:(int)theIdentifier {
	identifier = theIdentifier;
}

- (MGMSIPURL *)remoteURL {
	return remoteURL;
}
- (MGMSIPURL *)localURL {
	return localURL;
}

- (MGMSIPCallState)state {
	return state;
}
- (void)setState:(MGMSIPCallState)theState {
	if (theState==MGMSIPCallDisconnectedState) {
		if (holdMusicPlayer!=PJSUA_INVALID_ID)
			[self performSelectorOnMainThread:@selector(stopHoldMusic) withObject:nil waitUntilDone:NO];
		if (recorderID!=PJSUA_INVALID_ID)
			[self performSelectorOnMainThread:@selector(stopRecordingMain) withObject:nil waitUntilDone:NO];
	}
	state = theState;
}
- (NSString *)stateText {
	return stateText;
}
- (void)setStateText:(NSString *)theStateText {
	if (stateText!=nil) [stateText release];
	stateText = [theStateText copy];
}
- (int)lastStatus {
	return lastStatus;
}
- (void)setLastStatus:(int)theLastStatus {
	lastStatus = theLastStatus;
}
- (NSString *)lastStatusText {
	return lastStatusText;
}
- (void)setLastStatusText:(NSString *)theLastStatusText {
	if (lastStatusText!=nil) [lastStatusText release];
	lastStatusText = [theLastStatusText copy];
}
- (int)transferStatus {
	return transferStatus;
}
- (void)setTransferStatus:(int)theTransferStatus {
	transferStatus = theTransferStatus;
}
- (NSString *)transferStatusText {
	return transferStatusText;
}
- (void)setTransferStatusText:(NSString *)theTransferStatusText {
	if (transferStatusText!=nil) [transferStatusText release];
	transferStatusText = [theTransferStatusText copy];
}
- (BOOL)isIncoming {
	return incoming;
}

- (BOOL)isActive {
	if (identifier==PJSUA_INVALID_ID)
		return NO;
	
	[[MGMSIP sharedSIP] registerThread];
	
	return pjsua_call_is_active(identifier);
}
- (BOOL)hasMedia {
	if (identifier==PJSUA_INVALID_ID)
		return NO;
	
	[[MGMSIP sharedSIP] registerThread];
	
	return pjsua_call_has_media(identifier);
}
- (BOOL)hasActiveMedia {
	if (identifier==PJSUA_INVALID_ID)
		return NO;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(identifier, &callInfo);
	return (callInfo.media_status==PJSUA_CALL_MEDIA_ACTIVE);
}

- (BOOL)isLocalOnHold {
	if (identifier==PJSUA_INVALID_ID)
		return NO;
	
	return onHold;
}
- (BOOL)isRemoteOnHold {
	if (identifier==PJSUA_INVALID_ID)
		return NO;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(identifier, &callInfo);
	return (callInfo.media_status==PJSUA_CALL_MEDIA_REMOTE_HOLD);
}
- (void)setHoldMusicPath:(NSString *)thePath {
	if (holdMusicPath!=nil) [holdMusicPath release];
	holdMusicPath = [thePath copy];
}
- (void)hold {
	[[MGMSIP sharedSIP] registerThread];
	
	if (state==MGMSIPCallConfirmedState) {
		pjsua_conf_port_id conf_port = pjsua_call_get_conf_port(identifier);
		if (!onHold) {
			onHold = YES;
			pjsua_conf_disconnect(0, conf_port);
			pjsua_conf_adjust_rx_level(conf_port, 0);
			[self performSelectorOnMainThread:@selector(startHoldMusic) withObject:nil waitUntilDone:NO];
		} else {
			onHold = NO;
			pjsua_conf_connect(0, conf_port);
			pjsua_conf_adjust_rx_level(conf_port, [[MGMSIP sharedSIP] micVolume]);
			[self performSelectorOnMainThread:@selector(stopHoldMusic) withObject:nil waitUntilDone:NO];
		}
	}
}
- (void)startHoldMusic {
	if (holdMusicPlayer!=PJSUA_INVALID_ID)
		return;
	
	holdMusicPlayer = [self playSoundMain:holdMusicPath loop:YES];
}
- (void)stopHoldMusic {
	[self stopPlayingSound:&holdMusicPlayer];
}

- (void)answer {
	if (identifier==PJSUA_INVALID_ID || state==MGMSIPCallDisconnectedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_status_t status = pjsua_call_answer(identifier, PJSIP_SC_OK, NULL, NULL);
	if (status!=PJ_SUCCESS)
		NSLog(@"Error answering call %@", self);
}
- (void)hangUp {
	if (identifier==PJSUA_INVALID_ID || state==MGMSIPCallDisconnectedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_status_t status = pjsua_call_hangup(identifier, 0, NULL, NULL);
	if (status!=PJ_SUCCESS)
		NSLog(@"Error hanging up call %@", self);
}

- (void)sendRingingNotification {
	if (identifier==PJSUA_INVALID_ID || state==MGMSIPCallDisconnectedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_status_t status = pjsua_call_answer(identifier, PJSIP_SC_RINGING, NULL, NULL);
	if (status!=PJ_SUCCESS)
		NSLog(@"Error sending ringing notification to call %@", self);
}

- (void)replyWithTemporarilyUnavailable {
	if (identifier==PJSUA_INVALID_ID || state==MGMSIPCallDisconnectedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_status_t status = pjsua_call_answer(identifier, PJSIP_SC_TEMPORARILY_UNAVAILABLE, NULL, NULL);
	if (status!=PJ_SUCCESS)
		NSLog(@"Error replying 480 Temporarily Unavailable");
}

- (void)startRingback {
	if (identifier==PJSUA_INVALID_ID || state==MGMSIPCallDisconnectedState)
		return;
	
	if (isRingbackOn)
		return;
	isRingbackOn = YES;
	
	[[MGMSIP sharedSIP] registerThread];
	
	[[MGMSIP sharedSIP] setRingbackCount:[[MGMSIP sharedSIP] ringbackCount]+1];
	if ([[MGMSIP sharedSIP] ringbackCount]==1 && [[MGMSIP sharedSIP] ringbackSlot]!=PJSUA_INVALID_ID)
		pjsua_conf_connect([[MGMSIP sharedSIP] ringbackSlot], 0);
}
- (void)stopRingback {
	if (identifier==PJSUA_INVALID_ID || state==MGMSIPCallDisconnectedState)
		return;
	
	if (!isRingbackOn)
		return;
	isRingbackOn = NO;
	
	[[MGMSIP sharedSIP] registerThread];
	
	int ringbackCount = [[MGMSIP sharedSIP] ringbackCount];
	if (ringbackCount<0) return;
	[[MGMSIP sharedSIP] setRingbackCount:ringbackCount-1];
	if ([[MGMSIP sharedSIP] ringbackSlot]!=PJSUA_INVALID_ID) {
		pjsua_conf_disconnect([[MGMSIP sharedSIP] ringbackSlot], 0);
		pjmedia_tonegen_rewind([[MGMSIP sharedSIP] ringbackPort]);
	}
}

- (void)sendDTMFDigits:(NSString *)theDigits {
	if (identifier==PJSUA_INVALID_ID || state!=MGMSIPCallConfirmedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_str_t digits = [theDigits PJString];
	pj_status_t status = pjsua_call_dial_dtmf(identifier, &digits);
	if (status!=PJ_SUCCESS) {
		const pj_str_t INFO = pj_str("INFO");
		for (unsigned int i=0; i<[theDigits length]; i++) {
			pjsua_msg_data messageData;
			pjsua_msg_data_init(&messageData);
			messageData.content_type = pj_str("application/dtmf-relay");
			messageData.msg_body = [[NSString stringWithFormat:@"Signal=%C\r\nDuration=300", [theDigits characterAtIndex:i]] PJString];
			
			status = pjsua_call_send_request(identifier, &INFO, &messageData);
			if (status!=PJ_SUCCESS)
				NSLog(@"Unable to send DTMF with status %d.", status);
		}
	}
}

- (void)playSound:(NSString *)theFile {
	NSMethodSignature *signature = [self methodSignatureForSelector:@selector(playSoundMain:loop:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:@selector(playSoundMain:loop:)];
	[invocation setArgument:&theFile atIndex:2];
	BOOL shouldLoop = NO;
	[invocation setArgument:&shouldLoop atIndex:3];
	[invocation performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
}
- (pjsua_player_id)playSoundMain:(NSString *)theFile loop:(BOOL)shouldLoop {
	if (identifier==PJSUA_INVALID_ID || state!=MGMSIPCallConfirmedState)
		return PJSUA_INVALID_ID;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_player_id player_id = PJSUA_INVALID_ID;
	if (theFile==nil || ![[NSFileManager defaultManager] fileExistsAtPath:theFile])
		return player_id;
	pj_str_t file = [theFile PJString];
	pj_status_t status = pjsua_player_create(&file, (shouldLoop ? 0 : PJMEDIA_FILE_NO_LOOP), &player_id);
	if (status!=PJ_SUCCESS) {
		NSLog(@"Couldn't create player");
		return PJSUA_INVALID_ID;
	} else {
		status = pjsua_conf_connect(pjsua_player_get_conf_port(player_id), pjsua_call_get_conf_port(identifier));
		if (status!=PJ_SUCCESS)
			NSLog(@"Unable to play sound");
	}
	return player_id;
}
- (void)stopPlayingSound:(pjsua_player_id *)thePlayerID {
	if (*thePlayerID==PJSUA_INVALID_ID)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_player_destroy(*thePlayerID);
	*thePlayerID = PJSUA_INVALID_ID;
}

- (BOOL)isRecording {
	return (recorderID!=PJSUA_INVALID_ID);
}
- (void)startRecording:(NSString *)toFile {
	[self performSelectorOnMainThread:@selector(startRecordingMain:) withObject:toFile waitUntilDone:YES];
}
- (void)startRecordingMain:(NSString *)toFile {
	if (recorderID!=PJSUA_INVALID_ID || identifier==PJSUA_INVALID_ID || state!=MGMSIPCallConfirmedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_str_t file = [toFile PJString];
	pj_status_t status = pjsua_recorder_create(&file, 0, NULL, 0, 0, &recorderID);
	if (status!=PJ_SUCCESS) {
		NSLog(@"Couldn't create recorder");
	} else {
		pjsua_conf_connect(pjsua_call_get_conf_port(identifier), pjsua_recorder_get_conf_port(recorderID));
		pjsua_conf_connect(0, pjsua_recorder_get_conf_port(recorderID));
	}
}
- (void)stopRecording {
	[self performSelectorOnMainThread:@selector(stopRecordingMain) withObject:nil waitUntilDone:YES];
}
- (void)stopRecordingMain {
	if (recorderID==PJSUA_INVALID_ID)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pjsua_recorder_destroy(recorderID);
	recorderID = PJSUA_INVALID_ID;
}

- (BOOL)isMuted {
	return muted;
}
- (void)mute {
	if (identifier==PJSUA_INVALID_ID || holdMusicPlayer!=PJSUA_INVALID_ID || state!=MGMSIPCallConfirmedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_status_t status;
	if (muted)
		status = pjsua_conf_adjust_rx_level(pjsua_call_get_conf_port(identifier), [[MGMSIP sharedSIP] micVolume]);
	else
		status = pjsua_conf_adjust_rx_level(pjsua_call_get_conf_port(identifier), 0);
	if (status!=PJ_SUCCESS)
		NSLog(@"Error %@ speakers for call %@", (muted ? @"unmuting" : @"mutting"), self);
	else
		muted = !muted;
}
- (BOOL)isMicMuted {
	return micMuted;
}
- (void)muteMic {
	if (identifier==PJSUA_INVALID_ID || holdMusicPlayer!=PJSUA_INVALID_ID || state!=MGMSIPCallConfirmedState)
		return;
	
	[[MGMSIP sharedSIP] registerThread];
	
	pj_status_t status;
	if (micMuted)
		status = pjsua_conf_connect(0, pjsua_call_get_conf_port(identifier));
	else
		status = pjsua_conf_disconnect(0, pjsua_call_get_conf_port(identifier));
	if (status!=PJ_SUCCESS)
		NSLog(@"Error %@ microphone for call %@", (micMuted ? @"unmuting" : @"mutting"), self);
	else
		micMuted = !micMuted;
}
@end
#endif