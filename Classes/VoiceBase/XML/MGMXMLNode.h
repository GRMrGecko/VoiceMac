//
//  MGMXMLNode.h
//  MGMXML
//
//  Created by Mr. Gecko on 9/22/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <MGMXMLNodeOptions.h>
#else
#import <Cocoa/Cocoa.h>
#import <VoiceBase/MGMXMLNodeOptions.h>
#endif
#import <libxml/parser.h>
#import <libxml/tree.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <libxml/HTMLtree.h>
#import <libxml/HTMLparser.h>

#define MGMXMLNodePtr ((xmlNodePtr)commonXML)
#define MGMXMLAttrPtr ((xmlAttrPtr)commonXML)
#define MGMXMLDTDPtr ((xmlDtdPtr)commonXML)

@class MGMXMLDocument, MGMXMLElement;

extern NSString * const MGMXMLErrorDomain;

typedef enum {
	MGMXMLInvalidKind = 0,
	MGMXMLDocumentKind = XML_DOCUMENT_NODE,
	MGMXMLElementKind = XML_ELEMENT_NODE,
	MGMXMLAttributeKind = XML_ATTRIBUTE_NODE,
	MGMXMLNamespaceKind = XML_NAMESPACE_DECL,
	MGMXMLProcessingInstructionKind = XML_PI_NODE,
	MGMXMLCommentKind = XML_COMMENT_NODE,
	MGMXMLTextKind = XML_TEXT_NODE,
	MGMXMLDTDKind = XML_DTD_NODE,
	MGMXMLEntityDeclarationKind = XML_ENTITY_DECL,
	MGMXMLAttributeDeclarationKind = XML_ATTRIBUTE_DECL,
	MGMXMLElementDeclarationKind = XML_ELEMENT_DECL,
	MGMXMLNotationDeclarationKind = XML_NOTATION_NODE
} MGMXMLNodeKind;

//The common XML structure that has type.
typedef struct _xmlTyp xmlTyp;
typedef xmlTyp *xmlTypPtr;
struct _xmlTyp {
    void *trash;
    xmlElementType type;
};

//The common XML structure.
typedef struct _xmlCom xmlCom;
typedef xmlCom *xmlComPtr;
struct _xmlCom {
    void *_private;
    xmlElementType type;
    char *name;
    struct _xmlNode *children;
    struct _xmlNode *last;
    struct _xmlNode *parent;
    struct _xmlNode *next;
    struct _xmlNode *prev;
    struct _xmlDoc *doc;
};

@interface MGMXMLNode : NSObject {
	xmlComPtr commonXML;
	xmlNsPtr namespaceXML;
	xmlNodePtr parentNode;
	MGMXMLNodeKind type;
	MGMXMLDocument *documentNode;
}
+ (id)nodeWithTypeXMLPtr:(xmlTypPtr)theXMLPtr;
- (id)initWithTypeXMLPtr:(xmlTypPtr)theXMLPtr;
+ (void)stripDocumentFromAttribute:(xmlAttrPtr)theAttribute;
+ (void)stripDocumentFromNode:(xmlNodePtr)theNode;
+ (void)removeAttributesFromNode:(xmlNodePtr)theNode;
+ (void)removeNamespacesFromNode:(xmlNodePtr)theNode;
+ (void)removeChildrenFromNode:(xmlNodePtr)theNode;
+ (void)freeNode:(xmlNodePtr)theNode;
- (void)setTypeXMLPtr:(xmlTypPtr)theXMLPtr;
- (void)releaseDocument;
+ (BOOL)isNode:(MGMXMLNodeKind)theType;
- (BOOL)isNode;
+ (NSError *)lastError;
- (NSError *)lastError;
//- (id)initWithKind:(MGMXMLNodeKind)kind;
//- (id)initWithKind:(MGMXMLNodeKind)kind options:(NSUInteger)options; //primitive
//+ (id)document;
//+ (id)documentWithRootElement:(MGMXMLElement *)element;
//+ (id)elementWithName:(NSString *)name;
//+ (id)elementWithName:(NSString *)name URI:(NSString *)URI;
//+ (id)elementWithName:(NSString *)name stringValue:(NSString *)string;
//+ (id)elementWithName:(NSString *)name children:(NSArray *)children attributes:(NSArray *)attributes;
//+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)stringValue;
//+ (id)attributeWithName:(NSString *)name URI:(NSString *)URI stringValue:(NSString *)stringValue;
//+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)stringValue;
//+ (id)processingInstructionWithName:(NSString *)name stringValue:(NSString *)stringValue;
//+ (id)commentWithStringValue:(NSString *)stringValue;
//+ (id)textWithStringValue:(NSString *)stringValue;
//+ (id)DTDNodeWithXMLString:(NSString *)string;

- (MGMXMLNodeKind)kind;
- (xmlComPtr)commonXML;
- (xmlNsPtr)nameSpaceXML;
- (void)setName:(NSString *)name;
- (NSString *)name;
//- (void)setObjectValue:(id)value; //primitive
//- (id)objectValue; //primitive
//- (void)setStringValue:(NSString *)string;
//- (void)setStringValue:(NSString *)string resolvingEntities:(BOOL)resolve; //primitive
- (NSString *)stringValue; //primitive

//- (NSUInteger)index; //primitive
//- (NSUInteger)level;
- (MGMXMLDocument *)rootDocument;
- (MGMXMLNode *)parent; //primitive
//- (NSUInteger)childCount; //primitive
//- (NSArray *)children; //primitive
- (MGMXMLNode *)childAtIndex:(NSUInteger)index; //primitive
//- (MGMXMLNode *)previousSibling;
//- (MGMXMLNode *)nextSibling;
//- (MGMXMLNode *)previousNode;
//- (MGMXMLNode *)nextNode;
+ (void)detatchAttribute:(xmlAttrPtr)theAttribute fromNode:(xmlNodePtr)theNode;
- (void)detach; //primitive
//- (NSString *)XPath;

//- (NSString *)localName; //primitive
//- (NSString *)prefix; //primitive
//- (void)setURI:(NSString *)URI; //primitive
//- (NSString *)URI; //primitive
+ (NSString *)localNameForName:(NSString *)name;
+ (NSString *)prefixForName:(NSString *)name;
//+ (MGMXMLNode *)predefinedNamespaceForPrefix:(NSString *)name;

- (NSString *)description;
- (NSString *)XMLString;
- (NSString *)XMLStringWithOptions:(NSUInteger)options;
//- (NSString *)canonicalXMLStringPreservingComments:(BOOL)comments;

- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery constants:(NSDictionary *)constants error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery error:(NSError **)error;
@end