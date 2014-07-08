//
//  CameraViewController.h
//  Wild Fire V2.0
//
//  Created by Jeffrey Monaco on 6/5/14.
//  Copyright (c) 2014 Jeffrey Monaco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *picker;
    UIImagePickerController *picker2;
    UIImage *image;
    IBOutlet UIImageView *imageView;
}

-(IBAction)TakePhoto;
-(IBAction)ChooseExisting;
-(IBAction)BackButton;

- (IBAction)customizeButton:(id)sender;
- (IBAction)takePhotoButton:(id)sender;
- (IBAction)chooseExistingButton:(id)sender;

@end
