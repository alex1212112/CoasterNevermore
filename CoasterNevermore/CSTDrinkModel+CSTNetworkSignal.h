//
//  CSTDrinkModel+CSTNetworkSignal.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDrinkModel.h"
@class RACSignal;

@interface CSTDrinkModel (CSTNetworkSignal)

+ (RACSignal *)cst_todayUserDrinkWaterSignal;

+ (RACSignal *)cst_todayMateDrinkWaterSignal;

+ (RACSignal *)cst_userDrinkWaterSignalWithDate:(NSDate *)date;

+ (void)cst_uploadDocumentData;

@end
