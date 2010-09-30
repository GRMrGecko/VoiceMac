//
//  MGMNumberView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMNumberView.h"

NSString * const MGMFontName = @"Helvetica";

@implementation MGMNumberView
- (void)dealloc {
	if (number!=nil)
		[number release];
	if (alphabet!=nil)
		[alphabet release];
	[super dealloc];
}

- (NSString *)number {
	if (number==nil) {
		switch ([self tag]) {
			case -1:
				break;
			case 10:
				number = [@"✱" retain];
				break;
			case 11:
				number = [@"#" retain];
				break;
			case 12:
				number = [@"SMS" retain];
				break;
			case 13:
				number = [@"Call" retain];
				break;
			case 14:
				number = [@"↵" retain];
				break;
			default:
				number = [[[NSNumber numberWithInt:[self tag]] stringValue] copy];
				break;
		}
	}
	return number;
}
- (void)setNumber:(NSString *)theNumber {
	if (number!=nil) [number release];
	number = [theNumber copy];
	[self setNeedsDisplay];
}
- (NSString *)alphabet {
	if (alphabet==nil) {
		switch ([self tag]) {
			case 0:
				alphabet = [@"+" retain];
				break;
			case 2:
				alphabet = [@"ABC" retain];
				break;
			case 3:
				alphabet = [@"DEF" retain];
				break;
			case 4:
				alphabet = [@"GHI" retain];
				break;
			case 5:
				alphabet = [@"JKL" retain];
				break;
			case 6:
				alphabet = [@"MNO" retain];
				break;
			case 7:
				alphabet = [@"PQRS" retain];
				break;
			case 8:
				alphabet = [@"TUV" retain];
				break;
			case 9:
				alphabet = [@"WXYZ" retain];
				break;
			default:
				break;
		}
	}
	return alphabet;
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

- (void)drawRect:(CGRect)rect {
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = [self bounds];
	CGPathAddRect(path, NULL, bounds);
	CGContextAddPath(currentContext, path);
	CGContextClip(currentContext);
	
	CGColorRef colorsRef[2];
	if (touching) {
		colorsRef[0] = [[UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0] CGColor];
		colorsRef[1] = [[UIColor colorWithRed:0.1 green:0.1 blue:0.5 alpha:1.0] CGColor];
	} else {
		if ([self tag]==13) {
			colorsRef[0] = [[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] CGColor];
			colorsRef[1] = [[UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1.0] CGColor];
		} else if ([self tag]==14) {
			colorsRef[0] = [[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0] CGColor];
			colorsRef[1] = [[UIColor colorWithRed:0.5 green:0.1 blue:0.1 alpha:1.0] CGColor];
		} else {
			colorsRef[0] = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
			colorsRef[1] = [[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] CGColor];
		}
	}
	CFArrayRef colors = CFArrayCreate(NULL, (const void **)colorsRef, sizeof(colorsRef) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
	CFRelease(colorSpace);
	CFRelease(colors);
	
	CGPoint start = bounds.origin;
	bounds.origin.y += bounds.size.height;
	CGPoint end = bounds.origin;
	CGContextDrawLinearGradient(currentContext, gradient, start, end, 0);
	
	CFRelease(gradient);
	CFRelease(path);
	
	CGRect strokeRect = bounds;
	strokeRect.origin.x = 0;
	strokeRect.origin.y = 0;
	CGContextSetStrokeColorWithColor(currentContext, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor]);
	CGContextStrokeRectWithWidth(currentContext, strokeRect, 2.0);
	CGContextRestoreGState(currentContext);
	
	[[UIColor whiteColor] set];
	if ([self number]!=nil) {
		if ([self tag]>=0 && [self tag]<=11) {
			UIFont *font = [UIFont fontWithName:MGMFontName size:bounds.size.height-20.0];
			CGFloat actualSize;
			CGSize numberSize = [[self number] sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
			font = [UIFont fontWithName:MGMFontName size:actualSize];
			numberSize = [[self number] sizeWithFont:font forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
			CGPoint numberPoint = CGPointMake((bounds.size.width-numberSize.width)/2, 1);
			[[self number] drawAtPoint:numberPoint withFont:font];
		} else {
			UIFont *font = nil;
			if ([self tag]<=13)
				font = [UIFont fontWithName:MGMFontName size:bounds.size.height-10.0];
			else
				font = [UIFont fontWithName:MGMFontName size:bounds.size.height-6.0];
			CGFloat actualSize;
			CGSize numberSize = [[self number] sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
			font = [UIFont fontWithName:MGMFontName size:actualSize];
			numberSize = [[self number] sizeWithFont:font forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
			CGPoint numberPoint = CGPointMake((bounds.size.width-numberSize.width)/2, (bounds.size.height-numberSize.height)/2);
			[[self number] drawAtPoint:numberPoint withFont:font];
		}
	}
	
	if ([self alphabet]!=nil) {
		UIFont *font = [UIFont fontWithName:MGMFontName size:14.0];
		CGFloat actualSize;
		CGSize alphabetSize = [[self alphabet] sizeWithFont:font minFontSize:0.5 actualFontSize:&actualSize forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
		font = [UIFont fontWithName:MGMFontName size:actualSize];
		alphabetSize = [[self alphabet] sizeWithFont:font forWidth:bounds.size.width lineBreakMode:UILineBreakModeClip];
		CGPoint alphabetPoint = CGPointMake((bounds.size.width-alphabetSize.width)/2, bounds.size.height-20);
		[[self alphabet] drawAtPoint:alphabetPoint withFont:font];
	}
}
@end