//
//  MGMJSON.h
//  MGMUsers
//
//  Created by Mr. Gecko on 7/31/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@interface NSString (MGMJSON)
- (id)parseJSON;
- (NSString *)JSONValue;
@end
@interface NSData (MGMJSON)
- (id)parseJSON;
@end
@interface NSNumber (MGMJSON)
- (NSString *)JSONValue;
@end
@interface NSNull (MGMJSON)
- (NSString *)JSONValue;
@end
@interface NSDictionary (MGMJSON)
- (NSString *)JSONValue;
@end
@interface NSArray (MGMJSON)
- (NSString *)JSONValue;
@end

@interface MGMJSON : NSObject {
@private
	NSMutableCharacterSet *escapeSet;
    NSString *JSONString;
    unsigned long position;
    unsigned long length;
}
- (id)initWithString:(NSString *)theString;
- (id)parse;
- (void)skipWhitespace;
- (void)skipDigits;
- (id)parseForObject;
- (NSDictionary *)parseForDictionary;
- (NSArray *)parseForArray;
- (NSString *)parseForString;
- (unichar)parseForUnicodeChar;
- (NSNumber *)parseForYES;
- (id)parseForNONULL;
- (NSNumber *)parseForNumber;

- (NSString *)convert:(id)theObject;
- (NSString *)writeString:(NSString *)theString;
- (NSString *)writeNumber:(NSNumber *)theNumber;
- (NSString *)writeBool:(NSNumber *)theNumber;
- (NSString *)writeNull:(NSNull *)theNull;
- (NSString *)writeDictionary:(NSDictionary *)theDictionary;
- (NSString *)writeArray:(NSArray *)theArray;
@end