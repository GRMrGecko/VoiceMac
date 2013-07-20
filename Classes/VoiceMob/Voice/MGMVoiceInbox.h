//
//  MGMVoiceInbox.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class MGMVoiceUser, MGMProgressView, MGMInstance, MGMURLConnectionManager, AVAudioPlayer;

@interface MGMVoiceInbox : NSObject <UIWebViewDelegate, AVAudioPlayerDelegate> {
	MGMVoiceUser *voiceUser;
	
	NSDate *lastUpdate;
	
	int currentView;
	NSArray *inboxItems;
	NSArray *recordingItems;
	
	IBOutlet UITableView *inboxesTable;
	IBOutlet UITableView *inboxTable;
	IBOutlet UIWebView *recordingView;
	MGMProgressView *progressView;
	int progressStartCount;
	
	int currentInbox;
	int maxResults;
	unsigned int start;
	int resultsCount;
	
	NSMutableArray *currentData;
	NSDate *lastDate;
	
	int currentRecording;
	MGMURLConnectionManager *recordingConnection;
	AVAudioPlayer *recordingPlayer;
	NSTimer *recordingUpdater;
}
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (void)registerSettings;

- (MGMVoiceUser *)voiceUser;

- (void)checkVoicemail;

- (UIView *)view;
- (void)releaseView;

- (void)startProgress:(NSString *)theTitle;
- (void)stopProgress;

- (void)loadInbox;
- (void)addData:(NSArray *)theData;
- (int)currentInbox;

- (void)setRecording:(int)theRecording;
@end