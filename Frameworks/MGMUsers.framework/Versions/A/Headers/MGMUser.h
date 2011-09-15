//
//  MGMUser.h
//  MGMUsers
//
//  Created by Mr. Gecko on 7/4/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

extern NSString * const MGMUserStartNotification;
extern NSString * const MGMUserDoneNotification;
extern NSString * const MGMUserUpdatedNotification;
extern NSString * const MGMUserID;
extern NSString * const MGMUserName;
extern NSString * const MGMUserPassword;

@class MGMUser, MGMKeychainItem, MGMHTTPCookieStorage;

@protocol MGMUserDelegate <NSObject>
- (BOOL)isUserDone:(MGMUser *)theUser;
@end

@interface MGMUser : NSObject {
@private
	id<MGMUserDelegate> delegate;
	MGMKeychainItem *keychainItem;
	NSMutableDictionary *settings;
}
+ (NSString *)applicationSupportPath;
+ (NSString *)cachePath;
+ (NSString *)cookieStoragePath;
+ (MGMHTTPCookieStorage *)cookieStorage;
+ (NSMutableDictionary *)usersPlist;
+ (NSArray *)users;
+ (NSArray *)userNames;
+ (NSArray *)lastUsers;
+ (MGMUser *)userWithName:(NSString *)theName;
+ (MGMUser *)userWithID:(NSString *)theID;
+ (MGMUser *)createUserWithName:(NSString *)theName password:(NSString *)thePassword;
- (id)initWithSettings:(NSDictionary *)theSettings;
- (BOOL)isEqual:(id)theObject;
- (id<MGMUserDelegate>)delegate;
- (void)setDelegate:(id)theDelegate;
- (MGMKeychainItem *)keychainItem;
- (void)start;
- (BOOL)isStarted;
- (id)settingForKey:(NSString *)theKey;
- (void)setSetting:(id)theSetting forKey:(NSString *)theKey;
- (BOOL)boolForKey:(NSString *)theKey;
- (void)setBool:(BOOL)theBool forKey:(NSString *)theKey;
- (NSString *)settingsPath;
- (NSDictionary *)settings;
- (void)registerSettings:(NSDictionary *)theSettings;
- (NSString *)supportPath;
- (NSString *)cachePath;
- (NSString *)password;
- (void)setPassword:(NSString *)thePassword;
- (NSString *)cookieStoragePath;
- (MGMHTTPCookieStorage *)cookieStorage;
- (void)done;
- (void)remove;
@end