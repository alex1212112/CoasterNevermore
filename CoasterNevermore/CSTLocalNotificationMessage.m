//
//  CSTLocalNotificationMessage.m
//  Coaster
//
//  Created by Ren Guohua on 15/5/23.
//  Copyright (c) 2015年 ghren. All rights reserved.
//

#import "CSTLocalNotificationMessage.h"

@implementation CSTLocalNotificationMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"zeroToFiftyMessage" : @"zeroToFiftyMessage",
             @"fiftyToHundredMessage" : @"fiftyToHundredMessage",
             @"overHundredMessage" : @"overHundredMessage",
             @"periodIndex" : @"periodIndex"
             };
}

+ (NSArray *)messages
{
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"DefaltLocalNotificationMessages"  withExtension:@"plist"];
    
    NSArray *array = [NSArray arrayWithContentsOfURL:filePath];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {

        CSTLocalNotificationMessage *message = [MTLJSONAdapter modelOfClass:[CSTLocalNotificationMessage class] fromJSONDictionary:dic error:nil];

        [mutableArray addObject:message];
    }];
    
    if ([mutableArray count] >0)
    {
        return [NSArray arrayWithArray:mutableArray];
    }
    return nil;
}


+ (CSTLocalNotificationMessage *)messageWithIndex:(NSInteger)index
{
    NSArray *array = [CSTLocalNotificationMessage messages];
    
    if (index < [array count])
    {
        return array[index];
    }

    return nil;
}
@end
