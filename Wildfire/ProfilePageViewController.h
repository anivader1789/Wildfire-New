//
//  ProfilePageViewController.h
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Fire.h"

@interface ProfilePageViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

//Buttons
- (IBAction)contactsButton:(id)sender;
- (IBAction)followingButton:(id)sender;
- (IBAction)followedButton:(id)sender;
- (IBAction)gloabeButton:(id)sender;
- (IBAction)settingsButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *viewsLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong,nonatomic) NSMutableArray *fires;
@property (strong,nonatomic) PFUser *user;

//Table View
@property (strong, nonatomic) IBOutlet UITableView *firesListTableView;

//Images

@end
