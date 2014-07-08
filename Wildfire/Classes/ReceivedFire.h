//
//  ReceivedFire.h
//  Wildfire
//
//  Created by Animesh Anand on 6/10/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "Fire.h"

@interface ReceivedFire : PFObject <PFSubclassing>

@property (nonatomic,strong) Fire *fire;
@property (strong, nonatomic) PFUser *receiver;



+(NSString*)parseClassName;
+(void)getAllLiveFires:(void (^)(NSArray *, NSError *))completionBlock;

@end
