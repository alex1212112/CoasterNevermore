//
//  CSTHealthDrink.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/24.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTHealthDrink : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *healthDays;

@end
