//
//  CSTUserToken.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>

@class RACSignal;

extern NSString *const CSTSavedUserTokenKey;

@interface CSTUserToken : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *tokenString;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *authValue;
@property (nonatomic, strong) NSDate *expireDate;

+ (void)saveToken:(CSTUserToken *)token;

+ (void)removeToken;

+ (CSTUserToken *)token;

+ (BOOL)isLogin;


@end
