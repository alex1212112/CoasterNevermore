//
//  CSTValidateHelper.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSTValidateHelper : NSObject

+ (BOOL)isPhoneNumberValid:(NSString *)username;
+ (BOOL)isPasswordValid:(NSString *)password;
+ (BOOL)isVerifiedCodeValid:(NSString *)verifiedCode;

@end
