//
//  MGMSoundsPane.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/7/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import <MGMUsers/MGMUsers.h>

@class MGMThemeManager, WebView;

@interface MGMSoundsPane : MGMPreferencesPane {
	MGMThemeManager *themeManager;
	IBOutlet NSView *mainView;
	IBOutlet NSPopUpButton *SMSMessagePopUp;
	IBOutlet NSButton *SMSMessageAuthorButton;
	IBOutlet NSPopUpButton *voicemailPopUp;
	IBOutlet NSButton *voicemailAuthorButton;
	IBOutlet NSPopUpButton *SIPRingtonePopUp;
	IBOutlet NSButton *SIPRingtoneAuthorButton;
	IBOutlet NSPopUpButton *SIPHoldMusicPopUp;
	IBOutlet NSButton *SIPHoldMusicAuthorButton;
	IBOutlet NSPopUpButton *SIPConnectedPopUp;
	IBOutlet NSButton *SIPConnectedAuthorButton;
	IBOutlet NSPopUpButton *SIPDisconnectedPopUp;
	IBOutlet NSButton *SIPDisconnectedAuthorButton;
	IBOutlet NSPopUpButton *SIPSound1PopUp;
	IBOutlet NSButton *SIPSound1AuthorButton;
	IBOutlet NSPopUpButton *SIPSound2PopUp;
	IBOutlet NSButton *SIPSound2AuthorButton;
	IBOutlet NSPopUpButton *SIPSound3PopUp;
	IBOutlet NSButton *SIPSound3AuthorButton;
	IBOutlet NSPopUpButton *SIPSound4PopUp;
	IBOutlet NSButton *SIPSound4AuthorButton;
	IBOutlet NSPopUpButton *SIPSound5PopUp;
	IBOutlet NSButton *SIPSound5AuthorButton;
	NSMutableDictionary *sounds;
	NSSound *soundPlayer;
	
	IBOutlet NSWindow *browserWindow;
	IBOutlet WebView *browser;
}
- (id)initWithPreferences:(MGMPreferences *)thePreferences;
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem;
+ (NSString *)title;
- (NSView *)preferencesView;

- (void)reload:(NSString *)theSound;
- (IBAction)selectSound:(id)sender;
- (IBAction)stopSound:(id)sender;

- (IBAction)authorSite:(id)sender;
- (IBAction)showBrowser:(id)sender;
@end