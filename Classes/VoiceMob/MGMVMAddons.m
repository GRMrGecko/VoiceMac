//
//  MGMVMAddons.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVMAddons.h"

@implementation UIDevice (MGMVMAddons)
- (BOOL)isPad {
	if ([self respondsToSelector:@selector(userInterfaceIdiom)])
		return ([self userInterfaceIdiom]==UIUserInterfaceIdiomPad);
	return NO;
}
- (NSString *)appendDeviceSuffixToString:(NSString *)theString {
	if ([self isPad])
		return [theString stringByAppendingString:@"_iPad"];
	else
		return [theString stringByAppendingString:@"_iPhone"];
}
@end