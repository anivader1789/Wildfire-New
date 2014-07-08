//
//  Following.h
//  Wildfire
//
//  Created by Animesh Anand on 6/10/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface Following : PFObject <PFSubclassing>

@property (strong, nonatomic) PFUser *Follower;
@property (strong, nonatomic) PFUser *Followed;
@property bool followBack;

+(NSString*)parseClassName;
+(void)getAllFollowees:(void (^)(NSArray *, NSError *))completionBlock;
+(void)getAllFollowers:(void (^)(NSArray *, NSError *))completionBlock;

@end
