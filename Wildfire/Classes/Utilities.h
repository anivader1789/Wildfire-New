//
//  Utilities.h
//  Wildfire
//
//  Created by Animesh Anand on 6/9/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject


//UIAlertView helper method
+(void)popUpMessage:(NSString*)message;

+ (void)processProfilePictureData:(NSData *)newProfilePictureData;

+(BOOL)isExpired:(NSDate*)date;

@end
