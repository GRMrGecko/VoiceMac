//
//  MGMSIPCall.h
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

@class MGMSIPCall, MGMSIPAccount, MGMSIPURL;

@protocol MGMSIPCallDelegate <NSObject>
- (void)stateChanged:(MGMSIPCall *)theCall;
- (void)disconnected:(MGMSIPCall *)theCall;
- (void)early:(MGMSIPCall *)theCall code:(int)theCode reason:(NSString *)theReason;
- (void)calling:(MGMSIPCall *)theCall;
- (void)connecting:(MGMSIPCall *)theCall;
- (void)confirmed:(MGMSIPCall *)theCall;
- (void)mediaStateChanged:(MGMSIPCall *)theCall;
- (void)becameActive:(MGMSIPCall *)theCall;
- (void)localPlacedHold:(MGMSIPCall *)theCall;
- (void)remotePlacedHold:(MGMSIPCall *)theCall;
- (void)transferStatusCahgned:(MGMSIPCall *)theCall;
- (void)receivedDMTFDigit:(int)theDigit;
@end

typedef enum {
	MGMSIPCallNULLState = PJSIP_INV_STATE_NULL,
	MGMSIPCallCallingState = PJSIP_INV_STATE_CALLING,
	MGMSIPCallIncomingState = PJSIP_INV_STATE_INCOMING,
	MGMSIPCallEarlyState = PJSIP_INV_STATE_EARLY,
	MGMSIPCallConnectingState = PJSIP_INV_STATE_CONNECTING,
	MGMSIPCallConfirmedState = PJSIP_INV_STATE_CONFIRMED,
	MGMSIPCallDisconnectedState = PJSIP_INV_STATE_DISCONNECTED
} MGMSIPCallState;

@interface MGMSIPCall : NSObject {
	id<MGMSIPCallDelegate> delegate;
	MGMSIPAccount *account;
	pjsua_call_id identifier;
	
	MGMSIPURL *remoteURL;
	MGMSIPURL *localURL;
	MGMSIPCallState state;
	NSString *stateText;
	int lastStatus;
	NSString *lastStatusText;
	int transferStatus;
	NSString *transferStatusText;
	BOOL incoming;
	BOOL muted;
	BOOL micMuted;
	BOOL speaker;
	NSString *holdMusicPath;
	BOOL onHold;
	pjsua_player_id holdMusicPlayer;
	pjsua_recorder_id recorderID;
	
	pjmedia_port *toneGenPort;
	pjsua_conf_port_id toneGenSlot;
	
	BOOL isRingbackOn;
}
- (id)initWithIdentifier:(int)theIdentifier account:(MGMSIPAccount *)theAccount;

- (id<MGMSIPCallDelegate>)delegate;
- (void)setDelegate:(id)theDelegate;
- (MGMSIPAccount *)account;
- (pjsua_call_id)identifier;
- (void)setIdentifier:(pjsua_call_id)theIdentifier;

- (MGMSIPURL *)remoteURL;
- (MGMSIPURL *)localURL;

- (MGMSIPCallState)state;
- (void)setState:(MGMSIPCallState)theState;
- (NSString *)stateText;
- (void)setStateText:(NSString *)theStateText;
- (int)lastStatus;
- (void)setLastStatus:(int)theLastStatus;
- (NSString *)lastStatusText;
- (void)setLastStatusText:(NSString *)theLastStatusText;
- (int)transferStatus;
- (void)setTransferStatus:(int)theTransferStatus;
- (NSString *)transferStatusText;
- (void)setTransferStatusText:(NSString *)theTransferStatusText;;
- (BOOL)isIncoming;

- (BOOL)isActive;
- (BOOL)hasMedia;
- (BOOL)hasActiveMedia;

- (BOOL)isLocalOnHold;
- (BOOL)isRemoteOnHold;
- (void)setHoldMusicPath:(NSString *)thePath;
- (void)hold;

- (void)answer;
- (void)hangUp;

- (void)sendRingingNotification;

- (void)replyWithTemporarilyUnavailable;

- (void)startRingback;
- (void)stopRingback;

- (void)sendDTMFDigits:(NSString *)theDigits;
- (void)receivedDTMFDigit:(int)theDigit;

- (void)playSound:(NSString *)theFile;
- (pjsua_player_id)playSoundMain:(NSString *)theFile loop:(BOOL)shouldLoop;
- (void)stopPlayingSound:(pjsua_player_id *)thePlayerID;

- (BOOL)isRecording;
- (void)startRecording:(NSString *)toFile;
- (void)stopRecording;

- (BOOL)isMuted;
- (void)mute;
- (BOOL)isMicMuted;
- (void)muteMic;

#if TARGET_OS_IPHONE
- (BOOL)isOnSpeaker;
- (void)speaker;
#endif
@end
#endif