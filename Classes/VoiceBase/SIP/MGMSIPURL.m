//
//  MGMSIPURL.m
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
#import "MGMSIPURL.h"

@implementation MGMSIPURL
+ (id)URLWithFullName:(NSString *)theFullName userName:(NSString *)theUserName host:(NSString *)theHost {
	return [[[self alloc] initWithFullName:theFullName userName:theUserName host:theHost] autorelease];
}
- (id)initWithFullName:(NSString *)theFullName userName:(NSString *)theUserName host:(NSString *)theHost {
	if ((self = [super init])) {
		if (theHost==nil || [theHost isEqual:@""]) {
			[self release];
			self = nil;
		} else {
			fullName = [theFullName copy];
			userName = [theUserName copy];
			host = [theHost copy];
			port = 0;
		}
	}
	return self;
}
+ (id)URLWithSIPAddress:(NSString *)theSIPAddress {
	return [[[self alloc] initWithSIPAddress:theSIPAddress] autorelease];
}
- (id)initWithSIPAddress:(NSString *)theSIPAddress {
	return [self initWithSIPID:[NSString stringWithFormat:@"<sip:%@>", theSIPAddress]];
}
+ (id)URLWithSIPID:(NSString *)theSIPID {
	return [[[self alloc] initWithSIPID:theSIPID] autorelease];
}
- (id)initWithSIPID:(NSString *)theSIPID {
	if ((self = [super init])) {
		NSString *fullNameString, *addressString;
		NSRange range = [theSIPID rangeOfString:@"<sip:"];
		if (range.location==NSNotFound) {
			NSLog(@"Not a valid SIP ID.");
			[self release];
			self = nil;
		} else {
			NSMutableCharacterSet *characterSet = [NSMutableCharacterSet whitespaceCharacterSet];
			[characterSet addCharactersInString:@"'\"<>"];
			fullNameString = [[theSIPID substringToIndex:range.location] stringByTrimmingCharactersInSet:characterSet];
			addressString = [[theSIPID substringFromIndex:range.location+range.length] stringByTrimmingCharactersInSet:characterSet];
			if (![fullNameString isEqual:@""])
				fullName = [fullNameString copy];
			if (![addressString isEqual:@""]) {
				range = [addressString rangeOfString:@"@"];
				if (range.location!=NSNotFound) {
					userName = [[addressString substringToIndex:range.location] copy];
					addressString = [addressString substringFromIndex:range.location+range.length];
					range = [addressString rangeOfString:@":"];
					if (range.location!=NSNotFound) {
						host = [[addressString substringToIndex:range.location] copy];
						port = [[addressString substringFromIndex:range.location+range.length] intValue];
					}
				}
				if (host==nil) {
					host = [addressString copy];
					port = 0;
				}
			}
		}
	}
	return self;
}
- (void)dealloc {
	[fullName release];
	[userName release];
	[host release];
	[super dealloc];
}

- (NSString *)description {
	return [self SIPID];
}
- (NSString *)fullName {
	return fullName;
}
- (void)setFullName:(NSString *)theFullName {
	if (fullName!=nil) [fullName release];
	fullName = [theFullName copy];
}
- (NSString *)userName {
	return userName;
}
- (void)setUserName:(NSString *)theUserName {
	if (userName!=nil) [userName release];
	if (theUserName==nil) {
		userName = [@"" copy];
		return;
	}
	userName = [theUserName copy];
}
- (NSString *)host {
	return host;
}
- (void)setHost:(NSString *)theHost {
	if (theHost==nil || [theHost isEqual:@""]) return;
	if (host!=nil) [host release];
	host = [theHost copy];
}
- (int)port {
	return port;
}
- (void)setPort:(int)thePort {
	port = thePort;
}

- (NSString *)SIPAddress {
	NSMutableString *string = [NSMutableString string];
	if (userName!=nil && ![userName isEqual:@""])
		[string appendFormat:@"%@@", userName];
	[string appendString:host];
	if (port!=0)
		[string appendFormat:@":%d", port];
	return string;
}
- (NSString *)SIPID {
	NSMutableString *string = [NSMutableString string];
	if (fullName!=nil && ![fullName isEqual:@""])
		[string appendFormat:@"%@ ", fullName];
	[string appendString:@"<sip:"];
	if (userName!=nil && ![userName isEqual:@""])
		[string appendFormat:@"%@@", userName];
	[string appendString:host];
	if (port!=0)
		[string appendFormat:@":%d", port];
	[string appendString:@">"];
	return string;
}
@end
#endif