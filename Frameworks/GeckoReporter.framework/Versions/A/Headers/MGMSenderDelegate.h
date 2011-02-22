//
//  MGMSenderDelegate.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/2/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>


@protocol MGMSenderDelegate <NSObject>
- (void)sendError:(NSError *)error;
- (void)sendFinished:(NSString *)received;
@end