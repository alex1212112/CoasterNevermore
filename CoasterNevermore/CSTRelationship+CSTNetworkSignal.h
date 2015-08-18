//
//  CSTRelationship+CSTNetworkingSinal.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/9.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTRelationship.h"
@class RACSignal;

@interface CSTRelationship (CSTNetworkSignal)

+ (RACSignal *)cst_networkDataSignal;

+ (RACSignal *)cst_refuseRelationshipSignaFromUid:(NSString *)uid;

+ (RACSignal *)cst_acceptRelationshipSignalFromUid:(NSString *)uid;

+ (RACSignal *)cst_inviteRelationshipSignalWithUsername:(NSString *)username;

+ (RACSignal *)cst_cancelRelationshipSignal;

+ (RACSignal *)cst_deleteRelationshipSignal;

@end
