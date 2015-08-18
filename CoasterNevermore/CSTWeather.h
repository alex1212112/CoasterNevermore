//
//  CSTWeather.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/11.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTWeather : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *maxTemp;
@property (nonatomic, copy) NSString *minTemp;
@property (nonatomic, copy) NSString *temp;
@property (nonatomic, copy) NSNumber *humidity;
@property (nonatomic, copy) NSString *weatherDescription;
@property (nonatomic, copy) NSString *iconName;

@end
