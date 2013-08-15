//
//  MGMSIPUser.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/13/10.
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

#if MGMSIPENABLED
#import <Cocoa/Cocoa.h>
#import "MGMContactsController.h"

@class MGMUser, MGMContacts, MGMProgressView, MGMSIPAccount, MGMSIPCall, MGMSIPCallWindow;

extern NSString * const MGMSIPUserAreaCode;
extern NSString * const MGMSIPExitCode;

@interface MGMSIPUser : MGMContactsController
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1060)
<NSAnimationDelegate>
#endif
{
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