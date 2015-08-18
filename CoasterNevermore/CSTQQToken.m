//
//  CSTQQToken.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTQQToken.h"

NSString *const CSTSavedQQTokenKey = @"CSTSavedQQTokenKey";

@implementation CSTQQToken

- (instancetype)initWithToken:(NSString*)token openId:(NSString *)openId expiretime:(NSNumber *)expiretime
{
    if (self = [super init])
    {
        _accesstoken = token;
        _openid = openId;
        _accesstokenexpiretime = expiretime;
        
    }
    return self;
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"accesstoken" : @"accessToken",
             @"openid" : @"usid",
             @"accesstokenexpiretime" : @"accesstokenexpiretime"
             };
    
}

+ (CSTQQToken *)token
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:CSTSavedQQTokenKey];
    
    if (data) {
     
         return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

+ (void)saveToken:token
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:CSTSavedQQTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeToken
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CSTSavedQQTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
