//
//  MGMReporter.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/27/09.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

extern NSString * const MGMGRDoneNotification;
extern NSString * const MGMGRUserEmail;
extern NSString * const MGMGRUserName;
extern NSString * const MGMGRLastCrashDate;
extern NSString * const MGMGRSendAll;
extern NSString * const MGMGRIgnoreAll;

#define MGMGRReleaseDebug 0

@class MGMSender;

@interface MGMReporter : NSObject {
	BOOL foundReport;
	NSDate *lastDate;
	MGMSender *mailSender;
}
+ (id)sharedReporter;
@end
