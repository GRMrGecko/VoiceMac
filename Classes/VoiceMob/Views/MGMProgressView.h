//
//  MGMProgressView.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface MGMProgressView : UIView {
	UIActivityIndicatorView *progress;
	UILabel *pleaseWaitField;
	UILabel *progressField;
}
- (void)startProgess;
- (void)stopProgess;
- (void)setProgressTitle:(NSString *)theTitle;
@end