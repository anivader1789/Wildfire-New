//
//  HomePageViewController.h
//  Wildfire
//
//  Created by Jeffrey Monaco on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVPullToRefresh.h"


@interface HomePageViewController : UIViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate>{
    
}

@property (strong, nonatomic) NSData *imageData;
@property (strong,nonatomic) NSMutableArray *fires;

//Buttons
- (IBAction)profileButton:(id)sender;
- (IBAction)trendingButton:(id)sender;
- (IBAction)cameraButton:(id)sender;
- (IBAction)settingsButton:(id)sender;

//Table View
@property (strong, nonatomic) IBOutlet UITableView *listOfFiresTableView;
@property (strong, nonatomic) NSMutableArray *followers;



@end
