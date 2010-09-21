//
//  MGMBottomView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMBottomView.h"
#import "MGMVMAddons.h"

@implementation MGMBottomView
- (void)drawRect:(NSRect)rect {
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
	[path fillGradientFrom:[NSColor colorWithCalibratedWhite:0.992156 alpha:1.0] to:[NSColor colorWithCalibratedWhite:0.886274 alpha:1.0]];
}
@end