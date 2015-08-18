//
//  NSString+CSTExtention.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/28.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "NSString+CSTExtention.h"

@implementation NSString (CSTExtention)


- (CGRect)cst_rectWithFont:(UIFont *)font width:(CGFloat)width{
    
    return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil];
}

- (CGRect)cst_rectWithFont:(UIFont *)font height:(CGFloat)height{
    
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil];

}
@end
