//
//  MGMSIPPane.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/16/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import <Cocoa/Cocoa.h>
#import <MGMUsers/MGMUsers.h>

@interface MGMSIPPane : MGMPreferencesPane {
	IBOutlet NSView *mainView;
	BOOL shouldRestart;
	
	//Sound Tab
	IBOutlet NSSlider *volumeSlider;
	IBOutlet NSSlider *micVolumeSlider;
	IBOutlet NSPopUpButton *audioOutputPopUp;
	IBOutlet NSPopUpButton *audioInputPopUp;
	IBOutlet NSButton *echoCancelationButton;
	IBOutlet NSButton *voiceActivityDetectionButton;
	
	//Network Tab
	IBOutlet NSTextField *localPortField;
	IBOutlet NSTextField *outboundProxyHostField;
	IBOutlet NSTextField *outboundProxyPortField;
	IBOutlet NSTextField *STUNServerField;
	IBOutlet NSTextField *STUNServerPortField;
	IBOutlet NSButton *nameServersButton;
	IBOutlet NSButton *ICEButton;
	
	//Advanced Tab
	IBOutlet NSTextField *logFileField;
	IBOutlet NSButton *logFileButton;
	IBOutlet NSTextField *logFileLevelField;
	IBOutlet NSTextField *consoleLogLevelField;
	IBOutlet NSTextField *publicAddressField;
}
- (id)initWithPreferences:(MGMPreferences *)thePreferences;
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem;
+ (NSString *)title;
- (NSView *)preferencesView;

//Sound
- (IBAction)volume:(id)sender;
- (IBAction)micVolume:(id)sender;
- (void)audioChanged:(NSNotification *)theNotificaiton;
- (IBAction)audio:(id)sender;
- (IBAction)echoCancelation:(id)sender;
- (IBAction)voiceActivityDetection:(id)sender;

//Network
- (IBAction)localPort:(id)sender;
- (IBAction)outboundProxyHost:(id)sender;
- (IBAction)outboundProxyPort:(id)sender;
- (IBAction)STUNServer:(id)sender;
- (IBAction)STUNServerPort:(id)sender;
- (IBAction)nameServer:(id)sender;
- (IBAction)ICE:(id)sender;

//Advanced
- (IBAction)logFile:(id)sender;
- (IBAction)chooseLogFile:(id)sender;
- (IBAction)logFileLevel:(id)sender;
- (IBAction)consoleLogLevel:(id)sender;
- (IBAction)publicAddress:(id)sender;
@end
#endif