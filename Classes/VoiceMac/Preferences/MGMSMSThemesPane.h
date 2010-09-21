//
//  MGMSMSThemesPane.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/6/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import <MGMUsers/MGMUsers.h>

@class MGMThemeManager, WebView;

@interface MGMSMSThemesPane : MGMPreferencesPane {
	MGMThemeManager *themeManager;
	NSMutableArray *testMessages;
	NSMutableDictionary *testMessageInfo;
	NSArray *themes;
    IBOutlet NSView *mainView;
	IBOutlet WebView *SMSView;
	IBOutlet NSPopUpButton *themePopUp;
	IBOutlet NSPopUpButton *variantPopUp;
	IBOutlet NSButton *authorButton;
	
	IBOutlet NSWindow *browserWindow;
	IBOutlet WebView *browser;
}
- (id)initWithPreferences:(MGMPreferences *)thePreferences;
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem;
+ (NSString *)title;
- (NSView *)preferencesView;

- (IBAction)reload:(id)sender;
- (void)buildHTML;

- (IBAction)changeTheme:(id)sender;
- (IBAction)changeVariant:(id)sender;
- (IBAction)authorSite:(id)sender;

- (IBAction)showBrowser:(id)sender;
@end