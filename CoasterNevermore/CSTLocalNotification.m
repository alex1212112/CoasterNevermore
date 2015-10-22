//
//  CSTLocalNotification.m
//  Coaster
//
//  Created by Ren Guohua on 14/11/5.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import "CSTLocalNotification.h"
#import "CSTDataManager.h"
#import "CSTLocalNotificationMessage.h"
#import "APService.h"
#import "CSTUserToken.h"


#import "NSDate+CSTTransformString.h"
#import "CSTDayPeriod+CSTExtention.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CSTLocalNotification ()

@property (nonatomic, copy,readwrite) NSArray *dates;
@property (nonatomic, copy,readwrite) NSArray *localNotificationSettingTypes;

@end

@implementation CSTLocalNotification

@synthesize localNotificationSetting = _localNotificationSetting;

static CSTLocalNotification *instance = nil;

+ (instancetype)shareNotification
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


- (id)init
{
    if (self = [super init])
    {
        [self configObservers];
    }
    return self;
}

- (NSArray *)dates
{
    if (!_dates)
    {
        NSDate *date = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
        [components setHour:9];
        [components setMinute:15];
        NSDate *date1 = [cal dateFromComponents:components];
        
        [components setHour:11];
        [components setMinute:15];
        NSDate *date2 = [cal dateFromComponents:components];
        
        [components setHour:13];
        [components setMinute:45];
        NSDate *date3 = [cal dateFromComponents:components];
        
        [components setHour:15];
        [components setMinute:45];
        NSDate *date4 = [cal dateFromComponents:components];
        
        [components setHour:17];
        [components setMinute:15];
        NSDate *date5 = [cal dateFromComponents:components];
        
        date1 = [self randomDateWithDate:date1];
        date2 = [self randomDateWithDate:date2];
        date3 = [self randomDateWithDate:date3];
        date4 = [self randomDateWithDate:date4];
        date5 = [self randomDateWithDate:date5];
        
        _dates = @[
                  date1,
                  date2,
                  date3,
                  date4,
                  date5
                 ];
    }
    
    return _dates;
    
}



- (NSDate*)randomDateWithDate:(NSDate *)date
{
    NSTimeInterval interval = arc4random() % (60 * 60 >> 1);
    return  [NSDate dateWithTimeInterval:interval sinceDate:date];
}


- (void)setupNotifications
{
    [self.dates enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {

        CSTLocalNotificationMessage *message = [CSTLocalNotificationMessage messageWithIndex:idx];
        NSString *body = message.zeroToFiftyMessage ?: @"小C发现主人已经有很长时间没有喝水了，喝点水休息下吧";

        [self creatNotificationWithBody:body title:@"小C温馨提醒" fireDate:date tag:idx];
        
    }];
}


- (void)creatNotificationWithBody:(NSString *)body title:(NSString *)title fireDate:(NSDate *)date tag:(NSInteger)tag
{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    //设置本地通知的触发时间（如果要立即触发，无需设置）
    
    if ([[NSDate date] cst_isSaturday])
    {
        notification.fireDate = [date dateByAddingTimeInterval:60 * 60 * 24 * 2];
    }
    else if([[NSDate date] cst_isSunday])
    {
        notification.fireDate = [date dateByAddingTimeInterval:60 * 60 * 24];
    }
    else
    {
        notification.fireDate = date;
    }
    notification.repeatInterval = [[NSDate date] cst_isFriday] ? NSCalendarUnitWeekOfYear : NSCalendarUnitDay;
    
    //设置本地通知的时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //设置通知的内容
    notification.alertBody = body;
    //设置通知动作按钮的标题
    notification.alertAction = @"查看";
    notification.applicationIconBadgeNumber = 1;
    
    //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
    NSDictionary *infoDic = @{@"title":title,@"content":body,@"tag":@(tag)};
    
    notification.userInfo = infoDic;
    //在规定的日期触发通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}



- (void)removeNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    long count;
    while ((count = [[[UIApplication sharedApplication] scheduledLocalNotifications] count]) > 0) {
        NSLog(@"Remaining notificaitons to cancel: %lu",(unsigned long)count);
        [NSThread sleepForTimeInterval:.01f];
    }
}


- (void)removeNotificationWithTag:(NSInteger)tag
{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for(UILocalNotification *notification in localNotifications)
    {
        if ([notification.userInfo[@"tag"] integerValue] == tag)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            [NSThread sleepForTimeInterval:.01f];
        }
    }
}

# pragma - mark  KVO Observer

- (void)configObservers{

    [RACObserve([CSTDataManager shareManager], todayUserDrinkWater) subscribeNext:^(id x) {
        
        [self p_resetLocalNotifications];
    }];
}



- (void)p_resetLocalNotifications
{
    if ([[NSDate date] cst_isWeekend])
    {
        [self removeNotifications];
        [self setupNotifications];
        return;
    }
    
    UILocalNotification *nearestNotification = [self nearestFutureNotification];
    if (!nearestNotification)
    {
        return;
    }
    NSLog(@"near == %@",nearestNotification.fireDate);
    NSDate *todayNearestFireDate = [CSTLocalNotification todayDateWithTimeOfOtherDate:nearestNotification.fireDate];
    
    CSTDayPeriod *nearestFireDateBelongPeriod = [CSTDayPeriod cst_periodWithDate:todayNearestFireDate];
    CSTDayPeriod *currentTimeBelongPeriod = [CSTDayPeriod cst_periodWithDate:[NSDate date]];
    
    if (currentTimeBelongPeriod.periodIndex != nearestFireDateBelongPeriod.periodIndex)
    {
        [self resetAllLocalNotificationsToDefault];
        return;
    }
    
    if ([CSTDataManager shareManager].userCurrentPeriodDrinkPercentState  == CSTUserCurrentPeriodDrinkPercentStateOverhundred)
    {
         NSLog(@"100%%");
        if (self.localNotificationSetting == CSTLocalNotificationSettingAlways)
        {
            [self resetLocalNotificationByOverFifityWithNotification:nearestNotification];
        }
        else
        {
            [self resetLocalNotificationToTomorrorWithNotification:nearestNotification];
        }
        return;
    }
    
    if ([CSTDataManager shareManager].userCurrentPeriodDrinkPercentState  == CSTUserCurrentPeriodDrinkPercentStateFifityToHundred)
    {
        NSLog(@"50%%-100%%");
        [self resetLocalNotificationByOverFifityWithNotification:nearestNotification];
        return;
    }
    
    if ([CSTDataManager shareManager].userCurrentPeriodDrinkPercentState  == CSTUserCurrentPeriodDrinkPercentStateZeroToFifty)
    {
         NSLog(@"0%%-50%%");
        [self resetAllLocalNotificationsToDefault];
        return;
    }
}


- (void)resetAllLocalNotificationsToDefault
{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray* mutableArray = [NSMutableArray  array];
    
    [localNotifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        
        [self resetLocalNotification:notification withCurrentPeroidPercentState:CSTUserCurrentPeriodDrinkPercentStateZeroToFifty];
        [mutableArray addObject:notification];
    }];
    
    [UIApplication sharedApplication].scheduledLocalNotifications = [NSArray arrayWithArray:mutableArray];
    
    [NSThread sleepForTimeInterval:.01f];
    
}

- (void)resetLocalNotificationToTomorrorWithNotification:(UILocalNotification *)notification
{
    
    [self resetLocalNotification:notification withCurrentPeroidPercentState:CSTUserCurrentPeriodDrinkPercentStateZeroToFifty];
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    NSDate *toadyFireTime = [CSTLocalNotification todayDateWithTimeOfOtherDate:notification.fireDate];
    
    NSDate *nextFireDate;
    
    if ([[NSDate date] cst_isFriday])
    {
        nextFireDate = [NSDate dateWithTimeInterval:60 * 60 * 24 * 3 sinceDate:toadyFireTime];
    }
    else
    {
        nextFireDate = [NSDate dateWithTimeInterval:60 * 60 * 24 sinceDate:toadyFireTime];
    }
    
    notification.fireDate = nextFireDate;
    
    [mutableArray addObject:notification];
    
    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    [array enumerateObjectsUsingBlock:^(UILocalNotification *obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj.userInfo[@"tag"] integerValue] != [notification.userInfo[@"tag"] integerValue])
        {
            [self resetLocalNotification:obj withCurrentPeroidPercentState:CSTUserCurrentPeriodDrinkPercentStateZeroToFifty];
            [mutableArray addObject:obj];
        }
    }];
    [UIApplication sharedApplication].scheduledLocalNotifications = [NSArray arrayWithArray:mutableArray];
    
    [NSThread sleepForTimeInterval:.01f];

}

- (void)resetLocalNotificationByOverFifityWithNotification:(UILocalNotification *)notification
{
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [self resetLocalNotification:notification withCurrentPeroidPercentState:[CSTDataManager shareManager].userCurrentPeriodDrinkPercentState];
    [mutableArray addObject:notification];
        
    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    [array enumerateObjectsUsingBlock:^(UILocalNotification *obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj.userInfo[@"tag"] integerValue] != [notification.userInfo[@"tag"] integerValue])
        {
            [self resetLocalNotification:obj withCurrentPeroidPercentState:CSTUserCurrentPeriodDrinkPercentStateZeroToFifty];
            [mutableArray addObject:obj];
        }
    }];
    [UIApplication sharedApplication].scheduledLocalNotifications = [NSArray arrayWithArray:mutableArray];
    
    [NSThread sleepForTimeInterval:.01f];

}


- (void)resetLocalNotification:(UILocalNotification *)notification withCurrentPeroidPercentState:(CSTUserCurrentPeriodDrinkPercentState)state
{
    
    CSTDayPeriod *period = [CSTDayPeriod cst_periodWithDate:notification.fireDate];
    
    NSInteger index = period.periodIndex;
    
    CSTLocalNotificationMessage *message = [CSTLocalNotificationMessage messageWithIndex:index];
    
    NSString *body = @"小C发现主人已经有很长时间没有喝水了，喝点水休息下吧";
    
    switch (state) {
        case CSTUserCurrentPeriodDrinkPercentStateZeroToFifty:
            {
                body = message.zeroToFiftyMessage;
               // notification.repeatInterval = NSCalendarUnitDay;
                notification.repeatInterval = [[NSDate date] cst_isFriday] ? NSCalendarUnitWeekOfYear : NSCalendarUnitDay;
                break;
            }
        case CSTUserCurrentPeriodDrinkPercentStateFifityToHundred:
            {
                body = message.fiftyToHundredMessage;
                notification.repeatInterval = NSCalendarUnitYear;
               // notification.repeatInterval = [[NSDate date] gh_isFriday] ? NSCalendarUnitYear : NSCalendarUnitDay;
                break;
            }
        case CSTUserCurrentPeriodDrinkPercentStateOverhundred:
            {
                body = message.overHundredMessage;
                notification.repeatInterval = NSCalendarUnitYear;
                //notification.repeatInterval = [[NSDate date] gh_isFriday] ? NSCalendarUnitYear : NSCalendarUnitDay;
                break;
            }
            
        default:
            break;
    }
    notification.alertBody = body;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:notification.userInfo];
    dic[@"content"] = body;
    
    notification.userInfo = [NSDictionary dictionaryWithDictionary:dic];
   
}


- (UILocalNotification *)nearestFutureNotification
{
    __block UILocalNotification *notification;
    __block NSDate *nearestFireDate;
    
    NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    NSArray *dates = [notifications valueForKeyPath:@"fireDate"];
    
    if ([dates count] == 5)
    {
        self.dates = dates;
    }
    
    [self.dates enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
        
        NSDate *todaysFlagTime = [CSTLocalNotification todayDateWithTimeOfOtherDate:date];

        if ([todaysFlagTime timeIntervalSinceNow] > 0)
        {
            nearestFireDate = todaysFlagTime;
            *stop = YES;
        }
    }];
    
    if (nearestFireDate)
    {
        [[[UIApplication sharedApplication] scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *theNotification, NSUInteger idx, BOOL *stop) {
            
            NSDate *todayFireTime = [CSTLocalNotification todayDateWithTimeOfOtherDate:theNotification.fireDate];

            if ([todayFireTime isEqualToDate:nearestFireDate])
            {
                notification = theNotification;
                *stop = YES;
            }
        }];
    }
    return notification;
}



+ (NSDate *)todayDateWithTimeOfOtherDate:(NSDate *)otherDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:otherDate];
    
    NSDateComponents *today = [cal components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    
    [components setDay: [today day]];
    [components setMonth: [today month]];
    [components setYear: [today year]];
    
    return [cal dateFromComponents:components];
}


- (CSTLocalNotificationSetting)localNotificationSetting
{
    if (!_localNotificationSetting)
    {
        _localNotificationSetting = (CSTLocalNotificationSetting)[[[NSUserDefaults standardUserDefaults] objectForKey:@"localNotification"] integerValue];
    }
    
    return _localNotificationSetting;
}

- (void)setLocalNotificationSetting:(CSTLocalNotificationSetting)localNotificationSetting
{
    if (_localNotificationSetting != localNotificationSetting)
    {
        _localNotificationSetting = localNotificationSetting;
        [[NSUserDefaults standardUserDefaults] setObject:@(localNotificationSetting) forKey:@"localNotification"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (localNotificationSetting == CSTLocalNotificationSettingNever)
        {
            [self removeNotifications];
        }
        else
        {
            [self removeNotifications];
            [self setupNotifications];
        }
    }
}

- (NSArray *)localNotificationSettingTypes
{
    if (!_localNotificationSettingTypes)
    {
        _localNotificationSettingTypes = @[@(CSTLocalNotificationSettingAlways),
                                       @(CSTLocalNotificationSettingUnderHydrationTime),
                                           @(CSTLocalNotificationSettingNever),
                                           ];
    }
    
    return _localNotificationSettingTypes;

}

+ (void)configLocalNotifications
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"localNotification"] isEqual:@(CSTLocalNotificationSettingNever)])
    {
        [[CSTLocalNotification shareNotification] removeNotifications];
        [[CSTLocalNotification shareNotification] setupNotifications];
    }
    else
    {
        [[CSTLocalNotification shareNotification] removeNotifications];
    }
}



@end
