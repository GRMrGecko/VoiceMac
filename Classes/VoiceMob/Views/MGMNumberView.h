//
//  MGMNumberView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface MGMNumberView : UIControl {
	NSString *number;
	NSString *info;
	NSString *credit;
	UIImage *image;
	NSString *alphabet;
	BOOL touching;
	
	UIColor *startColor;
	UIColor *endColor;
	UIColor *touchingStartColor;
	UIColor *touchingEndColor;
	BOOL glass;
}
- (void)setStartColor:(UIColor *)theColor;
- (UIColor *)startColor;
- (void)setEndColor:(UIColor *)theColor;
- (UIColor *)endColor;
- (void)setTouchingStartColor:(UIColor *)theColor;
- (UIColor *)touchingStartColor;
- (void)setTouchingEndColor:(UIColor *)theColor;
- (UIColor *)touchingEndColor;

- (void)setImage:(UIImage *)theImage;
- (UIImage *)image;
- (void)setNumber:(NSString *)theNumber;
- (NSString *)number;
- (void)setInfo:(NSString *)theInfo;
- (NSString *)info;
- (void)setCredit:(NSString *)theCredit;
- (NSString *)credit;
- (void)setAlphabet:(NSString *)theAlphabet;
- (NSString *)alphabet;

- (void)setGlass:(BOOL)isGlass;
- (BOOL)glass;
@end