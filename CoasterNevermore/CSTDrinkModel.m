//
//  CSTDrinkModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/10.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDrinkModel.h"
#import "NSDate+CSTTransformString.h"

@interface CSTDrinkModel ()

@property (nonatomic, strong) NSDate *uppercaseLetterKeyDate;
@property (nonatomic, strong) NSDate *lowercaseLetterKeyDate;
@end

@implementation CSTDrinkModel

#pragma mark - Life cycle

- (instancetype)initWithDate:(NSDate *)date weight:(NSNumber *)weight{

    if (self = [super init]) {
        
        _uppercaseLetterKeyDate = date;
        _weight = weight;
    }
    return self;
}

#pragma mark - Mantle method
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"lowercaseLetterKeyDate" : @"datetime",
             @"uppercaseLetterKeyDate" : @"DateTime",
             @"weight" : @"Weight",
             };
}

+ (NSValueTransformer *)uppercaseLetterKeyDateJSONTransformer{

    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return  [NSDate cst_dateWithOriginString:value Format:@"yyyy-MM-dd'T'HH:mm:ss"];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [value cst_stringWithFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }];
}

+ (NSValueTransformer *)lowercaseLetterKeyDateJSONTransformer{
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return  [NSDate cst_dateWithOriginString:value Format:@"yyyy-MM-dd HH:mm:ss"];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [value cst_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    }];
}

#pragma mark - Private method


#pragma mark - property dependence

- (NSDate *)date{
    
    if (self.lowercaseLetterKeyDate) {
        
        return self.lowercaseLetterKeyDate;
    }
    return self.uppercaseLetterKeyDate;
}

+ (NSSet *)keyPathsForValuesAffectingUsername
{
    return [NSSet setWithObjects:@"lowercaseLetterKeyDate",@"uppercaseLetterKeyDate", nil];
}

@end
