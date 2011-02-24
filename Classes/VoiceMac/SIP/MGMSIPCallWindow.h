//
//  MGMSIPCallWindow.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/14/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import <Cocoa/Cocoa.h>

@class MGMSIPCall, MGMSIPAccount, MGMSIPUser, MGMURLConnectionManager, MGMSound;

@interface MGMSIPCallWindow : NSObject {
	MGMSIPCall *call;
	MGMSIPAccount *account;
	MGMSIPUser *SIPUser;
	MGMURLConnectionManager *connectionManager;
	
	IBOutlet NSWindow *incomingWindow;
	IBOutlet NSTextField *phoneField;
	IBOutlet NSTextField *nameField;
	IBOutlet NSButton *answerButton;
	IBOutlet NSButton *ignoreButton;
	NSString *fullName;
	NSString *phoneNumber;
	
	MGMSound *ringtone;
	
	NSDate *startTime;
	NSTimer *durationUpdater;
	
	IBOutlet NSWindow *callWindow;
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *durationField;
	IBOutlet NSTextField *statusField;
	IBOutlet NSSlider *volumeSlider;
	IBOutlet NSSlider *micVolumeSlider;
	IBOutlet NSButton *holdButton;
	IBOutlet NSButton *showPadButton;
	IBOutlet NSButton *hangUpButton;
	
	IBOutlet NSView *numberPadView;
	NSSize callWindowSize;
	NSSize callWindowPadSize;
	IBOutlet NSButton *recordingButton;
	IBOutlet NSButton *muteMicrophoneButton;
	IBOutlet NSButton *muteSpeakersButton;
	IBOutlet NSButton *sound1Button;
	IBOutlet NSButton *sound2Button;
	IBOutlet NSButton *sound3Button;
	IBOutlet NSButton *sound4Button;
	IBOutlet NSButton *sound5Button;
	IBOutlet NSButton *n1Button;
	IBOutlet NSButton *n2Button;
	IBOutlet NSButton *n3Button;
	IBOutlet NSButton *n4Button;
	IBOutlet NSButton *n5Button;
	IBOutlet NSButton *n6Button;
	IBOutlet NSButton *n7Button;
	IBOutlet NSButton *n8Button;
	IBOutlet NSButton *n9Button;
	IBOutlet NSButton *n0Button;
	IBOutlet NSButton *nStarButton;
	IBOutlet NSButton *nPoundButton;
}
+ (id)windowWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser;
- (id)initWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser;

- (void)fillCallWindow;
- (IBAction)answer:(id)sender;
- (IBAction)ignore:(id)sender;

- (void)setTitle:(NSString *)theTitle;

- (IBAction)volume:(id)sender;
- (IBAction)micVolume:(id)sender;

- (IBAction)hold:(id)sender;
- (void)hidePad;
- (IBAction)showPad:(id)sender;
- (IBAction)hangUp:(id)sender;

- (IBAction)startRecording:(id)sender;
- (IBAction)muteMicrophone:(id)sender;
- (IBAction)muteSpeakers:(id)sender;
- (IBAction)sound:(id)sender;
- (IBAction)dial:(id)sender;
@end
#endif