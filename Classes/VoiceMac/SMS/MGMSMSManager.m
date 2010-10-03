//
//  MGMSMSManager.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSMSManager.h"
#import "MGMSMSMessageView.h"
#import "MGMViewCell.h"
#import "MGMSplitView.h"
#import "MGMSMSTextView.h"
#import "MGMVoiceUser.h"
#import "MGMSIPUser.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

const float updateTimeInterval = 300.0;

@implementation MGMSMSManager
+ (id)managerWithController:(MGMController *)theController {
	return [[[self alloc] initWithController:theController] autorelease];
}
- (id)initWithController:(MGMController *)theController {
	if (self = [super init]) {
		controller = theController;
		SMSMessages = [NSMutableArray new];
		lastDates = [NSMutableDictionary new];
		updateTimer = [[NSTimer scheduledTimerWithTimeInterval:updateTimeInterval target:self selector:@selector(update) userInfo:nil repeats:YES] retain];
	}
	return self;
}
- (void)awakeFromNib {
	[[[messagesTable tableColumns] objectAtIndex:0] setDataCell:[[[MGMViewCell alloc] initGradientCell] autorelease]];
}
- (void)dealloc {
	if (SMSWindow!=nil)
		[SMSWindow close];
	if (updateTimer!=nil) {
		[updateTimer invalidate];
		[updateTimer release];
	}
	if (SMSMessages!=nil)
		[SMSMessages release];
	if (lastDates!=nil)
		[lastDates release];
	[super dealloc];
}

- (NSWindow *)SMSWindow {
	return SMSWindow;
}
- (MGMController *)controller {
	return controller;
}
- (MGMThemeManager *)themeManager {
	return [controller themeManager];
}
- (NSMutableArray *)SMSMessages {
	return SMSMessages;
}

- (void)loadWindow {
	if (SMSWindow==nil) {
		if (![NSBundle loadNibNamed:@"SMSWindow" owner:self]) {
			NSLog(@"Error: Unable to load SMS Window!");
			return;
		}
	}
}
- (IBAction)showWindow:(id)sender {
	[self loadWindow];
	[SMSWindow makeKeyAndOrderFront:self];
}

- (void)update {
	if ([SMSMessages count]>0) {
		NSMutableArray *instances = [NSMutableArray array];
		for (unsigned int i=0; i<[SMSMessages count]; i++) {
			MGMSMSMessageView *message = [SMSMessages objectAtIndex:i];
			if (![instances containsObject:[message instance]]) {
				[instances addObject:[message instance]];
				[self checkSMSMessagesForInstance:[message instance]];
			}
		}
	}
}

- (void)reloadData {
	while ([[messagesTable subviews] count]>0)
		[[[messagesTable subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    [messagesTable reloadData];
}
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	return [SMSMessages count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	return nil;
}
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	[(MGMViewCell *)cell addSubview:[[SMSMessages objectAtIndex:row] view]];
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row {
	while ([[messageView subviews] count]>0)
		[[[messageView subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
	MGMSMSMessageView *message = [SMSMessages objectAtIndex:row];
	[[message SMSSplitView] setFrame:NSMakeRect(0, 0, [messageView frame].size.width, [messageView frame].size.height)];
	[messageView addSubview:[message SMSSplitView]];
	[SMSWindow makeFirstResponder:[message SMSTextField]];
	[(MGMVoiceUser *)[[message instance] delegate] windowDidBecomeKey:nil];
	return YES;
}
- (void)closeSMSMessage:(MGMSMSMessageView *)theMessage {
	unsigned int message = [SMSMessages indexOfObject:theMessage];
	if (messagesTable!=nil) {
		if (message==[messagesTable selectedRow])
			[[theMessage SMSSplitView] removeFromSuperviewWithoutNeedingDisplay];
	}
	[SMSMessages removeObjectAtIndex:message];
	if (SMSWindow!=nil) {
		if ([SMSMessages count]<=0) {
			[self reloadData];
			[SMSWindow close];
		} else {
			[self reloadData];
			[messagesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
			[self tableView:messagesTable shouldSelectRow:0];
		}
	}
}

- (void)checkSMSMessagesForInstance:(MGMInstance *)theInstance {
	[[theInstance inbox] getSMSForPage:1 delegate:self];
}
- (void)inbox:(NSDictionary *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"SMS Error: %@ for instance: %@", theError, theInstance);
}
- (void)inboxGotInfo:(NSArray *)theMessages instance:(MGMInstance *)theInstance {
	if (updateTimer!=nil) {
		[updateTimer invalidate];
		[updateTimer release];
		updateTimer = [[NSTimer scheduledTimerWithTimeInterval:updateTimeInterval target:self selector:@selector(update) userInfo:nil repeats:YES] retain];
	}
	NSDate *newestDate = [NSDate distantPast];
	BOOL newMessage = NO;
	BOOL newTab = NO;
	for (unsigned int i=0; i<[theMessages count]; i++) {
		if ([lastDates objectForKey:[theInstance userNumber]]==nil || (![[lastDates objectForKey:[theInstance userNumber]] isEqual:[[theMessages objectAtIndex:i] objectForKey:MGMITime]] && [[lastDates objectForKey:[theInstance userNumber]] earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==[lastDates objectForKey:[theInstance userNumber]])) {
			NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithDictionary:[theMessages objectAtIndex:i]];
			NSArray *messages = [[[messageInfo objectForKey:MGMIMessages] retain] autorelease];
			[messageInfo removeObjectForKey:MGMIMessages];
			[messageInfo setObject:[[theInstance contacts] nameForNumber:[messageInfo objectForKey:MGMIPhoneNumber]] forKey:MGMTInName];
			[messageInfo setObject:[theInstance userNumber] forKey:MGMTUserNumber];
			BOOL tab = NO;
			for (unsigned int m=0; m<[SMSMessages count]; m++) {
				if ([[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIPhoneNumber] isEqual:[messageInfo objectForKey:MGMIPhoneNumber]] && ([[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIID] isEqual:[messageInfo objectForKey:MGMIID]] || [[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIID] isEqual:@""]) && [[SMSMessages objectAtIndex:m] instance]==theInstance) {
					tab = YES;
					if ([[SMSMessages objectAtIndex:m] updateWithMessages:messages messageInfo:messageInfo])
						newMessage = YES;
					break;
				}
			}
			if (![[[theMessages objectAtIndex:i] objectForKey:MGMIRead] boolValue]) {
				newMessage = YES;
				if (!tab) {
					newTab = YES;
					[SMSMessages addObject:[MGMSMSMessageView viewWithManager:self messages:messages messageInfo:messageInfo instance:theInstance]];
				}
			}
			if ([newestDate earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==newestDate)
				newestDate = [[theMessages objectAtIndex:i] objectForKey:MGMITime];
		}
	}
	if (newMessage) {
		[lastDates setObject:newestDate forKey:[theInstance userNumber]];
		[[controller themeManager] playSound:MGMTSSMSMessage];
	}
	if (newTab) {
		[self loadWindow];
		[self reloadData];
		[SMSWindow makeKeyAndOrderFront:self];
	}
}
- (void)messageWithNumber:(NSString *)theNumber instance:(MGMInstance *)theInstance {
	[self loadWindow];
	NSMutableDictionary *messageInfo = [NSMutableDictionary dictionary];
	[messageInfo setObject:[NSDate date] forKey:MGMITime];
	[messageInfo setObject:[[theInstance contacts] nameForNumber:theNumber] forKey:MGMTInName];
	[messageInfo setObject:theNumber forKey:MGMIPhoneNumber];
	[messageInfo setObject:[theInstance userNumber] forKey:MGMTUserNumber];
	[messageInfo setObject:@"" forKey:MGMIID];
	[messageInfo setObject:[NSNumber numberWithBool:YES] forKey:MGMIRead];
	BOOL window = NO;
	for (unsigned int m=0; m<[SMSMessages count]; m++) {
		if ([[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIPhoneNumber] isEqual:[messageInfo objectForKey:MGMIPhoneNumber]] && [[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIID] isEqual:@""] && [[[SMSMessages objectAtIndex:m] instance] isEqual:theInstance]) {
			window = YES;
			[messagesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:m] byExtendingSelection:NO];
			[self tableView:messagesTable shouldSelectRow:m];
			break;
		}
	}
	if (!window) {
		[SMSMessages addObject:[MGMSMSMessageView viewWithManager:self messages:[NSArray array] messageInfo:messageInfo instance:theInstance]];
		[self reloadData];
		[messagesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[SMSMessages count]-1] byExtendingSelection:NO];
		[self tableView:messagesTable shouldSelectRow:[SMSMessages count]-1];
	}
	[SMSWindow makeKeyAndOrderFront:self];
}
- (void)messageWithData:(NSDictionary *)theData instance:(MGMInstance *)theInstance {
	[self loadWindow];
	NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithDictionary:theData];
	NSArray *messages = [[[messageInfo objectForKey:MGMIMessages] retain] autorelease];
	[messageInfo removeObjectForKey:MGMIMessages];
	[messageInfo setObject:[[theInstance contacts] nameForNumber:[messageInfo objectForKey:MGMIPhoneNumber]] forKey:MGMTInName];
	[messageInfo setObject:[theInstance userNumber] forKey:MGMTUserNumber];
	BOOL window = NO;
	for (unsigned int m=0; m<[SMSMessages count]; m++) {
		if ([[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIPhoneNumber] isEqual:[messageInfo objectForKey:MGMIPhoneNumber]] && ([[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIID] isEqual:[messageInfo objectForKey:MGMIID]] || [[[[SMSMessages objectAtIndex:m] messageInfo] objectForKey:MGMIID] isEqual:@""]) && [[SMSMessages objectAtIndex:m] instance]==theInstance) {
			window = YES;
			[[SMSMessages objectAtIndex:m] updateWithMessages:messages messageInfo:messageInfo];
			break;
		}
	}
	if (!window) {
		[SMSMessages addObject:[MGMSMSMessageView viewWithManager:self messages:messages messageInfo:messageInfo instance:theInstance]];
		[self reloadData];
		[messagesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[SMSMessages count]-1] byExtendingSelection:NO];
		[self tableView:messagesTable shouldSelectRow:[SMSMessages count]-1];
	}
	[SMSWindow makeKeyAndOrderFront:self];
}
- (NSString *)currentPhoneNumber {
	if (messagesTable==nil)
		return nil;
	return [[[SMSMessages objectAtIndex:[messagesTable selectedRow]] messageInfo] objectForKey:MGMIPhoneNumber];
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset {
    leftMax = [[[sender subviews] objectAtIndex:0] frame].size.width;
	rightMax = [[[sender subviews] objectAtIndex:1] frame].size.width;
	return 0.0;
}
- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset{
	leftMax = [[[sender subviews] objectAtIndex:0] frame].size.width;
	rightMax = [[[sender subviews] objectAtIndex:1] frame].size.width;
	return proposedMax - 150.0;
}
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSRect newFrame = [sender frame];
    if (newFrame.size.width == oldSize.width) {
		[sender adjustSubviews];
		return;
    }
	if (rightMax==0.0)
		[self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:0];
	
	NSView *left = [[sender subviews] objectAtIndex:0];
    NSRect leftFrame = [left frame];
	NSView *right = [[sender subviews] objectAtIndex:1];
    NSRect rightFrame = [right frame];
	
	if (rightFrame.size.width<150.0) {
		rightMax = newFrame.size.width-(150.0+[sender dividerThickness]);
		rightFrame.size.width = rightMax;
	}
	
	if (rightMax<150.0)
		rightMax = 150.0;
	
	NSSize minSize = [SMSWindow minSize];
	minSize.width = leftMax+150.0;
	[SMSWindow setMinSize:minSize];
	
	if (leftFrame.size.width<leftMax || leftFrame.size.width>leftMax)
		leftFrame.size.width = leftMax;
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	if ([messagesTable selectedRow]==-1) return;
	[(MGMVoiceUser *)[[[SMSMessages objectAtIndex:[messagesTable selectedRow]] instance] delegate] windowDidBecomeKey:notification];
}
- (BOOL)windowShouldClose:(id)sender {
	if ([SMSMessages count]>1) {
		[[SMSMessages objectAtIndex:[messagesTable selectedRow]] close:self];
		return NO;
	}
	if ([SMSMessages count]==1) {
		if (![[SMSMessages objectAtIndex:0] shouldClose]) {
			NSAlert *theAlert = [[NSAlert new] autorelease];
			[theAlert setMessageText:@"Sending a SMS Message"];
			[theAlert setInformativeText:@"You currently have a SMS Message being sent, please wait for it to be sent."];
			[theAlert runModal];
			return NO;
		} else {
			[[SMSMessages objectAtIndex:0] close:self];
			return NO;
		}
	}
	return YES;
}
- (void)windowWillClose:(NSNotification *)notification {
	[SMSWindow setDelegate:nil];
	SMSWindow = nil;
	splitView = nil;
	messageView = nil;
	messagesTable = nil;
}
@end