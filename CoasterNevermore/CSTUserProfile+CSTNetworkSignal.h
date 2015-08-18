//
//  CSTUserProfile+CSTNetworkSignal.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/8.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserProfile.h"
@class RACSignal;

@interface CSTUserProfile (CSTNetworkSignal)

+ (RACSignal *)cst_networkDataSignalWithUid:(NSString *)uid;

@end
