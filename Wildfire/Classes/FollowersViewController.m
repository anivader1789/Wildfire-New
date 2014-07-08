//
//  FollowersViewController.m
//  Wildfire
//
//  Created by Animesh Anand on 6/25/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "FollowersViewController.h"
#import "Following.h"
#import "FollowersTableViewCell.h"
#import "ProfilePageViewController.h"

@interface FollowersViewController ()

@end

@implementation FollowersViewController

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
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadUsers];
}


-(void) loadUsers
{
    
    NSLog(@"Number of users in following before loading: %d",[_userList count]);
    
    PFQuery *query = [Following query];
    [query includeKey:@"User"];
    [query includeKey:@"User.username"];
    if(_isFollowers)
        [query whereKey:@"Followed" equalTo:[PFUser currentUser]];
    else
        [query whereKey:@"Follower" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            NSLog(@"num of results: %lu",(unsigned long)objects.count);
            NSMutableArray *follows = [[NSMutableArray alloc] init];
            
                //NSLog(@"Number of users 2: %d",[_userList count]);
            
                //NSLog(@"Number of users 3: %d",[_userList count]);
                if(_isFollowers){
                    for(PFObject* obj in objects){
                        Following* following = (Following*)obj;
                        //NSLog(@"Number of users 5: %d",[_userList count]);
                        PFUser *user = (PFUser*)[following objectForKey:@"Follower"];
                        [follows addObject:user.objectId];
                        //NSLog(@"Number of users 6: %d",[_userList count]);
                    }
                }
                else{
                    for(PFObject* obj in objects){
                        Following* following = (Following*)obj;
                        //NSLog(@"Number of users 7: %d",[_userList count]);
                        PFUser *user = (PFUser*)[following objectForKey:@"Followed"];
                        [follows addObject:user.objectId];
                        //NSLog(@"Number of users 8: %d",[_userList count]);
                    }
                }
                
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:@"objectId" containedIn:follows];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *Error) {
                    if(!Error){
                        @synchronized(_userList){
                            if(!_userList){
                                _userList = [[NSMutableArray alloc] init];
                            }

                            [_userList removeAllObjects];
                            
                            [_userList addObjectsFromArray:results];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                //[_listOfFiresTableView.pullToRefreshView stopAnimating];
                                //NSLog(@"Number of users in following: %d",[_userList count]);
                                [_userTableView reloadData];
                            });

                            
                        }
                    }
                    else{
                        
                    }

                }];
                //NSLog(@"Number of users 4: %d",[_userList count]);
            
        }
        else{
            
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark
#pragma mark - UITableView Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    
    
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _userList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table delegate method followers: %lu",  (unsigned long)_userList.count);
	static NSString *cellIdentifier = @"Cell";
	//static NSString *CellIdentifier = @"TableCell";
    FollowersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    int row = [indexPath row];
    PFUser *user = (PFUser*)[_userList objectAtIndex:row];
    
    cell.usernameLabel.text = [user objectForKey:@"username"];
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    PFUser *user = (PFUser*)[_userList objectAtIndex:row];
    
    
    ProfilePageViewController * profilePage = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePage"];
    self.navigationController.navigationBarHidden = NO;
    profilePage.user = user;
    [self.navigationController pushViewController:profilePage animated:NO];
        
    
}


@end
