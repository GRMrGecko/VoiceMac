//
//  MGMVoicePad.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMVoiceUser, MGMNumberView;

@interface MGMVoicePad : NSObject <UIActionSheetDelegate> {
	MGMVoiceUser *voiceUser;
	
	IBOutlet UIView *view;
	
	NSString *info;
	NSString *credit;
	NSString *numberString;
	IBOutlet MGMNumberView *numberView;
	IBOutlet MGMNumberView *number1View;
	IBOutlet MGMNumberView *number2View;
	IBOutlet MGMNumberView *number3View;
	IBOutlet MGMNumberView *number4View;
	IBOutlet MGMNumberView *number5View;
	IBOutlet MGMNumberView *number6View;
	IBOutlet MGMNumberView *number7View;
	IBOutlet MGMNumberView *number8View;
	IBOutlet MGMNumberView *number9View;
	IBOutlet MGMNumberView *numberStarView;
	IBOutlet MGMNumberView *number0View;
	IBOutlet MGMNumberView *numberPondView;
	IBOutlet MGMNumberView *numberSMSView;
	IBOutlet MGMNumberView *numberCallView;
	IBOutlet MGMNumberView *numberDeleteView;
	
	IBOutlet UIView *phonesView;
	IBOutlet UIPickerView *phonesPicker;
}
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (MGMVoiceUser *)voiceUser;

- (UIView *)view;
- (void)releaseView;

- (void)updateInfo;
- (void)setCredit:(NSString *)theCredit;

- (IBAction)numberDecide:(id)sender;

- (IBAction)closePhones:(id)sender;

- (IBAction)dial:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)call:(id)sender;
- (IBAction)sms:(id)sender;
@end