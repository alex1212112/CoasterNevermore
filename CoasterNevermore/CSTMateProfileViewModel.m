//
//  CSTMateProfileViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/9.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMateProfileViewModel.h"
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import "CSTAPIBaseManager.h"
#import "CSTNetworking.h"
#import "DXAlertView.h"

#import "NSDate+CSTTransformString.h"
#import "CSTRelationship+CSTNetworkSignal.h"
#import "SDWebImageManager+CSTDownloadSignal.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation CSTMateProfileViewModel

#pragma mark - Life cycle
- (instancetype)init{
    
    if (self = [super init]) {
        
        [self p_configObserverWithMateProfile];
        [self p_configObserverWithRelationship];
    }
    return self;
}

#pragma mark -Observer
- (void)p_configObserverWithMateProfile{
    
    RAC(self, mateNickname) = [RACObserve([CSTDataManager shareManager], mateProfile.nickname) map:^id(id value) {
        
        return value ?: @"小C";
    }];
    
    RAC(self, mateUsername) = [RACObserve([CSTDataManager shareManager], mateProfile.username) map:^id(id value) {
        
        return value ?: @"Coaster@nevermore.cn";
    }];
    
    RAC(self, avatarImage) =  [[RACObserve([CSTDataManager shareManager], mateProfile.imageURLString) flattenMap:^RACStream *(id value) {
        
        return [SDWebImageManager cst_imageSignalWithURLString:value];
    }] map:^id(id value) {
        
        return value ?: [UIImage imageNamed:@"AvatarIcon"];
    }];
}

- (void)p_configObserverWithRelationship{
    
    RAC(self, startDateString) = [RACObserve([CSTDataManager shareManager], relationship.startTime) map:^id(id value) {
        
        return [self p_startDateStringWithDateString:value];
    }];
    
    RAC(self, shareDaysString) = [RACObserve([CSTDataManager shareManager], relationship.startTime) map:^id(id value) {
        
        return [self p_intervalDaysStringWithStartDateString:value];
    }];
    
    
    RAC(self, hasMate) = [RACObserve([CSTDataManager shareManager], relationship.status) map:^id(id value) {
        
        return @([value integerValue] == 2);
    }];
    
    RAC(self, relationship) = RACObserve([CSTDataManager shareManager], relationship);
    
    RAC(self, pendingRelationshipDescription) = [RACObserve([CSTDataManager shareManager], relationship) map:^id(id value) {
        
        CSTRelationship *relationship = value;
        if ([relationship.status integerValue] == 1) {
         
            if ([relationship.fromUid isEqualToString:[CSTDataManager shareManager].userProfile.uid]) {
                return @"邀请已发送，等待对方接受邀请";
            }else{
                return [NSString stringWithFormat:@"收到来自%@的伴侣邀请",relationship.fromNickname];
            }
        }else{
            return nil;
        }
    }];
}


#pragma mark - Private method

- (NSString *)p_intervalDaysStringWithStartDateString:(NSString *)dateString{

    NSDate *date = [NSDate cst_dateWithOriginString:dateString Format:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    NSTimeInterval interval = - [date timeIntervalSinceNow] / kCSTSecondsInOneDay;
    
    return [NSString stringWithFormat:@"%ld天",(long)interval];
}

- (NSString *)p_startDateStringWithDateString:(NSString *)dateString{

    if (!dateString) {
        
        return @"Soon...";
    }
    NSDate *date = [NSDate cst_dateWithOriginString:dateString Format:@"yyyy-MM-dd HH:mm:ss"];
    return [date cst_stringWithFormat:@"yyyy-MM-dd"];
}


#pragma mark - Private method

- (void)p_showAlertViewWithTitle:(NSString *)title content:(NSString *)content  buttonTitle:(NSString *)buttonTitle
{
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:nil rightButtonTitle:buttonTitle];
    alertView.alertTitleLabel.textColor = [UIColor redColor];
    
    [alertView show];
}


#pragma mark - Public method

- (void)refreshCurrentPageData{

    [[[CSTDataManager refreshRelationshipSignal] flattenMap:^RACStream *(id value) {
        
       return  [CSTDataManager refreshMateProfileSignalWithRelationship:value];
        
    }] subscribeNext:^(id x) {
        
        
    }];
}


- (RACSignal *)deleteRelationshipSignal{

    return [[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        return [self p_deleteRelationshipSignal];
    }] doError:^(NSError *error) {
        
        if (error.code == CSTNotReachableCode){
            [self p_showAlertViewWithTitle:@"无网络连接" content:@"请检查网络连接是否正常" buttonTitle:@"确定"];
        }else{
            [self p_showAlertViewWithTitle:@"解除绑定失败" content:@"有可能网络出现故障，请检查网络连接是否正常" buttonTitle:@"确定"];
        }
    }];

}
- (RACSignal *)inviteRelationshipSignalWithUsername:(NSString *)username{

    return [[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        return [self p_inviteRelationshipSignalWithUsername:username];
        
    }] doError:^(NSError *error) {
        
        [self p_handleError:error];
    }];
};

- (RACSignal *)cancelRelationshipSignal{

    return [[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        return [self p_cancelRelationshipSignal];
        
    }] doError:^(NSError *error) {
        
        [self p_handleError:error];
    }];
}

- (RACSignal *)refuseRalationshiSignal{
    
    return [[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        return [self p_refuseRelationshiSignal];
        
    }] doError:^(NSError *error) {
        
        [self p_handleError:error];
    }];

}

- (RACSignal *)acceptRelationshipSignal{

    return [[[CSTNetworkManager reachableSignal] flattenMap:^RACStream *(id value) {
        return [self  p_acceptRelationshipSignal];
        
    }] doError:^(NSError *error) {
        
        [self p_handleError:error];
    }];
}



#pragma mark - Relationship

- (RACSignal *)p_deleteRelationshipSignal{
  
    return  [[[CSTRelationship cst_deleteRelationshipSignal] doNext:^(id x) {
        
        [CSTDataManager removeRelationship];
        
    }] doError:^(NSError *error) {
        
        [[CSTDataManager refreshRelationshipSignal] subscribeNext:^(id x) {
            
        }];
    }];
}


- (void)p_handleError:(NSError *)error{

    if (error.code == CSTNotReachableCode)
    {
        [self p_showAlertViewWithTitle:@"无网络连接" content:@"请检查网络连接是否正常" buttonTitle:@"确定"];
        return;
    }
    if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
        
        if ([response.URL.lastPathComponent isEqualToString:@"sendrequest"] && response.statusCode  == 400) {
            
            [self p_showAlertViewWithTitle:@"邀请伴侣失败" content:@"输入信息不正确,可能不存在这样的用户" buttonTitle:@"确定"];
            return;
        }
        if ([response.URL.lastPathComponent isEqualToString:@"sendrequest"] && response.statusCode  == 409) {
            
            [self p_showAlertViewWithTitle:@"邀请伴侣失败" content:@"您邀请的伴侣已经与其他账号绑定" buttonTitle:@"确定"];
            return;
        }
    }
}

- (RACSignal *)p_inviteRelationshipSignalWithUsername:(NSString *)username{

   return [[CSTRelationship cst_inviteRelationshipSignalWithUsername:username] flattenMap:^RACStream *(id value) {
       
       return [CSTDataManager refreshRelationshipSignal];
   }];
}


- (RACSignal *)p_cancelRelationshipSignal{

    return [[CSTRelationship cst_cancelRelationshipSignal]doNext:^(id x) {
        
         [CSTDataManager removeRelationship];
    }];
}


- (RACSignal *)p_refuseRelationshiSignal{

    return [[[CSTRelationship cst_refuseRelationshipSignaFromUid:[CSTDataManager shareManager].relationship.fromUid] doNext:^(id x) {
        
         [CSTDataManager removeRelationship];
        
    }] doError:^(NSError *error) {
        
        [[CSTDataManager refreshRelationshipSignal] subscribeNext:^(id x) {
            
        }];
    }];
}

- (RACSignal *)p_acceptRelationshipSignal{
    
    return [[[CSTRelationship cst_acceptRelationshipSignalFromUid:[CSTDataManager shareManager].relationship.fromUid] flattenMap:^RACStream *(id value) {
        
        return [CSTDataManager refreshRelationshipSignal];
    }] flattenMap:^RACStream *(id value) {
        
        return [CSTDataManager refreshMateProfileSignalWithRelationship:value];
    }];
}



@end
