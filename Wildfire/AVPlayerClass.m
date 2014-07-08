//
//  AVPlayerClass.m
//  AVCam
//
//  Created by Jeffrey Monaco on 6/19/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "AVPlayerClass.h"


@implementation AVPlayerClass

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

-(AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer]player];
}

-(void)setMovieToPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

@end
