//
//  CSTQQHandler.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/7.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTQQManager.h"
#import "CSTAPIBaseManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTDataManager.h"
#import "CSTUserAccessViewController.h"
#import "CSTRouter.h"
#import "CSTQQToken.h"
#import "DXAlertView.h"
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import "CSTDrinkModel+CSTCache.h"
#import "NSDate+CSTTransformString.h"
#import "CSTUmeng.h"

NSString *const CSTQQHealth = @"qqhealth";

@interface CSTQQManager ()

@property (nonatomic, copy) NSDictionary *qqTokenParameters;

@end

@implementation CSTQQManager

#pragma mark - Public method

+ (instancetype)shareManager
{
    static CSTQQManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (NSDictionary *)dictionaryWithURLQueryString:(NSString *)string
{
    if (string.length <= 0)
    {
        return nil;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *array = [string componentsSeparatedByString:@"&"];
    [array enumerateObjectsUsingBlock:^(NSString *keyValueString, NSUInteger idx, BOOL *stop) {
        
        NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
        
        dic[[keyValueArray firstObject]] = [keyValueArray lastObject];
        
    }];
    
    return [CSTQQManager p_qqTokenDictionaryWithSource:dic];
}


- (void)handleQQParameters:(NSDictionary *)parameters{
    
    if (!parameters[@"accessToken"])
    {
        return;
    }
    
    self.qqTokenParameters = parameters;
    
    if (![CSTDataManager isLogin]) {
        
        CSTUserAccessViewController *userAccessViewController = [CSTRouter loginViewController];
        
        [[userAccessViewController qqLoginSignalWithQQTokenDic:parameters] subscribeNext:^(id x) {
            
        }];
        return;
    }
    
    if ([CSTDataManager shareManager].loginType == CSTLoginTypeQQ) {
        
        if(![[CSTQQToken token].openid isEqualToString:parameters[@"usid"]])
        {
            [self p_showSwitchQQNumberAlert];
        }
        return;
    }
    
    [self p_showSwitchToQQLoginAlert];
}


#pragma mark - Private method

+ (NSDictionary *)p_qqTokenDictionaryWithSource:(NSDictionary *)dic{
    
    NSMutableDictionary *mutablDic = [NSMutableDictionary dictionary];
    if (dic[@"accesstoken"]) {
        
        mutablDic[@"accessToken"] = dic[@"accesstoken"];
    }
    if (dic[@"openid"]) {
        mutablDic[@"usid"] = dic[@"openid"];
    }
    if (dic[@"accesstokenexpiretime"]) {
        mutablDic[@"accesstokenexpiretime"] = dic[@"accesstokenexpiretime"];
    }
    if (dic[@"from"]) {
        mutablDic[@"from"] = dic[@"from"];
    }
    if (dic[@"type"]) {
         mutablDic[@"type"] = dic[@"type"];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutablDic];
}


- (NSDictionary *)p_localTokenParametersWithQQToken:(NSDictionary *)qqToken{
  
    if (!qqToken[@"accessToken"]) {
        
        return nil;
    }
  return @{@"provider":@"QQ",@"externalAccessToken":qqToken[@"accesstToken"]};
}

- (RACSignal *)p_localTokenSignalWithQQTokenParameters:(NSDictionary *)qqToken{

    return [[self p_localAccessTokenWithQQTokenParameters:qqToken] fetchDataSignal];

}

- (CSTLocalAccessTokenFrom3rdAPIManager *)p_localAccessTokenWithQQTokenParameters:(NSDictionary *)qqToken{

    CSTLocalAccessTokenFrom3rdAPIManager *apiManager = [[CSTLocalAccessTokenFrom3rdAPIManager alloc] init];
    apiManager.parameters = [self p_localTokenParametersWithQQToken:qqToken];
    
    return apiManager;
}

- (void)p_showSwitchQQNumberAlert{
    
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提醒" contentText:@"您需要切换至当前的QQ号码登录Coaster，才能在QQ健康中心看到数据哦~" leftButtonTitle:@"取消" rightButtonTitle:@"切换"];
    
    [alert show];
    
    alert.rightBlock = ^{
    
        [self p_switch];
    };
    
}

- (void)p_showSwitchToQQLoginAlert{

    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提醒" contentText:@"您需要使用QQ号码登录Coaster，才能在QQ健康中心看到数据哦~" leftButtonTitle:@"取消" rightButtonTitle:@"QQ登录"];
    
    [alert show];
    
    alert.rightBlock = ^{
        
        [self p_switch];
    };
}


- (void)p_switch{

    [CSTDataManager removeAllData];
    CSTUserAccessViewController *accessVC = (CSTUserAccessViewController *)[CSTRouter routerToLoginViewControllerWithLogin];
    [[accessVC qqLoginSignalWithQQTokenDic:self.qqTokenParameters] subscribeNext:^(id x) {
        
    }];

}


#pragma mark - Upload user drink to QQ health

- (RACSignal *)uploadUserDrinkWaterWithParameters:(NSDictionary *)parameters{

    return [[self p_uploadDrinkToQQWithParameters:parameters] fetchDataSignal];
}

- (CSTUploadDrinkToQQAPIManager *)p_uploadDrinkToQQWithParameters:(NSDictionary *)parameters{

    CSTUploadDrinkToQQAPIManager *apiManager = [[CSTUploadDrinkToQQAPIManager alloc] init];
    apiManager.parameters = parameters;
    return apiManager;
}


+ (NSDictionary *)upLoadDrinkToQQParametersWithDrinkArray:(NSArray *)array date:(NSDate *)date{

    NSArray *documentArray = [[CSTDrinkModel cst_documentDrinkModelArrayWithDocument:[CSTDataManager documentCacheFileName]] linq_where:^BOOL(id item) {
    
        return [date cst_isTheSameDayWithDate:[item valueForKey:@"date"]];
    }];
    
    NSArray *drinkArray = [array linq_concat:documentArray];
    
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    
    NSInteger totalDrink = [[drinkArray valueForKeyPath:@"@sum.weight"] integerValue] / 1000 ;
    
    NSInteger drinkCount = [drinkArray count];
    
    NSDictionary *parameters = @{@"access_token" : [CSTQQToken token].accesstoken,
                                 @"oauth_consumer_key" : CSTQQAppId,
                                 @"openid" : [CSTQQToken token].openid,
                                 @"pf" : @"qzone",
                                 @"time" : @(timeStamp),
                                 @"total_water" : @(totalDrink),
                                 @"cup_count" : @(drinkCount)
                                 };
    
    if ([date cst_isTheSameDayWithDate:[NSDate date]] && [CSTDataManager shareManager].todayUserSuggestWater > 0) {
        
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableDic setObject: @([CSTDataManager shareManager].todayUserSuggestWater) forKey:@"water_goal"];
        parameters = [NSDictionary dictionaryWithDictionary:mutableDic];
    }
    
    return parameters;
}


@end
