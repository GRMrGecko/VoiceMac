//
//  MGMVMAddons.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface UIDevice (MGMVMAddons)
- (BOOL)isPad;
- (NSString *)appendDeviceSuffixToString:(NSString *)theString;
@end

@interface UIScreen (MGMVMAddons)
- (BOOL)isRetina;
@end

@interface UIColor (MGMVMAddons)
- (UIColor *)colorWithDifference:(CGFloat)theDifference;
@end