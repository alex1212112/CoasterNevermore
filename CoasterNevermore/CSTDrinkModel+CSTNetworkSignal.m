//
//  CSTDrinkModel+CSTNetworkSignal.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDrinkModel+CSTNetworkSignal.h"
#import "CSTAPIBaseManager.h"
#import <ReactiveCocoa.h>
#import "RACSignal+CSTModel.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import "NSDate+CSTTransformString.h"
#import "NSArray+CSTExtention.h"
#import "CSTDataManager.h"
#import "CSTDrinkModel+CSTCache.h"


@implementation CSTDrinkModel (CSTNetworkSignal)


#pragma mark - Today user drink
+ (RACSignal *)cst_todayUserDrinkWaterSignal{
    
    return [[[[[[self cst_userDrinkApiManagerWithDate:[NSDate date]] fetchDataSignal] doNext:^(id x) {
        
        [CSTDrinkModel cst_uploadDocumentData];
    }] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {

        return  [RACSignal cst_transformToModelArraySignalWithModelClass:[CSTDrinkModel class]  dicArray:value[@"Drinks"]];
    }] map:^id(id value) {
        
        return  [value cst_distinctAndSortResultWithKeyPath:@"date"];
    }] ;
}


#pragma mark - Today mate drink

+ (RACSignal *)cst_todayMateDrinkWaterSignal{
    
    return [[[[[self cst_todayMateDrinkApiManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {
        
        return  [RACSignal cst_transformToModelArraySignalWithModelClass:[CSTDrinkModel class]  dicArray:value[@"Drinks"]];
        
    }] map:^id(id value) {
        
        return  [value cst_distinctAndSortResultWithKeyPath:@"date"];
    }];
}


+ (CSTMateDrinkWaterAPIManager *)cst_todayMateDrinkApiManager{
    
    CSTMateDrinkWaterAPIManager *apiManager = [[CSTMateDrinkWaterAPIManager alloc] init];
    apiManager.parameters = [CSTDrinkModel cst_userDrinkWaterParametersWithDate:[NSDate date]];
    
    return apiManager;
}

#pragma mark - upload document data

+ (CSTUploadWaterAPIManager *)cst_uploadWaterAPIManagerWithParameters:(NSDictionary *)parameters{

    CSTUploadWaterAPIManager *apiManager = [[CSTUploadWaterAPIManager alloc] init];
    apiManager.parameters = parameters;
    
    return apiManager;
}

+ (void)cst_uploadDocumentData{
    
    static BOOL cst_userDrink_uploading = NO;
    if (cst_userDrink_uploading)
    {
        return;
    }
    
    NSString *fileName = [CSTDataManager documentCacheFileName];
    NSArray *documentArray =  [CSTDrinkModel cst_userDrinkArrayWithDocumentFileName:fileName];
    
    if ([documentArray count] == 0) {
        
        return;
    }
    
    cst_userDrink_uploading = YES;
    [documentArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        
        
        [[[CSTDrinkModel cst_uploadWaterAPIManagerWithParameters:dic] fetchDataSignal] subscribeNext:^(id x) {
            
            [CSTDrinkModel cst_removeItem:dic FromDocumentFile:fileName];
            if (idx >= [documentArray count] - 1)
            {
                cst_userDrink_uploading = NO;
            }
            
        } error:^(NSError *error) {
            
            if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]])
            {
                
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
                if (response.statusCode == 409) {
                    
                    [CSTDrinkModel cst_removeItem:dic FromDocumentFile:fileName];
                }
            }
            
            if (idx >= [documentArray count] - 1)
            {
                cst_userDrink_uploading = NO;
            }
        }];
        
    }];
}

#pragma mark - User drink

+ (RACSignal *)cst_userDrinkWaterSignalWithDate:(NSDate *)date{
    
    return [[[[[[self cst_userDrinkApiManagerWithDate:date] fetchDataSignal] doNext:^(id x) {
        
    }] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {
        
        return  [RACSignal cst_transformToModelArraySignalWithModelClass:[CSTDrinkModel class]  dicArray:value[@"Drinks"]];
        
    }] map:^id(id value) {
        
        return  [value cst_distinctAndSortResultWithKeyPath:@"date"];
    }] ;
}


+ (CSTUserDrinkWaterAPIManager *)cst_userDrinkApiManagerWithDate:(NSDate *)date{
    
    CSTUserDrinkWaterAPIManager *apiManager = [[CSTUserDrinkWaterAPIManager alloc] init];
    apiManager.parameters = [CSTDrinkModel cst_userDrinkWaterParametersWithDate:date];
    
    return apiManager;
}

+ (NSDictionary *)cst_userDrinkWaterParametersWithDate:(NSDate *)date{
    
    NSString *dateString = [date cst_stringWithFormat:@"yyyy-MM-dd"];
    
    return  @{@"startDate" : dateString,
              @"endDate" : dateString,
              @"type" : @1
              };
}



@end
