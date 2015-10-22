//
//  RACSignal+CSTModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "RACSignal+CSTModel.h"
#import <Mantle/Mantle.h>
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>

@implementation RACSignal (CSTModel)

+ (RACSignal *)cst_transformSignalWithModelClass:(Class)modelClass dictionary:(NSDictionary *)dic
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSError *error = nil;
        id model =  [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:dic error:&error];
        
        if (error)
        {
            [subscriber sendError:error];
        }
        [subscriber sendNext:model];
        [subscriber sendCompleted];
        return nil;
    }];
}

+ (RACSignal *)cst_transformToModelArraySignalWithModelClass:(Class)modelClass dicArray:(NSArray *)dics{
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSArray *modelArray = [dics linq_select:^id(id item) {
            
            return [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:item error:nil];
        }];
        
        [subscriber sendNext:modelArray];
        [subscriber sendCompleted];
        return nil;
    }];
}
@end
