//
//  MGMInboxPlayWindow.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/4/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose
//  with or without fee is hereby granted, provided that the above copyright notice
//  and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT,
//  OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
//  DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
//  ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

#import "MGMInboxPlayWindow.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <QTKit/QTKit.h>

@implementation MGMInboxPlayWindow
- (id)initWithNibNamed:(NSString *)theNib data:(NSDictionary *)theData instance:(MGMInstance *)theInstance {
	if ((self = [super initWithContentRect:NSMakeRect(34, 34, 0, 0) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES])) {
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
				MGMURLBasicHandler *handler = [MGMURLBasicHandler handlerWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:MGMIVoiceMailDownloadURL, [[theData objectForKey:MGMIID] addPercentEscapes]]]] delegate:self];
				[connectionManager addHandler:handler];
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
	[connectionManager release];
	[super dealloc];
}

- (void)handler:(MGMURLBasicHandler *)theHandler didFailWithError:(NSError *)theError {
	NSLog(@"Starting Audio Error: %@", theError);
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Error loading audio"];
	[alert setInformativeText:[theError localizedDescription]];
	[alert runModal];
}
- (void)handlerDidFinish:(MGMURLBasicHandler *)theHandler {
	QTDataReference *audioReference = [QTDataReference dataReferenceWithReferenceToData:[theHandler data] name:@"voicemail.mp3" MIMEType:nil];
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
	[connectionManager cancelAll];
	[audioPlayer setMovie:nil];
	[self setContentView:nil];
	[view release];
	[self close];
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}
@end