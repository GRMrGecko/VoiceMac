//
//  MGMVoiceVerify.m
//  VoiceMac
//
//  Created by James on 3/17/11.
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

#import "MGMVoiceVerify.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

@implementation MGMVoiceVerify
+ (id)verifyWithInstance:(MGMInstance *)theInstance {
	return [[[self alloc] initWithInstance:theInstance] autorelease];
}
- (id)initWithInstance:(MGMInstance *)theInstance {
	if ((self = [super init])) {
		if (![NSBundle loadNibNamed:@"VoiceVerify" owner:self]) {
			NSLog(@"Unable to load Voice Verification.");
			[theInstance cancelVerification];
			[self release];
			self = nil;
		} else {
			instance = theInstance;
			[accountNameField setStringValue:[[instance user] settingForKey:MGMUserName]];
			[window makeKeyAndOrderFront:self];
		}
	}
	return self;
}
- (void)dealloc {
	[window release];
	[super dealloc];
}

- (IBAction)verify:(id)sender {
	[window close];
	[instance verifyWithCode:[codeField stringValue]];
}
- (IBAction)cancel:(id)sender {
	[window close];
	[instance cancelVerification];
}
@end