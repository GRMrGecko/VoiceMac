//
//  MGMAccountController.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMAccounts.h"
#import "MGMVoiceUser.h"
#import "MGMSIPUser.h"
#import "MGMVMAddons.h"
#import "MGMAccountSetup.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

NSString * const MGMLastContactsController = @"MGMLastContactsController";

NSString * const MGMAccountsTitle = @"Accounts";

@implementation MGMAccountController
- (id)initWithController:(MGMController *)theController {
	if (self = [super init]) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"AccountController"] owner:self options:nil]) {
			NSLog(@"Unable to load Account Controller");
			[self release];
			self = nil;
		} else {
			controller = theController;
			
			[self registerDefaults];
			
			contactsControllers = [NSMutableArray new];
			NSArray *lastUsers = [MGMUser lastUsers];
			for (int i=0; i<[lastUsers count]; i++) {
				MGMUser *user = [MGMUser userWithID:[lastUsers objectAtIndex:i]];
				if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
					[contactsControllers addObject:[MGMVoiceUser voiceUser:user accountController:self]];
				}
#if MGMSIPENABLED
				else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
					if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
					[contactsControllers addObject:[MGMSIPUser SIPUser:user accountController:self]];
				}
#endif
			}
			currentContactsController = [[NSUserDefaults standardUserDefaults] integerForKey:MGMLastContactsController];
			
			accounts = [[MGMAccounts alloc] initWithAccountController:self];
			accountsItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAccount:)] autorelease], nil] retain];
			accountItems = [[toolbar items] copy];
			if ([contactsControllers count]==0 || currentContactsController==-1) {
				[toolbar setItems:accountsItems animated:NO];
				[contentView addSubview:[accounts view]];
				[self setTitle:MGMAccountsTitle];
			} else {
				id<MGMAccountProtocol> contactsController = [contactsControllers objectAtIndex:currentContactsController];
				[toolbar setItems:accountItems animated:NO];
				[contentView addSubview:[contactsController view]];
				
				[self setTitle:[contactsController title]];
			}
			
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter addObserver:self selector:@selector(userStarted:) name:MGMUserStartNotification object:nil];
			[notificationCenter addObserver:self selector:@selector(userDone:) name:MGMUserDoneNotification object:nil];		
		}
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (contactsControllers!=nil)
		[contactsControllers release];
	if (accounts!=nil)
		[accounts release];
	if (view!=nil)
		[view release];
	if (accountsItems!=nil)
		[accountsItems release];
	if (accountItems!=nil)
		[accountItems release];
	[super dealloc];
}

- (void)registerDefaults {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithInt:-1] forKey:MGMLastContactsController];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (MGMController *)controller {
	return controller;
}
- (UIView *)view {
	return view;
}
- (UIToolbar *)toolbar {
	return toolbar;
}
- (NSArray *)accountsItems {
	return accountsItems;
}
- (NSArray *)accountItems {
	return accountItems;
}

- (BOOL)isCurrent:(id)theUser {
	return ([contactsControllers indexOfObject:theUser]==currentContactsController);
}
- (void)setTitle:(NSString *)theTitle {
	[titleField setText:theTitle];
}

- (IBAction)addAccount:(id)sender {
	[controller showAccountSetup];
}

- (IBAction)showAccounts:(id)sender {
	id contactsController = [contactsControllers objectAtIndex:currentContactsController];
	currentContactsController = -1;
	[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];
	[toolbar setItems:accountsItems animated:YES];
	[self setTitle:MGMAccountsTitle];
	CGRect inViewFrame = [[accounts view] frame];
	inViewFrame.origin.x -= inViewFrame.size.width;
	[[accounts view] setFrame:inViewFrame];
	[contentView addSubview:[accounts view]];
	[UIView beginAnimations:nil context:contactsController];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(contactsControllerAnimationDidStop:finished:contactsController:)];
	[[accounts view] setFrame:[[contactsController view] frame]];
	CGRect outViewFrame = [[contactsController view] frame];
	outViewFrame.origin.x += outViewFrame.size.width;
	[[contactsController view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (IBAction)showSettings:(id)sender {
	
}

- (void)userStarted:(NSNotification *)theNotification {
	MGMUser *user = [theNotification object];
	if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
		[contactsControllers addObject:[MGMVoiceUser voiceUser:user accountController:self]];
	}
#if MGMSIPENABLED
	else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
		if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
		[contactsControllers addObject:[MGMSIPUser SIPUser:user accountController:self]];
	}
#endif
}
- (void)userDone:(NSNotification *)theNotification {
	for (int i=0; i<[contactsControllers count]; i++) {
		if ([[contactsControllers objectAtIndex:i] isKindOfClass:[MGMVoiceUser class]]) {
			MGMVoiceUser *voiceUser = [contactsControllers objectAtIndex:i];
			if ([[voiceUser user] isEqual:[theNotification object]]) {
				if (currentContactsController==i) {
					currentContactsController = -1;
					[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];
				} else {
					[contactsControllers removeObject:voiceUser];
				}
				break;
			}
		}
#if MGMSIPENABLED
		else if ([[contactsControllers objectAtIndex:i] isKindOfClass:[MGMSIPUser class]]) {
			MGMSIPUser *SIPUser = [contactsControllers objectAtIndex:i];
			if ([[SIPUser user] isEqual:[theNotification object]]) {
				if (currentContactsController==i) {
					currentContactsController = -1;
					[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];
				} else {
					[contactsControllers removeObject:SIPUser];
				}
			}
		}
#endif
	}
}

- (void)showUser:(MGMUser *)theUser {
	id contactsController = nil;
	for (int i=0; i<[contactsControllers count]; i++) {
		if ([[[contactsControllers objectAtIndex:i] user] isEqual:theUser]) {
			contactsController = [contactsControllers objectAtIndex:i];
			break;
		}
	}
	if (contactsController==nil) {
		if ([[theUser settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
			contactsController = [MGMVoiceUser voiceUser:theUser accountController:self];
			[contactsControllers addObject:contactsController];
		}
#if MGMSIPENABLED
		else if ([[theUser settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
			if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
			contactsController = [MGMSIPUser SIPUser:theUser accountController:self];
			[contactsControllers addObject:contactsController];
		}
#endif
	}
	if ([theUser isStarted]) {
		currentContactsController = [contactsControllers indexOfObject:contactsController];
		[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];	
	}
	[toolbar setItems:nil animated:YES];
	[self setTitle:[contactsController title]];
	
	CGRect inViewFrame = [[contactsController view] frame];
	inViewFrame.origin.x += inViewFrame.size.width;
	[[contactsController view] setFrame:inViewFrame];
	[contentView addSubview:[contactsController view]];
	[UIView beginAnimations:nil context:accounts];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(contactsControllerAnimationDidStop:finished:contactsController:)];
	[[contactsController view] setFrame:[[accounts view] frame]];
	CGRect outViewFrame = [[accounts view] frame];
	outViewFrame.origin.x -= outViewFrame.size.width;
	[[accounts view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)contactsControllerAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished contactsController:(id<MGMAccountProtocol>)theContactsController {
	[[theContactsController view] removeFromSuperview];
	[theContactsController releaseView];
	if ([theContactsController isKindOfClass:[MGMAccounts class]]) {
		[toolbar setItems:accountItems animated:YES];
	} else {
		if (![[theContactsController user] isStarted])
			[contactsControllers removeObject:theContactsController];
	}
}
@end