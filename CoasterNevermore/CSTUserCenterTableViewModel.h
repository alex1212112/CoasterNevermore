//
//  CSTUserCenterTableViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/7.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface CSTUserCenterTableViewModel : NSObject


@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *nCointCount;
@property (nonatomic, strong) UIImage *avatarImage;

- (void)refreshCurrentPageData;

- (BOOL)isUserOwnDevice;

@end
