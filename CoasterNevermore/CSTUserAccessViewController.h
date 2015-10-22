//
//  CSTUserAccessViewController.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import UIKit;
#import "CSTUserAccessViewModel.h"
@class RACSignal;

@interface CSTUserAccessViewController : UIViewController <CSTThirdPartyLoginDelegate>

@property (nonatomic, strong) CSTUserAccessViewModel *viewModel;

- (RACSignal *)qqLoginSignalWithQQTokenDic:(NSDictionary *)qqToken;

- (RACSignal *)qqLoginSignal;

@end
