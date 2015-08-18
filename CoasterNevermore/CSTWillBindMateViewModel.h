//
//  CSTWillBindMateViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/11.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSTRelationship;
@class RACSignal;

@interface CSTWillBindMateViewModel : NSObject

@property (nonatomic, strong) CSTRelationship *relationship;

@property (nonatomic, copy) NSString *mateUsername;
@property (nonatomic, copy) NSString *mateNickname;
@property (nonatomic, copy) NSString *pendingRelationshipDescription;

@property (nonatomic, assign) BOOL hasMate;

- (RACSignal *)deleteRelationshipSignal;

- (RACSignal *)inviteRelationshipSignalWithUsername:(NSString *)username;

- (RACSignal *)cancelRelationshipSignal;

- (RACSignal *)refuseRalationshiSignal;

- (RACSignal *)acceptRelationshipSignal;

- (void)refreshCurrentPageData;

@end
