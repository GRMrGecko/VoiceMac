//
//  MGMSMSTextView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/1/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSMSTextView.h"
#import "MGMPath.h"

@implementation MGMSMSTextView
- (void)awakeFromNib {
	[self setBackgroundColor:[UIColor clearColor]];
	[self setContentInset:UIEdgeInsetsMake(-6.0, 3.0, -6.0, -3.0)];
}

- (void)setContentOffset:(CGPoint)theOffset {
	if ([self isTracking] || [self isDecelerating]) {
		if ([self contentSize].height>=130.0) {
			[self setContentInset:UIEdgeInsetsMake(-6.0, 3.0, -4.0, -3.0)];
		} else {
			[self setContentInset:UIEdgeInsetsMake(-6.0, 3.0, -6.0, -3.0)];
		}
		[super setContentOffset:theOffset];
	} else {
		[super setContentOffset:theOffset];
		if ([self contentSize].height>=130.0) {
			[self setScrollEnabled:YES];
			[self setContentInset:UIEdgeInsetsMake(-6.0, 3.0, -2.0, -3.0)];
			if (lastHeight!=[self contentSize].height) {
				lastHeight = [self contentSize].height;
				[self scrollRectToVisible:CGRectMake(0, [self contentSize].height-10, 320, 10) animated:NO];
				[self flashScrollIndicators];
			}
		} else {
			lastHeight = 0;
			[self setScrollEnabled:NO];
			[self setContentInset:UIEdgeInsetsMake(-6.0, 3.0, -6.0, -3.0)];
		}
	}
}

- (void)drawRect:(CGRect)theRect {
	CGRect whitePathBounds = [self bounds];
	CGRect pathBounds = whitePathBounds;
	whitePathBounds.size.width -= 2.0;
	whitePathBounds.origin.x += 1.0;
	whitePathBounds.size.height -= 2.0;
	whitePathBounds.origin.y += 0.7;
	MGMPath *whitePath = [MGMPath pathWithRoundedRect:whitePathBounds cornerRadius:13];
	[[UIColor colorWithWhite:1.0 alpha:1.0] setStroke];
	[whitePath setLineWidth:2.0];
	[whitePath stroke];
	pathBounds.size.height -= 1.0;
	MGMPath *path = [MGMPath pathWithRoundedRect:pathBounds cornerRadius:13];
	[[UIColor colorWithWhite:0.95 alpha:1.0] setFill];
	[[UIColor colorWithWhite:0.4 alpha:1.0] setStroke];
	[path fill];
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	[path addClip];
	CGContextAddPath(currentContext, [path CGPath]);
	CGContextSetShadowWithColor(currentContext, CGSizeMake(0, 1), 3.0, [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor]);
	CGContextStrokePath(currentContext);
	CGContextRestoreGState(currentContext);
	
	[super drawRect:theRect];
}
@end