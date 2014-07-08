//
//  AVPlayerClass.h
//  AVCam
//
//  Created by Jeffrey Monaco on 6/19/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;

@interface AVPlayerClass : UIView

@property (nonatomic, retain)AVPlayer*player;

-(void)setMovieToPlayer:(AVPlayer*)player;

@end
