//
//  MGMAccountsPane.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/21/10.
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
	IBOutlet NSPopUpButton *SIPTransportPopUp;
	IBOutlet NSPopUpButton *SIPToneTypePopUp;
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
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

- (IBAction)saveGV:(id)sender;
- (IBAction)saveGC:(id)sender;
- (IBAction)saveSIP:(id)sender;

- (IBAction)saveContacts:(id)sender;
- (IBAction)saveGoogleContactsUser:(id)sender;
- (IBAction)saveAction:(id)sender;
@end