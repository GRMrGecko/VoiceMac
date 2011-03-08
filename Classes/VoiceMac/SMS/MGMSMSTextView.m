//
//  MGMSMSTextView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
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