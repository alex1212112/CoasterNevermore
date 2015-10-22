//
//  CSTMainDataViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/8.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMainDataViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import "CSTRelationship.h"
#import "CSTMainContentViewModel.h"
#import "SDWebImageManager+CSTDownloadSignal.h"

@implementation CSTMainDataViewModel

#pragma mark - Life cycle
- (instancetype)init{
    
    if (self = [super init]) {
        
        [self p_configObserverWithUserProfile];
        [self p_configObserverWithRelationship];
    }
    return self;
}

#pragma mark -Observer
- (void)p_configObserverWithUserProfile{
    
    RAC(self, avatarImage) =  [[RACObserve([CSTDataManager shareManager], userProfile.imageURLString) flattenMap:^RACStream *(id value) {
        
        return [SDWebImageManager cst_imageSignalWithURLString:value];
    }] map:^id(id value) {
        
        return value ?: [UIImage imageNamed:@"AvatarIcon"];
    }];
    
}

- (void)p_configObserverWithRelationship{

    RAC(self,relationship) = RACObserve([CSTDataManager shareManager], relationship);
    @weakify(self);
    [RACObserve([CSTDataManager shareManager], relationship) subscribeNext:^(id x) {
        @strongify(self);
        
        CSTRelationship *relationship = (CSTRelationship *)x;
        self.hasMate = [relationship.status isEqual:@2];
    }];
}

#pragma mark - Public method

- (void)refreshCurrentPageData{

    [self refreshUserAvatar];
    [self.userContentViewModel refresCurrentPageData];
    [self.mateContentViewModel refresCurrentPageData];
}

- (void)refreshUserAvatar{
    
    @weakify(self);
    
    [[SDWebImageManager cst_imageSignalWithURLString:[CSTDataManager shareManager].userProfile.imageURLString] subscribeNext:^(id x) {
        
        @strongify(self);
        self.avatarImage = x;
    }error:^(NSError *error) {
        @strongify(self);
        self.avatarImage = [UIImage imageNamed:@"AvatarIcon"];
        
    }];
}



#pragma mark - Private method



#pragma mark - Setters and getters

- (CSTMainContentViewModel *)userContentViewModel{

    if (!_userContentViewModel) {
        
        _userContentViewModel = [[CSTMainContentViewModel alloc] initWithContentType:CSTContentTypeUser];
    }
    return _userContentViewModel;
}

- (CSTMainContentViewModel *)mateContentViewModel{

    if (!_mateContentViewModel) {
        
        _mateContentViewModel = [[CSTMainContentViewModel alloc] initWithContentType:CSTContentTypeMate];
    }
    return _mateContentViewModel;
}

@end
