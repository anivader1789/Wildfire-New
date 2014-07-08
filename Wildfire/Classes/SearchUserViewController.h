//
//  SearchUserViewController.h
//  Wildfire
//
//  Created by Animesh Anand on 6/17/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUserViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *guestsTableViewSearchBar;

@property (strong, nonatomic) NSMutableArray *filteredSearchedContacts;
@property (strong, nonatomic) NSArray *filteredResultsContacts;


@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *followees;

@end
