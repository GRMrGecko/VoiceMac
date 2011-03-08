//
//  MGMVMAddons.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/27/10.
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