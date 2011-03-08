//
//  MGMSMSThemesPane.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/6/10.
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