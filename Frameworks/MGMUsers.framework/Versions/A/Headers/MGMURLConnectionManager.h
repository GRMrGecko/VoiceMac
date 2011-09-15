//
//  MGMURLConnectionManager.h
//  MGMUsers
//
//  Created by Mr. Gecko on 2/21/11.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@class MGMURLConnectionManager;

@protocol MGMURLConnectionHandler <NSObject>
- (void)setManager:(MGMURLConnectionManager *)theManager;
- (void)setConnection:(NSURLConnection *)theConnection;
- (NSURLConnection *)connection;
- (void)setRequest:(NSMutableURLRequest *)theRequest;
- (NSMutableURLRequest *)request;
- (BOOL)synchronous;
- (NSURLCredential *)credentailsForChallenge:(NSURLAuthenticationChallenge *)theChallenge;
- (void)uploaded:(unsigned long)theBytes totalBytes:(unsigned long)theTotalBytes totalBytesExpected:(unsigned long)theExpectedBytes;
- (NSURLRequest *)willSendRequest:(NSURLRequest *)theRequest redirectResponse:(NSHTTPURLResponse *)theResponse;
- (void)didReceiveResponse:(NSHTTPURLResponse *)theResponse;
- (void)didReceiveData:(NSData *)theData;
- (void)didFailWithError:(NSError *)theError;
- (void)didFinishLoading;
@end

@interface MGMURLConnectionManager : NSObject {
    NSHTTPCookieStorage *cookieStorage;
    NSString *userAgent;
	NSURLCredential *credentials;
	NSMutableArray *handlers;
	
	BOOL runningSynchronousConnection;
}
+ (id)manager;
+ (id)managerWithCookieStorage:(id)theCookieStorage;
- (id)initWithCookieStorage:(id)theCookieStorage;

- (void)setCookieStorage:(id)theCookieStorage;
- (NSHTTPCookieStorage *)cookieStorage;
- (void)setUserAgent:(NSString *)theUserAgent;
- (NSString *)userAgent;
- (void)setCredentials:(NSURLCredential *)theCredentials;
- (void)setUser:(NSString *)theUser password:(NSString *)thePassword;
- (NSURLCredential *)credentials;

- (void)addHandler:(id)theHandler;
- (void)cancelHandler:(id)theHandler;
- (void)cancelAll;
@end