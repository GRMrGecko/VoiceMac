//
//  MGMURLBasicHandler.h
//  MGMUsers
//
//  Created by Mr. Gecko on 2/21/11.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@class MGMURLConnectionManager;

@interface MGMURLBasicHandler : NSObject {
	MGMURLConnectionManager *manager;
	NSURLConnection *connection;
	NSMutableURLRequest *request;
	NSHTTPURLResponse *response;
	
	NSString *file;
	NSFileHandle *fileHandle;
	NSMutableData *dataBuffer;
	
	unsigned long totalExpected;
	unsigned long totalDownloaded;
	
	id delegate;
	SEL receiveResponse;
	SEL sendRequest;
	SEL bytesUploaded;
	SEL bytesReceived;
	SEL failWithError;
	SEL finish;
	BOOL invisible;
	id object;
	BOOL synchronous;
}
+ (id)handler;
+ (id)handlerWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate;
- (id)initWithRequest:(NSURLRequest *)theRequest delegate:(id)theDelegate;

- (void)setDelegate:(id)theDelegate;
- (id)delegate;
// Arguments
// MGMURLBasicHandler *theHandler
// NSHTTPURLResponse *theResponse
// Default
// handler:didReceiveResponse:
- (void)setReceiveResponse:(SEL)didReceiveResponse;
- (SEL)receiveResponse;
// Arguments
// MGMURLBasicHandler *theHandler
// NSURLRequest *theRequest
// NSHTTPURLResponse *theResponse
// Return
// NSURLRequest *newRequest (nil for continue loading).
// Default
// handler:willSendRequest:redirectResponse:
- (void)setSendRequest:(SEL)willSendRequest;
- (SEL)sendRequest;
// Arguments
// MGMURLBasicHandler *theHandler
// unsigned long theBytes
// unsigned long theTotalBytes
// unsigned long theExpectedBytes
- (void)setBytesUploaded:(SEL)theBytesUploaded;
- (SEL)bytesUploaded;
// Arguments
// MGMURLBasicHandler *theHandler
// unsigned long theBytes
// unsigned long theTotalBytes
// unsigned long theExpectedBytes
- (void)setBytesReceived:(SEL)theBytesReceived;
- (SEL)bytesReceived;
// Arguments
// MGMURLBasicHandler *theHandler
// NSError *theError
// Default
// handler:didFailWithError:
- (void)setFailWithError:(SEL)didFailWithError;
- (SEL)failWithError;
// Arguments
// MGMURLBasicHandler *theHandler
// Default
// handlerDidFinish:
- (void)setFinish:(SEL)didFinish;
- (SEL)finish;
- (void)setInvisible:(BOOL)isInvisible;
- (BOOL)invisible;
- (void)setObject:(id)theObject;
- (id)object;
- (void)setSynchronous:(BOOL)isSynchronous;
- (BOOL)synchronous;
- (void)setFile:(NSString *)theFile;
- (NSString *)file;

- (void)setRequest:(NSURLRequest *)theRequest;
- (NSMutableURLRequest *)request;
- (NSHTTPURLResponse *)response;
- (NSData *)data;
- (NSString *)string;
@end