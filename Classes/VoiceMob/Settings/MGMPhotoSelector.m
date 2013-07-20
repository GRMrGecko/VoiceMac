//
//  MGMPhotoSelector.m
//  VoiceMob
//
//  Created by James on 3/25/11.
//  Copyright 2011 Mr. Gecko's Media. All rights reserved.
//

#import "MGMPhotoSelector.h"
#import "MGMVMAddons.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMSIPBackground = @"MGMSIPBackground";
NSString * const MGMSIPBCustom = @"custom";
NSString * const MGMSIPBDefault = @"default";
NSString * const MGMPSBackground = @"background.png";

@implementation MGMPhotoSelector
- (id)initWithSetting:(MGMSetting *)theSetting {
	if ((self = [super initWithSetting:theSetting])) {
		
	}
	return self;
}
- (void)dealloc {
	[self releaseView];
	[super dealloc];
}

- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:@"PhotoSelector" owner:self options:nil]) {
			NSLog(@"Unable to load Photo Selector.");
		} else {
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:MGMSIPBackground] isEqual:MGMSIPBCustom])
				[imageView setImage:[UIImage imageWithContentsOfFile:[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMPSBackground]]];
			else
				[self selectPhoto:self];
		}
	}
	return view;
}
- (void)releaseView {
	[view release];
	view = nil;
	[imagePickerController release];
	imagePickerController = nil;
	[imageView release];
	imageView = nil;
}

- (IBAction)selectPhoto:(id)sender {
	imagePickerController = [[UIImagePickerController alloc] init];
	[imagePickerController setDelegate:self];
	[imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	
	UIView *viewController = [[[[[UIApplication sharedApplication] windows] objectAtIndex:0] subviews] objectAtIndex:0];
	CGRect inViewFrame = [[imagePickerController view] frame];
	inViewFrame.size = [viewController frame].size;
	inViewFrame.origin.y = +inViewFrame.size.height;
	[[imagePickerController view] setFrame:inViewFrame];
	[viewController addSubview:[imagePickerController view]];
	[imagePickerController viewWillAppear:YES];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	CGRect outViewFrame = [[imagePickerController view] frame];
	outViewFrame.origin.y -= outViewFrame.size.height;
	[[imagePickerController view] setFrame:outViewFrame];
	[UIView commitAnimations];
	[imagePickerController viewDidAppear:YES];
}

- (UIImage *)cropImage:(UIImage *)theImage toSize:(CGSize)theSize {
	if (theImage!=nil) {
		CGSize size = [theImage size];
		float scaleFactor = 0.0;
		float scaledWidth = theSize.width;
		float scaledHeight = theSize.height;
		
		if (!CGSizeEqualToSize(size, theSize)) {
			float widthFactor = theSize.width / size.width;
			float heightFactor = theSize.height / size.height;
			
			if (widthFactor > heightFactor)
				scaleFactor = widthFactor;
			else
				scaleFactor = heightFactor;
			
			scaledWidth = size.width * scaleFactor;
			scaledHeight = size.height * scaleFactor;
		}
		CGSize newSize = CGSizeMake(scaledWidth, scaledHeight);
		if (!CGSizeEqualToSize(newSize, CGSizeZero)) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			UIGraphicsBeginImageContext(theSize);
			[theImage drawInRect:CGRectMake((theSize.width-scaledWidth)/2, (theSize.height-scaledHeight)/2, scaledWidth, scaledHeight)];
			UIImage *newImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
			UIGraphicsEndImageContext();
			[pool drain];
			return [newImage autorelease];
		}
	}
	return theImage;
}

- (void)imagePickerController:(UIImagePickerController *)thePicker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo {
	CGSize size;
	if ([[UIScreen mainScreen] isRetina])
		size = CGSizeMake(640, 920);
	else
		size = CGSizeMake(320, 460);
	UIImage *image = [self cropImage:[theInfo objectForKey:UIImagePickerControllerOriginalImage] toSize:size];
	NSData *data = UIImagePNGRepresentation(image);
	if (data!=nil) {
		[imageView setImage:image];
		[data writeToFile:[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMPSBackground] atomically:YES];
		[[NSUserDefaults standardUserDefaults] setObject:MGMSIPBCustom forKey:MGMSIPBackground];
	}
	[self dismiss];
}
- (void)imagePickerController:(UIImagePickerController *)thePicker didFinishPickingImage:(UIImage *)theImage editingInfo:(NSDictionary *)theInfo {
	CGSize size;
	if ([[UIScreen mainScreen] isRetina])
		size = CGSizeMake(640, 920);
	else
		size = CGSizeMake(320, 460);
	UIImage *image = [self cropImage:theImage toSize:size];
	NSData *data = UIImagePNGRepresentation(image);
	if (data!=nil) {
		[imageView setImage:image];
		[data writeToFile:[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMPSBackground] atomically:YES];
		[[NSUserDefaults standardUserDefaults] setObject:MGMSIPBCustom forKey:MGMSIPBackground];
	}
	[self dismiss];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thePicker {
	[self dismiss];
}

- (void)dismiss {
	[imagePickerController viewWillDisappear:YES];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
	CGRect outViewFrame = [[imagePickerController view] frame];
	outViewFrame.origin.y = +outViewFrame.size.height;
	[[imagePickerController view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(id)theContext {
	[imagePickerController viewDidDisappear:YES];
	[[imagePickerController view] removeFromSuperview];
	[imagePickerController release];
	imagePickerController = nil;
}
@end