//
//  MGMConverter.m
//  VoiceBase
//
//  Created by Mr. Gecko on 3/1/11.
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

#if MGMSIPENABLED
#import "MGMConverter.h"
#import "MGMFFmpeg.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

@implementation MGMConverter
- (id)initWithSound:(NSString *)theSound file:(NSString *)theFile {
	if ((self = [super init])) {
		sound = [theSound retain];
		file = [theFile retain];
		canceled = NO;
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(soundChanged:) name:MGMTSoundChangedNotification object:sound];
		
		NSString *finalPath = [[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMTCallSoundsFolder];
		NSFileManager *manager = [NSFileManager defaultManager];
		if (![manager fileExistsAtPath:finalPath])
			[manager createDirectoryAtPath:finalPath withAttributes:nil];
		finalPath = [finalPath stringByAppendingPathComponent:sound];
		tmpPath = [[[finalPath stringByAppendingPathExtension:@"tmp"] stringByAppendingPathExtension:MGMWavExt] retain];
		completePath = [[finalPath stringByAppendingPathExtension:MGMWavExt] retain];
		
		NSLog(@"File: %@\nTMP: %@\nComplete: %@", file, tmpPath, completePath);
		
		FFmpeg = [[MGMFFmpeg FFmpegWithDelegate:self] retain];
		[FFmpeg setInputFile:file];
		[FFmpeg setOptions:[NSArray arrayWithObjects:@"-ab", @"16000", @"-ac", @"1", nil]];
		[FFmpeg setOutputFile:tmpPath];
		[FFmpeg startConverting];
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[FFmpeg release];
	[sound release];
	[file release];
	[tmpPath release];
	[completePath release];
	[super dealloc];
}

- (void)soundChanged:(NSNotification *)theNotification {
	canceled = YES;
	[FFmpeg stopConverting];
}

- (void)conversionFinished {
	NSLog(@"Done");
	NSFileManager *manager = [NSFileManager defaultManager];
	if (!canceled) {
		[manager removeItemAtPath:completePath];
		[manager moveItemAtPath:tmpPath toPath:completePath];
	}
	[self release];
}
@end
#endif