//
//  MGMAccountsPane.m
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

#import "MGMAccountsPane.h"
#import "MGMAccountSetup.h"
#import "MGMContactsController.h"
#import "MGMVoiceUser.h"
#import "MGMSIPUser.h"
#import <VoiceBase/VoiceBase.h>

NSString * const MGMLogin = @"Login";
NSString * const MGMLogout = @"Logout";

@implementation MGMAccountsPane
- (id)initWithPreferences:(MGMPreferences *)thePreferences {
	if ((self = [super initWithPreferences:thePreferences])) {
        if (![NSBundle loadNibNamed:@"AccountsPane" owner:self]) {
            NSLog(@"Unable to load Nib for Account Preferences");
            [self release];
            self = nil;
        } else {
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter addObserver:usersTable selector:@selector(reloadData) name:MGMUserStartNotification object:nil];
			[notificationCenter addObserver:usersTable selector:@selector(reloadData) name:MGMUserDoneNotification object:nil];
			[usersTable setTarget:self];
			[usersTable setDoubleAction:@selector(loginout:)];
			[loginoutButton setEnabled:NO];
			[removeButton setEnabled:NO];
			[GVContactsMatrix setEnabled:NO];
			[GVGoogleContactsPopUp setEnabled:NO];
			[GVActionMatrix setEnabled:NO];
			[GVUserNameField setEnabled:NO];
			[GVPasswordField setEnabled:NO];
			[GCUserNameField setEnabled:NO];
			[GCPasswordField setEnabled:NO];
			[SIPFullNameField setEnabled:NO];
			[SIPDomainField setEnabled:NO];
			[SIPRegistrarField setEnabled:NO];
			[SIPUserNameField setEnabled:NO];
			[SIPPasswordField setEnabled:NO];
			[SIPAreaCodeField setEnabled:NO];
			[SIPProxyHostField setEnabled:NO];
			[SIPProxyPortField setEnabled:NO];
			[SIPSIPAddressField setEnabled:NO];
			[SIPRegistrarTimeoutField setEnabled:NO];
			[SIPTransportPopUp setEnabled:NO];
			[SIPToneTypePopUp setEnabled:NO];
			[SIPContactsMatrix setEnabled:NO];
			[SIPGoogleContactsPopUp setEnabled:NO];
			[settingsTab selectTabViewItemAtIndex:0];
        }
    }
    return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:usersTable];
	[checkInstance release];
	[mainView release];
	[super dealloc];
}
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem {
	[theItem setLabel:[self title]];
    [theItem setPaletteLabel:[theItem label]];
    [theItem setImage:[NSImage imageNamed:@"Accounts"]];
}
+ (NSString *)title {
	return @"Accounts";
}
- (NSView *)preferencesView {
	return mainView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [[MGMUser userNames] count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([[tableColumn identifier] isEqual:@"username"]) {
#if MGMSIPENABLED
		NSArray *users = [MGMUser users];
		if ([users count]<=row)
			return nil;
		MGMUser *user = [MGMUser userWithID:[users objectAtIndex:row]];
		if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
			if ([user settingForKey:MGMSIPAccountFullName]!=nil && ![[user settingForKey:MGMSIPAccountFullName] isEqual:@""])
				return [user settingForKey:MGMSIPAccountFullName];
		}
#endif
		return [[MGMUser userNames] objectAtIndex:row];
	} else if ([[tableColumn identifier] isEqual:@"state"]) {
		NSDictionary *users = [MGMUser usersPlist];
		if ([[users allKeys] count]<=row)
			return nil;
		return ([[users objectForKey:[[users allKeys] objectAtIndex:row]] boolValue] ? @"✓" : @"");
	}
	return nil;
}

- (IBAction)loginout:(id)sender {
	if ([usersTable selectedRow]==-1) return;
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:[usersTable selectedRow]]];
	if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts])
		return;
	if ([user isStarted]) {
		[user done];
		[user setSetting:[NSNumber numberWithBool:YES] forKey:MGMContactsWindowOpen];
		[loginoutButton setTitle:MGMLogin];
	} else {
		[user start];
		[loginoutButton setTitle:MGMLogout];
	}
	[usersTable reloadData];
	[self tableViewSelectionDidChange:nil];
}
- (IBAction)add:(id)sender {
	[[MGMAccountSetup new] attachToWindow:[preferences preferencesWindow]]; // The Account Setup will automatically release it self when user is done.
}
- (IBAction)remove:(id)sender {
	if ([usersTable selectedRow]==-1) return;
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:[usersTable selectedRow]]];
	if ([user isStarted]) {
		[user done];
		if ([user isStarted])
			return;
	}
	[user remove];
	[usersTable reloadData];
	[self tableViewSelectionDidChange:nil];
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	int selected = [usersTable selectedRow];
	[loginoutButton setEnabled:NO];
	[removeButton setEnabled:NO];
	[GVContactsMatrix setEnabled:NO];
	[GVGoogleContactsPopUp setEnabled:NO];
	[GVActionMatrix setEnabled:NO];
	[GVUserNameField setEnabled:NO];
	[GVPasswordField setEnabled:NO];
	[GCUserNameField setEnabled:NO];
	[GCPasswordField setEnabled:NO];
	[SIPFullNameField setEnabled:NO];
	[SIPDomainField setEnabled:NO];
	[SIPRegistrarField setEnabled:NO];
	[SIPUserNameField setEnabled:NO];
	[SIPPasswordField setEnabled:NO];
	[SIPAreaCodeField setEnabled:NO];
	[SIPProxyHostField setEnabled:NO];
	[SIPProxyPortField setEnabled:NO];
	[SIPSIPAddressField setEnabled:NO];
	[SIPRegistrarTimeoutField setEnabled:NO];
	[SIPTransportPopUp setEnabled:NO];
	[SIPToneTypePopUp setEnabled:NO];
	[SIPContactsMatrix setEnabled:NO];
	[SIPGoogleContactsPopUp setEnabled:NO];
	if (selected==-1)
		return;
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:selected]];
	if ([user isStarted])
		[loginoutButton setTitle:MGMLogout];
	else
		[loginoutButton setTitle:MGMLogin];
	if (![[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts])
		[loginoutButton setEnabled:YES];
	else
		[loginoutButton setEnabled:NO];
	[removeButton setEnabled:YES];
	if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
		[settingsTab selectTabViewItemAtIndex:0];
		
		NSArray *users = [MGMUser users];
		NSMenu *menu = [[NSMenu new] autorelease];
		
		int selectedGC = 0;
		int cCount = 0;
		for (int i=0; i<[users count]; i++) {
			MGMUser *gcUser = [MGMUser userWithID:[users objectAtIndex:i]];
			if ([[gcUser settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts]) {
				NSMenuItem *item = [[NSMenuItem new] autorelease];
				[item setTitle:[gcUser settingForKey:MGMUserName]];
				[item setRepresentedObject:[gcUser settingForKey:MGMUserID]];
				if ([[user settingForKey:MGMCGoogleContactsUser] isEqual:[gcUser settingForKey:MGMUserID]])
					selectedGC = cCount;
				[menu addItem:item];
				cCount++;
			}
		}
		NSString *contactsSource = [user settingForKey:MGMSContactsSourceKey];
		if ([contactsSource isEqual:NSStringFromClass([MGMAddressBook class])]) {
			[GVContactsMatrix selectCellAtRow:0 column:0];
			[GVGoogleContactsPopUp setEnabled:NO];
		} else if ([contactsSource isEqual:NSStringFromClass([MGMGoogleContacts class])]) {
			if (cCount!=0) {
				[GVContactsMatrix selectCellAtRow:1 column:0];
				[GVGoogleContactsPopUp setEnabled:YES];
			} else {
				[user setSetting:NSStringFromClass([MGMAddressBook class]) forKey:MGMSContactsSourceKey];
				[GVContactsMatrix selectCellAtRow:0 column:0];
				[GVGoogleContactsPopUp setEnabled:NO];
			}
		}
		[GVContactsMatrix setEnabled:YES];
		[GVGoogleContactsPopUp setMenu:menu];
		[GVGoogleContactsPopUp selectItemAtIndex:selectedGC];
		if ([[GVGoogleContactsPopUp selectedItem] representedObject]!=nil)
			[user setSetting:[[GVGoogleContactsPopUp selectedItem] representedObject] forKey:MGMCGoogleContactsUser];
		
		[GVActionMatrix setEnabled:YES];
		[GVActionMatrix selectCellAtRow:[[user settingForKey:MGMSContactsActionKey] intValue] column:0];
		
		if (![user isStarted]) {
			[GVUserNameField setEnabled:YES];
			[GVPasswordField setEnabled:YES];
		}
		[GVUserNameField setStringValue:[user settingForKey:MGMUserName]];
		[GVPasswordField setStringValue:[user password]];
	} else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts]) {
		[settingsTab selectTabViewItemAtIndex:1];
		
		if (![user isStarted]) {
			[GCUserNameField setEnabled:YES];
			[GCPasswordField setEnabled:YES];
		}
		[GCUserNameField setStringValue:[user settingForKey:MGMUserName]];
		[GCPasswordField setStringValue:[user password]];
	}
#if MGMSIPENABLED
	else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
		[settingsTab selectTabViewItemAtIndex:2];
		if (![user isStarted]) {
			[SIPFullNameField setEnabled:YES];
			[SIPDomainField setEnabled:YES];
			[SIPRegistrarField setEnabled:YES];
			[SIPUserNameField setEnabled:YES];
			[SIPPasswordField setEnabled:YES];
			[SIPAreaCodeField setEnabled:YES];
			[SIPProxyHostField setEnabled:YES];
			[SIPProxyPortField setEnabled:YES];
			[SIPSIPAddressField setEnabled:YES];
			[SIPRegistrarTimeoutField setEnabled:YES];
			[SIPTransportPopUp setEnabled:YES];
			[SIPToneTypePopUp setEnabled:YES];
		}
		if ([user settingForKey:MGMSIPAccountFullName]!=nil)
			[SIPFullNameField setStringValue:[user settingForKey:MGMSIPAccountFullName]];
		else
			[SIPFullNameField setStringValue:@""];
		if ([user settingForKey:MGMSIPAccountDomain]!=nil)
			[SIPDomainField setStringValue:[user settingForKey:MGMSIPAccountDomain]];
		else
			[SIPDomainField setStringValue:@""];
		if ([user settingForKey:MGMSIPAccountRegistrar]==nil || [[user settingForKey:MGMSIPAccountRegistrar] isEqual:@""]) {
			[[SIPDomainField cell] setPlaceholderString:@"Usually *"];
			[SIPRegistrarField setStringValue:@""];
		} else {
			[[SIPDomainField cell] setPlaceholderString:[user settingForKey:MGMSIPAccountRegistrar]];
			[SIPRegistrarField setStringValue:[user settingForKey:MGMSIPAccountRegistrar]];
		}
		if ([user settingForKey:MGMSIPAccountUserName]!=nil)
			[SIPUserNameField setStringValue:[user settingForKey:MGMSIPAccountUserName]];
		else
			[SIPUserNameField setStringValue:@""];
		[SIPPasswordField setStringValue:[user password]];
		if ([user settingForKey:MGMSIPUserAreaCode]!=nil)
			[SIPAreaCodeField setStringValue:[user settingForKey:MGMSIPUserAreaCode]];
		else
			[SIPAreaCodeField setStringValue:@""];
		if ([user settingForKey:MGMSIPAccountProxy]!=nil)
			[SIPProxyHostField setStringValue:[user settingForKey:MGMSIPAccountProxy]];
		else
			[SIPProxyHostField setStringValue:@""];
		if ([user settingForKey:MGMSIPAccountProxyPort]!=nil && [[user settingForKey:MGMSIPAccountProxyPort] intValue]!=0)
			[SIPProxyPortField setIntValue:[[user settingForKey:MGMSIPAccountProxyPort] intValue]];
		else
			[SIPProxyPortField setStringValue:@""];
		if ([user settingForKey:MGMSIPAccountSIPAddress]!=nil)
			[SIPSIPAddressField setStringValue:[user settingForKey:MGMSIPAccountSIPAddress]];
		else
			[SIPSIPAddressField setStringValue:@""];
		[[SIPSIPAddressField cell] setPlaceholderString:[NSString stringWithFormat:@"%@@%@", [user settingForKey:MGMSIPAccountUserName], [user settingForKey:MGMSIPAccountRegistrar]]];
		if ([user settingForKey:MGMSIPAccountRegisterTimeout]!=nil && [[user settingForKey:MGMSIPAccountRegisterTimeout] intValue]!=0)
			[SIPRegistrarTimeoutField setIntValue:[[user settingForKey:MGMSIPAccountRegisterTimeout] intValue]];
		else
			[SIPRegistrarTimeoutField setStringValue:@""];
		int transport = [[user settingForKey:MGMSIPAccountTransport] intValue];
		[SIPTransportPopUp selectItemAtIndex:transport];
		int dtmfToneType = [[user settingForKey:MGMSIPAccountDTMFToneType] intValue];
		[SIPToneTypePopUp selectItemAtIndex:dtmfToneType];
		
		NSArray *users = [MGMUser users];
		NSMenu *menu = [[NSMenu new] autorelease];
		
		int selectedGC = 0;
		int cCount = 0;
		for (int i=0; i<[users count]; i++) {
			MGMUser *gcUser = [MGMUser userWithID:[users objectAtIndex:i]];
			if ([[gcUser settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts]) {
				NSMenuItem *item = [[NSMenuItem new] autorelease];
				[item setTitle:[gcUser settingForKey:MGMUserName]];
				[item setRepresentedObject:[gcUser settingForKey:MGMUserID]];
				if ([[user settingForKey:MGMCGoogleContactsUser] isEqual:[gcUser settingForKey:MGMUserID]])
					selectedGC = cCount;
				[menu addItem:item];
				cCount++;
			}
		}
		NSString *contactsSource = [user settingForKey:MGMSContactsSourceKey];
		if ([contactsSource isEqual:NSStringFromClass([MGMAddressBook class])]) {
			[SIPContactsMatrix selectCellAtRow:0 column:0];
			[SIPGoogleContactsPopUp setEnabled:NO];
		} else if ([contactsSource isEqual:NSStringFromClass([MGMGoogleContacts class])]) {
			if ([[menu itemArray] count]!=0) {
				[SIPContactsMatrix selectCellAtRow:1 column:0];
				[SIPGoogleContactsPopUp setEnabled:YES];
			} else {
				[user setSetting:NSStringFromClass([MGMAddressBook class]) forKey:MGMSContactsSourceKey];
				[SIPContactsMatrix selectCellAtRow:0 column:0];
				[SIPGoogleContactsPopUp setEnabled:NO];
			}
		}
		[SIPContactsMatrix setEnabled:YES];
		[SIPGoogleContactsPopUp setMenu:menu];
		[SIPGoogleContactsPopUp selectItemAtIndex:selectedGC];
		if ([[SIPGoogleContactsPopUp selectedItem] representedObject]!=nil)
			[user setSetting:[[SIPGoogleContactsPopUp selectedItem] representedObject] forKey:MGMCGoogleContactsUser];
	}
#endif
}

- (IBAction)saveGV:(id)sender {
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:[usersTable selectedRow]]];
	if ([[GVUserNameField stringValue] isEqual:@""] || [[GVPasswordField stringValue] isEqual:@""]) {
		NSBeep();
		[GVUserNameField setStringValue:[user settingForKey:MGMUserName]];
		[GVPasswordField setStringValue:[user password]];
	} else {
		[user setSetting:[GVUserNameField stringValue] forKey:MGMUserName];
		[user setPassword:[GVPasswordField stringValue]];
	}
}
- (IBAction)saveGC:(id)sender {
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:[usersTable selectedRow]]];
	if ([[GCUserNameField stringValue] isEqual:@""] || [[GCPasswordField stringValue] isEqual:@""]) {
		NSBeep();
		[GCUserNameField setStringValue:[user settingForKey:MGMUserName]];
		[GCPasswordField setStringValue:[user password]];
	} else {
		[user setSetting:[GCUserNameField stringValue] forKey:MGMUserName];
		[user setPassword:[GCPasswordField stringValue]];
	}
}
- (IBAction)saveSIP:(id)sender {
#if MGMSIPENABLED
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:[usersTable selectedRow]]];
	[user setSetting:[SIPFullNameField stringValue] forKey:MGMSIPAccountFullName];
	if ([[SIPRegistrarField stringValue] isEqual:@""]) {
		[[SIPDomainField cell] setPlaceholderString:@"Usually *"];
		[user setSetting:@"" forKey:MGMSIPAccountRegistrar];
	} else {
		[[SIPDomainField cell] setPlaceholderString:[SIPRegistrarField stringValue]];
		[user setSetting:[SIPRegistrarField stringValue] forKey:MGMSIPAccountRegistrar];
	}
	if ([[SIPRegistrarField stringValue] isEqual:@""] && [[SIPDomainField stringValue] isEqual:@""])
		NSBeep();
	else
		[user setSetting:[SIPDomainField stringValue] forKey:MGMSIPAccountDomain];
	if ([[SIPUserNameField stringValue] isEqual:@""] || [[SIPPasswordField stringValue] isEqual:@""]) {
		NSBeep();
		if ([user settingForKey:MGMSIPAccountUserName]!=nil) {
			[SIPUserNameField setStringValue:[user settingForKey:MGMSIPAccountUserName]];
		} else {
			[SIPUserNameField setStringValue:@""];
		}
		[SIPPasswordField setStringValue:[user password]];
	} else {
		[user setSetting:[SIPUserNameField stringValue] forKey:MGMSIPAccountUserName];
		[user setSetting:[SIPUserNameField stringValue] forKey:MGMUserName];
		[user setPassword:[SIPPasswordField stringValue]];
	}
	[user setSetting:[SIPAreaCodeField stringValue] forKey:MGMSIPUserAreaCode];
	[user setSetting:[SIPProxyHostField stringValue] forKey:MGMSIPAccountProxy];
	[user setSetting:[NSNumber numberWithInt:[SIPProxyPortField intValue]] forKey:MGMSIPAccountProxyPort];
	[user setSetting:[SIPSIPAddressField stringValue] forKey:MGMSIPAccountSIPAddress];
	[[SIPSIPAddressField cell] setPlaceholderString:[NSString stringWithFormat:@"%@@%@", [user settingForKey:MGMSIPAccountUserName], [user settingForKey:MGMSIPAccountRegistrar]]];
	[user setSetting:[NSNumber numberWithInt:[SIPRegistrarTimeoutField intValue]] forKey:MGMSIPAccountRegisterTimeout];
	[user setSetting:[NSNumber numberWithInt:[SIPTransportPopUp indexOfSelectedItem]] forKey:MGMSIPAccountTransport];
	[user setSetting:[NSNumber numberWithInt:[SIPToneTypePopUp indexOfSelectedItem]] forKey:MGMSIPAccountDTMFToneType];
#endif
}

- (IBAction)saveContacts:(id)sender {
	int selected = [usersTable selectedRow];
	if (selected==-1) return;
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:selected]];
	NSPopUpButton *googleContacts = nil;
	if (sender==GVContactsMatrix)
		googleContacts = GVGoogleContactsPopUp;
	else if (sender==SIPContactsMatrix)
		googleContacts = SIPGoogleContactsPopUp;
	if ([sender selectedRow]==0) {
		[user setSetting:NSStringFromClass([MGMAddressBook class]) forKey:MGMSContactsSourceKey];
		[googleContacts setEnabled:NO];
	} else if ([sender selectedRow]==1) {
		NSArray *users = [MGMUser users];
		int cCount = 0;
		for (int i=0; i<[users count]; i++) {
			MGMUser *gcUser = [MGMUser userWithID:[users objectAtIndex:i]];
			if ([[gcUser settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts])
				cCount++;
		}
		if (cCount>0) {
			[user setSetting:NSStringFromClass([MGMGoogleContacts class]) forKey:MGMSContactsSourceKey];
			[googleContacts setEnabled:YES];
		} else {
			[user setSetting:NSStringFromClass([MGMAddressBook class]) forKey:MGMSContactsSourceKey];
			[sender selectCellAtRow:0 column:0];
			[googleContacts setEnabled:NO];
		}
	}
}
- (IBAction)saveGoogleContactsUser:(id)sender {
	int selected = [usersTable selectedRow];
	if (selected==-1) return;
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:selected]];
	[user setSetting:[[sender selectedItem] representedObject] forKey:MGMCGoogleContactsUser];
}
- (IBAction)saveAction:(id)sender {
	int selected = [usersTable selectedRow];
	if (selected==-1) return;
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:selected]];
	[user setSetting:[NSNumber numberWithInt:[GVActionMatrix selectedRow]] forKey:MGMSContactsActionKey];
}
@end