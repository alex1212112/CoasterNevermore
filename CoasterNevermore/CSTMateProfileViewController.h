//
//  CSTMateProfileViewController.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/3.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSTMateProfileViewModel;

@interface CSTMateProfileViewController : UIViewController

@property (nonatomic, strong) CSTMateProfileViewModel *viewModel;

- (void)refreshCurrentPageData;

@end
