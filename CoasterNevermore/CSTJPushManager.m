//
//  CSTJPushManager.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/10.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTJPushManager.h"
#import "JPUSHService.h"
#import "CSTMessage.h"
#import "CSTDataManager.h"
#import "DXAlertView.h"

#import <Mantle/Mantle.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <UserNotifications/UserNotifications.h>


@import UIKit;

@interface CSTJPushManager ()<JPUSHRegisterDelegate>

@end

@implementation CSTJPushManager

#pragma mark - Public method

+ (instancetype)shareManager
{
    static CSTJPushManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)configJpushWithlaunchOptions:(NSDictionary *)launchOptions
{
//    [APService setupWithOption:launchOptions];
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    [JPUSHService setupWithOption:launchOptions appKey:@"7fa7f247619f0156b1761172" channel:@"App Store" apsForProduction:YES advertisingIdentifier:nil];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(p_networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}


+ (void)handleRemoteNotification:(NSDictionary *)userInfo{

    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

+ (void)registerDeviceToken:(NSData *)deviceToken{

    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

+ (void)configJpushAlias:(NSString *)string{

    if (!string) {
        [JPUSHService setAlias:@"" callbackSelector:nil object:nil];
        return;
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [JPUSHService setAlias:string callbackSelector:nil object:nil];
    
}

#pragma mark - JPUSHRegisterDelegate
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}



#pragma mark - Private method
- (void)p_networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    CSTMessage *message = [MTLJSONAdapter modelOfClass:[CSTMessage class] fromJSONDictionary:userInfo error:nil];
    
    if ([message.type integerValue] == 1) {
        
        [[[CSTDataManager refreshRelationshipSignal] flattenMap:^RACStream *(id value) {
            
            return [CSTDataManager  refreshMateProfileSignalWithRelationship:value];
            
        }] subscribeNext:^(id x) {
            
        }];
    }else if ([message.type integerValue] == 2 || [message.type integerValue] == 3 || [message.type integerValue] == 4){
    
        [DXAlertView showAlertWithTitle:nil contentText:message.content leftButtonTitle:nil rightButtonTitle:@"确定"];
        
        [[[CSTDataManager refreshRelationshipSignal] flattenMap:^RACStream *(id value) {
            
            return [CSTDataManager  refreshMateProfileSignalWithRelationship:value];
            
        }] subscribeNext:^(id x) {
            
        }];
        
    }else if ([message.type integerValue] == 5){
    
        [DXAlertView showAlertWithTitle:nil contentText:message.content leftButtonTitle:nil rightButtonTitle:@"确定"];
    }

}

@end
