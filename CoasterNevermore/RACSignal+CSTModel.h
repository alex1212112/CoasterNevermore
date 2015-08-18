//
//  RACSignal+CSTModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <ReactiveCocoa.h>

@interface RACSignal (CSTModel)

+ (RACSignal *)cst_transformSignalWithModelClass:(Class)modelClass dictionary:(NSDictionary *)dic;

+ (RACSignal *)cst_transformToModelArraySignalWithModelClass:(Class)modelClass dicArray:(NSArray *)dics;

@end
