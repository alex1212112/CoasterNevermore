//
//  CSTUserProfile+CSTNetworkSignal.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/8.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserProfile+CSTNetworkSignal.h"
#import "CSTAPIBaseManager.h"
#import <ReactiveCocoa.h>
#import "RACSignal+CSTModel.h"
#import "NSData+CSTParsedJsonDataSignal.h"

@implementation CSTUserProfile (CSTNetworkSignal)

+ (RACSignal *)cst_networkDataSignalWithUid:(NSString *)uid{

    
    return [[[[CSTUserProfile p_userProfileAPIManagerWithUid:uid] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
         return [value cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {
        
        return [RACSignal cst_transformSignalWithModelClass:[CSTUserProfile class] dictionary:value];
    }];

}


+ (NSDictionary *)p_userProfileParametersWithUid:(NSString *)uid{
    
    if (uid)
    {
        return @{@"uid":uid,@"expand":@"true"};
    }
    return nil;
}

+ (CSTUserInfomationAPIManager *)p_userProfileAPIManagerWithUid:(NSString *)uid{

    CSTUserInfomationAPIManager *apiManager = [[CSTUserInfomationAPIManager alloc] init];
    apiManager.parameters = [CSTUserProfile p_userProfileParametersWithUid:uid];
    
    return apiManager;
}

@end
