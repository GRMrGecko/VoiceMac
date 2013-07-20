//
//  MGMAccounts.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMAccounts.h"
#import "MGMAccountController.h"
#import "MGMBadgeView.h"
#import "MGMAccountSetup.h"
#import "MGMVoiceUser.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

NSString * const MGMAccountCellIdentifier = @"MGMAccountCellIdentifier";

@implementation MGMAccounts
- (id)initWithAccountController:(MGMAccountController *)theAccountController {
	if ((self = [super init])) {
		accountController = theAccountController;
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[super dealloc];
}

- (UIView *)view {
	if (tableView==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"Accounts"] owner:self options:nil]) {
			NSLog(@"Unable to load Accounts");
		} else {
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter addObserver:tableView selector:@selector(reloadData) name:MGMUserStartNotification object:nil];
			[notificationCenter addObserver:tableView selector:@selector(reloadData) name:MGMUserDoneNotification object:nil];
		}
	}
	return tableView;
}
- (void)releaseView {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[tableView release];
	tableView = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [[MGMUser users] count];
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MGMBadgeView *cell = (MGMBadgeView *)[tableView dequeueReusableCellWithIdentifier:MGMAccountCellIdentifier];
	if (cell==nil) {
		cell = [[[MGMBadgeView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMAccountCellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	NSArray *users = [MGMUser users];
	if ([users count]<=[indexPath indexAtPosition:1]) {
		[cell setName:@"Unknown"];
	} else {
		[cell setName:[[MGMUser userNames] objectAtIndex:[indexPath indexAtPosition:1]]];
		MGMUser *user = [MGMUser userWithID:[users objectAtIndex:[indexPath indexAtPosition:1]]];
		id<MGMAccountProtocol> account = [accountController contactControllerWithUser:user];
		if ([account isKindOfClass:[MGMVoiceUser class]]) {
			int count = [accountController badgeValueForInstance:[(MGMVoiceUser *)account instance]];
			if (count!=0)
				[cell setBadge:[[NSNumber numberWithInt:count] stringValue]];
			else
				[cell setBadge:nil];
		} else {
			[cell setBadge:nil];
		}
#if MGMSPENABLED
		if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
			if ([user settingForKey:MGMSIPAccountFullName]!=nil && ![[user settingForKey:MGMSIPAccountFullName] isEqual:@""])
				[cell setName:[user settingForKey:MGMSIPAccountFullName]];
		}
#endif
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