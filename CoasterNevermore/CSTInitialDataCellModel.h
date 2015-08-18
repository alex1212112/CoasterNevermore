//
//  CSTInitialDataCellModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;
#import "CSTUserProfile.h"

//typedef NS_ENUM(NSInteger, CSTUserDataType) {
//    CSTUserDataTypeSex,
//    CSTUserDataTypeWeight,
//    CSTUserDataTypeHeight,
//    CSTUserDataTypeAge
//};
//

@interface CSTInitialDataCellModel : NSObject <UIPickerViewDataSource>

@property (nonatomic, assign) CSTUserProfileType type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) CSTUserProfile *userInfo;


- (instancetype)initWithType:(CSTUserProfileType)type  title:(NSString *)title content:(NSString *)content detail:(NSString *)detail userInfo:(CSTUserProfile *)userInfo;

- (NSAttributedString *)attributedStringWithNumber:(NSInteger)number string:(NSString *)string;

@end
