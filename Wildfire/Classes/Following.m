//
//  Following.m
//  Wildfire
//
//  Created by Animesh Anand on 6/10/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "Following.h"

@implementation Following

@dynamic Follower,Followed,followBack;

+(NSString*)parseClassName
{
    return @"Following";
}

+(void)getAllFollowees:(void (^)(NSArray *, NSError *))completionBlock
{
    PFQuery *query = [Following query];
    [query whereKey:@"Follower" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            NSLog(@"followees %d",objects.count);
            if(objects.count > 0){
                NSMutableArray* results = [[NSMutableArray alloc] init];
                for(int i=0;i<objects.count;i++){
                    //if([Utilities isExpired:[[objects objectAtIndex:i] objectForKey:@"createdAt"]]){
                    PFUser* followed = (PFUser*)[[objects objectAtIndex:i] objectForKey:@"Followed"];
                    [results addObject:followed];
                    NSLog(@"result id: %@",followed.objectId);
                    //}
                }
                
                completionBlock(results,NULL);
            }
        }
        else{
            completionBlock(NULL, error);
        }
    }];
}

+(void)getAllFollowers:(void (^)(NSArray *, NSError *))completionBlock
{
    PFQuery *query = [Following query];
    [query whereKey:@"Followed" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            NSLog(@"followers %d",objects.count);
            if(objects.count > 0){
                NSMutableArray* results = [[NSMutableArray alloc] init];
                for(int i=0;i<objects.count;i++){
                    //if([Utilities isExpired:[[objects objectAtIndex:i] objectForKey:@"createdAt"]]){
                    PFUser* followed = (PFUser*)[[objects objectAtIndex:i] objectForKey:@"Follower"];
                    [results addObject:followed];
                    NSLog(@"result id: %@",followed.objectId);
                    //}
                }
                
                completionBlock(results,NULL);
            }
        }
        else{
            completionBlock(NULL, error);
        }
    }];
}


@end
