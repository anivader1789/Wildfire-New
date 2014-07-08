//
//  PhotoViewController.h
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController

//Buttons
- (IBAction)globeButton:(id)sender;
- (IBAction)extinguishButton:(id)sender;
- (IBAction)spreadButton:(id)sender;

//Labels
@property (strong, nonatomic) IBOutlet UILabel *postersUsernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeElapsedSincePostLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfViewsLabel;

//Images
@property (strong, nonatomic) IBOutlet UIImageView *postersProfilePictureImage;
@property (strong, nonatomic) IBOutlet UIImageView *photoPostedImage;


@end
