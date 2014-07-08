//
//  SettingsViewController.h
//  Wildfire
//
//  Created by Animesh Anand on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableArray *titleArray;
    NSMutableArray *rightImageArray;
    NSMutableArray *descriptionArray;

}

- (IBAction)signoutButton:(id)sender;
@property (strong, nonatomic) IBOutlet UISwitch *privateSwitch;
- (IBAction)switch:(id)sender;


@end
