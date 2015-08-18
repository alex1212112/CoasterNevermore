//
//  CSTIOSDevice.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/3.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTIOSDevice.h"

const NSInteger kiPhone6Width = 375;
const NSInteger kiPhone6PWidth = 414;
const NSInteger kiPhone5Width = 320;

@implementation CSTIOSDevice

+ (BOOL)isIPhone5{
    
    return (CGRectGetWidth([UIScreen mainScreen].bounds) == kiPhone5Width);
    
}
+ (BOOL)isIPhone6{
    
    return (CGRectGetWidth([UIScreen mainScreen].bounds) == kiPhone6Width);

}
+ (BOOL)isIPhone6P{

    return (CGRectGetWidth([UIScreen mainScreen].bounds) == kiPhone6PWidth);
}

+ (CGFloat)systemVersion{

    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGRect)mainScreenBounds{

    return [[UIScreen mainScreen] bounds];
}

@end
