//
//  MGMSIPPad.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import <UIKit/UIKit.h>

@class MGMSIPUser, MGMNumberView;

@interface MGMSIPPad : NSObject <UIActionSheetDelegate, UITextFieldDelegate> {
	MGMSIPUser *SIPUser;
	
	IBOutlet UIView *view;
	
	UITextField *keyboard;
	BOOL keyboardInput;
	IBOutlet UIButton *closeKeyboardButon;
	
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
	IBOutlet MGMNumberView *numberKeyboardView;
	IBOutlet MGMNumberView *numberCallView;
	IBOutlet MGMNumberView *numberDeleteView;
}
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser;
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser;

- (MGMSIPUser *)SIPUser;

- (UIView *)view;
- (void)releaseView;

- (IBAction)numberDecide:(id)sender;
- (IBAction)dial:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)call:(id)sender;
- (IBAction)showKeyboard:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
@end
#endif