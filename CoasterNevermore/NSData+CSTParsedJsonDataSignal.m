//
//  NSData+CSTParsedJsonDataSignal.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "NSData+CSTParsedJsonDataSignal.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation NSData (CSTParsedJsonDataSignal)

- (RACSignal *)cst_parsedJsonDataSignal;
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSError *error = nil;
        
        id parsedData = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableLeaves error:&error];
        
        if ([parsedData isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *mutableDictionary = [parsedData mutableCopy];
            [(NSDictionary *)parsedData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isKindOfClass:[NSString class]])
                {
                    if ([(NSString* )key rangeOfString:@"."].location != NSNotFound) {
                        
                       NSString *newKey = [(NSString *)key stringByReplacingOccurrencesOfString:@"." withString:@""];
                        [mutableDictionary setObject:obj forKey:newKey];
                    }
                }
            }];
            parsedData = [mutableDictionary copy];
        }
        
        if (error)
        {
            [subscriber sendError:error];
        }
        else if (parsedData)
        {
            [subscriber sendNext:parsedData];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}



@end
