//
//  MGMDelegateInfo.h
//  VoiceBase
//
//  Created by Mr. Gecko on 2/23/11.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@interface MGMDelegateInfo : NSObject {
	id delegate;
	SEL receiveInfo;
	SEL finish;
	SEL failWithError;
	NSArray *entries;
	NSArray *phoneNumbers;
	NSString *phone;
	NSString *message;
	NSString *identifier;
}
+ (id)info;
+ (id)infoWithDelegate:(id)theDelegate;
- (id)initWithDelegate:(id)theDelegate;
- (void)setDelegate:(id)theDelegate;
- (id)delegate;
- (void)setReceiveInfo:(SEL)didReceiveInfo;
- (SEL)receiveInfo;
- (void)setFinish:(SEL)didFinish;
- (SEL)finish;
- (void)setFailWithError:(SEL)didFailWithError;
- (SEL)failWithError;
- (void)setEntries:(NSArray *)theEntries;
- (NSArray *)entries;
- (void)setPhoneNumbers:(NSArray *)thePhoneNumbers;
- (NSArray *)phoneNumbers;
- (void)setPhone:(NSString *)thePhone;
- (NSString *)phone;
- (void)setMessage:(NSString *)theMessage;
- (NSString *)message;
- (void)setIdentifier:(NSString *)theIdentifier;
- (NSString *)identifier;
@end