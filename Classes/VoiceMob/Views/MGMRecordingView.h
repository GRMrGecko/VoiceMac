//
//  MGMRecordingView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/14/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface MGMRecordingView : UITableViewCell {
	UILabel *nameField;
	UILabel *dateField;
	
	NSDictionary *recording;
}
- (void)setRecording:(NSDictionary *)theRecording;
@end