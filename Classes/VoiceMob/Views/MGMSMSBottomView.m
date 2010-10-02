//
//  MGMSMSBottomView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/1/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSMSBottomView.h"
#import "MGMPath.h"

@implementation MGMSMSBottomView
- (void)drawRect:(CGRect)frameRect {
	UIColor *startColor = [UIColor colorWithRed:0.968627 green:0.972549 blue:0.972549 alpha:1.0];
	UIColor *endColor = [UIColor colorWithRed:0.772549 green:0.780392 blue:0.796078 alpha:1.0];
	
	MGMPath *path = [MGMPath pathWithRect:[self bounds]];
	[path fillGradientFrom:startColor to:endColor];
	CGRect lineRect = [self bounds];
	lineRect.size.height = 1;
	MGMPath *linePath = [MGMPath pathWithRect:lineRect];
	[[UIColor colorWithWhite:0.7 alpha:1.0] setFill];
	[linePath fill];
	lineRect.origin.y += 1;
	MGMPath *line2Path = [MGMPath pathWithRect:lineRect];
	[[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
	[line2Path fill];
}
@end