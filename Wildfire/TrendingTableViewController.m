//
//  TrendingTableViewController.m
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "TrendingTableViewController.h"
#import "TrendingTableViewCell.h"

@interface TrendingTableViewController ()

@end

@implementation TrendingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _Title = @[@"Lifestyle",
               @"Technology",
               @"Food",
               @"Education",
               @"Technology",
               @"Technology",
               @"Food",];
    _Description = @[@"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",];
    _Icon = @[@"Wild Fire Logo.png",@"Wild Fire Logo.png",
              @"Wild Fire Logo.png",@"Wild Fire Logo.png",
              @"Wild Fire Logo.png",@"Wild Fire Logo.png",
              @"Wild Fire Logo.png",];
    
    _filterButtonPressed = FALSE;
    
    _numberOfRows = 7;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return _numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Invite friends Table loaded");
    static NSString *CellIdentifier = @"TableCell";
    TrendingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    int row = [indexPath row];
    
    cell.Title.text = _Title[row];
    cell.Description.text = _Description[row];
    cell.Icon.image = [UIImage imageNamed:_Icon[row]];
    cell.Arrow.image = [UIImage imageNamed: @"rightArrow.png"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _Description = @[@"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",
                     @"23 minutes ago - Press and hold to view",];
    
    int row = [indexPath row];
    if(_filterButtonPressed == TRUE && row == 0){
        _numberOfRows = 7;
        _Title = @[@"Lifestyle",
                   @"Technology",
                   @"Food",
                   @"Education",
                   @"Technology",
                   @"Technology",
                   @"Food",];
        [self.tableView reloadData];
    }else if(_filterButtonPressed == TRUE && row == 1){
        _numberOfRows = 1;
        _Title = @[@"Education",];
        [self.tableView reloadData];
    }else if(_filterButtonPressed == TRUE && row == 2){
        _numberOfRows = 2;
        _Title = @[@"Food",
                   @"Food",];
        [self.tableView reloadData];
    }else if(_filterButtonPressed == TRUE && row == 3){
        _numberOfRows = 1;
        _Title = @[@"Lifestyle",];
        [self.tableView reloadData];
    }else if(_filterButtonPressed == TRUE && row == 4){
        _numberOfRows = 3;
        _Title = @[@"Technology",
                   @"Technology",
                   @"Technology",];
        [self.tableView reloadData];
    }

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)filterButton:(id)sender {
    _filterButtonPressed = TRUE;
    
    _Title = @[@"All Catagories",
               @"Education",
               @"Food",
               @"Lifestyle",
               @"Technology",];
    
    _Description = @[@"",
                     @"",
                     @"",
                     @"",
                     @"",
                     @"",
                     @"",];
    
    _numberOfRows = 5;
    
    [self.tableView reloadData];
    
}
@end
