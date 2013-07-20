//
//  MGMSIPPad.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import "MGMSIPPad.h"
#import "MGMSIPUser.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMNumberView.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMSIPPad
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser {
	return [[[self alloc] initWithSIPUser:theSIPUser] autorelease];
}
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser {
	if ((self = [super init])) {
		SIPUser = theSIPUser;
		keyboardInput = NO;
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[numberString release];
	[super dealloc];
}

- (MGMSIPUser *)SIPUser {
	return SIPUser;
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"SIPPad"] owner:self options:nil]) {
			NSLog(@"Unable to load SIP Pad");
		} else {
			keyboard = [[UITextField alloc] initWithFrame:CGRectMake(-22, -22, 22, 22)];
			[keyboard setDelegate:self];
			[keyboard setReturnKeyType:UIReturnKeyDone];
			[keyboard setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[keyboard setText:@" "];
			[view addSubview:keyboard];
			[closeKeyboardButon setHidden:YES];
			
			if (numberString!=nil)
				[numberView setNumber:numberString];
			else
				[numberView setNumber:@""];
			[numberView setStartColor:[UIColor colorWithRed:0.19 green:0.22 blue:0.37 alpha:1.0]];
			[numberView setEndColor:[UIColor colorWithRed:0.04 green:0.16 blue:0.33 alpha:1.0]];
			[numberView setGlass:YES];
			[number1View setNumber:@"1"];
			[number1View setAlphabet:@""];
			[number2View setNumber:@"2"];
			[number2View setAlphabet:@"ABC"];
			[number3View setNumber:@"3"];
			[number3View setAlphabet:@"DEF"];
			[number4View setNumber:@"4"];
			[number4View setAlphabet:@"GHI"];
			[number5View setNumber:@"5"];
			[number5View setAlphabet:@"JKL"];
			[number6View setNumber:@"6"];
			[number6View setAlphabet:@"MNO"];
			[number7View setNumber:@"7"];
			[number7View setAlphabet:@"PQRS"];
			[number8View setNumber:@"8"];
			[number8View setAlphabet:@"TUV"];
			[number9View setNumber:@"9"];
			[number9View setAlphabet:@"WXYZ"];
			[numberStarView setNumber:@"✱"];
			[numberStarView setAlphabet:@""];
			[number0View setNumber:@"0"];
			[number0View setAlphabet:@"+"];
			[numberPondView setNumber:@"#"];
			[numberPondView setAlphabet:@""];
			[numberKeyboardView setNumber:@"ABC"];
			UIColor *darkColor = [UIColor colorWithRed:0.02 green:0.09 blue:0.19 alpha:1.0];
			[numberKeyboardView setStartColor:darkColor];
			[numberKeyboardView setEndColor:darkColor];
			[numberKeyboardView setGlass:YES];
			[numberCallView setNumber:@"Call"];
			[numberCallView setStartColor:[UIColor colorWithRed:0.13 green:0.81 blue:0.1 alpha:1.0]];
			[numberCallView setEndColor:[UIColor colorWithRed:0.11 green:0.69 blue:0.09 alpha:1.0]];
			[numberCallView setGlass:YES];
			[numberDeleteView setImage:[[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeleteKey" ofType:@"png"]] autorelease]];
			[numberDeleteView setStartColor:darkColor];
			[numberDeleteView setEndColor:darkColor];
			[numberDeleteView setGlass:YES];
		}
	}
	return view;
}
- (void)releaseView {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[view release];
	view = nil;
	[keyboard release];
	keyboard = nil;
	[closeKeyboardButon release];
	closeKeyboardButon = nil;
	[numberView release];
	numberView = nil;
	[number1View release];
	number1View = nil;
	[number2View release];
	number2View = nil;
	[number3View release];
	number3View = nil;
	[number4View release];
	number4View = nil;
	[number5View release];
	number5View = nil;
	[number6View release];
	number6View = nil;
	[number7View release];
	number7View = nil;
	[number8View release];
	number8View = nil;
	[number9View release];
	number9View = nil;
	[numberStarView release];
	numberStarView = nil;
	[number0View release];
	number0View = nil;
	[numberPondView release];
	numberPondView = nil;
	[numberKeyboardView release];
	numberKeyboardView = nil;
	[numberCallView release];
	numberCallView = nil;
	[numberDeleteView release];
	numberDeleteView = nil;
}

- (IBAction)numberDecide:(id)sender {
	UIActionSheet *theAction = [[UIActionSheet new] autorelease];
	[theAction addButtonWithTitle:@"Copy"];
	BOOL pasteEnabled = ([[UIPasteboard generalPasteboard] string]!=nil);
	if (pasteEnabled)
		[theAction addButtonWithTitle:@"Paste"];
	[theAction addButtonWithTitle:@"Reverse Lookup"];
	[theAction addButtonWithTitle:@"Cancel"];
	[theAction setCancelButtonIndex:(pasteEnabled ? 3 : 2)];
	[theAction setDelegate:self];
	[theAction showInView:[SIPUser view]];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	BOOL pasteEnabled = ([[UIPasteboard generalPasteboard] string]!=nil);
	if (buttonIndex==0) {
		[[UIPasteboard generalPasteboard] setString:numberString];
	} else if (pasteEnabled && buttonIndex==1) {
		[numberString release];
		keyboardInput = ![[[UIPasteboard generalPasteboard] string] isPhoneComplete];
		numberString = [(keyboardInput ? [[UIPasteboard generalPasteboard] string] : [[[UIPasteboard generalPasteboard] string] readableNumber]) copy];
		[numberView setNumber:numberString];
	} else if ((pasteEnabled && buttonIndex==2) || (!pasteEnabled && buttonIndex==1)) {
		[[[SIPUser accountController] controller] showReverseLookupWithNumber:[numberString phoneFormatWithAreaCode:[SIPUser areaCode]]];
	}
}
- (IBAction)dial:(id)sender {
	NSString *number = [numberView number];
	if ([number length]==0 && [sender tag]==0) {
		[numberView setNumber:@"+"];
	} else {
		NSString *numberAdd = nil;
		switch ([sender tag]) {
			case 10:
			case 11:
				break;
			default:
				numberAdd = [[NSNumber numberWithInt:[sender tag]] stringValue];
				break;
		}
		if (numberAdd!=nil)
			number = [number stringByAppendingString:numberAdd];
		[numberString release];
		numberString = [(keyboardInput ? number : [number readableNumber]) copy];
		[numberView setNumber:numberString];
	}
}
- (IBAction)delete:(id)sender {
	if ([numberString isEqual:@""])
		keyboardInput = NO;
	NSString *number = [numberView number];
	if ([number length]!=0) {
		number = [number substringToIndex:[number length]-1];
		[numberString release];
		numberString = [(keyboardInput ? number : [number readableNumber]) copy];
		[numberView setNumber:numberString];
		if ([numberString isEqual:@""])
			keyboardInput = NO;
	}
}
- (IBAction)call:(id)sender {
	if ([numberString isPhoneComplete]) {
		[SIPUser call:[numberString phoneFormatWithAreaCode:[SIPUser areaCode]]];
	} else if (keyboardInput) {
		[SIPUser call:numberString];
	} else {
		UIAlertView *alert = [[UIAlertView new] autorelease];
		[alert setTitle:@"Incorrect Number"];
		[alert setMessage:@"The phone number you have entered is incorrect."];
		[alert addButtonWithTitle:MGMOkButtonTitle];
		[alert show];
	}
}
- (IBAction)showKeyboard:(id)sender {
	[closeKeyboardButon setHidden:NO];
	[keyboard becomeFirstResponder];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqual:@""])
		[self delete:keyboard];
	keyboardInput = YES;
	NSString *number = [numberView number];
	number = [number stringByAppendingString:string];
	[numberString release];
	numberString = [(keyboardInput ? number : [number readableNumber]) copy];
	[numberView setNumber:numberString];
	[keyboard setText:@" "];
	return NO;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[closeKeyboardButon setHidden:YES];
	return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[keyboard resignFirstResponder];
	return NO;
}
- (IBAction)hideKeyboard:(id)sender {
	[keyboard resignFirstResponder];
}
@end
#endif