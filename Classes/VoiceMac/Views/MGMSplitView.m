//
//  MGMSplitView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSplitView.h"

@implementation MGMSplitView
- (CGFloat)dividerThickness {
	return 2.0;
}
- (void)drawDividerInRect:(NSRect)aRect {
	[[NSColor lightGrayColor] set];
	NSRectFill(aRect);
}
@end