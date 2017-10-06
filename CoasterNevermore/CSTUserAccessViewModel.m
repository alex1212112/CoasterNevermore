//
//  CSTUserAccessViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserAccessViewModel.h"
#import "CSTAPIBaseManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSData+CSTParsedJsonDataSignal.h"
#import "CSTUserToken.h"
#import <Mantle/Mantle.h>
#import "RACSignal+CSTModel.h"
#import "CSTValidateHelper.h"
#import "CSTUserProfile.h"
#import "CSTUserProfile+CSTNetworkSignal.h"
#import "CSTNetworking.h"
#import "DXAlertView.h"
#import "CSTDataManager.h"
#import "CSTBLEManager.h"
#import "UMSocial.h"
#import "CSTQQToken.h"
#import "UIImage+CSTTransformBase64String.h"
#import <SDWebImage/SDWebImageManager.h>
#import "MBProgressHUD.h"
#import "CSTLocalNotification.h"


NSString *const CSTQQLoginErrorWrongParameterKey = @"com.nevermore.Coaster.error.qqLoginWrongParameterKey";

const NSInteger CSTQQLoginErrorWrongParameterCode = 10030404;

@interface CSTUserAccessViewModel ()

@property (nonatomic, copy) NSString *qqLoginPhone;

@end

@implementation CSTUserAccessViewModel

#pragma Life cycle
- (instancetype)initWithAccessType:(CSTAccessType)type userName:(NSString *)username password:(NSString *)password verifiedCode:(NSString *)verifiedCode
{
    if (self = [super init])
    {
        _accessType = type;
        _userName = username;
        _password = password;
        _verifiedCode = verifiedCode;
    }
    return self;
}

#pragma Public method
- (RACSignal *)loginSignal
{
    @weakify(self);
    
    return [[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        
        @strongify(self);
        
        return [self p_loginSignal];
    }];
}


- (RACSignal *)registerSignal
{
    @weakify(self);
    return [[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self p_registerSignal];
    }];
}

- (RACSignal *)smsSignal
{
    @weakify(self);
    return [[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self p_smsSignal];
    }];
}


- (RACSignal *)validateSignal
{
    return [RACSignal combineLatest:
             @[RACObserve(self, accessType),
               RACObserve(self, userName),
               RACObserve(self, password),
               RACObserve(self, verifiedCode)]
                              reduce:^id(NSNumber *accessType,NSString *username, NSString *password,NSString *verifiedCode){
                                  
                                  return ((CSTAccessType)[accessType integerValue]) == CSTAccessTypeLogin ? @([CSTValidateHelper isPhoneNumberValid:username] && [CSTValidateHelper isPasswordValid:password]) : @([CSTValidateHelper isPhoneNumberValid:username] && [CSTValidateHelper isPasswordValid:password] && [CSTValidateHelper isVerifiedCodeValid:verifiedCode]);
                              }];

}


- (RACSignal *)relationShipAndMateProfileSignal{

    return [[CSTDataManager refreshRelationshipSignal] flattenMap:^RACStream *(id value) {
        
         return [CSTDataManager refreshMateProfileSignalWithRelationship:value];
    }];
}

- (void)handleError:(NSError *)error withEventType:(CSTAccessEventErrorType)errorType
{

    if (error.code == CSTNotReachableCode)
    {
        [self p_showAlertViewWithTitle:@"无网络连接" content:@"请检查网络连接是否正常" buttonTitle:@"确定"];
        return;
    }
    
    
    if (errorType == CSTAccessEventErrorLogin)
    {
        
        if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
            if (response.statusCode == 400) {
                
                [self p_showAlertViewWithTitle:@"登录失败" content:@"用户名或密码错误" buttonTitle:@"确定"];
            }else{
            
                [self p_showAlertViewWithTitle:@"登录失败" content:@"用户名或密码错误" buttonTitle:@"确定"];
            }
        }
        else
        {
            [self p_showAlertViewWithTitle:@"登录失败" content:@"用户名或密码错误" buttonTitle:@"确定"];
        }
        
        return;
    }
    
    if (errorType == CSTAccessEventErrorRegister)
    {
        if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
            if (response.statusCode == 400) {
        
                [self p_showAlertViewWithTitle:@"注册失败" content:@"注册时发生错误,可能该号码已经被注册" buttonTitle:@"确定"];
            }else{
            
                [self p_showAlertViewWithTitle:@"注册失败" content:@"注册时发生错误,可能该号码已经被注册" buttonTitle:@"确定"];
            }
        }
        else
        {
            [self p_showAlertViewWithTitle:@"注册失败" content:@"注册时发生错误,有可能网络出现了故障，请换个网络或稍候再试" buttonTitle:@"确定"];
        }
        
        return;
    }
    
    if (errorType == CSTAccessEventErrorSMS)
    {
        NSData *errorResponseBody = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        @weakify(self);
        
        if (!errorResponseBody) {
            
            [self p_showAlertViewWithTitle:@"获取验证码失败" content:@"有可能网络出现了故障，请换个网络或稍候再试" buttonTitle:@"确定"];
            return;
        }
        
        [[errorResponseBody cst_parsedJsonDataSignal] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = x;
            NSString *code = dic[@"CustomErrorCode"];
            NSInteger codenumber = [code integerValue];
            if (codenumber == 5010) {
                
                [self p_showAlertViewWithTitle:@"获取验证码失败" content:@"该用户已存在，请用别的号码注册" buttonTitle:@"确定"];
            }
            else if(codenumber == 5011)
            {
                [self p_showAlertViewWithTitle:@"获取验证码失败" content:@"获取验证码太频繁,请稍候再试" buttonTitle:@"确定"];
            }
            else
            {
                [self p_showAlertViewWithTitle:@"获取验证码失败" content:@"有可能网络出现了故障，请换个网络或稍候再试" buttonTitle:@"确定"];
            }
        }];
    }
}

- (void)configBLEWithUserProfile:(CSTUserProfile *)userProfile{

    if (userProfile.birthday) {
        
        [[CSTBLEManager shareManager] configCentralManager];
    }
}


#pragma mark - Private method

- (void)p_showAlertViewWithTitle:(NSString *)title content:(NSString *)content  buttonTitle:(NSString *)buttonTitle
{
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:nil rightButtonTitle:buttonTitle];
    alertView.alertTitleLabel.textColor = [UIColor redColor];
    
    [alertView show];
}


- (NSDictionary *)p_loginParameters
{
    return @{
             @"username":self.userName,
             @"password":self.password,
             @"grant_type":@"password"
             };
}

- (NSDictionary *)p_userInformationParametersWithToken:(CSTUserToken *)token
{
    
    if (token.uid)
    {
        return @{@"uid":token.uid,@"expand":@"true"};
    }
    return nil;
}


- (NSDictionary *)p_registerParameters
{
   return  @{
             @"phone":self.userName,
             @"password":self.password,
             @"code":self.verifiedCode,
             @"gender" : @0,
             @"nickname" : self.userName,
            };
}


- (NSDictionary *)p_smsAPIParamters
{
    return @{
             @"phone" : self.userName,
             @"type" : @1
             };
}

- (RACSignal *)p_loginSignal
{
    CSTLoginAPIManager *loginManager = [[CSTLoginAPIManager alloc] init];
    loginManager.parameters = [self p_loginParameters];
  
    
    return [[[[[[loginManager fetchDataSignal]flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }]flattenMap:^RACStream *(id value) {
        
        return [RACSignal cst_transformSignalWithModelClass:[CSTUserToken class] dictionary:value];
    }]flattenMap:^RACStream *(id value) {
        
        [CSTUserToken saveToken:value];
        return [CSTDataManager refreshUserProfileSignal]; //UserProfile
    }] doError:^(NSError *error) {
        
        [CSTUserToken removeToken];
    }] doNext:^(id x) {
        
        [CSTLocalNotification configLocalNotifications];
    }];
}

- (RACSignal *)p_registerSignal
{
    CSTRegisterAPIManager *registerManager = [[CSTRegisterAPIManager alloc] init];
    registerManager.parameters = [self p_registerParameters];
    
    @weakify(self);
    return [[registerManager fetchDataSignal]
            flattenMap:^RACStream *(id value) {
                
                @strongify(self);
                return [self p_loginSignal];
            }];
}

- (RACSignal *)p_smsSignal
{
    CSTSMSAPIManager *smsSignal = [[CSTSMSAPIManager alloc] init];
    smsSignal.parameters = [self p_smsAPIParamters];
    
    return [smsSignal fetchDataSignal];
}


#pragma mark - QQ login

- (RACSignal *)qqTokenSignalWithViewController:(id)loginVC{

    @weakify(self);
    return [[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self p_qqTokenSignalWithViewController:loginVC];
    }];
}

- (RACSignal *)p_qqTokenSignalWithViewController:(id)loginVC{

    @weakify(self);
   return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       @strongify(self);
       UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
       
        snsPlatform.loginClickHandler(loginVC,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            if (response.data[@"qq"][@"accessToken"] && response.data[@"qq"][@"usid"])
            {
                self.qqTokenParameters = response.data[@"qq"];
                [subscriber sendNext:response.data[@"qq"]];
                [subscriber sendCompleted];
            }
            else
            {
                NSError *error = [NSError errorWithDomain:CSTQQLoginErrorWrongParameterKey code:CSTQQLoginErrorWrongParameterCode userInfo:@{CSTQQLoginErrorWrongParameterKey : @"平台参数错误"}];
                [subscriber sendError:error];
            }
        });
        return nil;
    }];
}


- (CSTLocalAccessTokenFrom3rdAPIManager *)p_localAccessTokenFromQQAPIManagerWithDic:(NSDictionary *)dic{

    CSTLocalAccessTokenFrom3rdAPIManager *apiManager = [[CSTLocalAccessTokenFrom3rdAPIManager alloc] init];
    
    apiManager.parameters = [self p_localAccessTokenParametersWithQQResponse:dic];
    
    return apiManager;

}

- (NSDictionary *)p_localAccessTokenParametersWithQQResponse:(NSDictionary *)dic {

    if (!dic[@"accessToken"]) {
        
        return nil;
    }
    return @{@"provider":@"QQ",
             @"externalAccessToken":dic[@"accessToken"]};
}


- (RACSignal *)p_localAccessTokenSignalWithQQParameters:(NSDictionary *)dic{

   return  [[[[self p_localAccessTokenFromQQAPIManagerWithDic:dic] fetchDataSignal] flattenMap:^RACStream *(id value) {
       
       return [value cst_parsedJsonDataSignal];
   }] flattenMap:^RACStream *(id value) {
       
       return [RACSignal cst_transformSignalWithModelClass:[CSTUserToken class] dictionary:value];
   }];
}


- (RACSignal *)qqLoginSignalWithQQTokenDic:(NSDictionary *)dic{

    return [[[[self p_localAccessTokenSignalWithQQParameters:dic] flattenMap:^RACStream *(id value) {
        
        [CSTUserToken saveToken:value];
         return [CSTDataManager refreshUserProfileSignal];
    }] doNext:^(id x) {
        
        [CSTQQToken saveToken:[MTLJSONAdapter modelOfClass:[CSTQQToken class] fromJSONDictionary:self.qqTokenParameters error:nil]];
        [CSTLocalNotification configLocalNotifications];
        
    }] doError:^(NSError *error) {
        
        [CSTUserToken removeToken];
        [self p_handleQQLoginError:error];
    }];
}

- (void)p_handleQQLoginError:(NSError *)error {

    
    if (error.code == CSTNotReachableCode)
    {
        [self p_showAlertViewWithTitle:@"无网络连接"  content:@"请检查网络连接是否正常" buttonTitle:@"确定"];
        return;
    }
    
    if (error.code == CSTQQLoginErrorWrongParameterCode) {
        
        [self p_showAlertViewWithTitle:@"登录失败" content:@"未能从QQ获取到登录信息" buttonTitle:@"确定"];
        return;
    }
    
    if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
        if (response.statusCode == 400 && [response.URL.lastPathComponent isEqualToString:@"ObtainLocalAccessToken"]) {
            
            //输入手机号
            [self p_showPhoneAlert];
            
        }else{
            
            [self p_showAlertViewWithTitle:@"登录失败" content:@"未能从QQ获取到登录信息" buttonTitle:@"确定"];
        }
    }
    else
    {
        [self p_showAlertViewWithTitle:@"登录失败" content:@"未能从QQ获取到登录信息" buttonTitle:@"确定"];
    }

}


- (void)p_showPhoneAlert{

    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"请输入您的手机号" contentText:@"为了能够和您的伴侣分享饮水健康，请输入您的手机号码" leftButtonTitle:@"取消" rightButtonTitle:@"确定" hasTextFiled:YES];
    
    [alert show];
    
    __weak DXAlertView *weakAlert = alert;
    alert.rightBlock = ^{
    
        UITextField *textField = weakAlert.alertTextField;
        
        NSString *phone = textField.text;
        self.qqLoginPhone = phone;
        
        if ([CSTValidateHelper isPhoneNumberValid:phone])
        {
            [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            
            [[[[[[self p_qqRegSignalWithParameters:[self p_qqRegParametersWithQQToken:self.qqTokenParameters username:phone]] doNext:^(id x) {
                //切换页面
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
                [self.delegate userDidLoginWithUserProfile:x];
                
            }] doError:^(NSError *error) {
                
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
                [self p_handleRegisterError:error];
                
            }] flattenMap:^RACStream *(id value) {
                
                return [self p_updateUserprofileWithQQData];
                
            }] flattenMap:^RACStream *(id value) {
                
                return [self relationShipAndMateProfileSignal];
                
            }] subscribeNext:^(id x) {
                
                //do nothing
            }];
        }
        else
        {
            [self p_showAlertViewWithTitle:@"手机号码不正确" content:@"请输入正确格式的手机号码" buttonTitle:@"确定"];

        }
    };
}

- (NSDictionary *)p_qqRegParametersWithQQToken:(NSDictionary *)dic username:(NSString *)username{

    if (!username) {
        
        return nil;
    }
    if (!dic[@"accessToken"]) {
        
        return nil;
    }
    
    return @{@"userName" : username,
             @"provider" : @"QQ",
             @"externalAccessToken" :dic[@"accessToken"]
             };
}

#pragma mark - QQ reg Coaster id
- (RACSignal *)p_qqRegSignalWithParameters:(NSDictionary *)parameters{

    return [[[[[[[self p_registerFromQQAPIManagerWithParameters:parameters] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {
        return [RACSignal cst_transformSignalWithModelClass:[CSTUserToken class] dictionary:value];
    }] flattenMap:^RACStream *(id value) {
        
        [CSTUserToken saveToken:value];
        return [CSTDataManager refreshUserProfileSignal];
        
    }]doNext:^(id x) {
      
        [CSTQQToken saveToken:[MTLJSONAdapter modelOfClass:[CSTQQToken class] fromJSONDictionary:self.qqTokenParameters error:nil]];
        [CSTLocalNotification configLocalNotifications];
        
    }]doError:^(NSError *error) {
        
        [CSTUserToken removeToken];
    }];
}


- (CSTRegisterWith3rdPartyAPIManager *)p_registerFromQQAPIManagerWithParameters:(NSDictionary *)parameters  {

    CSTRegisterWith3rdPartyAPIManager *apiManager = [[CSTRegisterWith3rdPartyAPIManager alloc] init];
    apiManager.parameters = parameters;
    
    return apiManager;
}


- (RACSignal *)p_updateUserprofileWithQQData{

    return [[self p_userProfileFromQQSignal] flattenMap:^RACStream *(id value) {
        
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:value];
        NSString *avatarURLString = mutableDic[@"qqAvatarUrl"];
        [mutableDic removeObjectForKey:@"qqAvatarUrl"];
        return [[[self p_updateUserProfileWithParameters:mutableDic] fetchDataSignal] merge:[self p_uploadUserAvatarSignalWithSourceURLString:avatarURLString]];
    }];
}
            
- (RACSignal *)p_userProfileFromQQSignal{
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
            
            [subscriber sendNext:[self p_qqUserProfileWithData:response]];
            [subscriber sendCompleted];
            
        }];
        return nil;
    }];
}


- (NSDictionary *)p_qqUserProfileWithData:(UMSocialResponseEntity *)response{

    NSString *qqAvatarUrlString = response.data[@"profile_image_url"];
    NSNumber *gender = [response.data[@"gender"] isEqualToString:@"男"] ? @1 : @0;
    NSString *nickname = response.data[@"screen_name"];
    
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    if (qqAvatarUrlString) {
        [mutableDic setObject:qqAvatarUrlString forKey:@"qqAvatarUrl"];
    }
    if (nickname) {
        [mutableDic setObject:nickname forKey:@"nickname"];
    }
    
    [mutableDic setObject:gender forKey:@"gender"];
    return [NSDictionary dictionaryWithDictionary:mutableDic];

}

- (CSTUpdateUserInformationAPIManager *)p_updateUserProfileWithParameters:(NSDictionary *)dic{

    CSTUpdateUserInformationAPIManager *apiManager = [[CSTUpdateUserInformationAPIManager alloc] init];
    apiManager.parameters = dic;
    
    return apiManager;
}

- (CSTUploadUserAvatarAPIManager *)p_uploadUserAvatarAPIManagerWithImage:(UIImage *)image{

    CSTUploadUserAvatarAPIManager *apiManager = [[CSTUploadUserAvatarAPIManager alloc] init];
    
    apiManager.parameters = @{@"image" : [image cst_base64StringLessThanFiftyKb]};

    return apiManager;
}

- (RACSignal *)p_imageSignalWithURLString:(NSString *)urlString{
    
   return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlString] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            if (error) {
                [subscriber sendError:error];
            }
            [subscriber sendNext:image];
            [subscriber sendCompleted];
        }];
       return nil;
    }];
}

- (RACSignal *)p_uploadUserAvatarSignalWithSourceURLString:(NSString *)urlString{

    if (!urlString) {
        
        return [RACSignal empty];
    }
    return [[self p_imageSignalWithURLString:urlString] flattenMap:^RACStream *(id value) {
        
        if (value) {
            
            return [[self p_uploadUserAvatarAPIManagerWithImage:value] fetchDataSignal];
        }
        return [RACSignal empty];
    }];
}

#pragma mark - QQ bind Coaster id

- (void)p_handleRegisterError:(NSError *)error{

    if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
    
        if (response.statusCode == 400 && [response.URL.lastPathComponent isEqualToString:@"RegisterExternal"]) {
            //输入密码
            NSData *errorResponseBody = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            
            [[errorResponseBody cst_parsedJsonDataSignal]subscribeNext:^(id x) {
                
                NSDictionary *errorDic = (NSDictionary *)x;
                NSInteger customCode = [errorDic[@"CustomErrorCode"] integerValue];
                
                if (customCode == 6005) {
                    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"注册失败" contentText:@"输入的手机号已经与其他QQ号码关联，请尝试新的手机号码"  leftButtonTitle:@"确定" rightButtonTitle:@"取消" hasTextFiled:YES];
                    alert.leftBlock = ^{
                        [self p_showPhoneAlert];
                    };
                    
                    [alert show];
                    
                }else{
                
                    [self p_showPWDAlert];
                }
            }];
            
        }else{
            
            [self p_showAlertViewWithTitle:@"登录失败" content:@"未能从QQ获取到登录信息" buttonTitle:@"确定"];
        }
    }
    else
    {
        [self p_showAlertViewWithTitle:@"登录失败" content:@"未能从QQ获取到登录信息" buttonTitle:@"确定"];
    }
}


- (void)p_showPWDAlert{
    
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"输入Coaster的密码" contentText:@"输入Coaster账号的密码，就可与QQ账号关联" leftButtonTitle:@"取消" rightButtonTitle:@"确定" hasTextFiled:YES];
    
    [alert show];
    
    __weak DXAlertView *weakAlert = alert;
    alert.rightBlock = ^{
        
        UITextField *textField = weakAlert.alertTextField;
        
        NSString *pwd = textField.text;
        
        if ([CSTValidateHelper isPasswordValid:pwd])
        {
            [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            @weakify(self);
            [[[[[self p_bind3rdPartySignalWithPassword:pwd] doNext:^(id x) {
                
                @strongify(self);
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
                [self.delegate userDidLoginWithUserProfile:x];
                
            }] doError:^(NSError *error) {
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
                
                
                NSData * data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"error == %@",string);
                
                
                [self p_showAlertViewWithTitle:@"绑定失败" content:@"QQ号码与 Coaster 绑定失败" buttonTitle:@"确定"];
                
            }] flattenMap:^RACStream *(id value) {
                
                return [self relationShipAndMateProfileSignal];
                
            }] subscribeNext:^(id x) {
                
            }];
        }
        else
        {
            [self p_showAlertViewWithTitle:@"密码输入有误" content:@"用户密码至少为6位" buttonTitle:@"确定"];
            
        }
    };
}

- (RACSignal *)p_bind3rdPartySignalWithPassword:(NSString *)password{

    return [[[[[[[self p_bind3rdPartyAPIManagerWithPassword:password] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        return [RACSignal cst_transformSignalWithModelClass:[CSTUserToken class] dictionary:value];
    }] flattenMap:^RACStream *(id value) {
        
        [CSTUserToken saveToken:value];
        return [CSTDataManager refreshUserProfileSignal];
    }] doNext:^(id x) {
        
        [CSTQQToken saveToken:[MTLJSONAdapter modelOfClass:[CSTQQToken class] fromJSONDictionary:self.qqTokenParameters error:nil]];
        [CSTLocalNotification configLocalNotifications];
        
    }] doError:^(NSError *error) {
        
        [CSTUserToken removeToken];
    }];

}


- (CSTBind3rdPartyAPIManager *)p_bind3rdPartyAPIManagerWithPassword:(NSString *)password{

    CSTBind3rdPartyAPIManager *apiManager = [[CSTBind3rdPartyAPIManager alloc] init];
    apiManager.parameters = [self p_bind3rdPartyParametersWithQQToken:self.qqTokenParameters username:self.qqLoginPhone password:password];
    
    
    return apiManager;
}


- (NSDictionary *)p_bind3rdPartyParametersWithQQToken:(NSDictionary *)qqToken username:(NSString *)username password:(NSString *)password{

    
    if (!username) {
        
        return nil;
    }
    
    if (!password) {
        return nil;
    }
    if (!qqToken[@"accessToken"]) {
        
        return nil;
    }
    
    return @{@"userName" : username,
             @"password" : password,
             @"provider" : @"QQ",
             @"externalAccessToken" :qqToken[@"accessToken"]
             };
    
}


@end
