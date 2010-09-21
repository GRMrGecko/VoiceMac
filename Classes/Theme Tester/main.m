//
//  main.m
//  Voice Mac
//
//  Created by Mr. Gecko on 7/24/09.
//  Copyright Mr. Gecko's Media 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
	[pool drain];
	return NSApplicationMain(argc, (const char **)argv);
}