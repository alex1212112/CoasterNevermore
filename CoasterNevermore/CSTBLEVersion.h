//
//  CSTBLEVersion.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTBLEVersion : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *downloadAddressA;
@property (nonatomic, copy) NSString *downloadAddressB;
@property (nonatomic, copy) NSString *type;

@end
