//
//  CSTMessage.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/10.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTMessage : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *fromUid;
@property (nonatomic, copy) NSString *toUid;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *content;

@end
