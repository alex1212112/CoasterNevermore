//
//  CSTHealthRank.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/23.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>


@interface CSTHealthRank : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *score;
@property (nonatomic, copy) NSNumber *rank;
@end
