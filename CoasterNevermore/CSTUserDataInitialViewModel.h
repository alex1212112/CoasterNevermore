//
//  CSTUserDataInnitialViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;

@interface CSTUserDataInitialViewModel : NSObject

@property (nonatomic, strong) NSArray *userDataInitialCellModels;


- (RACSignal *)forwardSignalWithCurrentPage:(NSInteger)page;

- (RACSignal *)updateUserInformationSignal;

- (BOOL)isUserOwndevice;

@end
