//
//  Fire.h
//  Wildfire
//
//  Created by Animesh Anand on 6/10/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

/*
typedef enum{
    Technology,
    Politics,
    Fashion,
    Education,
    Lifestyle,
    Food,
    Art,
    Entertainment,
    Funny,
    Cute,
    Outrageous,
    Health,
    Kids,
    Places,
    Celebrity,
    Random
}Category;
 */

typedef enum{
    Audio,
    Video,
    Picture
}FireType;

@interface Fire : PFObject <PFSubclassing>


@property int category;
@property int fireType;
@property (strong, nonatomic) PFGeoPoint *locationList;
@property (strong, nonatomic) PFGeoPoint *locationOrigin;
@property (strong, nonatomic) PFUser *originator;
@property (strong, nonatomic) NSURL *fireURL;
@property (strong, nonatomic) NSString* NumberOfViews;




+(NSString*)parseClassName;

@end
