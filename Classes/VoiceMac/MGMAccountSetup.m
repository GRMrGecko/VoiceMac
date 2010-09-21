//
//  MGMAccountSetup.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/13/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMAccountSetup.h"
#import "MGMVoiceUser.h"
#import "MGMSIPUser.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <WebKit/WebKit.h>

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
- (id)init {
	if (self = [super init]) {
		if (![NSBundle loadNibNamed:@"AccountSetup" owner:self]) {
			NSLog(@"Unable to load Account Set Up!");
			[self release];
			self = nil;
		} else {
			isAttached = NO;
			step = 1;
			accountType = -1;
			accountsCreated = [NSMutableArray new];
			S7ConnectionManager = [[MGMURLConnectionManager managerWithCookieStorage:nil] retain];
			[self displayStep];
		}
	}
	return self;
}
- (void)dealloc {
	if (setupWindow!=nil)
		[setupWindow release];
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

- (IBAction)showSetupWindow:(id)sender {
	[setupWindow makeKeyAndOrderFront:sender];
}
- (void)attachToWindow:(NSWindow *)theWindow {
	isAttached = YES;
	step = 2;
	[self displayStep];
	[[NSApplication sharedApplication] beginSheet:setupWindow modalForWindow:theWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}
- (void)displayStep {
	switch (step) {
		case 1:
			[titleField setStringValue:@"Welcome to VoiceMac"];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:NO];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:YES];
			break;
		case 2:
			[titleField setStringValue:@"Account Set Up"];
			if (isAttached)
				[backButton setTitle:MGMSCancel];
			else
				[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:YES];
			if (accountType==-1)
				[S2AccountTypeMatrix selectCellAtRow:0 column:0];
			else
				[S2AccountTypeMatrix selectCellAtRow:accountType column:0];
			break;
		case 3:
			[titleField setStringValue:@"Google Voice Privacy Policy"];
			[backButton setTitle:MGMSDisagree];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSAgree];
			[continueButton setEnabled:YES];
			[[S3Browser mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/googlevoice/legal-notices.html"]]];
			break;
		case 4:
		case 5:
		case 6: {
			NSString *type = nil;
			if (accountType==0)
				type = MGMSGoogleVoice;
			else if (accountType==1)
				type = MGMSGoogleContacts;
			else if (accountType==2)
				type = MGMSSIP;
			[titleField setStringValue:[NSString stringWithFormat:@"Set Up %@", type]];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:YES];
			break;
		}
		case 7:
			[titleField setStringValue:@"Checking Credentials"];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:NO];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:NO];
			[S7StatusField setStringValue:MGMS7Crediential];
			if (accountType==0)
				[self S7CheckGoogleVoice];
			else if (accountType==1)
				[self S7CheckGoogleContacts];
			else if (accountType==2)
				[self S7CheckSIP];
			[S7Progress startAnimation:self];
			break;
		case 8: {
			[S7Progress stopAnimation:self];
			NSString *type = nil;
			if (accountType==0)
				type = MGMSGoogleVoice;
			else if (accountType==1)
				type = MGMSGoogleContacts;
			else if (accountType==2)
				type = MGMSSIP;
			[titleField setStringValue:@"Credentials Error"];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:YES];
			[continueButton setTitle:MGMSContinue];
			[continueButton setEnabled:NO];
			[S8MessageField setStringValue:[NSString stringWithFormat:@"Unable to set up your %@ account, the error we receviced was \"%@\" Please go back and correct the problem.", type, S8Message]];
			if (S8Message!=nil) {
				[S8Message release];
				S8Message = nil;
			}
			NSBeep();
			break;
		}
		case 9: {
			[titleField setStringValue:@"Set Up Successful"];
			NSString *type = nil;
			if (accountType==0)
				type = MGMSGoogleVoice;
			else if (accountType==1)
				type = MGMSGoogleContacts;
			else if (accountType==2)
				type = MGMSSIP;
			[S7Progress stopAnimation:self];
			[backButton setTitle:MGMSGoBack];
			[backButton setEnabled:NO];
			[continueButton setTitle:MGMSDone];
			[continueButton setEnabled:YES];
			[S9MessageField setStringValue:[NSString stringWithFormat:@"You have sucessfully set up your %@ account. You may continue to the Application or you add another account by pressing \"Add Another Account\". If you are confused about VoiceMac, please read the documentation which explains how you use it and all you can do with it.", type]];
			break;
		}
	}
	[stepView selectTabViewItemAtIndex:step-1];	
}

- (IBAction)back:(id)sender {
	switch (step) {
		case 2:
			if (isAttached) {
				[[NSApplication sharedApplication] endSheet:setupWindow];
				[setupWindow orderOut:self];
				[accountsCreated makeObjectsPerformSelector:@selector(start)];
				[self release];
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
	[self displayStep];
}
- (IBAction)continue:(id)sender {
	switch (step) {
		case 2:
			accountType = [S2AccountTypeMatrix selectedRow];
			switch (accountType) {
				case 1:
					step = 5;
					break;
				case 2: {
#if MGMSIPENABLED
					step = 6;
#else
					NSAlert *theAlert = [[NSAlert new] autorelease];
					[theAlert setMessageText:@"Unable to Add Account"];
					[theAlert setInformativeText:@"MGMSIP is not compiled with VoiceMac, you can not add a SIP account without first compiling with MGMSIP."];
					[theAlert runModal];
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
				if ([[S4EmailField stringValue] isEqual:@""] || [[S4PasswordField stringValue] isEqual:@""])
					emptyFields = YES;
			} else if (accountType==1) {
				if ([[S5EmailField stringValue] isEqual:@""] || [[S5PasswordField stringValue] isEqual:@""])
					emptyFields = YES;
			} else if (accountType==2) {
				if ([[S6UserNameField stringValue] isEqual:@""] || [[S6PasswordField stringValue] isEqual:@""])
					emptyFields = YES;
			}
			if (emptyFields) {
				NSAlert *theAlert = [[NSAlert new] autorelease];
				[theAlert setMessageText:@"Missing Information"];
				[theAlert setInformativeText:@"It appears as if you did not fill the required fields, please fill out the required fields and then continue."];
				[theAlert runModal];
				return;
			}
			step = 7;
			break;
		}
		case 9:
			if (isAttached) {
				[[NSApplication sharedApplication] endSheet:setupWindow];
			}
			[setupWindow orderOut:self];
			[accountsCreated makeObjectsPerformSelector:@selector(start)];
			[self release];
			return;
		default:
			step++;
			break;
	}
	[self displayStep];
}

//Step 4
- (void)S4Reset {
	[S4EmailField setStringValue:@""];
	[S4PasswordField setStringValue:@""];
}

//Step 5
- (void)S5Reset {
	[S5EmailField setStringValue:@""];
	[S5PasswordField setStringValue:@""];
}

//Step 6
- (IBAction)S6UserNameChanged:(id)sender {
	[[S6FullNameField cell] setPlaceholderString:[S6UserNameField stringValue]];
}
- (IBAction)S6DomainChanged:(id)sender {
	if ([[S6DomainField stringValue] isEqual:@""])
		[[S6RegistrarField cell] setPlaceholderString:MGMSIPDefaultDomain];
	else
		[[S6RegistrarField cell] setPlaceholderString:[S6DomainField stringValue]];
}
- (void)S6Reset {
	[S6FullNameField setStringValue:@""];
	[[S6FullNameField cell] setPlaceholderString:@"UserName"];
	[S6DomainField setStringValue:@""];
	[S6RegistrarField setStringValue:@""];
	[S6UserNameField setStringValue:@""];
	[S6PasswordField setStringValue:@""];
}

//Step 7
- (void)S7CheckGoogleVoice {
	S7CheckUser = [[MGMUser createUserWithName:[S4EmailField stringValue] password:[S4PasswordField stringValue]] retain];
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
		MGMUser *contactsUser = [MGMUser createUserWithName:[S4EmailField stringValue] password:[S4PasswordField stringValue]];
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
	S7CheckUser = [[MGMUser createUserWithName:[S5EmailField stringValue] password:[S5PasswordField stringValue]] retain];
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
	S7CheckUser = [[MGMUser createUserWithName:[S6UserNameField stringValue] password:[S6PasswordField stringValue]] retain];
	[S7CheckUser setSetting:MGMSSIP forKey:MGMSAccountType];
	NSString *fullName = [S6FullNameField stringValue];
	if ([fullName isEqual:@""])
		fullName = [S6UserNameField stringValue];
	[S7CheckUser setSetting:fullName forKey:MGMSIPAccountFullName];
	[S7CheckUser setSetting:[S6UserNameField stringValue] forKey:MGMSIPAccountUserName];
	if ([[S6UserNameField stringValue] isPhone])
		[S7CheckUser setSetting:[[S6UserNameField stringValue] areaCode] forKey:MGMSIPUserAreaCode];
	if ([[S6DomainField stringValue] isEqual:@""])
		[S7CheckUser setSetting:MGMSIPDefaultDomain forKey:MGMSIPAccountDomain];
	else
		[S7CheckUser setSetting:[S6DomainField stringValue] forKey:MGMSIPAccountDomain];
	if (![[S6RegistrarField stringValue] isEqual:@""])
		[S7CheckUser setSetting:[S6RegistrarField stringValue] forKey:MGMSIPAccountRegistrar];
	S7CheckSIPAccount = [[MGMSIPAccount alloc] initWithSettings:[S7CheckUser settings]];
	[S7CheckSIPAccount setDelegate:self];
	S7AccountRegistered = NO;
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
	[self displayStep];
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
	[S7StatusField setStringValue:MGMS7SIPWaiting];
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
	[self displayStep];
}
#endif

//Step 9
- (IBAction)S9AddAnotherAccount:(id)sender {
	step = 2;
	[self displayStep];
}

- (void)windowWillClose:(NSNotification *)notification {
	step = 9;
	[self continue:self];
}
@end