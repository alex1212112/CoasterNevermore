//
//  CSTTodayWaterDataViewController.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSTMainDataViewModel;

@interface CSTMainDataViewController : UIViewController

@property (nonatomic, strong) CSTMainDataViewModel *viewModel;

- (void)resetOffset;

- (void)showRightViewController;

- (void)refreshCurrentPageData;

- (BOOL)isShowRightViewController;


@end
