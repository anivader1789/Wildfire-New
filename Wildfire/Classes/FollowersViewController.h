//
//  FollowersViewController.h
//  Wildfire
//
//  Created by Animesh Anand on 6/25/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FollowersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray* userList;
@property bool isFollowers;
@property (strong, nonatomic) IBOutlet UITableView *userTableView;

@end
