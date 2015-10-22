//
//  CSTDrinkModel+CSTCache.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDrinkModel+CSTCache.h"
#import "GHCache.h"
#import "GHDocumentCache.h"
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import "NSArray+CSTExtention.h"

@implementation CSTDrinkModel (CSTCache)

+ (void)cst_cacheDrinkModelArray:(NSArray *)array withFileName:(NSString *)fileName{

    if ([array count] > 0) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [[GHCache shareCache] cacheData:data tofile:fileName];
    }
}

+ (NSArray *)cst_cachedArrayWithFileName:(NSString *)fileName{

    NSData *data = [[GHCache shareCache] dataFromFile:fileName];
    
    if (!data) {
        
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
}


+ (void)cst_saveUserDrink:(NSDictionary *)drink withDocumentFilName:(NSString *)fileName
{

    NSMutableArray *waterArray = [NSMutableArray arrayWithArray:[CSTDrinkModel cst_userDrinkArrayWithDocumentFileName:fileName]];
    if (!waterArray)
    {
        waterArray = [NSMutableArray array];
    }
    [waterArray addObject:drink];
    
    NSData *waterData =  [NSKeyedArchiver archivedDataWithRootObject:waterArray];
    
    [[GHDocumentCache shareCache] cacheData:waterData tofile:fileName];
}


+ (NSArray *)cst_userDrinkArrayWithDocumentFileName:(NSString *)fileName{
    
    NSData *waterData = [[GHDocumentCache shareCache] dataFromFile:fileName];
    if (!waterData)
    {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:waterData];
}

+ (NSArray *)cst_drinkModelArrayWithDocument:(NSString *)documentFileName cache:(NSString *)cacheFileName{

    NSArray *cacheArray = [CSTDrinkModel cst_cachedArrayWithFileName:cacheFileName];
    return [CSTDrinkModel cst_drinkModelArrayWithDocument:documentFileName currentModelArray:cacheArray];
}

+ (NSArray *)cst_drinkModelArrayWithDocument:(NSString *)documentFileName currentModelArray:(NSArray *)modelArray{
    
    NSArray *documentModelArray = [CSTDrinkModel cst_documentDrinkModelArrayWithDocument:documentFileName];
    
    return [[modelArray linq_concat:documentModelArray] cst_distinctAndSortResultWithKeyPath:@"date"];
}

+ (void)cst_removeItem:(id)item FromDocumentFile:(NSString *)fileName
{
    NSMutableArray *waterArray = [NSMutableArray arrayWithArray:[CSTDrinkModel cst_userDrinkArrayWithDocumentFileName:fileName]];
    if (!waterArray)
    {
        return;
    }
    [waterArray removeObject:item];
    
    
    if ([waterArray count] <= 0)
    {
        [[GHDocumentCache shareCache] clearCacheWithFile:fileName];
    }
    else
    {
        NSData *waterData =  [NSKeyedArchiver archivedDataWithRootObject:waterArray];
        [[GHDocumentCache shareCache] cacheData:waterData tofile:fileName];
    }
}

+ (NSArray *)cst_documentDrinkModelArrayWithDocument:(NSString *)documentFileName{

    NSArray *documentArray = [CSTDrinkModel cst_userDrinkArrayWithDocumentFileName:documentFileName];
    
    return [documentArray linq_select:^id(id item) {
        
        return [MTLJSONAdapter modelOfClass:[CSTDrinkModel class] fromJSONDictionary:item error:nil];
    }];
}

@end
