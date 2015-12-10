//
//  CSTDetailDataViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/22.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDetailDataViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTAPIBaseManager.h"
#import "NSDate+CSTTransformString.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import <Mantle/Mantle.h>
#import "CSTDrinkModel.h"
#import "CSTDataManager.h"
#import "RACSignal+CSTModel.h"
#import "CSTHealthRank.h"
#import "CSTHealthDrink.h"
#import "NSArray+CSTExtention.h"
#import "CSTDrinkModel.h"

#import "CSTDayPeriod+CSTExtention.h"

NSInteger const kShowDatesCount = 13;


@implementation CSTDetailDataViewModel
#pragma mark - Life cycle
- (instancetype)init{
    
    if (self = [super init]) {
        
        [self p_configObserverWithHistoryUserDrink];
        [self p_configObserverWithHistoryUserDetail];
        [self p_configObserverWithHistoryUserSuggest];
    }
    return self;
}



#pragma mark - Observers
- (void)p_configObserverWithHistoryUserDrink{

    @weakify(self);
    [RACObserve([CSTDataManager shareManager], historyUserDrinkWater) subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.historyDrinkArray = [self p_arrayWithHistoryDrinkArray:x];
        
        self.historyAverageDrink = [self p_averageDrinkWithHistoryDrinkArray:self.historyDrinkArray];
        self.historyDrinkShowDateArray = [self p_showDateArrayWithHistoryDrinkArray:self.historyDrinkArray];
    }];
}

- (void)p_configObserverWithHistoryUserDetail{
    
    RAC(self, historyDrinkDetail) = RACObserve([CSTDataManager shareManager], historyUserDrinkDetail) ;
}

- (void)p_configObserverWithHistoryUserSuggest{

    RAC(self, historySuggestDrink) = RACObserve([CSTDataManager shareManager], historyUserSuggestWater);
}



#pragma mark - Public method

- (void)refreshCurrentPageData{

    
    [[self p_historyUserDrinkSignal] subscribeNext:^(id x) {
        
    }];
    
    [[self p_userHealthDrinkDaysSignal] subscribeNext:^(id x) {
        
        
    }];
    
    [[self p_userHealthRankSignal] subscribeNext:^(id x) {
        
    }];
    
    
    [[self p_historyUserDrinkDetailSignal] subscribeNext:^(id x) {
        
    }];
    
    [[self p_historyUserSuggestSignal] subscribeNext:^(id x) {
        
    }];
    
//    [[[self p_uploadHealthDrinkAPIManager] fetchDataSignal] subscribeNext:^(id x) {
//        
//    }];
}

- (NSString *)todayUserDrinkShareText{

    NSInteger suggest = [CSTDataManager shareManager].todayUserSuggestWater;
    if (suggest == 0) {
        suggest = 2000;
    };
    CGFloat drink = [[[CSTDataManager shareManager].todayUserDrinkWater valueForKeyPath:@"@sum.weight"] integerValue] / 1000.0;
    
    NSInteger percent = drink / (CGFloat)suggest;
    
    return [NSString stringWithFormat:@"我今天的饮水计划已经完成了%ld%%啦~",(long)percent];
}

- (NSDate *)defaultSelectedDateWithArry:(NSArray *)array{
    
    NSInteger index = [self defaultSelectedIndexWithArry:array];
    return [array[index] valueForKey:@"date"];
}

- (NSInteger)defaultSelectedIndexWithArry:(NSArray *)array{
    
    
    if ([array count] == 0) {
        
        return 0;
    }else{
        return [array count] - 1;
    }
    
//    if ([array count] == 0) {
//        
//        return 0;
//    }
//    if ([array count] <= 7) {
//        
//        return  [array count] / 2 + 1;
//    }
//    
//    return [array count] - 4;
}

- (NSDate *)defaultSelectedDateWithDetailArry:(NSArray *)array{

    NSDate *firstDate = [[array firstObject] valueForKey:@"date"];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:firstDate];
    firstDate = [cal dateFromComponents:components];
    
    NSInteger intervalDays = [firstDate cst_intervalDaysWithDate:[NSDate date]];

    if (intervalDays == 0) {
        
        return firstDate;
    }
    
    return  [firstDate cst_dateWithIntervalDays: intervalDays - 1];
//    if (intervalDays <= 7) {
//        
//        return  [firstDate cst_dateWithIntervalDays: intervalDays / 2 + 1];
//    }
//    
//    return  [firstDate cst_dateWithIntervalDays: intervalDays - 4];
}


- (NSArray *)segmentArrayWithDetail:(NSArray *)detailArray inDate:(NSDate *)date{

    NSArray *selectedArray = [detailArray linq_where:^BOOL(id item) {
        
        NSDate *itemDate = [item valueForKey:@"date"];
        return [itemDate cst_isTheSameDayWithDate:date];
    }];

    NSArray *timePointDateArray = [CSTDayPeriod cst_timePointDateArrayInDate:date];
    NSMutableArray *segmentArray = [NSMutableArray array];
    
    [timePointDateArray enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
        
        NSDate *nextDate = timePointDateArray[idx + 1];
        NSNumber *segmentDrinkWeight = [CSTDayPeriod cst_drinkBetweenDate:date andDate:nextDate withDrinkArray:selectedArray] ?: @(0);
        
        [segmentArray addObject:segmentDrinkWeight];
        
        if (idx == [timePointDateArray count] - 2)
        {
            *stop = YES;
        }
    }];
    
    return [NSArray arrayWithArray:segmentArray];
}
- (NSArray *)segmentArraywithSuggests:(NSArray *)suggests inDate:(NSDate *)date{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@",date];
    NSArray *filteredArray = [suggests filteredArrayUsingPredicate:predicate];

    NSNumber *weight = [[filteredArray firstObject] valueForKey:@"weight"];
    
    if (!weight) {
        
        weight = @2000;
    }
    
    return  [[CSTDayPeriod cst_modulus] linq_select:^id(id item) {
       
        return @([weight doubleValue] * [item doubleValue]);
    }];
}

#pragma mark - Private method


- (CGFloat)p_averageDrinkWithHistoryDrinkArray:(NSArray *)drinkArray{

    return [[drinkArray valueForKeyPath:@"@sum.weight"] doubleValue] / [drinkArray count];
}

- (NSArray *)p_arrayWithHistoryDrinkArray:(NSArray *)historyDrinkArray{

    if ([historyDrinkArray count] == 0) {
        
        return nil;
    }
    
    NSDate *firstDate = [[historyDrinkArray firstObject] valueForKey:@"date"];
    
    NSInteger intervalDays = [firstDate cst_intervalDaysWithDate:[NSDate date]];

    NSDate *beginDate = nil;
    if (intervalDays <  7)
    {
        beginDate = [[NSDate date] cst_dateWithIntervalDays: -7];
    }
    else
    {
        beginDate = firstDate;
    }
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSInteger drinkIndex = 0;
    for (NSDate *date = beginDate; [date compare:[NSDate date]]  == NSOrderedSame || [date compare:[NSDate date]] == NSOrderedAscending; date = [date cst_dateWithIntervalDays:1])
    {
        if (drinkIndex < [historyDrinkArray count])
        {
            CSTDrinkModel *drink = historyDrinkArray[drinkIndex];
            if ([drink.date cst_isTheSameDayWithDate:date])
            {
                [mutableArray addObject:drink];
                drinkIndex ++;
            }else{
            
                [mutableArray addObject:[[CSTDrinkModel alloc] initWithDate:date weight:@0]];
            }
        }else{
            
                [mutableArray addObject:[[CSTDrinkModel alloc] initWithDate:date weight:@0]];
        }
    }
    return [NSArray arrayWithArray:mutableArray];
}

- (NSArray *)p_showDateArrayWithHistoryDrinkArray:(NSArray *)drinkArray{


    NSArray *dateArray = [drinkArray count] == 0 ? @[[NSDate date]] :  [drinkArray valueForKeyPath:@"date"];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSDate *firstDate = [dateArray firstObject];
    NSDate *beginDate = nil;
    
    beginDate = [firstDate cst_dateWithIntervalDays: -3];
    
    for (NSInteger dayIndex = 0; dayIndex < 3 ; dayIndex ++) {
        
        [mutableArray addObject:[beginDate cst_dateWithIntervalDays:dayIndex]];
    };
    
    [mutableArray addObjectsFromArray:dateArray];
    
    NSDate *lastDate = [dateArray lastObject];
    
    for (NSInteger dayIndex = 0; dayIndex < 3 ; dayIndex ++) {
        
        [mutableArray addObject:[lastDate cst_dateWithIntervalDays:dayIndex + 1]];
    };
    
    return [NSArray arrayWithArray:mutableArray];
}


#pragma mark - User history drink by day

- (RACSignal *)p_historyUserDrinkSignal{

    return [[[[[[self p_historyUserDrinkWaterAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
        return [self p_transformToModelArraySignalWithDicArray:value[@"Drinks"]];
        
    }] map:^id(id value) {
        
        return [value cst_distinctAndSortResultWithKeyPath:@"date"];
    }] doNext:^(id x) {
        
        [CSTDataManager shareManager].historyUserDrinkWater = x;

    }];

}

- (CSTUserDrinkWaterAPIManager *)p_historyUserDrinkWaterAPIManager{

    CSTUserDrinkWaterAPIManager *apiManager = [[CSTUserDrinkWaterAPIManager alloc] init];
    apiManager.parameters = [self p_historyUserDrinkWaterParameters];
    
    return apiManager;
}

- (NSDictionary *)p_historyUserDrinkWaterParameters{

    NSString *today = [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"];
    NSString *start = @"2014-10-01";
    
    return  @{@"startDate" : start,
              @"endDate" : today,
              @"type" : @2
              };
}


- (RACSignal *)p_transformToModelArraySignalWithDicArray:(NSArray *)dics{
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSArray *modelArray = [dics linq_select:^id(id item) {
            
            return [MTLJSONAdapter modelOfClass:[CSTDrinkModel class] fromJSONDictionary:item error:nil];
        }];
        
        [subscriber sendNext:modelArray];
        [subscriber sendCompleted];
        return nil;
    }];
}


#pragma mark - User history detail (by date and time)


- (RACSignal *)p_historyUserDrinkDetailSignal{
    
    return [[[[[[self p_historyUserDrinkDetailAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
        return [self p_transformToModelArraySignalWithDicArray:value[@"Drinks"]];
        
    }] map:^id(id value) {
        
        return [value cst_distinctAndSortResultWithKeyPath:@"date"];
    }] doNext:^(id x) {
        
        [CSTDataManager shareManager].historyUserDrinkDetail = x;
    }];
}

- (CSTUserDrinkWaterAPIManager *)p_historyUserDrinkDetailAPIManager{
    
    CSTUserDrinkWaterAPIManager *apiManager = [[CSTUserDrinkWaterAPIManager alloc] init];
    apiManager.parameters = [self p_historyUserDrinkDetailParameters];
    
    return apiManager;
}

- (NSDictionary *)p_historyUserDrinkDetailParameters{
    
    NSString *today = [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"];
    NSString *start = @"2014-10-01";
    
    return  @{@"startDate" : start,
              @"endDate" : today,
              @"type" : @1
              };
}

#pragma mark - User health drink data

- (RACSignal *)p_userHealthDrinkDaysSignal{

    return [[[[[self p_healthDrinkAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
        NSArray *array = value[@"Summary"];
        
        return  [RACSignal cst_transformToModelArraySignalWithModelClass:[CSTHealthDrink class] dicArray:array];
        
    }] doNext:^(id x) {
        
        [CSTDataManager shareManager].userHealthDrink = x;
    }];
}

- (RACSignal *)p_userHealthRankSignal{

    return [[[[[self p_healthRankAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
        return [RACSignal cst_transformSignalWithModelClass:[CSTHealthRank class] dictionary:value];
    }] doNext:^(id x) {
        
        [CSTDataManager shareManager].userHealthRank = x;
    }];
}

- (CSTHealthDrinkAPIManager *)p_healthDrinkAPIManager{

    CSTHealthDrinkAPIManager *apiManager = [[CSTHealthDrinkAPIManager alloc] init];
    
    apiManager.parameters =  [self p_userHealthDrinkDaysParameters];
    return apiManager;
}


- (NSDictionary *)p_userHealthDrinkDaysParameters{

    NSString *today = [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"];
    NSString *start = @"2014-10-01";
    
    return  @{@"startDate" : start,
              @"endDate" : today,
              @"type" : @4
              };
}


- (CSTHealthRankAPIManager *)p_healthRankAPIManager{
    
    return [[CSTHealthRankAPIManager alloc] init];
}


//- (CSTUploadHealthDrinkAPIManager *)p_uploadHealthDrinkAPIManager{
//
//    CSTUploadHealthDrinkAPIManager *apiManager = [[CSTUploadHealthDrinkAPIManager alloc] init];
//    
//    apiManager.parameters = @{@"datetime" : @"2015-07-12 12:25:21"};
//    
//    return apiManager;
//}

#pragma mark - User history suggest drink


- (RACSignal *)p_historyUserSuggestSignal{

    return [[[[[self p_historyUserSuggestAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        return [self p_transformToModelArraySignalWithDicArray:value[@"Drinks"]];
        
    }] doNext:^(id x) {
        
        [CSTDataManager shareManager].historyUserSuggestWater = x;
    }];
    
}

- (CSTUserSuggestWaterAPIManager *)p_historyUserSuggestAPIManager{

    
    CSTUserSuggestWaterAPIManager *apiManager = [[CSTUserSuggestWaterAPIManager alloc] init];
    
    apiManager.parameters = [self p_historyUserSuggestParameters];
    
    return apiManager;

}

- (NSDictionary *)p_historyUserSuggestParameters{

    return @{@"startDate" : @"2014-10-01",
             @"endDate" : [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"]};
}

#pragma mark - Setters and getters
- (NSArray *)barchartXStrings{
    if (!_barchartXStrings) {
        _barchartXStrings = @[@"清晨", @"上午", @"中午", @"下午",@"傍晚",@"晚上"];
    }
    return _barchartXStrings;
}

- (NSArray *)barchartXTicks{
    if (!_barchartXTicks) {
        
        _barchartXTicks = @[@1.5, @4.5, @7.5, @10.5, @13.5, @16.5];
    }
    return _barchartXTicks;
}

@end
