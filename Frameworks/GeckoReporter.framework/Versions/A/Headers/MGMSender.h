//
//  MGMSender.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/28/09.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import "MGMSenderDelegate.h"

@interface MGMSender : NSObject {
	id<MGMSenderDelegate> delegate;
	NSMutableData *receivedData;
	NSURLConnection *theConnection;
}
- (void)sendReport:(NSString *)theReportPath reportDate:(NSDate *)theReportDate userReport:(NSString *)theUserReport delegate:(id)theDelegate;
- (void)sendBug:(NSString *)theBug reproduce:(NSString *)theReproduce delegate:(id)theDelegate;
- (void)sendMessage:(NSString *)theMessage subject:(NSString *)theSubject delegate:(id)theDelegate;
@end