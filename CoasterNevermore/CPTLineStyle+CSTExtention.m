//
//  CPTLineStyle+CSTExtention.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/27.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CPTLineStyle+CSTExtention.h"

@implementation CPTLineStyle (CSTExtention)

+ (CPTLineStyle *)cst_linestyleWithColor:(CPTColor *)color width:(CGFloat)lineWidth{

    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = color;
    lineStyle.lineWidth = lineWidth;
    
    return [lineStyle copy];
}
@end
