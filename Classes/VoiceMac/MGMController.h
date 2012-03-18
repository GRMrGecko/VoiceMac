//
//  MGMController.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/15/10.
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

@class MGMContactsController, MGMPreferences, MGMAbout, MGMTaskManager, MGMURLConnectionManager, MGMThemeManager, MGMSMSManager, MGMBadge, MGMMultiSMS, MGMInstance, WebView;

extern NSString * const MGMContactsControllersChangedNotification;

@interface MGMController : NSObject {
	NSMutableArray *contactsControllers;
	int currentContactsController;
	NSMutableArray *multipleSMS;
	MGMPreferences *preferences;
	MGMAbout *about;
	MGMTaskManager *taskManager;
	MGMURLConnectionManager *connectionManager;
	BOOL quitting;
	
	MGMThemeManager *themeManager;
	MGMSMSManager *SMSManager;
	MGMBadge *badge;
	NSMutableDictionary *badgeValues;
    
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusActiveImage;
	
    IBOutlet NSWindow *RLWindow;
    IBOutlet NSTextField *RLName;
    IBOutlet NSTextField *RLAddress;
    IBOutlet NSTextField *RLCityState;
    IBOutlet NSTextField *RLZipCode;
    IBOutlet NSTextField *RLPhoneNumber;
    IBOutlet WebView *RLMap;
	IBOutlet NSMenu *windowMenu;
}
- (void)registerDefaults;

- (BOOL)isQuitting;
- (NSArray *)contactsControllers;
- (MGMPreferences *)preferences;
- (MGMThemeManager *)themeManager;
- (MGMSMSManager *)SMSManager;
- (MGMBadge *)badge;
- (void)setBadge:(int)theBadge forInstance:(MGMInstance *)theInstance;

- (void)updateWindowMenu;

- (IBAction)about:(id)sender;
- (IBAction)showApp:(id)sender;
- (IBAction)showTaskManager:(id)sender;

- (IBAction)showInbox:(id)sender;
- (IBAction)refreshInbox:(id)sender;
- (IBAction)inboxSpam:(id)sender;
- (IBAction)inboxMarkRead:(id)sender;
- (IBAction)inboxDelete:(id)sender;
- (IBAction)inboxUndelete:(id)sender;

- (void)contactsControllerBecameCurrent:(MGMContactsController *)theContactsController;
- (NSString *)currentPhoneNumber;

- (IBAction)preferences:(id)sender;

- (IBAction)sendMultipleSMS:(id)sender;
- (void)removeMultiSMS:(MGMMultiSMS *)theMultiSMS;

- (IBAction)saveAudio:(id)sender;

- (IBAction)call:(id)sender;
- (IBAction)sms:(id)sender;

- (IBAction)reverseLookup:(id)sender;

- (IBAction)donate:(id)sender;
- (IBAction)openSource:(id)sender;
- (IBAction)viewTOS:(id)sender;
- (IBAction)rates:(id)sender;
- (IBAction)billing:(id)sender;
@end