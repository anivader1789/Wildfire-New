//
//  CampaignViewController.h
//  Wildfire
//
//  Created by Animesh Anand on 6/23/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampaignViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *categorySelector;
@property (strong, nonatomic) IBOutlet UITextField *numPeopleTextfield;
- (IBAction)locButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *coinsLabel;
- (IBAction)launchButton:(id)sender;

@end
