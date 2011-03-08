//
//  MGMXMLDocument.m
//  MGMXML
//
//  Created by Mr. Gecko on 9/22/10.
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

#import "MGMXMLDocument.h"
#import "MGMXMLElement.h"
#import <libxml/HTMLtree.h>
#import <libxml/HTMLparser.h>

@implementation MGMXMLDocument
- (id)initWithXMLString:(NSString *)string options:(NSUInteger)mask error:(NSError **)error {
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	return [self initWithData:data options:mask error:error];
}
- (id)initWithContentsOfURL:(NSURL *)url options:(NSUInteger)mask error:(NSError **)error {
	NSData *data = [NSData dataWithContentsOfURL:url];
	return [self initWithData:data options:mask error:error];
}
- (id)initWithData:(NSData *)data options:(NSUInteger)mask error:(NSError **)error {
	if ((self = [super init])) {
		if (data==nil || [data length]<=0) {
			if (error!=nil) *error = [NSError errorWithDomain:MGMXMLErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"Data has no length." forKey:NSLocalizedDescriptionKey]];
			[self release];
			self = nil;
		} else {
			xmlKeepBlanksDefault(0);
			
			xmlDocPtr document = NULL;
			if (mask & MGMXMLDocumentTidyHTML) {
				document = htmlReadMemory([data bytes], [data length], NULL, NULL, XML_PARSE_RECOVER | HTML_PARSE_NONET);
			} else {
				document = xmlParseMemory([data bytes], [data length]);
			}
			if (document==NULL) {
				if (error!=nil) *error = [NSError errorWithDomain:MGMXMLErrorDomain code:1 userInfo:[NSDictionary dictionaryWithObject:@"Unable to parse document." forKey:NSLocalizedDescriptionKey]];
				[self release];
				self = nil;
			} else {
				[self setTypeXMLPtr:(xmlTypPtr)document];
			}
		}
	}
	return self;
}

- (void)setRootElement:(MGMXMLNode *)root {
	if ([root kind]==MGMXMLNamespaceKind)
		return;
	xmlDocSetRootElement(MGMXMLDocPtr, (xmlNodePtr)[root commonXML]);
}
- (MGMXMLElement *)rootElement {
	xmlNodePtr element = xmlDocGetRootElement(MGMXMLDocPtr);
	if (element!=NULL)
		return [MGMXMLElement nodeWithTypeXMLPtr:(xmlTypPtr)element];
	return nil;
}

- (NSData *)XMLData {
	return [[self XMLStringWithOptions:0] dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSData *)XMLDataWithOptions:(NSUInteger)options {
	return [[self XMLStringWithOptions:options] dataUsingEncoding:NSUTF8StringEncoding];
}
@end