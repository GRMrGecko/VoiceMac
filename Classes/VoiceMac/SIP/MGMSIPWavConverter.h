//
//  MGMSIPWavConverter.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/15/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class QTMovie;

@interface MGMSIPWavConverter : NSObject {
	NSString *fileConverting;
	NSString *soundName;
	QTMovie *movie;
	NSThread *backgroundThread;
	BOOL cancel;
}
- (id)initWithSoundName:(NSString *)theSoundname fileConverting:(NSString *)theFile;
@end