//
//  AppDelegate.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <CloudSight/CloudSightConnection.h>

#import "AppDelegate.h"
#import "HistoryItemStore.h"
#import "TagQueryManager.h"
#import "NSString+UUID.h"
#import "Config.h"
#import "NSUserDefaults+GroundControl.h"
#import "CameraViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CloudSightConnection sharedInstance].consumerKey = CLOUDSIGHT_KEY;
    [CloudSightConnection sharedInstance].consumerSecret = CLOUDSIGHT_SECRET;
    
    // Set some defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:DEFAULT_FOCUS_LOCK_SOUND_KEY] == nil)
        [defaults setBool:YES forKey:DEFAULT_FOCUS_LOCK_SOUND_KEY];
    
    if ([defaults objectForKey:DEFAULT_FLASH_KEY] == nil)
        [defaults setBool:YES forKey:DEFAULT_FLASH_KEY];

    [defaults synchronize];
    
    // Load remote defaults, make sure cache is off
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    // Setup initial window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Setup main view controller
    CameraViewController *viewController = [[CameraViewController alloc] init];

    // Set status bar
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Setup base navigation controller
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.navigationBarHidden = YES;
    
    // Start root view controller
    [[self window] setRootViewController:navController];
    [[self window] makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // Remove unfinished queries from history list
    [[HistoryItemStore sharedStore] removeUnfinishedQueries];
    
    // Remove all from the query manager (connection state won't be consistent when reloaded anyway)
    [[TagQueryManager sharedManager] reset];    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
