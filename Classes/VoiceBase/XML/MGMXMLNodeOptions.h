//
//  MGMXMLNodeOptions.m
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