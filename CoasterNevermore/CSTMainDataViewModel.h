//
//  CSTMainDataViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/8.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;

@class CSTRelationship;
@class CSTMainContentViewModel;

@interface CSTMainDataViewModel : NSObject

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) CSTRelationship *relationship;

@property (nonatomic, assign) BOOL hasMate;

@property (nonatomic, strong) CSTMainContentViewModel *userContentViewModel;
@property (nonatomic, strong) CSTMainContentViewModel *mateContentViewModel;


- (void)refreshCurrentPageData;

- (void)refreshUserAvatar;

@end
