//
//  MGMMultiSMS.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/30/10.
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

#import "MGMMultiSMS.h"
#import "MGMController.h"
#import "MGMSMSTextView.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

@implementation MGMMultiSMS
+ (id)SMSWithInstance:(MGMInstance *)theInstance controller:(MGMController *)theController {
	return [[[self alloc] initWithInstance:theInstance  controller:theController] autorelease];
}
- (id)initWithInstance:(MGMInstance *)theInstance controller:(MGMController *)theController {
	if ((self = [super init])) {
		if (![NSBundle loadNibNamed:@"MultiSMS" owner:self]) {
			NSLog(@"Unable to load Multiple SMS Window.");
			[self release];
			self = nil;
		} else {
			instance = theInstance;
			controller = theController;
			[SMSWindow setFrameAutosaveName:[@"multipleSMS" stringByAppendingString:[[instance user] settingForKey:MGMUserID]]];
			[SMSWindow setTitle:[NSString stringWithFormat:@"%@ (%@)", [SMSWindow title], [[instance userNumber] readableNumber]]];
			NSArray *groups = [[instance contacts] groups];
			NSMenu *menu = [[NSMenu new] autorelease];
			NSMenuItem *noneMenuItem = [[NSMenuItem new] autorelease];
			[noneMenuItem setTitle:@"None"];
			[noneMenuItem setTag:-1];
			[menu addItem:noneMenuItem];
			if ([groups count]>0) {
				[menu addItem:[NSMenuItem separatorItem]];
				for (int i=0; i<[groups count]; i++) {
					NSDictionary *group = [groups objectAtIndex:i];
					NSMenuItem *item = [[NSMenuItem new] autorelease];
					[item setTitle:[NSString stringWithFormat:@"%@ (%@)", [group objectForKey:MGMCName], [[instance contacts] membersCountOfGroup:group]]];
					[item setTag:[[group objectForKey:MGMCDocID] longValue]];
					[menu addItem:item];
				}
			}
			[groupsPopUp setMenu:menu];
			[SMSWindow makeKeyAndOrderFront:self];
		}
	}
	return self;
}

- (MGMInstance *)instance {
	return instance;
}
- (MGMController *)controller {
	return controller;
}
- (NSWindow *)SMSWindow {
	return SMSWindow;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex {
	return [[instance contacts] contactCompletionsMatching:substring];
}

- (IBAction)sendMessage:(id)sender {
	NSMutableArray *SMSNumbers = [NSMutableArray array];
	if ([[groupsPopUp selectedItem] tag]!=-1) {
		NSArray *members = [[instance contacts] membersOfGroupID:[NSNumber numberWithInt:[[groupsPopUp selectedItem] tag]]];
		for (unsigned int i=0; i<[members count]; i++) {
			[SMSNumbers addObject:[[members objectAtIndex:i] objectForKey:MGMCNumber]];
		}
	}
	if (![[[additionalField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqual:@""]) {
		NSArray *numbers = [[additionalField stringValue] componentsSeparatedByString:@","];
		for (unsigned int i=0; i<[numbers count]; i++) {
			NSString *number = [numbers objectAtIndex:i];
			if ([number containsString:@"<"]) {
				NSRange range = [number rangeOfString:@"<"];
				if (range.location!=NSNotFound) {
					NSString *string = [number substringFromIndex:range.location+range.length];
					range = [string rangeOfString:@">"];
					if (range.location==NSNotFound) {
						NSLog(@"failed 0017");
					} else {
						number = [[string substringWithRange:NSMakeRange(0, range.location)] phoneFormat];
					}
				}
			} else {
				if ([number hasPrefix:@"("]) {
					number = [number phoneFormatWithAreaCode:[instance userAreaCode]];
				} else {
					NSRange range = [number rangeOfString:@"("];
					if (range.location!=NSNotFound) {
						number = [number substringToIndex:range.location-1];
					}
					number = [number phoneFormatWithAreaCode:[instance userAreaCode]];
				}
			}
			[SMSNumbers addObject:number];
		}
	}
	if ([SMSNumbers count]<=0) {
		NSAlert *theAlert = [[NSAlert new] autorelease];
		[theAlert setMessageText:@"Error sending a SMS Message"];
		[theAlert setInformativeText:@"You need to at least have 1 contact to send to."];
		[theAlert runModal];
	} else {
		if ([[SMSTextView string] isEqual:@""])
			return;
		sendingMessage = YES;
		[sendButton setTitle:@"Sending..."];
		[sendButton setEnabled:NO];
		[cancelButton setEnabled:NO];
		[[instance inbox] sendMessage:[SMSTextView string] phoneNumbers:SMSNumbers smsID:@"" delegate:self];
	}
}
- (void)message:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	sendingMessage = NO;
	[SMSTextView setEditable:YES];
	[sendButton setTitle:@"Send"];
	[sendButton setEnabled:YES];
	[cancelButton setEnabled:YES];
	[SMSWindow makeFirstResponder:SMSTextView];
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert addButtonWithTitle:@"Ok"];
	[theAlert setMessageText:@"Error sending a SMS Message"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert setAlertStyle:2];
	[theAlert runModal];
}
- (void)messageDidFinish:(MGMDelegateInfo *)theInfo instance:(MGMInstance *)theInstance {
	sendingMessage = NO;
	[SMSWindow close];
}
- (IBAction)cancel:(id)sender {
	[SMSWindow close];
}

- (BOOL)windowShouldClose:(id)sender {
	if (sendingMessage) {
		NSAlert *theAlert = [[NSAlert new] autorelease];
		[theAlert setMessageText:@"Sending a SMS Message"];
		[theAlert setInformativeText:@"Your SMS Message is currently being sent, please wait for it to be sent."];
		[theAlert runModal];
		return NO;
	}
	return YES;
}
- (void)windowWillClose:(NSNotification *)notification {
	[SMSWindow setDelegate:nil];
	[controller removeMultiSMS:self];
}
@end