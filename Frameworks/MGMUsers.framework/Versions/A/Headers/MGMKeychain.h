//
//  MGMKeychain.h
//  MGMUsers
//
//  Created by Mr. Gecko on 4/3/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@class MGMKeychainItem;

@interface MGMKeychain : NSObject {

}
+ (BOOL)itemExists:(NSString *)theDescription withName:(NSString *)theName service:(NSString *)theService account:(NSString *)theAccount;
+ (BOOL)itemExists:(NSString *)theDescription withName:(NSString *)theName service:(NSString *)theService account:(NSString *)theAccount itemClass:(SecItemClass)theClass;
+ (NSArray *)items:(NSString *)theDescription withName:(NSString *)theName service:(NSString *)theService account:(NSString *)theAccount;
+ (NSArray *)items:(NSString *)theDescription withName:(NSString *)theName service:(NSString *)theService account:(NSString *)theAccount itemClass:(SecItemClass)theClass;
+ (MGMKeychainItem *)addItem:(NSString *)theDescription withName:(NSString *)theName service:(NSString *)theService account:(NSString *)theAccount password:(NSString *)thePassword;
+ (MGMKeychainItem *)addItem:(NSString *)theDescription withName:(NSString *)theName service:(NSString *)theService account:(NSString *)theAccount password:(NSString *)thePassword itemClass:(SecItemClass)theClass;
@end