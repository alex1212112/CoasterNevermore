//
//  NSArray+CSTExtention.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "NSArray+CSTExtention.h"
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>

@implementation NSArray (CSTExtention)


- (NSArray *)cst_distinctAndSortResultWithKeyPath:(NSString *)keyPath{
    
    
    if (!keyPath) {
        
        return [[self linq_distinct] linq_sort];
    }
    
    return [[self linq_distinct:^id(id item) {
        
        return [item valueForKeyPath:keyPath];
        
    }] linq_sort:^id(id item) {
        
        return [item valueForKeyPath:keyPath];
    }];
}
@end
