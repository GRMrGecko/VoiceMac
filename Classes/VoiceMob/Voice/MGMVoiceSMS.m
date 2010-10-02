//
//  MGMVoiceSMS.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVoiceSMS.h"
#import "MGMVoiceUser.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMVoiceSMS
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	return [[[self alloc] initWithVoiceUser:theVoiceUser] autorelease];
}
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	if (self = [super init]) {
		voiceUser = theVoiceUser;
	}
	return self;
}
- (void)dealloc {
	[self releaseView];
	[super dealloc];
}

- (MGMVoiceUser *)voiceUser {
	return voiceUser;
}

- (UIView *)view {
	if (messageView==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoiceSMS"] owner:self options:nil]) {
			NSLog(@"Unable to load Voice SMS");
			[self release];
			self = nil;
		} else {
			
		}
	}
	return messageView;
}
- (void)releaseView {
	if (messageView!=nil) {
		[messageView release];
		messageView = nil;
	}
}
@end