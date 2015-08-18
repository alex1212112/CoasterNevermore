//
//  CSTDayPeriod.m
//  Coaster
//
//  Created by Ren Guohua on 15/5/23.
//  Copyright (c) 2015年 ghren. All rights reserved.
//

#import "CSTDayPeriod.h"

@implementation CSTDayPeriod

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"startTime" : @"startTime",
             @"endTime" : @"endTime",
             @"periodIndex" : @"periodIndex"
             };
}

- (instancetype)initWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime periodIndex:(NSInteger)index
{
    if (self = [super init])
    {
        _startTime = startTime;
        _endTime = endTime;
        _periodIndex = index;
    }
    
    return self;
}

@end
