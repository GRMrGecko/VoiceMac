//
//  MGMViewCell.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/20/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMViewCell.h"
#import "MGMVMAddons.h"

@implementation MGMViewCell
- (id)initGradientCell {
	if ((self = [super init])) {
		gradient = YES;
	}
	return self;
}

- (void)addSubview:(NSView *)theView {
	subview = theView;
}
- (NSView *)view {
	return subview;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[super drawWithFrame:cellFrame inView:controlView];
	
	[subview setFrame:cellFrame];
    if ([subview superview]!=controlView)
		[controlView addSubview:subview];
}
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if ([self isHighlighted])
		[subview setFontColor:[NSColor whiteColor]];
	else
		[subview setFontColor:[NSColor blackColor]];
	if (!gradient || ![self isHighlighted]) {
		[super drawInteriorWithFrame:cellFrame inView:controlView];
	} else {
		[controlView lockFocus];
		
		NSColor *startColor = nil;
		NSColor *endColor = nil;
		if ([[controlView window] isKeyWindow]) {
			startColor = [NSColor colorWithCalibratedRed:MGMHLKSRed green:MGMHLKSGreen blue:MGMHLKSBlue alpha:1.0];
			endColor = [NSColor colorWithCalibratedRed:MGMHLKERed green:MGMHLKEGreen blue:MGMHLKEBlue alpha:1.0];
		} else {
			startColor = [NSColor colorWithCalibratedRed:MGMHLSRed green:MGMHLSGreen blue:MGMHLSBlue alpha:1.0];
			endColor = [NSColor colorWithCalibratedRed:MGMHLERed green:MGMHLEGreen blue:MGMHLEBlue alpha:1.0];
		}
		
		NSRect drawingRect = [self drawingRectForBounds:cellFrame];
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:drawingRect];
		[path fillGradientFrom:startColor to:endColor];
		path = [NSBezierPath bezierPathWithRect:NSMakeRect(drawingRect.origin.x, drawingRect.origin.y, drawingRect.size.width, 1.0)];
		[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.15] set];
		[path fill];
		
		[controlView unlockFocus];
	}
}
@end