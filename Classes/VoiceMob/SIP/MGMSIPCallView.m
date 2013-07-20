//
//  MGMSIPCallView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/9/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIPCallView.h"
#import "MGMSIPUser.h"
#import "MGMSIPRecordings.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMMiddleView.h"
#import "MGMPhotoSelector.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

@implementation MGMSIPCallView
+ (id)viewWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser {
	return [[[self alloc] initWithCall:theCall SIPUser:theSIPUser] autorelease];
}
- (id)initWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser {
	if ((self = [super init])) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"SIPCall"] owner:self options:nil]) {
			NSLog(@"Unable to load SIP Call View");
			[self release];
			self = nil;
		} else {
			call = [theCall retain];
			[call setDelegate:self];
			[call setHoldMusicPath:[[[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMTCallSoundsFolder] stringByAppendingPathComponent:MGMTSSIPHoldMusic] stringByAppendingPathExtension:MGMWavExt]];
			account = [call account];
			SIPUser = theSIPUser;
			answered = NO;
			
			UIImage *background = nil;
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:MGMSIPBackground] isEqual:MGMSIPBCustom])
				background = [UIImage imageWithContentsOfFile:[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMPSBackground]];
			else
				background = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"]];
			[iImageView setImage:background];
			
			
			CGSize scrollViewSize = [scrollView frame].size;
			[scrollView setContentSize:CGSizeMake(scrollViewSize.width * 4, scrollViewSize.height)];
			[scrollView scrollRectToVisible:CGRectMake(scrollViewSize.width, 0, scrollViewSize.width, scrollViewSize.height) animated:NO];
			
			[optionsView addButtonWithTitle:@"Keypad" imageName:@"keypad" target:self action:@selector(showKeypad:atIndex:)];
			[optionsView addButtonWithTitle:@"Record" imageName:@"record" target:self action:@selector(startRecording:atIndex:)];
			[optionsView addButtonWithTitle:@"Speaker" imageName:@"speaker" target:self action:@selector(playThroughSpeakers:atIndex:)];
			[optionsView addButtonWithTitle:@"Mute Microphone" imageName:@"mutemicrophone" target:self action:@selector(muteMicrophone:atIndex:)];
			[optionsView addButtonWithTitle:@"Mute Speaker" imageName:@"mutespeaker" target:self action:@selector(muteSpeakers:atIndex:)];
			[optionsView addButtonWithTitle:@"Sound Effects" imageName:@"soundeffects" target:self action:@selector(showSoundEffects:atIndex:)];
			
			[keypadView addButtonWithTitle:nil imageName:@"n1" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"ABC" imageName:@"n2" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"DEF" imageName:@"n3" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"GHI" imageName:@"n4" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"JKL" imageName:@"n5" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"MNO" imageName:@"n6" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"PQRS" imageName:@"n7" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"TUV" imageName:@"n8" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"WXYZ" imageName:@"n9" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:nil imageName:@"n*" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:@"+" imageName:@"n0" target:self action:@selector(dial:atIndex:)];
			[keypadView addButtonWithTitle:nil imageName:@"n#" target:self action:@selector(dial:atIndex:)];
			
			NSString *phoneCalling = [SIPUser phoneCalling];
			if (phoneCalling!=nil)
				[[call remoteURL] setUserName:phoneCalling];
			
			if ([call isIncoming] && phoneCalling==nil) {
				if ([[[call remoteURL] userName] isPhone]) {
					NSString *number = [[[call remoteURL] userName] phoneFormat];
					phoneNumber = [[number readableNumber] copy];
					[iPhoneField setText:phoneNumber];
					NSString *name = [[SIPUser contacts] nameForNumber:number];
					if (name==nil || [name isEqual:phoneNumber]) {
						connectionManager = [MGMURLConnectionManager new];
						MGMWhitePagesHandler *handler = [MGMWhitePagesHandler reverseLookup:number delegate:self];
						[connectionManager addHandler:handler];
						[iNameField setText:@"Loading..."];
					} else {
						fullName = [name copy];
						[iNameField setText:fullName];
					}
				} else {
					phoneNumber = [[[call remoteURL] SIPAddress] copy];
					[iPhoneField setText:phoneNumber];
					if ([[call remoteURL] fullName]!=nil && ![[[call remoteURL] fullName] isEqual:@""]) {
						fullName = [[[call remoteURL] fullName] copy];
						[iNameField setText:fullName];
					} else {
						[iNameField setText:@"Unknown"];
					}
				}
				[backgroundView addSubview:incomingView];
				[call sendRingingNotification];
				NSString *ringtonePath = [[[[SIPUser accountController] controller] themeManager] currentSoundPath:MGMTSSIPRingtone];
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
						connectionManager = [MGMURLConnectionManager new];
						MGMWhitePagesHandler *handler = [MGMWhitePagesHandler reverseLookup:number delegate:self];
						[connectionManager addHandler:handler];
					} else {
						fullName = [name copy];
					}
				} else {
					phoneNumber = [[[call remoteURL] SIPAddress] copy];
					if ([[call remoteURL] fullName]!=nil && ![[[call remoteURL] fullName] isEqual:@""])
						fullName = [[[call remoteURL] fullName] copy];
				}
				[self fillCallView];
				if (phoneCalling!=nil)
					[call answer];
				[backgroundView addSubview:callView];
			}
			
			if ([call state]==MGMSIPCallDisconnectedState) {
				[ringtone stop];
				[ringtone release];
				ringtone = nil;
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
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[call setDelegate:nil];
	[call release];
	[connectionManager cancelAll];
	[connectionManager release];
	[fullName release];
	[phoneNumber release];
	[ringtone stop];
	[ringtone release];
	[durationUpdater invalidate];
	[durationUpdater release];
	[startTime release];
	[backgroundView release];
	[iImageView release];
	[incomingView release];
	[iPhoneField release];
	[iNameField release];
	[callView release];
	[scrollView release];
	[phoneField release];
	[nameField release];
	[durationField release];
	[statusField release];
	[optionsView release];
	[keypadView release];
	[volumeSlider release];
	[micVolumeSlider release];
	[sound1Button release];
	[sound2Button release];
	[sound3Button release];
	[sound4Button release];
	[sound5Button release];
	[holdButton release];
	[super dealloc];
}

- (MGMSIPUser *)SIPUser {
	return SIPUser;
}
- (MGMSIPCall *)call {
	return call;
}
- (BOOL)didAnswer {
	return answered;
}

- (UIView *)view {
	return backgroundView;
}

- (void)disconnected:(MGMSIPCall *)theCall {
	[ringtone stop];
	[ringtone release];
	ringtone = nil;
	if ([callView superview]!=nil) {
		[durationUpdater invalidate];
		[durationUpdater release];
		durationUpdater = nil;
		[startTime release];
		startTime = nil;
		[statusField performSelectorOnMainThread:@selector(setText:) withObject:@"Disconnected" waitUntilDone:NO];
		[[[[SIPUser accountController] controller] themeManager] playSound:MGMTSSIPDisconnected];
	} else {
		[ringtone stop];
		[ringtone release];
		ringtone = nil;
		[SIPUser callDone:self];
	}
}
- (void)confirmed:(MGMSIPCall *)theCall {
	[statusField performSelectorOnMainThread:@selector(setText:) withObject:@"Connected" waitUntilDone:NO];
	[[[[SIPUser accountController] controller] themeManager] playSound:MGMTSSIPConnected];
	[self performSelectorOnMainThread:@selector(startDurationTimer) withObject:nil waitUntilDone:NO];
}
- (void)startDurationTimer {
	startTime = [NSDate new];
	durationUpdater = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES] retain];
}

- (void)soundChanged:(NSNotification *)theNotification {
	if ([[theNotification object] isEqual:MGMTSSIPSound1])
		[sound1Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound1] forState:UIControlStateNormal];
	if ([[theNotification object] isEqual:MGMTSSIPSound2])
		[sound2Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound2] forState:UIControlStateNormal];
	if ([[theNotification object] isEqual:MGMTSSIPSound3])
		[sound3Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound3] forState:UIControlStateNormal];
	if ([[theNotification object] isEqual:MGMTSSIPSound4])
		[sound4Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound4] forState:UIControlStateNormal];
	if ([[theNotification object] isEqual:MGMTSSIPSound5])
		[sound5Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound5] forState:UIControlStateNormal];
}

- (void)fillCallView {
	if (fullName!=nil)
		[nameField setText:fullName];
	else
		[nameField setText:@"Unkown"];
	[phoneField setText:phoneNumber];
	[durationField setText:[NSString stringWithSeconds:0]];
	[volumeSlider setValue:[[MGMSIP sharedSIP] volume]];
	[micVolumeSlider setValue:[[MGMSIP sharedSIP] micVolume]];
	if ([call state]!=MGMSIPCallConfirmedState)
		[statusField setText:@"Connecting..."];
	else
		[self confirmed:call];
	
	[sound1Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound1] forState:UIControlStateNormal];
	[sound2Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound2] forState:UIControlStateNormal];
	[sound3Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound3] forState:UIControlStateNormal];
	[sound4Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound4] forState:UIControlStateNormal];
	[sound5Button setTitle:[[[[SIPUser accountController] controller] themeManager] nameOfSound:MGMTSSIPSound5] forState:UIControlStateNormal];
}

- (IBAction)answer:(id)sender {
	[ringtone stop];
	[ringtone release];
	ringtone = nil;
	[call answer];
	[self fillCallView];
	[incomingView removeFromSuperview];
	[backgroundView addSubview:callView];
	answered = YES;
}
- (IBAction)ignore:(id)sender {
	[ringtone stop];
	[ringtone release];
	ringtone = nil;
	[SIPUser callDone:self];
}

- (void)updateDuration {
	int time = [[NSDate date] timeIntervalSinceDate:startTime];
	[durationField setText:[NSString stringWithSeconds:time]];
}

- (void)volumeChanged:(NSNotification *)theNotification {
	[volumeSlider setValue:[[theNotification object] floatValue]];
}
- (IBAction)volume:(id)sender {
	[[MGMSIP sharedSIP] setVolume:[volumeSlider value]];
}
- (void)micVolumeChanged:(NSNotification *)theNotification {
	[micVolumeSlider setValue:[[theNotification object] floatValue]];
}
- (IBAction)micVolume:(id)sender {
	[[MGMSIP sharedSIP] setMicVolume:[micVolumeSlider value]];
}

- (IBAction)hold:(id)sender {
	[call hold];
	[holdButton setTitle:([call isLocalOnHold] ? @"Unhold" : @"Hold") forState:UIControlStateNormal];
}
- (IBAction)hangUp:(id)sender {
	[durationUpdater invalidate];
	[durationUpdater release];
	durationUpdater = nil;
	[startTime release];
	startTime = nil;
	[call hangUp];
	[SIPUser callDone:self];
}

- (void)middleViewDidCancel:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	if (theIndex==1) {
		if ([call isRecording])
			[theMiddleView setHighlighted:YES forButtonAtIndex:1];
	} else if (theIndex==2) {
		if ([call isOnSpeaker])
			[theMiddleView setHighlighted:YES forButtonAtIndex:2];
	} else if (theIndex==3) {
		if ([call isMicMuted])
			[theMiddleView setHighlighted:YES forButtonAtIndex:3];
	} else if (theIndex==4) {
		if ([call isMuted])
			[theMiddleView setHighlighted:YES forButtonAtIndex:4];
	}
}

- (void)showKeypad:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	CGSize scrollViewSize = [scrollView frame].size;
	[scrollView scrollRectToVisible:CGRectMake(scrollViewSize.width*2, 0, scrollViewSize.width, scrollViewSize.height) animated:YES];
}

- (void)startRecording:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	if ([call isRecording]) {
		[call stopRecording];
	} else {
		NSFileManager *manager = [NSFileManager defaultManager];
		NSString *baseName = [[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMRecordingsFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - ", phoneNumber]];
		if (![manager fileExistsAtPath:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMRecordingsFolder]])
			[manager createDirectoryAtPath:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMRecordingsFolder] withIntermediateDirectories:YES attributes:nil error:nil];
		
		NSString *name = nil;
		for (int i=1; i<50; i++) { // Not like someone will have 50 recordings with one person on their desktop...
			name = [[baseName stringByAppendingFormat:@"%02d", i] stringByAppendingPathExtension:MGMWavExt];
			if (![manager fileExistsAtPath:name])
				break;
		}
		[call startRecording:name];
	}
	if ([call isRecording])
		[theMiddleView setHighlighted:YES forButtonAtIndex:1];
}

- (void)playThroughSpeakers:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	[call speaker];
	if ([call isOnSpeaker])
		[theMiddleView setHighlighted:YES forButtonAtIndex:2];
}

- (void)muteMicrophone:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	[call muteMic];
	if ([call isMicMuted])
		[theMiddleView setHighlighted:YES forButtonAtIndex:3];
}
- (void)muteSpeakers:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	[call mute];
	if ([call isMuted])
		[theMiddleView setHighlighted:YES forButtonAtIndex:4];
}

- (void)showSoundEffects:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	CGSize scrollViewSize = [scrollView frame].size;
	[scrollView scrollRectToVisible:CGRectMake(0, 0, scrollViewSize.width, scrollViewSize.height) animated:YES];
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
	[[[[SIPUser accountController] controller] themeManager] performSelector:@selector(playSound:) withObject:soundName afterDelay:0.2]; // The phone has a delay, so why not delay this so you hear it at the same time?
}
- (void)dial:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex {
	if (theIndex==0)
		[call sendDTMFDigits:@"1"];
	else if (theIndex==1)
		[call sendDTMFDigits:@"2"];
	else if (theIndex==2)
		[call sendDTMFDigits:@"3"];
	else if (theIndex==3)
		[call sendDTMFDigits:@"4"];
	else if (theIndex==4)
		[call sendDTMFDigits:@"5"];
	else if (theIndex==5)
		[call sendDTMFDigits:@"6"];
	else if (theIndex==6)
		[call sendDTMFDigits:@"7"];
	else if (theIndex==7)
		[call sendDTMFDigits:@"8"];
	else if (theIndex==8)
		[call sendDTMFDigits:@"9"];
	else if (theIndex==9)
		[call sendDTMFDigits:@"*"];
	else if (theIndex==10)
		[call sendDTMFDigits:@"0"];
	else if (theIndex==11)
		[call sendDTMFDigits:@"#"];
}

- (void)reverseLookupDidFindInfo:(MGMWhitePagesHandler *)theHandler forRequest:(NSDictionary *)theRequest {
	if ([theHandler name]!=nil)
		fullName = [[theHandler name] copy];
	else if ([theHandler location]!=nil)
		fullName = [[theHandler location] copy];
	if (fullName!=nil && [callView superview]!=nil)
		[nameField setText:fullName];
	else if (fullName!=nil && [incomingView superview]!=nil)
		[iNameField setText:fullName];
}
@end
#endif