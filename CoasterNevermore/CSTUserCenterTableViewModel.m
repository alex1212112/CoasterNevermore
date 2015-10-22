//
//  CSTUserCenterTableViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/7.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserCenterTableViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import "CSTAPIBaseManager.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import "SDWebImageManager+CSTDownloadSignal.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation CSTUserCenterTableViewModel

#pragma mark - Life cycle
- (instancetype)init{

    if (self = [super init]) {
        
        [self p_configObserverWithUserProfile];
        [self p_configObserverWithNCoinCount];
    }
    
    return self;
}


#pragma mark -Observer
- (void)p_configObserverWithUserProfile{
    
    RAC(self,username) = RACObserve([CSTDataManager shareManager], userProfile.username);
    RAC(self,nickname) = RACObserve([CSTDataManager shareManager], userProfile.nickname);
    
    
    RAC(self, avatarImage) =  [[RACObserve([CSTDataManager shareManager], userProfile.imageURLString) flattenMap:^RACStream *(id value) {
        
        return [SDWebImageManager cst_imageSignalWithURLString:value];
    }] map:^id(id value) {
        
        return value ?: [UIImage imageNamed:@"AvatarIcon"];
    }];
}

- (void)p_configObserverWithNCoinCount{

    
    RAC(self,nCointCount) = [RACObserve([CSTDataManager shareManager], nCoinCount)map:^id(id value) {
        
        return [NSString stringWithFormat:@"奈币: %ld",(long)[value integerValue]];
    }];
    
}

#pragma mark - Public method
- (void)refreshCurrentPageData{

    [self p_refreshNcoinCount];
    [self p_refreshUserProfile];
}

- (BOOL)isUserOwnDevice{

    return [CSTDataManager shareManager].userProfile.deviceId ? YES : NO;
}

#pragma mark - Private method


- (void)p_refreshUserProfile{

    [[CSTDataManager refreshUserProfileSignal] subscribeNext:^(id x) {
        
    }];
}

- (void)p_refreshNcoinCount{

    [[self p_nCoinCountSignal]subscribeNext:^(id x) {
      
        [CSTDataManager shareManager].nCoinCount = [x integerValue];
    }];
}


- (RACSignal *)p_nCoinCountSignal{

    CSTNCoinCountAPIManager *nCoinAPIManager = [[CSTNCoinCountAPIManager alloc] init];
    return [[[nCoinAPIManager fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }] map:^id(id value) {
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)value;
            return dic[@"ScoreValue"];
        }
        return  nil;
    }];
}


#pragma mark - Setters and getters




@end
