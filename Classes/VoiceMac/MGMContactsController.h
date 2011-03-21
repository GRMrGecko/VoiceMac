//
//  MGMContactsController.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/12/10.
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

@class MGMController, MGMPhoneField, MGMPhoneFieldView, MGMContactsTableView, MGMContacts;

extern NSString *MGMContactsWindowOpen;

@interface MGMContactsController : NSObject
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1060)
<NSTextFieldDelegate>
#endif
{
	MGMController *controller;
	IBOutlet NSWindow *contactsWindow;
	BOOL closingWindow;
	IBOutlet MGMContactsTableView *contactsTable;
	IBOutlet MGMPhoneField *phoneField;
	MGMPhoneFieldView *phoneFieldView;
	
	NSLock *filterLock;
	NSString *contactsMatchString;
	int filterWaiting;
	NSMutableArray *contactViews;
	int contactsCount;
	NSRange contactsLoading;
	NSRange contactsVisible;
	
	BOOL hasCustomIncomingIcon;
}
- (id)initWithController:(MGMController *)theController;

- (MGMController *)controller;
- (NSString *)menuTitle;
- (NSArray *)contactViews;
- (NSWindow *)contactsWindow;
- (NSTableView *)contactsTable;
- (MGMPhoneField *)phoneField;
- (void)showContactsWindow;
- (MGMContacts *)contacts;
- (NSString *)filterString;

- (void)reloadData;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row;
- (void)checkContactRow:(int)row;

- (void)updatedTheme:(NSNotification *)theNotification;

- (void)filterContacts;
- (void)backgroundFilter;
- (void)loadContacts:(BOOL)updatingCount;
- (void)selectFirstContact;

- (void)updatedContacts;

- (NSString *)areaCode;
- (NSString *)currentPhoneNumber;
- (IBAction)runAction:(id)sender;
- (IBAction)call:(id)sender;

- (void)windowDidBecomeKey:(NSNotification *)notification;
- (void)windowWillClose:(NSNotification *)notification;
@end

@interface MGMContactsTableView : NSTableView {
    IBOutlet MGMContactsController *contactsController;
}

@end