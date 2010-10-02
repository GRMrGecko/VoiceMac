//
//  MGMSIPUser.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSIPUser.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

NSString * const MGMSIPUserAreaCode = @"MGMVSIPUserAreaCode";

@implementation MGMSIPUser
+ (id)SIPUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	return [[[self alloc] initWithUser:theUser accountController:theAccountController] autorelease];
}
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	if (self = [super init]) {
		accountController = theAccountController;
		user = [theUser retain];
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
- (NSString *)title {
	if ([user settingForKey:MGMSIPAccountFullName]!=nil && ![[user settingForKey:MGMSIPAccountFullName] isEqual:@""])
		return [user settingForKey:MGMSIPAccountFullName];
	return [user settingForKey:MGMUserName];
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"SIPUser"] owner:self options:nil]) {
			NSLog(@"Unable to load SIP User");
			[self release];
			self = nil;
		} else {
			
		}
	}
	return view;
}
- (void)releaseView {
	if (view!=nil) {
		[view release];
		view = nil;
	}
}
@end