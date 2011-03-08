//
//  MGMLoginProcessView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
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

#import "MGMProgressView.h"

@implementation MGMProgressView
- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {
		progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect((frameRect.size.width-32)/2, (frameRect.size.height-32)/2, 32, 32)];
		[progress setStyle:NSProgressIndicatorSpinningStyle];
		[progress setControlSize:NSRegularControlSize];
		[self addSubview:progress];
		pleaseWaitField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, (((frameRect.size.height-32)/2)+32)+8, frameRect.size.width-34, 17)];
		[pleaseWaitField setTextColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[pleaseWaitField setAlignment:NSCenterTextAlignment];
		[pleaseWaitField setEditable:NO];
		[pleaseWaitField setSelectable:NO];
		[pleaseWaitField setBezeled:NO];
		[pleaseWaitField setBordered:NO];
		[pleaseWaitField setDrawsBackground:NO];
		[pleaseWaitField setStringValue:@"Please Wait..."];
		[self addSubview:pleaseWaitField];
		progressField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, ((frameRect.size.height-32)/2)-25, frameRect.size.width-34, 17)];
		[progressField setTextColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[progressField setAlignment:NSCenterTextAlignment];
		[progressField setEditable:NO];
		[progressField setSelectable:NO];
		[progressField setBezeled:NO];
		[progressField setBordered:NO];
		[progressField setDrawsBackground:NO];
		[progressField setStringValue:@"Progress"];
		[self addSubview:progressField];
	}
	return self;
}
- (void)dealloc {
	[progress release];
	[pleaseWaitField release];
	[progressField release];
	[super dealloc];
}
- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
	[super resizeSubviewsWithOldSize:oldBoundsSize];
	NSRect frameRect = [self frame];
	[progress setFrame:NSMakeRect((frameRect.size.width-32)/2, (frameRect.size.height-32)/2, 32, 32)];
	[pleaseWaitField setFrame:NSMakeRect(17, (((frameRect.size.height-32)/2)+32)+8, frameRect.size.width-34, 17)];
	[progressField setFrame:NSMakeRect(17, ((frameRect.size.height-32)/2)-25, frameRect.size.width-34, 17)];
}
- (void)startProgess {
	[progress startAnimation:self];
}
- (void)stopProgess {
	[progress stopAnimation:self];
}
- (void)setProgressTitle:(NSString *)theTitle {
	[progressField setStringValue:theTitle];
}
- (void)drawRect:(NSRect)rect {
	NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:rect];
	[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
	[backgroundPath fill];
}
- (void)mouseDown:(NSEvent *)theEvent {
	
}
- (void)mouseUp:(NSEvent *)theEvent {
	
}
- (void)mouseDragged:(NSEvent *)theEvent {
	
}
- (void)mouseEntered:(NSEvent *)theEvent {
	
}
- (void)mouseExited:(NSEvent *)theEvent {
	
}
- (void)mouseMoved:(NSEvent *)theEvent {
	
}
- (BOOL)canBecomeKeyView {
	return YES;
}
- (BOOL)acceptsFirstResponder {
	return YES;
}
@end