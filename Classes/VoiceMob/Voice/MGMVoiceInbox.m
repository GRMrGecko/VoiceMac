//
//  MGMVoiceInbox.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMVoiceInbox.h"
#import "MGMVoiceUser.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMVoiceSMS.h"
#import "MGMBadgeView.h"
#import "MGMInboxMessageView.h"
#import "MGMProgressView.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

static NSMutableArray *MGMInboxItems;

NSString * const MGMSInboxPlist = @"inbox.plist";
NSString * const MGMSInbox = @"MGMSInbox";
NSString * const MGMSLastUpdate = @"MGMSLastUpdate";
NSString * const MGMSResultsCount = @"MGMSResultsCount";
NSString * const MGMSStart = @"MGMSStart";

NSString * const MGMSName = @"name";
NSString * const MGMSID = @"id";

NSString * const MGMInboxesCellIdentifier = @"MGMInboxesCellIdentifier";
NSString * const MGMInboxMessageCellIdentifier = @"MGMInboxMessageCellIdentifier";
NSString * const MGMInboxMessageLoadCellIdentifier = @"MGMInboxMessageLoadCellIdentifier";

NSString * const MGMITLoading = @"Loading...";
NSString * const MGMITDeleting = @"Deleting...";

@implementation MGMVoiceInbox
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	return [[[self alloc] initWithVoiceUser:theVoiceUser] autorelease];
}
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	if ((self = [super init])) {
		if (MGMInboxItems==nil) {
			MGMInboxItems = [NSMutableArray new];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Inbox", MGMSName, [NSNumber numberWithInt:0], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Starred", MGMSName, [NSNumber numberWithInt:1], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Spam", MGMSName, [NSNumber numberWithInt:2], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Trash", MGMSName, [NSNumber numberWithInt:3], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Voicemail", MGMSName, [NSNumber numberWithInt:4], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"SMS Messages", MGMSName, [NSNumber numberWithInt:5], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Recorded", MGMSName, [NSNumber numberWithInt:6], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Placed", MGMSName, [NSNumber numberWithInt:7], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Received", MGMSName, [NSNumber numberWithInt:8], MGMSID, nil]];
			[MGMInboxItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Missed", MGMSName, [NSNumber numberWithInt:9], MGMSID, nil]];
		}
		voiceUser = theVoiceUser;
		
		[self registerSettings];
		
		lastUpdate = [[[voiceUser user] settingForKey:MGMSLastUpdate] retain];
		
		currentView = 1;
		currentInbox = [[[voiceUser user] settingForKey:MGMSInbox] intValue];
		maxResults = 10;
		start = [[[voiceUser user] settingForKey:MGMSStart] intValue];
		resultsCount = [[[voiceUser user] settingForKey:MGMSResultsCount] intValue];
		inboxItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:@"Inboxes" style:UIBarButtonItemStyleBordered target:self action:@selector(showInboxes:)] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease], [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:[voiceUser accountController] action:@selector(showSettings:)] autorelease], nil] retain];
		recordingItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:@"Inbox" style:UIBarButtonItemStyleBordered target:self action:@selector(showInbox:)] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease], [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:[voiceUser accountController] action:@selector(showSettings:)] autorelease], nil] retain];
		currentData = [NSMutableArray new];
		currentRecording = -1;
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[lastUpdate release];
	[inboxItems release];
	[recordingItems release];
	[currentData release];
	[lastDate release];
	[recordingConnection cancelAll];
	[recordingConnection release];
	[recordingPlayer release];
	[super dealloc];
}

- (void)registerSettings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMSInbox];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMSResultsCount];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMSStart];
	[[voiceUser user] registerSettings:settings];
}

- (MGMVoiceUser *)voiceUser {
	return voiceUser;
}
- (NSString *)title {
	if (currentRecording!=-1)
		return [[[currentData objectAtIndex:currentRecording] objectForKey:MGMIPhoneNumber] readableNumber];
	return [voiceUser title];
}

- (void)checkVoicemail {
	[[[voiceUser instance] inbox] getVoicemailForPage:1 delegate:self didFailWithError:@selector(voicemail:didFailWithError:instance:) didReceiveInfo:@selector(voicemailGotInfo:instance:)];
}
- (void)voicemail:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"Voicemail Error: %@ for instance: %@", theError, theInstance);
}
- (void)voicemailGotInfo:(NSArray *)theMessages instance:(MGMInstance *)theInstance {
	NSDate *newestDate = [NSDate distantPast];
	BOOL newMessage = NO;
	for (unsigned int i=0; i<[theMessages count]; i++) {
		if (![[[theMessages objectAtIndex:i] objectForKey:MGMIRead] boolValue] && (lastDate==nil || (![lastDate isEqual:[[theMessages objectAtIndex:i] objectForKey:MGMITime]] && [lastDate earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==lastDate))) {
			newMessage = YES;
			if ([newestDate earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==newestDate)
				newestDate = [[theMessages objectAtIndex:i] objectForKey:MGMITime];
		}
	}
	if (newMessage) {
		[lastDate release];
		lastDate = [newestDate copy];
		[[[[voiceUser accountController] controller] themeManager] playSound:MGMTSVoicemail];
	}
}

- (UIView *)view {
	if (inboxesTable==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoiceInbox"] owner:self options:nil]) {
			NSLog(@"Unable to load Voice Inbox");
		} else {
			if (lastUpdate==nil || [lastUpdate earlierDate:[NSDate dateWithTimeIntervalSinceNow:-300]]==lastUpdate) {
				start = 0;
				resultsCount = 0;
				[self loadInbox];
			} else if ([currentData count]<=0 && [[NSFileManager defaultManager] fileExistsAtPath:[[[voiceUser user] supportPath] stringByAppendingPathComponent:MGMSInboxPlist]]) {
				[currentData addObjectsFromArray:[NSArray arrayWithContentsOfFile:[[[voiceUser user] supportPath] stringByAppendingPathComponent:MGMSInboxPlist]]];
			}
			CGSize contentSize = [[voiceUser tabView] frame].size;
			progressView = [[MGMProgressView alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
			if (progressStartCount>0) {
				[progressView startProgess];
				[progressView setProgressTitle:MGMITLoading];
				[[voiceUser tabView] performSelector:@selector(addSubview:) withObject:progressView afterDelay:0.1];
			}
			[recordingView setDelegate:self];
			[recordingView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"recording" ofType:@"html"]]]];
			if (currentView==1)
				[[voiceUser accountController] setItems:inboxItems animated:YES];
			else if (currentView==2)
				[[voiceUser accountController] setItems:recordingItems animated:YES];
			else
				[[voiceUser accountController] setItems:[[voiceUser accountController] accountItems] animated:YES];
			[[voiceUser accountController] setTitle:[self title]];
		}
	}
	if (currentView==1)
		return inboxTable;
	if (currentView==2)
		return recordingView;
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
	[progressView release];
	progressView = nil;
	[recordingView release];
	recordingView = nil;
	[recordingUpdater invalidate];
	[recordingUpdater release];
	recordingUpdater = nil;
	[recordingPlayer pause];
	[currentData writeToFile:[[[voiceUser user] supportPath] stringByAppendingPathComponent:MGMSInboxPlist] atomically:YES];
	[currentData removeAllObjects];
}

- (void)startProgress:(NSString *)theTitle {
	if (progressView!=nil) {
		[progressView setProgressTitle:theTitle];
		CGRect viewFrame = [progressView frame];
		viewFrame.size = [[voiceUser tabView] frame].size;
		[progressView setFrame:viewFrame];
		if ([progressView superview]==nil)
			[[voiceUser tabView] addSubview:progressView];
		[progressView startProgess];
		[progressView becomeFirstResponder];
	}
	progressStartCount++;
}
- (void)stopProgress {
	if (progressStartCount==1) {
		[progressView stopProgess];
		[progressView removeFromSuperview];
	}
	progressStartCount--;
}

- (IBAction)showInboxes:(id)sender {
	CGRect outViewFrame = [inboxTable frame];
	CGRect inViewFrame = [inboxesTable frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = -inViewFrame.size.width;
	[inboxesTable setFrame:inViewFrame];
	[[voiceUser tabView] addSubview:inboxesTable];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(inboxesAnimationDidStop:finished:context:)];
	[inboxesTable setFrame:outViewFrame];
	outViewFrame.origin.x = +outViewFrame.size.width;
	[inboxTable setFrame:outViewFrame];
	[UIView commitAnimations];
	[[voiceUser accountController] setItems:[[voiceUser accountController] accountItems] animated:YES];
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
		return [MGMInboxItems count];
	else if (theTableView==inboxTable)
		return (resultsCount==maxResults ? [currentData count]+1 : [currentData count]);
	return 0;
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (theTableView==inboxesTable) {
		MGMBadgeView *cell = (MGMBadgeView *)[inboxesTable dequeueReusableCellWithIdentifier:MGMInboxesCellIdentifier];
		if (cell==nil) {
			cell = [[[MGMBadgeView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMInboxesCellIdentifier] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		}
		NSDictionary *info = [MGMInboxItems objectAtIndex:[indexPath indexAtPosition:1]];
		[cell setName:[info objectForKey:MGMSName]];
		NSString *countName = @"";
		int sid = [[info objectForKey:MGMSID] intValue];
		if (sid==0)
			countName = MGMUCInbox;
		else if (sid==1)
			countName = MGMUCStarred;
		else if (sid==2)
			countName = MGMUCSpam;
		else if (sid==3)
			countName = MGMUCTrash;
		else if (sid==4)
			countName = MGMUCVoicemail;
		else if (sid==5)
			countName = MGMUCSMS;
		else if (sid==6)
			countName = MGMUCRecorded;
		else if (sid==7)
			countName = MGMUCPlaced;
		else if (sid==8)
			countName = MGMUCReceived;
		else if (sid==9)
			countName = MGMUCMissed;
		if ([[[[voiceUser instance] unreadCounts] objectForKey:countName] intValue]!=0)
			[cell setBadge:[[[[voiceUser instance] unreadCounts] objectForKey:countName] stringValue]];
		else
			[cell setBadge:nil];
		return cell;
	} else if (theTableView==inboxTable) {
		if ([currentData count]<=[indexPath indexAtPosition:1]) {
			UITableViewCell *cell = [inboxesTable dequeueReusableCellWithIdentifier:MGMInboxMessageLoadCellIdentifier];
			if (cell==nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMInboxMessageLoadCellIdentifier] autorelease];
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
			MGMInboxMessageView *cell = (MGMInboxMessageView *)[inboxTable dequeueReusableCellWithIdentifier:MGMInboxMessageCellIdentifier];
			if (cell==nil) {
				cell = [[[MGMInboxMessageView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMInboxMessageCellIdentifier] autorelease];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				[cell setInstance:[voiceUser instance]];
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
	return (currentInbox==3 ? @"Delete Forever" : @"Delete");
}
- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *data = [currentData objectAtIndex:[indexPath indexAtPosition:1]];
	[self startProgress:MGMITDeleting];
	if (currentInbox==3)
		[[[voiceUser instance] inbox] deleteEntriesForever:[NSArray arrayWithObject:[data objectForKey:MGMIID]] delegate:self];
	else
		[[[voiceUser instance] inbox] deleteEntries:[NSArray arrayWithObject:[data objectForKey:MGMIID]] delegate:self];
}
- (void)delete:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"Delete Error: %@ for instance: %@", theError, theInstance);
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error deleting"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
	[self stopProgress];
}
- (void)deleteDidFinish:(MGMDelegateInfo *)theInfo instance:(MGMInstance *)theInstance {
	int dataCount = [currentData count]-1;
	for (int i=0; i<resultsCount; i++) {
		[currentData removeObjectAtIndex:dataCount-i];
	}
	[self loadInbox];
	[self stopProgress];
}
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (theTableView==inboxesTable) {
		currentInbox = [[[MGMInboxItems objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:MGMSID] intValue];
		[[voiceUser user] setSetting:[NSNumber numberWithInt:currentInbox] forKey:MGMSInbox];
		[[inboxItems objectAtIndex:0] setEnabled:NO];
		[[voiceUser accountController] setItems:inboxItems animated:YES];
		
		CGRect outViewFrame = [inboxesTable frame];
		CGRect inViewFrame = [inboxTable frame];
		inViewFrame.size = outViewFrame.size;
		inViewFrame.origin.x = +inViewFrame.size.width;
		[inboxTable setFrame:inViewFrame];
		[[voiceUser tabView] addSubview:inboxTable];
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
				[[[voiceUser instance] inbox] markEntries:[NSArray arrayWithObject:[data objectForKey:MGMIID]] read:![[data objectForKey:MGMIRead] boolValue] delegate:self];
				[data setObject:[NSNumber numberWithBool:![[data objectForKey:MGMIRead] boolValue]] forKey:MGMIRead];
				[currentData replaceObjectAtIndex:[indexPath indexAtPosition:1] withObject:data];
				[inboxTable reloadData];
			}
			int type = [[data objectForKey:MGMIType] intValue];
			if (type==MGMIVoicemailType || type==MGMIRecordedType) {
				[self setRecording:[indexPath indexAtPosition:1]];
			} else if (type==MGMISMSInType || type==MGMISMSOutType) {
				[[[voiceUser tabObjects] objectAtIndex:MGMVUSMSTabIndex] messageWithData:data instance:[voiceUser instance]];
			} else {
				[voiceUser showOptionsForNumber:[data objectForKey:MGMIPhoneNumber]];
				[inboxTable deselectRowAtIndexPath:[inboxTable indexPathForSelectedRow] animated:YES];
			}
		}
	}
}
- (void)inboxAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[inboxesTable removeFromSuperview];
	[inboxesTable deselectRowAtIndexPath:[inboxesTable indexPathForSelectedRow] animated:NO];
	[[inboxItems objectAtIndex:0] setEnabled:YES];
}

- (void)loadInbox {
	[lastUpdate release];
	lastUpdate = [NSDate new];
	[[voiceUser user] setSetting:lastUpdate forKey:MGMSLastUpdate];
	[[voiceUser user] setSetting:[NSNumber numberWithInt:start] forKey:MGMSStart];
	int page = (start/maxResults)+1;
	[self startProgress:MGMITLoading];
	switch (currentInbox) {
		case 0:
			[[[voiceUser instance] inbox] getInboxForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 1:
			[[[voiceUser instance] inbox] getStarredForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 2:
			[[[voiceUser instance] inbox] getSpamForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 3:
			[[[voiceUser instance] inbox] getTrashForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 4:
			[[[voiceUser instance] inbox] getVoicemailForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 5:
			[[[voiceUser instance] inbox] getSMSForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 6:
			[[[voiceUser instance] inbox] getRecordedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 7:
			[[[voiceUser instance] inbox] getPlacedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 8:
			[[[voiceUser instance] inbox] getReceivedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
		case 9:
			[[[voiceUser instance] inbox] getMissedCallsForPage:page delegate:self didFailWithError:@selector(inbox:didFailWithError:instance:) didReceiveInfo:@selector(inboxGotInfo:instance:)];
			break;
	}
}
- (void)inbox:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	NSLog(@"Inbox Error: %@ for instance: %@", theError, theInstance);
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error loading inbox"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
	[self stopProgress];
}
- (void)inboxGotInfo:(NSArray *)theInfo instance:(MGMInstance *)theInstance {
	if (theInfo!=nil)
		[self addData:theInfo];
	else
		NSLog(@"Error 234554: Hold on, this should never happen.");
	[self stopProgress];
}
- (void)addData:(NSArray *)theData {
	resultsCount = [theData count];
	[[voiceUser user] setSetting:[NSNumber numberWithInt:resultsCount] forKey:MGMSResultsCount];
	[currentData addObjectsFromArray:theData];
	[inboxTable reloadData];
}
- (int)currentInbox {
	return currentInbox;
}

- (void)setRecording:(int)theRecording {
	currentRecording = theRecording;
	if (currentRecording==-1)
		return;
	NSMutableDictionary *data = [currentData objectAtIndex:currentRecording];
	int type = [[data objectForKey:MGMIType] intValue];
	[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerLoading()"];
	NSString *transcript = @"";
	if (type==MGMIVoicemailType)
		transcript = [data objectForKey:MGMIText];
	[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setTranscription('%@')", [transcript javascriptEscape]]];
	
	[[recordingItems objectAtIndex:0] setEnabled:NO];
	[[voiceUser accountController] setItems:recordingItems animated:YES];
	
	if (recordingConnection==nil)
		recordingConnection = [[MGMURLConnectionManager managerWithCookieStorage:[[voiceUser instance] cookieStorage]] retain];
	MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:MGMIVoiceMailDownloadURL, [[data objectForKey:MGMIID] addPercentEscapes]]]] delegate:self];
	[recordingConnection addHandler:handler];
	
	CGRect outViewFrame = [inboxTable frame];
	CGRect inViewFrame = [recordingView frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = +inViewFrame.size.width;
	[recordingView setFrame:inViewFrame];
	[[voiceUser tabView] addSubview:recordingView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(recordingAnimationDidStop:finished:context:)];
	[recordingView setFrame:outViewFrame];
	outViewFrame.origin.x = -outViewFrame.size.width;
	[inboxTable setFrame:outViewFrame];
	[UIView commitAnimations];
	currentView = 2;
	[[voiceUser accountController] setTitle:[self title]];
}
- (void)recordingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[inboxTable removeFromSuperview];
	[inboxTable deselectRowAtIndexPath:[inboxTable indexPathForSelectedRow] animated:NO];
	[[recordingItems objectAtIndex:0] setEnabled:YES];
}

- (void)request:(MGMURLBasicHandler *)theHandler didFailWithError:(NSError *)theError {
	NSLog(@"Starting Audio Error: %@", theError);
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error loading audio"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
}
- (void)requestDidFinish:(MGMURLBasicHandler *)theHandler {
	recordingPlayer = [[AVAudioPlayer alloc] initWithData:[theHandler data] error:nil];
	[recordingPlayer setDelegate:self];
	if (recordingView!=nil) {
		[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setDurration(%d)", (int)[recordingPlayer duration]]];
		[recordingView stringByEvaluatingJavaScriptFromString:@"setCurrent(0)"];
		[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerPlaying()"];
		[recordingPlayer play];
		recordingUpdater = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecording) userInfo:nil repeats:YES] retain];
	}
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerPaused()"];
}
- (void)updateRecording {
	[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setCurrent(%d)", (int)[recordingPlayer currentTime]]];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
	NSString *scheme = [[url scheme] lowercaseString];
	NSString *data = [url resourceSpecifier];
	NSString *queryData = [url query];
	NSDictionary *query;
	if (queryData) {
		NSMutableArray *dataArr = [NSMutableArray arrayWithArray:[data componentsSeparatedByString:@"?"]];
		[dataArr removeLastObject];
		data = [dataArr componentsJoinedByString:@"?"];
		NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
		NSArray *parameters = [queryData componentsSeparatedByString:@"&"];
		for (int i=0; i<[parameters count]; i++) {
			NSArray *info = [[parameters objectAtIndex:i] componentsSeparatedByString:@"="];
			[dataDic setObject:[[[info subarrayWithRange:NSMakeRange(1, [info count]-1)] componentsJoinedByString:@"="] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[info objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		query = [NSDictionary dictionaryWithDictionary:dataDic];
	}
	if ([data hasPrefix:@"//"])
		data = [data substringFromIndex:2];
	
	if ([scheme isEqual:@"voicemob"]) {
		if ([data isEqual:@"pause"])
			[recordingPlayer pause];
		else if ([data isEqual:@"play"])
			[recordingPlayer play];
		else if ([data isEqual:@"start"])
			[recordingPlayer setCurrentTime:[[query objectForKey:@"time"] intValue]];
	} else if ([scheme isEqual:@"tel"]) {
		[voiceUser call:[data phoneFormatWithAreaCode:[voiceUser areaCode]]];
	} else if ([scheme isEqual:@"file"]) {
		return YES;
	} else {
		[[UIApplication sharedApplication] openURL:url];
	}
	return NO;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if (currentRecording!=-1) {
		if (recordingPlayer!=nil) {
			[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setDurration(%d)", (int)[recordingPlayer duration]]];
			[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setCurrent(%d)", (int)[recordingPlayer currentTime]]];
			[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerPlaying()"];
			[recordingPlayer play];
			recordingUpdater = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecording) userInfo:nil repeats:YES] retain];
		}
		
		NSMutableDictionary *data = [currentData objectAtIndex:currentRecording];
		int type = [[data objectForKey:MGMIType] intValue];
		NSString *transcript = @"";
		if (type==MGMIVoicemailType)
			transcript = [data objectForKey:MGMIText];
		[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setTranscription('%@')", [transcript javascriptEscape]]];
	}
}

- (IBAction)showInbox:(id)sender {
	[[inboxItems objectAtIndex:0] setEnabled:NO];
	[[voiceUser accountController] setItems:inboxItems animated:YES];
	
	[recordingPlayer release];
	recordingPlayer = nil;
	[recordingUpdater invalidate];
	[recordingUpdater release];
	recordingUpdater = nil;
	[recordingConnection cancelAll];
	[recordingConnection release];
	recordingConnection = nil;
	
	CGRect outViewFrame = [recordingView frame];
	CGRect inViewFrame = [inboxTable frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = -inViewFrame.size.width;
	[inboxTable setFrame:inViewFrame];
	[[voiceUser tabView] addSubview:inboxTable];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showInboxAnimationDidStop:finished:context:)];
	[inboxTable setFrame:outViewFrame];
	outViewFrame.origin.x = +outViewFrame.size.width;
	[recordingView setFrame:outViewFrame];
	[UIView commitAnimations];
	currentView = 1;
}
- (void)showInboxAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[recordingView removeFromSuperview];
	[[inboxItems objectAtIndex:0] setEnabled:YES];
	currentRecording = -1;
	[[voiceUser accountController] setTitle:[self title]];
}
@end