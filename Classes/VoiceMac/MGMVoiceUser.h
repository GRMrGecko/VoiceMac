//
//  MGMVoiceUser.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import "MGMContactsController.h"

extern NSString *MGMLastUserPhoneKey;

@class MGMController, MGMUser, MGMInstance, MGMInboxWindow, MGMProgressView, MGMPhoneField, MGMPhoneFieldView, MGMContactsTableView;

@interface MGMVoiceUser : MGMContactsController {
	MGMInstance *instance;
	MGMUser *user;
	MGMInboxWindow *inboxWindow;

	MGMProgressView *progressView;
	NSViewAnimation *progressFadeAnimation;
	IBOutlet NSTextField *creditField;
	IBOutlet NSButton *userNumberButton;
	IBOutlet NSPopUpButton *userPhonesButton;
	IBOutlet NSButton *callButton;
	IBOutlet NSButton *smsButton;

	BOOL placingCall;
	NSTimer *callTimer;
}
+ (id)voiceUser:(MGMUser *)theUser controller:(MGMController *)theController;
+ (id)voiceUser:(MGMUser *)theUser controller:(MGMController *)theController instance:(MGMInstance *)theInstance;
- (id)initUser:(MGMUser *)theUser controller:(MGMController *)theController instance:(MGMInstance *)theInstance;

- (void)registerSettings;

- (MGMInstance *)instance;
- (MGMUser *)user;
- (MGMInboxWindow *)inboxWindow;

- (void)loginSuccessful;
- (void)setInstanceInfo;

- (BOOL)isPlacingCall;

- (IBAction)sms:(id)sender;

- (IBAction)viewSettings:(id)sender;
@end