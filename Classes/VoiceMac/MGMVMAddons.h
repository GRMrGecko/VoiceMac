//
//  MGMVMAddons.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

extern const float MGMHLKSRed;
extern const float MGMHLKSGreen;
extern const float MGMHLKSBlue;
extern const float MGMHLKERed;
extern const float MGMHLKEGreen;
extern const float MGMHLKEBlue;

extern const float MGMHLSRed;
extern const float MGMHLSGreen;
extern const float MGMHLSBlue;
extern const float MGMHLERed;
extern const float MGMHLEGreen;
extern const float MGMHLEBlue;

@interface NSBezierPath (MGMVMAddons)
+ (NSBezierPath *)pathWithRect:(NSRect)theRect radiusX:(float)theRadiusX radiusY:(float)theRadiusY;
- (void)fillGradientFrom:(NSColor *)theStartColor to:(NSColor *)theEndColor;
@end

@interface NSWorkspace (MGMVMAddons)
- (NSArray *)installedPhones;
- (NSString *)defaultPhoneIdentifier;
- (void)setDefaultPhoneWithIdentifier:(NSString*)bundleID;
@end

@interface NSAttributedString (MGMVMAddons)
- (NSSize)sizeForWidth:(float)width height:(float)height;
- (float)heightForWidth:(float)width;
- (float)widthForHeight:(float)height;
@end