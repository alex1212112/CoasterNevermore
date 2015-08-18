//
//  CSTAQI.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTAQI.h"

@implementation CSTAQI
+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"city" : @"city",
             @"time" : @"time",
             @"level" : @"level",
             @"core" : @"core",
             @"aqi" : @"aqi",
             };
}


@end
