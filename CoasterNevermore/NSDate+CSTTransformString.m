//
//  NSDate+CSTTransformString.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/23.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "NSDate+CSTTransformString.h"

const NSInteger kCSTSecondsInOneDay = 60 * 60 * 24;

@implementation NSDate (CSTTransformString)

- (NSString *)cst_stringWithFormat:(NSString *)format{

    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    
    [dateFormat setDateFormat:format];//设定时间格式,这里可以设置成自己需要的格式
    
    NSString *currentDateStr = [dateFormat stringFromDate:self];
    return currentDateStr;
}

+ (NSDate *)cst_dateWithOriginString:(NSString *)dateString Format:(NSString *)format{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    
    [dateFormat setDateFormat:format];//设定时间格式,这里可以设置成自己需要的格式
    
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}

- (NSInteger)cst_intervalDaysWithDate:(NSDate *)otherDate{

    NSCalendar *cal = [NSCalendar currentCalendar];

    return [cal components:NSCalendarUnitDay fromDate:self toDate:otherDate options:NSCalendarWrapComponents].day;
}

- (NSDate *)cst_dateWithIntervalDays:(NSInteger)days{

    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponentsAsTimeQantum = [[NSDateComponents alloc] init];
    [dateComponentsAsTimeQantum setDay:days];
    
    //  在当前历法下，获取days天后的时间点
  return [cal dateByAddingComponents:dateComponentsAsTimeQantum toDate:self options:0];
}

- (BOOL)cst_isTheSameDayWithDate:(NSDate *)date
{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    if ([cal respondsToSelector:@selector(isDate:inSameDayAsDate:)])
    {
        if ([cal isDate:self inSameDayAsDate:date])
        {
            return YES;
        }
        return NO;
    }
    
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
    NSDate *date1 = [cal dateFromComponents:components];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *date2 = [cal dateFromComponents:components];
    
    
    if([date1 isEqualToDate:date2])
    {
        return YES;
    }
    
    return NO;
}



- (BOOL)cst_isToday
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    if ([cal respondsToSelector:@selector(isDateInToday:)])
    {
        if ([cal isDateInToday:self])
        {
            return YES;
        }
        return NO;
    }
    
    return [self cst_isTheSameDayWithDate:[NSDate date]];
}


- (BOOL)cst_isFriday
{
    if (self.cst_weekDay == 6)
    {
        return YES;
    }
    return NO;
}


- (NSInteger)cst_weekDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitWeekday) fromDate:self];
    return components.weekday;
}

- (BOOL)cst_isSaturday
{
    if (self.cst_weekDay == 7)
    {
        return YES;
    }
    return NO;
}

- (BOOL)cst_isSunday
{
    
    if (self.cst_weekDay == 1)
    {
        return YES;
    }
    return NO;
}


- (BOOL)cst_isWeekend
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    if ([cal respondsToSelector:@selector(isDateInWeekend:)])
    {
        if ([cal isDateInWeekend:self])
        {
            return YES;
        }
        return NO;
    }
    
    if (self.cst_weekDay == 7 || self.cst_weekDay == 1)
    {
        return YES;
    }
    return NO;
}

@end
