//
//  CSTBasicCellModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBasicCellModel.h"

@implementation CSTBasicCellModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"title" : @"title",
             @"detail" : @"detail",
             @"imageName" : @"imageName",
             };
}

@end
