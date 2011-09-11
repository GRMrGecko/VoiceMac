//
//  MGMLiteConnection.h
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

#define MGMLiteDebug 0

@class MGMLiteResult;

@interface MGMLiteConnection : NSObject {
	sqlite3 *SQLiteConnection;
	NSString *path;
	BOOL isConnected;
	NSCharacterSet *escapeSet;
	BOOL logQuery;
}
+ (id)memoryConnection;
+ (id)connectionWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;

- (sqlite3 *)SQLiteConnection;
- (NSString *)path;

- (NSString *)errorMessage;
- (int)errorID;

- (NSString *)escapeData:(NSData *)theData;
- (NSString *)escapeString:(NSString *)theString;
- (NSString *)quoteObject:(id)theObject;
- (NSString *)quoteChar:(const char *)theChar;

- (BOOL)logQuery;
- (void)setLogQuery:(BOOL)shouldLogQuery;
- (MGMLiteResult *)query:(NSString *)format, ...;
- (MGMLiteResult *)tables;
- (MGMLiteResult *)tablesLike:(NSString *)theName;
- (MGMLiteResult *)columnsFromTable:(NSString *)theTable;
- (int)affectedRows;
- (long long int)insertId;
@end