//
//  MGMThemeDownloader.m
//  VoiceMob
//
//  Created by Mr. Gecko on 11/6/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMDownloader.h"
#import "ZipArchive.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

NSString * const MGMTMPPath = @"~/tmp/";
NSString * const MGMZIPEXT = @"zip";

NSString * const MGMVMTURL = @"vmtheme";
NSString * const MGMVMSURL = @"vmsound";

@implementation MGMDownloader
- (id)initWithSetting:(MGMSetting *)theSetting {
	if ((self = [super initWithSetting:theSetting])) {
		connectionManager = [MGMURLConnectionManager new];
	}
	return self;
}
- (id)init {
	if ((self = [super init])) {
		connectionManager = [MGMURLConnectionManager new];
	}
	return self;
}
- (void)dealloc {
	[self releaseView];
	[URLScheme release];
	[tmpFile release];
	[fileHandle release];
	[secCheckTimer invalidate];
	[secCheckTimer release];
	[receivedSec release];
	[super dealloc];
}

- (UIView *)view {
	if (webView==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:@"Downloader" owner:self options:nil]) {
			NSLog(@"Unable to load Downloader");
			[self release];
			self = nil;
		} else {
			[webView setDelegate:self];
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[setting extra] objectForKey:MGMSExtraKey]]]];
		}
	}
	return webView;
}
- (void)releaseView {
	[webView release];
	webView = nil;
	[downloadView release];
	downloadView = nil;
	[progressView release];
	progressView = nil;
	[nameField release];
	nameField = nil;
	[sizeField release];
	sizeField = nil;
	[speedField release];
	speedField = nil;
	[estimentField release];
	estimentField = nil;
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([[[[request URL] scheme] lowercaseString] isEqual:MGMVMTURL]) {
		[self downloadURL:[request URL]];
		return NO;
	} else if ([[[[request URL] scheme] lowercaseString] isEqual:MGMVMSURL]) {
		[self downloadURL:[request URL]];
		return NO;
	}
	return YES;
}
- (void)downloadURL:(NSURL *)theURL {
	[URLScheme release];
	URLScheme = [[[theURL scheme] lowercaseString] copy];
	theURL = [NSURL URLWithString:[@"http:" stringByAppendingString:[theURL resourceSpecifier]]];
	UIView *view = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
	CGRect inViewFrame = [downloadView frame];
	inViewFrame.size = [view frame].size;
	inViewFrame.origin.y = +inViewFrame.size.height;
	[downloadView setFrame:inViewFrame];
	[view addSubview:downloadView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [downloadView frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[downloadView setFrame:outViewFrame];
	[UIView commitAnimations];
	
	bytesReceivedSec = 1;
	receivedContentLength = 0;
	expectedContentLength = 0;
	[self secCheck];
	[progressView setProgress:0.0];
	[nameField setText:@""];
	
	srandomdev();
	[tmpFile release];
	tmpFile = [[[[[NSNumber numberWithLong:random()] stringValue] MD5] stringByAppendingPathExtension:MGMZIPEXT] retain];
	
	if (secCheckTimer==nil)
		secCheckTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secCheck) userInfo:nil repeats:YES] retain];
	
	MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self];
	[handler setFile:[[MGMTMPPath stringByExpandingTildeInPath] stringByAppendingPathComponent:tmpFile]];
	[connectionManager addHandler:handler];
}
- (IBAction)close:(id)sender {
	[connectionManager cancelAll];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(closeAnimationDidStop:finished:context:)];
	CGRect outViewFrame = [downloadView frame];
	outViewFrame.origin.y = +outViewFrame.size.height;
	[downloadView setFrame:outViewFrame];
	[UIView commitAnimations];
	[secCheckTimer release];
	secCheckTimer = nil;
	[fileHandle closeFile];
	[fileHandle release];
	fileHandle = nil;
	[tmpFile release];
	tmpFile = nil;
}
- (void)closeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[downloadView removeFromSuperview];
}

- (NSString *)bytesToString:(double)bytes {
	NSString *type = @"Bytes";
	if (bytes>1024.00) {
		type = @"KB";
		bytes = bytes/1024.00;
		if (bytes>1024.00) {
			type = @"MB";
			bytes = bytes/1024.00;
			if (bytes>1024.00) {
				type = @"GB";
				bytes = bytes/1024.00;
			}
		}
	}
	return [NSString stringWithFormat:@"%.2f %@", bytes, type];
}

- (void)secCheck {
	[receivedSec release];
	receivedSec = [[self bytesToString:(double)bytesReceived] retain];
	bytesReceivedSec = (bytesReceived==0 ? 1 : bytesReceived);
	bytesReceived = 0;
	int secs = (expectedContentLength-receivedContentLength)/bytesReceivedSec;
	[sizeField setText:[NSString stringWithFormat:@"%@ of %@", [self bytesToString:(double)receivedContentLength], [self bytesToString:(double)expectedContentLength]]];
	[speedField setText:[NSString stringWithFormat:@"%@/sec", receivedSec]];
	[estimentField setText:[NSString stringWithSeconds:secs]];
}

- (void)handler:(MGMURLBasicHandler *)theHandler didReceiveResponse:(NSHTTPURLResponse *)theResponse {
	[nameField setText:[theResponse suggestedFilename]];
}
- (void)handler:(MGMURLBasicHandler *)theHandler receivedBytes:(unsigned long)theBytes totalBytes:(unsigned long)theTotalBytes expectedBytes:(unsigned long)theExpectedBytes {
	expectedContentLength = theExpectedBytes;
	receivedContentLength = theTotalBytes;
	bytesReceived += theBytes;
	[progressView setProgress:(double)theTotalBytes/(double)theExpectedBytes];
}
- (void)handler:(MGMURLBasicHandler *)theHandler didFailWithError:(NSError *)theError {
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error downloading"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
	[self close:self];
}
- (void)handlerDidFinish:(MGMURLBasicHandler *)theHandler {
	ZipArchive *zip = [ZipArchive new];
	[zip UnzipOpenFile:[[MGMTMPPath stringByExpandingTildeInPath] stringByAppendingPathComponent:tmpFile]];
	[zip UnzipFileTo:([URLScheme isEqual:MGMVMTURL] ? [[[MGMThemeManager new] autorelease] themesFolderPath] : [[[MGMThemeManager new] autorelease] soundsFolderPath]) overWrite:YES];
	[zip UnzipCloseFile];
	[zip release];
	[[NSFileManager defaultManager] removeItemAtPath:[[MGMTMPPath stringByExpandingTildeInPath] stringByAppendingPathComponent:tmpFile] error:nil];
	[self performSelector:@selector(close:) withObject:nil afterDelay:0.5];
}
@end