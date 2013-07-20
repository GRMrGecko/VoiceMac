//
//  MGMSIPHistory.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/14/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMSIPInbox.h"
#import "MGMSIPUser.h"
#import "MGMAccountController.h"
#import "MGMInboxMessageView.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

static NSMutableArray *MGMSIPInboxItems;

NSString * const MGMHInboxDB = @"inbox.db";

NSString * const MGMHInboxPlist = @"inbox.plist";
NSString * const MGMHInbox = @"MGMHInbox";
NSString * const MGMHStart = @"MGMHStart";
NSString * const MGMHResultsCount = @"MGMHResultsCount";
NSString * const MGMHLastUpdate = @"MGMHLastUpdate";

NSString * const MGMHName = @"name";
NSString * const MGMHID = @"id";

NSString * const MGMSIPInboxesCellIdentifier = @"MGMSIPInboxesCellIdentifier";
NSString * const MGMSIPInboxMessageCellIdentifier = @"MGMSIPInboxMessageCellIdentifier";
NSString * const MGMSIPInboxMessageLoadCellIdentifier = @"MGMSIPInboxMessageLoadCellIdentifier";

@implementation MGMSIPInbox
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser {
	return [[[self alloc] initWithSIPUser:theSIPUser] autorelease];
}
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser {
	if ((self = [super init])) {
		if (MGMSIPInboxItems==nil) {
			MGMSIPInboxItems = [NSMutableArray new];
			[MGMSIPInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Inbox", MGMHName, [NSNumber numberWithInt:0], MGMHID, nil]];
			[MGMSIPInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Placed", MGMHName, [NSNumber numberWithInt:1], MGMHID, nil]];
			[MGMSIPInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Received", MGMHName, [NSNumber numberWithInt:2], MGMHID, nil]];
			[MGMSIPInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Missed", MGMHName, [NSNumber numberWithInt:3], MGMHID, nil]];
		}
		SIPUser = theSIPUser;
		
		BOOL buildDB = ![[NSFileManager defaultManager] fileExistsAtPath:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMHInboxDB]];
		inboxConnection = [[MGMLiteConnection connectionWithPath:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMHInboxDB]] retain];
		//[inboxConnection setLogQuery:YES];
		if (buildDB)
			[inboxConnection query:@"CREATE TABLE inbox (id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER, isRead INTEGER, time INTEGER, phoneNumber TEXT)"];
		
		[self registerSettings];
		
		lastUpdate = [[[SIPUser user] settingForKey:MGMHLastUpdate] retain];
		
		currentView = 1;
		currentInbox = [[[SIPUser user] settingForKey:MGMHInbox] intValue];
		maxResults = 10;
		start = [[[SIPUser user] settingForKey:MGMHStart] intValue];
		resultsCount = [[[SIPUser user] settingForKey:MGMHResultsCount] intValue];
		inboxItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:@"Inboxes" style:UIBarButtonItemStyleBordered target:self action:@selector(showInboxes:)] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease], [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:[SIPUser accountController] action:@selector(showSettings:)] autorelease], nil] retain];
		currentData = [NSMutableArray new];
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[inboxConnection release];
	[lastUpdate release];
	[inboxItems release];
	[currentData release];
	[super dealloc];
}

- (void)registerSettings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMHInbox];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMHResultsCount];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMHStart];
	[[SIPUser user] registerSettings:settings];
}

- (MGMSIPUser *)SIPUser {
	return SIPUser;
}

- (UIView *)view {
	if (inboxesTable==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"SIPInbox"] owner:self options:nil]) {
			NSLog(@"Unable to load SIP Inbox");
		} else {
			if (start==0 || lastUpdate==nil || [lastUpdate earlierDate:[NSDate dateWithTimeIntervalSinceNow:-300]]==lastUpdate) {
				start = 0;
				resultsCount = 0;
				[self loadInbox];
			} else if ([currentData count]<=0 && [[NSFileManager defaultManager] fileExistsAtPath:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMHInboxPlist]]) {
				[currentData addObjectsFromArray:[NSArray arrayWithContentsOfFile:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMHInboxPlist]]];
			}
			if (currentView==1)
				[[SIPUser accountController] setItems:inboxItems animated:YES];
			else
				[[SIPUser accountController] setItems:[[SIPUser accountController] accountItems] animated:YES];
		}
	}
	if (currentView==1)
		return inboxTable;
	return inboxesTable;
}
- (void)releaseView {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[inboxesTable release];
	inboxesTable = nil;
	[inboxTable release];
	inboxTable = nil;
	if (start!=0) {
		[currentData writeToFile:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMHInboxPlist] atomically:YES];
		[currentData removeAllObjects];
	}
}

- (void)addPhoneNumber:(NSString *)thePhoneNumber type:(int)theType {
	[inboxConnection query:@"INSERT INTO inbox (type, isRead, time, phoneNumber) VALUES (%d, %d, %qu, %@)", theType, (theType==MGMIMissedType ? 0 : 1), (unsigned long long)[[NSDate date] timeIntervalSince1970], thePhoneNumber];
}

- (IBAction)showInboxes:(id)sender {
	CGRect outViewFrame = [inboxTable frame];
	CGRect inViewFrame = [inboxesTable frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = -inViewFrame.size.width;
	[inboxesTable setFrame:inViewFrame];
	[[SIPUser tabView] addSubview:inboxesTable];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(inboxesAnimationDidStop:finished:context:)];
	[inboxesTable setFrame:outViewFrame];
	outViewFrame.origin.x = +outViewFrame.size.width;
	[inboxTable setFrame:outViewFrame];
	[UIView commitAnimations];
	[[SIPUser accountController] setItems:[[SIPUser accountController] accountItems] animated:YES];
	currentView = 0;
}
- (void)inboxesAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[inboxTable removeFromSuperview];
	currentInbox = -1;
	start = 0;
	resultsCount = 0;
	[currentData removeAllObjects];
	[inboxTable reloadData];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (theTableView==inboxesTable)
		return [MGMSIPInboxItems count];
	else if (theTableView==inboxTable)
		return (resultsCount==maxResults ? [currentData count]+1 : [currentData count]);
	return 0;
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (theTableView==inboxesTable) {
		UITableViewCell *cell = [inboxesTable dequeueReusableCellWithIdentifier:MGMSIPInboxesCellIdentifier];
		if (cell==nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMSIPInboxesCellIdentifier] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		}
		if ([cell respondsToSelector:@selector(textLabel)])
			[[cell textLabel] setText:[[MGMSIPInboxItems objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:MGMHName]];
		else
			[cell setText:[[MGMSIPInboxItems objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:MGMHName]];
		return cell;
	} else if (theTableView==inboxTable) {
		if ([currentData count]<=[indexPath indexAtPosition:1]) {
			UITableViewCell *cell = [inboxesTable dequeueReusableCellWithIdentifier:MGMSIPInboxMessageLoadCellIdentifier];
			if (cell==nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMSIPInboxMessageLoadCellIdentifier] autorelease];
				NSString *text = @"Load More...";
				if ([cell respondsToSelector:@selector(textLabel)]) {
					[[cell textLabel] setText:text];
					[[cell textLabel] setTextColor:[UIColor blueColor]];
					[[cell textLabel] setTextAlignment:UITextAlignmentCenter];
				} else {
					[cell setText:text];
					[cell setTextColor:[UIColor blueColor]];
					[cell setTextAlignment:UITextAlignmentCenter];
				}
			}
			return cell;
		} else {
			MGMInboxMessageView *cell = (MGMInboxMessageView *)[inboxTable dequeueReusableCellWithIdentifier:MGMSIPInboxMessageCellIdentifier];
			if (cell==nil) {
				cell = [[[MGMInboxMessageView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMSIPInboxMessageCellIdentifier] autorelease];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				[cell setInstance:(MGMInstance *)SIPUser];
			}
			[cell setMessageData:[currentData objectAtIndex:[indexPath indexAtPosition:1]]];
			return cell;
		}
	}
	return nil;
}
- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (theTableView==inboxesTable)
		return NO;
	return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)theTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)theTableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Delete";
}
- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *data = [currentData objectAtIndex:[indexPath indexAtPosition:1]];
	[inboxConnection query:@"DELETE FROM inbox WHERE id=%@", [data objectForKey:MGMHID]];
	[currentData removeObjectAtIndex:[indexPath indexAtPosition:1]];
	[inboxTable reloadData];
	
}
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (theTableView==inboxesTable) {
		currentInbox = [[[MGMSIPInboxItems objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:MGMHID] intValue];
		[[SIPUser user] setSetting:[NSNumber numberWithInt:currentInbox] forKey:MGMHInbox];
		[[inboxItems objectAtIndex:0] setEnabled:NO];
		[[SIPUser accountController] setItems:inboxItems animated:YES];
		
		CGRect outViewFrame = [inboxesTable frame];
		CGRect inViewFrame = [inboxTable frame];
		inViewFrame.size = outViewFrame.size;
		inViewFrame.origin.x = +inViewFrame.size.width;
		[inboxTable setFrame:inViewFrame];
		[[SIPUser tabView] addSubview:inboxTable];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(inboxAnimationDidStop:finished:context:)];
		[inboxTable setFrame:outViewFrame];
		outViewFrame.origin.x = -outViewFrame.size.width;
		[inboxesTable setFrame:outViewFrame];
		[UIView commitAnimations];
		currentView = 1;
		[self loadInbox];
	} else if (theTableView==inboxTable) {
		if ([indexPath indexAtPosition:1]>=[currentData count]) {
			start += maxResults;
			[self loadInbox];
		} else {
			NSMutableDictionary *data = [[[currentData objectAtIndex:[indexPath indexAtPosition:1]] mutableCopy] autorelease];
			if (![[data objectForKey:MGMIRead] boolValue]) {
				[inboxConnection query:@"UPDATE inbox SET isRead=1 WHERE id=%@", [data objectForKey:MGMHID]];
				[data setObject:[NSNumber numberWithBool:![[data objectForKey:MGMIRead] boolValue]] forKey:MGMIRead];
				[currentData replaceObjectAtIndex:[indexPath indexAtPosition:1] withObject:data];
				[inboxTable reloadData];
			}
			[SIPUser showOptionsForNumber:[data objectForKey:MGMIPhoneNumber]];
			[inboxTable deselectRowAtIndexPath:[inboxTable indexPathForSelectedRow] animated:YES];
		}
	}
}
- (void)inboxAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[inboxesTable removeFromSuperview];
	[inboxesTable deselectRowAtIndexPath:[inboxesTable indexPathForSelectedRow] animated:NO];
	[[inboxItems objectAtIndex:0] setEnabled:YES];
}

- (NSArray *)dataForType:(int)theType start:(unsigned int)theStart {
	MGMLiteResult *result = nil;
	if (theType==-1)
		result = [inboxConnection query:@"SELECT * FROM inbox ORDER BY id DESC LIMIT %u, %d", theStart, maxResults];
	else
		result = [inboxConnection query:@"SELECT * FROM inbox WHERE type = %d ORDER BY id DESC LIMIT %u, %d", theType, theStart, maxResults];
	NSMutableArray *data = [NSMutableArray array];
	NSDictionary *thisData = nil;
	while ((thisData=[result nextRow])!=nil) {
		NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:thisData];
		[dataDic setObject:[NSDate dateWithTimeIntervalSince1970:[[thisData objectForKey:MGMITime] unsignedLongLongValue]] forKey:MGMITime];
		[data addObject:dataDic];
	}
	return data;
}

- (void)loadInbox {
	[lastUpdate release];
	lastUpdate = [NSDate new];
	[[SIPUser user] setSetting:lastUpdate forKey:MGMHLastUpdate];
	[[SIPUser user] setSetting:[NSNumber numberWithInt:start] forKey:MGMHStart];
	NSArray *data = nil;
	switch (currentInbox) {
		case 0:
			data = [self dataForType:-1 start:start];
			break;
		case 1:
			data = [self dataForType:MGMIPlacedType start:start];
			break;
		case 2:
			data = [self dataForType:MGMIReceivedType start:start];
			break;
		case 3:
			data = [self dataForType:MGMIMissedType start:start];
			break;
	}
	[self addData:data];
}

- (void)addData:(NSArray *)theData {
	resultsCount = [theData count];
	[[SIPUser user] setSetting:[NSNumber numberWithInt:resultsCount] forKey:MGMHResultsCount];
	[currentData addObjectsFromArray:theData];
	[inboxTable reloadData];
}
- (int)currentInbox {
	return currentInbox;
}
@end