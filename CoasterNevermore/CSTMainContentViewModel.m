//
//  CSTMainContentViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/29.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMainContentViewModel.h"
#import "CSTIOSDevice.h"
#import "CSTDataManager.h"
#import <ReactiveCocoa.h>
#import "CSTUserProfile.h"
#import "CSTAPIBaseManager.h"
#import "NSDate+CSTTransformString.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import "CSTDrinkModel.h"
#import "RACSignal+CSTModel.h"
#import "CSTRelationship.h"
#import "CSTWeather.h"
#import "CSTWeatherManager.h"
#import "Colours.h"
#import "CSTDrinkModel+CSTNetworkSignal.h"
#import "NSArray+CSTExtention.h"
#import "CSTDrinkModel+CSTCache.h"
#import "CSTBLEManager.h"
#import "CSTAQI.h"

@implementation CSTMainContentViewModel


#pragma mark - Life cycle
- (instancetype)init{
    
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithContentType:(CSTContentType)type{

    if (self = [super init]) {
        _contentType = type;
        
        [self p_configObserversWithContentType:type];
    }
    return self;
}
#pragma mark - Observer Weather

- (void)p_configObserverWithWeather{

    RAC(self, address) = RACObserve([CSTWeatherManager shareManager],cityName);
    RAC(self, weatherDescrithion) = RACObserve([CSTWeatherManager shareManager], weather.weatherDescription);
    RAC(self, tempratureText) = [RACObserve([CSTWeatherManager shareManager], weather.temp) map:^id(id value) {
        
        if (!value) {
            return [NSString stringWithFormat:@"温度 : 正在获取..."];
        }
        return [NSString stringWithFormat:@"温度 :%@℃",value];
    }];
    
    RAC(self, humidityText) = [RACObserve([CSTWeatherManager shareManager], weather.humidity) map:^id(id value) {
        
        return [NSString stringWithFormat:@"%ld%%",(long)[value floatValue]];
    }];
    RAC(self, weatherIcon) = [RACObserve([CSTWeatherManager shareManager], weather.iconName) map:^id(id value) {
        
        NSString *iconName = (NSString *)value;
        if (!iconName) {
            
            return nil;
        }
        return [UIImage imageNamed:iconName];
    }];
    
    RAC(self,aqiText) = [RACObserve([CSTWeatherManager shareManager], aqi.level)map:^id(id value) {
        
        if (((NSString *)value).length == 0) {
            
            return @"未知";
        }
        return value;
    }];
    
}

#pragma mark - Observer BLE state

- (void)p_configObserverWithBLEState{

    
    RAC(self,bleStateColor) = [RACObserve([CSTBLEManager shareManager], peripheral.state) map:^id(id value) {
        
        if ([value integerValue] == CBPeripheralStateDisconnected) {
            
            return [UIColor redColor];
        }else if ([value integerValue] == CBPeripheralStateConnected){
        
            return [UIColor greenColor];
        }
        
        return [UIColor yellowColor];
    }];
    
    RAC(self,bleStateString) = [RACObserve([CSTBLEManager shareManager], peripheral.state) map:^id(id value) {
        
        if ([value integerValue] == CBPeripheralStateDisconnected) {
            
            return @"未连接";
        }else if ([value integerValue] == CBPeripheralStateConnected){
            
            return @"已连接";
        }
        
        return @"正在连接";
    }];
}

#pragma mark - Observer
- (void)p_configObserverWithMateProfile{
    
    
    @weakify(self);
    [RACObserve([CSTDataManager shareManager], mateProfile) subscribeNext:^(id x) {
        @strongify(self);
        self.nickname = ((CSTUserProfile *)x).nickname;
    }];
}

- (void)p_configObserverWithTodayUserDinkWater{

    @weakify(self);
    [RACObserve([CSTDataManager shareManager], todayUserDrinkWater) subscribeNext:^(id x) {
        
        @strongify(self);
        NSInteger sum = [[x valueForKeyPath:@"@sum.weight"] integerValue];
        NSInteger count = [((NSArray*)x) count];
        self.todayDrinkWaterString = [self p_attributedStringWithDrinkWater:sum];
        self.topDetail = [NSString stringWithFormat:@"%ld次",(long)count];
        
        
        NSInteger average = count == 0 ? 0 : sum / count / 1000;
        self.middleDetail = count == 0 ? @"0ml" : [NSString stringWithFormat:@"%ldml",(long)average];
        self.bottomDetail = [[[((NSArray *)x) lastObject] valueForKey:@"date"] cst_stringWithFormat:@"HH:mm"] ?: @"00:00";
    }];
    
    RAC(self, remindMessage) = [[RACObserve([CSTDataManager shareManager], todayUserDrinkWater) map:^id(id value) {
        
        return @([CSTDataManager shareManager].userCurrentPeriodDrinkPercentState);
    }] map:^id(id value) {
        
        if ([value integerValue] == CSTUserCurrentPeriodDrinkPercentStateZeroToFifty || [value integerValue] == CSTUserCurrentPeriodDrinkPercentStateFifityToHundred) {
            return @"您最近有点缺水,喝点水休息一下喔...";
        }
        
        return @"饮水习惯很健康，继续保持...";
    }];
}

- (void)p_configObserverWithTodayMateDinkWater{

    @weakify(self);
    [RACObserve([CSTDataManager shareManager], todayMateDrinkWater) subscribeNext:^(id x) {
    
        @strongify(self);
        NSInteger sum = [[x valueForKeyPath:@"@sum.weight"] integerValue];
        self.todayDrinkWaterString = [self p_attributedStringWithDrinkWater:sum];
    }];
    
    RAC(self, remindMessage) = [[RACObserve([CSTDataManager shareManager], todayMateDrinkWater) map:^id(id value) {
        
        return @([CSTDataManager shareManager].mateCurrentPeriodDrinkPercentState);
    }] map:^id(id value) {
        
        if ([value integerValue] == CSTUserCurrentPeriodDrinkPercentStateZeroToFifty || [value integerValue] == CSTUserCurrentPeriodDrinkPercentStateFifityToHundred) {
            return @"Ta最近有点缺水...";
        }
        return @"饮水习惯很健康，继续保持...";
    }];
}

#pragma mark - Observer Today User suggest

- (void)p_configObserverWithTodayUserProgress{

    @weakify(self);
    [[RACSignal combineLatest:@[RACObserve([CSTDataManager shareManager], todayUserDrinkWater),RACObserve([CSTDataManager shareManager], todayUserSuggestWater)] reduce:^id(NSArray *drink, NSNumber *suggest){
        
        if ([suggest integerValue] == 0) {
            
            return @"0%";
            
        }else{

            float drinkWater =  [[drink valueForKeyPath:@"@sum.weight"] floatValue] / 1000;
            float progress = drinkWater / [suggest floatValue];
            
           return @(progress < 1.0 ? progress : 1.0);
        }
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.progress = [NSString stringWithFormat:@"%ld%%",(long)([x floatValue] * 100)];
        self.circleProgress = [x floatValue];
        
    }];
}


- (void)p_configObserverWithTodayUserRemainWater{

    @weakify(self);
    [[RACSignal combineLatest:@[RACObserve([CSTDataManager shareManager], todayUserDrinkWater),RACObserve([CSTDataManager shareManager], todayUserSuggestWater)] reduce:^id(NSArray *drink, NSNumber *suggest){
        
        NSInteger drinkWater =  [[drink valueForKeyPath:@"@sum.weight"] floatValue] / 1000;
   
            NSInteger remain = [suggest  integerValue] - drinkWater;
            remain = remain >= 0 ? remain : 0;
            return [NSString stringWithFormat:@"%ldml",(long)remain];
    }] subscribeNext:^(id x) {
        @strongify(self);
        self.remainWater = x;
    }];
}


- (void)p_configObserverWithUserSuggestWater{
    
    @weakify(self);
    [RACObserve([CSTDataManager shareManager], todayUserSuggestWater) subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.suggestWater = [NSString stringWithFormat:@"%ldml",(long)[x integerValue]];
    }];
}

#pragma mark - Observer Today Mate suggestWater

- (void)p_configObserverWithTodayMateProgress{
    
    @weakify(self);
    [[RACSignal combineLatest:@[RACObserve([CSTDataManager shareManager], todayMateDrinkWater),RACObserve([CSTDataManager shareManager], todayMateSuggestWater)] reduce:^id(NSArray *drink, NSNumber *suggest){
        
        if ([suggest integerValue] == 0) {
            
            return @"0%";
            
        }else{
            
            float drinkWater =  [[drink valueForKeyPath:@"@sum.weight"] floatValue] / 1000;
            float progress = drinkWater / [suggest floatValue];
            
            return @(progress < 1.0 ? progress : 1.0);
        }
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.progress = [NSString stringWithFormat:@"%ld%%",(long)([x floatValue] * 100)];
        self.circleProgress = [x floatValue];
        
    }];
}


- (void)p_configObserverWithTodayMateRemainWater{
    
    @weakify(self);
    [[RACSignal combineLatest:@[RACObserve([CSTDataManager shareManager], todayMateDrinkWater),RACObserve([CSTDataManager shareManager], todayMateSuggestWater)] reduce:^id(NSArray *drink, NSNumber *suggest){
        
        NSInteger drinkWater =  [[drink valueForKeyPath:@"@sum.weight"] floatValue] / 1000;
        
        NSInteger remain = [suggest  integerValue] - drinkWater;
        
        remain = remain >= 0 ? remain : 0;
        return [NSString stringWithFormat:@"%ldml",(long)remain];
    }] subscribeNext:^(id x) {
        @strongify(self);
        self.remainWater = x;
    }];
}


- (void)p_configObserverWithMateSuggestWater{
    
    @weakify(self);
    [RACObserve([CSTDataManager shareManager], todayMateSuggestWater) subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.suggestWater = [NSString stringWithFormat:@"%ldml",(long)[x integerValue]];
    }];
}

- (void)p_configObserverWithHistoryMateWater{
    
    @weakify(self);
    [RACObserve([CSTDataManager shareManager], historyMateDrinkWater) subscribeNext:^(id x) {
        
        @strongify(self);
        
        NSArray *historyDrinkWater = (NSArray *)x;
        NSInteger sum = [[historyDrinkWater valueForKeyPath:@"@sum.weight"] floatValue] / 1000;

        self.topDetail = [NSString stringWithFormat:@"%ldml",(long)sum];
        
        NSInteger dayCount = [historyDrinkWater count];
        if (dayCount > 0) {
         
            NSInteger dayAverage = (float)sum / (float)dayCount;
            self.middleDetail = [NSString stringWithFormat:@"%ldml",(long)dayAverage];
        }else{
            
            self.middleDetail = @"0ml";
        }
        self.bottomDetail = [NSString stringWithFormat:@"%ld天",(long)dayCount];
    }];
}

#pragma mark - Public method

- (void)refresCurrentPageData{

    [[self p_todayDrinkWaterSignalWithContentType:self.contentType] subscribeNext:^(id x) {
        
    }];
    
    [[self p_todaySuggestWaterSignalWithContentType:self.contentType] subscribeNext:^(id x) {
        
    }];
    if (self.contentType == CSTContentTypeMate) {
        
        [[self p_historyMateDrinkWaterSignal] subscribeNext:^(id x) {
            
        }];
    }
}

- (RACSignal *)sendeMessageToMateSignalWithMessage:(NSString *)message{

    return [[self p_sendMessageToMateAPIManagerWithMessage:message] fetchDataSignal];
}

- (RACSignal *)sendeMessageToMateSignal{
    
    return [[self p_sendMessageToMateAPIManagerWithMessage:[self sendMessage]] fetchDataSignal];
}


- (NSString *)sendMessage{

    return [NSString stringWithFormat:@"%@ : 喝点水休息一下吧",[CSTDataManager shareManager].userProfile.nickname];
}



#pragma mark - Private method

- (void)p_configObserversWithContentType:(CSTContentType)type{

    if (type == CSTContentTypeUser) {
        
        [self p_configObserverWithTodayUserDinkWater];
        [self p_configObserverWithTodayUserProgress];
        [self p_configObserverWithTodayUserRemainWater];
        [self p_configObserverWithUserSuggestWater];
        [self p_configObserverWithBLEState];
        [self p_configObserverWithWeather];
        
    }else if (type == CSTContentTypeMate){
    
        [self p_configObserverWithMateProfile];
        [self p_configObserverWithTodayMateDinkWater];
        [self p_configObserverWithTodayMateProgress];
        [self p_configObserverWithTodayMateRemainWater];
        [self p_configObserverWithMateSuggestWater];
        [self p_configObserverWithHistoryMateWater];
    }

}


#pragma mark - Today drink
- (NSAttributedString *)p_attributedStringWithDrinkWater:(NSInteger )water{

    
    NSString *string = [NSString stringWithFormat:@"%ldml",(long)water / 1000];
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:61.0f]}];
    [attributedString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:29]} range:NSMakeRange(attributedString.length - 2,2)];
  
    return [attributedString copy];
}

- (RACSignal *)p_todayDrinkWaterSignalWithContentType:(CSTContentType)type{

    if (type == CSTContentTypeUser) {
        
        return [self p_todayUserDrinkWaterSignal];
        
    }else if (type == CSTContentTypeMate){
    
        return [self p_todayMateDrinkWaterSignal];
    }
    return nil;
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

- (RACSignal *)p_todayUserDrinkWaterSignal{
    
    return [[[CSTDrinkModel cst_todayUserDrinkWaterSignal] doNext:^(id x) {
        
        [CSTDrinkModel cst_cacheDrinkModelArray:x withFileName:[CSTDataManager todayUserDrinkCacheFileName]];
        
        [CSTDataManager shareManager].todayUserDrinkWater = [CSTDrinkModel cst_drinkModelArrayWithDocument:[CSTDataManager documentCacheFileName] currentModelArray:x];
        
    }] doError:^(NSError *error) {
        
        [CSTDataManager shareManager].todayUserDrinkWater = [CSTDrinkModel cst_drinkModelArrayWithDocument:[CSTDataManager documentCacheFileName] cache:[CSTDataManager todayUserDrinkCacheFileName]];
    }];
}


- (RACSignal *)p_todayMateDrinkWaterSignal{

    return [[CSTDrinkModel cst_todayMateDrinkWaterSignal] doNext:^(id x) {
        
        [CSTDataManager shareManager].todayMateDrinkWater = x;
    }];
}



#pragma mark - Today suggest


- (RACSignal *)p_todaySuggestWaterSignalWithContentType:(CSTContentType)type{
    
    if (type == CSTContentTypeUser) {
        
        return [self p_todayUserSuggestWaterSignal];
        
    }else if (type == CSTContentTypeMate){
        
        return [self p_todayMateSuggestWaterSignal];
    }
    return nil;
}


- (RACSignal *)p_todayUserSuggestWaterSignal{

    return [[[[[[self p_todayUserSuggestWaterAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
        NSArray *list = value[@"Drinks"];
        return [RACSignal cst_transformSignalWithModelClass:[CSTDrinkModel class] dictionary:[list firstObject]];
    }] doNext:^(id x) {
        
        if (x) {
            [CSTDataManager shareManager].todayUserSuggestWater = [((CSTDrinkModel *)x).weight integerValue];
        }else{
            [self p_handlefetchUserSuggestWaterWithNil];
        }
        
    }] doError:^(NSError *error) {
        
        if ([CSTDataManager shareManager].todayUserSuggestWater == 0) {
            
            [CSTDataManager shareManager].todayUserSuggestWater = 2000;
        }
    }];
}

- (void)p_handlefetchUserSuggestWaterWithNil {
    
    NSInteger suggest = [[CSTWeatherManager shareManager] calculateSuggestWaterWithUserProfile:[CSTDataManager shareManager].userProfile weather:[CSTWeatherManager shareManager].weather];

    if (suggest != 0) {
        
        [[self p_uploadUserSuggestWaterSignalWithSuggest:suggest] subscribeNext:^(id x) {
            
        }];
        [CSTDataManager shareManager].todayUserSuggestWater = suggest;
        
        return;
    }
    if ([CSTDataManager shareManager].todayUserSuggestWater == 0) {
        
        [CSTDataManager shareManager].todayUserSuggestWater = 2000;
    }
}


- (RACSignal *)p_todayMateSuggestWaterSignal{

    return [[[[[[self p_todayMateSuggestWaterAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
        NSArray *list = value[@"Drinks"];
        return [RACSignal cst_transformSignalWithModelClass:[CSTDrinkModel class] dictionary:[list firstObject]];
    }] doNext:^(id x) {
        if (x){
            [CSTDataManager shareManager].todayMateSuggestWater = [((CSTDrinkModel *)x).weight integerValue];
        }else{
            if ([CSTDataManager shareManager].todayMateSuggestWater == 0){
                [CSTDataManager shareManager].todayMateSuggestWater = 2000;
            }
        }
    }] doError:^(NSError *error) {
        
        if ([CSTDataManager shareManager].todayMateSuggestWater == 0) {
            [CSTDataManager shareManager].todayMateSuggestWater = 2000;
        }
    }];
}


- (RACSignal *)p_uploadUserSuggestWaterSignalWithSuggest:(NSInteger)suggest{

    
    return [[self p_uploadUserSuggestWaterAPIManagerWithSuggest:suggest] fetchDataSignal];
}


#pragma mark -  Mate history drink

- (RACSignal *)p_historyMateDrinkWaterSignal{

    return [[[[[self p_historyMateDrinkApiManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {
        
        return  [self p_transformToModelArraySignalWithDicArray:value[@"Drinks"]];
    }] doNext:^(id x) {

        [CSTDataManager shareManager].historyMateDrinkWater = [x cst_distinctAndSortResultWithKeyPath:@"date"];
    }];
}


#pragma mark - APIManager
- (CSTUserSuggestWaterAPIManager *)p_todayUserSuggestWaterAPIManager{
    
    CSTUserSuggestWaterAPIManager *apiManager = [[CSTUserSuggestWaterAPIManager alloc] init];
    apiManager.parameters = [self p_todayUserSuggestWaterAPIParameters];
    
    return apiManager;
}

- (CSTMateSuggestWaterAPIManager *)p_todayMateSuggestWaterAPIManager{
    
    CSTMateSuggestWaterAPIManager *apiManager = [[CSTMateSuggestWaterAPIManager alloc] init];
    apiManager.parameters = [self p_todayUserSuggestWaterAPIParameters];
    
    return apiManager;
}


- (CSTUploadUserSuggestWaterAPIManager *)p_uploadUserSuggestWaterAPIManagerWithSuggest:(NSInteger)suggest{

    CSTUploadUserSuggestWaterAPIManager *apiManager = [[CSTUploadUserSuggestWaterAPIManager alloc] init];
    apiManager.parameters = [self p_uploadUserSuggestWaterAPIParametersWithSuggest:suggest];
    
    return apiManager;
}


- (CSTMateDrinkWaterAPIManager *)p_historyMateDrinkApiManager{

    CSTMateDrinkWaterAPIManager *apiManager = [[CSTMateDrinkWaterAPIManager alloc] init];
    apiManager.parameters = [self p_historyDrinkWaterParameters];
    
    return apiManager;
}


- (CSTSendMessageToMateAPIManager *)p_sendMessageToMateAPIManagerWithMessage:(NSString *)message{

    if (!message) {
        return nil;
    }
    CSTSendMessageToMateAPIManager *apiManager = [[CSTSendMessageToMateAPIManager alloc] init];
    apiManager.parameters = @{@"notification" : message};
    
    return apiManager;
}

#pragma mark - API parameters

- (NSDictionary *)p_uploadUserSuggestWaterAPIParametersWithSuggest:(NSInteger)suggest{
    
    return @{@"datetime":[[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"],
             @"weight":@(suggest)
             };
}

- (NSDictionary *)p_todayUserSuggestWaterAPIParameters{
    
    //return @{@"datetime" : [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"]};
    
     return @{@"startDate" : [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"],
              @"endDate" : [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"]};
    
}

- (NSDictionary *)p_historyDrinkWaterParameters{
    
    NSString *end = [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"];
    NSString *begein = @"2014-10-01";
    
    return  @{@"startDate" : begein,
              @"endDate" : end,
              @"type" : @2
              };
}



#pragma mark - Setters and getters

- (UIImage *)topImage{

    return self.contentType == CSTContentTypeUser ? [UIImage imageNamed:@"DropIcon"] : [UIImage imageNamed:@"DropYellowIcon"];
}

- (UIImage *)middleImage{
    
    return self.contentType == CSTContentTypeUser ? [UIImage imageNamed:@"CupIcon"] : [UIImage imageNamed:@"DayIcon"];
}

- (UIImage *)bottomImage{
    
    return self.contentType == CSTContentTypeUser ? [UIImage imageNamed:@"ClockIcon"] : [UIImage imageNamed:@"CalendarIcon"];
}


- (NSString *)topTitle{

    return self.contentType == CSTContentTypeUser ? @"今天喝水" : @"历史累积饮水量";
}

- (NSString *)middleTitle{
    
    return self.contentType == CSTContentTypeUser ? @"平均每次喝" : @"日均饮水量";
}


- (NSString *)bottomTitle{
    
    return self.contentType == CSTContentTypeUser ? @"最后一次补充水分" : @"Coaster累积使用天数";
}


- (CGFloat)thicknessRatio{

    if ([CSTIOSDevice isIPhone5]) {
        
        return 0.1;
        
    }else if ([CSTIOSDevice isIPhone6]){
    
        return kiPhone6Width * 0.1 / kiPhone5Width;
        
    }else if ([CSTIOSDevice isIPhone6P]){
        
        return kiPhone6PWidth * 0.1 / kiPhone5Width;
    }
    return 0.1;
    
}

- (UIColor *)trackTintColor{

    return self.contentType == CSTContentTypeUser ? [UIColor colorFromHexString:@"c4ebff"] : [UIColor colorFromHexString:@"ffddba"];
}


@end
