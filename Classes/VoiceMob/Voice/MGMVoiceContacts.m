//
//  MGMVoiceContacts.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVoiceContacts.h"
#import "MGMVoiceUser.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMVoiceContacts
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	return [[[self alloc] initWithVoiceUser:theVoiceUser] autorelease];
}
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	if (self = [super initWithAccountController:[theVoiceUser accountController]]) {
		voiceUser = theVoiceUser;
	}
	return self;
}

- (MGMVoiceUser *)voiceUser {
	return voiceUser;
}
- (MGMContacts *)contacts {
	return [[voiceUser instance] contacts];
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoiceContacts"] owner:self options:nil]) {
			NSLog(@"Unable to load Voice Contacts");
			[self release];
			self = nil;
		} else {
			[super awakeFromNib];
		}
	}
	return view;
}
- (void)releaseView {
	if (view!=nil) {
		[view release];
		view = nil;
	}
	[super releaseView];
}

- (void)selectedContact:(NSDictionary *)theContact {
	selectedContact = theContact;
	UIActionSheet *theAction = [[UIActionSheet new] autorelease];
	[theAction addButtonWithTitle:@"Call"];
	[theAction addButtonWithTitle:@"SMS"];
	[theAction addButtonWithTitle:@"Reverse Lookup"];
	[theAction addButtonWithTitle:@"Cancel"];
	[theAction setCancelButtonIndex:3];
	[theAction setDelegate:self];
	[theAction showInView:[voiceUser view]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex==0) {
		[voiceUser call:[selectedContact objectForKey:MGMCNumber]];
	}
	selectedContact = nil;
	[contactsTable deselectRowAtIndexPath:[contactsTable indexPathForSelectedRow] animated:YES];
}
@end