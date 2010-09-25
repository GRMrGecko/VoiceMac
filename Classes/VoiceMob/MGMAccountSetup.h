//
//  MGMAccountSetup.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMUser, MGMInstance, MGMURLConnectionManager, MGMSIPAccount;

@interface MGMAccountSetup : NSObject {
	IBOutlet UIView *setupView;
	CGRect setupRect;
	CGRect setupKeyboardRect;
	IBOutlet UIView *view;
	IBOutlet UILabel *titleField;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *continueButton;
	
	UIView *lastView;
	UIView *nextView;
	BOOL displaying;
	BOOL needsDisplay;
	BOOL goingBack;
	BOOL backEnabled;
	BOOL continueEnabled;
	int step;
	int accountType;
	NSMutableArray *accountsCreated;
	
	//Step 1 - Welcome To VoiceMac
	IBOutlet UIView *S1View;
	
	//Step 2 - Account Type
	IBOutlet UIView *S2View;
	IBOutlet UIButton *S2GVButton;
	IBOutlet UIButton *S2GCButton;
	IBOutlet UIButton *S2SIPButton;
	
	//Step 3 - Google Voice Privacy Policy
	IBOutlet UIView *S3View;
	IBOutlet UIWebView *S3Browser;
	
	//Step 4 - Google Voice Setup
	IBOutlet UIView *S4View;
	IBOutlet UITextField *S4EmailField;
	IBOutlet UITextField *S4PasswordField;
	
	//Step 5 - Google Contacts Setup
	IBOutlet UIView *S5View;
	IBOutlet UITextField *S5EmailField;
	IBOutlet UITextField *S5PasswordField;
	
	//Step 6 - SIP Setup
	IBOutlet UIView *S6View;
	IBOutlet UITextField *S6FullNameField;
	IBOutlet UITextField *S6DomainField;
	IBOutlet UITextField *S6RegistrarField;
	IBOutlet UITextField *S6UserNameField;
	IBOutlet UITextField *S6PasswordField;
	
	//Step 7 - Checking Login Credentials
	IBOutlet UIView *S7View;
	IBOutlet UIActivityIndicatorView *S7Progress;
	IBOutlet UILabel *S7StatusField;
	MGMUser *S7CheckUser;
	MGMInstance *S7CheckInstance;
	MGMURLConnectionManager *S7ConnectionManager;
#if MGMSIPENABLED
	MGMSIPAccount *S7CheckSIPAccount;
	BOOL S7AccountRegistered;
	NSTimer *S7SIPRegistrationTimeout;
#endif
	
	//Step 8 - Setup Error
	IBOutlet UIView *S8View;
	IBOutlet UITextView *S8MessageField;
	NSString *S8Message;
	
	//Step 9 - Setup Successful
	IBOutlet UIView *S9View;
	IBOutlet UITextView *S9MessageField;
}
- (UIView *)view;

- (IBAction)closeKeyboard:(id)sender;

- (void)displayStep;
- (IBAction)back:(id)sender;
- (IBAction)continue:(id)sender;

//Step 2
- (IBAction)S2SelectType:(id)sender;

//Step 4
- (void)S4Reset;

//Step 5
- (void)S5Reset;

//Step 6
- (IBAction)S6ShowKeyboard:(id)sender;
- (IBAction)S6CloseKeyboard:(id)sender;
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