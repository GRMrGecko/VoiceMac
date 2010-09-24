//
//  MGMXMLAddons.m
//  MGMXML
//
//  Created by Mr. Gecko on 9/22/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMXMLAddons.h"

@implementation NSValue (MGMXMLAddons)
+ (id)valueWithXMLError:(xmlErrorPtr)error {
	return [NSValue valueWithBytes:error objCType:@encode(xmlErrorPtr)];
}
- (xmlErrorPtr)xmlErrorValue {
	xmlErrorPtr error;
	[self getValue:&error];
	return error;
}
@end

@implementation NSString (MGMXMLAddons)
+ (NSString *)stringWithXMLString:(const xmlChar *)xmlString {
	return [[[NSString alloc] initWithBytes:(const char *)xmlString length:strlen((const char *)xmlString) encoding:NSUTF8StringEncoding] autorelease];
}
- (const xmlChar *)xmlString {
	return (const xmlChar *)[self UTF8String];
}
@end