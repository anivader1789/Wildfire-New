//
//  PhotoEditViewController.h
//  AVCam
//
//  Created by Jeffrey Monaco on 6/18/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>

@interface PhotoEditViewController : UIViewController<AmazonServiceRequestDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
@property NSData *capturedPic;
- (IBAction)spread:(id)sender;
- (IBAction)putOut:(id)sender;
@property (strong, nonatomic) NSMutableArray *followers;
@property (nonatomic, retain) AmazonS3Client *s3;

@end
