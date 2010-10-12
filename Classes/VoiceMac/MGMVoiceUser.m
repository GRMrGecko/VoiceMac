//
//  MGMVoiceUser.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVoiceUser.h"
#import "MGMController.h"
#import "MGMProgressView.h"
#import "MGMContactView.h"
#import "MGMPhoneFeild.h"
#import "MGMSMSManager.h"
#import "MGMInboxWindow.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

NSString *MGMLastUserPhoneKey = @"MGMLastUserPhone";

@implementation MGMVoiceUser
+ (id)voiceUser:(MGMUser *)theUser controller:(MGMController *)theController {
	return [[[self alloc] initUser:theUser controller:theController instance:nil] autorelease];
}
+ (id)voiceUser:(MGMUser *)theUser controller:(MGMController *)theController instance:(MGMInstance *)theInstance {
	return [[[self alloc] initUser:theUser controller:theController instance:theInstance] autorelease];
}
- (id)initUser:(MGMUser *)theUser controller:(MGMController *)theController instance:(MGMInstance *)theInstance {
	if (self = [super initWithController:theController]) {
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
	if (progressFadeAnimation!=nil) {
		[progressFadeAnimation stopAnimation];
		[progressFadeAnimation release];
		progressFadeAnimation = nil;
	}
	[super dealloc];
	if (inboxWindow!=nil) {
		[inboxWindow closeWindow];
		[inboxWindow release];
	}
	if (instance!=nil) {
		[instance setDelegate:nil];
		[instance stop];
		[instance release];
	}
	if (progressView!=nil) {
		[progressView removeFromSuperview];
		[progressView release];
	}
	if (callTimer!=nil) {
		[callTimer invalidate];
		[callTimer release];
	}
	if (user!=nil)
		[user release];
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
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert setMessageText:@"Error logging in"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert runModal];
	
	if (progressView!=nil) {
		[progressView stopProgess];
		[progressView removeFromSuperview];
		[progressView release];
		progressView = nil;
	}
}
- (void)loginSuccessful {
	if (progressView!=nil) {
		[progressView stopProgess];
		[progressView display];
	}
	
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
	if (contactsWindow==nil) return;
	if ([instance isLoggedIn]) {
		[userNumberButton setTitle:[[instance userNumber] readableNumber]];
		[userPhonesButton removeAllItems];
		NSArray *phones = [instance userPhoneNumbers];
		for (int i=0; i<[phones count]; i++) {
			NSDictionary *phone = [phones objectAtIndex:i];
			[userPhonesButton addItemWithTitle:[NSString stringWithFormat:@"%@ [%@]", [[phone objectForKey:MGMPhoneNumber] readableNumber], [phone objectForKey:MGMName]]];
			[userPhonesButton selectItemAtIndex:0];
		}
		[userPhonesButton selectItemAtIndex:[[user settingForKey:MGMLastUserPhoneKey] intValue]];
	}
}
- (void)animationDidEnd:(NSAnimation *)animation {
	if (progressFadeAnimation!=nil) {
		[progressFadeAnimation release];
		progressFadeAnimation = nil;
	}
	if (progressView!=nil) {
		[progressView removeFromSuperview];
		[progressView release];
		progressView = nil;
	}
}

- (MGMContacts *)contacts {
	return [instance contacts];
}

- (void)reloadData {
	[super reloadData];
	if (progressView!=nil) [progressView display];
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
	} else {
		if ([userPhonesButton indexOfSelectedItem]==-1) {
			NSBeep();
			return;
		}
		
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
- (void)call:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Call Failed"];
	[alert setInformativeText:[theError localizedDescription]];
	[alert runModal];
	placingCall = NO;
	if (callTimer!=nil)
		[callTimer fire];
}
- (void)callDidFinish:(NSDictionary *)theInfo {
	placingCall = NO;
	NSLog(@"YEA! We Made The Call!");
}
- (void)callCancel:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Call Cancel Failed"];
	[alert setInformativeText:[theError localizedDescription]];
	[alert runModal];
}
- (void)callTimer {
	if (callTimer!=nil) {
		[callTimer invalidate];
		[callTimer release];
		callTimer = nil;
	}
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
- (void)updateCredit:(NSString *)credit {
	[creditField setStringValue:credit];
}

- (IBAction)viewSettings:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.google.com/voice/#phones"]];
}

- (void)windowWillClose:(NSNotification *)notification {
	if (![controller isQuitting])
		[user setSetting:[NSNumber numberWithBool:NO] forKey:MGMContactsWindowOpen];
	[super windowWillClose:notification];
	if (progressFadeAnimation!=nil) {
		[progressFadeAnimation stopAnimation];
		[progressFadeAnimation release];
		progressFadeAnimation = nil;
	}
	creditField = nil;
	userNumberButton = nil;
	userPhonesButton = nil;
	callButton = nil;
	smsButton = nil;
}
@end