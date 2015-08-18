//
//  CSTValidateHelper.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTValidateHelper.h"

@implementation CSTValidateHelper

#pragma Validate Method

+ (BOOL)isPhoneNumberValid:(NSString *)username
{
    if (!username)
    {
        return NO;
    }
    if (username.length != 11)
    {
        return NO;
    }
    if (![username hasPrefix:@"1"])
    {
        return NO;
    }
    
    return YES;
}
+ (BOOL)isPasswordValid:(NSString *)password
{
    if (!password)
    {
        return NO;
    }
    if (password.length < 6)
    {
        return NO;
    }
    if (password.length > 11)
    {
        return NO;
    }
    return YES;
}
+ (BOOL)isVerifiedCodeValid:(NSString *)verifiedCode;
{
    if (!verifiedCode)
    {
        return NO;
    }
    if (verifiedCode.length != 6)
    {
        return NO;
    }
    return YES;
}


@end
