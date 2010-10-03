//
//  MGMVoiceUser.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@class MGMVoiceUser, MGMAccountController, MGMUser, MGMInstance, MGMProgressView;

extern const int MGMKeypadTabIndex;
extern const int MGMContactsTabIndex;
extern const int MGMSMSTabIndex;
extern const int MGMInboxTabIndex;

@protocol MGMVoiceUserTabProtocol <NSObject>
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (MGMVoiceUser *)voiceUser;

- (UIView *)view;
- (void)releaseView;
@end

@interface MGMVoiceUser : NSObject {
	MGMAccountController *accountController;
	MGMUser *user;
	MGMInstance *instance;
	
	int currentTab;
	NSMutableArray *tabObjects;
	
	MGMProgressView *progressView;
	IBOutlet UIView *view;
	IBOutlet UIView *tabView;
	IBOutlet UITabBar *tabBar;
	
	BOOL placingCall;
	NSTimer *callTimer;
	UIAlertView *callCancelView;
}
+ (id)voiceUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;

- (MGMAccountController *)accountController;
- (MGMUser *)user;
- (MGMInstance *)instance;
- (NSString *)title;
- (NSString *)areaCode;

- (UIView *)view;
- (NSArray *)tabObjects;
- (UIView *)tabView;
- (UITabBar *)tabBar;
- (void)releaseView;

- (void)loginSuccessful;
- (void)setInstanceInfo;

- (BOOL)isPlacingCall;
- (void)call:(NSString *)theNumber;

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item;
@end