//
//  MGMSIPUser.m
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
#import "MGMSIPUser.h"
#import "MGMSIPCallWindow.h"
#import "MGMController.h"
#import "MGMVoiceUser.h"
#import "MGMProgressView.h"
#import "MGMPhoneFeild.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

NSString * const MGMSIPUserAreaCode = @"MGMVSIPUserAreaCode";
NSString * const MGMSIPExitCode = @"MGMVSIPExitCode";

@implementation MGMSIPUser
+ (id)SIPUser:(MGMUser *)theUser controller:(MGMController *)theController {
	return [[[self alloc] initUser:theUser controller:theController] autorelease];
}
- (id)initUser:(MGMUser *)theUser controller:(MGMController *)theController {
	if ((self = [super initWithController:theController])) {
		user = [theUser retain];
		[user setDelegate:self];
		[self registerSettings];
		account = [[MGMSIPAccount alloc] initWithSettings:[user settings]];
		[account setDelegate:self];
		calls = [NSMutableArray new];
		loggingIn = YES;
		acountRegistered = NO;
		[NSThread detachNewThreadSelector:@selector(login) toTarget:account withObject:nil];
		contacts = [[MGMContacts contactsWithClass:NSClassFromString([user settingForKey:MGMSContactsSourceKey]) delegate:self] retain];
		[contacts updateContacts];
		if ([[user settingForKey:MGMContactsWindowOpen] boolValue])
			[self showContactsWindow];
	}
	return self;
}
- (void)awakeFromNib {
	[contactsWindow setFrameAutosaveName:[@"contactsWindow" stringByAppendingString:[user settingForKey:MGMUserID]]];
	
	[super awakeFromNib];
	
	NSString *userName = [user settingForKey:MGMUserName];
	if ([userName isPhoneComplete])
		userName = [userName readableNumber];
	else if ([user settingForKey:MGMSIPAccountFullName]!=nil && ![[user settingForKey:MGMSIPAccountFullName] isEqual:@""])
		userName = [user settingForKey:MGMSIPAccountFullName];
	[userNameField setStringValue:userName];
	
	if (![account isRegistered]) {
		NSSize contentSize = [[contactsWindow contentView] frame].size;
		progressView = [[MGMProgressView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
		[progressView setProgressTitle:@"Logging In"];
		[[contactsWindow contentView] addSubview:progressView];
		[progressView startProgess];
		[contactsWindow makeFirstResponder:progressView];
	}
}
- (void)dealloc {
	[account setDelegate:nil];
	[contacts setDelegate:nil];
	[progressFadeAnimation stopAnimation];
	[progressFadeAnimation release];
	progressFadeAnimation = nil;
	[progressView stopProgess];
	[progressView release];
	[SIPRegistrationTimeout invalidate];
	[SIPRegistrationTimeout release];
	[calls removeAllObjects];
	[calls release];
	[account logout];
	[account release];
	[contacts stop];
	[contacts release];
	[user release];
	[super dealloc];
}

- (void)registerSettings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setObject:NSStringFromClass([MGMAddressBook class]) forKey:MGMSContactsSourceKey];
	[settings setObject:[NSNumber numberWithBool:YES] forKey:MGMContactsWindowOpen];
	[user registerSettings:settings];
}

- (NSString *)menuTitle {
	NSString *userName = [user settingForKey:MGMUserName];
	if ([user settingForKey:MGMSIPAccountFullName]!=nil && ![[user settingForKey:MGMSIPAccountFullName] isEqual:@""])
		userName = [user settingForKey:MGMSIPAccountFullName];
	if ([userName isPhone])
		userName = [userName readableNumber];
	return userName;
}
- (void)showContactsWindow {
	if (contactsWindow==nil) {
		if (![NSBundle loadNibNamed:@"SIPUser" owner:self]) {
			NSLog(@"Error: Unable to load SIP User!");
		} else {
			[user setSetting:[NSNumber numberWithBool:YES] forKey:MGMContactsWindowOpen];
		}
	}
	[contactsWindow makeKeyAndOrderFront:self];
}
- (MGMUser *)user {
	return user;
}
- (NSArray *)calls {
	return calls;
}

- (NSString *)password {
	return [user password];
}

- (void)registrationChanged {
	[SIPRegistrationTimeout invalidate];
	[SIPRegistrationTimeout release];
	SIPRegistrationTimeout = nil;
	if (!acountRegistered) {
		if (![account isRegistered]) {
			NSAlert *alert = [[NSAlert new] autorelease];
			[alert setMessageText:@"Error logging in"];
			[alert setInformativeText:@"Unable to Register with Server. Please check your credentials."];
			[alert runModal];
		}
		acountRegistered = YES;
		[self performSelectorOnMainThread:@selector(removeLoginProgress) withObject:nil waitUntilDone:YES];
	}
}
- (void)loggedIn {
	loggingIn = NO;
	[self performSelectorOnMainThread:@selector(startRegistrationTimeoutTimer) withObject:nil waitUntilDone:YES];
}
- (void)startRegistrationTimeoutTimer {
	if (!acountRegistered)
		SIPRegistrationTimeout = [[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(SIPTimeout) userInfo:nil repeats:NO] retain];
}
- (void)SIPTimeout {
	[SIPRegistrationTimeout invalidate];
	[SIPRegistrationTimeout release];
	SIPRegistrationTimeout = nil;
	[account setLastError:@"Registration Timeout."];
	[self loginErrored];
}
- (void)removeLoginProgress {
	if (progressView!=nil) {
		[progressView stopProgess];
		[progressView display];
		
		NSMutableDictionary *animationInfo = [NSMutableDictionary dictionary];
		[animationInfo setObject:progressView forKey:NSViewAnimationTargetKey];
		[animationInfo setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
		progressFadeAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animationInfo]];
		[progressFadeAnimation setDuration:1.0];
		[progressFadeAnimation setDelegate:self];
		[progressFadeAnimation startAnimation];
	}
}
- (void)loginErrored {
	loggingIn = NO;
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Error logging in"];
	[alert setInformativeText:[account lastError]];
	[alert runModal];
	
	[progressView stopProgess];
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
	[self performSelectorOnMainThread:@selector(removeLoginProgress) withObject:nil waitUntilDone:YES];
}
- (void)logoutErrored {
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Error logging out"];
	[alert setInformativeText:[account lastError]];
	[alert runModal];
}
- (void)animationDidEnd:(NSAnimation *)animation {
	[progressFadeAnimation release];
	progressFadeAnimation = nil;
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
}

- (MGMContacts *)contacts {
	return contacts;
}

- (void)reloadData {
	[super reloadData];
	[progressView display];
}

- (NSString *)areaCode {
	return [user settingForKey:MGMSIPUserAreaCode];
}
- (IBAction)runAction:(id)sender {
	[self call:sender];
}
- (NSString *)currentPhoneNumber {
	NSString *phoneNumber = nil;
	if (phoneNumber==nil && ![[phoneField stringValue] isPhoneComplete]) {
		if ([contactViews count]>0) {
			[self selectFirstContact];
		} else {
			return [phoneField stringValue];
		}
	}
	if (phoneNumber==nil)
		phoneNumber = [[phoneField stringValue] phoneFormatWithAreaCode:[self areaCode]];
	return phoneNumber;
}
- (IBAction)call:(id)sender {
	NSString *phoneNumber = [controller currentPhoneNumber];
	if (phoneNumber==nil || [phoneNumber isEqual:@""]) {
		NSBeep();
		return;
	}
	if ([phoneNumber hasPrefix:@"011"]) {
		phoneNumber = [phoneNumber substringFromIndex:3];
		if ([user settingForKey:MGMSIPExitCode]!=nil)
			phoneNumber = [[user settingForKey:MGMSIPExitCode] stringByAppendingString:phoneNumber];
	}
	[account makeCallToNumber:phoneNumber];
}

- (NSString *)phoneCalling {
	for (int i=0; i<[[controller contactsControllers] count]; i++) {
		if ([[[controller contactsControllers] objectAtIndex:i] isKindOfClass:[MGMVoiceUser class]] && [[[controller contactsControllers] objectAtIndex:i] isPlacingCall]) {
			MGMVoiceUser *voiceUser = [[controller contactsControllers] objectAtIndex:i];
			[voiceUser donePlacingCall];
			return [voiceUser currentPhoneNumber];
		}
	}
	return nil;
}
- (void)gotNewCall:(MGMSIPCall *)theCall {
	[calls addObject:[MGMSIPCallWindow windowWithCall:theCall SIPUser:self]];
}
- (void)callDone:(MGMSIPCallWindow *)theCall {
	[calls removeObject:theCall];
}

- (BOOL)isUserDone:(MGMUser *)theUser {
	return !loggingIn;
}

- (void)windowWillClose:(NSNotification *)notification {
	if (![controller isQuitting])
		[user setSetting:[NSNumber numberWithBool:NO] forKey:MGMContactsWindowOpen];
	[super windowWillClose:notification];
	[progressFadeAnimation stopAnimation];
	[progressFadeAnimation release];
	progressFadeAnimation = nil;
}
@end
#endif