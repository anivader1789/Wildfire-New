//
//  Constants.h
//  Wildfire
//
//  Created by Animesh Anand on 6/18/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACCESS_KEY_ID          @"AKIAI4ASD6BAHDWKSOUA"
#define SECRET_KEY             @"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"


// Constants for the Bucket and Object name.
#define PICTURE_BUCKET         @"wildfiremobileaug"
#define PICTURE_NAME           @"photo.JPG"


#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."


@interface Constants : NSObject

+ (NSString *)transferManagerBucket;

@end
