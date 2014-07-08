//
//  FireViewController.m
//  Wildfire
//
//  Created by Animesh Anand on 6/19/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "FireViewController.h"
#import "Following.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Constants.h"
#import "Utilities.h"
#import "Fire.h"

@interface FireViewController ()

@end

@implementation FireViewController

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
    
    PFQuery *query = [Fire query];
    [query getObjectInBackgroundWithId:_fire.objectId block:^(PFObject *object, NSError *error) {
        NSString *views = [object objectForKey:@"NumberOfViews"];
        int viewsInt = [views intValue];
        NSLog(@"Views 1: %d",viewsInt);
        viewsInt++;
        NSLog(@"Views 2: %d",viewsInt);
        views = [NSString stringWithFormat:@"%d",viewsInt];
        Fire *f = (Fire*)object ;
        f.NumberOfViews = views;
        [f setObject:views forKey:@"NumberOfViews"];
        //[f setObject:[NSNumber numberWithInt:views] forKey:@"numOfViews"];
        
        [f saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Views 3: %@",[f objectForKey:@"NumberOfViews"]);
            _viewsLabel.text = [NSString stringWithFormat:@"# Views: %@",[f objectForKey:@"NumberOfViews"]];
        }];
        
    }];
    
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

    //_fire.numOfViews++;
    //Fire *fire = recvFire.fire;
    

    
    
    [self displayImage];
}

-(void)displayImage
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Set the content type so that the browser will treat the URL as an image.
        S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
        override.contentType = @"image/jpeg";
        
        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
        gpsur.key                     = [NSString stringWithFormat:@"fire%@.jpg",_fire.objectId];
        //gpsur.key = PICTURE_NAME;
        NSLog(@"Key: %@",gpsur.key);
        gpsur.bucket                  = [Constants transferManagerBucket];
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;
        
        // Get the URL
        NSError *error = nil;
        NSURL *url = [_s3 getPreSignedURL:gpsur error:&error];
        //url = [NSURL URLWithString:@"http://rottingspace.com/markers/parrot.tiff"];
        if(url == nil)
        {
            NSLog(@"%@",url);
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"Error: %@", error);
                    [Utilities popUpMessage:[error.userInfo objectForKey:@"message"]];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Display the URL in Safari
                NSData *data = [NSData dataWithContentsOfURL:url];
                NSLog(@"%@",url);
                UIImage *image = [UIImage imageWithData:data];
                _fireView.image = image;
            });
        }
        
    });
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)spread:(id)sender {
    for(PFUser *follower in _followers){
        
        PFQuery *query = [ReceivedFire query];
        [query whereKey:@"receiver" equalTo:follower];
        [query whereKey:@"fire" equalTo:_fire];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                if(objects.count == 0){
                    ReceivedFire *recvFire = [ReceivedFire object];
                    
                    //PFQuery *userQuery = [PFUser query];
                    //[userQuery whereKey:@"objectId" equalTo:@"xmYIG1TsKa"];
                    
                    PFUser *recver = follower;
                    
                    recvFire.receiver = recver;
                    recvFire.fire = _fire;
                    
                    [recvFire saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            //[newFire setObject:recver forKey:@"Receiver"];
                            //[newFire setObject:newFire forKey:@"Fire"];
                            //[Utilities popUpMessage:[NSString stringWithFormat:@"Created a fire and sent to %@",followee.username]];
                            //[Utilities popUpMessage:@"Fire sent!!"];
                            
                            
                            NSLog(@"Save success");
                            
                        }
                        else{
                            NSLog(@"Save failed");
                        }
                    }];

                }
            }
        }];
        
    }
    if(_receivedFire)
        [_receivedFire delete];
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)putOut:(id)sender {
    if(_receivedFire)
        [_receivedFire delete];

    [self.navigationController popViewControllerAnimated:YES];
}
@end
