//
//  MGMMiddleView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/11/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMMiddleView.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMMFontName = @"Helvetica";

@implementation MGMMiddleViewButton
+ (id)buttonWithTitle:(NSString *)theTitle image:(NSString *)theImage target:(id)theTarget action:(SEL)theAction {
	return [[[self alloc] initWithTitle:theTitle image:theImage target:theTarget action:theAction] autorelease];
}
- (id)initWithTitle:(NSString *)theTitle image:(NSString *)theImage target:(id)theTarget action:(SEL)theAction {
	if ((self = [super init])) {
		title = [theTitle copy];
		image = [theImage copy];
		target = theTarget;
		action = theAction;
	}
	return self;
}
- (void)dealloc {
	[title release];
	[image release];
	[super dealloc];
}
- (void)setTitle:(NSString *)theTitle {
	[title release];
	title = [theTitle copy];
}
- (NSString *)title {
	return title;
}
- (void)setImage:(NSString *)theImage {
	[image release];
	image = [theImage copy];
}
- (NSString *)image {
	return image;
}
- (void)setTarget:(id)theTarget {
	target = theTarget;
}
- (id)target {
	return target;
}
- (void)setAction:(SEL)theAction {
	action = theAction;
}
- (SEL)action {
	return action;
}
- (void)setHighlighted:(BOOL)isHighlighted {
	highlighted = isHighlighted;
}
- (BOOL)highlighted {
	return highlighted;
}
- (void)setRect:(CGRect)theRect {
	rect = theRect;
}
- (CGRect)rect {
	return rect;
}
@end


@implementation MGMMiddleView
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[buttons release];
	[super dealloc];
}
- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}
- (id<MGMMiddleViewDelegate>)delegate {
	return delegate;
}

- (void)addButtonWithTitle:(NSString *)theTitle imageName:(NSString *)theImage target:(id)theTarget action:(SEL)theAction {
	if (buttons==nil) buttons = [NSMutableArray new];
	[buttons addObject:[MGMMiddleViewButton buttonWithTitle:theTitle image:theImage target:theTarget action:theAction]];
	[self updateButtonRects];
	[self setNeedsDisplay];
}
- (void)setButtons:(NSArray *)theButtons {
	[buttons release];
	buttons = [theButtons mutableCopy];
	[self updateButtonRects];
}
- (NSArray *)buttons {
	return buttons;
}

- (void)updateButtonRects {
	CGRect bounds = [self bounds];
	
	int count = [buttons count];
	int row = 3;
	int numRow = count/row;
	if (numRow<=1) {
		row = 2;
		numRow = count/row;
	}
	int width = bounds.size.width/row;
	int height = bounds.size.height/numRow;
	int index = 0;
	for (int r=0; r<numRow; r++) {
		int y = (r*height) + bounds.origin.y;
		for (int i=0; i<row; i++) {
			int x = (i*width) + bounds.origin.x;
			CGRect buttonRect = CGRectMake(x, y, width, height);
			[[buttons objectAtIndex:index] setRect:buttonRect];
			index++;
		}
	}
}

- (void)setHighlighted:(BOOL)isHighlighted forButtonAtIndex:(int)theIndex {
	[[buttons objectAtIndex:theIndex] setHighlighted:isHighlighted];
	[self setNeedsDisplay];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	touchStartPoint = [touch locationInView:self];
	for (int i=0; i<[buttons count]; i++) {
		if (CGRectContainsPoint([[buttons objectAtIndex:i] rect], touchStartPoint)) {
			touchStartIndex = i;
			[self setHighlighted:YES forButtonAtIndex:i];
			break;
		}
	}
	[super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setHighlighted:NO forButtonAtIndex:touchStartIndex];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	BOOL cancel = YES;
	for (int i=0; i<[buttons count]; i++) {
		if (CGRectContainsPoint([[buttons objectAtIndex:i] rect], point)) {
			if (touchStartIndex==i) {
				cancel = NO;
				MGMMiddleViewButton *button = [buttons objectAtIndex:i];
				NSMethodSignature *signature = [[button target] methodSignatureForSelector:[button action]];
				if (signature!=nil) {
					NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
					[invocation setSelector:[button action]];
					[invocation setArgument:&self atIndex:2];
					[invocation setArgument:&i atIndex:3];
					[invocation invokeWithTarget:[button target]];
				}
				if (delegate!=nil && [delegate respondsToSelector:@selector(middleViewDidSelect:atIndex:)]) [delegate middleViewDidSelect:self atIndex:touchStartIndex];
			}
			break;
		}
	}
	if (cancel && delegate!=nil && [delegate respondsToSelector:@selector(middleViewDidCancel:atIndex:)]) [delegate middleViewDidCancel:self atIndex:touchStartIndex];
	[super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (delegate!=nil && [delegate respondsToSelector:@selector(middleViewDidCancel:atIndex:)]) [delegate middleViewDidCancel:self atIndex:touchStartIndex];
	[self setHighlighted:NO forButtonAtIndex:touchStartIndex];
	[super touchesCancelled:touches withEvent:event];
}

- (void)drawRect:(CGRect)frameRect {
	UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.6];
	UIColor *whiteColor = [UIColor colorWithWhite:1.0 alpha:0.1];
	UIColor *highlightStartColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.6];
	UIColor *highlightEndColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.6];
	CGFloat radius = 20.0;
	CGRect bounds = [self bounds];
	MGMPath *path = [MGMPath pathWithRoundedRect:bounds cornerRadius:radius];
	[path fillGradientFrom:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.6] to:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
	
	CGRect innerBounds = bounds;
	innerBounds.size.width -= 1;
	innerBounds.origin.x += 0.5;
	innerBounds.size.height -= 1;
	innerBounds.origin.y += 0.5;
	MGMPath *innerPath = [MGMPath pathWithRoundedRect:innerBounds cornerRadius:radius];
	[blackColor setStroke];
	[innerPath stroke];
	CGRect innerWhiteBounds = innerBounds;
	innerWhiteBounds.size.width -= 2;
	innerWhiteBounds.origin.x += 1;
	innerWhiteBounds.size.height -= 2;
	innerWhiteBounds.origin.y += 1;
	MGMPath *innerWhitePath = [MGMPath pathWithRoundedRect:innerWhiteBounds cornerRadius:radius];
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	
	[innerWhitePath addClip];
	
	int count = [buttons count];
	int row = 3;
	int numRow = count/row;
	if (numRow<=1) {
		row = 2;
		numRow = count/row;
	}
	int width = bounds.size.width/row;
	int height = bounds.size.height/numRow;
	int index = 0;
	for (int r=0; r<numRow; r++) {
		int y = (r*height) + bounds.origin.y;
		for (int i=0; i<row; i++) {
			int x = (i*width) + bounds.origin.x;
			MGMMiddleViewButton *button = [buttons objectAtIndex:index];
			if ([button highlighted]) {
				CGRect highlightRect = CGRectMake(x, y, width, height);
				MGMPath *highlightPath = [MGMPath pathWithRect:highlightRect];
				[highlightPath fillGradientFrom:highlightStartColor to:highlightEndColor];
			}
			
			if ([button image]!=nil) {
				CGRect imageRect = CGRectMake(x+5, y+10, width-10, height-30);
				UIImage *image = [UIImage imageNamed:[button image]];
				
				CGSize size = [image size];
				float scaleFactor = 0.0;
				float scaledWidth = imageRect.size.width;
				float scaledHeight = imageRect.size.height;
				
				if (!CGSizeEqualToSize(size, imageRect.size)) {
					float widthFactor = imageRect.size.width / size.width;
					float heightFactor = imageRect.size.height / size.height;
					
					if (widthFactor < heightFactor)
						scaleFactor = widthFactor;
					else
						scaleFactor = heightFactor;
					
					scaledWidth = size.width * scaleFactor;
					scaledHeight = size.height * scaleFactor;
				}
				
				[image drawInRect:CGRectMake(imageRect.origin.x+((imageRect.size.width-scaledWidth)/2), imageRect.origin.y+((imageRect.size.height-scaledHeight)/2), scaledWidth, scaledHeight)];
			}
			
			if ([button title]!=nil) {
				[[UIColor whiteColor] set];
				UIFont *font = [UIFont fontWithName:MGMMFontName size:12.0];
				CGFloat actualSize;
				CGSize titleSize = [[button title] sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:width-15 lineBreakMode:UILineBreakModeClip];
				font = [UIFont fontWithName:MGMMFontName size:actualSize];
				titleSize = [[button title] sizeWithFont:font forWidth:width-15 lineBreakMode:UILineBreakModeClip];
				CGPoint titlePoint = CGPointMake(x+((width-titleSize.width)/2), (y+height)-20);
				[[button title] drawAtPoint:titlePoint withFont:font];
			}
			
			if (x!=bounds.origin.x) {
				CGRect lineRect = CGRectMake(x, bounds.origin.y, 1, bounds.size.height);
				MGMPath *linePath = [MGMPath pathWithRect:lineRect];
				[blackColor setFill];
				[linePath fill];
				CGRect lineWhiteRect = CGRectMake(x+1, bounds.origin.y, 1, bounds.size.height);
				MGMPath *lineWhitePath = [MGMPath pathWithRect:lineWhiteRect];
				[whiteColor setFill];
				[lineWhitePath fill];
			}
			index++;
		}
		if (y!=bounds.origin.y) {
			CGRect lineRect = CGRectMake(bounds.origin.x, y, bounds.size.width, 1);
			MGMPath *linePath = [MGMPath pathWithRect:lineRect];
			[blackColor setFill];
			[linePath fill];
			CGRect lineWhiteRect = CGRectMake(bounds.origin.x, y-1, bounds.size.width, 1);
			MGMPath *lineWhitePath = [MGMPath pathWithRect:lineWhiteRect];
			[whiteColor setFill];
			[lineWhitePath fill];
		}
	}
	
	CGContextRestoreGState(currentContext);
	
	[whiteColor setStroke];
	[innerWhitePath stroke];
}
@end