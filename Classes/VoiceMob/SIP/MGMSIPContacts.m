//
//  MGMSIPContacts.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIPContacts.h"
#import "MGMSIPUser.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMSIPContacts
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser {
	return [[[self alloc] initWithSIPUser:theSIPUser] autorelease];
}
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser {
	if ((self = [super initWithAccountController:[theSIPUser accountController]])) {
		SIPUser = theSIPUser;
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

- (MGMSIPUser *)SIPUser {
	return SIPUser;
}
- (MGMContacts *)contacts {
	return [SIPUser contacts];
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"SIPContacts"] owner:self options:nil]) {
			NSLog(@"Unable to load SIP Contacts");
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
	[SIPUser showOptionsForNumber:[theContact objectForKey:MGMCNumber]];
	[contactsTable deselectRowAtIndexPath:[contactsTable indexPathForSelectedRow] animated:YES];
}
@end
#endif