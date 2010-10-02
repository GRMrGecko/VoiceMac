//
//  MGMContactsController.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMContactsController.h"
#import "MGMContactView.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import <VoiceBase/VoiceBase.h>

NSString * const MGMContactViewCellIdentifier = @"MGMContactViewCellIdentifier";

@implementation MGMContactsController
- (id)initWithAccountController:(MGMAccountController *)theAccountController {
	if (self = [super init]) {
		accountController = theAccountController;
		
		filterLock = [NSLock new];
		filterWaiting = 0;
		contactViews = [NSMutableArray new];
		contactsCount = 0;
	}
	return self;
}
- (void)awakeFromNib {
	if (contactsMatchString!=nil)
		[searchBar setText:contactsMatchString];
	[self filterContacts];
	[searchCancelButton setHidden:YES];
}
- (void)releaseView {
	searchBar = nil;
	searchCancelButton = nil;
	contactsTable = nil;
	contactsCount = 0;
	[contactViews removeAllObjects];
}
- (void)dealloc {
	if (filterLock!=nil)
		[filterLock release];
	if (contactsMatchString!=nil)
		[contactsMatchString release];
	if (contactViews!=nil)
		[contactViews release];
	[super dealloc];
}

- (MGMContacts *)contacts {
	return nil;
}
- (NSString *)filterString {
	return [searchBar text];
}
- (void)updateMatchString {
	if (contactsMatchString!=nil) [contactsMatchString release];
	contactsMatchString = [[self filterString] copy];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)theSearchBar {
	[searchCancelButton setHidden:NO];
	return YES;
}
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	[self filterContacts];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self cancelSearch:self];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
	[self cancelSearch:self];
}
- (IBAction)cancelSearch:(id)sender {
	[searchBar resignFirstResponder];
	[searchCancelButton setHidden:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return contactsCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MGMContactView *cell = (MGMContactView *)[tableView dequeueReusableCellWithIdentifier:MGMContactViewCellIdentifier];
	if (cell==nil) {
		cell = [[[MGMContactView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMContactViewCellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[cell setThemeManager:[[accountController controller] themeManager]];
	}
	
	int row = [indexPath indexAtPosition:1];
	if (row>=contactsCount) return cell;
	[self checkContactRow:row];
	@try {
		[cell setContact:[contactViews objectAtIndex:row-contactsVisible.location]];
	}
	@catch (NSException *e) {
		NSLog(@"Contact error, ignoring. %@", e);
	}
	
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath indexAtPosition:1];
	if (row>=contactsCount) return;
	[self selectedContact:[contactViews objectAtIndex:row-contactsVisible.location]];
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

- (void)filterContacts {
	[NSThread detachNewThreadSelector:@selector(backgroundFilter) toTarget:self withObject:nil];
}
- (void)backgroundFilter {
	if (contactsTable==nil) return;
	if (filterWaiting>=1)
		return;
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	filterWaiting++;
	[filterLock lock];
	filterWaiting--;
	contactsCount = 0;
	[contactViews removeAllObjects];
	[self performSelectorOnMainThread:@selector(updateMatchString) withObject:nil waitUntilDone:YES];
	int count = [[[self contacts] countContactsMatching:contactsMatchString] intValue];
	
	contactsLoading.location = 0;
	contactsLoading.length = 0;
	contactsVisible.location = 0;
	contactsVisible.length = [[self contacts] maxResults];
	
	[contactViews addObjectsFromArray:[[self contacts] contactsMatching:contactsMatchString page:1]];
	contactsCount = count;
	[filterLock unlock];
	if (contactsTable==nil) return;
	[contactsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	if (contactsCount!=0)
		[contactsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	[pool drain];
}
- (void)loadContacts:(BOOL)updatingCount {
	if (contactsTable==nil) return;
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
		[contactViews addObjectsFromArray:[[self contacts] contactsMatching:contactsMatchString page:page]];
	}
	contactsVisible = contactsLoading;
	if (updatingCount)
		contactsCount = count;
	[filterLock unlock];
	if (contactsTable==nil) return;
	[contactsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[pool drain];
}

- (void)updatedContacts {
	if (contactsTable==nil) return;
	contactsLoading = contactsVisible;
	[self loadContacts:YES];
}

- (void)selectedContact:(NSDictionary *)theContact {
	
}
@end