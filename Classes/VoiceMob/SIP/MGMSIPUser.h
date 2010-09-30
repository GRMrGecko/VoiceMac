//
//  MGMSIPUser.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

extern NSString * const MGMSIPUserAreaCode;

@class MGMAccountController, MGMUser;

@interface MGMSIPUser : NSObject {
	MGMAccountController *accountController;
	MGMUser *user;
	
	IBOutlet UIView *view;
}
+ (id)SIPUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;

- (MGMAccountController *)accountController;
- (MGMUser *)user;

- (UIView *)view;
- (void)releaseView;
@end