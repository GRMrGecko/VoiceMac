//
//  MGMController.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMController.h"
#import "MGMAccountController.h"
#import "MGMAccountSetup.h"
#import "MGMReverseLookup.h"
#import "MGMVoiceMultiSMS.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

#if MGMSIPENABLED
#import "MGMSIPUser.h"
#import "MGMSIPCallView.h"
#endif

@implementation MGMController
- (void)awakeFromNib {
	inBackground = NO;
	
	themeManager = [MGMThemeManager new];
	accountController = [[MGMAccountController alloc] initWithController:self];
	[mainWindow addSubview:[self view]];
	[mainWindow makeKeyAndVisible];
}
- (void)dealloc {
	[mainWindow release];
	[themeManager release];
	[accountController release];
	[super dealloc];
}

- (BOOL)isInBackground {
	return inBackground;
}
- (MGMThemeManager *)themeManager {
	return themeManager;
}
- (MGMAccountController *)accountController {
	return accountController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[accountController releaseView];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
	inBackground = NO;
	[self performSelector:@selector(clearCalls) withObject:nil afterDelay:0.1];
	CGRect viewFrame = [[accountController view] frame];
	viewFrame.size = [[self view] frame].size;
	[[accountController view] setFrame:viewFrame];
	[[self view] addSubview:[accountController view]];
	if ([[MGMUser userNames] count]==0) {
		MGMAccountSetup *accountSetup = [[MGMAccountSetup alloc] initWithController:self];
		[[self view] addSubview:[accountSetup view]];
	}
}

#if MGMSIPENABLED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	for (int i=0; i<[[accountController contactsControllers] count]; i++) {
		if ([[[accountController contactsControllers] objectAtIndex:i] isKindOfClass:[MGMSIPUser class]])
			[[[accountController contactsControllers] objectAtIndex:i] answerCall];
	}
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[MGMSIP sharedSIP] performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
	[application setKeepAliveTimeout:600 handler: ^{
		[[MGMSIP sharedSIP] performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
	}];
	inBackground = YES;
}
- (void)clearCalls {
	for (int i=0; i<[[accountController contactsControllers] count]; i++) {
		if ([[[accountController contactsControllers] objectAtIndex:i] isKindOfClass:[MGMSIPUser class]])
			[[[accountController contactsControllers] objectAtIndex:i] clearCall];
	}
}
#endif
#endif

- (void)showAccountSetup {
	MGMAccountSetup *accountSetup = [[MGMAccountSetup alloc] initWithController:self];
	[accountSetup setSetupOnly:YES];
	CGRect inViewFrame = [[accountSetup view] frame];
	inViewFrame.size = [[self view] frame].size;
	inViewFrame.origin.y = +inViewFrame.size.height;
	[[accountSetup view] setFrame:inViewFrame];
	[[self view] addSubview:[accountSetup view]];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [[accountSetup view] frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[[accountSetup view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAccountSetup:(MGMAccountSetup *)theAccountSetup {
	[UIView beginAnimations:nil context:theAccountSetup];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:accountSetup:)];
	CGRect outViewFrame = [[theAccountSetup view] frame];
	outViewFrame.origin.y = +outViewFrame.size.height;
	[[theAccountSetup view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished accountSetup:(MGMAccountSetup *)theAccountSetup {
	[[theAccountSetup view] removeFromSuperview];
	[theAccountSetup release];
}

- (void)showReverseLookupWithNumber:(NSString *)theNumber {
	MGMReverseLookup *reverseLookup = [[MGMReverseLookup alloc] initWithController:self];
	[reverseLookup setNumber:theNumber];
	CGRect inViewFrame = [[reverseLookup view] frame];
	inViewFrame.size = [[self view] frame].size;
	inViewFrame.origin.y = +inViewFrame.size.height;
	[[reverseLookup view] setFrame:inViewFrame];
	[[self view] addSubview:[reverseLookup view]];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [[reverseLookup view] frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[[reverseLookup view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissReverseLookup:(MGMReverseLookup *)theReverseLookup {
	[UIView beginAnimations:nil context:theReverseLookup];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:reverseLookup:)];
	CGRect outViewFrame = [[theReverseLookup view] frame];
	outViewFrame.origin.y = +outViewFrame.size.height;
	[[theReverseLookup view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished reverseLookup:(MGMReverseLookup *)theReverseLookup {
	[[theReverseLookup view] removeFromSuperview];
	[theReverseLookup release];
}

- (void)showMultiSMSWithInstance:(MGMInstance *)theInstance {
	MGMVoiceMultiSMS *multiSMS = [[MGMVoiceMultiSMS alloc] initWithInstance:theInstance controller:self];
	CGRect inViewFrame = [[multiSMS view] frame];
	inViewFrame.size = [[self view] frame].size;
	inViewFrame.origin.y = +inViewFrame.size.height;
	[[multiSMS view] setFrame:inViewFrame];
	[[self view] addSubview:[multiSMS view]];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [[multiSMS view] frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[[multiSMS view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissMultiSMS:(MGMVoiceMultiSMS *)theMultiSMS {
	[UIView beginAnimations:nil context:theMultiSMS];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:reverseLookup:)];
	CGRect outViewFrame = [[theMultiSMS view] frame];
	outViewFrame.origin.y = +outViewFrame.size.height;
	[[theMultiSMS view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished multiSMS:(MGMVoiceMultiSMS *)theMultiSMS {
	[[theMultiSMS view] removeFromSuperview];
	[theMultiSMS release];
}

#if MGMSIPENABLED
- (void)showCallView:(MGMSIPCallView *)theCallView {
	CGRect inViewFrame = [[theCallView view] frame];
	inViewFrame.size = [[self view] frame].size;
	inViewFrame.origin.y = +inViewFrame.size.height;
	[[theCallView view] setFrame:inViewFrame];
	[[self view] addSubview:[theCallView view]];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [[theCallView view] frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[[theCallView view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissCallView:(MGMSIPCallView *)theCallView {
	[theCallView retain];
	[UIView beginAnimations:nil context:theCallView];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:callView:)];
	CGRect outViewFrame = [[theCallView view] frame];
	outViewFrame.origin.y = +outViewFrame.size.height;
	[[theCallView view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished callView:(MGMSIPCallView *)theCallView {
	[[theCallView view] removeFromSuperview];
	[theCallView release];
}
#endif
@end