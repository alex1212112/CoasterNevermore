//
//  CSTBasicCellModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CSTBasicCellModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *imageName;

@end
