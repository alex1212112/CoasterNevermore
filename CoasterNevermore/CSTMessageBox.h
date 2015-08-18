//
//  CSTMessageBox.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CSTMessageBox : UIView

@property (nonatomic, copy) dispatch_block_t doneBlock;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;


- (void)showInView:(UIView *)view;
- (void)hideInView:(UIView *)view;
+ (instancetype)showInView:(UIView *)view;
+ (void)hideInview:(UIView *)view;


@end
