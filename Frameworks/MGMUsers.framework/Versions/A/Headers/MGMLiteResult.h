//
//  MGMLiteResult.h
//  MGMUsers
//
//  Created by Mr. Gecko on 8/13/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#else
#import <Cocoa/Cocoa.h>
#import <MGMUsers/sqlite3.h>
#endif
@class MGMLiteConnection;

@interface MGMLiteResult : NSObject {
	MGMLiteConnection *connection;
	sqlite3_stmt *result;
	NSArray *columnNames;
	int columnCount;
}
+ (id)resultWithConnection:(MGMLiteConnection *)theConnection result:(sqlite3_stmt *)theResult;
- (id)initWithConnection:(MGMLiteConnection *)theConnection result:(sqlite3_stmt *)theResult;

- (int)dataCount;
- (int)columnCount;
- (NSString *)columnName:(int)theColumn;
- (NSArray *)columnNames;

- (NSNumber *)integerAtColumn:(int)theColumn;
- (NSNumber *)doubleAtColumn:(int)theColumn;
- (NSString *)stringAtColumn:(int)theColumn;
- (NSData *)dataAtColumn:(int)theColumn;
- (id)objectAtColumn:(int)theColumn;

- (NSArray *)nextRowAsArray;
- (NSDictionary *)nextRow;
- (int)step;
- (int)reset;
@end