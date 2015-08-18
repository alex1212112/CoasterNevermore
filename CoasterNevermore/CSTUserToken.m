//
//  CSTUserToken.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserToken.h"
#import <ReactiveCocoa.h>

NSString *const CSTSavedUserTokenKey = @"CSTSavedUserTokenKey";

@implementation CSTUserToken

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"tokenString" : @"access_token",
             @"tokenType" : @"token_type",
             @"expireDate" : @"expires",
             @"uid" :@"uid"
             };
}

+ (NSValueTransformer *)expireDateJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        return [dateFormat dateFromString:value];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSString stringWithFormat:@"%@",value];
    }];
}

- (NSString *)authValue
{
    return [NSString stringWithFormat:@"%@ %@", _tokenType ?:@"",_tokenString ?: @""];
}

+ (NSSet *)keyPathsForValuesAffectingAuthValue
{
    return [NSSet setWithObjects:@"tokenType", @"tokenString",nil];
}


+ (CSTUserToken *)token
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:CSTSavedUserTokenKey];
    
    if (!data) {
        
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (void)saveToken:token
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:CSTSavedUserTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeToken
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CSTSavedUserTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isLogin
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:CSTSavedUserTokenKey];
    if (data)
    {
        return YES;
    }
    return NO;
}



@end
