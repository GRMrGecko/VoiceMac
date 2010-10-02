//
//  MGMVoicePad.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVoicePad.h"
#import "MGMVoiceUser.h"
#import "MGMNumberView.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>
 
@implementation MGMVoicePad
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
	if (numberString!=nil)
		[numberString release];
	[super dealloc];
}

- (MGMVoiceUser *)voiceUser {
	return voiceUser;
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoicePad"] owner:self options:nil]) {
			NSLog(@"Unable to load Voice Pad");
			[self release];
			self = nil;
		} else {
			if (numberString!=nil)
				[numberView setNumber:numberString];
			else
				[numberView setNumber:@""];
		}
	}
	return view;
}
- (void)releaseView {
	if (view!=nil) {
		[view release];
		view = nil;
	}
}

- (IBAction)dial:(id)sender {
	NSString *number = [numberView number];
	if ([number length]==0 && [sender tag]==0) {
		[numberView setNumber:@"+"];
	} else {
		NSString *numberAdd = nil;
		switch ([sender tag]) {
			case 10:
			case 11:
				break;
			default:
				numberAdd = [[NSNumber numberWithInt:[sender tag]] stringValue];
				break;
		}
		if (numberAdd!=nil)
			number = [number stringByAppendingString:numberAdd];
		if (numberString!=nil) [numberString release];
		numberString = [[number readableNumber] copy];
		[numberView setNumber:numberString];
	}
}
- (IBAction)delete:(id)sender {
	NSString *number = [numberView number];
	if ([number length]!=0) {
		number = [number substringToIndex:[number length]-1];
		if (numberString!=nil) [numberString release];
		numberString = [[number readableNumber] copy];
		[numberView setNumber:numberString];
	}
}
- (IBAction)call:(id)sender {
	if ([numberString isPhoneComplete]) {
		[voiceUser call:[numberString phoneFormatWithAreaCode:[voiceUser areaCode]]];
	} else {
		UIAlertView *theAlert = [[UIAlertView new] autorelease];
		[theAlert setTitle:@"Incorrect Number"];
		[theAlert setMessage:@"The phone number you have entered is incorrect."];
		[theAlert addButtonWithTitle:MGMOkButtonTitle];
		[theAlert show];
	}
}
@end