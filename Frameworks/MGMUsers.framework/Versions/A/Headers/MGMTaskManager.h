//
//  MGMTaskManager.h
//  YouView
//
//  Created by Mr. Gecko on 4/16/09.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

extern NSString * const MGMTAURL;
extern NSString * const MGMTAFilePath;
extern NSString * const MGMTAVMTaskPath;
extern NSString * const MGMTAFileName;
extern NSString * const MGMTADonePath;
extern NSString * const MGMTARevealPath;
extern NSString * const MGMTATime;

extern NSString * const MGMTAInfoPlist;

extern NSString * const MGMVMTaskExt;
extern NSString * const MGMMP3Ext;
extern NSString * const MGMZIPExt;
extern NSString * const MGMVMTExt;
extern NSString * const MGMVMSExt;

@protocol MGMTaskManagerDelegate <NSObject>

@end


@interface MGMTaskManager : NSObject {
	id delegate;
	
	IBOutlet NSWindow *tasksWindow;
	IBOutlet NSTableView *taskTable;
	IBOutlet NSTextField *numTasks;
	NSMutableArray *tasks;
}
+ (id)managerWithDelegate:(id)theDelegate;
- (id)initWithDelegate:(id)theDelegate;

- (id<MGMTaskManagerDelegate>)delegate;

- (void)reloadData;
- (void)updateCount;
- (IBAction)showTaskManager:(id)sender;
- (IBAction)clear:(id)sender;
- (void)addTask:(NSDictionary *)theTask withURL:(NSURL *)theURL;
- (void)saveURL:(NSURL *)theURL withName:(NSString *)theName;

- (void)application:(NSApplication *)sender openFiles:(NSArray *)files;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
@end