//
//  MGMContactsController.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/12/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMContactsController.h"
#import "MGMController.h"
#import "MGMViewCell.h"
#import "MGMContactView.h"
#import "MGMPhoneFeild.h"
#import <VoiceBase/VoiceBase.h>

NSString *MGMContactsWindowOpen = @"MGMContactsWindowOpen";

@implementation MGMContactsController
- (id)initWithController:(MGMController *)theController {
	if (self = [super init]) {
		controller = theController;
		filterLock = [NSLock new];
		filterWaiting = 0;
		contactViews = [NSMutableArray new];
		contactsCount = 0;
		
		hasCustomIncomingIcon = [[controller themeManager] hasCustomIncomingIcon];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedTheme:) name:MGMTUpdatedSMSThemeNotification object:[controller themeManager]];
	}
	return self;
}
- (void)awakeFromNib {
	[[[contactsTable tableColumns] objectAtIndex:0] setDataCell:[[MGMViewCell new] autorelease]];
	[contactsTable setTarget:self];
	[contactsTable setDoubleAction:@selector(runAction:)];
	[contactsWindow setExcludedFromWindowsMenu:YES];
	
	phoneFieldView = [[MGMPhoneFieldView alloc] initWithFrame:NSZeroRect];
	[phoneFieldView setFieldEditor:YES];
	[phoneFieldView setPhoneDelegate:self];
	[phoneField setDelegate:self];
	[self filterContacts];
}
- (void)dealloc {
	if (contactsWindow!=nil)
		[contactsWindow close];
	if (filterLock!=nil) {
		[filterLock lock];
		[filterLock unlock];
		[filterLock release];
	}
	if (contactViews!=nil)
		[contactViews release];
	[super dealloc];
}

- (MGMController *)controller {
	return controller;
}
- (NSString *)menuTitle {
	return @"Contacts";
}
- (NSArray *)contactViews {
	return contactViews;
}
- (NSWindow *)contactsWindow {
	return contactsWindow;
}
- (NSTableView *)contactsTable {
	return contactsTable;
}
- (MGMPhoneField *)phoneField {
	return phoneField;
}
- (void)showContactsWindow {
	
}
- (MGMContacts *)contacts {
	return nil;
}
- (NSString *)filterString {
	return [phoneField stringValue];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if (commandSelector==@selector(insertNewline:)) {
		[self runAction:self];
		return YES;
	} else if (commandSelector==@selector(moveDown:)) {
		[self selectFirstContact];
		return YES;
	} else if (commandSelector==@selector(deleteToBeginningOfLine:)) {
		[self performSelector:@selector(filterContacts) withObject:nil afterDelay:0.2];
		return NO;
	}
	return NO;
}

- (void)reloadData {
	while ([[contactsTable subviews] count]>0)
		[[[contactsTable subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    [contactsTable reloadData];
	[contactsTable display];
}
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	return contactsCount;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	return nil;
}
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	if (row>=contactsCount) return;
	[self checkContactRow:row];
	[filterLock lock];
	@try {
		[(MGMViewCell *)cell addSubview:[contactViews objectAtIndex:row-contactsVisible.location]];
	}
	@catch (NSException *e) {
		NSLog(@"Contact error, ignoreing. %@", e);
	}
	[filterLock unlock];
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row {
	if (row>=contactsCount) return NO;
	[self checkContactRow:row];
	[phoneField setStringValue:[[[[contactViews objectAtIndex:row-contactsVisible.location] contact] objectForKey:MGMCNumber] readableNumber]];
	return YES;
}
- (void)checkContactRow:(int)row {
	if (!NSLocationInRange(row, contactsVisible)) {
		int maxResults = [[self contacts] maxResults];
		int page = (row/maxResults)+1;
		contactsLoading.location = ((page==1 ? 1 : page-1)*maxResults)-maxResults;
		contactsLoading.length = (row<(maxResults-3) ? maxResults : maxResults*2);
		[self loadContacts:NO];
	}
}

- (void)updatedTheme:(NSNotification *)theNotification {
	BOOL customIncoming = [[controller themeManager] hasCustomIncomingIcon];
	if (hasCustomIncomingIcon!=customIncoming || customIncoming) {
		hasCustomIncomingIcon = customIncoming;
		[self reloadData];
	}
}

- (void)filterContacts {
	[NSThread detachNewThreadSelector:@selector(backgroundFilter) toTarget:self withObject:nil];
}
- (void)backgroundFilter {
	if (contactsWindow==nil) return;
	if (filterWaiting>=1)
		return;
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	filterWaiting++;
	[filterLock lock];
	filterWaiting--;
	contactsCount = 0;
	[contactViews removeAllObjects];
	if (contactsMatchString!=nil) [contactsMatchString release];
	contactsMatchString = [[self filterString] copy];
	int count = [[[self contacts] countContactsMatching:contactsMatchString] intValue];
	[contactsTable scrollRowToVisible:0];
	
	contactsLoading.location = 0;
	contactsLoading.length = 0;
	contactsVisible.location = 0;
	contactsVisible.length = [[self contacts] maxResults];
	
	NSArray *newContacts = [[self contacts] contactsMatching:contactsMatchString page:1];
	for (int i=0; i<[newContacts count]; i++) {
		MGMContactView *contact = [MGMContactView viewWithFrame:NSMakeRect(0, 0, 200, 64) themeManager:[controller themeManager]];
		[contact setContact:[newContacts objectAtIndex:i]];
		[contactViews addObject:contact];
	}
	contactsCount = count;
	[filterLock unlock];
	if (contactsWindow==nil) return;
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[pool drain];
}
- (void)loadContacts:(BOOL)updatingCount {
	if (contactsWindow==nil) return;
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[filterLock lock];
	int count = 0;
	if (updatingCount) {
		count = [[[self contacts] countContactsMatching:contactsMatchString] intValue];
		contactsCount = 0;
	}
	int maxResults = [[self contacts] maxResults];
	[contactViews removeAllObjects];
	int page = contactsLoading.location/maxResults;
	int times = contactsLoading.length/maxResults;
	for (int t=0; t<times; t++) {
		page++;
		NSArray *newContacts = [[self contacts] contactsMatching:contactsMatchString page:page];
		for (int i=0; i<[newContacts count]; i++) {
			MGMContactView *contact = [MGMContactView viewWithFrame:NSMakeRect(0, 0, 200, 64) themeManager:[controller themeManager]];
			[contact setContact:[newContacts objectAtIndex:i]];
			[contactViews addObject:contact];
		}
	}
	contactsVisible = contactsLoading;
	if (updatingCount)
		contactsCount = count;
	[filterLock unlock];
	if (contactsWindow==nil) return;
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[pool drain];
}
- (void)selectFirstContact {
	[contactsWindow makeFirstResponder:contactsTable];
	[contactsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	[self tableView:contactsTable shouldSelectRow:0];
}

- (void)updatedContacts {
	if (contactsWindow==nil) return;
	contactsLoading = contactsVisible;
	[self loadContacts:YES];
}

- (NSString *)areaCode {
	return nil;
}
- (NSString *)currentPhoneNumber {
	NSString *phoneNumber = nil;
	if (phoneNumber==nil && ![[phoneField stringValue] isPhoneComplete]) {
		if ([contactViews count]>0) {
			[self selectFirstContact];
		} else {
			return nil;
		}
	}
	if (phoneNumber==nil)
		phoneNumber = [[phoneField stringValue] phoneFormatWithAreaCode:[self areaCode]];
	return phoneNumber;
}
- (IBAction)runAction:(id)sender {
	
}
- (IBAction)call:(id)sender {
	
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject {
	if ([anObject isKindOfClass:[MGMPhoneField class]]) {
		return phoneFieldView;
	}
	return nil;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	[controller contactsControllerBecameCurrent:self];
}
- (void)windowWillClose:(NSNotification *)notification {
	[contactViews removeAllObjects];
	contactsCount = 0;
	[self reloadData];
	[contactsWindow setDelegate:nil];
	contactsWindow = nil;
	contactsTable = nil;
	if (phoneFieldView!=nil) {
		[phoneFieldView release];
		phoneFieldView = nil;
	}
	phoneField = nil;
}
@end

@implementation MGMContactsTableView
- (void)keyDown:(NSEvent *)theEvent {
	int keyCode = [theEvent keyCode];
	if (keyCode==36 || keyCode==76) {
		[contactsController runAction:self];
	} else if (keyCode==48) {
		[[self window] makeFirstResponder:[contactsController phoneField]];
	} else {
		[super keyDown:theEvent];
	}
}
- (void)copy:(id)sender {
	if ([self selectedRow]==-1) {
		NSBeep();
		return;
	}
	NSString *phoneNumber = [[[[contactsController contactViews] objectAtIndex:[self selectedRow]] contact] objectForKey:MGMCNumber];
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString:[phoneNumber readableNumber] forType:NSStringPboardType];
}
@end