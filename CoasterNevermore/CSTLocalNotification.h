//
//  CSTLocalNotification.h
//  Coaster
//
//  Created by Ren Guohua on 14/11/5.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, CSTLocalNotificationSetting){
    
    CSTLocalNotificationSettingAlways,
    CSTLocalNotificationSettingUnderHydrationTime,
    CSTLocalNotificationSettingNever,
    
};

@interface CSTLocalNotification : NSObject

@property (nonatomic, assign) CSTLocalNotificationSetting localNotificationSetting;
@property (nonatomic, copy,readonly) NSArray *localNotificationSettingTypes;
@property (nonatomic, copy,readonly) NSArray *dates;


+ (instancetype)shareNotification;

+ (NSDate *)todayDateWithTimeOfOtherDate:(NSDate *)otherDate;

+ (void)configLocalNotifications;

- (void)setupNotifications;

- (void)removeNotifications;

- (void)removeNotificationWithTag:(NSInteger)tag;


@end
