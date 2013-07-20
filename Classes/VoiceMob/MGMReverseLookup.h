//
//  MGMReverseLookup.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/5/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

#define MGMMKEnabled 1

@class MGMController, MGMURLConnectionManager, MKMapView;

@interface MGMReverseLookup : NSObject <UIWebViewDelegate> {
	MGMController *controller;
	MGMURLConnectionManager *connectionManager;
	
	NSString *currentNumber;
#if !MGMMKEnabled
	BOOL mapLoaded;
	NSString *mapCall;
#endif
	
	IBOutlet UIView *view;
	IBOutlet UITextView *RLName;
    IBOutlet UITextView *RLAddress;
    IBOutlet UITextView *RLCityState;
    IBOutlet UITextView *RLZipCode;
    IBOutlet UITextView *RLPhoneNumber;
#if MGMMKEnabled
	IBOutlet MKMapView *map;
#else
	IBOutlet UIWebView *RLMap;
#endif
}
- (id)initWithController:(MGMController *)theController;

- (MGMController *)controller;
- (UIView *)view;

- (void)setNumber:(NSString *)theNumber;

- (IBAction)close:(id)sender;
@end