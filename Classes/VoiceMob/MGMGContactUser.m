//
//  MGMGContactUser.m
//  VoiceMob
//
//  Created by Mr. Gecko on 11/9/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMGContactUser.h"
#import "MGMAccountController.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

@implementation MGMGContactUser
+ (id)gContactUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	return [[[self alloc] initWithUser:theUser accountController:theAccountController] autorelease];
}
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController {
	if ((self = [super init])) {
		accountController = theAccountController;
		user = [theUser retain];
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[user release];
	[super dealloc];
}

- (MGMAccountController *)accountController {
	return accountController;
}
- (MGMUser *)user {
	return user;
}

- (UIView *)view {
	return nil;
}
- (void)releaseView {
	
}
@end