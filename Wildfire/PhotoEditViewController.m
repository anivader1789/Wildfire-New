//
//  PhotoEditViewController.m
//  AVCam
//
//  Created by Jeffrey Monaco on 6/18/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "PhotoEditViewController.h"
#import "Fire.h"
#import "Following.h"
#import "ReceivedFire.h"
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Utilities.h"
#import <Parse/Parse.h>

@interface PhotoEditViewController ()

@end

@implementation PhotoEditViewController

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
    
    _mainImageView.image = [UIImage imageWithData:_capturedPic];
    
    
    if(![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"]
       && _s3 == nil)
    {
        // Initial the S3 Client.
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // This sample App is for demonstration purposes only.
        // It is not secure to embed your credentials into source code.
        // DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.
        // We offer two solutions for getting credentials to your mobile App.
        // Please read the following article to learn about Token Vending Machine:
        // * http://aws.amazon.com/articles/Mobile/4611615499399490
        // Or consider using web identity federation:
        // * http://aws.amazon.com/articles/Mobile/4617974389850313
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        @try{
        NSLog(@"debug point 1");
        _s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        _s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
        
        NSLog(@"debug point 2");
        // Create the picture bucket.
        S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[Constants transferManagerBucket] andRegion:[S3Region USWest2]];
        NSLog(@"debug point 3");
        S3CreateBucketResponse *createBucketResponse = [_s3 createBucket:createBucketRequest];
        NSLog(@"debug point 4");
        if(createBucketResponse.error != nil)
        {
            NSLog(@"Error: %@", createBucketResponse.error);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"There was an exception when connecting to s3: %@",exception.description);
    }
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self reloadFollowees];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [Utilities popUpMessage:@"The image was successfully uploaded."];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [Utilities popUpMessage:error.description];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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

- (void)uploadFire:(NSString*)objectid
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @try{
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"fire%@.jpg",objectid]
                                                                  inBucket:[Constants transferManagerBucket]];
        por.contentType = @"image/jpeg";
        por.data        = _capturedPic;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [Utilities popUpMessage:[putObjectResponse.error.userInfo objectForKey:@"message"]];
            }
            else
            {
                [Utilities popUpMessage:@"Upload was successful."];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    }
                   
                   @catch (NSException *exception) {
                       NSLog(@"There was an exception when connecting to s3: %@",exception.description);
                   }
    });
}

- (IBAction)spread:(id)sender {
    
    Fire *newFire = [Fire object];
    newFire.category = 0;
    newFire.fireType = 2;
    
    newFire.originator = [PFUser currentUser];
    newFire.NumberOfViews = [NSString stringWithFormat:@"%d",1];
    NSLog(@"okay here");
   
    
    [newFire saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(!error){
            if(succeeded){
                 [self uploadFire:newFire.objectId];
                
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
                            //[Utilities popUpMessage:@"Fire sent!!"];
                            
                            
                            NSLog(@"Save success");
                            
                        }
                        else{
                            NSLog(@"Save failed");
                        }
                    }];
                    
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }
        }
        else{
            [Utilities popUpMessage:@"Error creating the fire"];
        }
    }];
    
}

- (IBAction)putOut:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
