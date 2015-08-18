//
//  NSDate+CSTTransformString.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/23.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSInteger kCSTSecondsInOneDay;

@interface NSDate (CSTTransformString)


- (NSString *)cst_stringWithFormat:(NSString *)format;

+ (NSDate *)cst_dateWithOriginString:(NSString *)dateString Format:(NSString *)format;

- (NSInteger)cst_intervalDaysWithDate:(NSDate *)otherDate;

- (NSDate *)cst_dateWithIntervalDays:(NSInteger)days;

- (BOOL)cst_isTheSameDayWithDate:(NSDate *)date;


/**
 *  判断日期是不是今天
 *
 *  @return Yes－是 NO－不是
 */
- (BOOL)cst_isToday;

/**
 *  判断日期是不是周五
 *
 *  @return YES  NO
 */
- (BOOL)cst_isFriday;

/**
 *  判断日期是不是周末
 *
 *  @return YES NO
 */
- (BOOL)cst_isWeekend;

/**
 *  判断日期是不是周六
 *
 *  @return YES NO
 */
- (BOOL)cst_isSaturday;

/**
 *  判断日期是不是周日
 *
 *  @return YES NO
 */
- (BOOL)cst_isSunday;

/**
 *  判断该日时一周中的第几天
 *
 *  @return 一周中的第几天，周日为第一天
 */
- (NSInteger)cst_weekDay;

@end
