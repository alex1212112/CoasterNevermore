//
//  CSTBLEVersion+CSTNetworkSignal.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBLEVersion.h"
@class RACSignal;
@interface CSTBLEVersion (CSTNetworkSignal)

+ (RACSignal *)cst_serviceFirmwareVersionSignal;


@end
