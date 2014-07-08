//
//  AppDelegate.m
//  Wildfire
//
//  Created by Animesh Anand on 6/4/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "AppDelegate.h"
#import "Fire.h"
#import "ReceivedFire.h"
#import "Following.h"
#import "LoginScreenViewController.h"
#import "HomePageViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Override point for customization after application launch.
    
   // self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
    [GMSServices provideAPIKey:@"AIzaSyAn67_hB7ArE1ZwVhoIzgRDsVxK0IBWV6E"];
    
    [Parse setApplicationId:@"rb0CMbQnEWZBlwLT9vnm3l4THp0adhTxuXrtPHqg"
                  clientKey:@"S11BFNVPiSHFozUrh4di6PlzmTMXfTTdDXceSolu"];
    
    //Setup default ACL for all parse objects
    PFACL *defaultACL = [PFACL ACL];
    
    //Enable public read access while disabling public write access.
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [Fire registerSubclass];
    [ReceivedFire registerSubclass];
    [Following registerSubclass];
    
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    
    
    //self.mapView = [[MapView alloc] init];
    
    //Setup the welcome view controller
    //self.mapView = [[MapView alloc] initWithNibName:@"MapView" bundle:nil];
    
    //Set root view controller
    //self.window.rootViewController = self.mapView;
    //[self.window makeKeyAndVisible];
    
    
    //Jeffs navigational code start.
    _storyboard = [UIStoryboard storyboardWithName:@"iPhoneMain" bundle:nil];
    LoginScreenViewController * loginController = [_storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    
    //[self.window setRootViewController:newController];
    _navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    
    self.window.rootViewController = _navController;
    _navController.navigationBarHidden = YES;
    [self.window makeKeyAndVisible];

    
    
    
    return YES;
}

/*
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

 */

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}


#pragma mark
#pragma mark - log in user
-(void)userLogIn
{
    
    HomePageViewController *homePage = [_storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
     _navController.navigationBarHidden = NO;
    [_navController pushViewController:homePage animated:NO];
    
}




@end
