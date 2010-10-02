//
//  MGMXMLElement.h
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
#import <VoiceBase/MGMXMLNode.h>

@interface MGMXMLElement : MGMXMLNode {

}
//- (id)initWithName:(NSString *)name;
//- (id)initWithName:(NSString *)name URI:(NSString *)URI; //primitive
//- (id)initWithName:(NSString *)name stringValue:(NSString *)string;
- (id)initWithXMLString:(NSString *)string error:(NSError **)error;

- (NSArray *)elementsForName:(NSString *)name;
- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI;

- (void)addAttribute:(MGMXMLNode *)attribute; //primitive
- (void)removeAttributeForName:(NSString *)name; //primitive
//- (void)setAttributes:(NSArray *)attributes; //primitive
//- (void)setAttributesAsDictionary:(NSDictionary *)attributes;
- (NSArray *)attributes; //primitive
- (MGMXMLNode *)attributeForName:(NSString *)name;
//- (MGMXMLNode *)attributeForLocalName:(NSString *)localName URI:(NSString *)URI; //primitive

//- (void)addNamespace:(MGMXMLNode *)aNamespace; //primitive
//- (void)removeNamespaceForPrefix:(NSString *)name; //primitive
//- (void)setNamespaces:(NSArray *)namespaces; //primitive
//- (NSArray *)namespaces; //primitive
//- (MGMXMLNode *)namespaceForPrefix:(NSString *)name;
//- (MGMXMLNode *)resolveNamespaceForName:(NSString *)name;
- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI;

//- (void)insertChild:(MGMXMLNode *)child atIndex:(NSUInteger)index; //primitive
//- (void)insertChildren:(NSArray *)children atIndex:(NSUInteger)index;
//- (void)removeChildAtIndex:(NSUInteger)index; //primitive
//- (void)setChildren:(NSArray *)children; //primitive
//- (void)addChild:(MGMXMLNode *)child;
//- (void)replaceChildAtIndex:(NSUInteger)index withNode:(MGMXMLNode *)node;
//- (void)normalizeAdjacentTextNodesPreservingCDATA:(BOOL)preserve;
@end