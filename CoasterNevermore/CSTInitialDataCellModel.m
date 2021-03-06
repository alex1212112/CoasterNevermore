//
//  CSTInitialDataCellModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTInitialDataCellModel.h"

@implementation CSTInitialDataCellModel

#pragma mark - Life cycle
- (instancetype)initWithType:(CSTUserProfileType)type  title:(NSString *)title content:(NSString *)content detail:(NSString *)detail userInfo:(CSTUserProfile *)userInfo
{
    if (self = [super init]) {
        
        _type = type;
        _title = title;
        _content = content;
        _detail = detail;
        _userInfo = userInfo;
    }
    return self;
}

#pragma mark - UIPickerView data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 180;
}


#pragma mark - Public method

- (NSAttributedString *)attributedStringWithNumber:(NSInteger)number string:(NSString *)string
{
    NSString *numberString = [[NSString alloc] initWithFormat:@"%ld",(long)number];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:numberString attributes:@{NSFontAttributeName : [UIFont  systemFontOfSize:25],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : [UIFont  systemFontOfSize:13],NSForegroundColorAttributeName : [UIColor whiteColor]}]];
    
    return  [[NSAttributedString alloc] initWithAttributedString:attributedString];

}

@end
