//
//  CSTUserAccessViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;
@class CSTUserProfile;

extern NSString *const CSTQQLoginErrorWrongParameterKey;
extern const NSInteger CSTQQLoginErrorWrongParameterCode;

typedef NS_ENUM(NSInteger, CSTAccessType) {
    CSTAccessTypeLogin,
    CSTAccessTypeRegister,
};


typedef NS_ENUM(NSInteger, CSTAccessEventErrorType) {
    CSTAccessEventErrorLogin,
    CSTAccessEventErrorRegister,
    CSTAccessEventErrorSMS,
};
@protocol CSTThirdPartyLoginDelegate <NSObject>

@required

- (void)userDidLoginWithUserProfile:(CSTUserProfile *)userProfile;

@end

@interface CSTUserAccessViewModel : NSObject

@property (nonatomic, assign) CSTAccessType accessType;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *verifiedCode;
@property (nonatomic, weak) id <CSTThirdPartyLoginDelegate> delegate;

@property (nonatomic, copy) NSDictionary *qqTokenParameters;

- (instancetype)initWithAccessType:(CSTAccessType)type userName:(NSString *)username password:(NSString *)password verifiedCode:(NSString *)verifiedCode;

- (RACSignal *)loginSignal;

- (RACSignal *)registerSignal;

- (RACSignal *)validateSignal;

- (RACSignal *)smsSignal;

- (RACSignal *)relationShipAndMateProfileSignal;


- (void)handleError:(NSError *)error withEventType:(CSTAccessEventErrorType)errorType;

- (void)configBLEWithUserProfile:(CSTUserProfile *)userProfile;


- (RACSignal *)qqTokenSignalWithViewController:(id)loginVC;

- (RACSignal *)qqLoginSignalWithQQTokenDic:(NSDictionary *)dic;


@end
