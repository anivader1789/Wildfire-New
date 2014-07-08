//
//  SettingsTableViewCell.h
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/10/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewCell : UITableViewCell

@property (strong, nonatomic)IBOutlet UILabel *Title;
@property (strong, nonatomic)IBOutlet UILabel *UserInfo;
@property (strong, nonatomic)IBOutlet UISwitch *Switch;
@property (strong, nonatomic)IBOutlet UIImageView *Arrow;

@end
