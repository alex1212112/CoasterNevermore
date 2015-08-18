//
//  CSTHealthDrink.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/24.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTHealthDrink.h"
#import "NSDate+CSTTransformString.h"

@implementation CSTHealthDrink


+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"date" : @"DateTime",
             @"healthDays" : @"HealthDays"
             };
    
}

+ (NSValueTransformer *)dateJSONTransformer{

    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSDate cst_dateWithOriginString:value Format:@"yyyy-MM-dd'T'HH:mm:ss "];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [value cst_stringWithFormat:@"yyyy-MM-dd'T'HH:mm:ss "];
    }];
}

@end
