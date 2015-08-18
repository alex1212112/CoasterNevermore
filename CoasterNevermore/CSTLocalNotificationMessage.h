//
//  CSTLocalNotificationMessage.h
//  Coaster
//
//  Created by Ren Guohua on 15/5/23.
//  Copyright (c) 2015年 ghren. All rights reserved.
//

#import  <Mantle/Mantle.h>

@interface CSTLocalNotificationMessage : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *zeroToFiftyMessage;
@property (nonatomic, copy) NSString *fiftyToHundredMessage;
@property (nonatomic, copy) NSString *overHundredMessage;

@property (nonatomic, assign) NSInteger periodIndex;

+ (NSArray *)messages;

+ (CSTLocalNotificationMessage *)messageWithIndex:(NSInteger)index;

@end
