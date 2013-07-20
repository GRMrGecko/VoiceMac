//
//  MGMSIPUser.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIPUser.h"
#import "MGMSIPCallView.h"
#import "MGMSIPPad.h"
#import "MGMSIPContacts.h"
#import "MGMSIPInbox.h"
#import "MGMSIPRecordings.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMVoiceUser.h"
#import "MGMProgressView.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

const int MGMSIPKeypadTabIndex = 0;
const int MGMSIPContactsTabIndex = 1;
const int MGMSIPInboxTabIndex = 2;
const int MGMSIPRecordingsTabIndex = 3;

NSString * const MGMSIPUserAreaCode = @"MGMVSIPUserAreaCode";
NSString * const MGMSIPCurrentTab = @"MGMSIPCurrentTab";

@implementation MGMSIPUser
+ (id)SIPUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	return [[[self alloc] initWithUser:theUser accountController:theAccountController] autorelease];
}
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	if ((self = [super init])) {
		accountController = theAccountController;
		user = [theUser retain];
		[self registerSettings];
		
		if ([user isStarted]) {
			account = [[MGMSIPAccount alloc] initWithSettings:[user settings]];
			[account setDelegate:self];
			calls = [NSMutableArray new];
			loggingIn = NO;
			acountRegistered = NO;
			contacts = [[MGMContacts contactsWithClass:NSClassFromString([user settingForKey:MGMSContactsSourceKey]) delegate:self] retain];
			[contacts updateContacts];
			
			currentTab = [[user settingForKey:MGMSIPCurrentTab] intValue];
			tabObjects = [NSMutableArray new];
			[tabObjects addObject:[MGMSIPPad tabWithSIPUser:self]];
			[tabObjects addObject:[MGMSIPContacts tabWithSIPUser:self]];
			[tabObjects addObject:[MGMSIPInbox tabWithSIPUser:self]];
			[tabObjects addObject:[MGMSIPRecordings tabWithSIPUser:self]];
			
			loggingIn = YES;
			[NSThread detachNewThreadSelector:@selector(login) toTarget:account withObject:nil];
		}
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[tabObjects removeAllObjects];
	[tabObjects release];
	[SIPRegistrationTimeout invalidate];
	[SIPRegistrationTimeout release];
	[calls removeAllObjects];
	[calls release];
	[account setDelegate:nil];
	[account logout];
	[account release];
	[contacts stop];
	[contacts setDelegate:nil];
	[contacts release];
	[user release];
	[callToAwnswer release];
	[optionsNumber release];
	[callToAwnswer release];
	[super dealloc];
}

- (void)registerSettings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setObject:NSStringFromClass([MGMAddressBook class]) forKey:MGMSContactsSourceKey];
	[settings setObject:[NSNumber numberWithInt:MGMSIPKeypadTabIndex] forKey:MGMSIPCurrentTab];
	[user registerSettings:settings];
}

- (MGMAccountController *)accountController {
	return accountController;
}
- (MGMUser *)user {
	return user;
}
- (MGMContacts *)contacts {
	return contacts;
}
- (NSArray *)calls {
	return calls;
}
- (NSString *)title {
	if ([user settingForKey:MGMSIPAccountFullName]!=nil && ![[user settingForKey:MGMSIPAccountFullName] isEqual:@""])
		return [user settingForKey:MGMSIPAccountFullName];
	NSString *userName = [user settingForKey:MGMUserName];
	if ([userName isPhoneComplete])
		userName = [userName readableNumber];
	return userName;
}
- (NSString *)areaCode {
	return [user settingForKey:MGMSIPUserAreaCode];
}
- (NSString *)password {
	return [user password];
}

- (void)registrationChanged {
	[SIPRegistrationTimeout invalidate];
	[SIPRegistrationTimeout release];
	SIPRegistrationTimeout = nil;
	if (!acountRegistered) {
		if (![account isRegistered]) {
			UIAlertView *alert = [[UIAlertView new] autorelease];
			[alert setTitle:@"Unable to Register with Server. Please check your credentials."];
			[alert setMessage:[account lastError]];
			[alert addButtonWithTitle:MGMOkButtonTitle];
			[alert show];
		}
		acountRegistered = YES;
		[self performSelectorOnMainThread:@selector(removeLoginProgress) withObject:nil waitUntilDone:NO];
	}
}
- (void)loggedIn {
	loggingIn = NO;
	[self performSelectorOnMainThread:@selector(startRegistrationTimeoutTimer) withObject:nil waitUntilDone:NO];
}
- (void)startRegistrationTimeoutTimer {
	if (!acountRegistered)
		SIPRegistrationTimeout = [[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(SIPTimeout) userInfo:nil repeats:NO] retain];
}
- (void)SIPTimeout {
	[SIPRegistrationTimeout invalidate];
	[SIPRegistrationTimeout release];
	SIPRegistrationTimeout = nil;
	[account setLastError:@"Registration Timeout."];
	[self loginErrored];
}
- (void)removeLoginProgress {
	if (progressView!=nil) {
		[progressView stopProgess];
		[progressView setNeedsDisplay];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(progressFadeAnimationDidStop:finished:context:)];
		[progressView setAlpha:0.0];
		[UIView commitAnimations];
	}
}
- (void)progressFadeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
}
- (void)loginErrored {
	loggingIn = NO;
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error logging in"];
	[alert setMessage:[account lastError]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
	
	[progressView stopProgess];
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
	[self performSelectorOnMainThread:@selector(removeLoginProgress) withObject:nil waitUntilDone:NO];
}
- (void)logoutErrored {
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error logging out"];
	[alert setMessage:[account lastError]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"SIPUser"] owner:self options:nil]) {
			NSLog(@"Unable to load SIP User");
		} else {
			[tabView addSubview:[[tabObjects objectAtIndex:currentTab] view]];
			[tabBar setSelectedItem:[[tabBar items] objectAtIndex:currentTab]];
			if (![account isRegistered]) {
				CGSize contentSize = [view frame].size;
				progressView = [[MGMProgressView alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
				[progressView setProgressTitle:@"Logging In"];
				[view addSubview:progressView];
				[progressView startProgess];
				[progressView becomeFirstResponder];
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

- (void)updatedContacts {
	[[tabObjects objectAtIndex:MGMSIPContactsTabIndex] updatedContacts];
}

- (void)call:(NSString *)theNumber {
	[[tabObjects objectAtIndex:MGMSIPInboxTabIndex] addPhoneNumber:theNumber type:MGMIPlacedType];
	[account makeCallToNumber:theNumber];
}

- (NSString *)phoneCalling {
	for (int i=0; i<[[accountController contactsControllers] count]; i++) {
		if ([[[accountController contactsControllers] objectAtIndex:i] isKindOfClass:[MGMVoiceUser class]] && [[[accountController contactsControllers] objectAtIndex:i] isPlacingCall]) {
			MGMVoiceUser *voiceUser = [[accountController contactsControllers] objectAtIndex:i];
			[voiceUser donePlacingCall];
			return [voiceUser currentPhoneNumber];
		}
	}
	return nil;
}
- (void)gotNewCall:(MGMSIPCall *)theCall {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([[accountController controller] isInBackground]) {
		[self performSelectorOnMainThread:@selector(showNotificationForCall:) withObject:theCall waitUntilDone:YES];
	} else {
#endif
		[self performSelectorOnMainThread:@selector(mainGotNewCall:) withObject:theCall waitUntilDone:NO];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	}
#endif
}
- (void)answerCall {
	if (callToAwnswer!=nil) {
		if ([callToAwnswer state]!=MGMSIPCallDisconnectedState) {
			[callToAwnswer answer];
			[self performSelectorOnMainThread:@selector(mainGotNewCall:) withObject:callToAwnswer waitUntilDone:NO];
		}
		[callToAwnswer release];
		callToAwnswer = nil;
	}
}
- (void)clearCall {
	[callToAwnswer release];
	callToAwnswer = nil;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
- (void)showNotificationForCall:(MGMSIPCall *)theCall {
	UILocalNotification *alert = [[[UILocalNotification alloc] init] autorelease];
    if (alert!=nil) {
		[callToAwnswer release];
		callToAwnswer = [theCall retain];
		[alert setRepeatInterval:0];
		NSString *name = [[theCall remoteURL] userName];
		if ([name isPhone])
			name = [contacts nameForNumber:[name phoneFormatWithAreaCode:[self areaCode]]];
		[alert setAlertBody:[NSString stringWithFormat:@"Call from %@", name]];
		[alert setAlertAction:@"Answer"];
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:alert];
		//[theCall sendRingingNotification];
    }
}
#endif
- (void)mainGotNewCall:(MGMSIPCall *)theCall {
	MGMSIPCallView *callView = [MGMSIPCallView viewWithCall:theCall SIPUser:self];
	[calls addObject:callView];
	[[accountController controller] showCallView:callView];
}
- (void)callDone:(MGMSIPCallView *)theCall {
	if ([[theCall call] isIncoming])
		[[tabObjects objectAtIndex:MGMSIPInboxTabIndex] addPhoneNumber:[[[theCall call] remoteURL] userName] type:([theCall didAnswer] ? MGMIReceivedType : MGMIMissedType)];
	[[accountController controller] performSelectorOnMainThread:@selector(dismissCallView:) withObject:theCall waitUntilDone:NO];
	[calls removeObject:theCall];
}

- (BOOL)isUserDone:(MGMUser *)theUser {
	return !loggingIn;
}

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item {
	int tabIndex = [[tabBar items] indexOfObject:item];
	if (tabIndex==currentTab)
		return;
	
	if (tabIndex!=MGMSIPRecordingsTabIndex)
		[accountController setItems:[accountController accountItems] animated:YES];
	
	id tab = [tabObjects objectAtIndex:currentTab];
	currentTab = tabIndex;
	[user setSetting:[NSNumber numberWithInt:currentTab] forKey:MGMSIPCurrentTab];
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
	[theAction addButtonWithTitle:@"Reverse Lookup"];
	[theAction addButtonWithTitle:@"Cancel"];
	[theAction setCancelButtonIndex:2];
	[theAction setDelegate:self];
	[theAction showInView:view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex==0)
		[self call:optionsNumber];
	else if (buttonIndex==1)
		[[accountController controller] showReverseLookupWithNumber:optionsNumber];
	[optionsNumber release];
	optionsNumber = nil;
}
@end
#endif