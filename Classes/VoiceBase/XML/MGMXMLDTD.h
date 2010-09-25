//
//  MGMXMLDTD.h
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

@interface MGMXMLDTD : MGMXMLNode {

}
//- (id)initWithContentsOfURL:(NSURL *)url options:(NSUInteger)mask error:(NSError **)error;
//- (id)initWithData:(NSData *)data options:(NSUInteger)mask error:(NSError **)error; //primitive
//- (void)setPublicID:(NSString *)publicID; //primitive
//- (NSString *)publicID; //primitive
//- (void)setSystemID:(NSString *)systemID; //primitive
//- (NSString *)systemID; //primitive

//- (void)insertChild:(MGMXMLNode *)child atIndex:(NSUInteger)index; //primitive
//- (void)insertChildren:(NSArray *)children atIndex:(NSUInteger)index;
//- (void)removeChildAtIndex:(NSUInteger)index; //primitive
//- (void)setChildren:(NSArray *)children; //primitive
//- (void)addChild:(MGMXMLNode *)child;
//- (void)replaceChildAtIndex:(NSUInteger)index withNode:(MGMXMLNode *)node;

//- (MGMXMLDTDNode *)entityDeclarationForName:(NSString *)name; //primitive
//- (MGMXMLDTDNode *)notationDeclarationForName:(NSString *)name; //primitive
//- (MGMXMLDTDNode *)elementDeclarationForName:(NSString *)name; //primitive
//- (MGMXMLDTDNode *)attributeDeclarationForName:(NSString *)name elementName:(NSString *)elementName; //primitive
//+ (MGMXMLDTDNode *)predefinedEntityDeclarationForName:(NSString *)name;
@end