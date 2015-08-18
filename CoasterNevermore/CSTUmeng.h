//
//  CSTUmeng.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import UIKit;

extern NSString *const CSTUmengKey;
extern NSString *const CSTQQAppId;
extern NSString *const CSTQQAppKey;
extern NSString *const CSTWXAppId;
extern NSString *const CSTWXAppSecret;

@interface CSTUmeng : NSObject

+ (void)configUmeng;

+ (void)shareText:(NSString *)text image:(UIImage *)image presentSnsIconSheetView:(UIViewController *)vc;

+ (BOOL)isQQInstalled;


@end
