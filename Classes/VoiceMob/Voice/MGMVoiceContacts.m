//
//  MGMVoiceContacts.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMVoiceContacts.h"
#import "MGMVoiceUser.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMVoiceSMS.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMVoiceContacts
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	return [[[self alloc] initWithVoiceUser:theVoiceUser] autorelease];
}
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	if ((self = [super initWithAccountController:[theVoiceUser accountController]])) {
		voiceUser = theVoiceUser;
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[super dealloc];
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
		} else {
			[super awakeFromNib];
		}
	}
	return view;
}
- (void)releaseView {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[view release];
	view = nil;
	[super releaseView];
}

- (void)selectedContact:(NSDictionary *)theContact {
	[voiceUser showOptionsForNumber:[theContact objectForKey:MGMCNumber]];
	[contactsTable deselectRowAtIndexPath:[contactsTable indexPathForSelectedRow] animated:YES];
}
@end