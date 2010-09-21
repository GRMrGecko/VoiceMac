//
//  MGMGradiantView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMGradiantView.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMGradiantTableView
- (void)awakeFromNib {
	[self setIntercellSpacing:NSMakeSize(0.0, 0.0)];
	
	NSTableColumn *column = [[self tableColumns] objectAtIndex:0];
	if ([[column dataCell] isKindOfClass:[NSTextFieldCell class]]) {
		MGMTextCell *theTextCell = [[MGMTextCell new] autorelease];
		[column setDataCell:theTextCell];
		[[column dataCell] setFont:[NSFont labelFontOfSize:[NSFont labelFontSize]]];
	}
}
- (void)highlightSelectionInClipRect:(NSRect)clipRect {
	int selectedRow = [self selectedRow];
	if(selectedRow == -1)
		return;
	[self lockFocus];
	
	NSColor *startColor = nil;
	NSColor *endColor = nil;
	if ([[self window] isKeyWindow]) {
		startColor = [NSColor colorWithCalibratedRed:MGMHLKSRed green:MGMHLKSGreen blue:MGMHLKSBlue alpha:1.0];
		endColor = [NSColor colorWithCalibratedRed:MGMHLKERed green:MGMHLKEGreen blue:MGMHLKEBlue alpha:1.0];
	} else {
		startColor = [NSColor colorWithCalibratedRed:MGMHLSRed green:MGMHLSGreen blue:MGMHLSBlue alpha:1.0];
		endColor = [NSColor colorWithCalibratedRed:MGMHLERed green:MGMHLEGreen blue:MGMHLEBlue alpha:1.0];
	}
	
	NSRect drawingRect = [self rectOfRow:selectedRow];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:drawingRect];
	[path fillGradientFrom:startColor to:endColor];
	path = [NSBezierPath bezierPathWithRect:NSMakeRect(drawingRect.origin.x, drawingRect.origin.y, drawingRect.size.width, 1.0)];
	[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.15] set];
	[path fill];
	
	[self unlockFocus];
}
- (void)viewWillDraw {
	if ([[self window] isKeyWindow]) {
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.863389 green:0.892058 blue:0.9205 alpha:1.0]];
	} else {
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.929412 green:0.929412 blue:0.929412 alpha:1.0]];
	}
}
@end

@implementation MGMGradiantOutlineView
- (void)awakeFromNib {
	[self setIntercellSpacing:NSMakeSize(0.0, 0.0)];
	
	NSTableColumn *column = [[self tableColumns] objectAtIndex:0];
	if ([[column dataCell] isKindOfClass:[NSTextFieldCell class]]) {
		MGMTextCell *theTextCell = [[MGMTextCell new] autorelease];
		[column setDataCell:theTextCell];
		[[column dataCell] setFont:[NSFont labelFontOfSize:[NSFont labelFontSize]]];
	}
}
- (void)highlightSelectionInClipRect:(NSRect)clipRect {
	int selectedRow = [self selectedRow];
	if(selectedRow == -1)
		return;
	[self lockFocus];
	
	NSColor *startColor = nil;
	NSColor *endColor = nil;
	if ([[self window] isKeyWindow]) {
		startColor = [NSColor colorWithCalibratedRed:MGMHLKSRed green:MGMHLKSGreen blue:MGMHLKSBlue alpha:1.0];
		endColor = [NSColor colorWithCalibratedRed:MGMHLKERed green:MGMHLKEGreen blue:MGMHLKEBlue alpha:1.0];
	} else {
		startColor = [NSColor colorWithCalibratedRed:MGMHLSRed green:MGMHLSGreen blue:MGMHLSBlue alpha:1.0];
		endColor = [NSColor colorWithCalibratedRed:MGMHLERed green:MGMHLEGreen blue:MGMHLEBlue alpha:1.0];
	}
	
	NSRect drawingRect = [self rectOfRow:selectedRow];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:drawingRect];
	[path fillGradientFrom:startColor to:endColor];
	path = [NSBezierPath bezierPathWithRect:NSMakeRect(drawingRect.origin.x, drawingRect.origin.y, drawingRect.size.width, 1.0)];
	[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.15] set];
	[path fill];
	
	[self unlockFocus];
}
- (void)viewWillDraw {
	if ([[self window] isKeyWindow]) {
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.863389 green:0.892058 blue:0.9205 alpha:1.0]];
	} else {
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.929412 green:0.929412 blue:0.929412 alpha:1.0]];
	}
}
@end

@implementation MGMTextCell
- (id)init {
	self = [super init];
	if (self != nil) {
		[self setWraps:NO];
	}
	return self;
}
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[controlView lockFocus];
	if ([self isHighlighted]) {
		NSColor *startColor = nil;
		NSColor *endColor = nil;
		if ([[controlView window] isKeyWindow]) {
			startColor = [NSColor colorWithCalibratedRed:MGMHLKSRed green:MGMHLKSGreen blue:MGMHLKSBlue alpha:1.0];
			endColor = [NSColor colorWithCalibratedRed:MGMHLKERed green:MGMHLKEGreen blue:MGMHLKEBlue alpha:1.0];
		} else {
			startColor = [NSColor colorWithCalibratedRed:MGMHLSRed green:MGMHLSGreen blue:MGMHLSBlue alpha:1.0];
			endColor = [NSColor colorWithCalibratedRed:MGMHLERed green:MGMHLEGreen blue:MGMHLEBlue alpha:1.0];
		}
		
		NSRect drawingRect = [super drawingRectForBounds:cellFrame];
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:drawingRect];
		[path fillGradientFrom:startColor to:endColor];
		path = [NSBezierPath bezierPathWithRect:NSMakeRect(drawingRect.origin.x, drawingRect.origin.y, drawingRect.size.width, 1.0)];
		[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.15] set];
		[path fill];
	}
	cellFrame.size.width += 10;
	NSRect textRect = [self drawingRectForBounds:cellFrame];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	if ([self isHighlighted]) {
		[attributes setObject:[NSFont fontWithName:[NSString stringWithFormat:@"%@ Bold", [[self font] displayName]] size:[[self font] pointSize]] forKey:NSFontAttributeName];
		[attributes setValue:[NSColor whiteColor] forKey:@"NSColor"];
	} else {
		[attributes setObject:[self font] forKey:NSFontAttributeName];
	}
	NSString *displayString = [[self stringValue] truncateForWidth:textRect.size.width attributes:attributes];
	[displayString drawAtPoint:textRect.origin withAttributes:attributes];
	
	[controlView unlockFocus];
}

- (NSRect)drawingRectForBounds:(NSRect)theRect {
	NSRect newRect = [super drawingRectForBounds:theRect];
	NSSize textSize = [self cellSizeForBounds:theRect];
	float heightDifference = newRect.size.height - textSize.height;	
	if (heightDifference > 0) {
		newRect.size.height -= heightDifference;
		newRect.origin.y += (heightDifference / 2);
	}
	newRect.origin.x += 4;
	newRect.size.width -= 14;
	return newRect;
}
@end