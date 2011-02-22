//
//  MGMXMLNode.m
//  MGMXML
//
//  Created by Mr. Gecko on 9/22/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMXMLNode.h"
#import "MGMXMLAddons.h"
#import "MGMXMLDocument.h"
#import "MGMXMLElement.h"
#import "MGMXMLNodeOptions.h"

NSString * const MGMXMLErrorDomain = @"MGMXMLErrorDomain";
NSString * const MGMXMLLastError = @"MGMXMLLastError";

static NSMutableDictionary *MGMXMLInfo = nil;

static void MGMXMLErrorHandler(void *userData, xmlErrorPtr error) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];;
	if (error==NULL) {
		[MGMXMLInfo removeObjectForKey:MGMXMLLastError];
	} else {
		[MGMXMLInfo setObject:[NSValue valueWithXMLError:error] forKey:MGMXMLLastError];
	}
	[pool drain];
}

@implementation MGMXMLNode
+ (void)initialize {
	if (MGMXMLInfo==nil) {
		MGMXMLInfo = [NSMutableDictionary new];
		
		initGenericErrorDefaultFunc(NULL);
		xmlSetStructuredErrorFunc(NULL, MGMXMLErrorHandler);
		xmlKeepBlanksDefault(0);
	}
}

- (id)init {
	if ((self = [super init])) {
		commonXML = NULL;
		namespaceXML = NULL;
		parentNode = NULL;
		type = MGMXMLInvalidKind;
	}
	return self;
}
+ (id)nodeWithTypeXMLPtr:(xmlTypPtr)theXMLPtr {
	return [[[self alloc] initWithTypeXMLPtr:theXMLPtr] autorelease];
}
- (id)initWithTypeXMLPtr:(xmlTypPtr)theXMLPtr {
	if ((self = [self init])) {
		if (theXMLPtr->type==MGMXMLNamespaceKind) {
			xmlNsPtr xmlPtr = (xmlNsPtr)theXMLPtr;
			if (xmlPtr->_private!=NULL) {
				[self release];
				self = nil;
				return [(MGMXMLNode *)xmlPtr->_private retain];
			}
		} else {
			xmlComPtr comXML = (xmlComPtr)theXMLPtr;
			if (comXML->_private!=NULL) {
				[self release];
				self = nil;
				return [(MGMXMLNode *)comXML->_private retain];
			}
		}
		[self setTypeXMLPtr:theXMLPtr];
	}
	return self;
}
- (void)clearParent {
	parentNode = NULL;
}
- (void)freeXML {
	if (namespaceXML!=NULL) {
		namespaceXML->_private = NULL;
		
		if (parentNode==NULL)
			xmlFreeNs(namespaceXML);
		namespaceXML = NULL;
		parentNode = NULL;
	}
	if (commonXML!=NULL) {
		commonXML->_private = NULL;
		if (type!=MGMXMLDocumentKind)
			[self releaseDocument];
		
		if (commonXML->parent==NULL) {
			if (type==MGMXMLDocumentKind) {
				xmlNodePtr child = commonXML->children;
				while (child!=NULL) {
					xmlNodePtr nextChild = child->next;
					if (child->type==MGMXMLElementKind) {
						if (child->prev!=NULL)
							child->prev->next = child->next;
						if (child->next!=NULL)
							child->next->prev = child->prev;
						if (commonXML->children==child)
							commonXML->children = child->next;
						if (commonXML->last==child)
							commonXML->last = child->prev;
						[[self class] freeNode:child];
					}
					child = nextChild;
				}
				xmlFreeDoc(MGMXMLDocPtr);
			} else if (type==MGMXMLAttributeKind) {
				xmlFreeProp(MGMXMLAttrPtr);
			} else if (type==MGMXMLDTDKind) {
				xmlFreeDtd(MGMXMLDTDPtr);
			} else {
				[[self class] freeNode:MGMXMLNodePtr];
			}
		}
		commonXML = NULL;
	}
	type = MGMXMLInvalidKind;
}
- (void)dealloc {
	[self freeXML];
	[super dealloc];
}
+ (void)stripDocumentFromAttribute:(xmlAttrPtr)theAttribute {
	xmlNodePtr child = theAttribute->children;
	while (child!=NULL) {
		child->doc = NULL;
		child = child->next;
	}
	theAttribute->doc = NULL;
}
+ (void)stripDocumentFromNode:(xmlNodePtr)theNode {
	xmlAttrPtr attribute = theNode->properties;
	while (attribute!=NULL) {
		[self stripDocumentFromAttribute:attribute];
		attribute = attribute->next;
	}
	
	xmlNodePtr child = theNode->children;
	while (child!=NULL) {
		[self stripDocumentFromNode:child];
		child = child->next;
	}
	theNode->doc = NULL;
}
+ (void)removeAttributesFromNode:(xmlNodePtr)theNode {
	xmlAttrPtr attribute = theNode->properties;
	while (attribute!=NULL) {
		xmlAttrPtr nextAttribute = attribute->next;
		
		if (attribute->_private==NULL) {
			xmlFreeProp(attribute);
		} else {
			attribute->parent = NULL;
			attribute->prev = NULL;
			attribute->next = NULL;
			if (attribute->doc!=NULL) [self stripDocumentFromAttribute:attribute];
		}
		attribute = nextAttribute;
	}
	theNode->properties = NULL;
}
+ (void)removeNamespacesFromNode:(xmlNodePtr)theNode {
	xmlNsPtr namespace = theNode->nsDef;
	while (namespace!=NULL){
		xmlNsPtr nextNamespace = namespace->next;
		if (namespace->_private!=NULL) {
			[(MGMXMLNode *)namespace->_private clearParent];
			namespace->next = NULL;
		} else {
			xmlFreeNs(namespace);
		}
		namespace = nextNamespace;
	}
	theNode->nsDef = NULL;
	theNode->ns = NULL;
}
+ (void)removeChildrenFromNode:(xmlNodePtr)theNode {
	xmlNodePtr child = theNode->children;
	while (child!=NULL) {
		xmlNodePtr nextChild = child->next;
		[self freeNode:child];
		child = nextChild;
	}
	theNode->children = NULL;
	theNode->last = NULL;
}
+ (void)freeNode:(xmlNodePtr)theNode {
	if (![[self class] isNode:theNode->type]) {
		NSLog(@"Cannot free node as it is the wrong type %d.", theNode->type);
	} else {
		if (theNode->_private==NULL) {
			[self removeAttributesFromNode:theNode];
			[self removeNamespacesFromNode:theNode];
			[self removeChildrenFromNode:theNode];
			
			xmlFreeNode(theNode);
		} else {
			theNode->parent = NULL;
			theNode->prev = NULL;
			theNode->next = NULL;
			if (theNode->doc!=NULL) {
				[(MGMXMLNode *)theNode->_private releaseDocument];
				[self stripDocumentFromNode:theNode];
			}
		}
	}
}

- (void)setTypeXMLPtr:(xmlTypPtr)theXMLPtr {
	[self freeXML];
	type = theXMLPtr->type;
	if (type==XML_HTML_DOCUMENT_NODE)
		type = MGMXMLDocumentKind;
	if (type==MGMXMLNamespaceKind) {
		namespaceXML = (xmlNsPtr)theXMLPtr;
		namespaceXML->_private = self;
	} else {
		commonXML = (xmlComPtr)theXMLPtr;
		commonXML->_private = self;
		if (type==MGMXMLDocumentKind && [self isMemberOfClass:[MGMXMLNode class]])
			self->isa = [MGMXMLDocument class];
		else if (type==MGMXMLElementKind && [self isMemberOfClass:[MGMXMLNode class]])
			self->isa = [MGMXMLElement class];
		if (type!=MGMXMLDocumentKind)
			documentNode = [[MGMXMLDocument alloc] initWithTypeXMLPtr:(xmlTypPtr)commonXML->doc];
	}
}
- (void)releaseDocument {
	[documentNode release];
	documentNode = nil;
}
+ (BOOL)isNode:(MGMXMLNodeKind)theType {
	switch (theType) {
		case MGMXMLElementKind:
		case MGMXMLProcessingInstructionKind:
		case MGMXMLCommentKind:
		case MGMXMLTextKind:
		case XML_CDATA_SECTION_NODE:
			return YES;
			break;
		default:
			break;
	}
	return NO;
}
- (BOOL)isNode {
	return [[self class] isNode:type];
}
+ (NSError *)lastError {
	if ([MGMXMLInfo objectForKey:MGMXMLLastError]!=nil) {
		xmlErrorPtr lastError = [[MGMXMLInfo objectForKey:MGMXMLLastError] xmlErrorValue];
		NSString *description = [[NSString stringWithUTF8String:lastError->message] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		return [NSError errorWithDomain:MGMXMLErrorDomain code:lastError->code userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]];
	}
	return nil;
}
- (NSError *)lastError {
	return [[self class] lastError];
}

- (MGMXMLNodeKind)kind {
	return type;
}
- (xmlComPtr)commonXML {
	return commonXML;
}
- (xmlNsPtr)nameSpaceXML {
	return namespaceXML;
}
- (void)setName:(NSString *)name {
	if (type==MGMXMLNamespaceKind) {
		if (namespaceXML->prefix!=NULL)
			xmlFree((xmlChar *)namespaceXML->prefix);
		namespaceXML->prefix = xmlStrdup([name xmlString]);
	} else {
		xmlNodeSetName(MGMXMLNodePtr, [name xmlString]);
	}
}
- (NSString *)name {
	if (type==MGMXMLNamespaceKind) {
		if (namespaceXML->prefix!=NULL)
			return [NSString stringWithXMLString:namespaceXML->prefix];
	} else {
		if (MGMXMLNodePtr->name!=NULL)
			return [NSString stringWithXMLString:(xmlChar *)MGMXMLNodePtr->name];
	}
	return nil;
}
- (NSString *)stringValue {
	if (type==MGMXMLNamespaceKind) {
		return [NSString stringWithXMLString:namespaceXML->href];
	} else if (type==MGMXMLAttributeKind) {
		if (MGMXMLAttrPtr->children!=NULL)
			return [NSString stringWithXMLString:MGMXMLAttrPtr->children->content];
	} else if ([self isNode]) {
		xmlChar *contentString = xmlNodeGetContent(MGMXMLNodePtr);
		NSString *stringValue = [NSString stringWithXMLString:contentString];
		xmlFree(contentString);
		return stringValue;
	}
	return nil;
}

- (MGMXMLDocument *)rootDocument {
	if (MGMXMLNodePtr->doc!=NULL)
		return [MGMXMLDocument nodeWithTypeXMLPtr:(xmlTypPtr)MGMXMLNodePtr->doc];
	return nil;
}
- (MGMXMLNode *)parent {
	return [MGMXMLNode nodeWithTypeXMLPtr:(xmlTypPtr)MGMXMLNodePtr->parent];
}
- (MGMXMLNode *)childAtIndex:(NSUInteger)index {
	if (type==MGMXMLNamespaceKind)
		return nil;
	
	NSUInteger i = 0;
	xmlNodePtr child = commonXML->children;
	while (child!=NULL) {
		if (i==index)
			return [MGMXMLNode nodeWithTypeXMLPtr:(xmlTypPtr)child];
		i++;
		child = child->next;
	}
	return nil;
}
+ (void)detatchAttribute:(xmlAttrPtr)theAttribute fromNode:(xmlNodePtr)theNode {
	if (theAttribute->prev==NULL && theAttribute->next==NULL) {
		theNode->properties = NULL;
	} else if (theAttribute->prev==NULL) {
		theNode->properties = theAttribute->next;
		theAttribute->next->prev = NULL;
	} else if (theAttribute->next==NULL) {
		theAttribute->prev->next = NULL;
	} else {
		theAttribute->prev->next = theAttribute->next;
		theAttribute->next->prev = theAttribute->prev;
	}
	theAttribute->parent = NULL;
	theAttribute->prev = NULL;
	theAttribute->next = NULL;
	if (theAttribute->doc!=NULL) [[self class] stripDocumentFromAttribute:theAttribute];
}
- (void)detach {
	if (type==MGMXMLNamespaceKind) {
		if (parentNode!=NULL) {
			xmlNsPtr previousNamespace = NULL;
			xmlNsPtr currentNamespace = parentNode->nsDef;
			while (currentNamespace!=NULL) {
				if (currentNamespace==namespaceXML) {
					if (previousNamespace!=NULL)
						previousNamespace->next = currentNamespace->next;
					else
						parentNode->nsDef = currentNamespace->next;
					break;
				}
				previousNamespace = currentNamespace;
				currentNamespace = currentNamespace->next;
			}
			namespaceXML->next = NULL;
			if (parentNode->ns==namespaceXML)
				parentNode->ns = NULL;
			parentNode = NULL;
		}
		return;
	}
	
	if (commonXML->parent==NULL) return;
	
	if (type==MGMXMLAttributeKind) {
		[[self class] detatchAttribute:MGMXMLAttrPtr fromNode:MGMXMLAttrPtr->parent];
	} else if ([self isNode]) {
		if (commonXML->prev==NULL && commonXML->next==NULL) {
			commonXML->parent->children = NULL;
			commonXML->parent->last = NULL;
		} else if (commonXML->prev==NULL) {
			commonXML->parent->children = commonXML->next;
			commonXML->next->prev = NULL;
		} else if (commonXML->next==NULL) {
			commonXML->parent->last = commonXML->prev;
			commonXML->prev->next = NULL;
		} else {
			commonXML->prev->next = commonXML->next;
			commonXML->next->prev = commonXML->prev;
		}
		commonXML->parent = NULL;
		commonXML->prev = NULL;
		commonXML->next = NULL;
		if (commonXML->doc!=NULL) [[self class] stripDocumentFromNode:MGMXMLNodePtr];
	}
}

+ (NSString *)localNameForName:(NSString *)name {
	if (name!=nil && [name length]>0) {
		NSRange range = [name rangeOfString:@":"];
		if (range.location!=NSNotFound)
			return [name substringFromIndex:range.location+range.length];
		else
			return name;
	}
	return nil;
}
+ (NSString *)prefixForName:(NSString *)name {
	if (name!=nil && [name length]>0) {
		NSRange range = [name rangeOfString:@":"];
		if (range.location!=NSNotFound)
			return [name substringToIndex:range.location];
	}
	return nil;
}

- (NSString *)description {
	return [self XMLString];
}
- (NSString *)XMLString {
	return [self XMLStringWithOptions:0];
}
- (NSString *)XMLStringWithOptions:(NSUInteger)options {
	if(options & MGMXMLNodeCompactEmptyElement)
		xmlSaveNoEmptyTags = 0;
	else
		xmlSaveNoEmptyTags = 1;
	
	int format = 0;
	if (options & MGMXMLNodePrettyPrint) {
		format = 1;
		xmlIndentTreeOutput = 1;
	}
	
	xmlBufferPtr bufferPtr = xmlBufferCreate();
	if (type==MGMXMLNamespaceKind)
		xmlNodeDump(bufferPtr, NULL, MGMXMLNodePtr, 0, format);
	else
		xmlNodeDump(bufferPtr, commonXML->doc, MGMXMLNodePtr, 0, format);
	
	NSString *result = [NSString stringWithXMLString:bufferPtr->content];
	if (type!=MGMXMLTextKind)
		result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	xmlBufferFree(bufferPtr);
	return result;
}

- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error {
	BOOL shouldRemoveDocument = NO;
	xmlDocPtr document;
	if ([self isNode]) {
		document = MGMXMLNodePtr->doc;
		if (document==NULL) {
			shouldRemoveDocument = YES;
			document = xmlNewDoc(NULL);
			xmlDocSetRootElement(document, MGMXMLNodePtr);
		}
	} else if (type==MGMXMLDocumentKind) {
		document = MGMXMLDocPtr;
	} else {
		return nil;
	}
	
	xmlXPathContextPtr xPathContext = xmlXPathNewContext(document);
	xPathContext->node = MGMXMLNodePtr;
	
	xmlNodePtr rootNode = document->children;
	if (rootNode!=NULL) {
		xmlNsPtr namespace = rootNode->nsDef;
		while (namespace!=NULL) {
			xmlXPathRegisterNs(xPathContext, namespace->prefix, namespace->href);
			namespace = namespace->next;
		}
	}
	
	xmlXPathObjectPtr xPathObject = xmlXPathEvalExpression([xpath xmlString], xPathContext);
	
	NSMutableArray *nodes = [NSMutableArray array];
	
	if (xPathObject==NULL) {
		if (error!=nil) *error = [self lastError];
		nodes = nil;
	} else {
		int count = xmlXPathNodeSetGetLength(xPathObject->nodesetval);
		if (count!=0) {
			for (int i=0; i<count; i++)
				[nodes addObject:[MGMXMLNode nodeWithTypeXMLPtr:(xmlTypPtr)xPathObject->nodesetval->nodeTab[i]]];
		}
	}
	
	if (xPathObject) xmlXPathFreeObject(xPathObject);
	if (xPathContext) xmlXPathFreeContext(xPathContext);
	
	if (shouldRemoveDocument) {
		xmlUnlinkNode(MGMXMLNodePtr);
		xmlFreeDoc(document);
		[[self class] stripDocumentFromNode:MGMXMLNodePtr];
	}
	
	return nodes;
}
@end