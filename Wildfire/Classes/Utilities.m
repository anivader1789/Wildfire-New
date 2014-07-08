//
//  Utilities.m
//  Wildfire
//
//  Created by Animesh Anand on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "Utilities.h"
#import "UIImage+ResizeAdditions.h"
#import "UIImage+RoundedCornerAdditions.h"
#import <Parse/Parse.h>


@implementation Utilities


#pragma mark
#pragma mark - Pop Up Message
+(void)popUpMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WildFIRE" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark
#pragma mark - Update Profile Picture
+ (void)processProfilePictureData:(NSData *)newProfilePictureData {
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    UIImage *thumbRoundedImage = [image thumbnailImage:200 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationDefault];
    NSData *thumbRoundedImageData = UIImageJPEGRepresentation(thumbRoundedImage, 0.9);
    
    if (thumbRoundedImageData.length > 0) {
        
        PFFile *fileThumbRoundedImage = [PFFile fileWithName:@"thumbProfile.jpg" data:thumbRoundedImageData];
        [fileThumbRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileThumbRoundedImage forKey:@"thumbProfileImage"];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
}


+(BOOL)isExpired:(NSDate *)date
{
    if ([date timeIntervalSinceNow] > 172800.0) {
        // Date has passed
        return YES;
    } else {
        return NO;
    }
}


@end
