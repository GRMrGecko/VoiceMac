//
//  MGMPath.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/1/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface MGMPath : NSObject {
	CGMutablePathRef pathRef;
	CGFloat *lineDashPattern;
    NSUInteger lineDashPatternCount;
	CGFloat lineDashPhase;
    CGFloat lineWidth;
	CGFloat miterLimit;
	CGFloat flatness;
    CGLineCap lineCapStyle;
    CGLineJoin lineJoinStyle;
}
+ (MGMPath *)path;
+ (MGMPath *)pathWithRect:(CGRect)theRect;
//+ (MGMPath *)pathWithOvalInRect:(CGRect)theRect;
+ (MGMPath *)pathWithRoundedRect:(CGRect)theRect cornerRadius:(CGFloat)theRadius;
+ (MGMPath *)pathWithRoundedRect:(CGRect)theRect cornerRadiusX:(CGFloat)theRadiusX cornerRadiusY:(CGFloat)theRadiusY;
//+ (MGMPath *)pathWithRoundedRect:(CGRect)theRect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;
//+ (MGMPath *)pathWithArcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;
//+ (MGMPath *)pathWithCGPath:(CGPathRef)CGPath;

- (CGMutablePathRef)CGPath;

- (void)moveToPoint:(CGPoint)thePoint;
- (void)addLineToPoint:(CGPoint)thePoint;
- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;
- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;
- (void)closePath;

//- (void)removeAllPoints;

- (void)appendPath:(MGMPath *)thePath;

//- (void)applyTransform:(CGAffineTransform)transform;

- (BOOL)isEmpty;
- (CGRect)bounds;
- (CGPoint)currentPoint;
- (BOOL)containsPoint:(CGPoint)point;

- (void)setLineWidth:(CGFloat)theWidth;
- (CGFloat)lineWidth;
- (void)setLineJoinStyle:(CGLineJoin)theLineJoinStyle;
- (CGLineJoin)lineJoinStyle;
- (void)setLineCapStyle:(CGLineCap)theLineCapStyle;
- (CGLineCap)lineCapStyle;
- (void)setMiterLimit:(CGFloat)theMiterLimit;
- (CGFloat)miterLimit;
- (void)setFlatness:(CGFloat)theFlatness;
- (CGFloat)flatness;
- (void)setLineDash:(const CGFloat *)pattern count:(NSInteger)count phase:(CGFloat)phase;
- (void)getLineDash:(CGFloat *)pattern count:(NSInteger *)count phase:(CGFloat *)phase;

- (void)fill;
- (void)fillGradientFrom:(UIColor *)theStartColor to:(UIColor *)theEndColor;
- (void)stroke;

//- (void)fillWithBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
//- (void)strokeWithBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (void)addClip;
@end