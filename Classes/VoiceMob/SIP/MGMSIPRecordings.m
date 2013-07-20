//
//  MGMSIPRecordings.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/14/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMSIPRecordings.h"
#import "MGMSIPUser.h"
#import "MGMRecordingView.h"
#import "MGMAccountController.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

NSString * const MGMRecordingsFolder = @"recordings";

NSString * const MGMRName = @"name";
NSString * const MGMRDate = @"date";
NSString * const MGMRFile = @"file";

NSString * const MGMRecordingCellIdentifier = @"MGMRecordingCellIdentifier";

@implementation MGMSIPRecordings
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser {
	return [[[self alloc] initWithSIPUser:theSIPUser] autorelease];
}
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser {
	if ((self = [super init])) {
		SIPUser = theSIPUser;
		
		recordingItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:@"Recordings" style:UIBarButtonItemStyleBordered target:self action:@selector(showRecordings:)] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease], [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:[SIPUser accountController] action:@selector(showSettings:)] autorelease], nil] retain];
		currentRecording = -1;
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[recordingItems release];
	[recordingPlayer release];
	[super dealloc];
}

- (MGMSIPUser *)SIPUser {
	return SIPUser;
}

- (UIView *)view {
	if (recordingsTable==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"SIPRecordings"] owner:self options:nil]) {
			NSLog(@"Unable to load SIP Recordings");
		} else {
			recordings = [NSMutableArray new];
			NSDirectoryEnumerator *recordingFolder = [[NSFileManager defaultManager] enumeratorAtPath:[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMRecordingsFolder]];
			NSString *recordingName = nil;
			while ((recordingName = [recordingFolder nextObject])) {
				NSMutableDictionary *recording = [NSMutableDictionary dictionary];
				[recording setObject:[recordingName stringByDeletingPathExtension] forKey:MGMRName];
				[recording setObject:[[recordingFolder fileAttributes] objectForKey:NSFileCreationDate] forKey:MGMRDate];
				[recording setObject:[[[[SIPUser user] supportPath] stringByAppendingPathComponent:MGMRecordingsFolder] stringByAppendingPathComponent:recordingName] forKey:MGMRFile];
				[recordings addObject:recording];
			}
			[recordingsTable reloadData];
			
			[recordingView setDelegate:self];
			[recordingView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"recording" ofType:@"html"]]]];
			
			if (currentRecording!=-1)
				[[SIPUser accountController] setItems:recordingItems animated:YES];
			else
				[[SIPUser accountController] setItems:[[SIPUser accountController] accountItems] animated:YES];
		}
	}
	if (currentRecording!=-1)
		return recordingView;
	return recordingsTable;
}
- (void)releaseView {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[recordingsTable release];
	recordingsTable = nil;
	[recordings release];
	recordings = nil;
	[recordingView release];
	recordingView = nil;
	[recordingUpdater invalidate];
	[recordingUpdater release];
	recordingUpdater = nil;
	[recordingPlayer pause];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [recordings count];
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MGMRecordingView *cell = (MGMRecordingView *)[recordingsTable dequeueReusableCellWithIdentifier:MGMRecordingCellIdentifier];
	if (cell==nil) {
		cell = [[[MGMRecordingView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMRecordingCellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	[cell setRecording:[recordings objectAtIndex:[indexPath indexAtPosition:1]]];
	return cell;
}
- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)theTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)theTableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Delete";
}
- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *recording = [recordings objectAtIndex:[indexPath indexAtPosition:1]];
	[[NSFileManager defaultManager] removeItemAtPath:[recording objectForKey:MGMRFile] error:nil];
	[recordings removeObject:recording];
	[recordingsTable reloadData];
}
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self setRecording:[indexPath indexAtPosition:1]];
}

- (void)setRecording:(int)theRecording {
	currentRecording = theRecording;
	if (currentRecording==-1)
		return;
	[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerLoading()"];
	
	[[recordingItems objectAtIndex:0] setEnabled:NO];
	[[SIPUser accountController] setItems:recordingItems animated:YES];
	
	recordingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[recordings objectAtIndex:currentRecording] objectForKey:MGMRFile]] error:nil];
	[recordingPlayer setDelegate:self];
	if (recordingView!=nil) {
		[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setDurration(%d)", (int)[recordingPlayer duration]]];
		[recordingView stringByEvaluatingJavaScriptFromString:@"setCurrent(0)"];
		[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerPlaying()"];
		[recordingPlayer play];
		recordingUpdater = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecording) userInfo:nil repeats:YES] retain];
	}
	
	CGRect outViewFrame = [recordingsTable frame];
	CGRect inViewFrame = [recordingView frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = +inViewFrame.size.width;
	[recordingView setFrame:inViewFrame];
	[[SIPUser tabView] addSubview:recordingView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(recordingAnimationDidStop:finished:context:)];
	[recordingView setFrame:outViewFrame];
	outViewFrame.origin.x = -outViewFrame.size.width;
	[recordingsTable setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)recordingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[recordingsTable removeFromSuperview];
	[recordingsTable deselectRowAtIndexPath:[recordingsTable indexPathForSelectedRow] animated:NO];
	[[recordingItems objectAtIndex:0] setEnabled:YES];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerPaused()"];
}
- (void)updateRecording {
	[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setCurrent(%d)", (int)[recordingPlayer currentTime]]];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
	NSString *scheme = [[url scheme] lowercaseString];
	NSString *data = [url resourceSpecifier];
	NSString *queryData = [url query];
	NSDictionary *query;
	if (queryData) {
		NSMutableArray *dataArr = [NSMutableArray arrayWithArray:[data componentsSeparatedByString:@"?"]];
		[dataArr removeLastObject];
		data = [dataArr componentsJoinedByString:@"?"];
		NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
		NSArray *parameters = [queryData componentsSeparatedByString:@"&"];
		for (int i=0; i<[parameters count]; i++) {
			NSArray *info = [[parameters objectAtIndex:i] componentsSeparatedByString:@"="];
			[dataDic setObject:[[[info subarrayWithRange:NSMakeRange(1, [info count]-1)] componentsJoinedByString:@"="] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[info objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		query = [NSDictionary dictionaryWithDictionary:dataDic];
	}
	if ([data hasPrefix:@"//"])
		data = [data substringFromIndex:2];
	
	if ([scheme isEqual:@"voicemob"]) {
		if ([data isEqual:@"pause"])
			[recordingPlayer pause];
		else if ([data isEqual:@"play"])
			[recordingPlayer play];
		else if ([data isEqual:@"start"])
			[recordingPlayer setCurrentTime:[[query objectForKey:@"time"] intValue]];
	} else if ([scheme isEqual:@"tel"]) {
		[SIPUser call:[data phoneFormatWithAreaCode:[SIPUser areaCode]]];
	} else if ([scheme isEqual:@"file"]) {
		return YES;
	} else {
		[[UIApplication sharedApplication] openURL:url];
	}
	return NO;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if (currentRecording!=-1) {
		if (recordingPlayer!=nil) {
			[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setDurration(%d)", (int)[recordingPlayer duration]]];
			[recordingView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setCurrent(%d)", (int)[recordingPlayer currentTime]]];
			[recordingView stringByEvaluatingJavaScriptFromString:@"setPlayerPlaying()"];
			[recordingPlayer play];
			recordingUpdater = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecording) userInfo:nil repeats:YES] retain];
		}
	}
}

- (IBAction)showRecordings:(id)sender {
	[[SIPUser accountController] setItems:[[SIPUser accountController] accountItems] animated:YES];
	
	[recordingPlayer release];
	recordingPlayer = nil;
	[recordingUpdater invalidate];
	[recordingUpdater release];
	recordingUpdater = nil;
	
	CGRect outViewFrame = [recordingView frame];
	CGRect inViewFrame = [recordingsTable frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = -inViewFrame.size.width;
	[recordingsTable setFrame:inViewFrame];
	[[SIPUser tabView] addSubview:recordingsTable];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showRecordingsAnimationDidStop:finished:context:)];
	[recordingsTable setFrame:outViewFrame];
	outViewFrame.origin.x = +outViewFrame.size.width;
	[recordingView setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)showRecordingsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[recordingView removeFromSuperview];
	currentRecording = -1;
}
@end