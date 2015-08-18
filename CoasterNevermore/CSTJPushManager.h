//
//  CSTJPushManager.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/10.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;

@interface CSTJPushManager : NSObject

+ (instancetype)shareManager;

+ (void)handleRemoteNotification:(NSDictionary *)userInfo;

+ (void)registerDeviceToken:(NSData *)deviceToken;

- (void)configJpushWithlaunchOptions:(NSDictionary *)launchOptions;

+ (void)configJpushAlias:(NSString *)string;

@end
