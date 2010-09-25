//
//  MGMController.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMController.h"
#import "MGMAccountSetup.h"
#import "MGMVMAddons.h"

@implementation MGMController
- (void)awakeFromNib {
	NSLog(@"Device is %@", ([[UIDevice currentDevice] isPad] ? @"iPad" : @"iPhone/iPod"));
	MGMAccountSetup *accountSetup = [MGMAccountSetup new];
	[accountSetup displayStep];
	[[self view] addSubview:[accountSetup view]];
	[mainWindow addSubview:[self view]];
	[mainWindow makeKeyAndVisible];
}
@end