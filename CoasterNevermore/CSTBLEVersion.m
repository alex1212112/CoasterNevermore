//
//  CSTBLEVersion.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBLEVersion.h"

@implementation CSTBLEVersion

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"version" : @"version",
             @"downloadAddressA" : @"downloadAddressA",
             @"downloadAddressB" : @"downloadAddressB"
             };

}
@end
