//
//  CSTBLEScanResultViewController.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVBlurViewController.h"
#import "CSTBLEConnectViewController.h"
@class CSTBLEScanResultViewModel;

@interface CSTBLEScanResultViewController : VVBlurViewController

@property (nonatomic, strong) CSTBLEScanResultViewModel *viewModel;

@property (nonatomic, weak) id <CSTBLEConnectDelegate> delegate;

@end
