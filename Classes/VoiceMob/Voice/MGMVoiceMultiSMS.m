//
//  MGMVoiceMultiSMS.m
//  VoiceMob
//
//  Created by James on 12/2/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMVoiceMultiSMS.h"
#import "MGMController.h"
#import "MGMNumberView.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

NSString * const MGMAdditionalCellIdentifier = @"MGMAdditionalCellIdentifier";
NSString * const MGMKeyboardBoundsM = @"UIKeyboardBoundsUserInfoKey";

@implementation MGMVoiceMultiSMS
- (id)initWithInstance:(MGMInstance *)theInstance controller:(MGMController *)theController {
	if ((self = [super init])) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"VoiceMultiSMS"] owner:self options:nil]) {
			NSLog(@"Unable to load Multi SMS");
			[self release];
			self = nil;
		} else {
			instance = theInstance;
			controller = theController;
			accountController = [controller accountController];
			
			groups = [[[instance contacts] groups] retain];
			
			additional = [NSMutableArray new];
			
			[tabView addSubview:keypadView];
			[tabBar setSelectedItem:[[tabBar items] objectAtIndex:0]];
			
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
			[numberRemoveView setNumber:@"−"];
			[numberRemoveView setStartColor:[UIColor colorWithRed:0.79 green:0.18 blue:0.07 alpha:1.0]];
			[numberRemoveView setEndColor:[UIColor colorWithRed:0.76 green:0.19 blue:0.13 alpha:1.0]];
			[numberRemoveView setGlass:YES];
			[numberAddView setNumber:@"+"];
			[numberAddView setStartColor:[UIColor colorWithRed:0.13 green:0.81 blue:0.1 alpha:1.0]];
			[numberAddView setEndColor:[UIColor colorWithRed:0.11 green:0.69 blue:0.09 alpha:1.0]];
			[numberAddView setGlass:YES];
			[numberDeleteView setImage:[[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeleteKey" ofType:@"png"]] autorelease]];
			UIColor *darkColor = [UIColor colorWithRed:0.02 green:0.09 blue:0.19 alpha:1.0];
			[numberDeleteView setStartColor:darkColor];
			[numberDeleteView setEndColor:darkColor];
			[numberDeleteView setGlass:YES];
			
			
			NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
			[notifications addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
			[notifications addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		}
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[groups release];
	[view release];
	[sendButton release];
	[cancelButton release];
	[SMSTextView release];
	[SMSTextCountField release];
	[groupButton release];
	[groupView release];
	[groupPicker release];
	[tabView release];
	[tabBar release];
	[keypadView release];
	[contactsView release];
	[selectedView release];
	[additional release];
	[additionalButton release];
	[additionalView release];
	[numberView release];
	[number1View release];
	[number2View release];
	[number3View release];
	[number4View release];
	[number5View release];
	[number6View release];
	[number7View release];
	[number8View release];
	[number9View release];
	[numberStarView release];
	[number0View release];
	[numberPondView release];
	[numberRemoveView release];
	[numberAddView release];
	[numberDeleteView release];
	[numbersTable release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (MGMInstance *)instance {
	return instance;
}
- (MGMController *)controller {
	return controller;
}
- (UIView *)view {
	return view;
}

- (IBAction)chooseGroup:(id)sender {
	[SMSTextView resignFirstResponder];
	CGRect inViewFrame = [groupView frame];
	inViewFrame.origin.y = +[[self view] frame].size.height;
	[groupView setFrame:inViewFrame];
	[[self view] addSubview:groupView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [groupView frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[groupView setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)theComponent {
	return [groups count]+1;
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)theRow forComponent:(NSInteger)theComponent {
	if (theRow!=0) {
		NSDictionary *group = [groups objectAtIndex:theRow-1];
		return [NSString stringWithFormat:@"%@ (%@)", [group objectForKey:MGMCName], [[instance contacts] membersCountOfGroup:group]];
	}
	return @"None";
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)theRow inComponent:(NSInteger)theComponent {
	NSString *title = [self pickerView:thePickerView titleForRow:theRow forComponent:theComponent];
	[groupButton setTitle:title forState:UIControlStateNormal];
}
- (IBAction)closeGroups:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:groups:)];
	CGRect outViewFrame = [groupView frame];
	outViewFrame.origin.y = +[[self view] frame].size.height;
	[groupView setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished groups:(id)context {
	[groupView removeFromSuperview];
}

- (IBAction)chooseAdditional:(id)sender {
	[SMSTextView resignFirstResponder];
	CGRect inViewFrame = [additionalView frame];
	inViewFrame.origin.y = +[[self view] frame].size.height;
	[additionalView setFrame:inViewFrame];
	[[self view] addSubview:additionalView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [additionalView frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[additionalView setFrame:outViewFrame];
	[UIView commitAnimations];
}

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)theItem {
	int tabIndex = [[tabBar items] indexOfObject:theItem];
	if (tabIndex==currentTab)
		return;
	
	UIView *newTabView = nil;
	if (tabIndex==0)
		newTabView = keypadView;
	else if (tabIndex==1) {
		[super awakeFromNib];
		newTabView = contactsView;
	} else if (tabIndex==2) {
		[selectedView reloadData];
		newTabView = selectedView;
	}
	CGRect tabFrame = [newTabView frame];
	tabFrame.size = [tabView frame].size;
	[newTabView setFrame:tabFrame];
	[tabView addSubview:newTabView];
	if (currentTab==0)
		[keypadView removeFromSuperview];
	else if (currentTab==1) {
		[super cleanup];
		[contactsView removeFromSuperview];
	} else if (currentTab==2)
		[selectedView removeFromSuperview];
	currentTab = tabIndex;
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
	[theAction showInView:additionalView];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	BOOL pasteEnabled = ([[UIPasteboard generalPasteboard] string]!=nil);
	if (buttonIndex==0) {
		[[UIPasteboard generalPasteboard] setString:[numberView number]];
	} else if (pasteEnabled && buttonIndex==1) {
		[numberView setNumber:[[[UIPasteboard generalPasteboard] string] readableNumber]];
	} else if ((pasteEnabled && buttonIndex==2) || (!pasteEnabled && buttonIndex==1)) {
		[controller showReverseLookupWithNumber:[[numberView number] phoneFormatWithAreaCode:[instance userAreaCode]]];
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
		[numberView setNumber:[number readableNumber]];
	}
}
- (IBAction)delete:(id)sender {
	NSString *number = [numberView number];
	if ([number length]!=0) {
		number = [number substringToIndex:[number length]-1];
		[numberView setNumber:[number readableNumber]];
	}
}
- (IBAction)add:(id)sender {
	NSString *number = [[numberView number] phoneFormatWithAreaCode:[instance userAreaCode]];
	if (![additional containsObject:number])
		[additional addObject:number];
	[numberView setNumber:@""];
}
- (IBAction)remove:(id)sender {
	NSString *number = [[numberView number] phoneFormatWithAreaCode:[instance userAreaCode]];
	[additional removeObject:number];
}


- (MGMContacts *)contacts {
	return [instance contacts];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)theSection {
	if (theTableView!=numbersTable)
		return [super tableView:theTableView numberOfRowsInSection:theSection];
	return [additional count];
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath {
	if (theTableView!=numbersTable)
		return [super tableView:theTableView cellForRowAtIndexPath:theIndexPath];
	
	UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:MGMAdditionalCellIdentifier];
	if (cell==nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MGMAdditionalCellIdentifier] autorelease];
	}
	NSString *number = [[additional objectAtIndex:[theIndexPath indexAtPosition:1]] readableNumber];
	NSString *name = [[instance contacts] nameForNumber:[additional objectAtIndex:[theIndexPath indexAtPosition:1]]];
	if (name!=nil && ![name isEqual:number])
		number = [NSString stringWithFormat:@"%@ (%@)", number, name];
	if ([cell respondsToSelector:@selector(textLabel)])
		[[cell textLabel] setText:number];
	else
		[cell setText:number];
	return cell;
}
- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (theTableView==selectedView)
		return YES;
	return NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)theTableView editingStyleForRowAtIndexPath:(NSIndexPath *)theIndexPath {
	return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)theTableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)theIndexPath {
	return @"Remove";
}
- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)theIndexPath {
	[additional removeObjectAtIndex:[theIndexPath indexAtPosition:1]];
	[selectedView reloadData];
}
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)theIndexPath {
	if (theTableView!=numbersTable)
		[super tableView:theTableView didSelectRowAtIndexPath:theIndexPath];
}

- (void)selectedContact:(NSDictionary *)theContact {
	NSString *number = [theContact objectForKey:MGMCNumber];
	if (![additional containsObject:number])
		[additional addObject:number];
	[contactsTable deselectRowAtIndexPath:[contactsTable indexPathForSelectedRow] animated:YES];
}

- (IBAction)closeAdditional:(id)sender {
	NSString *numbers = @"None";
	if ([additional count]==1) {
		numbers = [[additional objectAtIndex:0] readableNumber];
	} else if ([additional count]>1) {
		numbers = [NSString stringWithFormat:@"%@, …", [[additional objectAtIndex:0] readableNumber]];
	}
	[additionalButton setTitle:numbers forState:UIControlStateNormal];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:additional:)];
	CGRect outViewFrame = [additionalView frame];
	outViewFrame.origin.y = +[[self view] frame].size.height;
	[additionalView setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished additional:(id)context {
	[additionalView removeFromSuperview];
}


- (void)keyboardWillShow:(NSNotification *)theNotification {
	CGSize keyboardSize = CGSizeZero;
	if ([[theNotification userInfo] objectForKey:MGMKeyboardBoundsM]!=nil)
		keyboardSize = [[[theNotification userInfo] objectForKey:MGMKeyboardBoundsM] CGRectValue].size;
	else
		keyboardSize = [[[theNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	CGRect frame = [SMSTextView frame];
	frame.size.height -= keyboardSize.height;
	[SMSTextView setFrame:frame];
}
- (void)textViewDidChange:(UITextView *)textView {
	[SMSTextCountField setText:[[NSNumber numberWithInt:160-[[SMSTextView text] length]] stringValue]];
}
- (void)keyboardWillHide:(NSNotification *)theNotification {
	CGSize keyboardSize = CGSizeZero;
	if ([[theNotification userInfo] objectForKey:MGMKeyboardBoundsM]!=nil)
		keyboardSize = [[[theNotification userInfo] objectForKey:MGMKeyboardBoundsM] CGRectValue].size;
	else
		keyboardSize = [[[theNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	CGRect frame = [SMSTextView frame];
	frame.size.height += keyboardSize.height;
	[SMSTextView setFrame:frame];
}

- (IBAction)close:(id)sender {
	[SMSTextView resignFirstResponder];
	[controller dismissMultiSMS:self];
}
- (IBAction)send:(id)sender {
	NSMutableArray *SMSNumbers = [NSMutableArray arrayWithArray:additional];
	if ([groupPicker selectedRowInComponent:0]!=0) {
		NSArray *members = [[instance contacts] membersOfGroupID:[[groups objectAtIndex:[groupPicker selectedRowInComponent:0]-1] objectForKey:MGMCDocID]];
		for (unsigned int i=0; i<[members count]; i++) {
			[SMSNumbers addObject:[[members objectAtIndex:i] objectForKey:MGMCNumber]];
		}
	}
	if ([SMSNumbers count]<=0) {
		UIAlertView *alert = [[UIAlertView new] autorelease];
		[alert setTitle:@"Error sending a SMS Message"];
		[alert setMessage:@"You need to at least have 1 contact to send to."];
		[alert addButtonWithTitle:MGMOkButtonTitle];
		[alert show];
	} else if ([[SMSTextView text] isEqual:@""]) {
		UIAlertView *alert = [[UIAlertView new] autorelease];
		[alert setTitle:@"Error sending a SMS Message"];
		[alert setMessage:@"Message is blank."];
		[alert addButtonWithTitle:MGMOkButtonTitle];
		[alert show];
	} else {
		[SMSTextView resignFirstResponder];
		[SMSTextView setEditable:NO];
		[sendButton setTitle:@"Sending..."];
		[sendButton setEnabled:NO];
		[cancelButton setEnabled:NO];
		[[instance inbox] sendMessage:[SMSTextView text] phoneNumbers:SMSNumbers smsID:@"" delegate:self];
	}
}

- (void)message:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	[SMSTextView setEditable:YES];
	[sendButton setTitle:@"Send"];
	[sendButton setEnabled:YES];
	[cancelButton setEnabled:YES];
	[SMSTextView becomeFirstResponder];
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Error sending a SMS Message"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
}
- (void)messageDidFinish:(MGMDelegateInfo *)theInfo instance:(MGMInstance *)theInstance {
	[controller dismissMultiSMS:self];
}
@end

@implementation MGMMultiSMSTextView
- (void)awakeFromNib {
	[self setContentInset:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)];
}

- (void)setContentOffset:(CGPoint)theOffset {
	if ([self isTracking] || [self isDecelerating]) {
		[self setContentInset:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)];
		[super setContentOffset:theOffset];
	} else {
		[super setContentOffset:theOffset];
		[self setContentInset:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)];
	}
}
@end