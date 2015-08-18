//
//  CSTDrinkModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/10.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTDrinkModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *weight;

- (instancetype)initWithDate:(NSDate *)date weight:(NSNumber *)weight;

@end
