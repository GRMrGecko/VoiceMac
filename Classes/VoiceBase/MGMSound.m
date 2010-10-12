//
//  MGMSound.m
//  VoiceBase
//
//  Created by Mr. Gecko on 9/23/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSound.h"

@implementation MGMSound
- (id)init {
	if (self = [super init]) {
		loops = NO;
	}
	return self;
}
- (id)initWithContentsOfFile:(NSString *)theFile {
	return [self initWithContentsOfURL:[NSURL fileURLWithPath:theFile]];
}
- (id)initWithContentsOfURL:(NSURL *)theURL {
	if (self = [self init]) {
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
	if (self = [self init]) {
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
	if (sound!=nil) {
		[sound stop];
		[sound release];
	}
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
	[sound performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];
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