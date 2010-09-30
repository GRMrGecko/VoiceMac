//
//  MGMController.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMController.h"
#import "MGMAccountController.h"
#import "MGMAccountSetup.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase.h>

@implementation MGMController
- (void)awakeFromNib {
	themeManager = [MGMThemeManager new];
	accountController = [[MGMAccountController alloc] initWithController:self];
	[[self view] addSubview:[accountController view]];
	[mainWindow addSubview:[self view]];
	if ([[MGMUser userNames] count]==0) {
		MGMAccountSetup *accountSetup = [[MGMAccountSetup alloc] initWithController:self];
		[[self view] addSubview:[accountSetup view]];
	}
	[mainWindow makeKeyAndVisible];
}

- (MGMThemeManager *)themeManager {
	return themeManager;
}

- (void)showAccountSetup {
	MGMAccountSetup *accountSetup = [[MGMAccountSetup alloc] initWithController:self];
	[accountSetup setSetupOnly:YES];
	CGRect inViewFrame = [[accountSetup view] frame];
	inViewFrame.origin.y += inViewFrame.size.height;
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
	outViewFrame.origin.y += outViewFrame.size.height;
	[[theAccountSetup view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished accountSetup:(MGMAccountSetup *)theAccountSetup {
	[[theAccountSetup view] removeFromSuperview];
	[theAccountSetup release];
}
@end