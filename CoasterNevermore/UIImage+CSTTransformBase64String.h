//
//  UIImage+CSTTransformBase64String.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CSTTransformBase64String)

- (NSString *)cst_base64StringLessThanFiftyKb;

- (NSString *)cst_base64String;

@end
