//
//  MGMSound.m
//  VoiceBase
//
//  Created by Mr. Gecko on 9/23/10.
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

#import "MGMSound.h"

@implementation MGMSound
- (id)init {
	if ((self = [super init])) {
		loops = NO;
	}
	return self;
}
- (id)initWithContentsOfFile:(NSString *)theFile {
	return [self initWithContentsOfURL:[NSURL fileURLWithPath:theFile]];
}
- (id)initWithContentsOfURL:(NSURL *)theURL {
	if ((self = [self init])) {
#if TARGET_OS_IPHONE
		sound = [[AVAudioPlayer alloc] initWithContentsOfURL:theURL error:nil];
#else
		sound = [[NSSound alloc] initWithContentsOfURL:theURL byReference:YES];
#endif
		[sound setDelegate:self];
	}
	return self;
}
- (id)initWithData:(NSData *)theData {
	if ((self = [self init])) {
#if TARGET_OS_IPHONE
		sound = [[AVAudioPlayer alloc] initWithData:theData error:nil];
#else
		sound = [[NSSound alloc] initWithData:theData];
#endif
		[sound setDelegate:self];
	}
	return self;
}
- (void)dealloc {
	[sound setDelegate:nil];
	[sound stop];
	[sound release];
	[super dealloc];
}

- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}
- (id<MGMSoundDelegate>)delegate {
	return delegate;
}

#if TARGET_OS_IPHONE
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (loops) {
		[sound stop];
		[sound play];
	} else {
		if (delegate!=nil && [delegate respondsToSelector:@selector(soundDidFinishPlaying:)]) [delegate soundDidFinishPlaying:self];
	}
}
#else
- (void)sound:(NSSound *)theSound didFinishPlaying:(BOOL)finishedPlaying {
	if (finishedPlaying) {
		if (loops) {
			[sound stop];
			[sound play];
		} else {
			if (delegate!=nil && [delegate respondsToSelector:@selector(soundDidFinishPlaying:)]) [delegate soundDidFinishPlaying:self];
		}
	}
}
#endif

- (void)setLoops:(BOOL)shouldLoop {
	loops = shouldLoop;
}
- (BOOL)loops {
	return loops;
}

- (void)play {
	[sound performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:YES];
}
- (void)pause {
	[sound pause];
}
- (void)stop {
	[sound stop];
}
- (BOOL)isPlaying {
	return [sound isPlaying];
}
@end