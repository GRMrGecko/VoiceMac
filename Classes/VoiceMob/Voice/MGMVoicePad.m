//
//  MGMVoicePad.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMVoicePad.h"
#import "MGMVoiceUser.h"
#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMVoiceSMS.h"
#import "MGMNumberView.h"
#import "MGMVMAddons.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
 
@implementation MGMVoicePad
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	return [[[self alloc] initWithVoiceUser:theVoiceUser] autorelease];
}
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser {
	if ((self = [super init])) {
		voiceUser = theVoiceUser;
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[self releaseView];
	[info release];
	[credit release];
	[numberString release];
	[super dealloc];
}

- (MGMVoiceUser *)voiceUser {
	return voiceUser;
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoicePad"] owner:self options:nil]) {
			NSLog(@"Unable to load Voice Pad");
		} else {
			if (numberString!=nil)
				[numberView setNumber:numberString];
			else
				[numberView setNumber:@""];
			[numberView setInfo:info];
			[numberView setCredit:credit];
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
			[numberSMSView setNumber:@"SMS"];
			UIColor *darkColor = [UIColor colorWithRed:0.02 green:0.09 blue:0.19 alpha:1.0];
			[numberSMSView setStartColor:darkColor];
			[numberSMSView setEndColor:darkColor];
			[numberSMSView setGlass:YES];
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
	[numberSMSView release];
	numberSMSView = nil;
	[numberCallView release];
	numberCallView = nil;
	[numberDeleteView release];
	numberDeleteView = nil;
	[phonesView release];
	phonesView = nil;
	[phonesPicker release];
	phonesPicker = nil;
}

- (void)updateInfo {
	[info release];
	info = nil;
	if ([[[voiceUser instance] userPhoneNumbers] count]>=1) {
		if ([[[voiceUser instance] userPhoneNumbers] count]<([[[voiceUser user] settingForKey:MGMLastUserPhoneKey] intValue]+1))
			[[voiceUser user] setSetting:[NSNumber numberWithInt:0] forKey:MGMLastUserPhoneKey];
		
		NSDictionary *phone = [[[voiceUser instance] userPhoneNumbers] objectAtIndex:[[[voiceUser user] settingForKey:MGMLastUserPhoneKey] intValue]];
		info = [[NSString stringWithFormat:@"%@ [%@]", [[phone objectForKey:MGMPhoneNumber] readableNumber], [phone objectForKey:MGMName]] retain];
	}
	[numberView setInfo:info];
}
- (void)setCredit:(NSString *)theCredit {
	[credit release];
	credit = [theCredit retain];
	[numberView setCredit:credit];
}

- (IBAction)numberDecide:(id)sender {
	UIActionSheet *theAction = [[UIActionSheet new] autorelease];
	[theAction addButtonWithTitle:@"Copy"];
	BOOL pasteEnabled = ([[UIPasteboard generalPasteboard] string]!=nil);
	if (pasteEnabled)
		[theAction addButtonWithTitle:@"Paste"];
	[theAction addButtonWithTitle:@"Reverse Lookup"];
	[theAction addButtonWithTitle:@"Change Ring Phone"];
	[theAction addButtonWithTitle:@"Cancel"];
	[theAction setCancelButtonIndex:(pasteEnabled ? 4 : 3)];
	[theAction setDelegate:self];
	[theAction showInView:[voiceUser view]];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	BOOL pasteEnabled = ([[UIPasteboard generalPasteboard] string]!=nil);
	if (buttonIndex==0) {
		[[UIPasteboard generalPasteboard] setString:numberString];
	} else if (pasteEnabled && buttonIndex==1) {
		[numberString release];
		numberString = [[[[UIPasteboard generalPasteboard] string] readableNumber] copy];
		[numberView setNumber:numberString];
	} else if ((pasteEnabled && buttonIndex==2) || (!pasteEnabled && buttonIndex==1)) {
		[[[voiceUser accountController] controller] showReverseLookupWithNumber:[numberString phoneFormatWithAreaCode:[voiceUser areaCode]]];
	} else if ((pasteEnabled && buttonIndex==3) || (!pasteEnabled && buttonIndex==2)) {
		[phonesPicker reloadAllComponents];
		[phonesPicker selectRow:[[[voiceUser user] settingForKey:MGMLastUserPhoneKey] intValue] inComponent:0 animated:NO];
		
		CGRect inViewFrame = [phonesView frame];
		inViewFrame.origin.y = +([[self view] frame].size.height+[[voiceUser tabBar] frame].size.height);
		[phonesView setFrame:inViewFrame];
		[[self view] addSubview:phonesView];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		CGRect outViewFrame = [phonesView frame];
		outViewFrame.origin.y -= outViewFrame.size.height+[[voiceUser tabBar] frame].size.height;
		[phonesView setFrame:outViewFrame];
		[UIView commitAnimations];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)theComponent {
	return [[[voiceUser instance] userPhoneNumbers] count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)theRow forComponent:(NSInteger)theComponent {
	NSDictionary *phone = [[[voiceUser instance] userPhoneNumbers] objectAtIndex:theRow];
	return [NSString stringWithFormat:@"%@ [%@]", [[phone objectForKey:MGMPhoneNumber] readableNumber], [phone objectForKey:MGMName]];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)theRow inComponent:(NSInteger)theComponent {
	[[voiceUser user] setSetting:[NSNumber numberWithInt:theRow] forKey:MGMLastUserPhoneKey];
	[self updateInfo];
}
- (IBAction)closePhones:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:groups:)];
	CGRect outViewFrame = [phonesView frame];
	outViewFrame.origin.y = +([[self view] frame].size.height+[[voiceUser tabBar] frame].size.height);
	[phonesView setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished groups:(id)context {
	[phonesView removeFromSuperview];
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
		numberString = [[number readableNumber] copy];
		[numberView setNumber:numberString];
	}
}
- (IBAction)delete:(id)sender {
	NSString *number = [numberView number];
	if ([number length]!=0) {
		number = [number substringToIndex:[number length]-1];
		[numberString release];
		numberString = [[number readableNumber] copy];
		[numberView setNumber:numberString];
	}
}
- (IBAction)call:(id)sender {
	if ([numberString isPhoneComplete]) {
		[voiceUser call:[numberString phoneFormatWithAreaCode:[voiceUser areaCode]]];
	} else {
		UIAlertView *alert = [[UIAlertView new] autorelease];
		[alert setTitle:@"Incorrect Number"];
		[alert setMessage:@"The phone number you have entered is incorrect."];
		[alert addButtonWithTitle:MGMOkButtonTitle];
		[alert show];
	}
}
- (IBAction)sms:(id)sender {
	if ([numberString isPhoneComplete]) {
		[[[voiceUser tabObjects] objectAtIndex:MGMVUSMSTabIndex] messageWithNumber:[numberString phoneFormatWithAreaCode:[voiceUser areaCode]] instance:[voiceUser instance]];
	} else {
		UIAlertView *alert = [[UIAlertView new] autorelease];
		[alert setTitle:@"Incorrect Number"];
		[alert setMessage:@"The phone number you have entered is incorrect."];
		[alert addButtonWithTitle:MGMOkButtonTitle];
		[alert show];
	}
}
@end