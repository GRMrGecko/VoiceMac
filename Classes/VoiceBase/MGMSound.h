//
//  MGMSound.h
//  VoiceBase
//
//  Created by Mr. Gecko on 9/23/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@class MGMSound;

@protocol MGMSoundDelegate <NSObject>
- (void)soundDidFinishPlaying:(MGMSound *)theSound;
@end

@interface MGMSound : NSObject
#if TARGET_OS_IPHONE
<AVAudioPlayerDelegate>
#else
<NSSoundDelegate>
#endif
{
#if TARGET_OS_IPHONE
	AVAudioPlayer *sound;
#else
	NSSound *sound;
#endif
	id<MGMSoundDelegate> delegate;
	
	BOOL loops;
}
- (id)initWithContentsOfFile:(NSString *)theFile;
- (id)initWithContentsOfURL:(NSURL *)theURL;
- (id)initWithData:(NSData *)theData;

- (void)setDelegate:(id)theDelegate;
- (id<MGMSoundDelegate>)delegate;

- (void)setLoops:(BOOL)shouldLoop;
- (BOOL)loops;

- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
@end