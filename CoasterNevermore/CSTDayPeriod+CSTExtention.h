//
//  CSTDayPeriod+CSTExtention.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import UIKit;
#import "CSTDayPeriod.h"

@interface CSTDayPeriod (CSTExtention)


+ (NSArray *)cst_timePointStringArrayInOneDay;

+ (NSArray *)cst_timePointDateArrayInDate:(NSDate *)date;

+ (NSArray *)cst_modulus;

+ (CSTDayPeriod *)cst_periodWithDate:(NSDate *)date;

+ (NSNumber *)cst_drinkBetweenDate:(NSDate *)firstDate andDate:(NSDate *)secondDate withDrinkArray:(NSArray *)array;

+ (CGFloat)cst_drinkPercentWithDrinkArray:(NSArray *)drinkArray suggest:(NSInteger)suggest inPeriod:(CSTDayPeriod *)period;

//+ (NSNumber *)cst_currentPeriodDrinkWithTodayArray:(NSArray *)todayDrinkArray;





@end
