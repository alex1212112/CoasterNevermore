//
//  CSTFindPasswordViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;

typedef NS_ENUM(NSInteger, CSTChangePasswordEventErrorType) {
    CSTChangePasswordErrorChange,
    CSTChangePasswordErrorSMS,
};


@interface CSTFindPasswordViewModel : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *verifiedCode;
@property (nonatomic, strong) NSString *currentPassword;


- (RACSignal *)validateSignal;

- (RACSignal *)changePasswordSignal;

- (RACSignal *)smsSignal;

@end
