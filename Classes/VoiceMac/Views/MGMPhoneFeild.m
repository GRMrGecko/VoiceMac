//
//  MGMPhoneFeild.m
//  VoiceMac
//
//  Created by Mr. Gecko on 7/15/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMPhoneFeild.h"

@implementation MGMPhoneField
- (id)initWithCoder:(NSCoder*)coder {
	if (self = [super initWithCoder:coder]) {
		NSTextFieldCell *cell = [self cell];
		MGMPhoneFieldCell *phoneCell = [[MGMPhoneFieldCell alloc] initTextCell:[cell stringValue]];
		//NSTextFieldCell
		[phoneCell setTextColor:[cell textColor]];
		[phoneCell setBezelStyle:[cell bezelStyle]];
		[phoneCell setBackgroundColor:[cell backgroundColor]];
		[phoneCell setDrawsBackground:[cell drawsBackground]];
		[phoneCell setPlaceholderString:[cell placeholderString]];
		
		//NSActionCell
		[phoneCell setTarget:[cell target]];
		[phoneCell setAction:[cell action]];
		[phoneCell setTag:[cell tag]];
		
		//NSCell
		[phoneCell setEnabled:[cell isEnabled]];
		[phoneCell setAllowsUndo:[cell allowsUndo]];
		[phoneCell setBordered:[cell isBordered]];
		[phoneCell setBezeled:[cell isBezeled]];
		[phoneCell setAllowsMixedState:[cell allowsMixedState]];
		[phoneCell setState:[cell state]];
		[phoneCell setEditable:[cell isEditable]];
		[phoneCell setSelectable:[cell isSelectable]];
		[phoneCell setScrollable:[cell isScrollable]];
		[phoneCell setAlignment:[cell alignment]];
		[phoneCell setFont:[cell font]];
		[phoneCell setLineBreakMode:[cell lineBreakMode]];
		[phoneCell setWraps:[cell wraps]];
		[phoneCell setBaseWritingDirection:[cell baseWritingDirection]];
		[phoneCell setAllowsEditingTextAttributes:[cell allowsEditingTextAttributes]];
		[phoneCell setImportsGraphics:[cell importsGraphics]];
		[phoneCell setContinuous:[cell isContinuous]];
		[phoneCell setFormatter:[cell formatter]];
		[phoneCell setMenu:[cell menu]];
		[phoneCell setShowsFirstResponder:[cell showsFirstResponder]];
		[phoneCell setRefusesFirstResponder:[cell refusesFirstResponder]];
		[phoneCell setRepresentedObject:[cell representedObject]];
		[phoneCell setFocusRingType:[cell focusRingType]];
		[phoneCell setControlSize:[cell controlSize]];
		[phoneCell setControlView:[cell controlView]];
		[phoneCell setControlTint:[cell controlTint]];
		[phoneCell setSendsActionOnEndEditing:[cell sendsActionOnEndEditing]];
		
		[self setCell:phoneCell];
		[phoneCell release];
	}
	return self;
}
- (void)setPhoneDelegate:(id)thePhoneDelegate {
	phoneDelegate = thePhoneDelegate;
}
- (id<MGMPhoneFieldDelegate>)phoneDelegate {
	return phoneDelegate;
}
- (void)dealloc {
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)event {
	NSPoint location = [event locationInWindow];
	NSRect bounds = [self bounds];
	MGMPhoneFieldCell *cell = [self cell];
	
	if (!NSPointInRect(location, [cell textRectForBounds:bounds includeButtons:YES])) {
		NSRect clearRect = [self convertRect:[cell clearButtonRectForBounds:bounds] toView:nil];
		if (NSPointInRect(location, clearRect)) {
			[[cell clearButton] setHighlighted:YES];
		}
		return;
	}
	[super mouseDown:event];
}
- (void)mouseUp:(NSEvent *)event {
	NSPoint location = [event locationInWindow];
	NSRect bounds = [self bounds];
	MGMPhoneFieldCell *cell = [self cell];
	
	NSButtonCell *clearButton = [cell clearButton];
	[clearButton setHighlighted:NO];
	if (!NSPointInRect(location, [cell textRectForBounds:bounds includeButtons:YES])) {
		NSRect clearRect = [self convertRect:[cell clearButtonRectForBounds:bounds] toView:nil];
		if (NSPointInRect(location, clearRect)) {
			[self setStringValue:@""];
			if (phoneDelegate!=nil && [phoneDelegate respondsToSelector:@selector(filterContacts)]) [phoneDelegate filterContacts];
		}
	}
	
	[super mouseUp:event];
}

- (void)keyUp:(NSEvent *)theEvent {
	int keyCode = [theEvent keyCode];
	if (keyCode==125 || keyCode==36 || keyCode==76) {
		[super keyUp:theEvent];
	} else {
		if (phoneDelegate!=nil && [phoneDelegate respondsToSelector:@selector(filterContacts)]) [phoneDelegate filterContacts];
		[super keyUp:theEvent];
	}
}
@end

@implementation MGMPhoneFieldCell
- (id)initTextCell:(NSString *)aString {
	if (self = [super initTextCell:aString]) {
		clearButton = [[NSButtonCell alloc] initImageCell:nil];
		[clearButton setButtonType:NSMomentaryChangeButton];
		[clearButton setBezelStyle:NSRegularSquareBezelStyle];
		[clearButton setBordered:NO];
		[clearButton setImagePosition:NSImageOnly];
		[clearButton setImage:[NSImage imageNamed:@"Close"]];
		[clearButton setAlternateImage:[NSImage imageNamed:@"ClosePressed"]];
		[clearButton setKeyEquivalent:@"\e"];
	}
	return self;
}
- (void)dealloc {
	[clearButton release];
	[super dealloc];
}

- (NSButtonCell *)clearButton {
	return clearButton;
}

#define offset 4
- (NSRect)clearButtonRectForBounds:(NSRect)bounds {
	NSRect clearRect = NSZeroRect;
	clearRect.size = [clearButton cellSize];
	clearRect.size.height = bounds.size.height;
	clearRect.origin.x = bounds.size.width - clearRect.size.width - offset;
	return clearRect;
}
- (NSRect)textRectForBounds:(NSRect)bounds includeButtons:(BOOL)buttons {
	NSRect rect = NSInsetRect(bounds, 2, 2);
	rect.size.height = [super drawingRectForBounds:bounds].size.height;
	if (buttons) {
		rect.size.width -= [clearButton cellSize].width;
		rect.size.width -= offset;
		rect.origin.x += offset;
	}
	return rect;
}
- (NSRect)drawingRectForBounds:(NSRect)bounds {
	return [self textRectForBounds:bounds includeButtons:YES];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	[super drawWithFrame:cellFrame inView:controlView];
	if ([[self stringValue] length]>0)
		[clearButton drawWithFrame:[self clearButtonRectForBounds:cellFrame] inView:controlView];
}

- (void)resetCursorRect:(NSRect)cellFrame inView:(NSView *)controlView {
	[super resetCursorRect:[self textRectForBounds:cellFrame includeButtons:YES] inView:controlView];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObject delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	[super selectWithFrame:[self textRectForBounds:aRect includeButtons:NO] inView:controlView editor:textObject delegate:anObject start:selStart length:selLength];
}

- (BOOL)trackMouse:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
	NSRect clearRect = [self clearButtonRectForBounds:cellFrame];
	if ([controlView mouse:[controlView convertPoint:[event locationInWindow] fromView:nil] inRect:clearRect]) {
		return [clearButton trackMouse:event inRect:clearRect ofView:controlView untilMouseUp:untilMouseUp];
	}
	
	return [super trackMouse:event inRect:[self textRectForBounds:cellFrame includeButtons:YES] ofView:controlView untilMouseUp:untilMouseUp];
}
@end

@implementation MGMPhoneFieldView
- (void)setPhoneDelegate:(id)thePhoneDelegate {
	phoneDelegate = thePhoneDelegate;
}
- (id<MGMPhoneFieldDelegate>)phoneDelegate {
	return phoneDelegate;
}

- (void)paste:(id)sender {
	[super paste:sender];
	if (phoneDelegate!=nil && [phoneDelegate respondsToSelector:@selector(filterContacts)]) [phoneDelegate filterContacts];
}
- (void)cut:(id)sender {
	[super cut:sender];
	if (phoneDelegate!=nil && [phoneDelegate respondsToSelector:@selector(filterContacts)]) [phoneDelegate filterContacts];
}
@end