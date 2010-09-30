//
//  MGMAccountSetup.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMAccountSetup.h"
#import "MGMController.h"
#import "MGMSIPUser.h"
#import "MGMVMAddons.h"
#import <VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

NSString * const MGMRadioButton = @"Radio";
NSString * const MGMRadioSelectedButton = @"RadioSelected";

NSString * const MGMSGoBack = @"Go Back";
NSString * const MGMSCancel = @"Cancel";
NSString * const MGMSDisagree = @"Disagree";
NSString * const MGMSContinue = @"Continue";
NSString * const MGMSDone = @"Done";
NSString * const MGMSAgree = @"Agree";

NSString * const MGMSGoogleVoice = @"Google Voice";
NSString * const MGMSGoogleContacts = @"Google Contacts";
NSString * const MGMSSIP = @"Session Initiation Protocol";
NSString * const MGMSAccountType = @"MGMSAccountType";

NSString * const MGMS7Crediential = @"Checking Login Credentials.";
NSString * const MGMS7SIPWaiting = @"Waiting for Registration Status.";

NSString * const MGMSIPDefaultDomain = @"proxy01.sipphone.com";

@implementation MGMAccountSetup
- (id)initWithController:(MGMController *)theController {
	if (self = [super init]) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"AccountSetup"] owner:self options:nil]) {
			NSLog(@"Unable to load Account Setup");
			[self release];
			self = nil;
		} else {
			controller = theController;
			
			displaying = NO;
			needsDisplay = NO;
			goingBack = NO;
			[self setSetupOnly:NO];
			accountType = 0;
			accountsCreated = [NSMutableArray new];
			S7ConnectionManager = [[MGMURLConnectionManager managerWithCookieStorage:nil] retain];
			setupRect = [setupView frame];
			setupKeyboardRect = setupRect;
			setupKeyboardRect.origin.y = (-(setupKeyboardRect.size.height-45))+246;
		}
	}
	return self;
}
- (void)dealloc {
	if (setupView!=nil)
		[setupView release];
	if (S1View!=nil)
		[S1View release];
	if (S2View!=nil)
		[S2View release];
	if (S3View!=nil)
		[S3View release];
	if (S4View!=nil)
		[S4View release];
	if (S5View!=nil)
		[S5View release];
	if (S6View!=nil)
		[S6View release];
	if (S7View!=nil)
		[S7View release];
	if (S8View!=nil)
		[S8View release];
	if (S9View!=nil)
		[S9View release];
	if (accountsCreated!=nil)
		[accountsCreated release];
	if (S7CheckUser!=nil)
		[S7CheckUser release];
	if (S7CheckInstance!=nil)
		[S7CheckInstance release];
	if (S7ConnectionManager!=nil)
		[S7ConnectionManager release];
#if MGMSIPENABLED
	if (S7CheckSIPAccount!=nil)
		[S7CheckSIPAccount release];
#endif
	if (S8Message!=nil)
		[S8Message release];
	[super dealloc];
}

- (UIView *)view {
	if (lastView==nil)
		[self displayStep];
	return setupView;
}

- (IBAction)closeKeyboard:(id)sender {
	
}

- (void)setSetupOnly:(BOOL)isSetupOnly {
	setupOnly = isSetupOnly;
	if (setupOnly)
		step = 2;
	else
		step = 1;
}
- (void)setStep:(int)theStep {
	step = theStep;
}
- (void)displayStep {
	if (displaying) {
		needsDisplay = YES;
		return;
	}
	switch (step) {
		case 1:
			nextView = S1View;
			[titleField setText:@"Welcome to VoiceMob"];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:NO];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:YES];
			break;
		case 2:
			nextView = S2View;
			[titleField setText:@"Account Setup"];
			if (setupOnly)
				[backButton setTitle:MGMSCancel];
			else
				[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:YES];
			break;
		case 3:
			nextView = S3View;
			[titleField setText:@"Google Voice Privacy Policy"];
			[backButton setTitle:MGMSDisagree];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSAgree];
			[continueButton setEnabled:YES];
			[S3Browser loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/googlevoice/legal-notices.html"]]];
			break;
		case 4:
		case 5:
		case 6: {
			if (step==4)
				nextView = S4View;
			else if (step==5)
				nextView = S5View;
			else if (step==6)
				nextView = S6View;
			NSString *type = nil;
			if (accountType==0)
				type = MGMSGoogleVoice;
			else if (accountType==1)
				type = MGMSGoogleContacts;
			else if (accountType==2)
				type = MGMSSIP;
			[titleField setText:[NSString stringWithFormat:@"Set Up %@", type]];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:YES];
			break;
		}
		case 7:
			nextView = S7View;
			[titleField setText:@"Checking Credentials"];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:NO];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:NO];
			[S7StatusField setText:MGMS7Crediential];
			if (accountType==0)
				[self S7CheckGoogleVoice];
			else if (accountType==1)
				[self S7CheckGoogleContacts];
			else if (accountType==2)
				[self S7CheckSIP];
			[S7Progress startAnimating];
			break;
		case 8: {
			nextView = S8View;
			[S7Progress stopAnimating];
			NSString *type = nil;
			if (accountType==0)
				type = MGMSGoogleVoice;
			else if (accountType==1)
				type = MGMSGoogleContacts;
			else if (accountType==2)
				type = MGMSSIP;
			[titleField setText:@"Credentials Error"];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:NO];
			[S8MessageField setText:[NSString stringWithFormat:@"Unable to set up your %@ account, the error we receviced was \"%@\" Please go back and correct the problem.", type, S8Message]];
			if (S8Message!=nil) {
				[S8Message release];
				S8Message = nil;
			}
			break;
		}
		case 9: {
			nextView = S9View;
			[titleField setText:@"Setup Successful"];
			NSString *type = nil;
			if (accountType==0)
				type = MGMSGoogleVoice;
			else if (accountType==1)
				type = MGMSGoogleContacts;
			else if (accountType==2)
				type = MGMSSIP;
			[S7Progress stopAnimating];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:NO];
			[continueButton setTitle:MGMSDone];
			[continueButton setEnabled:YES];
			[S9MessageField setText:[NSString stringWithFormat:@"You have sucessfully set up your %@ account. You may continue to the Application or add another account by pressing \"Add Another Account\". If you are confused about VoiceMob, please read the documentation which explains all you can do with it.", type]];
			break;
		}
	}
	if (lastView==nil) {
		[view addSubview:nextView];
		lastView = nextView;
	} else if (lastView!=nextView) {
		backEnabled = [backButton isEnabled];
		[backButton setEnabled:NO];
		continueEnabled = [continueButton isEnabled];
		[continueButton setEnabled:NO];
		displaying = YES;
		if (goingBack) {
			CGRect inViewFrame = [nextView frame];
			inViewFrame.origin.x -= inViewFrame.size.width;
			[nextView setFrame:inViewFrame];
			[view addSubview:nextView];
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(displayAnimationDidStop:finished:context:)];
			[nextView setFrame:[lastView frame]];
			CGRect outViewFrame = [lastView frame];
			outViewFrame.origin.x += outViewFrame.size.width;
			[lastView  setFrame:outViewFrame];
			[UIView commitAnimations];
		} else {
			CGRect inViewFrame = [nextView frame];
			inViewFrame.origin.x += inViewFrame.size.width;
			[nextView setFrame:inViewFrame];
			[view addSubview:nextView];
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(displayAnimationDidStop:finished:context:)];
			[nextView setFrame:[lastView frame]];
			CGRect outViewFrame = [lastView frame];
			outViewFrame.origin.x -= outViewFrame.size.width;
			[lastView setFrame:outViewFrame];
			[UIView commitAnimations];
		}
	}
}
- (void)displayAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[backButton setEnabled:backEnabled];
	[continueButton setEnabled:continueEnabled];
	[lastView removeFromSuperview];
	lastView = nextView;
	nextView = nil;
	displaying = NO;
	if (needsDisplay) {
		needsDisplay = NO;
		[self displayStep];
	}
}
							  
- (IBAction)back:(id)sender {
	switch (step) {
		case 2:
			if (setupOnly) {
				[accountsCreated makeObjectsPerformSelector:@selector(start)];
				[controller dismissAccountSetup:self];
				return;
			}
			step--;
			break;
		case 4:
			step = 3;
			break;
		case 3:
		case 5:
		case 6:
			if (accountType==0)
				[self S4Reset];
			else if (accountType==1)
				[self S5Reset];
			else if (accountType==2)
				[self S6Reset];
			step = 2;
			break;
		case 8:
			if (accountType==0)
				step = 4;
			else if (accountType==1)
				step = 5;
			else if (accountType==2)
				step = 6;
			break;
		default:
			step--;
			break;
	}
	goingBack = YES;
	[self displayStep];
}
- (IBAction)continue:(id)sender {
	switch (step) {
		case 2:
			switch (accountType) {
				case 1:
					step = 5;
					break;
				case 2: {
#if MGMSIPENABLED
					step = 6;
#else
					UIAlertView *theAlert = [[UIAlertView new] autorelease];
					[theAlert setTitle:@"Unable to Add Account"];
					[theAlert setMessage:@"MGMSIP is not compiled with VoiceMob, you can not add a SIP account without first compiling with MGMSIP."];
					[theAlert addButtonWithTitle:MGMOkButtonTitle];
					[theAlert show];
					return;
#endif
					break;
				}
				default:
					step++;
					break;
			}
			break;
		case 4:
		case 5:
		case 6: {
			BOOL emptyFields = NO;
			if (accountType==0) {
				if ([[S4EmailField text] isEqual:@""] || [[S4PasswordField text] isEqual:@""])
					emptyFields = YES;
			} else if (accountType==1) {
				if ([[S5EmailField text] isEqual:@""] || [[S5PasswordField text] isEqual:@""])
					emptyFields = YES;
			} else if (accountType==2) {
				if ([[S6UserNameField text] isEqual:@""] || [[S6PasswordField text] isEqual:@""])
					emptyFields = YES;
			}
			if (emptyFields) {
				UIAlertView *theAlert = [[UIAlertView new] autorelease];
				[theAlert setTitle:@"Missing Information"];
				[theAlert setMessage:@"It appears as if you did not fill the required fields, please fill out the required fields and then continue."];
				[theAlert addButtonWithTitle:MGMOkButtonTitle];
				[theAlert show];
				return;
			}
			step = 7;
			break;
		}
		case 9:
			[accountsCreated makeObjectsPerformSelector:@selector(start)];
			[controller dismissAccountSetup:self];
			return;
		default:
			step++;
			break;
	}
	goingBack = NO;
	[self displayStep];
}

//Step 2
- (IBAction)S2SelectType:(id)sender {
	[S2GVButton setImage:[UIImage imageNamed:MGMRadioButton] forState:UIControlStateNormal];
	[S2GCButton setImage:[UIImage imageNamed:MGMRadioButton] forState:UIControlStateNormal];
	[S2SIPButton setImage:[UIImage imageNamed:MGMRadioButton] forState:UIControlStateNormal];
	accountType = [sender tag]-1;
	if (accountType==0)
		[S2GVButton setImage:[UIImage imageNamed:MGMRadioSelectedButton] forState:UIControlStateNormal];
	else if (accountType==1)
		[S2GCButton setImage:[UIImage imageNamed:MGMRadioSelectedButton] forState:UIControlStateNormal];
	else if (accountType==2)
		[S2SIPButton setImage:[UIImage imageNamed:MGMRadioSelectedButton] forState:UIControlStateNormal];
}

//Step 4
- (void)S4Reset {
	[S4EmailField setText:@""];
	[S4PasswordField setText:@""];
}

//Step 5
- (void)S5Reset {
	[S5EmailField setText:@""];
	[S5PasswordField setText:@""];
}

//Step 6
- (IBAction)S6ShowKeyboard:(id)sender {
	if (CGRectEqualToRect([setupView frame], setupRect)) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[setupView setFrame:setupKeyboardRect];
		[UIView commitAnimations];
	}
}
- (IBAction)S6CloseKeyboard:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[setupView setFrame:setupRect];
	[UIView commitAnimations];
}
- (IBAction)S6UserNameChanged:(id)sender {
	[S6FullNameField setPlaceholder:[S6UserNameField text]];
}
- (IBAction)S6DomainChanged:(id)sender {
	if ([[S6DomainField text] isEqual:@""])
		[S6RegistrarField setPlaceholder:MGMSIPDefaultDomain];
	else
		[S6RegistrarField setPlaceholder:[S6DomainField text]];
}
- (void)S6Reset {
	[S6FullNameField setText:@""];
	[S6FullNameField setPlaceholder:@"UserName"];
	[S6DomainField setText:@""];
	[S6RegistrarField setText:@""];
	[S6UserNameField setText:@""];
	[S6PasswordField setText:@""];
}

//Step 7
- (void)S7CheckGoogleVoice {
	S7CheckUser = [[MGMUser createUserWithName:[S4EmailField text] password:[S4PasswordField text]] retain];
	[S7CheckUser setSetting:MGMSGoogleVoice forKey:MGMSAccountType];
	S7CheckInstance = [[MGMInstance instanceWithUser:S7CheckUser delegate:self isCheck:YES] retain];
}
- (void)loginError:(NSError *)theError {
	if (S7CheckUser!=nil) {
		[S7CheckUser remove];
		[S7CheckUser release];
		S7CheckUser = nil;
	}
	if (S7CheckInstance!=nil) {
		[S7CheckInstance release];
		S7CheckInstance = nil;
	}
	NSLog(@"Login Failed %@", theError);
	S8Message = [[theError localizedDescription] copy];
	step = 8;
	[self displayStep];
}
- (void)loginSuccessful {
	if (S7CheckUser!=nil) {
		[accountsCreated addObject:S7CheckUser];
		MGMUser *contactsUser = [MGMUser createUserWithName:[S4EmailField text] password:[S4PasswordField text]];
		[contactsUser setSetting:MGMSGoogleContacts forKey:MGMSAccountType];
		[S7CheckUser setSetting:[contactsUser settingForKey:MGMUserID] forKey:MGMCGoogleContactsUser];
		[S7CheckUser release];
		S7CheckUser = nil;
	}
	if (S7CheckInstance!=nil) {
		[S7CheckInstance release];
		S7CheckInstance = nil;
	}
	[self S4Reset];
	step = 9;
	[self displayStep];
}

- (void)S7CheckGoogleContacts {
	S7CheckUser = [[MGMUser createUserWithName:[S5EmailField text] password:[S5PasswordField text]] retain];
	[S7CheckUser setSetting:MGMSGoogleContacts forKey:MGMSAccountType];
	NSString *username = [S7CheckUser settingForKey:MGMUserName];
	if (![username containsString:@"@"])
		username = [username stringByAppendingString:@"@gmail.com"];
	NSURLCredential *credentials = [NSURLCredential credentialWithUser:username password:[S7CheckUser password] persistence:NSURLCredentialPersistenceForSession];
	[S7ConnectionManager setCookieStorage:[S7CheckUser cookieStorage]];
	[S7ConnectionManager setCredentials:credentials];
	[S7ConnectionManager setCustomUseragent:MGMGCUseragent];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMGCAuthenticationURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
	[request setHTTPMethod:MGMPostMethod];
	[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
	[request setHTTPBody:[[NSString stringWithFormat:MGMGCAuthenticationBody, [username addPercentEscapes], [[S7CheckUser password] addPercentEscapes]] dataUsingEncoding:NSUTF8StringEncoding]];
	[S7ConnectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(authentication:didFailWithError:) didFinish:@selector(authenticationDidFinish:) invisible:NO object:nil];
}
- (void)authentication:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	if (S7CheckUser!=nil) {
		[S7CheckUser remove];
		[S7CheckUser release];
		S7CheckUser = nil;
	}
	if (S7ConnectionManager!=nil)
		[S7ConnectionManager setCookieStorage:nil];
	NSLog(@"Login Failed %@", theError);
	S8Message = [[theError localizedDescription] copy];
	step = 8;
	[self displayStep];
}
- (void)authenticationDidFinish:(NSDictionary *)theInfo {
	NSDictionary *info = [MGMGoogleContacts dictionaryWithData:[theInfo objectForKey:MGMConnectionData]];
	if (S7ConnectionManager!=nil)
		[S7ConnectionManager setCookieStorage:nil];
	if (S7CheckUser!=nil) {
		if ([info objectForKey:@"Error"]!=nil) {
			[S7CheckUser remove];
			[S7CheckUser release];
			S7CheckUser = nil;
			S8Message = [@"Unable to login. Please check your Credentials." retain];
			step = 8;
			[self displayStep];
			return;
		}
		[S7CheckUser done];
		[S7CheckUser release];
		S7CheckUser = nil;
	}
	
	[self S5Reset];
	step = 9;
	[self displayStep];
}

- (void)S7CheckSIP {
#if MGMSIPENABLED
	if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
	S7CheckUser = [[MGMUser createUserWithName:[S6UserNameField text] password:[S6PasswordField text]] retain];
	[S7CheckUser setSetting:MGMSSIP forKey:MGMSAccountType];
	NSString *fullName = [S6FullNameField text];
	if ([fullName isEqual:@""])
		fullName = [S6UserNameField text];
	[S7CheckUser setSetting:fullName forKey:MGMSIPAccountFullName];
	[S7CheckUser setSetting:[S6UserNameField text] forKey:MGMSIPAccountUserName];
	if ([[S6UserNameField text] isPhone])
		[S7CheckUser setSetting:[[S6UserNameField text] areaCode] forKey:MGMSIPUserAreaCode];
	if ([[S6DomainField text] isEqual:@""])
		[S7CheckUser setSetting:MGMSIPDefaultDomain forKey:MGMSIPAccountDomain];
	else
		[S7CheckUser setSetting:[S6DomainField text] forKey:MGMSIPAccountDomain];
	if (![[S6RegistrarField text] isEqual:@""])
		[S7CheckUser setSetting:[S6RegistrarField text] forKey:MGMSIPAccountRegistrar];
	S7CheckSIPAccount = [[MGMSIPAccount alloc] initWithSettings:[S7CheckUser settings]];
	[S7CheckSIPAccount setDelegate:self];
	S7AccountRegistered = NO;
	NSLog(@"Logging in");
	[NSThread detachNewThreadSelector:@selector(login) toTarget:S7CheckSIPAccount withObject:nil];
#endif
}
- (NSString *)password {
	return [S7CheckUser password];
}
- (void)registrationChanged {
#if MGMSIPENABLED
	if (S7SIPRegistrationTimeout!=nil) {
		[S7SIPRegistrationTimeout invalidate];
		[S7SIPRegistrationTimeout release];
		S7SIPRegistrationTimeout = nil;
	}
	if (S7CheckSIPAccount!=nil) {
		if (![S7CheckSIPAccount isRegistered]) {
			[S7CheckSIPAccount setLastError:@"Unable to Register with Server. Please check your credentials."];
			[self loginErrored];
			return;
		}
		[S7CheckSIPAccount setDelegate:nil];
		[S7CheckSIPAccount logout];
		[S7CheckSIPAccount release];
		S7CheckSIPAccount = nil;
	}
	if (S7CheckUser!=nil) {
		[accountsCreated addObject:S7CheckUser];
		[S7CheckUser release];
		S7CheckUser = nil;
	}
	[self S6Reset];
	S7AccountRegistered = YES;
	step = 9;
	[self performSelectorOnMainThread:@selector(displayStep) withObject:nil waitUntilDone:NO];
#endif
}
#if MGMSIPENABLED
- (void)S7SIPTimeout {
	if (S7SIPRegistrationTimeout!=nil) {
		[S7SIPRegistrationTimeout invalidate];
		[S7SIPRegistrationTimeout release];
		S7SIPRegistrationTimeout = nil;
	}
	[S7CheckSIPAccount setLastError:@"Registration Timeout."];
	[self loginErrored];
}
- (void)loggedIn {
	[S7StatusField setText:MGMS7SIPWaiting];
	[self performSelectorOnMainThread:@selector(S7StartRegistrationTimeoutTimer) withObject:nil waitUntilDone:NO];
}
- (void)S7StartRegistrationTimeoutTimer {
	if (!S7AccountRegistered)
		S7SIPRegistrationTimeout = [[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(S7SIPTimeout) userInfo:nil repeats:NO] retain];
}
- (void)loginErrored {
	if (S7CheckUser!=nil) {
		[S7CheckUser remove];
		[S7CheckUser release];
		S7CheckUser = nil;
	}
	if (S7CheckSIPAccount!=nil) {
		NSLog(@"Login Failed %@", [S7CheckSIPAccount lastError]);
		S8Message = [[S7CheckSIPAccount lastError] copy];
		[S7CheckSIPAccount setDelegate:nil];
		[S7CheckSIPAccount logout];
		[S7CheckSIPAccount release];
		S7CheckSIPAccount = nil;
	}
	step = 8;
	[self performSelectorOnMainThread:@selector(displayStep) withObject:nil waitUntilDone:NO];
}
#endif

//Step 9
- (IBAction)S9AddAnotherAccount:(id)sender {
	goingBack = YES;
	[self setSetupOnly:YES];
	[self displayStep];
}
@end