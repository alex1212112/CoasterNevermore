//
//  NSData+CSTParsedJsonDataSignal.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;

@interface NSData (CSTParsedJsonDataSignal)

- (RACSignal *)cst_parsedJsonDataSignal;
@end
