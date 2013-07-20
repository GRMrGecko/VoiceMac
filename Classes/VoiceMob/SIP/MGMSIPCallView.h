//
//  MGMSIPCallView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/9/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import <UIKit/UIKit.h>

@class MGMSIPCall, MGMSIPAccount, MGMSIPUser, MGMURLConnectionManager, MGMSound, MGMMiddleView;

@interface MGMSIPCallView : NSObject {
	MGMSIPCall *call;
	MGMSIPAccount *account;
	MGMSIPUser *SIPUser;
	MGMURLConnectionManager *connectionManager;
	
	IBOutlet UIView *backgroundView;
	IBOutlet UIImageView *iImageView;
	
	IBOutlet UIView *incomingView;
	IBOutlet UILabel *iPhoneField;
	IBOutlet UILabel *iNameField;
	NSString *fullName;
	NSString *phoneNumber;
	
	MGMSound *ringtone;
	
	NSDate *startTime;
	NSTimer *durationUpdater;
	
	BOOL answered;
	
	IBOutlet UIView *callView;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *phoneField;
	IBOutlet UILabel *nameField;
	IBOutlet UILabel *durationField;
	IBOutlet UILabel *statusField;
	IBOutlet MGMMiddleView *optionsView;
	IBOutlet MGMMiddleView *keypadView;
	IBOutlet UISlider *volumeSlider;
	IBOutlet UISlider *micVolumeSlider;
	IBOutlet UIButton *sound1Button;
	IBOutlet UIButton *sound2Button;
	IBOutlet UIButton *sound3Button;
	IBOutlet UIButton *sound4Button;
	IBOutlet UIButton *sound5Button;
	IBOutlet UIButton *holdButton;
}
+ (id)viewWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser;
- (id)initWithCall:(MGMSIPCall *)theCall SIPUser:(MGMSIPUser *)theSIPUser;

- (MGMSIPUser *)SIPUser;
- (MGMSIPCall *)call;
- (BOOL)didAnswer;

- (UIView *)view;

- (void)startDurationTimer;

- (void)fillCallView;

- (IBAction)answer:(id)sender;
- (IBAction)ignore:(id)sender;

- (IBAction)sound:(id)sender;

- (IBAction)volume:(id)sender;
- (IBAction)micVolume:(id)sender;

- (IBAction)hold:(id)sender;
- (IBAction)hangUp:(id)sender;
@end
#endif