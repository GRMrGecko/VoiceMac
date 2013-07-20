//
//  MGMGContactUser.h
//  VoiceMob
//
//  Created by Mr. Gecko on 11/9/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMAccountController, MGMUser;

@interface MGMGContactUser : NSObject {
	MGMAccountController *accountController;
	MGMUser *user;
}
+ (id)gContactUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;

- (MGMAccountController *)accountController;
- (MGMUser *)user;

- (UIView *)view;
- (void)releaseView;
@end