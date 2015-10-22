//
//  CSTRelationship+CSTNetworkingSinal.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/9.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTRelationship+CSTNetworkSignal.h"
#import "CSTAPIBaseManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACSignal+CSTModel.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import "CSTDataManager.h"

@implementation CSTRelationship (CSTNetworkSignal)

+ (RACSignal *)cst_networkDataSignal{

    return [[[[CSTRelationship p_relationshipAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
          return [value cst_parsedJsonDataSignal];
    }] flattenMap:^RACStream *(id value) {
        
         return [RACSignal cst_transformSignalWithModelClass:[CSTRelationship class] dictionary:value];
    }];
}

+ (CSTRelationshipAPIManager *)p_relationshipAPIManager{
    
    return  [[CSTRelationshipAPIManager alloc] init];
}


#pragma mark - Refuse
+ (RACSignal *)cst_refuseRelationshipSignaFromUid:(NSString *)uid{
    
    return [[CSTRelationship p_refuseRelationshipAPIManagerFromUid:uid] fetchDataSignal];
}

+ (CSTRefuseRelationshipAPIManager *)p_refuseRelationshipAPIManagerFromUid:(NSString *)uid{
    
    CSTRefuseRelationshipAPIManager *apiManager = [[CSTRefuseRelationshipAPIManager alloc] init];
    apiManager.parameters = @{@"fromUid" : uid};
    
    return apiManager;
}


#pragma mark - Accept

+ (RACSignal *)cst_acceptRelationshipSignalFromUid:(NSString *)uid{
    
    return [[CSTRelationship p_acceptRelationshipAPIManagerFromUid:uid]fetchDataSignal];
}


+ (CSTAcceptRelationshipAPIManager *)p_acceptRelationshipAPIManagerFromUid:(NSString *)uid{
    CSTAcceptRelationshipAPIManager *apiManager = [[CSTAcceptRelationshipAPIManager alloc] init];
    
    apiManager.parameters = @{@"fromUid" : uid};
    
    return apiManager;
    
}

#pragma mark - Invite

+ (RACSignal *)cst_inviteRelationshipSignalWithUsername:(NSString *)username{
    
    return [[CSTRelationship p_inviteRelationshipManagerWithUsername:username] fetchDataSignal];
}

+ (CSTInviteRelationshipAPIManager *)p_inviteRelationshipManagerWithUsername:(NSString *)username{
    
    CSTInviteRelationshipAPIManager *apiManager = [[CSTInviteRelationshipAPIManager alloc] init];
    
    apiManager.parameters = @{@"toUserName" : username};
    
    return apiManager;
}

#pragma mark - Cancel

+ (RACSignal *)cst_cancelRelationshipSignal{
    
    return [[self p_cancelRelationshipAPIManager] fetchDataSignal];
}

+ (CSTCancelRelationshipAPIManager *)p_cancelRelationshipAPIManager{
    
    CSTCancelRelationshipAPIManager *apiManager = [[CSTCancelRelationshipAPIManager alloc] init];
    
    NSString *toUid = [CSTDataManager shareManager].relationship.toUid ? :@"";
    
    apiManager.parameters = @{@"toUid":toUid};
    
    return apiManager;
}

#pragma mark - Cancel

+ (RACSignal *)cst_deleteRelationshipSignal{
    
    return  [[CSTRelationship p_deleteRelationshipAPIManager] fetchDataSignal];
}

+ (CSTDeleteRelationshipAPIManager *)p_deleteRelationshipAPIManager{
    
    return [[CSTDeleteRelationshipAPIManager alloc] init];
}



@end
