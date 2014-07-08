//
//  MoviePlayerViewController.h
//  AVCam
//
//  Created by Jeffrey Monaco on 6/21/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MoviePlayerViewController : UIViewController

@property NSData *tempData;

@property(nonatomic,strong)MPMoviePlayerController *moviePlayer;

@property NSURL *videoURL;//Used to store path to video.

@property NSData *movieData;//Used to store movie data.

//Button Actions
- (IBAction)spreadAction:(id)sender;

@end
