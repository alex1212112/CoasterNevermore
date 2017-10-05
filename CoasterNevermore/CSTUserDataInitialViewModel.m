//
//  CSTUserDataInnitialViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserDataInitialViewModel.h"
#import "CSTInitialDataCellModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTAPIBaseManager.h"
#import "RACSignal+CSTModel.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import "CSTDataManager.h"

@implementation CSTUserDataInitialViewModel


#pragma mark - Public method

- (RACSignal *)forwardSignalWithCurrentPage:(NSInteger)page{

    if (page >= [self.userDataInitialCellModels count]) {
        
        return nil;
    }
    CSTInitialDataCellModel *cellModel = self.userDataInitialCellModels[page];
    
    if (page == 0) {
        
        return [RACObserve(cellModel,userInfo.gender)map:^id(id value) {
            
            return @(value ? YES :NO);
        }];
    }
    if (page == 1) {
        
        return [RACObserve(cellModel,userInfo.weight)map:^id(id value) {
            
            return @(value ? YES :NO);
        }];
    }
    if (page == 2) {
        
        return [RACObserve(cellModel,userInfo.height)map:^id(id value) {
            
            return @(value ? YES :NO);
        }];
    }
    if (page == 3) {
        
        return [RACObserve(cellModel,userInfo.birthday)map:^id(id value) {
            
            return @(value ? YES :NO);
        }];
    }
    
    return nil;
}

- (RACSignal *)updateUserInformationSignal{

    CSTUpdateUserInformationAPIManager *apiManager = [[CSTUpdateUserInformationAPIManager alloc] init];
    apiManager.parameters = [self p_updateUserInformationParameters];
    
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    
    return [[[[[apiManager fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value  cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {
        
        return [RACSignal cst_transformSignalWithModelClass:[CSTUserProfile class] dictionary:value];
    }] doNext:^(id x) {
        
        [CSTDataManager shareManager].userProfile = x;
    }] subscribeOn:scheduler];
}

- (BOOL)isUserOwndevice{

    return [CSTDataManager shareManager].userProfile.deviceId ? YES : NO;

}

#pragma mark - Private method

- (NSArray *)p_titles
{
    return @[
             @"您的性别",
             @"您的体重",
             @"您的身高",
             @"您的年龄"
             ];
}


- (NSArray *)p_contents
{
    return @[
             @"请准确输入个人信息，",
             @"请准确输入个人信息，",
             @"请准确输入个人信息，",
             @"请准确输入个人信息，"
             ];
}

- (NSArray *)p_details
{
    return @[
             @"以便我们精确计算您每天所需都饮水量",
             @"以便我们精确计算您每天所需都饮水量",
             @"以便我们精确计算您每天所需都饮水量",
             @"以便我们精确计算您每天所需都饮水量"
             ];
    
}

- (NSDictionary *)p_updateUserInformationParameters{
    
    __block NSNumber *height;
    __block NSNumber *weight;
    __block NSNumber *gender;
    __block NSString *birthday;
    
    [self.userDataInitialCellModels enumerateObjectsUsingBlock:^(CSTInitialDataCellModel *cellModel, NSUInteger idx, BOOL *stop) {
        
        if (idx == 0) {
            gender = cellModel.userInfo.gender;
        }else if (idx == 1){
            weight = cellModel.userInfo.weight;
        }else if (idx == 2){
            height = cellModel.userInfo.height;
        }else if (idx == 3){
            birthday = cellModel.userInfo.birthday;
        }
    }];
    
    return @{@"height" : height,
             @"weight" : weight,
             @"gender" : gender,
             @"birthday" : birthday,
             @"expand" : @"true"
             };

}

- (NSArray *)p_userProfileMap{

    return @[@(CSTUserProfileTypeGender),@(CSTUserProfileTypeWeight),@(CSTUserProfileTypeHeight),@(CSTUserProfileTypeBirthday)];
}

#pragma mark - Setters and getters

- (NSArray *)userDataInitialCellModels
{
    if (!_userDataInitialCellModels) {
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSInteger n = 0; n < 4; n++) {
            
            CSTInitialDataCellModel *viewModel = [[CSTInitialDataCellModel alloc] initWithType:[[self p_userProfileMap][n] integerValue]  title:[self p_titles][n] content:[self p_contents][n] detail:[self p_details][n] userInfo:[[CSTUserProfile alloc] init]];
            [mutableArray addObject:viewModel];
        }
        
        _userDataInitialCellModels = [NSArray arrayWithArray:mutableArray];
    }
    return _userDataInitialCellModels;
}



@end
