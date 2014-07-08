//
//  ProfilePageViewController.m
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "ProfilePageViewController.h"
#import "InviteFriendsTableViewController.h"
#import "SearchUserViewController.h"
#import "FollowersViewController.h"
#import "FireTableCell.h"
#import "FireViewController.h"

@interface ProfilePageViewController ()

@end

@implementation ProfilePageViewController

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
    
    UIImage* image3 = [UIImage imageNamed:@"Wild Fire Logo.png"];
    CGRect frameimg = CGRectMake(0, 0, 15, 15);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(inviteFriends)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *menubutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem=menubutton;
}

-(void)viewDidAppear:(BOOL)animated
{
    _usernameLabel.text = _user.username;
    
    [self updateFiresDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)inviteFriends
{
    SearchUserViewController* invitePage = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchUser"];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:invitePage animated:NO];

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

- (IBAction)contactsButton:(id)sender {
}

- (IBAction)followingButton:(id)sender {
    FollowersViewController* followersPage = [self.storyboard instantiateViewControllerWithIdentifier:@"followers"];
    self.navigationController.navigationBarHidden = NO;
    followersPage.isFollowers = true;
    [self.navigationController pushViewController:followersPage animated:YES];
}

- (IBAction)followedButton:(id)sender {
    FollowersViewController* followersPage = [self.storyboard instantiateViewControllerWithIdentifier:@"followers"];
    self.navigationController.navigationBarHidden = NO;
    followersPage.isFollowers = false;
    [self.navigationController pushViewController:followersPage animated:YES];
}

- (IBAction)gloabeButton:(id)sender {
}

- (IBAction)settingsButton:(id)sender {
}

-(void)updateFiresDataSource
{
    if(!_fires){
        _fires = [[NSMutableArray alloc] init];
    }
    
    PFQuery *query = [Fire query];
    [query whereKey:@"originator" equalTo:_user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            @synchronized(_fires){
                [_fires removeAllObjects];
                
                [_fires addObjectsFromArray:objects];
                
                int totalViews = 0;
                
                for(Fire *fire in _fires){
                    int v = [[fire objectForKey:@"NumberOfViews"] intValue];
                    totalViews = totalViews + v;
                }
                
                _viewsLabel.text = [NSString stringWithFormat:@"%d",totalViews];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[_listOfFiresTableView.pullToRefreshView stopAnimating];
                [_firesListTableView reloadData];
            });
        }
    }];
}

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
	return _fires.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table delegate method fires: %lu",  (unsigned long)_fires.count);
	static NSString *cellIdentifier = @"Cell";
	//static NSString *CellIdentifier = @"TableCell";
    FireTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Clicked");
    int row = [indexPath row];
    Fire *fire = [_fires objectAtIndex:row];
    
    FireViewController *fireView = [self.storyboard instantiateViewControllerWithIdentifier:@"fireView"];
    //fireView.receivedFire = fire;
    
    fireView.fire = fire;
    [self.navigationController pushViewController:fireView animated:YES];
    
    
}


@end
