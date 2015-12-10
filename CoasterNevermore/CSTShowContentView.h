//
//  CSTShowContentView.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/11/4.
//  Copyright © 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTShowContentView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *cancelTitle;

@property (nonatomic, strong) UIImage *image;


- (void)show;

- (void)dismiss;

@end
