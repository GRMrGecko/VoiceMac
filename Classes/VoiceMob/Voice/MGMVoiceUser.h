//
//  MGMVoiceUser.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMVoiceUser, MGMAccountController, MGMUser, MGMInstance, MGMProgressView;

extern const int MGMVUKeypadTabIndex;
extern const int MGMVUContactsTabIndex;
extern const int MGMVUSMSTabIndex;
extern const int MGMVUInboxTabIndex;

extern NSString * const MGMLastUserPhoneKey;

@protocol MGMVoiceUserTabProtocol <NSObject>
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (MGMVoiceUser *)voiceUser;

- (UIView *)view;
- (void)releaseView;
@end

@interface MGMVoiceUser : NSObject <UIActionSheetDelegate> {
	MGMAccountController *accountController;
	MGMUser *user;
	MGMInstance *instance;
	
	int currentTab;
	NSMutableArray *tabObjects;
	
	MGMProgressView *progressView;
	UIAlertView *verificationView;
	UITextField *verificationField;
	IBOutlet UIView *view;
	IBOutlet UIView *tabView;
	IBOutlet UITabBar *tabBar;
	
	BOOL placingCall;
	NSTimer *callTimer;
	UIAlertView *callCancelView;
	
	NSString *currentPhoneNumber;
	
	NSString *optionsNumber;
	
	int unreadCount;
}
+ (id)voiceUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;

- (void)registerSettings;

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
- (void)donePlacingCall;
- (NSString *)currentPhoneNumber;
- (void)call:(NSString *)theNumber;

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item;

- (void)showOptionsForNumber:(NSString *)theNumber;
@end