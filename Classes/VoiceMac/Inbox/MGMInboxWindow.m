//
//  MGMInboxWindow.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/3/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMInboxWindow.h"
#import "MGMInboxPlayWindow.h"
#import "MGMVoiceUser.h"
#import "MGMController.h"
#import "MGMSMSManager.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <Growl/GrowlApplicationBridge.h>

static NSMutableArray *sideItems;

NSString * const MGMSName = @"name";
NSString * const MGMSObjects = @"objects";
NSString * const MGMSSelectable = @"selectable";
NSString * const MGMSID = @"id";

@implementation MGMInboxWindow
+ (id)windowWithInstance:(MGMInstance *)theInstance {
	return [[[self alloc] initWithInstance:theInstance] autorelease];
}
- (id)initWithInstance:(MGMInstance *)theInstance {
	if ((self = [super init])) {
		if (sideItems==nil) {
			sideItems = [NSMutableArray new];
			[sideItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Inbox", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:0], MGMSID, nil]];
			[sideItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Starred", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:1], MGMSID, nil]];
			[sideItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Spam", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:2], MGMSID, nil]];
			[sideItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Trash", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:3], MGMSID, nil]];
			NSMutableArray *history = [NSMutableArray array];
			[history addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Voicemail", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:4], MGMSID, nil]];
			[history addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"SMS Messages", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:5], MGMSID, nil]];
			[history addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Recorded", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:6], MGMSID, nil]];
			[history addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Placed", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:7], MGMSID, nil]];
			[history addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Received", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:8], MGMSID, nil]];
			[history addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Missed", MGMSName, [NSNumber numberWithBool:YES], MGMSSelectable, [NSNumber numberWithInt:9], MGMSID, nil]];
			[sideItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"History", MGMSName, [NSNumber numberWithBool:NO], MGMSSelectable, history, MGMSObjects, nil]];
		}
		instance = theInstance;
		maxResults = 10;
	}
	return self;
}
- (void)awakeFromNib {
	[inboxTable setTarget:self];
	[inboxTable setDoubleAction:@selector(inboxAction:)];
	[nextButton setEnabled:NO];
	[previousButton setEnabled:NO];
	progressStartCount = 0;
	[inboxWindow setFrameAutosaveName:[@"inboxWindow" stringByAppendingString:[[instance user] settingForKey:MGMUserID]]];
	[inboxWindow setTitle:[NSString stringWithFormat:@"%@ (%@)", [inboxWindow title], [[instance userNumber] readableNumber]]];
	if ([splitView respondsToSelector:@selector(setAutosaveName:)])
		[splitView setAutosaveName:[@"inboxSplitView" stringByAppendingString:[[instance user] settingForKey:MGMUserID]]];
	[sidebarView setAutosaveName:[@"inboxSidebarView" stringByAppendingString:[[instance user] settingForKey:MGMUserID]]];
	[sidebarView setAutosaveExpandedItems:YES];
}
- (void)dealloc {
	[inboxWindow close];
	[currentData release];
	[super dealloc];
}

- (NSWindow *)inboxWindow {
	return inboxWindow;
}
- (IBAction)showWindow:(id)sender {
	if (inboxWindow==nil) {
		if (![NSBundle loadNibNamed:@"InboxWindow" owner:self]) {
			NSLog(@"Error: Unable to load Inbox Window!");
			return;
		}
	}
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		switch ([sender tag]) {
			case 1:
				[sidebarView expandItem:[sideItems objectAtIndex:4]];
				[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:6] byExtendingSelection:NO];
				[self outlineView:sidebarView shouldSelectItem:[[[sideItems objectAtIndex:4] objectForKey:MGMSObjects] objectAtIndex:1]];
				break;
			case 2:
				[sidebarView expandItem:[sideItems objectAtIndex:4]];
				[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:5] byExtendingSelection:NO];
				[self outlineView:sidebarView shouldSelectItem:[[[sideItems objectAtIndex:4] objectForKey:MGMSObjects] objectAtIndex:0]];
				break;
			case 3:
				[sidebarView expandItem:[sideItems objectAtIndex:4]];
				[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:8] byExtendingSelection:NO];
				[self outlineView:sidebarView shouldSelectItem:[[[sideItems objectAtIndex:4] objectForKey:MGMSObjects] objectAtIndex:3]];
				break;
			case 4:
				[sidebarView expandItem:[sideItems objectAtIndex:4]];
				[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:9] byExtendingSelection:NO];
				[self outlineView:sidebarView shouldSelectItem:[[[sideItems objectAtIndex:4] objectForKey:MGMSObjects] objectAtIndex:4]];
				break;
			case 5:
				[sidebarView expandItem:[sideItems objectAtIndex:4]];
				[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:10] byExtendingSelection:NO];
				[self outlineView:sidebarView shouldSelectItem:[[[sideItems objectAtIndex:4] objectForKey:MGMSObjects] objectAtIndex:5]];
				break;
			default:
				[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
				[self outlineView:sidebarView shouldSelectItem:[sideItems objectAtIndex:0]];
				break;
		}
	} else if (sender!=self) {
		[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		[self outlineView:sidebarView shouldSelectItem:[sideItems objectAtIndex:0]];
	} else {
		start = 0;
		[sidebarView expandItem:[sideItems objectAtIndex:4]];
		[sidebarView selectRowIndexes:[NSIndexSet indexSetWithIndex:5] byExtendingSelection:NO];
		currentInbox = 4;
		[pageField setStringValue:@"Page 1"];
	}
	[sidebarView setAllowsEmptySelection:NO];
	[inboxWindow makeKeyAndOrderFront:self];
}
- (void)closeWindow {
	[inboxWindow close];
}

- (void)startProgress {
	if (progressStartCount==0)
		[progress startAnimation:self];
	progressStartCount++;
}
- (void)stopProgress {
	if (progressStartCount==1)
		[progress stopAnimation:self];
	progressStartCount--;
}

- (void)checkVoicemail {
	[[instance inbox] getVoicemailForPage:1 delegate:self didFailWithError:@selector(voicemail:didFailWithError:instance:) didReceiveInfo:@selector(voicemailGotInfo:instance:)];
}
- (void)voicemail:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"Voicemail Error: %@ for instance: %@", theError, theInstance);
}
- (void)voicemailGotInfo:(NSArray *)theMessages instance:(MGMInstance *)theInstance {
	NSDate *newestDate = [NSDate distantPast];
	BOOL newMessage = NO;
	for (unsigned int i=0; i<[theMessages count]; i++) {
		if (![[[theMessages objectAtIndex:i] objectForKey:MGMIRead] boolValue] && (lastDate==nil || (![lastDate isEqual:[[theMessages objectAtIndex:i] objectForKey:MGMITime]] && [lastDate earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==lastDate))) {
			[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"Voicemail from %@", [[instance contacts] nameForNumber:[[theMessages objectAtIndex:i] objectForKey:MGMIPhoneNumber]]] description:[[[theMessages objectAtIndex:i] objectForKey:MGMIText] flattenHTML] notificationName:@"Voicemail" iconData:[[instance contacts] photoDataForNumber:[[theMessages objectAtIndex:i] objectForKey:MGMIPhoneNumber]] priority:0 isSticky:NO clickContext:nil];
			newMessage = YES;
			if ([newestDate earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==newestDate)
				newestDate = [[theMessages objectAtIndex:i] objectForKey:MGMITime];
		}
	}
	if (newMessage) {
		[lastDate release];
		lastDate = [newestDate copy];
		[self setCurrentData:theMessages];
		[self showWindow:self];
		[[[(MGMVoiceUser *)[instance delegate] controller] themeManager] playSound:MGMTSVoicemail];
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	return (item==nil ? [sideItems count] : ([item objectForKey:MGMSObjects]!=nil ? [[item objectForKey:MGMSObjects] count] : 0));
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return (item!=nil ? ([item objectForKey:MGMSObjects]!=nil && [[item objectForKey:MGMSObjects] count]>0) : NO);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	return (item==nil ? [sideItems objectAtIndex:index] : [[item objectForKey:MGMSObjects] objectAtIndex:index]);
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	return [item objectForKey:MGMSName];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	if ([item objectForKey:MGMSSelectable]!=nil && ![[item objectForKey:MGMSSelectable] boolValue])
		return NO;
	[self setCurrentData:nil];
	if ([item objectForKey:MGMSID]!=nil) {
		currentInbox = [[item objectForKey:MGMSID] intValue];
		start = 0;
		[self loadInbox];
	}
	return YES;
}

- (IBAction)next:(id)sender {
	start += maxResults;
	[self loadInbox];
}
- (IBAction)previous:(id)sender {
	start -= maxResults;
	[self loadInbox];
}

- (void)loadInbox {
	int page = (start/maxResults)+1;
	[nextButton setEnabled:NO];
	[previousButton setEnabled:NO];
	[pageField setStringValue:[NSString stringWithFormat:@"Page %d", page]];
	[self startProgress];
	switch (currentInbox) {
		case 0:
			[[instance inbox] getInboxForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 1:
			[[instance inbox] getStarredForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 2:
			[[instance inbox] getSpamForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 3:
			[[instance inbox] getTrashForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 4:
			[[instance inbox] getVoicemailForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 5:
			[[instance inbox] getSMSForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 6:
			[[instance inbox] getRecordedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 7:
			[[instance inbox] getPlacedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 8:
			[[instance inbox] getReceivedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 9:
			[[instance inbox] getMissedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
	}
}
- (void)inbox:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"Inbox Error: %@ for instance: %@", theError, theInstance);
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert setMessageText:@"Error loading inbox"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert runModal];
	[self stopProgress];
}
- (void)inboxGotInfo:(NSArray *)theInfo instance:(MGMInstance *)theInstance {
	if (theInfo!=nil) {
		[self setCurrentData:theInfo];
	} else {
		NSLog(@"Error 234554: Hold on, this should never happen.");
	}
	[self stopProgress];
}
- (int)currentInbox {
	return currentInbox;
}
- (void)setCurrentData:(NSArray *)theData {
	[currentData release];
	currentData = [theData mutableCopy];
	
	resultsCount = [currentData count];
	if (resultsCount==maxResults)
		[nextButton setEnabled:YES];
	else
		[nextButton setEnabled:NO];
	if (start!=0)
		[previousButton setEnabled:YES];
	else
		[previousButton setEnabled:NO];
	[inboxTable reloadData];
}
- (NSDictionary *)selectedItem {
	if (inboxTable==nil || [inboxTable selectedRow]==-1)
		return nil;
	return [currentData objectAtIndex:[inboxTable selectedRow]];
}
- (NSString *)currentPhoneNumber {
	if (inboxTable==nil || [inboxTable selectedRow]==-1)
		return nil;
	return [[currentData objectAtIndex:[inboxTable selectedRow]] objectForKey:MGMIPhoneNumber];
}
- (NSURL *)audioURL {
	if (inboxTable==nil || [inboxTable selectedRow]==-1)
		return nil;
	NSDictionary *data = [currentData objectAtIndex:[inboxTable selectedRow]];
	if ([[data objectForKey:MGMIType] intValue]==MGMIVoicemailType || [[data objectForKey:MGMIType] intValue]==MGMIRecordedType)
		return [NSURL URLWithString:[NSString stringWithFormat:MGMIVoiceMailDownloadURL, [[data objectForKey:MGMIID] addPercentEscapes]]];
	return nil;
}
- (IBAction)spam:(id)sender {
	if (inboxTable==nil || [inboxTable selectedRow]==-1)
		return;
	NSMutableDictionary *data = [currentData objectAtIndex:[inboxTable selectedRow]];
	[self startProgress];
	[[instance inbox] reportEntries:[NSArray arrayWithObject:[data objectForKey:MGMIID]] delegate:self];
	[currentData removeObject:data];
	[inboxTable reloadData];
}
- (IBAction)report:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"Report Error: %@ for instance: %@", theError, theInstance);
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert setMessageText:@"Error reporting"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert runModal];
	[self stopProgress];
}
- (void)reportDidFinish:(MGMDelegateInfo *)theInfo instance:(MGMInstance *)theInstance {
	[self loadInbox];
	[self stopProgress];
}
- (IBAction)markRead:(id)sender {
	if (inboxTable==nil || [inboxTable selectedRow]==-1)
		return;
	NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[currentData objectAtIndex:[inboxTable selectedRow]]];
	[[instance inbox] markEntries:[NSArray arrayWithObject:[data objectForKey:MGMIID]] read:![[data objectForKey:MGMIRead] boolValue] delegate:self];
	[data setObject:[NSNumber numberWithBool:![[data objectForKey:MGMIRead] boolValue]] forKey:MGMIRead];
	[currentData replaceObjectAtIndex:[inboxTable selectedRow] withObject:data];
	[inboxTable reloadData];
}
- (IBAction)delete:(id)sender {
	if (inboxTable==nil || [inboxTable selectedRow]==-1)
		return;
	NSDictionary *data = [currentData objectAtIndex:[inboxTable selectedRow]];
	[self startProgress];
	if (currentInbox==3)
		[[instance inbox] deleteEntriesForever:[NSArray arrayWithObject:[data objectForKey:MGMIID]] delegate:self];
	else
		[[instance inbox] deleteEntries:[NSArray arrayWithObject:[data objectForKey:MGMIID]] delegate:self];
	[currentData removeObject:data];
	[inboxTable reloadData];
}
- (IBAction)undelete:(id)sender {
	if (inboxTable==nil || [inboxTable selectedRow]==-1)
		return;
	NSDictionary *data = [currentData objectAtIndex:[inboxTable selectedRow]];
	[self startProgress];
	[[instance inbox] deleteEntries:[NSArray arrayWithObject:[data objectForKey:MGMIID]] delegate:self];
	[currentData removeObject:data];
	[inboxTable reloadData];
}
- (void)delete:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"Delete Error: %@ for instance: %@", theError, theInstance);
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert setMessageText:@"Error deleting"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert runModal];
	[self stopProgress];
}
- (void)deleteDidFinish:(MGMDelegateInfo *)theInfo instance:(MGMInstance *)theInstance {
	[self loadInbox];
	[self stopProgress];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [currentData count];
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSDictionary *data = [currentData objectAtIndex:rowIndex];
	NSString *identifier = [aTableColumn identifier];
	if ([identifier isEqual:@"read"]) {
		return ([[data objectForKey:MGMIRead] boolValue] ? @"" : @"•");
	} else if ([identifier isEqual:@"name"]) {
		NSString *name = [[instance contacts] nameForNumber:[data objectForKey:MGMIPhoneNumber]];
		NSString *number = [[data objectForKey:MGMIPhoneNumber] readableNumber];
		if ([name isEqual:number])
			return number;
		return [NSString stringWithFormat:@"%@ (%@)", name, number];
	} else if ([identifier isEqual:@"text"]) {
		int type = [[data objectForKey:MGMIType] intValue];
		if (type==MGMIVoicemailType) {
			return [data objectForKey:MGMIText];
		} else if (type==MGMISMSInType || type==MGMISMSOutType) {
			return [[[[data objectForKey:MGMIMessages] lastObject] objectForKey:MGMIText] flattenHTML];
		} else {
			return [[[data objectForKey:MGMIPhoneNumber] areaCode] areaCodeLocation];
		}
	} else if ([identifier isEqual:@"date"]) {
		NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
		[formatter setDateFormat:@"M/d/yy h:mm:ss a"];
		return [formatter stringFromDate:[data objectForKey:MGMITime]];
	}
	return nil;
}
- (IBAction)inboxAction:(id)sender {
	NSDictionary *data = [currentData objectAtIndex:[inboxTable selectedRow]];
	int type = [[data objectForKey:MGMIType] intValue];
	if (type==MGMIVoicemailType) {
		NSArray *cookies = [[instance cookieStorage] cookies];
		for (int i=0; i<[cookies count]; i++) {
			NSHTTPCookie *cookie = [cookies objectAtIndex:i];
			if ([[cookie path] isEqual:@"/voice"] && [[cookie name] isEqual:@"gv"])
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
		}
		MGMInboxPlayWindow *playWindow = [[MGMInboxPlayWindow alloc] initWithNibNamed:@"VoicemailView" data:data instance:instance];
		NSRect rowRect = [inboxTable rectOfRow:[inboxTable selectedRow]];
		rowRect.origin = [[inboxWindow contentView] convertPoint:rowRect.origin fromView:inboxTable];
		rowRect.origin = [inboxWindow convertBaseToScreen:rowRect.origin];
		rowRect.origin.y -= ([playWindow frame].size.height+20);
		rowRect.origin.x += ((rowRect.size.width-[playWindow frame].size.width)/2);
		[playWindow setFrameOrigin:rowRect.origin];
		[playWindow makeKeyAndOrderFront:self];
	} else if (type==MGMIRecordedType) {
		NSArray *cookies = [[instance cookieStorage] cookies];
		for (int i=0; i<[cookies count]; i++) {
			NSHTTPCookie *cookie = [cookies objectAtIndex:i];
			if ([[cookie path] isEqual:@"/voice"] && [[cookie name] isEqual:@"gv"])
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
		}
		MGMInboxPlayWindow *playWindow = [[MGMInboxPlayWindow alloc] initWithNibNamed:@"RecordedView" data:data instance:instance];
		NSRect rowRect = [inboxTable rectOfRow:[inboxTable selectedRow]];
		rowRect.origin = [[inboxWindow contentView] convertPoint:rowRect.origin fromView:inboxTable];
		rowRect.origin = [inboxWindow convertBaseToScreen:rowRect.origin];
		rowRect.origin.y -= ([playWindow frame].size.height+20);
		rowRect.origin.x += ((rowRect.size.width-[playWindow frame].size.width)/2);
		[playWindow setFrameOrigin:rowRect.origin];
		[playWindow makeKeyAndOrderFront:self];
	} else if (type==MGMISMSInType || type==MGMISMSOutType) {
		[[[(MGMVoiceUser *)[instance delegate] controller] SMSManager] messageWithData:data instance:instance];
	} else {
		[(MGMVoiceUser *)[instance delegate] runAction:sender];
	}
	if (![[data objectForKey:MGMIRead] boolValue])
		[self markRead:self];
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset {
    leftMax = [[[sender subviews] objectAtIndex:0] frame].size.width;
	rightMax = [[[sender subviews] objectAtIndex:1] frame].size.width;
	return 0.0;
}
- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset{
	leftMax = [[[sender subviews] objectAtIndex:0] frame].size.width;
	rightMax = [[[sender subviews] objectAtIndex:1] frame].size.width;
	return proposedMax - 250.0;
}
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSRect newFrame = [sender frame];
    if (newFrame.size.width == oldSize.width) {
		[sender adjustSubviews];
		return;
    }
	
	NSView *left = [[sender subviews] objectAtIndex:0];
    NSRect leftFrame = [left frame];
	NSView *right = [[sender subviews] objectAtIndex:1];
    NSRect rightFrame = [right frame];
	
	if (rightFrame.size.width<250.0) {
		rightMax = newFrame.size.width-(250.0+[sender dividerThickness]);
		rightFrame.size.width = rightMax;
	}
	
	if (rightMax<250.0)
		rightMax = 250.0;
	
	if (leftFrame.size.width < leftMax || leftFrame.size.width > leftMax)
		leftFrame.size.width = leftMax;
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	[sidebarView display];
	[(MGMVoiceUser *)[instance delegate] windowDidBecomeKey:notification];
}
- (void)windowDidResignKey:(NSNotification *)notification {
	[sidebarView display];
}
- (void)windowWillClose:(NSNotification *)notification {
	[self setCurrentData:nil];
	[inboxWindow setDelegate:nil];
	inboxWindow = nil;
	splitView = nil;
	sidebarView = nil;
	inboxTable = nil;
	nextButton = nil;
	previousButton = nil;
	pageField = nil;
	progress = nil;
}
@end

@implementation MGMInboxTableView
- (void)keyDown:(NSEvent *)theEvent {
	int keyCode = [theEvent keyCode];
	if (keyCode==51 || keyCode==117) {
		if ([inboxWindow currentInbox]==3 && [theEvent modifierFlags] & NSAlternateKeyMask)
			[inboxWindow undelete:self];
		else
			[inboxWindow delete:self];
	} else {
		[super keyDown:theEvent];
	}
}
- (void)copy:(id)sender {
	NSString *phoneNumber = [inboxWindow currentPhoneNumber];
	if (phoneNumber==nil) {
		NSBeep();
		return;
	}
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString:[phoneNumber readableNumber] forType:NSStringPboardType];
}
@end