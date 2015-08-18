//
//  CSTUserDefaults.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserDefaults.h"
#import "CSTLocalNotification.h"

@implementation CSTUserDefaults

+ (void)registerUserDefalts
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"firstUse":@YES,@"localNotification":@(CSTLocalNotificationSettingAlways)}];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
