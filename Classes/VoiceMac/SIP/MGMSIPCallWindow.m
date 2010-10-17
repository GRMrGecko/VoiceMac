//
//  MGMSIPCallWindow.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/14/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIPCallWindow.h"
#import "MGMSIPUser.h"
#import "MGMController.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <QTKit/QTKit.h>

NSString * const MGMSCTitleFormat = @"Call With %@ %@";
NSString * const MGMSCTitleNoNameFormat = @"Call With %@";

@implementation MGMSIPCallWindow
+ (id)windowWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser {
	return [[[self alloc] initWithCall:theCall SIPUser:theSIPUser] autorelease];
}
- (id)initWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser {
	if (self = [super init]) {
		if (![NSBundle loadNibNamed:@"SIPCallWindow" owner:self]) {
			NSLog(@"Unable to load SIP Call Window!");
			[self release];
			self = nil;
		} else {
			call = [theCall retain];
			[call setDelegate:self];
			[call setHoldMusicPath:[[[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMTCallSoundsFolder] stringByAppendingPathComponent:MGMTSSIPHoldMusic] stringByAppendingPathExtension:MGMWavExt]];
			account = [call account];
			SIPUser = theSIPUser;
			[callWindow setLevel:NSNormalWindowLevel];
			[callWindow setExcludedFromWindowsMenu:NO];
			[[callWindow contentView] addSubview:numberPadView];
			NSRect padFrame = [numberPadView frame];
			callWindowSize = [callWindow frame].size;
			callWindowPadSize = [callWindow frame].size;
			padFrame.origin.y -= callWindowSize.height;
			callWindowPadSize.height += padFrame.size.height;
			[numberPadView setFrame:padFrame];
			[incomingWindow setLevel:NSStatusWindowLevel];
			[incomingWindow setExcludedFromWindowsMenu:YES];
			
			NSString *phoneCalling = [SIPUser phoneCalling];
			if (phoneCalling!=nil)
				[[call remoteURL] setUserName:phoneCalling];
			
			if ([call isIncoming] && phoneCalling==nil) {
				if ([[[call remoteURL] userName] isPhone]) {
					NSString *number = [[[call remoteURL] userName] phoneFormat];
					phoneNumber = [[number readableNumber] copy];
					[phoneField setStringValue:phoneNumber];
					NSString *name = [[SIPUser contacts] nameForNumber:number];
					if (name==nil || [name isEqual:phoneNumber]) {
						whitePages = [MGMWhitePages new];
						[whitePages reverseLookup:number delegate:self];
						[nameField setStringValue:@"Loading..."];
					} else {
						fullName = [name copy];
						[nameField setStringValue:fullName];
					}
				} else {
					phoneNumber = [[[call remoteURL] SIPAddress] copy];
					[phoneField setStringValue:phoneNumber];
					if ([[call remoteURL] fullName]!=nil && ![[[call remoteURL] fullName] isEqual:@""]) {
						fullName = [[[call remoteURL] fullName] copy];
						[nameField setStringValue:fullName];
					} else {
						[nameField setStringValue:@"Unknown"];
					}
				}
				[incomingWindow makeKeyAndOrderFront:self];
				[call sendRingingNotification];
				NSString *ringtonePath = [[[SIPUser controller] themeManager] currentSoundPath:MGMTSSIPRingtone];
				if (ringtonePath!=nil && ![ringtonePath isEqual:MGMTNoSound]) {
					ringtone = [[MGMSound alloc] initWithContentsOfFile:ringtonePath];
					[ringtone setLoops:YES];
					[ringtone play];
				}
			} else {
				if ([[[call remoteURL] userName] isPhone]) {
					NSString *number = [[[call remoteURL] userName] phoneFormat];
					phoneNumber = [[number readableNumber] copy];
					NSString *name = [[SIPUser contacts] nameForNumber:number];
					if (name==nil || [name isEqual:phoneNumber]) {
						whitePages = [MGMWhitePages new];
						[whitePages reverseLookup:number delegate:self];
					} else {
						fullName = [name copy];
					}
				} else {
					phoneNumber = [[[call remoteURL] SIPAddress] copy];
					if ([[call remoteURL] fullName]!=nil && ![[[call remoteURL] fullName] isEqual:@""])
						fullName = [[[call remoteURL] fullName] copy];
				}
				[self fillCallWindow];
				if (phoneCalling!=nil)
					[call answer];
				[callWindow makeKeyAndOrderFront:self];
			}
			
			if ([call state]==MGMSIPCallDisconnectedState) {
				if (ringtone!=nil) {
					[ringtone stop];
					[ringtone release];
					ringtone = nil;
				}
			}
			
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter addObserver:self selector:@selector(soundChanged:) name:MGMTSoundChangedNotification object:nil];
			[notificationCenter addObserver:self selector:@selector(volumeChanged:) name:MGMSIPVolumeChangedNotification object:nil];
			[notificationCenter addObserver:self selector:@selector(micVolumeChanged:) name:MGMSIPMicVolumeChangedNotification object:nil];
		}
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self hidePad];
	if (call!=nil) {
		[call setDelegate:nil];
		[call release];
	}
	if (whitePages!=nil)
		[whitePages release];
	if (incomingWindow!=nil)
		[incomingWindow release];
	if (callWindow!=nil)
		[callWindow release];
	if (fullName!=nil)
		[fullName release];
	if (phoneNumber!=nil)
		[phoneNumber release];
	if (ringtone!=nil) {
		[ringtone stop];
		[ringtone release];
	}
	if (startTime!=nil)
		[startTime release];
	if (durationUpdater!=nil) {
		[durationUpdater invalidate];
		[durationUpdater release];
	}
	[super dealloc];
}

- (void)disconnected:(MGMSIPCall *)theCall {
	if (ringtone!=nil) {
		[ringtone stop];
		[ringtone release];
		ringtone = nil;
	}
	if ([callWindow isVisible]) {
		if (durationUpdater!=nil) {
			[durationUpdater invalidate];
			[durationUpdater release];
			durationUpdater = nil;
		}
		if (startTime!=nil) {
			[startTime release];
			startTime = nil;
		}
		[statusField setStringValue:@"Disconnected"];
		[[[SIPUser controller] themeManager] playSound:MGMTSSIPDisconnected];
	} else {
		if ([incomingWindow isVisible])
			[incomingWindow close];
		[SIPUser callDone:self];
	}
}
- (void)confirmed:(MGMSIPCall *)theCall {
	[statusField setStringValue:@"Connected"];
	[[[SIPUser controller] themeManager] playSound:MGMTSSIPConnected];
	[self performSelectorOnMainThread:@selector(startDurationTimer) withObject:nil waitUntilDone:NO];
}
- (void)startDurationTimer {
	startTime = [NSDate new];
	durationUpdater = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES] retain];
}

- (void)soundChanged:(NSNotification *)theNotification {
	if ([[theNotification object] isEqual:MGMTSSIPSound1])
		[sound1Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound1]];
	if ([[theNotification object] isEqual:MGMTSSIPSound2])
		[sound2Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound2]];
	if ([[theNotification object] isEqual:MGMTSSIPSound3])
		[sound3Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound3]];
	if ([[theNotification object] isEqual:MGMTSSIPSound4])
		[sound4Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound4]];
	if ([[theNotification object] isEqual:MGMTSSIPSound5])
		[sound5Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound5]];
}

- (void)fillCallWindow {
	if (fullName==nil)
		[self setTitle:[NSString stringWithFormat:MGMSCTitleNoNameFormat, phoneNumber]];
	else
		[self setTitle:[NSString stringWithFormat:MGMSCTitleFormat, fullName, phoneNumber]];
	[durationField setStringValue:[NSString stringWithSeconds:0]];
	[volumeSlider setFloatValue:[[MGMSIP sharedSIP] volume]];
	[micVolumeSlider setFloatValue:[[MGMSIP sharedSIP] micVolume]];
	if ([call state]!=MGMSIPCallConfirmedState)
		[statusField setStringValue:@"Connecting..."];
	else
		[self confirmed:call];
	
	[sound1Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound1]];
	[sound2Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound2]];
	[sound3Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound3]];
	[sound4Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound4]];
	[sound5Button setTitle:[[[SIPUser controller] themeManager] nameOfSound:MGMTSSIPSound5]];
}
- (IBAction)answer:(id)sender {
	if (ringtone!=nil) {
		[ringtone stop];
		[ringtone release];
		ringtone = nil;
	}
	[incomingWindow close];
	[call answer];
	[self fillCallWindow];
	[callWindow makeKeyAndOrderFront:self];
}
- (IBAction)ignore:(id)sender {
	if (ringtone!=nil) {
		[ringtone stop];
		[ringtone release];
		ringtone = nil;
	}
	[incomingWindow close];
	[SIPUser callDone:self];
}

- (void)updateDuration {
	int time = [[NSDate date] timeIntervalSinceDate:startTime];
	[durationField setStringValue:[NSString stringWithSeconds:time]];
}

- (void)setTitle:(NSString *)theTitle {
	[titleField setStringValue:theTitle];
	[callWindow setTitle:theTitle];
}

- (void)volumeChanged:(NSNotification *)theNotification {
	[volumeSlider setFloatValue:[[theNotification object] floatValue]];
}
- (IBAction)volume:(id)sender {
	[[MGMSIP sharedSIP] setVolume:[volumeSlider floatValue]];
}
- (void)micVolumeChanged:(NSNotification *)theNotification {
	[micVolumeSlider setFloatValue:[[theNotification object] floatValue]];
}
- (IBAction)micVolume:(id)sender {
	[[MGMSIP sharedSIP] setMicVolume:[micVolumeSlider floatValue]];
}

- (IBAction)hold:(id)sender {
	[call hold];
	[holdButton setImage:[NSImage imageNamed:([call isLocalOnHold] ? @"unholdButton" : @"holdButton")]];
}
- (void)hidePad {
	if (NSEqualSizes([callWindow frame].size, callWindowPadSize)) {
		NSRect frame = [callWindow frame];
		frame.origin.y -= callWindowSize.height-frame.size.height;
		frame.size = callWindowSize;
		[callWindow setFrame:frame display:NO animate:NO];
	}
}
- (IBAction)showPad:(id)sender {
	if (NSEqualSizes([callWindow frame].size, callWindowSize)) {
		NSRect frame = [callWindow frame];
		frame.origin.y -= callWindowPadSize.height-frame.size.height;
		frame.size = callWindowPadSize;
		[callWindow setFrame:frame display:YES animate:YES];
	} else {
		NSRect frame = [callWindow frame];
		frame.origin.y -= callWindowSize.height-frame.size.height;
		frame.size = callWindowSize;
		[callWindow setFrame:frame display:YES animate:YES];
	}
}
- (IBAction)hangUp:(id)sender {
	[callWindow close];
	if (durationUpdater!=nil) {
		[durationUpdater invalidate];
		[durationUpdater release];
		durationUpdater = nil;
	}
	if (startTime!=nil) {
		[startTime release];
		startTime = nil;
	}
	[call hangUp];
	[SIPUser callDone:self];
}

- (IBAction)startRecording:(id)sender {
	if ([call isRecording]) {
		[call stopRecording];
	} else {
		NSFileManager *manager = [NSFileManager defaultManager];
		NSString *baseName = [[NSString stringWithFormat:@"~/Desktop/Call With %@ - ", phoneNumber] stringByExpandingTildeInPath];
		NSString *name = nil;
		for (int i=1; i<50; i++) { // Not like someone will have 50 recordings with one person on their desktop...
			name = [[baseName stringByAppendingFormat:@"%02d", i] stringByAppendingPathExtension:MGMWavExt];
			if (![manager fileExistsAtPath:name])
				break;
		}
		[call startRecording:name];
	}
	[recordingButton setTitle:([call isRecording] ? @"Stop Recording" : @"Start Recording")];
}
- (IBAction)muteMicrophone:(id)sender {
	[call muteMic];
	[muteMicrophoneButton setTitle:([call isMicMuted] ? @"Unmute Microphone" : @"Mute Microphone")];
}
- (IBAction)muteSpeakers:(id)sender {
	[call mute];
	[muteSpeakersButton setTitle:([call isMuted] ? @"Unmute Speakers" : @"Mute Speakers")];
}
- (IBAction)sound:(id)sender {
	NSString *soundName = nil;
	if (sender==sound1Button)
		soundName = MGMTSSIPSound1;
	else if (sender==sound2Button)
		soundName = MGMTSSIPSound2;
	else if (sender==sound3Button)
		soundName = MGMTSSIPSound3;
	else if (sender==sound4Button)
		soundName = MGMTSSIPSound4;
	else if (sender==sound5Button)
		soundName = MGMTSSIPSound5;
	NSString *soundFile = [[[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMTCallSoundsFolder] stringByAppendingPathComponent:soundName] stringByAppendingPathExtension:MGMWavExt];
	[call playSound:soundFile];
	[[[SIPUser controller] themeManager] performSelector:@selector(playSound:) withObject:soundName afterDelay:0.2]; // The phone has a delay, so why not delay this so you hear it at the same time?
}
- (IBAction)dial:(id)sender {
	if (sender==n1Button)
		[call sendDTMFDigits:@"1"];
	else if (sender==n2Button)
		[call sendDTMFDigits:@"2"];
	else if (sender==n3Button)
		[call sendDTMFDigits:@"3"];
	else if (sender==n4Button)
		[call sendDTMFDigits:@"4"];
	else if (sender==n5Button)
		[call sendDTMFDigits:@"5"];
	else if (sender==n6Button)
		[call sendDTMFDigits:@"6"];
	else if (sender==n7Button)
		[call sendDTMFDigits:@"7"];
	else if (sender==n8Button)
		[call sendDTMFDigits:@"8"];
	else if (sender==n9Button)
		[call sendDTMFDigits:@"9"];
	else if (sender==nStarButton)
		[call sendDTMFDigits:@"*"];
	else if (sender==n0Button)
		[call sendDTMFDigits:@"0"];
	else if (sender==nPoundButton)
		[call sendDTMFDigits:@"#"];
}

- (void)reverseLookupDidFindInfo:(NSDictionary *)theInfo forRequest:(NSDictionary *)theRequest {
	if ([theInfo objectForKey:MGMWPName]!=nil) {
		fullName = [[theInfo objectForKey:MGMWPName] copy];
		if ([callWindow isVisible])
			[self setTitle:[NSString stringWithFormat:MGMSCTitleFormat, fullName, phoneNumber]];
		else
			[nameField setStringValue:fullName];
	} else if ([theInfo objectForKey:MGMWPLocation]!=nil) {
		if ([incomingWindow isVisible])
			[nameField setStringValue:[theInfo objectForKey:MGMWPLocation]];
	}
}
@end
#endif