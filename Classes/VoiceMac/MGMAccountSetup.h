//
//  MGMAccountSetup.h
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

#import <Cocoa/Cocoa.h>

@class WebView, MGMUser, MGMInstance, MGMVoiceVerify, MGMURLConnectionManager, MGMSIPAccount;

extern NSString * const MGMSGoogleVoice;
extern NSString * const MGMSGoogleContacts;
extern NSString * const MGMSSIP;
extern NSString * const MGMSAccountType;

extern NSString * const MGMSIPDefaultDomain;

@interface MGMAccountSetup : NSObject {
	IBOutlet NSWindow *setupWindow;
	IBOutlet NSTextField *titleField;
	IBOutlet NSTabView *stepView;
	IBOutlet NSButton *backButton;
	IBOutlet NSButton *continueButton;
	
	BOOL isAttached;
	int step;
	int accountType;
	NSMutableArray *accountsCreated;
	
	//Step 1 - Welcome To VoiceMac
	
	//Step 2 - Account Type
	IBOutlet NSMatrix *S2AccountTypeMatrix;
	
	//Step 3 - Google Voice Privacy Policy
	IBOutlet WebView *S3Browser;
	
	//Step 4 - Google Voice Setup
	IBOutlet NSTextField *S4EmailField;
	IBOutlet NSTextField *S4PasswordField;
	
	//Step 5 - Google Contacts Setup
	IBOutlet NSTextField *S5EmailField;
	IBOutlet NSTextField *S5PasswordField;
	
	//Step 6 - SIP Setup
	IBOutlet NSTextField *S6FullNameField;
	IBOutlet NSTextField *S6DomainField;
	IBOutlet NSTextField *S6RegistrarField;
	IBOutlet NSTextField *S6UserNameField;
	IBOutlet NSTextField *S6PasswordField;
	
	//Step 7 - Checking Login Credentials
	IBOutlet NSProgressIndicator *S7Progress;
	IBOutlet NSTextField *S7StatusField;
	MGMUser *S7CheckUser;
	MGMInstance *S7CheckInstance;
	MGMVoiceVerify *S7VerifyWindow;
	MGMURLConnectionManager *S7ConnectionManager;
#if MGMSIPENABLED
	MGMSIPAccount *S7CheckSIPAccount;
	BOOL S7AccountRegistered;
	NSTimer *S7SIPRegistrationTimeout;
#endif
	
	//Step 8 - Setup Error
	IBOutlet NSTextField *S8MessageField;
	NSString *S8Message;
	
	//Step 9 - Setup Successful
	IBOutlet NSTextField *S9MessageField;
}
- (IBAction)showSetupWindow:(id)sender;
- (void)attachToWindow:(NSWindow *)theWindow;
- (void)displayStep;

- (IBAction)back:(id)sender;
- (IBAction)continue:(id)sender;

//Step 4
- (void)S4Reset;

//Step 5
- (void)S5Reset;

//Step 6
- (IBAction)S6UserNameChanged:(id)sender;
- (IBAction)S6DomainChanged:(id)sender;
- (void)S6Reset;

//Step 7
- (void)S7CheckGoogleVoice;
- (void)S7CheckGoogleContacts;
- (void)S7CheckSIP;
#if MGMSIPENABLED
- (void)loginErrored;
#endif

//Step 9
- (IBAction)S9AddAnotherAccount:(id)sender;
@end