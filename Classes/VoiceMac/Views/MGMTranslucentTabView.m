//
//  MGMTranslucentTabView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/13/10.
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