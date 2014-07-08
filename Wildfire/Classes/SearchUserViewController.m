//
//  SearchUserViewController.m
//  Wildfire
//
//  Created by Animesh Anand on 6/17/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "SearchUserViewController.h"
#import "SearchUserTableCell.h"
#import <Parse/Parse.h>
#import "Following.h"

@interface SearchUserViewController ()

@end

@implementation SearchUserViewController

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
    
    [self reloadFollowees];
    [self loadData];
    
}

-(void) reloadFollowees
{
    if(!_followees){
        _followees = [[NSMutableArray alloc] init];
    }
    
    
    [Following getAllFollowees:^(NSArray *objects, NSError *error) {
        if(!error){
            @synchronized(_followees){
                [_followees removeAllObjects];
                [_followees addObjectsFromArray:objects];
                
                [_usersTableView reloadData];
                
            }
        }
    }];
}


-(void) loadData
{
    
    if(!_users){
        _users = [[NSMutableArray alloc] init];
    }
    
    PFQuery *query = [PFUser query];
    
    @synchronized(_users){
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
            
                for(int i=0;i<objects.count;i++){
                    PFUser *user = (PFUser*)[objects objectAtIndex:i];
                    if(![user.objectId isEqualToString:[PFUser currentUser].objectId])
                        [_users addObject:user];
                }
                [_usersTableView reloadData];
            }
        }];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredResultsContacts count];
    } else {
        
        return _users.count;
    }
	
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table delegate method users: %lu",  (unsigned long)_users.count);
	static NSString *cellIdentifier = @"Cell";
    
    int row = [indexPath row];
    
    PFUser *user = [_users objectAtIndex:row];
    bool isFollowed = false;
    
    for(PFUser* followees in _followees){
        if([followees.objectId isEqualToString:user.objectId]){
            isFollowed = true;
        }
    }
    
	//static NSString *CellIdentifier = @"TableCell";
    SearchUserTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.username.text = user.username;
    //cell.follow.image = nil;
    if(!isFollowed){
        NSLog(@"is not followed");
       cell.follow.image = nil;
    }
    else{
        cell.follow.image = [UIImage imageNamed:@"Wild Fire Logo.png"];
        NSLog(@"is followed");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    PFUser *user = [_users objectAtIndex:row];
    
    if(![_followees containsObject:user]){
        Following *newFollowing = [Following object];
        
        newFollowing.Followed = user;
        newFollowing.Follower = [PFUser currentUser];
        
        [newFollowing saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                [newFollowing setObject:[PFUser currentUser] forKey:@"Follower"];
                [newFollowing setObject:user forKey:@"Followed"];
                NSLog(@"Follow Save success");
                [self reloadFollowees];
            }
            else{
                NSLog(@"Follow Save failure");
            }
        }];
    }
    
}

#pragma mark
#pragma mark - Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
    self.filteredResultsContacts = [self.filteredSearchedContacts filteredArrayUsingPredicate:predicate];
}

#pragma mark
#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
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

@end
