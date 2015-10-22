//
//  CSTBLEConnectViewController.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/23.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSTBLEConnectViewModel;

@protocol CSTBLEConnectDelegate <NSObject>

- (void)userDidCancelScan;

@end


@interface CSTBLEConnectViewController : UIViewController <CSTBLEConnectDelegate>

@property (nonatomic, strong) CSTBLEConnectViewModel *viewModel;

@end
