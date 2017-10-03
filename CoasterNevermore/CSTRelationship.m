//
//  CSTRelationship.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/9.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTRelationship.h"

@implementation CSTRelationship

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"status" : @"status",
             @"fromUid" : @"fromUid",
             @"toUid" : @"toUid",
             @"startTime" : @"startTime",
             @"fromNickname" : @"fromNickname",
             @"toNickname" : @"toNickname"
             };
}

@end
