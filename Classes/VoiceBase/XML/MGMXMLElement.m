//
//  MGMXMLElement.m
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

#import "MGMXMLElement.h"
#import "MGMXMLDocument.h"
#import "MGMXMLAddons.h"

@implementation MGMXMLElement
- (id)initWithName:(NSString *)name {
	return [self initWithName:name stringValue:nil];
}
- (id)initWithName:(NSString *)name stringValue:(NSString *)string {
	if ((self = [super init])) {
		xmlNodePtr node = xmlNewNode(NULL, [name xmlString]);
		if (string!=nil)
			xmlNodeSetContent(node, [string xmlString]);
		[self setTypeXMLPtr:(xmlTypPtr)node];
	}
	return self;
}
- (id)initWithXMLString:(NSString *)string error:(NSError **)error {
	[super release];
	MGMXMLDocument *document = [[MGMXMLDocument alloc] initWithXMLString:string options:0 error:error];
	MGMXMLElement *element = nil;
	if (document!=nil) {
		element = [[document rootElement] retain];
		if (element!=nil)
			[element detach];
		[document release];
	}
	return element;
}

- (NSArray *)elementsForName:(NSString *)name URI:(NSString *)URI resolvingNamespacePrefix:(BOOL)resolveNamespacePrefix {
	NSMutableArray *elements = [NSMutableArray array];
	
	if (resolveNamespacePrefix && URI!=nil) {
		NSString *prefix = [self resolvePrefixForNamespaceURI:URI];
		if (prefix!=nil)
			name = [NSString stringWithFormat:@"%@:%@", prefix, name];
	}
	NSString *localName = [[self class] localNameForName:name];
	BOOL hasPrefix = ([[self class] prefixForName:localName]!=nil);
	
	xmlNodePtr child = MGMXMLNodePtr->children;
	while (child!=NULL) {
		if (child->type==MGMXMLElementKind) {
			BOOL shouldAddElement = NO;
			if (URI==nil) {
				shouldAddElement = xmlStrEqual(child->name, [name xmlString]);
			} else {
				if (hasPrefix && xmlStrEqual(child->name, [name xmlString]))
					shouldAddElement = YES;
				else if (child->ns!=NULL)
					shouldAddElement = xmlStrEqual(child->name, [(hasPrefix ? localName : name) xmlString]) && xmlStrEqual(child->ns->href, [URI xmlString]);
			}
			
			if (shouldAddElement)
				[elements addObject:[MGMXMLElement nodeWithTypeXMLPtr:(xmlTypPtr)child]];
		}
		
		child = child->next;
	}
	return elements;
}
- (NSArray *)elementsForName:(NSString *)name {
	NSString *localName = [[self class] localNameForName:name];
	NSString *prefix = [[self class] prefixForName:name];
	NSString *uri = nil;
	if (prefix!=nil) {
		if (MGMXMLNodePtr->doc==NULL) {
			NSLog(@"You may not search for elements with a namespace if there is no document.");
			return nil;
		}
		xmlNsPtr namespace = xmlSearchNs(MGMXMLNodePtr->doc, MGMXMLNodePtr, [prefix xmlString]);
		if (namespace!=NULL)
			uri = [NSString stringWithXMLString:namespace->href];
	}
	
	return [self elementsForName:localName URI:uri resolvingNamespacePrefix:NO];
}
- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI {
	return [self elementsForName:localName URI:URI resolvingNamespacePrefix:YES];
}

- (void)addAttribute:(MGMXMLNode *)attribute {
	if ([attribute kind]==MGMXMLAttributeKind && [attribute commonXML]->parent!=NULL)
		[self removeAttributeForName:[attribute name]];
	xmlAddChild(MGMXMLNodePtr, (xmlNodePtr)[attribute commonXML]);
}
- (void)removeAttributeForName:(NSString *)name {
	xmlAttrPtr attribute = MGMXMLNodePtr->properties;
	while (attribute!=NULL) {
		if (xmlStrEqual(attribute->name, [name xmlString])) {
			[[self class] detatchAttribute:attribute fromNode:MGMXMLNodePtr];
			
			if(attribute->_private == NULL)
				xmlFreeProp(attribute);
			break;
		}
		attribute = attribute->next;
	}
}
- (NSArray *)attributes {
	NSMutableArray *attributes = [NSMutableArray array];
	xmlAttrPtr attribute = MGMXMLNodePtr->properties;
	while (attribute!=NULL) {
		[attributes addObject:[MGMXMLNode nodeWithTypeXMLPtr:(xmlTypPtr)attribute]];
		attribute = attribute->next;
	}
	return attributes;
}
- (MGMXMLNode *)attributeForName:(NSString *)name {
	xmlAttrPtr attribute = MGMXMLNodePtr->properties;
	while (attribute!=NULL) {
		if (xmlStrEqual(attribute->name, [name xmlString]))
			return [MGMXMLNode nodeWithTypeXMLPtr:(xmlTypPtr)attribute];
		attribute = attribute->next;
	}
	return nil;
}

- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI {
	xmlNodePtr child = MGMXMLNodePtr;
	while (child!=NULL) {
		xmlNsPtr namespace = child->nsDef;
		while (namespace!=NULL) {
			if (xmlStrEqual(namespace->href, [namespaceURI xmlString])) {
				if (namespace->prefix!=NULL)
					return [NSString stringWithXMLString:namespace->prefix];
			}
			namespace = namespace->next;
		}
	}
	
	return nil;
}
@end