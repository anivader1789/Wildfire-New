//
//  AudioPlayerViewController.h
//  AVCam
//
//  Created by Jeffrey Monaco on 6/23/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioPlayer.h"

@interface AudioPlayerViewController : UIViewController{
    
}


@property (strong, nonatomic) NSURL *audioUrl;//Used to store path to audio.

@property NSData *audioData;//Used to store audio data.


@property (nonatomic, strong) AudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UISlider *currentTimeSlider;
@property (strong, nonatomic) IBOutlet UISlider *speedSlider;
@property (strong, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UILabel *duration;
- (IBAction)playButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;

@property BOOL isPaused;
@property BOOL scrubbing;

@property NSTimer *timer;

@end
