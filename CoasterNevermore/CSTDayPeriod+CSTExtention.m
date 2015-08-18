//
//  CSTDayPeriod+CSTExtention.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDataManager.h"

#import "CSTDayPeriod+CSTExtention.h"
#import "NSDate+CSTTransformString.h"


@implementation CSTDayPeriod (CSTExtention)


+ (CSTDayPeriod *)cst_periodWithDate:(NSDate *)date
{
    NSArray *datePointArray = [CSTDayPeriod cst_timePointDateArrayInDate:date];
    
    __block NSDate *startDate;
    __block NSDate *endDate;
    __block NSInteger periodIndex;
    
    [datePointArray enumerateObjectsUsingBlock:^(NSDate *dateTime, NSUInteger idx, BOOL *stop) {
        
        NSDate *dateTimeMax = datePointArray[idx +1];
        
        if ([[NSPredicate predicateWithFormat:@"((self >= %@) AND (self < %@))",dateTime,dateTimeMax] evaluateWithObject:date])
        {
            startDate = dateTime;
            endDate = datePointArray[idx +1];
            periodIndex = idx;
            *stop = YES;
        }
        if (idx == [datePointArray count] - 2)
        {
            *stop = YES;
        }
    }];
    
    if (startDate && endDate)
    {
        return [[CSTDayPeriod alloc] initWithStartTime:startDate endTime:endDate periodIndex:periodIndex];
    }
    
    return nil;
}

+ (NSArray *)cst_timePointDateArrayInDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSArray *timeStringArray = [CSTDayPeriod cst_timePointStringArrayInOneDay];
    
    NSString *prefix = [[date cst_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"]substringToIndex:10];
    
    NSMutableArray *dateMutableArray = [NSMutableArray array];
    
    [timeStringArray enumerateObjectsUsingBlock:^(NSString *timeString, NSUInteger idx, BOOL *stop) {
        NSDate *dateTime = [NSDate cst_dateWithOriginString:[prefix stringByAppendingString:timeString] Format:@"yyyy-MM-dd HH:mm:ss"];
        [dateMutableArray addObject:dateTime];
    }];
    
    return [NSArray arrayWithArray:dateMutableArray];
}

+ (NSNumber *)cst_drinkBetweenDate:(NSDate *)firstDate andDate:(NSDate *)secondDate withDrinkArray:(NSArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((date >= %@) AND (date < %@))",firstDate,secondDate];
    
    NSArray *drinkDataArray = [array filteredArrayUsingPredicate:predicate];
    
    return [drinkDataArray valueForKeyPath:@"@sum.weight"];
}

+ (NSInteger )cst_drinkInPeriod:(CSTDayPeriod *)period withDrinkArray:(NSArray *)drinkArray{
    NSDate *begin = period.startTime;
    NSDate *end = period.endTime;

    return [[CSTDayPeriod cst_drinkBetweenDate:begin andDate:end withDrinkArray:drinkArray] integerValue];
}

+ (CGFloat)cst_drinkPercentWithDrinkArray:(NSArray *)drinkArray suggest:(NSInteger)suggest inPeriod:(CSTDayPeriod *)period
{
    NSInteger currentPeriodDrink = [CSTDayPeriod cst_drinkInPeriod:period withDrinkArray:drinkArray];
    if (suggest == 0) {
        suggest = 2000;
    }

    return  (CGFloat)currentPeriodDrink / ((CGFloat)suggest * [[CSTDayPeriod cst_modulus][period.periodIndex] floatValue]) / 1000.0;
}


+ (NSArray *)cst_timePointStringArrayInOneDay
{
    return   @[@" 00:00:00",
               @" 10:00:00",
               @" 12:00:00",
               @" 15:00:00",
               @" 16:30:00",
               @" 18:00:00",
               @" 23:59:59"
               ];
}

+ (NSArray *)cst_modulus
{
    return  @[@0.10f,
              @0.25f,
              @0.20f,
              @0.30f,
              @0.10f,
              @0.05f
              ];
}






@end
