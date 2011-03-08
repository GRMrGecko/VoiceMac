//
//  MGMSIPURL.h
//  VoiceBase
//
//  Created by Mr. Gecko on 9/11/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose
//  with or without fee is hereby granted, provided that the above copyright notice
//  and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT,
//  OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
//  DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
//  ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
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