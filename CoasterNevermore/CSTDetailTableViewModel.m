//
//  CSTDetailTableViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/22.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDetailTableViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTDataManager.h"
#import "CSTHealthRank.h"
#import "CSTHealthDrink.h"

@implementation CSTDetailTableViewModel

#pragma mark - Life cycle

- (instancetype)init{
    
    if (self = [super init]) {
        
        [self p_configObserverWithHistoryDrink];
        [self p_configObserverWithUserRank];
        [self p_configObserverWithUserDrink];
    }
    return self;
}

#pragma mark - Observers
- (void)p_configObserverWithHistoryDrink{

    RAC(self,historyTotalDrink) = [RACObserve([CSTDataManager shareManager], historyUserDrinkWater) map:^id(id value) {
        
        return [NSString stringWithFormat:@"%ldml",(long)[[value valueForKeyPath:@"@sum.weight"] floatValue] / 1000];
    }];
    
    RAC(self,deviceUsedDays) = [RACObserve([CSTDataManager shareManager], historyUserDrinkWater) map:^id(id value) {
        
        return [NSString stringWithFormat:@"%ld天",(long)[value count]];
    }];

}

- (void)p_configObserverWithUserRank{
    
    RAC(self,healthIndex) = [RACObserve([CSTDataManager shareManager], userHealthRank.score) map:^id(id value) {
        
        return [NSString stringWithFormat:@"%ld",(long)[value integerValue]];
    }];
    
    RAC(self,rankString) = [RACObserve([CSTDataManager shareManager], userHealthRank.rank) map:^id(id value) {
        
        return [NSString stringWithFormat:@"%ld",(long)[value integerValue]];
    }];
}

- (void)p_configObserverWithUserDrink{

    RAC(self,drinkLevel) = [RACObserve([CSTDataManager shareManager], userHealthDrink) map:^id(id value) {
        
        return [NSString stringWithFormat:@"%ld",(long)[[value valueForKeyPath:@"@sum.healthDays"] integerValue]];
    }];
}

@end
