//
//  SignUpViewController.m
//  Wildfire
//
//  Created by Animesh Anand on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "SignUpViewController.h"


@interface SignUpViewController ()

@end

@implementation SignUpViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.1;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 206;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
CGFloat animatedDistance;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _profilePic.layer.cornerRadius = 42.5;
    
    //[_usernameText becomeFirstResponder];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO; //so that action such as clear text field button can be pressed
    [self.view addGestureRecognizer:gestureRecognizer];
    
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)uploadProfilePic:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a profile image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Photo Library", nil];
        [actionSheet showInView:self.view];
        
    } else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}

- (IBAction)submitButton:(id)sender {
    if(_usernameText.text.length < 8){
        [Utilities popUpMessage:@"Username should at least be 8 characters"];
        return;
    }
    if(_passText.text.length < 8 ){
        [Utilities popUpMessage:@"Password should at least be 8 characters, have at least one uppercase character, at least 1 lowercase character and at least 1 number."];
        return;
    }
    bool upper=false,lower=false,num=false;
    for(int i=0;i<_passText.text.length;i++){
        unichar ch = [_passText.text characterAtIndex:i];
        
        if (ch >= 'A' && ch <= 'Z') {
            // upper case
            upper = true;
        }
        if (ch >= 'a' && ch <= 'z') {
            // lower case
            lower = true;
        }
        if (ch >= '0' && ch <= '9') {
            // lower case
            num = true;
        }

    }
    
    if(!upper || !lower || !num){
        [Utilities popUpMessage:@"Password should have at least one uppercase character, at least 1 lowercase character and at least 1 number."];
        return;
    }
    
    [self signUp];
    
    
}

-(void)signUp
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    
    //Create a new user
    PFUser* newUser = [PFUser user];
    
    newUser.username = _usernameText.text;
    newUser.password = _passText.text;
    
    
    //If user has selected a profile image upload it and associate it with the user
    if (_imageData) {
        
        //Create a PFFile to store in Parse
        PFFile *imageFile = [PFFile fileWithName:@"thumbProfile.jpg" data:_imageData];
        
        //Save the image file in the background with a callback
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            //If the save was successful associate it with the user
            if (!error) {
                [newUser setObject:imageFile forKey:@"thumbProfileImage"];
                
                //Sign the user up in the background with a callback
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    //If it was successful dismiss the hud and proceed with the login
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        });
                        [Utilities processProfilePictureData:_imageData];
                        
                        //Subscribe to private push channel
                        if (newUser) {
                            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [newUser objectId]];
                            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
                            [[PFInstallation currentInstallation] saveEventually];
                            
                            [newUser setObject:privateChannelName forKey:@"channel"];
                        }
                        
                        
                        
                        //Save the user
                        [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            
                            if (succeeded) {
                                [Utilities popUpMessage:@"SignUp Succeeded!!!"];
                            } else {
                                
                            }
                            
                        }];

                        
                    } else {
                        //There was an error
                        //Dismiss the hud
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        });
                        
                        //Show the error and pop to the root view controller so the user
                        //can attempt to signup again
                        NSString *errorString = [[error userInfo] objectForKey:@"error"];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eventap" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        //[self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    } else {
        
        //No profile image exists so signup without one
        //Same process as above
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                });
                
                //Subscribe to private push channel
                if (newUser) {
                    NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [newUser objectId]];
                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                    [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
                    [[PFInstallation currentInstallation] saveEventually];
                    
                    [newUser setObject:privateChannelName forKey:@"channel"];
                }
                
                //Save the user
                [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        [Utilities popUpMessage:@"SignUp Succeeded!!!"];
                    } else {
                        
                    }
                    
                }];
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                });
                
                if ([error code] == kPFErrorConnectionFailed) {
                    
                    [Utilities popUpMessage:@"There seems to be a problem connecting to the Eventap servers, please check your internet connection and try again later"];
                    
                } else if ([error code] == kPFErrorUserEmailTaken) {
                    [Utilities popUpMessage:@"An Eventap account with that phone number already exists, please signup again with a different phone number."];
                }
                
                //[self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }];
        
    }

    
    
}


#pragma mark
#pragma mark - ImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    picker.view.layer.cornerRadius = 50;
    NSData *data = UIImageJPEGRepresentation(image, .90);
    _imageData = data;
    _profilePic.image = [UIImage imageWithData:data];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = YES;
        [self presentViewController:picker animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        //NSLog(@"Im here..");
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}


#pragma mark
#pragma mark - Text Field Delegate Methods
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"method called..");
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
