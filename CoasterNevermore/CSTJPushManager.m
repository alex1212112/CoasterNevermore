//
//  CSTJPushManager.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/10.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTJPushManager.h"
#import "APService.h"
#import "CSTMessage.h"
#import "CSTDataManager.h"
#import "DXAlertView.h"

#import <Mantle/Mantle.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@import UIKit;

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
    [APService setupWithOption:launchOptions];
    [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                   UIUserNotificationTypeSound |
                                                   UIUserNotificationTypeAlert)
                                       categories:nil];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(p_networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}


+ (void)handleRemoteNotification:(NSDictionary *)userInfo{

    [APService handleRemoteNotification:userInfo];
}

+ (void)registerDeviceToken:(NSData *)deviceToken{

     [APService registerDeviceToken:deviceToken];
}

+ (void)configJpushAlias:(NSString *)string{

    if (!string) {
        [APService setAlias:@"" callbackSelector:nil object:nil];
        return;
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [APService setAlias:string callbackSelector:nil object:nil];
    
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
