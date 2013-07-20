//
//  MGMGlassButton.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/1/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMGlassButton.h"
#import <MGMUsers/MGMUsers.h>
#import "MGMVMAddons.h"

@implementation MGMGlassButton
- (void)awakeFromNib {
	buttonColor = [[self backgroundColor] retain];
	buttonTouchColor = [[buttonColor colorWithDifference:-0.1] retain];
	buttonDisabledColor = [[buttonColor colorWithDifference:0.1] retain];
	[self setBackgroundColor:[UIColor clearColor]];
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[buttonColor release];
	[buttonTouchColor release];
	[buttonDisabledColor release];
	[super dealloc];
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
- (void)setEnabled:(BOOL)isEnabled {
	[super setEnabled:isEnabled];
	[self setNeedsDisplay];
}

- (UIEdgeInsets)titleEdgeInsets {
	return UIEdgeInsetsMake(-2.0, 0.0, 0.0, 0.0);
}
- (void)drawRect:(CGRect)frameRect {
	UIColor *color = nil;
	if (![self isEnabled])
		color = buttonDisabledColor;
	else if (touching)
		color = buttonTouchColor;
	else
		color = buttonColor;
	CGRect pathBounds = [self bounds];
	pathBounds.size.width -= 1.0;
	pathBounds.origin.x += 0.5;
	pathBounds.size.height -= 1.0;
	pathBounds.origin.y += 0.5;
	MGMPath *path = [MGMPath pathWithRoundedRect:pathBounds cornerRadius:12];
	[path setLineWidth:1.0];
	[color setFill];
	[[color colorWithDifference:-0.1] setStroke];
	[path fill];
	[path stroke];
	
	CGRect gradientRect = pathBounds;
	gradientRect.size.width -= 1.0;
	gradientRect.origin.x += 0.5;
	gradientRect.size.height -= 0.5;
	gradientRect.origin.y += 0.5;
	CGFloat gradientRadius = 12.0;
	MGMPath *gradientPath = [MGMPath path];
	float maxRadiusX = gradientRect.size.width / 2.0;
    float maxRadiusY = gradientRect.size.height / 2.0;
    gradientRadius = (gradientRadius<maxRadiusX ? gradientRadius : maxRadiusX);
    gradientRadius = (gradientRadius<maxRadiusY ? gradientRadius : maxRadiusY);
    float ellipse = 0.55228474983079;
    float controlX = gradientRadius * ellipse;
    float controlY = gradientRadius * ellipse;
    CGRect edges = CGRectInset(gradientRect, gradientRadius, gradientRadius);
	
	[gradientPath moveToPoint:CGPointMake(edges.origin.x, gradientRect.origin.y)];
    
	// top right corner
    [gradientPath addLineToPoint:CGPointMake(CGRectGetMaxX(edges), gradientRect.origin.y)];
    [gradientPath addCurveToPoint:CGPointMake(CGRectGetMaxX(gradientRect), edges.origin.y) controlPoint1:CGPointMake(CGRectGetMaxX(edges) + controlX, gradientRect.origin.y) controlPoint2:CGPointMake(CGRectGetMaxX(gradientRect), edges.origin.y - controlY)];
    
    [gradientPath addLineToPoint:CGPointMake(CGRectGetMaxX(gradientRect), CGRectGetMidY(gradientRect))];
    [gradientPath addLineToPoint:CGPointMake(CGRectGetMinX(gradientRect), CGRectGetMidY(gradientRect))];
    
    // top left corner
    [gradientPath addLineToPoint:CGPointMake(gradientRect.origin.x, edges.origin.y)];
    [gradientPath addCurveToPoint:CGPointMake(edges.origin.x, gradientRect.origin.y) controlPoint1:CGPointMake(gradientRect.origin.x, edges.origin.y - controlY) controlPoint2:CGPointMake(edges.origin.x - controlX, gradientRect.origin.y)];
	
	[gradientPath closePath];
	[gradientPath fillGradientFrom:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] to:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
	
	[super drawRect:frameRect];
}
@end