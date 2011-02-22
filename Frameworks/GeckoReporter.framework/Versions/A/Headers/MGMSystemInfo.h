//
//  MGMSystemInfo.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/31/09.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>


@interface MGMSystemInfo : NSObject {

}
+ (MGMSystemInfo *)info;
- (NSString *)architecture;
- (BOOL)is64Bit;
- (NSString *)CPUFamily;
- (int)CPUCount;
- (NSString *)model;
- (NSString *)modelName;
- (int)CPUMHz;
- (int)RAMSize;
- (int)OSMajorVersion;
- (int)OSMinorVersion;
- (int)OSBugFixVersion;
- (NSString *)OSVersion;
- (NSString *)OSVersionName;
- (BOOL)isAfterCheetah;
- (BOOL)isAfterPuma;
- (BOOL)isAfterJaguar;
- (BOOL)isAfterPanther;
- (BOOL)isAfterTiger;
- (BOOL)isAfterLeopard;
- (BOOL)isAfterSnowLeopard;
- (NSString *)language;
- (NSString *)applicationIdentifier;
- (NSString *)applicationName;
- (NSString *)applicationEXECName;
- (NSString *)applicationVersion;
- (BOOL)isUIElement;
- (NSBundle *)frameworkBundle;
- (NSString *)frameworkVersion;
- (NSString *)useragentWithApplicationNameAndVersion:(NSString *)nameAndVersion;
- (NSString *)useragent;
@end
