//
//  MGMVoiceUser.m
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

#import "MGMVoiceUser.h"
#import "MGMController.h"
#import "MGMVoiceVerify.h"
#import "MGMProgressView.h"
#import "MGMContactView.h"
#import "MGMPhoneFeild.h"
#import "MGMSMSManager.h"
#import "MGMInboxWindow.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

NSString * const MGMLastUserPhoneKey = @"MGMLastUserPhone";

@implementation MGMVoiceUser
+ (id)voiceUser:(MGMUser *)theUser controller:(MGMController *)theController {
	return [[[self alloc] initUser:theUser controller:theController instance:nil] autorelease];
}
+ (id)voiceUser:(MGMUser *)theUser controller:(MGMController *)theController instance:(MGMInstance *)theInstance {
	return [[[self alloc] initUser:theUser controller:theController instance:theInstance] autorelease];
}
- (id)initUser:(MGMUser *)theUser controller:(MGMController *)theController instance:(MGMInstance *)theInstance {
	if ((self = [super initWithController:theController])) {
		user = [theUser retain];
		[self registerSettings];
		if (theInstance==nil) {
			instance = [[MGMInstance instanceWithUser:user delegate:self] retain];
		} else {
			instance = [theInstance retain];
			[instance setDelegate:self];
			if ([instance isLoggedIn])
				[self loginSuccessful];
		}
		inboxWindow = [[MGMInboxWindow windowWithInstance:instance] retain];
		if ([[user settingForKey:MGMContactsWindowOpen] boolValue])
			[self showContactsWindow];
	}
	return self;
}
- (void)awakeFromNib {
	[super awakeFromNib];
	
	[contactsWindow setFrameAutosaveName:[@"contactsWindow" stringByAppendingString:[user settingForKey:MGMUserID]]];
	
	if (![instance isLoggedIn]) {
		NSSize contentSize = [[contactsWindow contentView] frame].size;
		progressView = [[MGMProgressView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
		[progressView setProgressTitle:@"Logging In"];
		[[contactsWindow contentView] addSubview:progressView];
		[progressView startProgess];
		[contactsWindow makeFirstResponder:progressView];
	} else {
		[self setInstanceInfo];
	}
}
- (void)dealloc {
	[progressFadeAnimation stopAnimation];
	[progressFadeAnimation release];
	progressFadeAnimation = nil;
	[inboxWindow closeWindow];
	[inboxWindow release];
	[instance setDelegate:nil];
	[instance stop];
	[instance release];
	[progressView removeFromSuperview];
	[progressView release];
	[callTimer invalidate];
	[callTimer release];
	[user release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)registerSettings {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setObject:[NSNumber numberWithInt:0] forKey:MGMLastUserPhoneKey];
	[settings setObject:[NSNumber numberWithBool:YES] forKey:MGMContactsWindowOpen];
	[user registerSettings:settings];
}

- (NSString *)menuTitle {
	return [user settingForKey:MGMUserName];
}
- (void)showContactsWindow {
	if (contactsWindow==nil) {
		if (![NSBundle loadNibNamed:@"VoiceUser" owner:self]) {
			NSLog(@"Error: Unable to load Voice User!");
		} else {
			[user setSetting:[NSNumber numberWithBool:YES] forKey:MGMContactsWindowOpen];
		}
	}
	[contactsWindow makeKeyAndOrderFront:self];
}
- (MGMInstance *)instance {
	return instance;
}
- (MGMUser *)user {
	return user;
}
- (MGMInboxWindow *)inboxWindow {
	return inboxWindow;
}

- (void)loginError:(NSError *)theError {
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Error logging in"];
	[alert setInformativeText:[theError localizedDescription]];
	[alert runModal];
	
	[verifyWindow release];
	verifyWindow = nil;
	[progressView stopProgess];
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
}
- (void)loginVerificationRequested {
	[verifyWindow release];
	verifyWindow = [[MGMVoiceVerify verifyWithInstance:instance] retain];
}
- (void)loginSuccessful {
	[verifyWindow release];
	verifyWindow = nil;
	[progressView stopProgess];
	[progressView display];
	
	[self setInstanceInfo];
	
	if (progressView!=nil) {
		NSMutableDictionary *animationInfo = [NSMutableDictionary dictionary];
		[animationInfo setObject:progressView forKey:NSViewAnimationTargetKey];
		[animationInfo setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
		progressFadeAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animationInfo]];
		[progressFadeAnimation setDuration:1.0];
		[progressFadeAnimation setDelegate:self];
		[progressFadeAnimation startAnimation];
	}
}
- (void)setInstanceInfo {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becameActive) name:NSApplicationDidBecomeActiveNotification object:nil];
	if (contactsWindow==nil) return;
	if ([instance isLoggedIn]) {
		[userNumberButton setTitle:[[instance userNumber] readableNumber]];
		[self updatedUserPhones];
	}
}
- (void)animationDidEnd:(NSAnimation *)animation {
	[progressFadeAnimation release];
	progressFadeAnimation = nil;
	[progressView removeFromSuperview];
	[progressView release];
	progressView = nil;
}

- (MGMContacts *)contacts {
	return [instance contacts];
}

- (void)reloadData {
	[super reloadData];
	[progressView display];
}

- (void)becameActive {
	[instance checkPhones];
}
- (void)updatedUserPhones {
	[userPhonesButton removeAllItems];
	NSArray *phones = [instance userPhoneNumbers];
	for (int i=0; i<[phones count]; i++) {
		NSDictionary *phone = [phones objectAtIndex:i];
		[userPhonesButton addItemWithTitle:[NSString stringWithFormat:@"%@ [%@]", [[phone objectForKey:MGMPhoneNumber] readableNumber], [phone objectForKey:MGMName]]];
		[userPhonesButton selectItemAtIndex:0];
	}
	if ([[instance userPhoneNumbers] count]>=1) {
		if ([[instance userPhoneNumbers] count]<([[user settingForKey:MGMLastUserPhoneKey] intValue]+1))
			[user setSetting:[NSNumber numberWithInt:0] forKey:MGMLastUserPhoneKey];
		[userPhonesButton selectItemAtIndex:[[user settingForKey:MGMLastUserPhoneKey] intValue]];
	}
}

- (NSString *)areaCode {
	if (![instance isLoggedIn])
		return nil;
	return [instance userAreaCode];
}
- (NSString *)currentPhoneNumber {
	NSString *phoneNumber = nil;
	if ([[NSApplication sharedApplication] mainWindow]==[inboxWindow inboxWindow])
		phoneNumber = [inboxWindow currentPhoneNumber];
	if (phoneNumber==nil)
		phoneNumber = [super currentPhoneNumber];
	return phoneNumber;
}

- (BOOL)isPlacingCall {
	return (callTimer!=nil);
}
- (void)donePlacingCall {
	[callTimer fire];
}
- (IBAction)runAction:(id)sender {
	if ([[user settingForKey:MGMSContactsActionKey] intValue]==0) {
		[self call:sender];
	} else {
		[self sms:sender];
	}
}
- (IBAction)call:(id)sender {
	if (callTimer!=nil) {
		placingCall = NO;
		[callTimer invalidate];
		[callTimer release];
		callTimer = nil;
		if (placingCall)
			[[instance connectionManager] cancelAll];
		[callButton setImage:[NSImage imageNamed:@"placeCall"]];
		[instance cancelCallWithDelegate:self];
	} else if ([[instance userPhoneNumbers] count]<=0) {
		NSAlert *alert = [[NSAlert new] autorelease];
		[alert setMessageText:@"Call Failed"];
		[alert setInformativeText:@"You need to have a phone number setup with your Google Voice account. To add one, click your Google Voice number at the bottom left of your Contacts window and add a phone number. Once you got a phone number setup with Google Voice, reopen VoiceMac."];
		[alert runModal];
	} else {
		NSString *phoneNumber = [controller currentPhoneNumber];
		if (phoneNumber==nil || [phoneNumber isEqual:@""]) {
			NSBeep();
			return;
		}
		
		[user setSetting:[NSNumber numberWithInt:[userPhonesButton indexOfSelectedItem]] forKey:MGMLastUserPhoneKey];
		
		placingCall = YES;
		[callButton setImage:[NSImage imageNamed:@"cancelCall"]];
		callTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(callTimer) userInfo:nil repeats:NO] retain];
		[instance placeCall:phoneNumber usingPhone:[userPhonesButton indexOfSelectedItem] delegate:self];
	}
}
- (void)call:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError {
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Call Failed"];
	[alert setInformativeText:[theError localizedDescription]];
	[alert runModal];
	placingCall = NO;
	[callTimer fire];
}
- (void)callDidFinish:(MGMDelegateInfo *)theInfo {
	placingCall = NO;
	NSLog(@"YEA! We Made The Call!");
}
- (void)callCancel:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError {
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Call Cancel Failed"];
	[alert setInformativeText:[theError localizedDescription]];
	[alert runModal];
}
- (void)callTimer {
	[callTimer invalidate];
	[callTimer release];
	callTimer = nil;
	[callButton setImage:[NSImage imageNamed:@"placeCall"]];
}

- (IBAction)sms:(id)sender {
	NSString *phoneNumber = [controller currentPhoneNumber];
	if (phoneNumber==nil || [phoneNumber isEqual:@""]) {
		NSBeep();
		return;
	}
	
	[[controller SMSManager] messageWithNumber:phoneNumber instance:instance];
}

- (void)updateUnreadCount:(int)theCount {
	[controller setBadge:theCount forInstance:instance];
}
- (void)updateVoicemail {
	[inboxWindow checkVoicemail];
}
- (void)updateSMS {
	[[controller SMSManager] checkSMSMessagesForInstance:instance];
}
- (void)updateCredit:(NSString *)theCredit {
	[creditField setStringValue:theCredit];
}

- (IBAction)viewSettings:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.google.com/voice/#phones"]];
}

- (void)windowWillClose:(NSNotification *)notification {
	if (![controller isQuitting])
		[user setSetting:[NSNumber numberWithBool:NO] forKey:MGMContactsWindowOpen];
	[progressFadeAnimation stopAnimation];
	[progressFadeAnimation release];
	progressFadeAnimation = nil;
	creditField = nil;
	userNumberButton = nil;
	userPhonesButton = nil;
	callButton = nil;
	smsButton = nil;
	[super windowWillClose:notification];
}
@end