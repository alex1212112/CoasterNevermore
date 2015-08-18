//
//  CSTFindPasswordViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTFindPasswordViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTValidateHelper.h"
#import "CSTAPIBaseManager.h"
#import "CSTNetworking.h"
#import "DXAlertView.h"
#import "Colours.h"
#import "NSData+CSTParsedJsonDataSignal.h"

@implementation CSTFindPasswordViewModel


#pragma Public method
- (RACSignal *)validateSignal
{

    return  [RACSignal combineLatest:
             @[RACObserve(self, userName),
               RACObserve(self, verifiedCode),
               RACObserve(self, currentPassword)]
                       reduce:^id(NSString *username, NSString *verifiedCode,NSString *password){
                           
                           return @([CSTValidateHelper isPhoneNumberValid:username] && [CSTValidateHelper isPasswordValid:verifiedCode] && [CSTValidateHelper isPasswordValid:password]);
                           
                       }];

}

- (RACSignal *)changePasswordSignal
{
    
    @weakify(self);
    
    return [[[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        
        @strongify(self);
        
        return [self p_changePasswordSignal];
        
    }] doNext:^(id x) {
        
        [self p_showAlertViewWithTitle:@"密码修改成功" titleColor:[UIColor grassColor] content:@"恭喜您,密码修改成功!" buttonTitle:@"确定"];
        
    }] doError:^(NSError *error) {
        
        [self p_handleError:error WithType:CSTChangePasswordErrorChange];
    }];
}

- (RACSignal *)smsSignal
{
    @weakify(self);
    return [[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self p_smsSignal];
    }] doError:^(NSError *error) {
        
        [self p_handleError:error WithType:CSTChangePasswordErrorSMS];
    }];
}


#pragma  Private method

- (void)p_handleError:(NSError *)error WithType:(CSTChangePasswordEventErrorType)type
{
    if (error.code == CSTNotReachableCode)
    {
        DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:@"无网络连接" contentText:@"请检查网络连接是否正常" leftButtonTitle:nil rightButtonTitle:@"确定"];
        alertView.alertTitleLabel.textColor = [UIColor redColor];
        
        [alertView show];
        return;
    }
    
    if (type == CSTChangePasswordErrorChange)
    {
        [self p_showAlertViewWithTitle:@"密码修改失败" titleColor:[UIColor redColor] content:@"密码修改失败" buttonTitle:@"确定"];
        return;
    }
    
    if (type == CSTChangePasswordErrorSMS)
    {
        NSData *errorResponseBody = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        @weakify(self);
        [[errorResponseBody cst_parsedJsonDataSignal] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = x;
            NSString *code = dic[@"CustomErrorCode"];
            NSInteger codenumber = [code integerValue];
            if(codenumber == 5011 || codenumber == 5142)
            {
                [self p_showAlertViewWithTitle:@"获取验证码失败" titleColor:[UIColor redColor]  content:@"获取验证码太频繁,请稍候再试" buttonTitle:@"确定"];
            }
            else
            {
                [self p_showAlertViewWithTitle:@"获取验证码失败"  titleColor:[UIColor redColor] content:@"有可能网络出现了故障，请换个网络或稍候再试" buttonTitle:@"确定"];
            }
        }];
        return;
    }
    
}


- (void)p_showAlertViewWithTitle:(NSString *)title titleColor:(UIColor *)color content:(NSString *)content  buttonTitle:(NSString *)buttonTitle
{
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:nil rightButtonTitle:buttonTitle];
    alertView.alertTitleLabel.textColor = color;
    
    [alertView show];
}

- (NSDictionary *)p_changePasswordAPIParameters
{
    return  @{
              @"phone":self.userName,
              @"newpassword":self.currentPassword,
              @"code":self.verifiedCode,
              };

}
- (NSDictionary *)p_smsAPIParamters
{
    return @{
             @"phone" : self.userName,
             @"type" : @2
             };
}

- (RACSignal *)p_changePasswordSignal
{
    CSTChangePasswordAPIManager *apiManager = [[CSTChangePasswordAPIManager alloc] init];
    apiManager.parameters = [self p_changePasswordAPIParameters];
    
    return [apiManager fetchDataSignal];
}

- (RACSignal *)p_smsSignal
{
    CSTSMSAPIManager *smsSignal = [[CSTSMSAPIManager alloc] init];
    smsSignal.parameters = [self p_smsAPIParamters];
    
    return [smsSignal fetchDataSignal];
}

@end
