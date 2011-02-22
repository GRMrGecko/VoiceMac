//
//  MGMBlackWindow.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/6/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMBlackWindow.h"
#import "MGMVMAddons.h"

@implementation MGMBlackWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	if ((self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation])) {
		forceDisplay = NO;
		[self setLevel:NSStatusWindowLevel];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setHasShadow:YES];
		[self setAlphaValue:1.0];
		[self setMovableByWindowBackground:YES];
		[self setBackgroundColor:[self blackBackground]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self];
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)windowDidResize:(NSNotification *)aNotification {
	[self setBackgroundColor:[self blackBackground]];
	if (forceDisplay)
		[self display];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag {
	forceDisplay = YES;
	[super setFrame:frameRect display:displayFlag animate:animationFlag];
	forceDisplay = NO;
}

- (NSColor *)blackBackground {
	float alpha = 0.8;
	NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
	[bg lockFocus];
	
	float radius = 6.0;
	float stroke = 3.0;
	NSRect bgRect = NSMakeRect(stroke/2, stroke/2, [bg size].width-stroke, [bg size].height-stroke);
	NSBezierPath *bgPath = [NSBezierPath pathWithRect:bgRect radiusX:radius radiusY:radius];
	[bgPath setLineWidth:stroke];
	
	[[NSColor colorWithCalibratedWhite:0.0 alpha:alpha] set];
	[bgPath fill];
	[[NSColor colorWithCalibratedWhite:1.0 alpha:alpha] set];
	[bgPath stroke];
	
	[bg unlockFocus];
	
	return [NSColor colorWithPatternImage:[bg autorelease]];
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}
@end