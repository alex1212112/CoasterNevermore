//
//  CSTAQI.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTAQI : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *core;

@property (nonatomic, assign) NSInteger aqi;
@end
