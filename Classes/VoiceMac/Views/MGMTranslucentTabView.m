//
//  MGMTranslucentTabView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/13/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMTranslucentTabView.h"

@implementation MGMTranslucentTabView
- (void)awakeFromNib {
	[self setTabViewType:NSNoTabsNoBorder];
	[self setDrawsBackground:NO];
}

- (void)drawRect:(NSRect)frameRect {
	NSRect bounds = [self bounds];
	float lineSize = 2.0;
	float transparency = 0.87;
	NSBezierPath *strokePath = [NSBezierPath bezierPathWithRect:bounds];
	[strokePath setLineWidth:lineSize];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:bounds];
	
	[[NSColor colorWithCalibratedWhite:1.0 alpha:transparency] set];
	[path fill];
	[[NSColor colorWithCalibratedWhite:transparency-0.3 alpha:1.0] set];
	[strokePath stroke];
	[super drawRect:frameRect];
}
@end