//
//  MGMAccounts.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMAccounts.h"
#import "MGMAccountController.h"
#import "MGMAccountSetup.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase.h>

NSString * const MGMAccountCellIdentifier = @"MGMAccountCellIdentifier";

@implementation MGMAccounts
- (id)initWithAccountController:(MGMAccountController *)theAccountController {
	if (self = [super init]) {
		accountController = theAccountController;
	}
	return self;
}
- (void)dealloc {
	[self releaseView];
	[super dealloc];
}

- (UIView *)view {
	if (tableView==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"Accounts"] owner:self options:nil]) {
			NSLog(@"Unable to load Accounts");
			[self release];
			self = nil;
		} else {
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter addObserver:tableView selector:@selector(reloadData) name:MGMUserStartNotification object:nil];
			[notificationCenter addObserver:tableView selector:@selector(reloadData) name:MGMUserDoneNotification object:nil];
		}
	}
	return tableView;
}
- (void)releaseView {
	if (tableView!=nil) {
		[tableView release];
		tableView = nil;
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [[MGMUser users] count];
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MGMAccountCellIdentifier];
	if (cell==nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMAccountCellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	NSArray *users = [MGMUser users];
	if ([users count]<=[indexPath indexAtPosition:1]) {
		[cell setText:@"Unknown"];
	} else {
		[cell setText:[[MGMUser userNames] objectAtIndex:[indexPath indexAtPosition:1]]];
		MGMUser *user = [MGMUser userWithID:[users objectAtIndex:[indexPath indexAtPosition:1]]];
		if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
			if ([user settingForKey:MGMSIPAccountFullName]!=nil && ![[user settingForKey:MGMSIPAccountFullName] isEqual:@""])
				[cell setText:[user settingForKey:MGMSIPAccountFullName]];
		}
	}
	return cell;
}
- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)theTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)theTableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Remove";
}
- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:[indexPath indexAtPosition:1]]];
	if ([user isStarted]) {
		[user done];
		if ([user isStarted])
			return;
	}
	[user remove];
	[tableView reloadData];
}
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MGMUser *user = [MGMUser userWithID:[[MGMUser users] objectAtIndex:[indexPath indexAtPosition:1]]];
	[accountController showUser:user];
}
@end