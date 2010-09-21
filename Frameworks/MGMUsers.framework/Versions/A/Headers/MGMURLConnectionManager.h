//
//  MGMURLConnectionManager.h
//  MGMUsers
//
//  Created by Mr. Gecko on 7/23/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

extern NSString * const MGMCookie;
extern NSString * const MGMUserAgent;

extern NSString * const MGMConnectionObject;
extern NSString * const MGMConnectionRequest;
extern NSString * const MGMConnectionOldRequest;
extern NSString * const MGMConnectionResponse;
extern NSString * const MGMConnectionDelegate;
extern NSString * const MGMConnectionDidReceiveResponse;
extern NSString * const MGMConnectionDidReceiveData;
extern NSString * const MGMConnectionWillRedirect;
extern NSString * const MGMConnectionDidFailWithError;
extern NSString * const MGMConnectionDidFinish;
extern NSString * const MGMConnectionInvisible;
extern NSString * const MGMConnectionData;

@interface MGMURLConnectionManager : NSObject {
@private
    NSHTTPCookieStorage *cookieStorage;
    NSMutableArray *connections;
    NSURLConnection *connection;
    NSMutableData *receivedData;
    NSString *customUseragent;
	NSURLCredential *credentials;
}
+ (id)defaultManager;
+ (id)managerWithCookieStorage:(id)theCookieStorage;
- (id)initWithCookieStorage:(id)theCookieStorage;
- (NSHTTPCookieStorage *)cookieStorage;
- (void)setCredentials:(NSURLCredential *)theCredentials;
- (NSURLCredential *)credentials;
- (void)setCookieStorage:(id)theCookieStorage;
- (NSString *)customUseragent;
- (void)setCustomUseragent:(NSString *)theCustomUseragent;
- (NSData *)synchronousRequest:(NSURLRequest *)theRequest returningResponse:(NSURLResponse **)theResponse error:(NSError **)theError;
- (void)connectionWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate;
- (void)connectionWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate object:(id)theObject;
- (void)connectionWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish invisible:(BOOL)isInvisible object:(id)theObject;
- (void)connectionWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate didReceiveResponse:(SEL)didReceiveResponse didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish invisible:(BOOL)isInvisible object:(id)theObject;
- (void)connectionWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate didReceiveResponse:(SEL)didReceiveResponse willRedirect:(SEL)willRedirect didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish invisible:(BOOL)isInvisible object:(id)theObject;
- (void)connectionWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate didReceiveResponse:(SEL)didReceiveResponse didReceiveData:(SEL)didReceiveData willRedirect:(SEL)willRedirect didFailWithError:(SEL)didFailWithError didFinish:(SEL)didFinish invisible:(BOOL)isInvisible object:(id)theObject;
- (void)cancelCurrent;
- (void)cancelAll;
@end