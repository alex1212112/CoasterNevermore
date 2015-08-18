//
//  CSTDayPeriod.h
//  Coaster
//
//  Created by Ren Guohua on 15/5/23.
//  Copyright (c) 2015年 ghren. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTDayPeriod : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, assign) NSInteger periodIndex;

- (instancetype)initWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime periodIndex:(NSInteger)index;

@end
