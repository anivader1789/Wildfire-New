//
//  Constants.m
//  Wildfire
//
//  Created by Animesh Anand on 6/18/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (NSString *)transferManagerBucket
{
    return [[NSString stringWithFormat:@"%@-%@", PICTURE_BUCKET, ACCESS_KEY_ID] lowercaseString];
}

@end
