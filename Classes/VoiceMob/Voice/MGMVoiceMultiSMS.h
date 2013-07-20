//
//  MGMVoiceMultiSMS.h
//  VoiceMob
//
//  Created by James on 12/2/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>
#import "MGMContactsController.h"

@class MGMInstance, MGMController, MGMNumberView;

@interface MGMVoiceMultiSMS : MGMContactsController <UIActionSheetDelegate> {
	MGMInstance *instance;
	MGMController *controller;
	
	IBOutlet UIView *view;
	IBOutlet UIBarButtonItem *sendButton;
	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UITextView *SMSTextView;
	IBOutlet UILabel *SMSTextCountField;
	
	NSArray *groups;
	IBOutlet UIButton *groupButton;
	IBOutlet UIView *groupView;
	IBOutlet UIPickerView *groupPicker;
	
	NSMutableArray *additional;
	IBOutlet UIButton *additionalButton;
	IBOutlet UIView *additionalView;
	int currentTab;
	IBOutlet UIView *tabView;
	IBOutlet UITabBar *tabBar;
	
	IBOutlet UIView *keypadView;
	IBOutlet UIView *contactsView;
	IBOutlet UITableView *selectedView;
	
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
	IBOutlet MGMNumberView *numberRemoveView;
	IBOutlet MGMNumberView *numberAddView;
	IBOutlet MGMNumberView *numberDeleteView;
	
	IBOutlet UITableView *numbersTable;
}
- (id)initWithInstance:(MGMInstance *)theInstance controller:(MGMController *)theController;

- (MGMInstance *)instance;
- (MGMController *)controller;
- (UIView *)view;

- (IBAction)chooseGroup:(id)sender;
- (IBAction)closeGroups:(id)sender;

- (IBAction)chooseAdditional:(id)sender;

- (IBAction)numberDecide:(id)sender;
- (IBAction)dial:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)closeAdditional:(id)sender;

- (IBAction)close:(id)sender;
- (IBAction)send:(id)sender;
@end

@interface MGMMultiSMSTextView : UITextView {
	
}

@end