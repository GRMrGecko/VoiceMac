//
//  MGMHTTPCookieStorage.h
//  MGMUsers
//
//  Created by Mr. Gecko on 12/28/08.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

#define MGMEnableMemorySaving 1

@interface MGMHTTPCookieStorage : NSObject {
@private
#if MGMEnableMemorySaving
	MGMHTTPCookieStorage *foundCookieJar;
#endif
	NSString *cookiesPath;
	NSHTTPCookieAcceptPolicy policy;
	NSMutableArray *cookieJar;
}
#if !TARGET_OS_IPHONE
+ (void)override;
#endif
+ (void)setCookieJarPath:(NSString *)thePath;
+ (MGMHTTPCookieStorage *)sharedHTTPCookieStorage;
+ (MGMHTTPCookieStorage *)sharedCookieStorageWithPath:(NSString *)thePath;
+ (void)releaseShared;
+ (MGMHTTPCookieStorage *)cookieStorageWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;
- (NSArray *)cookies;
- (void)removeAllCookies;
- (void)setNewPath:(NSString *)thePath;
- (void)setCookie:(NSHTTPCookie *)theCookie;
- (void)setCookies:(NSArray *)theCookies;
- (void)deleteCookie:(NSHTTPCookie *)theCookie;
- (NSArray *)cookiesForURL:(NSURL *)theURL;
- (void)setCookies:(NSArray *)theCookies forURL:(NSURL *)theURL mainDocumentURL:(NSURL *)theMainDocumentURL;
- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy;
- (void)setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)cookieAcceptPolicy;
@end