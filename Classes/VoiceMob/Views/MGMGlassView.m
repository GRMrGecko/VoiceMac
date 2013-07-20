//
//  MGMGlassView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/9/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMGlassView.h"
#import <MGMUsers/MGMUsers.h>

@implementation MGMGlassView
- (void)drawRect:(CGRect)frameRect {
	CGRect bounds = [self bounds];
	MGMPath *path = [MGMPath pathWithRect:bounds];
	[[UIColor colorWithWhite:0.0 alpha:0.6] setFill];
	[path fill];
	CGRect glassBounds = bounds;
	glassBounds.size.height = glassBounds.size.height/2;
	MGMPath *glassPath = [MGMPath pathWithRect:glassBounds];
	[glassPath fillGradientFrom:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5] to:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
	
	[[UIColor colorWithWhite:0.0 alpha:0.6] setFill];
	CGRect line1Bounds = bounds;
	line1Bounds.size.height = 1;
	MGMPath *line1Path = [MGMPath pathWithRect:line1Bounds];
	[line1Path fill];
	CGRect line3Bounds = line1Bounds;
	line3Bounds.origin.y += bounds.size.height-1;
	MGMPath *line3Path = [MGMPath pathWithRect:line3Bounds];
	[line3Path fill];
	
	[[UIColor colorWithWhite:1.0 alpha:0.1] setFill];
	CGRect line2Bounds = line1Bounds;
	line2Bounds.origin.y += 1;
	MGMPath *line2Path = [MGMPath pathWithRect:line2Bounds];
	[line2Path fill];
	CGRect line4Bounds = line3Bounds;
	line4Bounds.origin.y -= 1;
	MGMPath *line4Path = [MGMPath pathWithRect:line4Bounds];
	[line4Path fill];
}
@end