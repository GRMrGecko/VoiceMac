//
//  MGMSIPRecordings.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/14/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern NSString * const MGMRecordingsFolder;

extern NSString * const MGMRName;
extern NSString * const MGMRDate;

@class MGMSIPUser;

@interface MGMSIPRecordings : NSObject <UIWebViewDelegate, AVAudioPlayerDelegate> {
	MGMSIPUser *SIPUser;
	
	NSMutableArray *recordings;
	NSArray *recordingItems;
	
	IBOutlet UITableView *recordingsTable;
	IBOutlet UIWebView *recordingView;
	
	int currentRecording;
	AVAudioPlayer *recordingPlayer;
	NSTimer *recordingUpdater;
}
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser;
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser;

- (MGMSIPUser *)SIPUser;

- (UIView *)view;
- (void)releaseView;

- (void)setRecording:(int)theRecording;
@end