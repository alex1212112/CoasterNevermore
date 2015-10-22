//
//  CSTUpdateUserProfileViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "CSTUserProfile.h"

@interface CSTUpdateUserProfileViewModel : NSObject <UIPickerViewDataSource>

@property (nonatomic, assign) CSTUserProfileType userProfileType;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSNumber *weight;

- (instancetype)initWithUserProfieType:(CSTUserProfileType)type;

- (NSAttributedString *)attributedStringWithNumber:(NSInteger)number string:(NSString *)string;

@end
