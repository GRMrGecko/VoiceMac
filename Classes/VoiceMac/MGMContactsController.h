//
//  MGMContactsController.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/12/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMController, MGMPhoneField, MGMPhoneFieldView, MGMContactsTableView, MGMContacts;

extern NSString *MGMContactsWindowOpen;

@interface MGMContactsController : NSObject <NSTextFieldDelegate> {
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