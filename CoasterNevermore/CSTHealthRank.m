//
//  CSTHealthRank.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/23.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTHealthRank.h"

@implementation CSTHealthRank

+ (NSDictionary *)JSONKeyPathsByPropertyKey{

    return @{
             @"rank" : @"Rank",
             @"score" : @"Score"
            };
    
}

@end
