//
//  MGMDelegateInfo.m
//  VoiceBase
//
//  Created by Mr. Gecko on 2/23/11.
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

#import "MGMDelegateInfo.h"

@implementation MGMDelegateInfo
+ (id)info {
	return [[[self alloc] init] autorelease];
}
+ (id)infoWithDelegate:(id)theDelegate {
	return [[[self alloc] initWithDelegate:theDelegate] autorelease];
}
- (id)initWithDelegate:(id)theDelegate {
	if ((self = [super init])) {
		delegate = theDelegate;
	}
	return self;
}
- (void)dealloc {
	[entries release];
	[phoneNumbers release];
	[phone release];
	[message release];
	[identifier release];
	[super dealloc];
}
- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}
- (id)delegate {
	return delegate;
}
- (void)setReceiveInfo:(SEL)didReceiveInfo {
	receiveInfo = didReceiveInfo;
}
- (SEL)receiveInfo {
	return receiveInfo;
}
- (void)setFinish:(SEL)didFinish {
	finish = didFinish;
}
- (SEL)finish {
	return finish;
}
- (void)setFailWithError:(SEL)didFailWithError {
	failWithError = didFailWithError;
}
- (SEL)failWithError {
	return failWithError;
}
- (void)setEntries:(NSArray *)theEntries {
	[entries release];
	entries = [theEntries retain];
}
- (NSArray *)entries {
	return entries;
}
- (void)setPhoneNumbers:(NSArray *)thePhoneNumbers {
	[phoneNumbers release];
	phoneNumbers = [thePhoneNumbers retain];
}
- (NSArray *)phoneNumbers {
	return phoneNumbers;
}
- (void)setPhone:(NSString *)thePhone {
	[phone release];
	phone = [thePhone retain];
}
- (NSString *)phone {
	return phone;
}
- (void)setMessage:(NSString *)theMessage {
	[message release];
	message = [theMessage retain];
}
- (NSString *)message {
	return message;
}
- (void)setIdentifier:(NSString *)theIdentifier {
	[identifier release];
	identifier = [theIdentifier retain];
}
- (NSString *)identifier {
	return identifier;
}
@end