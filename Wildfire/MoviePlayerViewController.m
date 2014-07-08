//
//  MoviePlayerViewController.m
//  AVCam
//
//  Created by Jeffrey Monaco on 6/21/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController ()

@end

@implementation MoviePlayerViewController
@synthesize moviePlayer;

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
    
    
    
    if(_tempData == nil /*&& error!=nil*/) {
        //Print error description
        NSLog(@"ERROR: tempData = nil");
    }
    
    // NSLog(@"Data****************: %@", [data description]);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.MOV"];
    [_tempData writeToFile:appFile atomically:YES];
    
    NSURL *movieUrl = [NSURL fileURLWithPath:appFile];
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
    
    NSLog(@"playing %@",_videoURL);
    NSURL *url = _videoURL;
    
    //Create our moviePlayer
    //moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
    
    [moviePlayer.view setFrame:CGRectMake(0, 30,327, 375)];
    [self.view addSubview:moviePlayer.view];
    
    //Some additional customization
    moviePlayer.fullscreen = NO;
    moviePlayer.allowsAirPlay = YES;
    moviePlayer.shouldAutoplay = YES;
    moviePlayer.repeatMode = YES;
    moviePlayer.controlStyle = MPMovieControlStyleNone;
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

- (IBAction)spreadAction:(id)sender {
}
@end
