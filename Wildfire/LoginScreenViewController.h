//
//  LoginScreenViewController.h
//  Wild Fire V2.0
//
//  Created by Jeffrey Monaco on 6/1/14.
//  Copyright (c) 2014 Jeffrey Monaco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginScreenViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
- (IBAction)loginButton:(id)sender;
- (IBAction)signUpButton:(id)sender;



@end
