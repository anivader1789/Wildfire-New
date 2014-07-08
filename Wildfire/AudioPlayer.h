//
//  AudioPlayer.h
//  Wildfire
//
//  Created by Animesh Anand on 7/7/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioPlayer : NSObject

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

// Public methods
- (void)initPlayer:(NSURL*)audioFileLocationURL;
- (void)playAudio;
- (void)pauseAudio;
- (void)setCurrentAudioTime:(float)value;
- (float)getAudioDuration;
- (NSString*)timeFormat:(float)value;
- (NSTimeInterval)getCurrentAudioTime;
-(void)setRate:(float)rate;

@end
