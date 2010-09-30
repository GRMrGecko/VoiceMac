//
//  MGMAccountController.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@class MGMAccountController, MGMController, MGMAccounts, MGMUser;

@protocol MGMAccountProtocol <NSObject>
- (MGMAccountController *)accountController;
- (MGMUser *)user;
- (NSString *)title;
- (NSString *)areaCode;

- (UIView *)view;
- (void)releaseView;
@end


@interface MGMAccountController : NSObject {
	MGMController *controller;
	
	NSMutableArray *contactsControllers;
	int currentContactsController;
	MGMAccounts *accounts;
	IBOutlet UIView *view;
	IBOutlet UIToolbar *toolbar;
	NSArray *accountsItems;
	NSArray *accountItems;
	IBOutlet UILabel *titleField;
	IBOutlet UIView *contentView;
}
- (id)initWithController:(MGMController *)theController;

- (void)registerDefaults;

- (MGMController *)controller;
- (UIView *)view;

- (BOOL)isCurrent:(id)theUser;
- (void)setTitle:(NSString *)theTitle;

- (IBAction)showAccounts:(id)sender;
- (IBAction)showSettings:(id)sender;

- (void)showUser:(MGMUser *)theUser;
@end