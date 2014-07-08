//
//  TrendingTableViewController.h
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingTableViewController : UITableViewController

@property(nonatomic,strong)NSArray *Icon;
@property(nonatomic,strong)NSArray *Arrow;
@property(nonatomic,strong)NSArray *Title;
@property(nonatomic,strong)NSArray *Description;

//Buttons
- (IBAction)filterButton:(id)sender;

//Boolean Values
@property BOOL filterButtonPressed;

//Integers
@property int numberOfRows;

@end
