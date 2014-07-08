//
//  FireViewController.h
//  Wildfire
//
//  Created by Animesh Anand on 6/19/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fire.h"
#import "ReceivedFire.h"
#import <AWSS3/AWSS3.h>

@interface FireViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *fireView;
- (IBAction)spread:(id)sender;
- (IBAction)putOut:(id)sender;

@property (strong, nonatomic) Fire *fire;
@property (strong, nonatomic) ReceivedFire *receivedFire;
@property (strong, nonatomic) NSMutableArray *followers;
@property (nonatomic, retain) AmazonS3Client *s3;
@property (strong, nonatomic) IBOutlet UILabel *viewsLabel;

@end
