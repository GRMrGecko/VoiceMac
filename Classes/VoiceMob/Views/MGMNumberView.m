//
//  MGMNumberView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMNumberView.h"
#import <MGMUsers/MGMUsers.h>

@implementation MGMNumberView
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[number release];
	[info release];
	[credit release];
	[image release];
	[alphabet release];
	[startColor release];
	[endColor release];
	[touchingStartColor release];
	[touchingEndColor release];
	[super dealloc];
}

- (void)setFrame:(CGRect)frameRect {
	[super setFrame:frameRect];
	[self setNeedsDisplay];
}

- (void)setStartColor:(UIColor *)theColor {
	[startColor release];
	startColor = [theColor retain];
}
- (UIColor *)startColor {
	return startColor;
}
- (void)setEndColor:(UIColor *)theColor {
	[endColor release];
	endColor = [theColor retain];
}
- (UIColor *)endColor {
	return endColor;
}
- (void)setTouchingStartColor:(UIColor *)theColor {
	[touchingStartColor release];
	touchingStartColor = [theColor retain];
}
- (UIColor *)touchingStartColor {
	return touchingStartColor;
}
- (void)setTouchingEndColor:(UIColor *)theColor {
	[touchingEndColor release];
	touchingEndColor = [theColor retain];
}
- (UIColor *)touchingEndColor {
	return touchingEndColor;
}

- (void)setImage:(UIImage *)theImage {
	[image release];
	image = [theImage retain];
	[self setNeedsDisplay];
}
- (UIImage *)image {
	return image;
}
- (void)setInfo:(NSString *)theInfo {
	[info release];
	info = [theInfo retain];
	[self setNeedsDisplay];
}
- (NSString *)info {
	return info;
}
- (void)setCredit:(NSString *)theCredit {
	[credit release];
	credit = [theCredit retain];
	[self setNeedsDisplay];
}
- (NSString *)credit {
	return credit;
}
- (void)setNumber:(NSString *)theNumber {
	[number release];
	number = [theNumber copy];
	[self setNeedsDisplay];
}
- (NSString *)number {
	return number;
}
- (void)setAlphabet:(NSString *)theAlphabet {
	[alphabet release];
	alphabet = [theAlphabet copy];
	[self setNeedsDisplay];
}
- (NSString *)alphabet {
	return alphabet;
}

- (void)setGlass:(BOOL)isGlass {
	glass = isGlass;
}
- (BOOL)glass {
	return glass;
}

- (void)setTouching:(BOOL)isTouching {
	touching = isTouching;
	[self setNeedsDisplay];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self setTouching:YES];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	[self setTouching:NO];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	[self setTouching:NO];
}

- (void)drawRect:(CGRect)frameRect {
	if (startColor==nil) {
		startColor = [[UIColor colorWithRed:0.11 green:0.14 blue:0.18 alpha:1.0] retain];
		endColor = [[UIColor colorWithRed:0.04 green:0.06 blue:0.1 alpha:1.0] retain];
	}
	if (touchingStartColor==nil) {
		UIColor *touchColor = [UIColor colorWithRed:0.12 green:0.42 blue:0.91 alpha:1.0];
		touchingStartColor = [touchColor retain];
		touchingEndColor = [touchColor retain];
	}
	CGRect bounds = [self bounds];
	MGMPath *path = [MGMPath pathWithRect:bounds];
	[path fillGradientFrom:(touching ? touchingStartColor : startColor) to:(touching ? touchingEndColor : endColor)];
	if (glass) {
		CGRect glassBounds = bounds;
		glassBounds.size.height = glassBounds.size.height/2;
		MGMPath *glassPath = [MGMPath pathWithRect:glassBounds];
		[glassPath fillGradientFrom:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] to:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
	}
	CGRect line = bounds;
	line.size.width += 1.5;
	line.size.height += 1.5;
	line.origin.x -= 0.2;
	line.origin.y -= 0.2;
	MGMPath *linePath = [MGMPath pathWithRect:line];
	[[UIColor colorWithRed:0.3 green:0.32 blue:0.36 alpha:1.0] setStroke];
	[linePath setLineWidth:2];
	[linePath stroke];
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	CGContextSetShadowWithColor(currentContext, CGSizeMake(0, 1), 3.0, [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor]);
	[[UIColor whiteColor] setFill];
	if (image!=nil) {
		CGRect imageRect;
		int y = 1;
		if (alphabet!=nil)
			imageRect = CGRectMake(0, 0, bounds.size.width, bounds.size.height-20.0);
		else
			imageRect = CGRectMake(0, 0, bounds.size.width, bounds.size.height-12.0);
		
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
		
		if (alphabet==nil)
			y = (bounds.size.height-scaledHeight)/2;
		[image drawInRect:CGRectMake((bounds.size.width-scaledWidth)/2, y, scaledWidth, scaledHeight)];
	}
	if (number!=nil) {
		UIFont *font = nil;
		int y = 1;
		if (alphabet!=nil)
			font = [UIFont boldSystemFontOfSize:bounds.size.height-20.0];
		else
			font = [UIFont boldSystemFontOfSize:bounds.size.height-10.0];
		CGFloat actualSize;
		CGSize numberSize = [number sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:bounds.size.width-4 lineBreakMode:UILineBreakModeClip];
		font = [UIFont boldSystemFontOfSize:actualSize];
		numberSize = [number sizeWithFont:font forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
		if (alphabet==nil)
			y = (bounds.size.height-numberSize.height)/2;
		CGPoint numberPoint = CGPointMake((bounds.size.width-numberSize.width)/2, y);
		[number drawAtPoint:numberPoint withFont:font];
	}
	if (!touching)
		[[UIColor colorWithRed:0.44 green:0.45 blue:0.46 alpha:1.0] setFill];
	if (info!=nil) {
		UIFont *font = [UIFont boldSystemFontOfSize:10.0];
		CGFloat actualSize;
		CGSize numberSize = [info sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:bounds.size.width-4 lineBreakMode:UILineBreakModeClip];
		font = [UIFont boldSystemFontOfSize:actualSize];
		numberSize = [info sizeWithFont:font forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
		CGPoint numberPoint = CGPointMake(4, bounds.size.height-numberSize.height);
		[info drawAtPoint:numberPoint withFont:font];
	}
	if (credit!=nil) {
		UIFont *font = [UIFont boldSystemFontOfSize:10.0];
		CGFloat actualSize;
		CGSize numberSize = [credit sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:bounds.size.width-4 lineBreakMode:UILineBreakModeClip];
		font = [UIFont boldSystemFontOfSize:actualSize];
		numberSize = [credit sizeWithFont:font forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
		CGPoint numberPoint = CGPointMake((bounds.size.width-numberSize.width)-4, bounds.size.height-numberSize.height);
		[credit drawAtPoint:numberPoint withFont:font];
	}
	if (alphabet!=nil) {
		UIFont *font = [UIFont boldSystemFontOfSize:14.0];
		CGFloat actualSize;
		CGSize alphabetSize = [alphabet sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
		font = [UIFont boldSystemFontOfSize:actualSize];
		alphabetSize = [alphabet sizeWithFont:font forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
		CGPoint alphabetPoint = CGPointMake((bounds.size.width-alphabetSize.width)/2, bounds.size.height-20);
		[alphabet drawAtPoint:alphabetPoint withFont:font];
	}
	CGContextRestoreGState(currentContext);
}
@end