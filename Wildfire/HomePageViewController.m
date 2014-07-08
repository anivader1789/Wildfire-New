//
//  HomePageViewController.m
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "HomePageViewController.h"
#import "SettingsViewController.h"
#import "AVCamViewController.h"
#import "Fire.h"
#import "ReceivedFire.h"
#import "Utilities.h"
#import "FireTableCell.h"
#import "ProfilePageViewController.h"
#import "Following.h"
#import "FireViewController.h"


@interface HomePageViewController ()

@end

@implementation HomePageViewController



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
    
    NSLog(@"Current user: %@",[PFUser currentUser].objectId);
    
    UIImage* image3 = [UIImage imageNamed:@"Wild Fire Logo.png"];
    CGRect frameimg = CGRectMake(0, 0, 15, 15);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self.navigationController action:@selector(showMenu)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *menubutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem=menubutton;
    self.navigationItem.hidesBackButton = YES;
    
    [self updateFiresDataSource];
    [self reloadFollowees];
    
    [_listOfFiresTableView reloadData];
    //Setup pull to refresh
    id weakSelf = self;
    [_listOfFiresTableView addPullToRefreshWithActionHandler:^{
        [weakSelf updateFiresDataSource];
    }];
    
    
}




-(void) reloadFollowees
{
    if(!_followers){
        _followers = [[NSMutableArray alloc] init];
    }
    
    
    [Following getAllFollowers:^(NSArray *objects, NSError *error) {
        if(!error){
            @synchronized(_followers){
                [_followers removeAllObjects];
                [_followers addObjectsFromArray:objects];
                
                
            }
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateFiresDataSource];
    [_listOfFiresTableView reloadData];
    [self reloadFollowees];
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

- (IBAction)profileButton:(id)sender {
    
    
    
    ProfilePageViewController * profilePage = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePage"];
    self.navigationController.navigationBarHidden = NO;
    profilePage.user = [PFUser currentUser];
    [self.navigationController pushViewController:profilePage animated:NO];
    
}

- (IBAction)trendingButton:(id)sender {
}

- (IBAction)cameraButton:(id)sender {
   /* if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a profile image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Photo Library", nil];
        [actionSheet showInView:self.view];
        
    } else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
        
    }*/
    
    /*NSLog(@"Working fine till here");
    //Make a fire
    Fire *newFire = [Fire object];
    newFire.category = 0;
    newFire.fireType = 2;
    
    newFire.originator = [PFUser currentUser];
    newFire.numOfViews = 1;
    NSLog(@"okay here");
    
    [newFire saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(!error){
            if(succeeded){
                
                [newFire setObject:[PFUser currentUser] forKey:@"Originator"];
                //[newFire setObject:1 forKey:@"NumberOfViews"];
                NSLog(@"Fine till here");
                
                for(PFUser *follower in _followers){
                    ReceivedFire *recvFire = [ReceivedFire object];
            
                    //PFQuery *userQuery = [PFUser query];
                    //[userQuery whereKey:@"objectId" equalTo:@"xmYIG1TsKa"];
            
                    PFUser *recver = follower;
            
                    recvFire.receiver = recver;
                    recvFire.fire = newFire;
                
                    [recvFire saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            [newFire setObject:recver forKey:@"Receiver"];
                            [newFire setObject:newFire forKey:@"Fire"];
                            //[Utilities popUpMessage:[NSString stringWithFormat:@"Created a fire and sent to %@",followee.username]];
                            [Utilities popUpMessage:@"Fire sent!!"];
                            NSLog(@"Save success");
                        
                        }
                        else{
                            NSLog(@"Save failed");
                        }
                    }];
                
                }
            
                
            }
        }
        else{
            [Utilities popUpMessage:@"Error creating the fire"];
        }
    }];*/
    
    AVCamViewController *aVCam = [self.storyboard instantiateViewControllerWithIdentifier:@"cameraScreen"];
    [self.navigationController pushViewController:aVCam animated:NO];
    
}

- (IBAction)settingsButton:(id)sender {
    SettingsViewController *settingsController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsScreen"];
    [self.navigationController pushViewController:settingsController animated:NO];
}

/*#pragma mark
#pragma mark - ImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    picker.view.layer.cornerRadius = 50;
    NSData *data = UIImageJPEGRepresentation(image, .90);
    _imageData = data;
    _profilePic.image = [UIImage imageWithData:data];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = YES;
        [self presentViewController:picker animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        //NSLog(@"Im here..");
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}*/

-(void)updateFiresDataSource
{
    if(!_fires){
        _fires = [[NSMutableArray alloc] init];
    }
    
    [ReceivedFire getAllLiveFires:^(NSArray *results, NSError *error) {
        if(!error){
            @synchronized(_fires){
                [_fires removeAllObjects];
                [_fires addObjectsFromArray:results];
                NSLog(@"fires in table: %d",_fires.count);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[_listOfFiresTableView.pullToRefreshView stopAnimating];
                [_listOfFiresTableView reloadData];
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
    int row = [indexPath row];
    ReceivedFire *recvFire = [_fires objectAtIndex:[indexPath row]];
    
    Fire *fire = recvFire.fire;
    PFQuery *query = [Fire query];
    Fire *queryFire = (Fire*)[query getObjectWithId:fire.objectId];
    //PFUser *user = [fire objectForKey:@"originator"];
    NSLog(@"Fire: %@",[queryFire objectForKey:@"numOfViews"]);
    
    
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Clicked");
    ReceivedFire *recvFire = [_fires objectAtIndex:[indexPath row]];
    Fire *fire = recvFire.fire;
    
    FireViewController *fireView = [self.storyboard instantiateViewControllerWithIdentifier:@"fireView"];
    fireView.receivedFire = recvFire;
    
    fireView.fire = fire;
    [self.navigationController pushViewController:fireView animated:YES];
    
    
}




@end
