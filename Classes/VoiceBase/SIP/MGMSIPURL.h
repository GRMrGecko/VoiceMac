//
//  MGMSIPURL.h
//  VoiceBase
//
//  Created by Mr. Gecko on 9/11/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@interface MGMSIPURL : NSObject {
	NSString *fullName;
	NSString *userName;
	NSString *host;
	int port;
}
+ (id)URLWithFullName:(NSString *)theFullName userName:(NSString *)theUserName host:(NSString *)theHost;
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName host:(NSString *)theHost;
+ (id)URLWithSIPAddress:(NSString *)theSIPAddress;
- (id)initWithSIPAddress:(NSString *)theSIPAddress;
+ (id)URLWithSIPID:(NSString *)theSIPID;
- (id)initWithSIPID:(NSString *)theSIPID;

- (NSString *)fullName;
- (void)setFullName:(NSString *)theFullName;
- (NSString *)userName;
- (void)setUserName:(NSString *)theUserName;
- (NSString *)host;
- (void)setHost:(NSString *)theHost;
- (int)port;
- (void)setPort:(int)thePort;

- (NSString *)SIPAddress;
- (NSString *)SIPID;
@end
#endif