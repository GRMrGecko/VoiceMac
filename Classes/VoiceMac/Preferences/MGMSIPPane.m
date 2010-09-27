//
//  MGMSIPPane.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/16/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIPPane.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMSIPPane
- (id)initWithPreferences:(MGMPreferences *)thePreferences {
	if (self = [super initWithPreferences:thePreferences]) {
        if (![NSBundle loadNibNamed:@"SIPPane" owner:self]) {
            NSLog(@"Unable to load Nib for SIP Preferences");
            [self release];
            self = nil;
        } else {
			shouldRestart = NO;
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			//Sound
			[volumeSlider setFloatValue:[[MGMSIP sharedSIP] volume]];
			[micVolumeSlider setFloatValue:[[MGMSIP sharedSIP] micVolume]];
			[self audioChanged:nil];
			[echoCancelationButton setState:([defaults boolForKey:MGMSIPEchoCacnellationEnabled] ? NSOnState : NSOffState)];
			[voiceActivityDetectionButton setState:([defaults boolForKey:MGMSIPVoiceActivityDetection] ? NSOnState : NSOffState)];
			
			//Network
			[[localPortField cell] setPlaceholderString:[[NSNumber numberWithInt:[[MGMSIP sharedSIP] port]] stringValue]];
			if ([defaults integerForKey:MGMSIPPort]!=0)
				[localPortField setIntValue:[defaults integerForKey:MGMSIPPort]];
			if ([defaults objectForKey:MGMSIPOutboundProxy]!=nil && ![[defaults objectForKey:MGMSIPOutboundProxy] isEqual:@""])
				[outboundProxyHostField setStringValue:[defaults objectForKey:MGMSIPOutboundProxy]];
			if ([defaults integerForKey:MGMSIPOutboundProxyPort]!=0)
				[outboundProxyPortField setIntValue:[defaults integerForKey:MGMSIPOutboundProxyPort]];
			if ([defaults objectForKey:MGMSIPSTUN]!=nil && ![[defaults objectForKey:MGMSIPSTUN] isEqual:@""])
				[STUNServerField setStringValue:[defaults objectForKey:MGMSIPSTUN]];
			if ([defaults integerForKey:MGMSIPSTUNPort]!=0)
				[STUNServerPortField setIntValue:[defaults integerForKey:MGMSIPSTUNPort]];
			[nameServersButton setState:([defaults boolForKey:MGMSIPNameServersEnabled] ? NSOnState : NSOffState)];
			[ICEButton setState:([defaults boolForKey:MGMSIPInteractiveConnectivityEstablishment] ? NSOnState : NSOffState)];
			
			//Advanced
			if ([defaults objectForKey:MGMSIPLogFile]!=nil && ![[defaults objectForKey:MGMSIPLogFile] isEqual:@""])
				[logFileField setStringValue:[defaults objectForKey:MGMSIPLogFile]];
			[logFileLevelField setIntValue:[defaults integerForKey:MGMSIPLogLevel]];
			[consoleLogLevelField setIntValue:[defaults integerForKey:MGMSIPConsoleLogLevel]];
			if ([defaults objectForKey:MGMSIPPublicAddress]!=nil && ![[defaults objectForKey:MGMSIPPublicAddress] isEqual:@""])
				[publicAddressField setStringValue:[defaults objectForKey:MGMSIPPublicAddress]];
			
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter addObserver:self selector:@selector(volumeChanged:) name:MGMSIPVolumeChangedNotification object:nil];
			[notificationCenter addObserver:self selector:@selector(micVolumeChanged:) name:MGMSIPMicVolumeChangedNotification object:nil];
			[notificationCenter addObserver:self selector:@selector(audioChanged:) name:MGMSIPAudioChangedNotification object:nil];
        }
    }
    return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (shouldRestart) {
		NSAlert *alert = [[NSAlert new] autorelease];
		[alert setMessageText:@"Restart Required"];
		[alert setInformativeText:@"You have changed some settings that requires you to restart VoiceMac for them to take place, do you want to restart VoiceMac now?"];
		[alert addButtonWithTitle:@"Yes"];
		[alert addButtonWithTitle:@"No"];
		int result = [alert runModal];
		if (result==1000) {
			//Took from Sparkle.
			NSString *pathToRelaunch = [[NSBundle mainBundle] bundlePath];
			NSString *relaunchPath = [[[NSBundle bundleWithIdentifier:@"org.andymatuschak.Sparkle"] resourcePath] stringByAppendingPathComponent:@"relaunch"];
			[NSTask launchedTaskWithLaunchPath:relaunchPath arguments:[NSArray arrayWithObjects:pathToRelaunch, [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]], nil]];
			[[NSApplication sharedApplication] terminate:self];
		}
		//[[MGMSIP sharedSIP] restart];
	}
	if (mainView!=nil)
		[mainView release];
	[super dealloc];
}
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem {
	[theItem setLabel:[self title]];
    [theItem setPaletteLabel:[theItem label]];
    [theItem setImage:[NSImage imageNamed:@"SIP"]];
}
+ (NSString *)title {
	return @"SIP Options";
}
- (NSView *)preferencesView {
	return mainView;
}

//Sound
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
- (void)audioChanged:(NSNotification *)theNotificaiton {
	if (![[MGMSIP sharedSIP] isStarted]) {
		[[MGMSIP sharedSIP] start];
		return;
	}
	NSArray *devices = nil;
	if (theNotificaiton==nil || [theNotificaiton object]==nil)
		devices = [[MGMSIP sharedSIP] audioDevices];
	else
		devices = [theNotificaiton object];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMenu *outputMenu = [[NSMenu new] autorelease];
	int outputIndex = 0;
	int outputCount = 0;
	NSMenu *inputMenu = [[NSMenu new] autorelease];
	int inputIndex = 0;
	int inputCount = 0;
	for (int i=0; i<[devices count]; i++) {
		NSDictionary *device = [devices objectAtIndex:i];
		if ([[device objectForKey:MGMSIPADeviceIndex] intValue]==-1 || [[device objectForKey:MGMSIPADeviceOutputCount] intValue]>0) {
			NSMenuItem *item = [[NSMenuItem new] autorelease];
			[item setTitle:[device objectForKey:MGMSIPADeviceName]];
			[item setTag:[[device objectForKey:MGMSIPADeviceIndex] intValue]];
			[outputMenu addItem:item];
			if ([[device objectForKey:MGMSIPADeviceUID] isEqual:[defaults objectForKey:MGMSIPACurrentOutputDevice]])
				outputIndex = outputCount;
			outputCount++;
			if ([[device objectForKey:MGMSIPADeviceIndex] intValue]==-1) {
				[outputMenu addItem:[NSMenuItem separatorItem]];
				outputCount++;
			}
		}
		if ([[device objectForKey:MGMSIPADeviceIndex] intValue]==-1 || [[device objectForKey:MGMSIPADeviceInputCount] intValue]>0) {
			NSMenuItem *item = [[NSMenuItem new] autorelease];
			[item setTitle:[device objectForKey:MGMSIPADeviceName]];
			[item setTag:[[device objectForKey:MGMSIPADeviceIndex] intValue]];
			[inputMenu addItem:item];
			if ([[device objectForKey:MGMSIPADeviceUID] isEqual:[defaults objectForKey:MGMSIPACurrentInputDevice]])
				inputIndex = inputCount;
			inputCount++;
			if ([[device objectForKey:MGMSIPADeviceIndex] intValue]==-1) {
				[inputMenu addItem:[NSMenuItem separatorItem]];
				inputCount++;
			}
		}
 	}
	[audioOutputPopUp setMenu:outputMenu];
	[audioOutputPopUp selectItemAtIndex:outputIndex];
	[audioInputPopUp setMenu:inputMenu];
	[audioInputPopUp selectItemAtIndex:inputIndex];
}
- (IBAction)audio:(id)sender {
	[[MGMSIP sharedSIP] setInputSoundDevice:[[audioInputPopUp selectedItem] tag] outputSoundDevice:[[audioOutputPopUp selectedItem] tag]];
}
- (IBAction)echoCancelation:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:([echoCancelationButton state]==NSOnState) forKey:MGMSIPEchoCacnellationEnabled];
	shouldRestart = YES;
}
- (IBAction)voiceActivityDetection:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:([voiceActivityDetectionButton state]==NSOnState) forKey:MGMSIPVoiceActivityDetection];
	shouldRestart = YES;
}

//Network
- (IBAction)localPort:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:[localPortField intValue] forKey:MGMSIPPort];
	[[MGMSIP sharedSIP] setPort:[localPortField intValue]];
	shouldRestart = YES;
}
- (IBAction)outboundProxyHost:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[outboundProxyHostField stringValue] forKey:MGMSIPOutboundProxy];
	shouldRestart = YES;
}
- (IBAction)outboundProxyPort:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:[outboundProxyPortField intValue] forKey:MGMSIPOutboundProxyPort];
	shouldRestart = YES;
}
- (IBAction)STUNServer:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[STUNServerField stringValue] forKey:MGMSIPSTUN];
	shouldRestart = YES;
}
- (IBAction)STUNServerPort:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:[STUNServerPortField intValue] forKey:MGMSIPSTUNPort];
	shouldRestart = YES;
}
- (IBAction)nameServer:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:([nameServersButton state]==NSOnState) forKey:MGMSIPNameServersEnabled];
	shouldRestart = YES;
}
- (IBAction)ICE:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:([ICEButton state]==NSOnState) forKey:MGMSIPInteractiveConnectivityEstablishment];
	shouldRestart = YES;
}

//Advanced
- (IBAction)logFile:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[logFileField stringValue] forKey:MGMSIPLogFile];
	shouldRestart = YES;
}
- (IBAction)chooseLogFile:(id)sender {
	NSSavePanel *panel = [NSSavePanel savePanel];
	int returnCode;
	returnCode = [panel runModal];
	if (returnCode==NSOKButton) {
		NSString *path = [[panel URL] path];
		[logFileField setStringValue:path];
		[[NSUserDefaults standardUserDefaults] setObject:path forKey:MGMSIPLogFile];
	}
	shouldRestart = YES;
}
- (IBAction)logFileLevel:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:[logFileLevelField intValue] forKey:MGMSIPLogLevel];
	shouldRestart = YES;
}
- (IBAction)consoleLogLevel:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:[consoleLogLevelField intValue] forKey:MGMSIPConsoleLogLevel];
	shouldRestart = YES;
}
- (IBAction)publicAddress:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[publicAddressField stringValue] forKey:MGMSIPPublicAddress];
	shouldRestart = YES;
}
@end
#endif