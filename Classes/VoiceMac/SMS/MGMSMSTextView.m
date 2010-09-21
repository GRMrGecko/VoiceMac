//
//  MGMSMSTextView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSMSTextView.h"
#import "MGMSplitView.h"

@implementation MGMSMSTextView
- (void)keyDown:(NSEvent *)theEvent {
	int keycode = [theEvent keyCode];
	int modifierFlags = [theEvent modifierFlags];
	if (modifierFlags & NSAlternateKeyMask) {
		[super keyDown:theEvent];
	} else if (keycode==36) {
		if ([messageView respondsToSelector:@selector(sendMessage:)]) [messageView sendMessage:self];
	} else {
		[super keyDown:theEvent];
	}
}
- (void)keyUp:(NSEvent *)theEvent {
	[self count];
	[super keyUp:theEvent];
}
- (void)count {
	[count setIntValue:160-[[self string] length]];
	if ([messageView respondsToSelector:@selector(SMSSplitView)]) {
		MGMSplitView *splitView = [messageView SMSSplitView];
		NSView *bottom = [[splitView subviews] objectAtIndex:1];
		NSRect bottomFrame = [bottom frame];
		bottomFrame.size.height = [self bounds].size.height+16.0;
		[bottom setFrame:bottomFrame];
	}
}
- (IBAction)print:(id)sender {
	NSLog(@"Printing");
	if ([messageView respondsToSelector:@selector(SMSView)]) [[messageView SMSView] print:sender];
}
- (void)paste:(id)sender {
	[super paste:sender];
	[self count];
}
- (void)cut:(id)sender {
	[super cut:sender];
	[self count];
}
@end