//
//  SignUpViewController.h
//  Wildfire
//
//  Created by Animesh Anand on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface SignUpViewController : UIViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passText;
@property (strong, nonatomic) IBOutlet UITextField *phoneText;
@property (strong, nonatomic) IBOutlet UITextField *locationText;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;

- (IBAction)uploadProfilePic:(id)sender;

- (IBAction)submitButton:(id)sender;

@end
