//
//  AppDelegate.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "AppDelegate.h"
#import "CSTUserToken.h"
#import "CSTNetworking.h"
#import "CSTDataManager.h"
#import "CSTWeatherManager.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTUmeng.h"
#import "UMSocial.h"
#import "CSTQQManager.h"
#import "CSTJPushManager.h"
#import "CSTRouter.h"
#import "CSTUserDefaults.h"
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [CSTUserDefaults registerUserDefalts];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [CSTRouter rootViewController];
    [self.window makeKeyAndVisible];
    
    
    [CSTRouter shareRouter];
    [[CSTWeatherManager shareManager] findCurrentLocation];
    [[CSTNetworkManager shareManager] enable];
    [CSTDataManager prepareLaunchData];
    [CSTUmeng configUmeng];
    [[CSTJPushManager shareManager] configJpushWithlaunchOptions:launchOptions];
    
//    [[CSTQQManager shareManager] showQQLoginWhenFirstUse];
    
    return YES;
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    NSDictionary *dic =[CSTQQManager dictionaryWithURLQueryString:[url host]];
    
    if ([dic[@"from"] isEqualToString:CSTQQHealth])
    {
        [[CSTQQManager shareManager]handleQQParameters:dic];
    }
    
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [CSTJPushManager registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [CSTJPushManager handleRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [CSTJPushManager handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.userInfo[@"title"]message:notification.alertBody delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
