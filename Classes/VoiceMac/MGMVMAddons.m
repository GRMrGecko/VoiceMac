//
//  MGMVMAddons.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMVMAddons.h"
#import <QuartzCore/QuartzCore.h>

const float MGMHLKSRed = 0.505882;
const float MGMHLKSGreen = 0.639215;
const float MGMHLKSBlue = 0.772549;
const float MGMHLKERed = 0.337254;
const float MGMHLKEGreen = 0.450980;
const float MGMHLKEBlue = 0.658823;

const float MGMHLSRed = 0.756862;
const float MGMHLSGreen = 0.756862;
const float MGMHLSBlue = 0.756862;
const float MGMHLERed = 0.607843;
const float MGMHLEGreen = 0.607843;
const float MGMHLEBlue = 0.607843;

@implementation NSBezierPath (MGMVMAddons)
+ (NSBezierPath *)pathWithRect:(NSRect)theRect radiusX:(float)theRadiusX radiusY:(float)theRadiusY {
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    float maxRadiusX = theRect.size.width / 2.0;
    float maxRadiusY = theRect.size.height / 2.0;
    theRadiusX = (theRadiusX<maxRadiusX ? theRadiusX : maxRadiusX);
    theRadiusY = (theRadiusY<maxRadiusY ? theRadiusY : maxRadiusY);
    float ellipse = 0.55228474983079;
    float controlX = theRadiusX * ellipse;
    float controlY = theRadiusY * ellipse;
    NSRect edges = NSInsetRect(theRect, theRadiusX, theRadiusY);
    
    // bottom right corner
    [path moveToPoint:NSMakePoint(edges.origin.x, theRect.origin.y)];
    [path lineToPoint:NSMakePoint(NSMaxX(edges), theRect.origin.y)];
    [path curveToPoint:NSMakePoint(NSMaxX(theRect), edges.origin.y) controlPoint1:NSMakePoint(NSMaxX(edges) + controlX, theRect.origin.y) controlPoint2:NSMakePoint(NSMaxX(theRect), edges.origin.y - controlY)];
    
    // top right corner
    [path lineToPoint:NSMakePoint(NSMaxX(theRect), NSMaxY(edges))];
    [path curveToPoint:NSMakePoint(NSMaxX(edges), NSMaxY(theRect)) controlPoint1:NSMakePoint(NSMaxX(theRect), NSMaxY(edges) + controlY) controlPoint2:NSMakePoint(NSMaxX(edges) + controlX, NSMaxY(theRect))];
    
    // top left corner
    [path lineToPoint:NSMakePoint(edges.origin.x, NSMaxY(theRect))];
    [path curveToPoint:NSMakePoint(theRect.origin.x, NSMaxY(edges)) controlPoint1:NSMakePoint(edges.origin.x - controlX, NSMaxY(theRect)) controlPoint2:NSMakePoint(theRect.origin.x, NSMaxY(edges) + controlY)];
    
    // bottom left corner
    [path lineToPoint:NSMakePoint(theRect.origin.x, edges.origin.y)];
    [path curveToPoint:NSMakePoint(edges.origin.x, theRect.origin.y) controlPoint1:NSMakePoint(theRect.origin.x, edges.origin.y - controlY) controlPoint2:NSMakePoint(edges.origin.x - controlX, theRect.origin.y)];
    
    [path closePath];
    return path;
}

- (void)fillGradientFrom:(NSColor *)theStartColor to:(NSColor *)theEndColor {
	CIFilter *filter = [CIFilter filterWithName:@"CILinearGradient"];
	
	theStartColor = [theStartColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	theEndColor = [theEndColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	if (![[NSGraphicsContext currentContext] isFlipped]) {
		NSColor *start = theStartColor;
		NSColor *end = theEndColor;
		theEndColor = start;
		theStartColor = end;
	}
	CIColor *startColor = [CIColor colorWithRed:[theStartColor redComponent] green:[theStartColor greenComponent] blue:[theStartColor blueComponent] alpha:[theStartColor alphaComponent]];
	CIColor *endColor = [CIColor colorWithRed:[theEndColor redComponent] green:[theEndColor greenComponent] blue:[theEndColor blueComponent] alpha:[theEndColor alphaComponent]];
	[filter setValue:startColor forKey:@"inputColor0"];
	[filter setValue:endColor forKey:@"inputColor1"];
	
	CIVector *startVector = [CIVector vectorWithX:0.0 Y:0.0];
	[filter setValue:startVector forKey:@"inputPoint0"];
	CIVector *endVector = [CIVector vectorWithX:0.0 Y:[self bounds].size.height];
	[filter setValue:endVector forKey:@"inputPoint1"];
	
	CIImage *coreimage = [filter valueForKey:@"outputImage"];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	[self setClip];
	CIContext *context = [[NSGraphicsContext currentContext] CIContext];
	[context drawImage:coreimage atPoint:CGPointMake([self bounds].origin.x, [self bounds].origin.y) fromRect:CGRectMake(0.0, 0.0, [self bounds].size.width, [self bounds].size.height)];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}
@end

@implementation NSWorkspace (MGMVMAddons)
- (NSArray *)installedPhones {
	NSArray *apps = [(NSArray *)LSCopyAllHandlersForURLScheme(CFSTR("tel")) autorelease];
	
	NSString *defaultHandler = [self defaultPhoneIdentifier];
	if (![apps indexOfObject:defaultHandler])
		apps = [apps arrayByAddingObject:defaultHandler];
	
	return apps;
}
- (NSString *)defaultPhoneIdentifier {
	NSString *defaultBundleId = [(NSString *)LSCopyDefaultHandlerForURLScheme(CFSTR("tel")) autorelease];
	if (!defaultBundleId)
		defaultBundleId = [[NSBundle mainBundle] bundleIdentifier];
	return defaultBundleId;
}
- (void)setDefaultPhoneWithIdentifier:(NSString*)bundleID {
	LSSetDefaultHandlerForURLScheme(CFSTR("tel"), (CFStringRef)bundleID);
	LSSetDefaultHandlerForURLScheme(CFSTR("telephone"), (CFStringRef)bundleID);
	LSSetDefaultHandlerForURLScheme(CFSTR("phone"), (CFStringRef)bundleID);
	LSSetDefaultHandlerForURLScheme(CFSTR("phonenumber"), (CFStringRef)bundleID);
	LSSetDefaultHandlerForURLScheme(CFSTR("call"), (CFStringRef)bundleID);
	LSSetDefaultHandlerForURLScheme(CFSTR("sms"), (CFStringRef)bundleID);
}
@end

@implementation NSAttributedString (MGMVMAddons)
- (NSSize)sizeForWidth:(float)width height:(float)height {
	NSSize size = NSZeroSize;
    if ([self length]>0) {
		NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(width, height)];
		NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self];
		NSLayoutManager *layoutManager = [NSLayoutManager new];
		[layoutManager addTextContainer:textContainer];
		[textStorage addLayoutManager:layoutManager];
		[layoutManager setHyphenationFactor:0.0];
		[layoutManager glyphRangeForTextContainer:textContainer];
		size = [layoutManager usedRectForTextContainer:textContainer].size;
		[textStorage release];
		[textContainer release];
		[layoutManager release];
	}
	return size;
}
- (float)heightForWidth:(float)width {
	return [self sizeForWidth:width height:FLT_MAX].height;
}
- (float)widthForHeight:(float)height {
	return [self sizeForWidth:FLT_MAX height:height].width;
}
@end