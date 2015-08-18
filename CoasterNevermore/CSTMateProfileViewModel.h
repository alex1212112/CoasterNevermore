//
//  CSTMateProfileViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/9.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;
@class RACSignal;
@class CSTRelationship;

@interface CSTMateProfileViewModel : NSObject

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) NSString *startDateString;
@property (nonatomic, copy) NSString *shareDaysString;
@property (nonatomic, copy) NSString *mateUsername;
@property (nonatomic, copy) NSString *mateNickname;
@property (nonatomic, copy) NSString *pendingRelationshipDescription;

@property (nonatomic, strong) CSTRelationship *relationship;


@property (nonatomic, assign) BOOL hasMate;

- (RACSignal *)deleteRelationshipSignal;

- (RACSignal *)inviteRelationshipSignalWithUsername:(NSString *)username;

- (RACSignal *)cancelRelationshipSignal;

- (RACSignal *)refuseRalationshiSignal;

- (RACSignal *)acceptRelationshipSignal;

- (void)refreshCurrentPageData;

@end
