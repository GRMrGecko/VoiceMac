//
//  MGMXMLAddons.h
//  MGMXML
//
//  Created by Mr. Gecko on 9/22/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import <libxml/parser.h>
#import <libxml/tree.h>

@interface NSValue (MGMXMLAddons)
+ (id)valueWithXMLError:(xmlErrorPtr)error;
- (xmlErrorPtr)xmlErrorValue;
@end

@interface NSString (MGMXMLAddons)
+ (NSString *)stringWithXMLString:(const xmlChar *)xmlString;
- (const xmlChar *)xmlString;
@end