//
//  MGMThemeDownloader.h
//  VoiceMob
//
//  Created by Mr. Gecko on 11/6/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>
#import <MGMUsers/MGMUsers.h>

@class MGMURLConnectionManager;

@interface MGMDownloader : MGMSettingView <UIWebViewDelegate> {
	MGMURLConnectionManager *connectionManager;
	IBOutlet UIWebView *webView;
	
	IBOutlet UIView *downloadView;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *nameField;
	IBOutlet UILabel *sizeField;
	IBOutlet UILabel *speedField;
	IBOutlet UILabel *estimentField;
	
	NSString *URLScheme;
	NSString *tmpFile;
	NSFileHandle *fileHandle;
	int startTime;
	int bytesReceivedSec;
	int bytesReceived;
	NSTimer *secCheckTimer;
	NSString *receivedSec;
    int receivedContentLength;
    int expectedContentLength;
}
- (void)downloadURL:(NSURL *)theURL;
- (void)secCheck;
- (IBAction)close:(id)sender;
@end