//
//  MGMSMSTextView.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class WebView, MGMSplitView;

@protocol MGMSMSTextViewProtocol <NSObject>
- (WebView *)SMSView;
- (MGMSplitView *)SMSSplitView;
- (IBAction)sendMessage:(id)sender;
@end


@interface MGMSMSTextView : NSTextView {
	IBOutlet id<MGMSMSTextViewProtocol> messageView;
	IBOutlet NSTextField *count;
}
- (void)count;
@end