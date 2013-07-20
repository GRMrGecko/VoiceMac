//
//  MGMViewCell.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/20/10.
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
	subview = (NSView<MGMViewCellProtocol> *)theView;
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