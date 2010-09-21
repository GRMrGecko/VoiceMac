//
//  MGMAccountsPane.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/21/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import <MGMUsers/MGMUsers.h>

@class MGMInstance;

@interface MGMAccountsPane : MGMPreferencesPane {
    IBOutlet NSView *mainView;
	IBOutlet NSTabView *settingsTab;
	
	MGMInstance *checkInstance;
	
	IBOutlet NSTableView *usersTable;
	IBOutlet NSButton *loginoutButton;
	IBOutlet NSButton *addButton;
	IBOutlet NSButton *removeButton;
	
	//Google Voice Settings
	IBOutlet NSMatrix *GVContactsMatrix;
	IBOutlet NSPopUpButton *GVGoogleContactsPopUp;
	IBOutlet NSMatrix *GVActionMatrix;
	IBOutlet NSTextField *GVUserNameField;
	IBOutlet NSTextField *GVPasswordField;
	
	//Google Contacts Settings
	IBOutlet NSTextField *GCUserNameField;
	IBOutlet NSTextField *GCPasswordField;
	
	//Session Initiation Protocol Settings
	IBOutlet NSTextField *SIPFullNameField;
	IBOutlet NSTextField *SIPDomainField;
	IBOutlet NSTextField *SIPRegistrarField;
	IBOutlet NSTextField *SIPUserNameField;
	IBOutlet NSTextField *SIPPasswordField;
	IBOutlet NSTextField *SIPAreaCodeField;
	IBOutlet NSTextField *SIPProxyHostField;
	IBOutlet NSTextField *SIPProxyPortField;
	IBOutlet NSTextField *SIPSIPAddressField;
	IBOutlet NSTextField *SIPRegistrarTimeoutField;
	IBOutlet NSMatrix *SIPContactsMatrix;
	IBOutlet NSPopUpButton *SIPGoogleContactsPopUp;
}
- (id)initWithPreferences:(MGMPreferences *)thePreferences;
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem;
+ (NSString *)title;
- (NSView *)preferencesView;

- (IBAction)loginout:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)saveGV:(id)sender;
- (IBAction)saveGC:(id)sender;
- (IBAction)saveSIP:(id)sender;

- (IBAction)saveContacts:(id)sender;
- (IBAction)saveGoogleContactsUser:(id)sender;
- (IBAction)saveAction:(id)sender;
@end