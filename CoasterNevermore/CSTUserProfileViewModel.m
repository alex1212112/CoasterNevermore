//
//  CSTUserProfileViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserProfileViewModel.h"
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import "CSTBasicCellModel.h"
#import <Mantle/Mantle.h>
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSDate+CSTTransformString.h"
#import "CSTAPIBaseManager.h"
#import "UIImage+CSTTransformBase64String.h"
#import "CSTNetworking.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import "RACSignal+CSTModel.h"
#import "DXAlertView.h"
#import "Colours.h"
#import "SDWebImageManager+CSTDownloadSignal.h"


@implementation CSTUserProfileViewModel

#pragma mark - Life cycle
- (instancetype)init{

    if (self = [super init]) {
        
        [self p_configObserverWithUserProfile];
        [self p_configObserverWithEditItem];
    }
    return self;
}

#pragma mark -Observer
- (void)p_configObserverWithUserProfile{
    
    
    @weakify(self);
    RAC(self, username) = RACObserve([CSTDataManager shareManager], userProfile.username);
    
    [[RACObserve([CSTDataManager shareManager], userProfile.imageURLString) flattenMap:^RACStream *(id value) {
        
        return [SDWebImageManager cst_imageSignalWithURLString:value];
    }] subscribeNext:^(id x) {
        
        self.avatarImage = (self.editImage ?: x) ?: [UIImage imageNamed:@"AvatarIcon"];
    }];
    
    
    [[RACObserve(self, editImage) ignore:nil] subscribeNext:^(id x) {
        
        self.avatarImage = x;
    }];
    
    
    [[RACSignal combineLatest:@[
                               RACObserve([CSTDataManager shareManager], userProfile),
                               RACObserve(self, editNickname),
                               RACObserve(self, editGender),
                               RACObserve(self, editHeight),
                               RACObserve(self, editWeight),
                               RACObserve(self, editBirthday)] reduce:
                            ^id(NSArray *array,
                                NSString *editNickname,
                                NSNumber *editGender,
                                NSNumber *editHeight,
                                NSNumber *editWeight,
                                NSDate *editBirthday){
                                   
        @strongify(self);
         return [self p_transItemsWithArray:[self p_profileDictionnarys]];
            
    }] subscribeNext:^(id x) {
        
        self.profileItems = x;
    }];
}



#pragma mark - Private method

- (NSArray *)p_profileDictionnarys{
    
    CSTUserProfile *userProfile = [CSTDataManager shareManager].userProfile;
    
    NSString *nickname =  (self.editNickname ?: userProfile.nickname) ?:@"";
    NSString *gender =   (self.editGender ? [self.editGender integerValue]:  [userProfile.gender integerValue]) == 0 ? @"女" : @"男";
    
    NSString *height = [NSString stringWithFormat:@"%ldcm",(long)(self.editHeight ? [self.editHeight integerValue]:[userProfile.height integerValue])];
    NSString *weight = [NSString stringWithFormat:@"%ldkg",(long)(self.editWeight ?[self.editWeight integerValue]:[userProfile.weight integerValue])];
    NSString *birthday = (self.editBirthday ? [self.editBirthday cst_stringWithFormat:@"yyyy-MM-dd"] : userProfile.birthday) ?: @"";
    
    return @[
             @{@"title" : @"昵称", @"detail" : nickname},
             @{@"title" : @"性别", @"detail" : gender},
             @{@"title" : @"身高", @"detail" : height},
             @{@"title" : @"体重", @"detail" : weight},
             @{@"title" : @"生日", @"detail" : birthday},
             ];
}


- (NSArray *)p_transItemsWithArray:(NSArray *)array{

    return [array linq_select:^id(id item){
        
            return [MTLJSONAdapter modelOfClass:[CSTBasicCellModel class ] fromJSONDictionary:item error:nil];
    }];
}

- (void)p_configObserverWithEditItem{

    [RACObserve(self.updateViewModel, nickname) subscribeNext:^(id x) {
        
        self.editNickname = [x isEqualToString:[CSTDataManager shareManager].userProfile.nickname]|| [x length] == 0 ? nil : x;
    }];
    
    [RACObserve(self.updateViewModel, gender) subscribeNext:^(id x) {
        
        self.editGender = [x isEqual:[CSTDataManager shareManager].userProfile.gender] ? nil : x;
    }];
    
    [RACObserve(self.updateViewModel, height) subscribeNext:^(id x) {
        
        self.editHeight = [x isEqual:[CSTDataManager shareManager].userProfile.height] ? nil : x;
    }];
    
    [RACObserve(self.updateViewModel, weight) subscribeNext:^(id x) {
        
        self.editWeight = [x isEqual:[CSTDataManager shareManager].userProfile.weight] ? nil : x;
    }];
    
    [RACObserve(self.updateViewModel, birthday) subscribeNext:^(id x) {
        
        self.editBirthday = [[x cst_stringWithFormat:@"yyyy-MM-dd"]isEqualToString:[CSTDataManager shareManager].userProfile.birthday] ? nil : x;
    }];
}

- (NSDictionary *)p_updateUserProfileDictionary{

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.editNickname.length > 0) {
        
        dic[@"nickname"] = self.editNickname;
    }
    if (self.editGender) {
        
        dic[@"gender"] = [self.editGender isEqual:@(CSTUserGenderFemale)] ? @"false" : @"true";
    }
    
    if (self.editHeight) {
        
        dic[@"height"] = self.editHeight;
    }
    
    if (self.editWeight) {
        
        dic[@"weight"] = self.editWeight;
    }
    
    if (self.editBirthday) {
        
        dic[@"birthday"] = [self.editBirthday cst_stringWithFormat:@"yyyy-MM-dd"];
    }
    
    if ([dic count] > 0) {
        
        return [NSDictionary dictionaryWithDictionary:dic];
    }
    return nil;
}

- (CSTUpdateUserInformationAPIManager *)p_updateUserInformationAPIManager{
    
    CSTUpdateUserInformationAPIManager *apiManager = [[CSTUpdateUserInformationAPIManager alloc] init];
    apiManager.parameters = [self p_updateUserProfileDictionary];
    return apiManager;
}

- (CSTUploadUserAvatarAPIManager *)p_uploadAvatarAPIManager{
    
    CSTUploadUserAvatarAPIManager *apiManager = [[CSTUploadUserAvatarAPIManager alloc] init];
    apiManager.parameters =@{@"image" : [self.editImage cst_base64StringLessThanFiftyKb]};
    return apiManager;
}

- (RACSignal *)p_updateUserInformationSignal{

    @weakify(self);
    return [[[[[self p_updateUserInformationAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value  cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
        return [RACSignal cst_transformSignalWithModelClass:[CSTUserProfile class] dictionary:value];
    }] doNext:^(id x) {
        
        @strongify(self);
        
        ((CSTUserProfile *)x).deviceId = [CSTDataManager shareManager].userProfile.deviceId;
        [CSTDataManager shareManager].userProfile = x;
        
        self.editNickname = nil;
        self.editGender = nil;
        self.editHeight = nil;
        self.editWeight = nil;
        self.editBirthday = nil;
    }];
}
- (RACSignal *)p_uploadAvatarSignal{

    @weakify(self);
    return [[[self p_uploadAvatarAPIManager] fetchDataSignal]doNext:^(id x) {
        
        @strongify(self);
        self.editImage = nil;
        
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
            
            [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:nil];
            [[[SDWebImageManager sharedManager] imageCache] clearMemory];
        }
    }];
}

- (RACSignal *)p_updateUserProfileSignal{
    
    if (self.editImage && [self p_updateUserProfileDictionary]) {
        
        return [[self p_updateUserInformationSignal] flattenMap:^RACStream *(id value) {
            
            return [self p_uploadAvatarSignal];
            
        }];
    }
    
    if (self.editImage) {
        
        return [self p_uploadAvatarSignal];
    }
    
    return [self p_updateUserInformationSignal] ;
}


- (void)p_showAlertViewWithTitle:(NSString *)title content:(NSString *)content  buttonTitle:(NSString *)buttonTitle
{
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:nil rightButtonTitle:buttonTitle];
    alertView.alertTitleLabel.textColor = [UIColor redColor];
    
    [alertView show];
}

- (void)p_showAlertViewWithTitle:(NSString *)title titleColor:(UIColor *)color content:(NSString *)content  buttonTitle:(NSString *)buttonTitle
{
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:nil rightButtonTitle:buttonTitle];
    alertView.alertTitleLabel.textColor = color;
    
    [alertView show];
}

- (void)p_handleError:(NSError *)error
{
    
    if (error.code == CSTNotReachableCode)
    {
        [self p_showAlertViewWithTitle:@"无网络连接" content:@"请检查网络连接是否正常" buttonTitle:@"确定"];
        return;
    }
    
    if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]])
    {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
        
        if ([response.URL.lastPathComponent isEqualToString:@"profile"]) {
            
            [self p_showAlertViewWithTitle:@"修改资料失败" content:@"请检查网络连接是否正常" buttonTitle:@"确定"];
        }else if ([response.URL.lastPathComponent isEqualToString:@"avatar"]){
            
            [self p_showAlertViewWithTitle:@"上传头像" content:@"请检查网络连接是否正常" buttonTitle:@"确定"];
        }
    }
}


#pragma mark - Public method

- (RACSignal *)EditSignal{

    
    return [RACSignal combineLatest:@[RACObserve(self, editImage),
                                      RACObserve(self, editNickname),
                                      RACObserve(self, editGender),
                                      RACObserve(self, editHeight),
                                      RACObserve(self, editWeight),
                                      RACObserve(self, editBirthday)] reduce:
            ^id(UIImage *editAvatar,
                NSString *editNickname,
                NSNumber *editGender,
                NSNumber *editHeight,
                NSNumber *editWeight,
                NSDate *editBirthday){
    
                return @(editAvatar || editNickname || editGender || editHeight ||editWeight || editBirthday);
    }];
}

- (BOOL)isUserProfieCanBeModified{

    if (self.editImage || self.editNickname || self.editGender || self.editHeight || self.editWeight || self.editBirthday) {
        return YES;
    }
    return NO;
}


- (void)configCurrentUpdateViewmodel{

    CSTUserProfile *userProfile = [CSTDataManager shareManager].userProfile;
    self.updateViewModel.nickname = self.editNickname ?: userProfile.nickname;
    
    self.updateViewModel.gender = self.editGender ?: userProfile.gender;
    self.updateViewModel.height = self.editHeight ?: userProfile.height;
    self.updateViewModel.weight = self.editWeight ?: userProfile.weight;
    self.updateViewModel.birthday = self.editBirthday ?: [NSDate cst_dateWithOriginString:userProfile.birthday Format:@"yyyy-MM-dd"];
}

- (RACSignal *)updateUserProfileSignal{

    return [[[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        
        return[self p_updateUserProfileSignal];
        
    }] doNext:^(id x) {
        
        [self p_showAlertViewWithTitle:@"用户资料修改成功" titleColor:[UIColor grassColor] content:@"恭喜您,资料修改成功!" buttonTitle:@"确定"];
    }] doError:^(NSError *error) {
        
        [self p_handleError:error];
    }];
}


#pragma mark - Setters and getters

- (CSTUpdateUserProfileViewModel *)updateViewModel{

    if (!_updateViewModel) {
        
        _updateViewModel = [[CSTUpdateUserProfileViewModel alloc] init];
    }
    
    return _updateViewModel;
}

@end
