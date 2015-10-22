//
//  CSTDeviceStateTableViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface CSTDeviceStateTableViewModel : NSObject

@property (nonatomic, copy) NSString *deviceIDString;
@property (nonatomic, copy) NSString *operationStateString;
@property (nonatomic, copy) NSString *batteryStateString;
@property (nonatomic, copy) NSString *connectStateString;
@property (nonatomic, copy) NSString *firmwareVersionString;

@property (nonatomic, assign) BOOL isFirmwareNeedUpdate;

- (RACSignal *)verifyFirmwareVersionNeedUpdateSignal;

- (RACSignal *)networkAndBLEConnectionSignal;

- (RACSignal *)networkConnectionSignal;

- (RACSignal *)verifyDeleteDeviceSignal;

- (RACSignal *)deleteDeviceSignal;

- (void)updateFirmware;


@end
