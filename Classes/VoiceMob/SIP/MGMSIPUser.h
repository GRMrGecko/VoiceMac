//
//  MGMSIPUser.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import <UIKit/UIKit.h>

@class MGMSIPUser, MGMAccountController, MGMUser, MGMSIPAccount, MGMContacts, MGMProgressView, MGMSIPCall, MGMSIPCallView;

extern const int MGMSIPKeypadTabIndex;
extern const int MGMSIPContactsTabIndex;
extern const int MGMSIPInboxTabIndex;
extern const int MGMSIPRecordingsTabIndex;

extern NSString * const MGMSIPUserAreaCode;

@protocol MGMSIPUserTabProtocol <NSObject>
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser;
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser;

- (MGMSIPUser *)SIPUser;

- (UIView *)view;
- (void)releaseView;
@end

@interface MGMSIPUser : NSObject <UIActionSheetDelegate> {
	MGMAccountController *accountController;
	MGMUser *user;
	MGMSIPAccount *account;
	NSMutableArray *calls;
	MGMContacts *contacts;
	
	int currentTab;
	NSMutableArray *tabObjects;
	
	BOOL loggingIn;
	BOOL acountRegistered;
	NSTimer *SIPRegistrationTimeout;
	
	MGMProgressView *progressView;
	IBOutlet UIView *view;
	IBOutlet UIView *tabView;
	IBOutlet UITabBar *tabBar;
	
	NSString *optionsNumber;
	MGMSIPCall *callToAwnswer;
}
+ (id)SIPUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;
- (id)initWithUser:(MGMUser *)theUser accountController:(MGMAccountController *)theAccountController;

- (void)registerSettings;

- (MGMAccountController *)accountController;
- (MGMUser *)user;
- (MGMContacts *)contacts;
- (NSArray *)calls;
- (NSString *)title;
- (NSString *)areaCode;

- (void)loginErrored;

- (UIView *)view;
- (NSArray *)tabObjects;
- (UIView *)tabView;
- (UITabBar *)tabBar;
- (void)releaseView;

- (void)call:(NSString *)theNumber;

- (NSString *)phoneCalling;
- (void)gotNewCall:(MGMSIPCall *)theCall;
- (void)answerCall;
- (void)clearCall;
- (void)callDone:(MGMSIPCallView *)theCall;

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item;

- (void)showOptionsForNumber:(NSString *)theNumber;
@end
#endif