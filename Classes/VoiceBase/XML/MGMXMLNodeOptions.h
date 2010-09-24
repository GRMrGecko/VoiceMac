/*
 *  MGMXMLNodeOptions.h
 *  MGMXML
 *
 *  Created by Mr. Gecko on 9/22/10.
 *  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
 *
 */

enum {
    MGMXMLNodeOptionsNone = 0,
    
    MGMXMLNodeIsCDATA = 1 << 0,
    MGMXMLNodeExpandEmptyElement = 1 << 1,
    MGMXMLNodeCompactEmptyElement =  1 << 2,
    MGMXMLNodeUseSingleQuotes = 1 << 3,
    MGMXMLNodeUseDoubleQuotes = 1 << 4,
    
    MGMXMLDocumentTidyHTML = 1 << 9,
    MGMXMLDocumentTidyXML = 1 << 10,
    
    MGMXMLDocumentValidate = 1 << 13,
	
    MGMXMLDocumentXInclude = 1 << 16,
    
    MGMXMLNodePrettyPrint = 1 << 17,
    MGMXMLDocumentIncludeContentTypeDeclaration = 1 << 18,
    
    MGMXMLNodePreserveNamespaceOrder = 1 << 20,
    MGMXMLNodePreserveAttributeOrder = 1 << 21,
    MGMXMLNodePreserveEntities = 1 << 22,
    MGMXMLNodePreservePrefixes = 1 << 23,
    MGMXMLNodePreserveCDATA = 1 << 24,
    MGMXMLNodePreserveWhitespace = 1 << 25,
    MGMXMLNodePreserveDTD = 1 << 26,
    MGMXMLNodePreserveCharacterReferences = 1 << 27,    
    MGMXMLNodePreserveEmptyElements = 
	(MGMXMLNodeExpandEmptyElement | MGMXMLNodeCompactEmptyElement),
    MGMXMLNodePreserveQuotes = 
	(MGMXMLNodeUseSingleQuotes | MGMXMLNodeUseDoubleQuotes),	
    MGMXMLNodePreserveAll = (
							MGMXMLNodePreserveNamespaceOrder | 
							MGMXMLNodePreserveAttributeOrder | 
							MGMXMLNodePreserveEntities | 
							MGMXMLNodePreservePrefixes | 
							MGMXMLNodePreserveCDATA | 
							MGMXMLNodePreserveEmptyElements | 
							MGMXMLNodePreserveQuotes | 
							MGMXMLNodePreserveWhitespace |
							MGMXMLNodePreserveDTD |
							MGMXMLNodePreserveCharacterReferences |
							0xFFF00000)
};