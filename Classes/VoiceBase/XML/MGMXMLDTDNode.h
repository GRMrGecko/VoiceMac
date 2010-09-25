//
//  MGMXMLDTDNode.h
//  MGMXML
//
//  Created by Mr. Gecko on 9/22/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <MGMXMLNode.h>
#else
#import <Cocoa/Cocoa.h>
#import <VoiceBase/MGMXMLNode.h>
#endif

@interface MGMXMLDTDNode : MGMXMLNode {

}
//- (id)initWithXMLString:(NSString *)string; //primitive
//- (void)setDTDKind:(MGMXMLDTDNodeKind)kind; //primitive
//- (MGMXMLDTDNodeKind)DTDKind; //primitive
//- (BOOL)isExternal; //primitive
//- (void)setPublicID:(NSString *)publicID; //primitive
//- (NSString *)publicID; //primitive
//- (void)setSystemID:(NSString *)systemID; //primitive
//- (NSString *)systemID; //primitive
//- (void)setNotationName:(NSString *)notationName; //primitive
//- (NSString *)notationName; //primitive
@end