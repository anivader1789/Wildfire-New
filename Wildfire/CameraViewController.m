//
//  CameraViewController.m
//  Wild Fire V2.0
//
//  Created by Jeffrey Monaco on 6/5/14.
//  Copyright (c) 2014 Jeffrey Monaco. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController

//Delete the following TakePhoto and ChooseExisting functions if app builds and runs correctly.
/*
- (IBAction)TakePhoto {
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.showsCameraControls = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)ChooseExisting {
    picker2 = [[UIImagePickerController alloc] init];
    picker2.delegate = self;
    [picker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker2 animated:YES completion:nil];

}*/

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imageView setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)BackButton{
    UIStoryboard *homePageStoryBoard = [UIStoryboard storyboardWithName:@"HomeScreen" bundle:nil];
    UIViewController *initialHomeScreen = [homePageStoryBoard instantiateInitialViewController];
    initialHomeScreen.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:initialHomeScreen animated:YES];

}

- (IBAction)customizeButton:(id)sender {
}

- (IBAction)takePhotoButton:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.showsCameraControls = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)chooseExistingButton:(id)sender {
    picker2 = [[UIImagePickerController alloc] init];
    picker2.delegate = self;
    [picker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker2 animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
