//
//  MGMInboxPlayWindow.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/4/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMInboxPlayWindow.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <QTKit/QTKit.h>

@implementation MGMInboxPlayWindow
- (id)initWithNibNamed:(NSString *)theNib data:(NSDictionary *)theData instance:(MGMInstance *)theInstance {
	if (self = [super initWithContentRect:NSMakeRect(34, 34, 0, 0) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES]) {
		if (![NSBundle loadNibNamed:theNib owner:self]) {
			NSLog(@"Unable to load nib for the Play Window");
			[self release];
			self = nil;
		} else {
			instance = theInstance;
			if (transcriptionField!=nil) {
				[transcriptionField setStringValue:[theData objectForKey:MGMIText]];
				NSSize transcriptionSize = [transcriptionField frame].size;
				NSRect viewRect = [view frame];
				float widthDiff = viewRect.size.width-transcriptionSize.width;
				float heightDiff = viewRect.size.height-transcriptionSize.height;
				NSAttributedString *string = [transcriptionField attributedStringValue];
				float width = [string widthForHeight:transcriptionSize.height];
				if (transcriptionSize.width<width) {
					if (width>455)
						transcriptionSize.width = 455;
					else
						transcriptionSize.width = width;
				}
				transcriptionSize.height = [string heightForWidth:transcriptionSize.width];
				viewRect.size.width = transcriptionSize.width + widthDiff;
				viewRect.size.height = transcriptionSize.height + heightDiff;
				[view setFrame:viewRect];
			}
			if (audioPlayer!=nil) {
				connectionManager = [[MGMURLConnectionManager managerWithCookieStorage:[instance cookieStorage]] retain];
				[connectionManager connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:MGMIVoiceMailDownloadURL, [[theData objectForKey:MGMIID] addPercentEscapes]]]] delegate:self];
			}
			forceDisplay = NO;
			[self setLevel:NSStatusWindowLevel];
			[self setBackgroundColor:[NSColor clearColor]];
			[self setOpaque:NO];
			[self setHasShadow:YES];
			[self setAlphaValue:1.0];
			[self setMovableByWindowBackground:NO];
			[self setContentSize:[view frame].size];
			[self setContentView:view];
			[self setBackgroundColor:[self whiteBackground]];
			[self setReleasedWhenClosed:YES];
			[self setDelegate:self];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self];
		}
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (connectionManager!=nil)
		[connectionManager release];
	[super dealloc];
}

- (void)request:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSLog(@"Starting Audio Error: %@", theError);
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert setMessageText:@"Error loading audio"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert runModal];
}
- (void)requestDidFinish:(NSDictionary *)theInfo {
	QTDataReference *audioReference = [QTDataReference dataReferenceWithReferenceToData:[theInfo objectForKey:MGMConnectionData] name:@"voicemail.mp3" MIMEType:nil];
	QTMovie *theAudio = [QTMovie movieWithDataReference:audioReference error:NULL];
	[theAudio autoplay];
	[audioPlayer setMovie:theAudio];
	[audioPlayer setBackButtonVisible:NO];
	[audioPlayer setVolumeButtonVisible:NO];
	[audioPlayer setStepButtonsVisible:NO];
}

- (void)windowDidResize:(NSNotification *)aNotification {
	[self setBackgroundColor:[self whiteBackground]];
	if (forceDisplay)
		[self display];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag {
	forceDisplay = YES;
	[super setFrame:frameRect display:displayFlag animate:animationFlag];
	forceDisplay = NO;
}

- (NSColor *)whiteBackground {
	float alpha = 0.9;
	NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
	[bg lockFocus];
	
	float radius = 6.0;
	float stroke = 3.0;
	NSRect bgRect = NSMakeRect(stroke/2, stroke/2, [bg size].width-stroke, [bg size].height-stroke);
	NSBezierPath *bgPath = [NSBezierPath pathWithRect:bgRect radiusX:radius radiusY:radius];
	[bgPath setLineWidth:stroke];
	
	[[NSColor colorWithCalibratedWhite:1.0 alpha:alpha] set];
	[bgPath fill];
	[[NSColor colorWithCalibratedWhite:0.6 alpha:alpha] set];
	[bgPath stroke];
	
	[bg unlockFocus];
	
	return [NSColor colorWithPatternImage:[bg autorelease]];
}
- (void)windowDidResignKey:(NSNotification *)notification {
	if (connectionManager!=nil)
		[connectionManager cancelAll];
	if (audioPlayer!=nil)
		[audioPlayer setMovie:nil];
	[self setContentView:nil];
	[view release];
	[self close];
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}
@end