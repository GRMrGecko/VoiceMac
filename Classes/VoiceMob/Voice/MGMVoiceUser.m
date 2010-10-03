//
//  MGMVoiceUser.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVoiceUser.h"
#import "MGMVoicePad.h"
#import "MGMVoiceContacts.h"
#import "MGMVoiceSMS.h"
#import "MGMVoiceInbox.h"
#import "MGMProgressView.h"
#import "MGMAccountController.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

const int MGMKeypadTabIndex = 0;
const int MGMContactsTabIndex = 1;
const int MGMSMSTabIndex = 2;
const int MGMInboxTabIndex = 3;

@implementation MGMVoiceUser
+ (id)voiceUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	return [[[self alloc] initWithUser:theUser accountController:theAccountController] autorelease];
}
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	if (self = [super init]) {
		accountController = theAccountController;
		user = [theUser retain];
		
		currentTab = 0;
		tabObjects = [NSMutableArray new];
		[tabObjects addObject:[MGMVoicePad tabWithVoiceUser:self]];
		[tabObjects addObject:[MGMVoiceContacts tabWithVoiceUser:self]];
		[tabObjects addObject:[MGMVoiceSMS tabWithVoiceUser:self]];
		[tabObjects addObject:[MGMVoiceInbox tabWithVoiceUser:self]];
		
		if ([user isStarted])
			instance = [[MGMInstance instanceWithUser:user delegate:self] retain];
	}
	return self;
}
- (void)dealloc {
	[self releaseView];
	if (user!=nil)
		[user release];
	[super dealloc];
}

- (MGMAccountController *)accountController {
	return accountController;
}
- (MGMUser *)user {
	return user;
}
- (MGMInstance *)instance {
	return instance;
}
- (NSString *)title {
	if ([instance isLoggedIn])
		return [[instance userNumber] readableNumber];
	return [user settingForKey:MGMUserName];
}
- (NSString *)areaCode {
	if (![instance isLoggedIn])
		return nil;
	return [instance userAreaCode];
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoiceUser"] owner:self options:nil]) {
			NSLog(@"Unable to load Voice User");
			[self release];
			self = nil;
		} else {
			[tabView addSubview:[[tabObjects objectAtIndex:currentTab] view]];
			[tabBar setSelectedItem:[[tabBar items] objectAtIndex:currentTab]];
			if (![instance isLoggedIn]) {
				CGSize contentSize = [view frame].size;
				progressView = [[MGMProgressView alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
				[progressView setProgressTitle:@"Logging In"];
				[view addSubview:progressView];
				[progressView startProgess];
				[progressView becomeFirstResponder];
			} else {
				[self setInstanceInfo];
			}
		}
	}
	return view;
}
- (NSArray *)tabObjects {
	return tabObjects;
}
- (UIView *)tabView {
	return tabView;
}
- (UITabBar *)tabBar {
	return tabBar;
}
- (void)releaseView {
	if (view!=nil) {
		[view release];
		view = nil;
		[[tabObjects objectAtIndex:currentTab] releaseView];
	}
}

- (void)loginError:(NSError *)theError {
	UIAlertView *theAlert = [[UIAlertView new] autorelease];
	[theAlert setTitle:@"Error logging in"];
	[theAlert setMessage:[theError localizedDescription]];
	[theAlert addButtonWithTitle:MGMOkButtonTitle];
	[theAlert show];
	
	if (progressView!=nil) {
		[progressView stopProgess];
		[progressView removeFromSuperview];
		[progressView release];
		progressView = nil;
	}
}
- (void)loginSuccessful {
	if (progressView!=nil) {
		[progressView stopProgess];
		[progressView setNeedsDisplay];
	}
	
	[self setInstanceInfo];
	
	if ([accountController isCurrent:self])
		[accountController setTitle:[[instance userNumber] readableNumber]];
	
	if (progressView!=nil) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(progressFadeAnimationDidStop:finished:context:)];
		[progressView setAlpha:0.0];
		[UIView commitAnimations];
	}
}
- (void)setInstanceInfo {
	
}
- (void)progressFadeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (progressView!=nil) {
		[progressView removeFromSuperview];
		[progressView release];
		progressView = nil;
	}
}

- (void)updatedContacts {
	[[tabObjects objectAtIndex:MGMContactsTabIndex] updatedContacts];
}
- (void)updateSMS {
	[[tabObjects objectAtIndex:MGMSMSTabIndex] checkSMSMessages];
}

- (BOOL)isPlacingCall {
	return (callTimer!=nil);
}
- (void)call:(NSString *)theNumber {
	placingCall = YES;
	callTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(callTimer) userInfo:nil repeats:NO] retain];
	[instance placeCall:theNumber usingPhone:0 delegate:self];
	callCancelView = [UIAlertView new];
	[callCancelView setTitle:@"Placing Call"];
	[callCancelView addButtonWithTitle:@"Cancel Call"];
	[callCancelView setDelegate:self];
	[callCancelView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView==callCancelView) {
		if (callTimer!=nil) {
			[callTimer invalidate];
			[callTimer release];
			callTimer = nil;
		}
		[callCancelView release];
		callCancelView = nil;
		[instance cancelCallWithDelegate:self];	
	}
}
- (void)call:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	placingCall = NO;
	if (callTimer!=nil)
		[callTimer fire];
	UIAlertView *theAlert = [[UIAlertView new] autorelease];
	[theAlert setTitle:@"Call Failed"];
	[theAlert setMessage:[theError localizedDescription]];
	[theAlert addButtonWithTitle:MGMOkButtonTitle];
	[theAlert show];
}
- (void)callDidFinish:(NSDictionary *)theInfo {
	placingCall = NO;
	NSLog(@"YEA! We Made The Call!");
}
- (void)callCancel:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	UIAlertView *theAlert = [[UIAlertView new] autorelease];
	[theAlert setTitle:@"Call Cancel Failed"];
	[theAlert setMessage:[theError localizedDescription]];
	[theAlert addButtonWithTitle:MGMOkButtonTitle];
	[theAlert show];
}
- (void)callTimer {
	if (callTimer!=nil) {
		[callTimer invalidate];
		[callTimer release];
		callTimer = nil;
	}
	[callCancelView dismissWithClickedButtonIndex:0 animated:YES];
	[callCancelView release];
	callCancelView = nil;
}

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item {
	int tabIndex = [[tabBar items] indexOfObject:item];
	if (tabIndex==currentTab)
		return;
	if (tabIndex!=MGMSMSTabIndex && tabIndex!=MGMInboxTabIndex)
		[accountController setItems:[accountController accountItems] animated:YES];
	
	id tab = [tabObjects objectAtIndex:currentTab];
	currentTab = tabIndex;
	id newTab = [tabObjects objectAtIndex:currentTab];
	[tabView addSubview:[newTab view]];
	[[tab view] removeFromSuperview];
	[tab releaseView];
}
@end