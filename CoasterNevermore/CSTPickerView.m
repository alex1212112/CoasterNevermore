//
//  CSTPickerView.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTPickerView.h"

@implementation CSTPickerView



- (void)layoutSubviews{

    [super layoutSubviews];
    if ([self.subviews count] > 0) {
        
        ((UIView *)[self.subviews objectAtIndex:1]).backgroundColor = [UIColor lightTextColor];
        ((UIView *)[self.subviews objectAtIndex:2]).backgroundColor = [UIColor lightTextColor];
    }

}
@end
