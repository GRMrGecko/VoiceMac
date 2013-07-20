//
//  MGMVMAddons.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
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

@implementation UIScreen (MGMVMAddons)
- (BOOL)isRetina {
	return ([self respondsToSelector:@selector(scale)] && [self scale]==2);
}
@end

@implementation UIColor (MGMVMAddons)
- (UIColor *)colorWithDifference:(CGFloat)theDifference {
	CGColorRef colorRef = [self CGColor];
	CGColorSpaceRef colorspace = CGColorGetColorSpace(colorRef);
	size_t componentsCount = CGColorGetNumberOfComponents(colorRef);
	const CGFloat *componentsRef = CGColorGetComponents(colorRef);
	CGFloat *components = malloc(sizeof(CGFloat)*componentsCount);
	memcpy(components, componentsRef, sizeof(CGFloat)*componentsCount);
	CGFloat *colorComponents = components;
	for (size_t i=0; i<(componentsCount-1); i++) {
		CGFloat value = *components+theDifference;
		if (value>=0.0 && value<=1.0)
			*components = value;
		components++;
	}
	CGColorRef newColor = CGColorCreate(colorspace, colorComponents);
	UIColor *color = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
	free(colorComponents);
	return color;
}
@end