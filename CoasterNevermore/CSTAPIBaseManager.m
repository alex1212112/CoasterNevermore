//
//  CSTAPIBaseManager.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTAPIBaseManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTUserToken.h"

#pragma mark - CSTAPIBaseManager
@implementation CSTAPIBaseManager

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
    
        if ([self conformsToProtocol:@protocol(CSTAPIManager)]) {
            self.child = (id <CSTAPIManager>)self;
        }
        else
        {
            NSAssert(NO, @"subclass must implement <CSTAPIManager>");
        }
    }
    return self;
}

- (BOOL)needToken
{
    return NO;
}

#pragma mark - Public method
- (RACSignal *)fetchDataSignal
{
    
   return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       NSMutableURLRequest *request = [[CSTNetworkManager shareManager] requestWithMethod:[self.child requestMethod]
                  serializer:[AFHTTPRequestSerializer serializer]
               baseURLString:[self.child baseURLString]
                     apiName:[self.child apiName]
                  parameters:[self.child parameters]];
       
       if ([self needToken])
       {
           [request setValue:[CSTUserToken token].authValue forHTTPHeaderField:@"Authorization"];
       }
       if ([self.child respondsToSelector:@selector(httpHeaderFields)]) {
           
           [[self.child httpHeaderFields] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
               
               [request setValue:obj forHTTPHeaderField:key];
           }];
       }
       
       __unused NSURLSessionTask *task = [[CSTNetworkManager shareManager] dataTaskWithURLRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
           
           if (error)
           {
               [subscriber sendError:error];
           }
           else
           {
               [subscriber sendNext:responseObject];
               [subscriber sendCompleted];
           }
       }];
       return nil;
    }];
}

@end

#pragma mark - CSTLoginAPI
@implementation CSTLoginAPIManager

- (NSString *)apiName
{
    return @"token";
}
- (NSString *)baseURLString
{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod
{
    return @"POST";
}
@end

#pragma mark - CSTRegisterAPI
@implementation CSTRegisterAPIManager
- (NSString *)apiName
{
    return @"api/account/register";
}
- (NSString *)baseURLString
{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod
{
    return @"POST";
}

@end

#pragma mark -  CSTUserInfomationAPI
@implementation CSTUserInfomationAPIManager

- (NSString *)apiName
{
    return @"api/account/profile";
}
- (NSString *)baseURLString
{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod
{
    return @"GET";
}

- (BOOL)needToken
{
    return YES;
}

@end



#pragma mark - CSTSMSAPI

@implementation CSTSMSAPIManager

- (NSString *)apiName
{
    return @"api/account/sendcode";
}
- (NSString *)baseURLString
{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod
{
    return @"POST";
}

@end


#pragma mark -  CSTChangePasswordAPI
@implementation CSTChangePasswordAPIManager

- (NSString *)apiName
{
    return @"api/account/setpassword";
}
- (NSString *)baseURLString
{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod
{
    return @"POST";
}
@end

#pragma mark -  CSTUpdateUserInformationAPI
@implementation CSTUpdateUserInformationAPIManager

- (NSString *)apiName{
    return @"api/account/profile";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"PUT";
}

- (BOOL)needToken{
    return YES;
}

@end

#pragma mark -  CSTNCoinCountAPI
@implementation CSTNCoinCountAPIManager

- (NSString *)apiName{
    return @"api/score";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (NSDictionary *)parameters{

    return nil;
}

- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTRelationshipAPI
@implementation CSTRelationshipAPIManager

- (NSString *)apiName{
    return @"api/relationship";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (NSDictionary *)parameters{
    
    return @{@"expand":@"true"};
}

- (BOOL)needToken{
    return YES;
}
@end


#pragma mark -  CSTUserDrinkWaterAPI
@implementation CSTUserDrinkWaterAPIManager

- (NSString *)apiName{
    return @"api/drink";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTMateDrinkWaterAPI
@implementation CSTMateDrinkWaterAPIManager

- (NSString *)apiName{
    return @"api/drink/pair";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTWeatherAPI
@implementation CSTWeatherAPIManager

- (NSString *)apiName{
    return @"";
}
- (NSString *)baseURLString{
    return CSTWeatherBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}
@end

#pragma mark -  CSTUserSuggestWaterAPI
@implementation CSTUserSuggestWaterAPIManager

- (NSString *)apiName{
    return @"api/drink/suggest";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (BOOL)needToken{
    
    return YES;
}
@end


#pragma mark -  CSTMateSuggestWaterAPI
@implementation CSTMateSuggestWaterAPIManager

- (NSString *)apiName{
    return @"api/drink/pair/suggest";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (BOOL)needToken{
    
    return YES;
}
@end


#pragma mark -  CSTUploadUserSuggestWaterAPI
@implementation CSTUploadUserSuggestWaterAPIManager

- (NSString *)apiName{
    return @"api/drink/suggest";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

- (BOOL)needToken{
    
    return YES;
}
@end

#pragma mark -  CSTUploadUserAvatarAPI
@implementation CSTUploadUserAvatarAPIManager

- (NSString *)apiName{
    return @"api/avatar";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

- (BOOL)needToken{
    
    return YES;
}
@end

#pragma mark -  CSTUploadWaterAPI
@implementation CSTUploadWaterAPIManager

- (NSString *)apiName{
    return @"api/drink";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

- (BOOL)needToken{
    
    return YES;
}
@end

#pragma mark -  CSTBindDeviceAPI
@implementation CSTBindDeviceAPIManager

- (NSString *)apiName{
    return @"api/device";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

- (BOOL)needToken{
    
    return YES;
}
@end

#pragma mark -  CSTDeleteDeviceAPI
@implementation CSTDeleteDeviceAPIManager

- (NSString *)apiName{
    return @"api/device";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"DELETE";
}

- (NSDictionary *)parameters{

    return nil;
}
- (BOOL)needToken{
    
    return YES;
}
@end


#pragma mark -  CSTBLEFirmwareVersionAPI
@implementation CSTBLEFirmwareVersionAPIManager

- (NSString *)apiName{
    return @"api/version/bluetooth";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (NSDictionary *)parameters{
    
    return nil;
}
@end

#pragma mark -  CSTHealthDrinkAPI
@implementation CSTHealthDrinkAPIManager

- (NSString *)apiName{
    return @"api/drinkhealths/summary";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (BOOL)needToken{
    
    return YES;
}
@end

#pragma mark -  CSTHealthRankAPI
@implementation CSTHealthRankAPIManager

- (NSString *)apiName{
    return @"api/drinkhealths/rank";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

- (BOOL)needToken{
    
    return YES;
}
@end


#pragma mark -  CSTUploadHealthDrink
@implementation CSTUploadHealthDrinkAPIManager

- (NSString *)apiName{
    return @"api/drinkhealths";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

- (BOOL)needToken{
    
    return YES;
}

@end

#pragma mark -  CSTLocalAccessTokenFrom3rd
@implementation CSTLocalAccessTokenFrom3rdAPIManager

- (NSString *)apiName{
    return @"api/account/ObtainLocalAccessToken";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"GET";
}

@end

#pragma mark -  CSTRegisterWith3rdParty
@implementation CSTRegisterWith3rdPartyAPIManager

- (NSString *)apiName{
    return @"api/account/RegisterExternal";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

@end

#pragma mark -  CSTBind3rdPartyAPI
@implementation CSTBind3rdPartyAPIManager

- (NSString *)apiName{
    return @"api/account/BindExternal";
}
- (NSString *)baseURLString{
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

@end

#pragma mark -  CSTUploadDrinkToQQAPI
@implementation CSTUploadDrinkToQQAPIManager

- (NSString *)apiName{
    return @"";
}
- (NSString *)baseURLString{
    return CSTQQHealthBaseURLString;
}
- (NSString *)requestMethod{
    return @"POST";
}

@end

#pragma mark -  CSTUploadNcoinsAPI
@implementation CSTUploadNcoinsAPIManager

- (NSString *)apiName{
    
    return @"api/score";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"PUT";
}
- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTRefuseRelationshipAPI
@implementation CSTRefuseRelationshipAPIManager

- (NSString *)apiName{
    
    return @"api/relationship/denyRequest";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"POST";
}
- (BOOL)needToken{
    return YES;
}

@end

#pragma mark -  CSTAcceptRelationshipAPI
@implementation CSTAcceptRelationshipAPIManager

- (NSString *)apiName{
    
    return @"api/relationship/acceptRequest";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"POST";
}
- (BOOL)needToken{
    return YES;
}

@end


#pragma mark -  CSTDeleteRelationshipAPI
@implementation CSTDeleteRelationshipAPIManager

- (NSString *)apiName{
    
    return @"api/relationship";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"DELETE";
}

- (NSDictionary *)parameters{
    
    return nil;
}

- (BOOL)needToken{
    return YES;
}

@end

#pragma mark -  CSTInviteRelationship
@implementation CSTInviteRelationshipAPIManager

- (NSString *)apiName{
    
    return @"api/relationship/sendrequest";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"POST";
}

- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTCancelRelationshipAPI
@implementation CSTCancelRelationshipAPIManager

- (NSString *)apiName{
    
    return @"api/relationship/cancelRequest";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"POST";
}

- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTSendMessageToMate
@implementation CSTSendMessageToMateAPIManager

- (NSString *)apiName{
    
    return @"api/relationship/notification";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"POST";
}

- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTFeedBackAPI
@implementation CSTFeedBackAPIManager

- (NSString *)apiName{
    
    return @"api/feedback";
}
- (NSString *)baseURLString{
    
    return CSTCoasterBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"POST";
}

- (BOOL)needToken{
    return YES;
}
@end

#pragma mark -  CSTAQIAPI

static NSString *const CSTAQIAPPKey = @"8bbca4a2a5e4a3c2be788b90dd961a71";
@implementation CSTAQIAPIManager

- (NSString *)apiName{
    
    return @"";
}
- (NSString *)baseURLString{
    
    return CSTAQIBaseURLString;
}
- (NSString *)requestMethod{
    
    return @"GET";
}

- (NSDictionary *)httpHeaderFields{

    return @{@"apikey" : CSTAQIAPPKey};
}


@end






