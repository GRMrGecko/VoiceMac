//
//  MGMWhitePages.h
//  MGMUsers
//
//  Created by Mr. Gecko on 9/2/09.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

extern NSString * const MGMWPDelegate;
extern NSString * const MGMWPDidFindInfo;
extern NSString * const MGMWPDidFailWithError;
extern NSString * const MGMWPPhoneNumber;
extern NSString * const MGMWPName;
extern NSString * const MGMWPAddress;
extern NSString * const MGMWPLocation;
extern NSString * const MGMWPZip;
extern NSString * const MGMWPLatitude;
extern NSString * const MGMWPLongitude;

@class MGMURLConnectionManager;

@interface MGMWhitePages : NSObject {
	MGMURLConnectionManager *connectionManager;
	NSDictionary *states;
	BOOL lookingup;
}
- (void)cancelAll;
- (void)reverseLookup:(NSString *)thePhoneNumber delegate:(id)theDelegate;
- (void)reverseLookup:(NSString *)thePhoneNumber delegate:(id)theDelegate didFailWithError:(SEL)didFailWithError didFindInfo:(SEL)didFindInfo;
@end