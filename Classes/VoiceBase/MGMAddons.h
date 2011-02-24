//
//  NSAddons.h
//  VoiceBase
//
//  Created by Mr. Gecko on 3/4/09.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#if MGMSIPENABLED
#import <pjsua-lib/pjsua.h>
#endif

@interface NSString (MGMAddons)
+ (NSString *)stringWithSeconds:(int)theSeconds;

- (NSString *)flattenHTML;
- (NSString *)replace:(NSString *)targetString with:(NSString *)replaceString;
- (BOOL)containsString:(NSString *)string;

- (NSString *)javascriptEscape;
- (NSString *)filePath;

- (NSString *)littersToNumbers;
- (NSString *)removePhoneWhiteSpace;
- (BOOL)isPhone;
- (BOOL)isPhoneComplete;
- (NSString *)phoneFormatWithAreaCode:(NSString *)theAreaCode;
- (NSString *)phoneFormatAreaCode:(NSString *)theAreaCode;
- (NSString *)phoneFormat;
- (NSString *)readableNumber;
- (NSString *)areaCode;
- (NSString *)areaCodeLocation;

- (NSString *)addPercentEscapes;

#if !TARGET_OS_IPHONE
- (NSString *)truncateForWidth:(double)theWidth attributes:(NSDictionary *)theAttributes;
#endif

NSComparisonResult dateSort(NSDictionary *info1, NSDictionary *info2, void *context);

- (BOOL)isIPAddress;

#if MGMSIPENABLED
+ (NSString *)stringWithPJString:(pj_str_t)pjString;
- (pj_str_t)PJString;
#endif
@end

@interface NSData (MGMAddons)
#if TARGET_OS_IPHONE
- (NSData *)resizeTo:(CGSize)theSize;
#else
- (NSData *)resizeTo:(NSSize)theSize;
#endif
@end