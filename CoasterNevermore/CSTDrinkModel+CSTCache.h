//
//  CSTDrinkModel+CSTCache.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDrinkModel.h"

@interface CSTDrinkModel (CSTCache)


+ (void)cst_cacheDrinkModelArray:(NSArray *)array withFileName:(NSString *)fileName;

+ (void)cst_saveUserDrink:(NSDictionary *)drink withDocumentFilName:(NSString *)fileName;

+ (NSArray *)cst_userDrinkArrayWithDocumentFileName:(NSString *)fileName;

+ (NSArray *)cst_drinkModelArrayWithDocument:(NSString *)documentFileName cache:(NSString *)cacheFileName;

+ (NSArray *)cst_drinkModelArrayWithDocument:(NSString *)documentFileName currentModelArray:(NSArray *)modelArray;

+ (void)cst_removeItem:(id)item FromDocumentFile:(NSString *)fileName;

+ (NSArray *)cst_documentDrinkModelArrayWithDocument:(NSString *)documentFileName;

@end
