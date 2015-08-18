//
//  CSTRelationship.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/9.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTRelationship : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *status;
@property (nonatomic, copy) NSString *fromUid;
@property (nonatomic, copy) NSString *toUid;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *fromNickname;
@property (nonatomic, copy) NSString *toNickname;

@end
