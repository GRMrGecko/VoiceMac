//
//  NSAddons.h
//  VoiceBase
//
//  Created by Mr. Gecko on 3/4/09.
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

#import <Foundation/Foundation.h>
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