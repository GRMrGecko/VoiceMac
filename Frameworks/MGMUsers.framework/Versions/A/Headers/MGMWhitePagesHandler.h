//
//  MGMWhitePages.h
//  MGMUsers
//
//  Created by Mr. Gecko on 9/2/09.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@class MGMURLConnectionManager;

@interface MGMWhitePagesHandler : NSObject {
	MGMURLConnectionManager *manager;
	NSURLConnection *connection;
	NSMutableURLRequest *request;
	NSMutableData *dataBuffer;
	
	id delegate;
	SEL findInfo;
	SEL failWithError;
	NSString *phoneNumber;
	NSString *name;
	NSString *address;
	NSString *location;
	NSString *zip;
	NSString *latitude;
	NSString *longitude;
}
+ (id)reverseLookup:(NSString *)thePhoneNumber delegate:(id)theDelegate;
- (id)initWithPhoneNumber:(NSString *)thePhoneNumber delegate:(id)theDelegate;

- (void)setDelegate:(id)theDelegate;
- (id)delegate;
- (void)setFindInfo:(SEL)didFindInfo;
- (SEL)findInfo;
- (void)setFailWithError:(SEL)didFailWithError;
- (SEL)failWithError;
- (void)setPhoneNumber:(NSString *)thePhoneNumber;
- (NSString *)phoneNumber;
- (NSString *)name;
- (NSString *)address;
- (NSString *)location;
- (NSString *)zip;
- (NSString *)latitude;
- (NSString *)longitude;
@end