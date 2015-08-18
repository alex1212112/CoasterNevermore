//
//  CSTMessage.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/10.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMessage.h"

@implementation CSTMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"date" : @"extras.datetime",
             @"fromUid" : @"extras.fromUid",
             @"toUid" : @"extras.toUid",
             @"type" : @"extras.type",
             @"content" : @"content"
             };
    
}

@end
