//
//  CarmenAppDelegate.m
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import "CarmenAppDelegate.h"

#import "CarmenViewController.h"

@implementation CarmenAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    CarmenViewController *carmenViewController = (CarmenViewController *)self.viewController;
    [carmenViewController switchToBackgroundMode:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    CarmenViewController *carmenViewController = (CarmenViewController *)self.viewController;
    [carmenViewController switchToBackgroundMode:NO];
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
