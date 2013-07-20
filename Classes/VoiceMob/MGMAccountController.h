//
//  MGMAccountController.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMAccountController, MGMController, MGMAccounts, MGMSettings, MGMSound, MGMUser, MGMInstance;

@protocol MGMAccountProtocol <NSObject>
- (MGMAccountController *)accountController;
- (MGMUser *)user;
- (NSString *)title;
- (NSString *)areaCode;

- (UIView *)view;
- (void)releaseView;

- (void)showOptionsForNumber:(NSString *)theNumber;
@end

@interface MGMAccountController : NSObject {
	MGMController *controller;
	
	NSMutableArray *contactsControllers;
	int currentContactsController;
	NSMutableDictionary *badgeValues;
	MGMAccounts *accounts;
	MGMSettings *settings;
	MGMSound *soundPlayer;
	IBOutlet UIView *view;
	IBOutlet UIToolbar *toolbar;
	NSArray *accountsItems;
	NSArray *accountItems;
	NSArray *settingsItems;
	IBOutlet UIButton *phoneButton;
	IBOutlet UIView *contentView;
	BOOL shouldRefreshSounds;
}
- (id)initWithController:(MGMController *)theController;

- (void)registerDefaults;

- (MGMController *)controller;
- (NSArray *)contactsControllers;
- (id<MGMAccountProtocol>)contactControllerWithUser:(MGMUser *)theUser;
- (NSDictionary *)badgeValues;
- (int)badgeValueForInstance:(MGMInstance *)theInstance;
- (void)setBadge:(int)theBadge forInstance:(MGMInstance *)theInstance;
- (UIView *)view;
- (void)releaseView;
- (UIToolbar *)toolbar;
- (void)setItems:(NSArray *)theItems animated:(BOOL)isAnimated;
- (NSArray *)accountsItems;
- (NSArray *)accountItems;

- (BOOL)isCurrent:(id)theUser;
- (void)setTitle:(NSString *)theTitle;

- (IBAction)showAccounts:(id)sender;
- (IBAction)showSettings:(id)sender;
- (NSString *)soundTitleForKey:(NSString *)theKey;
- (int)soundSectionForKey:(NSString *)theKey;
- (int)soundSettingRowForKey:(NSString *)theKey;
- (NSDictionary *)soundMenuWithSounds:(NSDictionary *)theSounds key:(NSString *)key;

- (void)showUser:(MGMUser *)theUser;

- (IBAction)phone:(id)sender;
@end