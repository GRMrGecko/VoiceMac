//
//  MGMPhotoSelector.h
//  VoiceMob
//
//  Created by James on 3/25/11.
//  Copyright 2011 Mr. Gecko's Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGMUsers/MGMUsers.h>

extern NSString * const MGMSIPBackground;
extern NSString * const MGMSIPBCustom;
extern NSString * const MGMSIPBDefault;
extern NSString * const MGMPSBackground;

@interface MGMPhotoSelector : MGMSettingView <UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
	IBOutlet UIView *view;
	IBOutlet UIImageView *imageView;
	UIImagePickerController *imagePickerController;
}
- (IBAction)selectPhoto:(id)sender;
- (void)dismiss;
@end