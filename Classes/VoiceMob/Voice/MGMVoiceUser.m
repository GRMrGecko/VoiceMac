//
//  MGMVoiceUser.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMVoiceUser.h"
#import "MGMVoicePad.h"
#import "MGMVoiceContacts.h"
#import "MGMVoiceSMS.h"
#import "MGMVoiceInbox.h"
#import "MGMProgressView.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

const int MGMVUKeypadTabIndex = 0;
const int MGMVUContactsTabIndex = 1;
const int MGMVUSMSTabIndex = 2;
const int MGMVUInboxTabIndex = 3;

NSString * const MGMVUCurrentTab = @"MGMVUCurrentTab";
NSString * const MGMLastUserPhoneKey = @"MGMLastUserPhone";

@implementation MGMVoiceUser
+ (id)voiceUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	return [[[self alloc] initWithUser:theUser accountController:theAccountController] autorelease];
}
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	if ((self = [super init])) {
		accountController = theAccountController;
		user = [theUser retain];
		[self registerSettings];
		
		if ([user isStarted]) {
			currentTab = [[user settingForKey:MGMVUCurrentTab] intValue];
			tabObjects = [NSMutableArray new];
			[tabObjects addObject:[MGMVoicePad tabWithVoiceUser:self]];
			[tabObjects addObject:[MGMVoiceContacts tabWithVoiceUser:self]];
			[tabObjects addObject:[MGMVoiceSMS tabWithVoiceUser:self]];
			[tabObjects addObject:[MGMVoiceInbox tabWithVoiceUser:self]];
			
			instance = [[MGMInstance instanceWithUser:user delegate:self] retain];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self releaseView];
	[tabObjects release];
	[callTimer invalidate];
	[callTimer release];
	[callCancelView release];
	[optionsNumber release];
	[instance stop];
	[instance release];
	[user release];
	[currentPhoneNumber release];
	[optionsNumber release];
	[super dealloc];
}

- (void)registerSettings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMLastUserPhoneKey];
	[settings setObject:[NSNumber numberWithInt:MGMVUKeypadTabIndex] forKey:MGMVUCurrentTab];
	[user registerSettings:settings];
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
				if (unreadCount!=0)
					[[[tabBar items] objectAtIndex:MGMVUInboxTabIndex] setBadgeValue:[[NSNumber numberWithInt:unreadCount] stringValue]];
				else
					[[[tabBar items] objectAtIndex:MGMVUInboxTabIndex] setBadgeValue:nil];
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
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[[tabObjects objectAtIndex:currentTab] releaseView];
	[view release];
	view = nil;
	[tabView release];
	tabView = nil;
	[tabBar release];
	tabBar = nil;
	[progressView stopProgess];
	[progressView release];
	progressView = nil;
}

- (void)loginError:(NSError *)theError {
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error logging in"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
	
	[verificationView release];
	verificationView = nil;
	[verificationField release];
	verificationField = nil;
	[progressView stopProgess];
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
}
- (void)loginVerificationRequested {
	[verificationView release];
	verificationView = [UIAlertView new];
	[verificationView setTitle:@"Account Verification"];
	[verificationView setMessage:@" "];
	[verificationView addButtonWithTitle:@"Cancel"];
	[verificationView addButtonWithTitle:@"Verify"];
	[verificationView setCancelButtonIndex:1];
	[verificationView setDelegate:self];
	[verificationField release];
	verificationField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
	[verificationField setBorderStyle:UITextBorderStyleLine];
	[verificationField setBackgroundColor:[UIColor whiteColor]];
	[verificationField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
	[verificationView addSubview:verificationField];
	[verificationView show];
	[verificationField becomeFirstResponder];
}
- (void)loginSuccessful {
	[verificationView release];
	verificationView = nil;
	[verificationField release];
	verificationField = nil;
	[progressView stopProgess];
	[progressView setNeedsDisplay];
	
	[self setInstanceInfo];
	
	if ([accountController isCurrent:self])
		[accountController setTitle:[self title]];
	
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
	[[tabObjects objectAtIndex:MGMVUKeypadTabIndex] updateInfo];
}
- (void)progressFadeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
}

- (void)becameActive {
	[instance checkPhones];
}
- (void)updatedUserPhones {
	[[tabObjects objectAtIndex:MGMVUKeypadTabIndex] updateInfo];
}

- (void)updatedContacts {
	[[tabObjects objectAtIndex:MGMVUContactsTabIndex] updatedContacts];
}
- (void)updateUnreadCount:(int)theCount {
	unreadCount = theCount;
	[accountController setBadge:unreadCount forInstance:instance];
	if (unreadCount!=0)
		[[[tabBar items] objectAtIndex:MGMVUInboxTabIndex] setBadgeValue:[[NSNumber numberWithInt:unreadCount] stringValue]];
	else
		[[[tabBar items] objectAtIndex:MGMVUInboxTabIndex] setBadgeValue:nil];
}
- (void)updateSMS {
	[[tabObjects objectAtIndex:MGMVUSMSTabIndex] checkSMSMessages];
}
- (void)updateVoicemail {
	[[tabObjects objectAtIndex:MGMVUInboxTabIndex] checkVoicemail];
}
- (void)updateCredit:(NSString *)theCredit {
	[[tabObjects objectAtIndex:MGMVUKeypadTabIndex] setCredit:theCredit];
}

- (BOOL)isPlacingCall {
	return (callTimer!=nil);
}
- (void)donePlacingCall {
	[callTimer fire];
}
- (NSString *)currentPhoneNumber {
	return currentPhoneNumber;
}
- (void)call:(NSString *)theNumber {
	if ([[instance userPhoneNumbers] count]<=0) {
		UIAlertView *alert = [[UIAlertView new] autorelease];
		[alert setTitle:@"Call Failed"];
		[alert setMessage:@"You need to have a phone number setup with your Google Voice account. To add one, visit voice.google.com and in the settings add a phone number. Once you got a phone number setup with Google Voice, reopen VoiceMob."];
		[alert addButtonWithTitle:MGMOkButtonTitle];
		[alert show];
		return;
	}
	
	[currentPhoneNumber release];
	currentPhoneNumber = [theNumber copy];
	placingCall = YES;
	callTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(callTimer) userInfo:nil repeats:NO] retain];
	[instance placeCall:theNumber usingPhone:[[user settingForKey:MGMLastUserPhoneKey] intValue] delegate:self];
	callCancelView = [UIAlertView new];
	[callCancelView setTitle:@"Placing Call"];
	[callCancelView addButtonWithTitle:@"Cancel Call"];
	[callCancelView setDelegate:self];
	[callCancelView show];
}
- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)theIndex {
	if (theAlertView==callCancelView) {
		[currentPhoneNumber release];
		currentPhoneNumber = nil;
		placingCall = NO;
		[callTimer invalidate];
		[callTimer release];
		callTimer = nil;
		[callCancelView release];
		callCancelView = nil;
		[instance cancelCallWithDelegate:self];	
	} else if (theAlertView==verificationView) {
		if (theIndex==1)
			[instance verifyWithCode:[verificationField text]];
		else
			[instance cancelVerification];
	}
}
- (void)call:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	[currentPhoneNumber release];
	currentPhoneNumber = nil;
	placingCall = NO;
	[callTimer fire];
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Call Failed"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
}
- (void)callDidFinish:(NSDictionary *)theInfo {
	[currentPhoneNumber release];
	currentPhoneNumber = nil;
	placingCall = NO;
	NSLog(@"YEA! We Made The Call!");
}
- (void)callCancel:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Call Cancel Failed"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
}
- (void)callTimer {
	[callTimer invalidate];
	[callTimer release];
	callTimer = nil;
	[callCancelView dismissWithClickedButtonIndex:0 animated:YES];
	[callCancelView release];
	callCancelView = nil;
}

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)theItem {
	int tabIndex = [[tabBar items] indexOfObject:theItem];
	if (tabIndex==currentTab)
		return;
	if (tabIndex!=MGMVUSMSTabIndex && tabIndex!=MGMVUInboxTabIndex) {
		[accountController setTitle:[self title]];
		[accountController setItems:[accountController accountItems] animated:YES];
	}
	
	id tab = [tabObjects objectAtIndex:currentTab];
	currentTab = tabIndex;
	[user setSetting:[NSNumber numberWithInt:currentTab] forKey:MGMVUCurrentTab];
	id newTab = [tabObjects objectAtIndex:currentTab];
	CGRect tabFrame = [[newTab view] frame];
	tabFrame.size = [tabView frame].size;
	[[newTab view] setFrame:tabFrame];
	[tabView addSubview:[newTab view]];
	[[tab view] removeFromSuperview];
	[tab releaseView];
}

- (void)showOptionsForNumber:(NSString *)theNumber {
	optionsNumber = [theNumber copy];
	UIActionSheet *theAction = [[UIActionSheet new] autorelease];
	[theAction addButtonWithTitle:@"Call"];
	[theAction addButtonWithTitle:@"SMS"];
	[theAction addButtonWithTitle:@"Reverse Lookup"];
	[theAction addButtonWithTitle:@"Cancel"];
	[theAction setCancelButtonIndex:3];
	[theAction setDelegate:self];
	[theAction showInView:view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex==0)
		[self call:optionsNumber];
	else if (buttonIndex==1)
		[[tabObjects objectAtIndex:MGMVUSMSTabIndex] messageWithNumber:optionsNumber instance:instance];
	else if (buttonIndex==2)
		[[accountController controller] showReverseLookupWithNumber:optionsNumber];
	[optionsNumber release];
	optionsNumber = nil;
}
@end