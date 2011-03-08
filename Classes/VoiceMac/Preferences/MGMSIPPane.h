//
//  MGMSIPPane.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/16/10.
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
	IBOutlet NSTextField *userAgentField;
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
- (IBAction)userAgent:(id)sender;
@end
#endif