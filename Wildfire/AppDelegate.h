//
//  AppDelegate.h
//  Wildfire
//
//  Created by Animesh Anand on 6/4/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "MapView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MapView *mapView;
@property (strong, nonatomic) UIStoryboard *storyboard;
@property (strong, nonatomic) UINavigationController* navController;

-(void)userLogIn;

@end
