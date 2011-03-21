//
//  MGMVoiceUser.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose
//  with or without fee is hereby granted, provided that the above copyright notice
//  and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT,
//  OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
//  DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
//  ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

#import <Cocoa/Cocoa.h>
#import "MGMContactsController.h"

extern NSString * const MGMLastUserPhoneKey;

@class MGMController, MGMUser, MGMInstance, MGMInboxWindow, MGMVoiceVerify, MGMProgressView, MGMPhoneField, MGMPhoneFieldView, MGMContactsTableView;

@interface MGMVoiceUser : MGMContactsController
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1060)
<NSAnimationDelegate>
#endif
{
	MGMInstance *instance;
	MGMUser *user;
	MGMInboxWindow *inboxWindow;
	
	MGMVoiceVerify *verifyWindow;
	
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

- (void)updatedUserPhones;

- (BOOL)isPlacingCall;
- (void)donePlacingCall;

- (IBAction)sms:(id)sender;

- (IBAction)viewSettings:(id)sender;
@end