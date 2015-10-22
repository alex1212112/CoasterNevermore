//
//  CSTUserProfileViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;


@class RACSignal;
#import "CSTUpdateUserProfileViewModel.h"

@interface CSTUserProfileViewModel : NSObject

@property (nonatomic, copy) NSArray *profileItems;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) UIImage *editImage;
@property (nonatomic, copy) NSString *editNickname;
@property (nonatomic, strong) NSNumber *editGender;
@property (nonatomic, strong) NSNumber *editHeight;
@property (nonatomic, strong) NSNumber *editWeight;
@property (nonatomic, strong) NSDate *editBirthday;

@property (nonatomic, strong) CSTUpdateUserProfileViewModel *updateViewModel;


- (RACSignal *)EditSignal;

- (BOOL)isUserProfieCanBeModified;


- (void)configCurrentUpdateViewmodel;

- (RACSignal *)updateUserProfileSignal;

@end
