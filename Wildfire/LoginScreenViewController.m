//
//  LoginScreenViewController.m
//  Wild Fire V2.0
//
//  Created by Jeffrey Monaco on 6/1/14.
//  Copyright (c) 2014 Jeffrey Monaco. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "HomePageViewController.h"
#import "SignUpViewController.h"
#import "Utilities.h"
#import "AppDelegate.h"
#import "SignUpViewController.h"

@interface LoginScreenViewController ()

@end

@implementation LoginScreenViewController

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
    

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO; //so that action such as clear text field button can be pressed
    [self.view addGestureRecognizer:gestureRecognizer];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"I'm a man!",@"msg",
                                                    [NSNumber numberWithInt:50], @"num", nil];
    
    [PFCloud callFunctionInBackground:@"Testing" withParameters:dic block:^(id object, NSError *error) {
        
        
        
    }];

}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"loginHome"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        
        //destViewController.recipeName = [recipes objectAtIndex:indexPath.row];
    }

}

/*
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    bool result = true;
    
    if ([identifier isEqualToString:@"loginHome"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        [Utilities popUpMessage:@"Cant go there yet"];
        result = false;
        
    }

    return result;
}
*/


- (IBAction)loginButton:(id)sender {
    [PFUser logInWithUsernameInBackground:_usernameText.text password:_passwordText.text block:^(PFUser *user, NSError *error) {
        if (!error) {
            //Login
            [Utilities popUpMessage:@"Login Success"];
            [self.navigationController dismissViewControllerAnimated:NO completion:^{
                
            }];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] userLogIn];
            
        } else {
            [Utilities popUpMessage:@"phone number or password invalid"];
        }
    }];
    
    
    

}

- (IBAction)signUpButton:(id)sender {
    //SignUpViewController *signUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpScreen"];
   // [self.navigationController pushViewController:signUpController animated:NO];
    SignUpViewController *signupController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    //SignUpViewController *signupController = [self.storyboard instantiateViewControllerWithIdentifier:@"signupScreen"];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:signupController animated:NO];
}




@end
