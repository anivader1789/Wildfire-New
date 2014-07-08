//
//  SettingsViewController.m
//  Wildfire
//
//  Created by Animesh Anand on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    
    //Initialize the dataArray
    titleArray = [[NSMutableArray alloc] init];
    
    //First section data
    NSArray *firstItemsArray = [[NSArray alloc] initWithObjects:@"Username",@"Mobile Number",@"Email",@"Push Notification",@"In App Notifications",@"GPS Location",nil];
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"title"];
    [titleArray addObject:firstItemsArrayDict];
    
    //Second section data
    NSArray *secondItemsArray = [[NSArray alloc] initWithObjects:@"FaceBook",@"Instagram",@"Twitter",nil];
    NSDictionary *secondItemsArrayDict = [NSDictionary dictionaryWithObject:secondItemsArray forKey:@"title"];
    [titleArray addObject:secondItemsArrayDict];
    
    //Third section data
    NSArray *thirdItemsArray = [[NSArray alloc] initWithObjects:@"See Fires Spread", @"View My Profile",nil];
    NSDictionary *thirdItemsArrayDict = [NSDictionary dictionaryWithObject:thirdItemsArray forKey:@"title"];
    [titleArray addObject:thirdItemsArrayDict];
    
    //Fourth section data
    NSArray *fourthItemsArray = [[NSArray alloc] initWithObjects:@"Help Center",@"Report a Problem", @"Privacy Policy", @"Terms of Use",@"Block People",nil];
    NSDictionary *fourthItemsArrayDict = [NSDictionary dictionaryWithObject:fourthItemsArray forKey:@"title"];
    [titleArray addObject:fourthItemsArrayDict];
    
    //Fifth section data
    NSArray *fifthItemsArray = [[NSArray alloc] initWithObjects:@"Clear Fires",nil];
    NSDictionary *fifthItemsArrayDict = [NSDictionary dictionaryWithObject:fifthItemsArray forKey:@"title"];
    [titleArray addObject:fifthItemsArrayDict];
    
    //Sixth section data
    NSArray *sixthItemsArray = [[NSArray alloc] initWithObjects:@"Wild Fire",@"Facebook",@"Instagram",@"Twitter",nil];
    NSDictionary *sixthItemsArrayDict = [NSDictionary dictionaryWithObject:sixthItemsArray forKey:@"title"];
    [titleArray addObject:sixthItemsArrayDict];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [titleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of rows it should expect should be based on the section
    NSDictionary *dictionary = [titleArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"title"];
    return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"MY ACCOUNT";
    else if(section == 1)
        return @"ADDITIONAL SERVICES";
    else if(section == 2)
        return @"WHO CAN...";
    else if(section == 3)
        return @"MORE INFORMATION";
    else if(section == 4)
        return @"ACCOUNT ACTIONS";
    else if(section == 5)
        return @"LOG OUT OF...";
    else return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSLog(@"Settings Table loaded");
    static NSString *CellIdentifier = @"TableCell";
   SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [titleArray objectAtIndex:indexPath.section];
    NSArray *titleArray = [dictionary objectForKey:@"title"];
    NSString *cellValue = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    
    return cell;
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

- (IBAction)signoutButton:(id)sender {
    NSLog(@"Logging out user");
    
    /*
    //Clear all cached results
    [PFQuery clearAllCachedResults];
    
    //Log out
    [PFUser logOut];
    PFUser *user = [PFUser currentUser];
    NSLog(@"%@", user);
    [[FBSession activeSession] closeAndClearTokenInformation];
     */
}
- (IBAction)switch:(id)sender {
    if(_privateSwitch.on){
        
    }
    else{
        
    }
}
@end
