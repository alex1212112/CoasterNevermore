//
//  CSTQQToken.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

extern NSString *const CSTSavedQQTokenKey;

@interface CSTQQToken : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *accesstoken;
@property (nonatomic, copy) NSString *openid;
@property (nonatomic, strong) NSNumber *accesstokenexpiretime;

- (instancetype)initWithToken:(NSString*)token openId:(NSString *)openId expiretime:(NSNumber *)expiretime;

+ (void)saveToken:(CSTQQToken *)token;

+ (void)removeToken;

+ (CSTQQToken *)token;

@end
