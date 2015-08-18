//
//  CSTMainContentViewController.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/29.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSTMainContentViewModel;

@interface CSTMainContentViewController : UIViewController

@property (nonatomic, strong) CSTMainContentViewModel *viewModel;


- (void)reAnimateSubviews;

@end
