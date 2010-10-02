//
//  MGMPath.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/1/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMPath.h"

@implementation MGMPath
+ (MGMPath *)path {
	return [[[self alloc] init] autorelease];
}
+ (MGMPath *)pathWithRect:(CGRect)theRect {
	MGMPath *path = [self path];
	CGPathAddRect([path CGPath], NULL, theRect);
	return path;
}
+ (MGMPath *)pathWithRoundedRect:(CGRect)theRect cornerRadius:(CGFloat)theRadius {
	return [self pathWithRoundedRect:theRect cornerRadiusX:theRadius cornerRadiusY:theRadius];
}
+ (MGMPath *)pathWithRoundedRect:(CGRect)theRect cornerRadiusX:(CGFloat)theRadiusX cornerRadiusY:(CGFloat)theRadiusY {
    MGMPath *path = [self path];
	
    float maxRadiusX = theRect.size.width / 2.0;
    float maxRadiusY = theRect.size.height / 2.0;
    theRadiusX = (theRadiusX<maxRadiusX ? theRadiusX : maxRadiusX);
    theRadiusY = (theRadiusY<maxRadiusY ? theRadiusY : maxRadiusY);
    float ellipse = 0.55228474983079;
    float controlX = theRadiusX * ellipse;
    float controlY = theRadiusY * ellipse;
    CGRect edges = CGRectInset(theRect, theRadiusX, theRadiusY);
	
	[path moveToPoint:CGPointMake(edges.origin.x, theRect.origin.y)];
    
	// top right corner
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(edges), theRect.origin.y)];
    [path addCurveToPoint:CGPointMake(CGRectGetMaxX(theRect), edges.origin.y) controlPoint1:CGPointMake(CGRectGetMaxX(edges) + controlX, theRect.origin.y) controlPoint2:CGPointMake(CGRectGetMaxX(theRect), edges.origin.y - controlY)];
    
    // bottom right corner
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(theRect), CGRectGetMaxY(edges))];
    [path addCurveToPoint:CGPointMake(CGRectGetMaxX(edges), CGRectGetMaxY(theRect)) controlPoint1:CGPointMake(CGRectGetMaxX(theRect), CGRectGetMaxY(edges) + controlY) controlPoint2:CGPointMake(CGRectGetMaxX(edges) + controlX, CGRectGetMaxY(theRect))];
    
    // bottom left corner
    [path addLineToPoint:CGPointMake(edges.origin.x, CGRectGetMaxY(theRect))];
    [path addCurveToPoint:CGPointMake(theRect.origin.x, CGRectGetMaxY(edges)) controlPoint1:CGPointMake(edges.origin.x - controlX, CGRectGetMaxY(theRect)) controlPoint2:CGPointMake(theRect.origin.x, CGRectGetMaxY(edges) + controlY)];
	
    // top left corner
    [path addLineToPoint:CGPointMake(theRect.origin.x, edges.origin.y)];
    [path addCurveToPoint:CGPointMake(edges.origin.x, theRect.origin.y) controlPoint1:CGPointMake(theRect.origin.x, edges.origin.y - controlY) controlPoint2:CGPointMake(edges.origin.x - controlX, theRect.origin.y)];
	
	[path closePath];
	
    return path;
}
- (id)init {
	if (self = [super init]) {
		pathRef = CGPathCreateMutable();
		lineWidth = 1.0;
		lineCapStyle = kCGLineCapButt;
		lineJoinStyle = kCGLineJoinMiter;
		miterLimit = 10.0;
		flatness = 0.6;
	}
	return self;
}
- (void)dealloc {
	if (pathRef!=NULL)
		CGPathRelease(pathRef);
	if (lineDashPattern!=NULL)
		free(lineDashPattern);
	[super dealloc];
}

- (CGMutablePathRef)CGPath {
	return pathRef;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[MGMPath class]]) {
		return CGPathEqualToPath(pathRef, [object CGPath]);
	}
	return NO;
}

- (void)moveToPoint:(CGPoint)thePoint {
	CGPathMoveToPoint(pathRef, NULL, thePoint.x, thePoint.y);
}
- (void)addLineToPoint:(CGPoint)thePoint {
	CGPathAddLineToPoint(pathRef, NULL, thePoint.x, thePoint.y);
}
- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 {
	CGPathAddCurveToPoint(pathRef, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
}
- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise {
	CGPathAddArc(pathRef, NULL, center.x, center.y, radius, startAngle, endAngle, clockwise);
}
- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint {
	CGPathAddQuadCurveToPoint(pathRef, NULL, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
}
- (void)closePath {
	CGPathCloseSubpath(pathRef);
}

- (void)appendPath:(MGMPath *)thePath {
	CGPathAddPath(pathRef, NULL, [thePath CGPath]);
}

- (BOOL)isEmpty {
	return CGPathIsEmpty(pathRef);
}
- (CGRect)bounds {
	return CGPathGetBoundingBox(pathRef);
}
- (CGPoint)currentPoint {
	return CGPathGetCurrentPoint(pathRef);
}
- (BOOL)containsPoint:(CGPoint)point {
	return CGPathContainsPoint(pathRef, NULL, point, NO);
}

- (void)setLineWidth:(CGFloat)theWidth {
	lineWidth = theWidth;
}
- (CGFloat)lineWidth {
	return lineWidth;
}
- (void)setLineJoinStyle:(CGLineJoin)theLineJoinStyle {
	lineJoinStyle = theLineJoinStyle;
}
- (CGLineJoin)lineJoinStyle {
	return lineJoinStyle;
}
- (void)setLineCapStyle:(CGLineCap)theLineCapStyle {
	lineCapStyle = theLineCapStyle;
}
- (CGLineCap)lineCapStyle {
	return lineCapStyle;
}
- (void)setMiterLimit:(CGFloat)theMiterLimit {
	miterLimit = theMiterLimit;
}
- (CGFloat)miterLimit {
	return miterLimit;
}
- (void)setFlatness:(CGFloat)theFlatness {
	flatness = theFlatness;
}
- (CGFloat)flatness {
	return flatness;
}
- (void)setLineDash:(const CGFloat *)pattern count:(NSInteger)count phase:(CGFloat)phase {
	if (lineDashPattern!=NULL) {
		free(lineDashPattern);
		lineDashPattern = NULL;
	}
	if (pattern!=NULL) {
		lineDashPattern  = malloc(sizeof(CGFloat)*count);
		memcpy(lineDashPattern, pattern, sizeof(pattern));
	}
	lineDashPatternCount = count;
	lineDashPhase = phase;
}
- (void)getLineDash:(CGFloat *)pattern count:(NSInteger *)count phase:(CGFloat *)phase {
	if (pattern!=NULL) {
		memcpy(pattern, lineDashPattern, sizeof(CGFloat)*lineDashPatternCount);
	}
	*count = lineDashPatternCount;
	*phase = lineDashPhase;
}

- (void)setContextOptions:(CGContextRef)theContext {
	CGContextSetLineWidth(theContext, lineWidth);
	CGContextSetLineCap(theContext, lineCapStyle);
	CGContextSetLineJoin(theContext, lineJoinStyle);
	CGContextSetMiterLimit(theContext, miterLimit);
	CGContextSetFlatness(theContext, flatness);
	if (lineDashPattern!=NULL)
		CGContextSetLineDash(theContext, lineDashPhase, lineDashPattern, lineDashPatternCount);
}

- (void)fill {
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	CGContextAddPath(currentContext, pathRef);
	[self setContextOptions:currentContext];
	CGContextFillPath(currentContext);
	CGContextRestoreGState(currentContext);
}
- (void)fillGradientFrom:(UIColor *)theStartColor to:(UIColor *)theEndColor {
	CGRect bounds = [self bounds];
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	[self addClip];
	
	CGColorRef colorsRef[2];
	colorsRef[0] = [theStartColor CGColor];
	colorsRef[1] = [theEndColor CGColor];
	CFArrayRef colors = CFArrayCreate(NULL, (const void **)colorsRef, sizeof(colorsRef) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
	CGPoint start = bounds.origin;
	bounds.origin.y += bounds.size.height;
	CGPoint end = bounds.origin;
	CGContextDrawLinearGradient(currentContext, gradient, start, end, 0);
	CGColorSpaceRelease(colorSpace);
	CFRelease(colors);
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(currentContext);
}
- (void)stroke {
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	CGContextAddPath(currentContext, pathRef);
	[self setContextOptions:currentContext];
	CGContextStrokePath(currentContext);
	CGContextRestoreGState(currentContext);
}

- (void)addClip {
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextAddPath(currentContext, pathRef);
	[self setContextOptions:currentContext];
	CGContextClip(currentContext);
}
@end
