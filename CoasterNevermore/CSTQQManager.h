//
//  CSTQQHandler.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/7.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;

extern NSString *const CSTQQHealth;

@interface CSTQQManager : NSObject

+ (instancetype)shareManager;

+ (NSDictionary *)dictionaryWithURLQueryString:(NSString *)string;

- (void)handleQQParameters:(NSDictionary *)parameters;


- (RACSignal *)uploadUserDrinkWaterWithParameters:(NSDictionary *)parameters;

+ (NSDictionary *)upLoadDrinkToQQParametersWithDrinkArray:(NSArray *)array date:(NSDate *)date;




@end
