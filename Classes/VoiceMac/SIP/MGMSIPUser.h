//
//  MGMSIPUser.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/13/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import <Cocoa/Cocoa.h>
#import "MGMContactsController.h"

@class MGMUser, MGMContacts, MGMProgressView, MGMSIPAccount, MGMSIPCall, MGMSIPCallWindow;

extern NSString * const MGMSIPUserAreaCode;

@interface MGMSIPUser : MGMContactsController {
	MGMUser *user;
	MGMSIPAccount *account;
	NSMutableArray *calls;
	MGMContacts *contacts;
	
	BOOL loggingIn;
	BOOL acountRegistered;
	NSTimer *SIPRegistrationTimeout;
	
	MGMProgressView *progressView;
	NSViewAnimation *progressFadeAnimation;
	
	IBOutlet NSButton *callButton;
	IBOutlet NSTextField *userNameField;
}
+ (id)SIPUser:(MGMUser *)theUser controller:(MGMController *)theController;
- (id)initUser:(MGMUser *)theUser controller:(MGMController *)theController;

- (void)registerSettings;

- (MGMUser *)user;
- (NSArray *)calls;

- (void)removeLoginProgress;
- (void)loginErrored;

- (NSString *)phoneCalling;
- (void)gotNewCall:(MGMSIPCall *)theCall;
- (void)callDone:(MGMSIPCallWindow *)theCall;
@end
#endif