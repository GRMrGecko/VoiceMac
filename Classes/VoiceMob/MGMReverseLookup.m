//
//  MGMReverseLookup.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/5/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMReverseLookup.h"
#import "MGMController.h"
#import "MGMVMAddons.h"
#if MGMMKEnabled
#import <MapKit/MapKit.h>
#endif
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

#if MGMMKEnabled
@interface MGMMapPin : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}
- (CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)theCoordinate;

- (NSString *)title;
- (void)setTitle:(NSString *)theTitle;
- (NSString *)subtitle;
- (void)setSubtitle:(NSString *)theTitle;
@end

@implementation MGMMapPin
- (void)dealloc {
	[title release];
	[subtitle release];
	[super dealloc];
}
- (CLLocationCoordinate2D)coordinate {
	return coordinate;
}
- (void)setCoordinate:(CLLocationCoordinate2D)theCoordinate {
	coordinate = theCoordinate;
}

- (NSString *)title {
	return title;
}
- (void)setTitle:(NSString *)theTitle {
	[title release];
	title = [theTitle copy];
}
- (NSString *)subtitle {
	return subtitle;
}
- (void)setSubtitle:(NSString *)theTitle {
	[subtitle release];
	subtitle = [theTitle copy];
}
@end
#endif

NSString * const MGMRLLoading = @"Loading...";

@implementation MGMReverseLookup
- (id)initWithController:(MGMController *)theController {
	if ((self = [super init])) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"ReverseLookup"] owner:self options:nil]) {
			NSLog(@"Unable to load Reverse Lookup");
			[self release];
			self = nil;
		} else {
			controller = theController;
			connectionManager = [MGMURLConnectionManager new];
#if !MGMMKEnabled
			mapLoaded = NO;
			[RLMap setDelegate:self];
			[RLMap loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"]]]];
#endif
		}
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[connectionManager cancelAll];
	[connectionManager release];
	[currentNumber release];
	[view release];
	[RLName release];
	[RLAddress release];
	[RLCityState release];
	[RLZipCode release];
	[RLPhoneNumber release];
#if MGMMKEnabled
	[map release];
#else
	[RLMap release];
	[mapCall release];
#endif
	[super dealloc];
}

- (MGMController *)controller {
	return controller;
}
- (UIView *)view {
	return view;
}

- (void)setNumber:(NSString *)theNumber {
	[currentNumber release];
	currentNumber = [theNumber copy];
	[RLPhoneNumber setText:[currentNumber readableNumber]];
	MGMWhitePagesHandler *handler = [MGMWhitePagesHandler reverseLookup:currentNumber delegate:self];
	[connectionManager addHandler:handler];
	[RLName setText:MGMRLLoading];
	[RLAddress setText:MGMRLLoading];
	[RLCityState setText:MGMRLLoading];
	[RLZipCode setText:MGMRLLoading];
}
- (void)reverseLookup:(MGMWhitePagesHandler *)theHandler didFailWithError:(NSError *)theError {
	UIAlertView *alert = [[UIAlertView new] autorelease];
	[alert setTitle:@"Reverse Lookup Failed"];
	[alert setMessage:[theError localizedDescription]];
	[alert addButtonWithTitle:MGMOkButtonTitle];
	[alert show];
}
- (void)reverseLookupDidFindInfo:(MGMWhitePagesHandler *)theHandler {
	if ([theHandler name]!=nil) {
		[RLName setText:[theHandler name]];
	} else {
		[RLName setText:@""];
	}
	if ([theHandler address]!=nil) {
		[RLAddress setText:[theHandler address]];
	} else {
		[RLAddress setText:@""];
	}
	if ([theHandler location]!=nil) {
		[RLCityState setText:[theHandler location]];
	} else {
		[RLCityState setText:@""];
	}
	if ([theHandler zip]!=nil) {
		[RLZipCode setText:[theHandler zip]];
	} else {
		[RLZipCode setText:@""];
	}
	if ([theHandler phoneNumber]!=nil) {
		[RLPhoneNumber setText:[[theHandler phoneNumber] readableNumber]];
	} else {
		[RLPhoneNumber setText:@""];
	}
	
	int zoom = 0;
	NSString *address = nil;
	if ([theHandler address]!=nil) {
		address = [NSString stringWithFormat:@"%@, %@", [theHandler address], [theHandler zip]];
		zoom = 15;
	} else if ([theHandler zip]!=nil) {
		address = [theHandler zip];
		zoom = 13;
	} else if ([theHandler location]!=nil) {
		address = [theHandler location];
		zoom = 13;
	} else if ([theHandler latitude]!=nil && [theHandler longitude]!=nil) {
		address = [NSString stringWithFormat:@"%@, %@", [theHandler latitude], [theHandler longitude]];
		zoom = 13;
	}
	
#if MGMMKEnabled
	double latitude = 0.0;
	double longitude = 0.0;
	if (address!=nil && [theHandler latitude]==nil) {
		NSData *geocodeData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", [address addPercentEscapes]]]];
		if (geocodeData!=nil) {
			NSDictionary *geocode = [geocodeData parseJSON];
			if ([[geocode objectForKey:@"status"] isEqual:@"OK"]) {
				NSDictionary *location = [[[[geocode objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
				latitude = [[location objectForKey:@"lat"] doubleValue];
				longitude = [[location objectForKey:@"lng"] doubleValue];
			}
		}
	} else {
		latitude = [[theHandler latitude] doubleValue];
		longitude = [[theHandler longitude] doubleValue];
	}
	
	if (latitude!=0.0 || longitude!=0.0) {
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		double span = (zoom==15 ? 0.002 : 0.3);
		[map setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(span, span))];
		MGMMapPin *pin = [[MGMMapPin new] autorelease];
		[pin setCoordinate:coordinate];
		if ([theHandler name]!=nil)
			[pin setTitle:[theHandler name]];
		else if (address!=nil)
			[pin setTitle:address];
		if ([pin title]!=nil) {
			[pin setSubtitle:[currentNumber readableNumber]];
		} else {
			[pin setTitle:[currentNumber readableNumber]];
			[pin setSubtitle:[NSString stringWithFormat:@"%lf, %lf", coordinate.latitude, coordinate.longitude]];
		}
		[map addAnnotation:pin];
	}
#else
	if (address!=nil && !mapLoaded) {
		[mapCall release];
		mapCall = [[NSString stringWithFormat:@"showAddress('%@', %d);", [address javascriptEscape], zoom] retain];
	} else if (address!=nil) {
		[RLMap stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showAddress('%@', %d);", [address javascriptEscape], zoom]];
	}
#endif
}
#if !MGMMKEnabled
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	mapLoaded = YES;
	if (mapCall!=nil) {
		[RLMap stringByEvaluatingJavaScriptFromString:mapCall];
		[mapCall release];
		mapCall = nil;
	}
}
#endif

- (IBAction)close:(id)sender {
#if !MGMMKEnabled
	[RLMap setDelegate:nil];
#endif
	[connectionManager cancelAll];
	[controller dismissReverseLookup:self];
}
@end