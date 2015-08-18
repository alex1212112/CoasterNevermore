//
//  CSTAPIBaseManager.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSTNetworking.h"

@class RACSignal;

@protocol CSTAPIManager <NSObject>

@required
- (NSString *)apiName;
- (NSString *)baseURLString;
- (NSString *)requestMethod;
- (NSDictionary *)parameters;
@optional
- (NSDictionary *)httpHeaderFields;
@end



@interface CSTAPIBaseManager : NSObject

@property (nonatomic, weak) NSObject<CSTAPIManager> *child; //里面会调用到NSObject的方法，所以这里不用id
- (RACSignal *)fetchDataSignal;
- (BOOL)needToken;
@end


@interface CSTLoginAPIManager :CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTRegisterAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTUserInfomationAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end


@interface CSTSMSAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;


@end

@interface CSTChangePasswordAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTUpdateUserInformationAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTNCoinCountAPIManager : CSTAPIBaseManager <CSTAPIManager>

@end

@interface CSTRelationshipAPIManager : CSTAPIBaseManager <CSTAPIManager>

@end

@interface CSTUserDrinkWaterAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTMateDrinkWaterAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTWeatherAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end


@interface CSTUserSuggestWaterAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTMateSuggestWaterAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTUploadUserSuggestWaterAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTUploadUserAvatarAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTUploadWaterAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTBindDeviceAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTDeleteDeviceAPIManager : CSTAPIBaseManager <CSTAPIManager>

@end

@interface CSTBLEFirmwareVersionAPIManager : CSTAPIBaseManager <CSTAPIManager>

@end


@interface CSTHealthDrinkAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTHealthRankAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTUploadHealthDrinkAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTLocalAccessTokenFrom3rdAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTRegisterWith3rdPartyAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTBind3rdPartyAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end


@interface CSTUploadDrinkToQQAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTUploadNcoinsAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTRefuseRelationshipAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTAcceptRelationshipAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTDeleteRelationshipAPIManager : CSTAPIBaseManager <CSTAPIManager>

@end

@interface CSTInviteRelationshipAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTCancelRelationshipAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTSendMessageToMateAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTFeedBackAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@interface CSTAQIAPIManager : CSTAPIBaseManager <CSTAPIManager>

@property (nonatomic, strong) NSDictionary *parameters;

@end







