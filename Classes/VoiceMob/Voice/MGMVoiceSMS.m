//
//  MGMVoiceSMS.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVoiceSMS.h"
#import "MGMVoiceUser.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMSMSTextView.h"
#import "MGMInboxMessageView.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>

NSString * const MGMMessageViewText = @"MGMMessageViewText";
NSString * const MGMKeyboardBounds = @"UIKeyboardBoundsUserInfoKey";

NSString * const MGMMessageCellIdentifier = @"MGMMessageCellIdentifier";

const float updateTimeInterval = 300.0;

@implementation MGMVoiceSMS
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	return [[[self alloc] initWithVoiceUser:theVoiceUser] autorelease];
}
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	if (self = [super init]) {
		voiceUser = theVoiceUser;
		
		messageItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:@"Messages" style:UIBarButtonItemStyleBordered target:self action:@selector(showMessages:)] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease], [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:[voiceUser accountController] action:@selector(showSettings:)] autorelease], nil] retain];
		
		SMSMessages = [NSMutableArray new];
		currentSMSMessage = -1;
		updateTimer = [[NSTimer scheduledTimerWithTimeInterval:updateTimeInterval target:self selector:@selector(update) userInfo:nil repeats:YES] retain];
	}
	return self;
}
- (void)dealloc {
	[self releaseView];
	[super dealloc];
}

- (MGMVoiceUser *)voiceUser {
	return voiceUser;
}
- (MGMThemeManager *)themeManager {
	return [[[voiceUser accountController] controller] themeManager];
}

- (UIView *)view {
	if (messageView==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoiceSMS"] owner:self options:nil]) {
			NSLog(@"Unable to load Voice SMS");
			[self release];
			self = nil;
		} else {
			[SMSTextCountField setHidden:YES];
			[SMSView setDelegate:self];
			if (currentSMSMessage!=-1) {
				if ([[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]!=nil)
					[SMSTextView setText:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]];
				[self buildHTML];
				[[voiceUser accountController] setItems:messageItems animated:YES];
			} else {
				[[voiceUser accountController] setItems:[[voiceUser accountController] accountItems] animated:YES];
			}
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		}
	}
	if (currentSMSMessage!=-1)
		return messageView;
	return messagesTable;
}
- (void)releaseView {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (messagesTable!=nil) {
		[messagesTable release];
		messagesTable = nil;
	}
	if (messageView!=nil) {
		if (currentSMSMessage!=-1) {
			NSMutableDictionary *messageInfo = [[SMSMessages objectAtIndex:currentSMSMessage] mutableCopy];
			[messageInfo setObject:[SMSTextView text] forKey:MGMMessageViewText];
			[SMSMessages replaceObjectAtIndex:currentSMSMessage withObject:messageInfo];
			[messageInfo release];	
		}
		[messageView release];
		messageView = nil;
		SMSView = nil;
		SMSBottomView = nil;
		SMSTextView = nil;
		SMSTextCountField = nil;
	}
}


- (void)update {
	if ([SMSMessages count]>0)
		[self checkSMSMessages];
}

- (void)checkSMSMessages {
	[[[voiceUser instance] inbox] getSMSForPage:1 delegate:self];
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
		if (lastDate==nil || (![lastDate isEqual:[[theMessages objectAtIndex:i] objectForKey:MGMITime]] && [lastDate earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==lastDate)) {
			NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithDictionary:[theMessages objectAtIndex:i]];
			[messageInfo setObject:[[theInstance contacts] nameForNumber:[messageInfo objectForKey:MGMIPhoneNumber]] forKey:MGMTInName];
			[messageInfo setObject:[theInstance userNumber] forKey:MGMTUserNumber];
			BOOL tab = NO;
			for (unsigned int m=0; m<[SMSMessages count]; m++) {
				if ([[[SMSMessages objectAtIndex:m] objectForKey:MGMIPhoneNumber] isEqual:[messageInfo objectForKey:MGMIPhoneNumber]] && ([[[SMSMessages objectAtIndex:m] objectForKey:MGMIID] isEqual:[messageInfo objectForKey:MGMIID]] || [[[SMSMessages objectAtIndex:m] objectForKey:MGMIID] isEqual:@""])) {
					tab = YES;
					if ([self updateMessage:m messageInfo:messageInfo])
						newMessage = YES;
					break;
				}
			}
			if (![[[theMessages objectAtIndex:i] objectForKey:MGMIRead] boolValue]) {
				newMessage = YES;
				if (!tab) {
					newTab = YES;
					[SMSMessages addObject:messageInfo];
				}
			}
			if ([newestDate earlierDate:[[theMessages objectAtIndex:i] objectForKey:MGMITime]]==newestDate)
				newestDate = [[theMessages objectAtIndex:i] objectForKey:MGMITime];
		}
	}
	if (newMessage) {
		if (lastDate!=nil) [lastDate release];
		lastDate = [newestDate copy];
		[[self themeManager] playSound:MGMTSSMSMessage];
		if (currentSMSMessage==-1 && messagesTable!=nil)
			[messagesTable reloadData];
	}
}
- (void)messageWithNumber:(NSString *)theNumber instance:(MGMInstance *)theInstance {
	if (currentSMSMessage!=-1 && SMSTextView!=nil) {
		NSMutableDictionary *messageInfo = [[SMSMessages objectAtIndex:currentSMSMessage] mutableCopy];
		[messageInfo setObject:[SMSTextView text] forKey:MGMMessageViewText];
		[SMSMessages replaceObjectAtIndex:currentSMSMessage withObject:messageInfo];
		[messageInfo release];
		[SMSTextView setText:@""];
		[self textViewDidChange:SMSTextView];
		currentSMSMessage = -1;
		[SMSView loadHTMLString:@"" baseURL:nil];
	}
	[self view];
	NSMutableDictionary *messageInfo = [NSMutableDictionary dictionary];
	[messageInfo setObject:[NSArray array] forKey:MGMIMessages];
	[messageInfo setObject:[NSNumber numberWithInt:MGMISMSOut] forKey:MGMIType];
	[messageInfo setObject:[NSDate date] forKey:MGMITime];
	[messageInfo setObject:[[theInstance contacts] nameForNumber:theNumber] forKey:MGMTInName];
	[messageInfo setObject:theNumber forKey:MGMIPhoneNumber];
	[messageInfo setObject:[theInstance userNumber] forKey:MGMTUserNumber];
	[messageInfo setObject:@"" forKey:MGMIID];
	[messageInfo setObject:[NSNumber numberWithBool:YES] forKey:MGMIRead];
	BOOL window = NO;
	for (unsigned int m=0; m<[SMSMessages count]; m++) {
		if ([[[SMSMessages objectAtIndex:m] objectForKey:MGMIPhoneNumber] isEqual:[messageInfo objectForKey:MGMIPhoneNumber]] && [[[SMSMessages objectAtIndex:m] objectForKey:MGMIID] isEqual:@""]) {
			window = YES;
			currentSMSMessage = m;
			if ([[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]!=nil)
				[SMSTextView setText:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]];		
			[self buildHTML];
			UITabBarItem *thisTab = [[[voiceUser tabBar] items] objectAtIndex:MGMSMSTabIndex];
			[[voiceUser tabBar] setSelectedItem:thisTab];
			[voiceUser tabBar:[voiceUser tabBar] didSelectItem:thisTab];
			[[voiceUser tabView] addSubview:messageView];
			[messagesTable removeFromSuperview];
			break;
		}
	}
	if (!window) {
		[SMSMessages addObject:messageInfo];
		[messagesTable reloadData];
		currentSMSMessage = [SMSMessages count]-1;
		if ([[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]!=nil)
			[SMSTextView setText:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]];		
		[self buildHTML];
		UITabBarItem *thisTab = [[[voiceUser tabBar] items] objectAtIndex:MGMSMSTabIndex];
		[[voiceUser tabBar] setSelectedItem:thisTab];
		[voiceUser tabBar:[voiceUser tabBar] didSelectItem:thisTab];
		[[voiceUser tabView] addSubview:messageView];
		[messagesTable removeFromSuperview];
	}
	[[voiceUser accountController] setItems:messageItems animated:YES];
}
- (void)messageWithData:(NSDictionary *)theData instance:(MGMInstance *)theInstance {
	if (currentSMSMessage!=-1 && SMSTextView!=nil) {
		NSMutableDictionary *messageInfo = [[SMSMessages objectAtIndex:currentSMSMessage] mutableCopy];
		[messageInfo setObject:[SMSTextView text] forKey:MGMMessageViewText];
		[SMSMessages replaceObjectAtIndex:currentSMSMessage withObject:messageInfo];
		[messageInfo release];
		[SMSTextView setText:@""];
		[self textViewDidChange:SMSTextView];
		currentSMSMessage = -1;
		[SMSView loadHTMLString:@"" baseURL:nil];
	}
	[self view];
	NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithDictionary:theData];
	[messageInfo setObject:[[theInstance contacts] nameForNumber:[messageInfo objectForKey:MGMIPhoneNumber]] forKey:MGMTInName];
	[messageInfo setObject:[theInstance userNumber] forKey:MGMTUserNumber];
	BOOL window = NO;
	for (unsigned int m=0; m<[SMSMessages count]; m++) {
		if ([[[SMSMessages objectAtIndex:m] objectForKey:MGMIPhoneNumber] isEqual:[messageInfo objectForKey:MGMIPhoneNumber]] && ([[[SMSMessages objectAtIndex:m] objectForKey:MGMIID] isEqual:[messageInfo objectForKey:MGMIID]] || [[[SMSMessages objectAtIndex:m] objectForKey:MGMIID] isEqual:@""])) {
			window = YES;
			[self updateMessage:m messageInfo:messageInfo];
			currentSMSMessage = m;
			if ([[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]!=nil)
				[SMSTextView setText:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]];		
			[self buildHTML];
			UITabBarItem *thisTab = [[[voiceUser tabBar] items] objectAtIndex:MGMSMSTabIndex];
			[[voiceUser tabBar] setSelectedItem:thisTab];
			[voiceUser tabBar:[voiceUser tabBar] didSelectItem:thisTab];
			[[voiceUser tabView] addSubview:messageView];
			[messagesTable removeFromSuperview];
			break;
		}
	}
	if (!window) {
		[SMSMessages addObject:messageInfo];
		[messagesTable reloadData];
		currentSMSMessage = [SMSMessages count]-1;
		if ([[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]!=nil)
			[SMSTextView setText:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]];		
		[self buildHTML];
		UITabBarItem *thisTab = [[[voiceUser tabBar] items] objectAtIndex:MGMSMSTabIndex];
		[[voiceUser tabBar] setSelectedItem:thisTab];
		[voiceUser tabBar:[voiceUser tabBar] didSelectItem:thisTab];
		[[voiceUser tabView] addSubview:messageView];
		[messagesTable removeFromSuperview];
	}
	[[voiceUser accountController] setItems:messageItems animated:YES];
}

- (IBAction)showMessages:(id)sender {
	if (sendingMessage) {
		UIAlertView *theAlert = [[UIAlertView new] autorelease];
		[theAlert setTitle:@"Sending a SMS Message"];
		[theAlert setMessage:@"Your SMS Message is currently being sent, please wait for it to be sent."];
		[theAlert addButtonWithTitle:MGMOkButtonTitle];
		[theAlert show];
	} else if (marking) {
		
	} else if (![[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMIRead] boolValue]) {
		marking = YES;
		[[[voiceUser instance] inbox] markEntries:[NSArray arrayWithObject:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMIID]] read:YES delegate:self];
	} else {
		[messagesTable reloadData];
		CGRect inViewFrame = [messagesTable frame];
		inViewFrame.origin.x = -inViewFrame.size.width;
		[messagesTable setFrame:inViewFrame];
		[[voiceUser tabView] addSubview:messagesTable];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(messagesAnimationDidStop:finished:context:)];
		[messagesTable setFrame:[messageView frame]];
		CGRect outViewFrame = [messageView frame];
		outViewFrame.origin.x = +outViewFrame.size.width;
		[messageView setFrame:outViewFrame];
		[UIView commitAnimations];
		[[voiceUser accountController] setItems:[[voiceUser accountController] accountItems] animated:YES];
	}
}
- (void)mark:(NSDictionary *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	marking = NO;
	UIAlertView *theAlert = [[UIAlertView new] autorelease];
	[theAlert setTitle:@"Error marking as read"];
	[theAlert setMessage:[theError localizedDescription]];
	[theAlert addButtonWithTitle:MGMOkButtonTitle];
	[theAlert show];
}
- (void)markDidFinish:(NSDictionary *)theInfo instance:(MGMInstance *)theInstance {
	marking = NO;
	[self setMessage:currentSMSMessage read:YES];
	[self showMessages:self];
}
- (void)messagesAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[messageView removeFromSuperview];
	NSMutableDictionary *messageInfo = [[SMSMessages objectAtIndex:currentSMSMessage] mutableCopy];
	[messageInfo setObject:[SMSTextView text] forKey:MGMMessageViewText];
	[SMSMessages replaceObjectAtIndex:currentSMSMessage withObject:messageInfo];
	[messageInfo release];
	[SMSTextView setText:@""];
	[self textViewDidChange:SMSTextView];
	currentSMSMessage = -1;
	[SMSView loadHTMLString:@"" baseURL:nil];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [SMSMessages count];
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MGMInboxMessageView *cell = (MGMInboxMessageView *)[messagesTable dequeueReusableCellWithIdentifier:MGMMessageCellIdentifier];
	if (cell==nil) {
		cell = [[[MGMInboxMessageView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMMessageCellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[cell setInstance:[voiceUser instance]];
	}
	[cell setMessageData:[SMSMessages objectAtIndex:[indexPath indexAtPosition:1]]];
	return cell;
}
- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)theTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)theTableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Close";
}
- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[SMSMessages removeObjectAtIndex:[indexPath indexAtPosition:1]];
	[messagesTable reloadData];
}
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	currentSMSMessage = [indexPath indexAtPosition:1];
	if ([[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]!=nil)
		[SMSTextView setText:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMMessageViewText]];
	[self buildHTML];
	[[messageItems objectAtIndex:0] setEnabled:NO];
	[[voiceUser accountController] setItems:messageItems animated:YES];
	
	CGRect inViewFrame = [messageView frame];
	inViewFrame.origin.x = +inViewFrame.size.width;
	[messageView setFrame:inViewFrame];
	[[voiceUser tabView] addSubview:messageView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(messageAnimationDidStop:finished:context:)];
	[messageView setFrame:[messagesTable frame]];
	CGRect outViewFrame = [messagesTable frame];
	outViewFrame.origin.x = -outViewFrame.size.width;
	[messagesTable setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)messageAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[messagesTable removeFromSuperview];
	[messagesTable deselectRowAtIndexPath:[messagesTable indexPathForSelectedRow] animated:NO];
	[[messageItems objectAtIndex:0] setEnabled:YES];
}

- (void)setMessage:(int)theMessage read:(BOOL)isRead {
	NSMutableDictionary *messageInfo = [[SMSMessages objectAtIndex:theMessage] mutableCopy];
	[messageInfo setObject:[NSNumber numberWithBool:isRead] forKey:MGMIRead];
	[SMSMessages replaceObjectAtIndex:theMessage withObject:messageInfo];
	[messageInfo release];
}

- (BOOL)updateMessage:(int)theMessage messageInfo:(NSDictionary *)theMessageInfo {
	BOOL newIncomingMessages = NO;
	NSMutableDictionary *messageInfo = [[SMSMessages objectAtIndex:theMessage] mutableCopy];
	if (![[theMessageInfo objectForKey:MGMITime] isEqual:[messageInfo objectForKey:MGMITime]]) {
		NSMutableDictionary *inMessageInfo = [theMessageInfo mutableCopy];
		[inMessageInfo removeObjectForKey:MGMIMessages];
		[messageInfo addEntriesFromDictionary:inMessageInfo];
		[inMessageInfo release];
		[self setMessage:theMessage read:[[messageInfo objectForKey:MGMIRead] boolValue]];
		NSArray *theMessages = [theMessageInfo objectForKey:MGMIMessages];
		
		if (theMessage!=currentSMSMessage) {
			[messageInfo setObject:theMessages forKey:MGMIMessages];
			[SMSMessages replaceObjectAtIndex:theMessage withObject:messageInfo];
		} else {
			NSMutableArray *messages = [[messageInfo objectForKey:MGMIMessages] mutableCopy];
			BOOL rebuild = [[[[self themeManager] variant] objectForKey:MGMTRebuild] boolValue];
			BOOL newMessages = NO;
			for (unsigned int i=[messages count]; i<[theMessages count]; i++) {
				newMessages = YES;
				[messages addObject:[theMessages objectAtIndex:i]];
				
				if (![[[theMessages objectAtIndex:i] objectForKey:MGMIYou] boolValue])
					newIncomingMessages = YES;
				if (!rebuild) {
					[messageInfo setObject:messages forKey:MGMIMessages];
					[self addMessage:[messages lastObject] withInfo:messageInfo];
				}
			}
			if (rebuild)
				[messageInfo setObject:messages forKey:MGMIMessages];
			[messages release];
			
			[SMSMessages replaceObjectAtIndex:theMessage withObject:messageInfo];
			
			if (newMessages && rebuild) {
				NSLog(@"Rebuilding HTML!");
				[self buildHTML];
			}
		}
	}
	[messageInfo release];
	return newIncomingMessages;
}

- (void)keyboardWillShow:(NSNotification *)theNotification {
	CGSize keyboardSize = CGSizeZero;
	if ([[theNotification userInfo] objectForKey:MGMKeyboardBounds]!=nil)
		keyboardSize = [[[theNotification userInfo] objectForKey:MGMKeyboardBounds] CGRectValue].size;
	else
		keyboardSize = [[[theNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	keyboardSize.height -= 49.0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1358];
	[UIView setAnimationDelay:0.1642];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect SMSBottomFrame = [SMSBottomView frame];
	SMSBottomFrame.origin.y -= keyboardSize.height;
	[SMSBottomView setFrame:SMSBottomFrame];
	CGRect SMSViewFrame = [SMSView frame];
	SMSViewFrame.size.height -= keyboardSize.height;
	SMSViewStartFrame = SMSViewFrame;
	[SMSView setFrame:SMSViewFrame];
	UIScrollView *SMSScrollView = [[SMSView subviews] objectAtIndex:0];
	[SMSScrollView setContentInset:UIEdgeInsetsZero];
	[SMSScrollView setScrollIndicatorInsets:UIEdgeInsetsZero];
	[SMSScrollView scrollRectToVisible:CGRectMake(0, [SMSScrollView contentSize].height-44, 320, 44) animated:YES];
	[UIView commitAnimations];
}
- (void)textViewDidChange:(UITextView *)textView {
	CGFloat newHeight = [SMSTextView contentSize].height+3;
	if ([SMSTextView contentSize].height<40.0 || [SMSTextView contentSize].height<=55.0)
		newHeight = 40.0;
	if (newHeight>124.0)
		newHeight = 124.0;
	if (newHeight!=[SMSBottomView frame].size.height) {
		if (newHeight==40.0)
			[SMSTextCountField setHidden:YES];
		else
			[SMSTextCountField setHidden:NO];
		CGRect SMSBottomFrame = [SMSBottomView frame];
		CGFloat heightDifference = SMSBottomFrame.size.height-newHeight;
		SMSBottomFrame.origin.y += heightDifference;
		SMSBottomFrame.size.height = newHeight;
		[SMSBottomView setFrame:SMSBottomFrame];
		CGRect SMSViewFrame = [SMSView frame];
		SMSViewFrame.size.height = ([messageView frame].size.height-SMSBottomFrame.size.height)-(heightDifference<0 ? 166 : 167);
		[SMSView setFrame:SMSViewFrame];
		UIScrollView *SMSScrollView = [[SMSView subviews] objectAtIndex:0];
		[SMSScrollView setContentInset:UIEdgeInsetsZero];
		[SMSScrollView setScrollIndicatorInsets:UIEdgeInsetsZero];
		if (heightDifference<0) {
			[SMSScrollView scrollRectToVisible:CGRectMake(0, [SMSScrollView contentSize].height-44, 320, 44) animated:NO];
		}
	}
	if (![SMSTextCountField isHidden])
		[SMSTextCountField setText:[[NSNumber numberWithInt:160-[[SMSTextView text] length]] stringValue]];
}
- (void)keyboardWillHide:(NSNotification *)theNotification {
	CGSize keyboardSize = CGSizeZero;
	if ([[theNotification userInfo] objectForKey:MGMKeyboardBounds]!=nil)
		keyboardSize = [[[theNotification userInfo] objectForKey:MGMKeyboardBounds] CGRectValue].size;
	else
		keyboardSize = [[[theNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	keyboardSize.height -= 49.0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.256];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect SMSBottomFrame = [SMSBottomView frame];
	SMSBottomFrame.origin.y += keyboardSize.height;
	[SMSBottomView setFrame:SMSBottomFrame];
	CGRect SMSViewFrame = [SMSView frame];
	CGFloat SMSViewHeightDifference = SMSViewFrame.size.height-SMSViewStartFrame.size.height;
	SMSViewFrame.size.height += keyboardSize.height;
	[SMSView setFrame:SMSViewFrame];
	UIScrollView *SMSScrollView = [[SMSView subviews] objectAtIndex:0];
	UIEdgeInsets SMSScrollContentInset = [SMSScrollView contentInset];
	SMSScrollContentInset.bottom += (keyboardSize.height-SMSBottomFrame.size.height)-SMSViewHeightDifference;
	[SMSScrollView setContentInset:SMSScrollContentInset];
	UIEdgeInsets SMSScrollInset = [SMSScrollView scrollIndicatorInsets];
	SMSScrollInset.bottom += (keyboardSize.height-SMSBottomFrame.size.height)-SMSViewHeightDifference;
	[SMSScrollView setScrollIndicatorInsets:SMSScrollContentInset];
	[SMSScrollView scrollRectToVisible:CGRectMake(0, [SMSScrollView contentSize].height-44, 320, 44) animated:YES];
	[UIView commitAnimations];
}

- (void)buildHTML {
	NSDictionary *messageInfo = [SMSMessages objectAtIndex:currentSMSMessage];
	NSString *yPhotoPath = [[[voiceUser instance] contacts] cachedPhotoForNumber:[messageInfo objectForKey:MGMTUserNumber]];
	if (yPhotoPath==nil)
		yPhotoPath = [[[self themeManager] outgoingIconPath] filePath];
	NSString *tPhotoPath = [[[voiceUser instance] contacts] cachedPhotoForNumber:[messageInfo objectForKey:MGMIPhoneNumber]];
	if (tPhotoPath==nil)
		tPhotoPath = [[[self themeManager] incomingIconPath] filePath];
	NSArray *messages = [messageInfo objectForKey:MGMIMessages];
	NSMutableArray *messageArray = [NSMutableArray array];
	for (unsigned int i=0; i<[messages count]; i++) {
		NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:[messages objectAtIndex:i]];
		[message setObject:[[NSNumber numberWithInt:i] stringValue] forKey:MGMIID];
		if ([[message objectForKey:MGMIYou] boolValue]) {
			[message setObject:yPhotoPath forKey:MGMTPhoto];
			[message setObject:NSFullUserName() forKey:MGMTName];
			[message setObject:[messageInfo objectForKey:MGMTUserNumber] forKey:MGMIPhoneNumber];
		} else {
			[message setObject:tPhotoPath forKey:MGMTPhoto];
			[message setObject:[messageInfo objectForKey:MGMTInName] forKey:MGMTName];
			[message setObject:[messageInfo objectForKey:MGMIPhoneNumber] forKey:MGMIPhoneNumber];
		}
		[messageArray addObject:message];
	}NSString *html = [[self themeManager] buildHTMLWithMessages:messageArray messageInfo:messageInfo];
	[SMSView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[self themeManager] currentThemeVariantPath]]];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}
- (void)addMessage:(NSDictionary *)theMessage withInfo:(NSMutableDictionary *)theMessageInfo {
	NSArray *messages = [theMessageInfo objectForKey:MGMIMessage];
	NSString *yPhotoPath = [[[voiceUser instance] contacts] cachedPhotoForNumber:[theMessageInfo objectForKey:MGMTUserNumber]];
	if (yPhotoPath==nil)
		yPhotoPath = [[[self themeManager] outgoingIconPath] filePath];
	NSString *tPhotoPath = [[[voiceUser instance] contacts] cachedPhotoForNumber:[theMessageInfo objectForKey:MGMIPhoneNumber]];
	if (tPhotoPath==nil)
		tPhotoPath = [[[self themeManager] incomingIconPath] filePath];
	NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:theMessage];
	[message setObject:[[NSNumber numberWithInt:[messages count]-1] stringValue] forKey:MGMIID];
	int type = 1;
	if ([[message objectForKey:MGMIYou] boolValue]) {
		type = (([[message objectForKey:MGMIID] intValue]==0 || ![[[messages objectAtIndex:[[message objectForKey:MGMIID] intValue]-1] objectForKey:MGMIYou] boolValue]) ? 1 : 2);
		[message setObject:yPhotoPath forKey:MGMTPhoto];
		[message setObject:NSFullUserName() forKey:MGMTName];
		[message setObject:[theMessageInfo objectForKey:MGMTUserNumber] forKey:MGMIPhoneNumber];
	} else {
		type = (([[message objectForKey:MGMIID] intValue]==0 || [[[messages objectAtIndex:[[message objectForKey:MGMIID] intValue]-1] objectForKey:MGMIYou] boolValue]) ? 3 : 4);
		[message setObject:tPhotoPath forKey:MGMTPhoto];
		[message setObject:[theMessageInfo objectForKey:MGMTInName] forKey:MGMTName];
		[message setObject:[theMessageInfo objectForKey:MGMIPhoneNumber] forKey:MGMIPhoneNumber];
	}
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:[[[self themeManager] variant] objectForKey:MGMTDate]];
	[SMSView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"newMessage('%@', '%@', '%@', %@, '%@', '%@', '%@', %d);", [[message objectForKey:MGMIText] escapeSMS], [[message objectForKey:MGMTPhoto] escapeSMS], [[message objectForKey:MGMITime] escapeSMS], [message objectForKey:MGMIID], [[message objectForKey:MGMTName] escapeSMS], [[[message objectForKey:MGMIPhoneNumber] readableNumber] escapeSMS], [formatter stringFromDate:[theMessageInfo objectForKey:MGMITime]], type]];
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}

- (IBAction)sendMessage:(id)sender {
	if ([[SMSTextView text] isEqual:@""])
		return;
	sendingMessage = YES;
	[SMSSendButton setEnabled:NO];
	[[[voiceUser instance] inbox] sendMessage:[SMSTextView text] phoneNumbers:[NSArray arrayWithObject:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMIPhoneNumber]] smsID:[[SMSMessages objectAtIndex:currentSMSMessage] objectForKey:MGMIID] delegate:self];
	[SMSTextView setText:@""];
	[self textViewDidChange:SMSTextView];
}
- (void)message:(NSDictionary *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	sendingMessage = NO;
	[SMSSendButton setEnabled:YES];
	[SMSTextView setText:[[theInfo objectForKey:MGMIMessage] stringByAppendingFormat:@" %@", [SMSTextView text]]];
	[self textViewDidChange:SMSTextView];
	[SMSTextView becomeFirstResponder];
	UIAlertView *theAlert = [[UIAlertView new] autorelease];
	[theAlert setTitle:@"Error sending a SMS Message"];
	[theAlert setMessage:[theError localizedDescription]];
	[theAlert addButtonWithTitle:MGMOkButtonTitle];
	[theAlert show];
}
- (void)messageDidFinish:(NSDictionary *)theInfo instance:(MGMInstance *)theInstance {
	sendingMessage = NO;
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:@"h:mm a"];
	NSMutableDictionary *messageInfo = [[SMSMessages objectAtIndex:currentSMSMessage] mutableCopy];
	NSMutableArray *messages = [[messageInfo objectForKey:MGMIMessages] mutableCopy];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[theInfo objectForKey:MGMIMessage], MGMIText, [formatter stringFromDate:[NSDate date]], MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil];
	[messages addObject:message];
	[messageInfo setObject:messages forKey:MGMIMessages];
	[messageInfo setObject:[NSDate date] forKey:MGMITime];
	[SMSMessages replaceObjectAtIndex:currentSMSMessage withObject:messageInfo];
	if ([[[[self themeManager] variant] objectForKey:MGMTRebuild] boolValue]) {
		[self buildHTML];
	} else {
		[self addMessage:message withInfo:messageInfo];
	}
	[messages release];
	[messageInfo release];
	[SMSSendButton setEnabled:YES];
	[SMSTextView becomeFirstResponder];
	[self setMessage:currentSMSMessage read:YES];
}

- (BOOL)shouldClose {
	return (!sendingMessage);
}
@end