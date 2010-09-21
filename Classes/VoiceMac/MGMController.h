//
//  MGMController.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/15/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMContactsController, MGMPreferences, MGMTaskManager, MGMWhitePages, MGMThemeManager, MGMSMSManager, MGMBadge, MGMMultiSMS, MGMInstance, WebView;

extern NSString * const MGMContactsControllersChangedNotification;

@interface MGMController : NSObject {
	NSMutableArray *contactsControllers;
	int currentContactsController;
	NSMutableArray *multipleSMS;
	MGMPreferences *preferences;
	MGMTaskManager *taskManager;
	MGMWhitePages *whitePages;
	BOOL quitting;
	
	MGMThemeManager *themeManager;
	MGMSMSManager *SMSManager;
	MGMBadge *badge;
	NSMutableDictionary *badgeValues;
	
	IBOutlet NSWindow *aboutWindow;
	IBOutlet NSTextField *aboutNameField;
	
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
- (IBAction)viewTOS:(id)sender;
- (IBAction)rates:(id)sender;
- (IBAction)billing:(id)sender;
@end