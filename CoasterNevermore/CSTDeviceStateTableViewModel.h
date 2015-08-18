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

@property (nonatomic, strong) NSString *deviceIDString;
@property (nonatomic, strong) NSString *operationStateString;
@property (nonatomic, strong) NSString *batteryStateString;
@property (nonatomic, strong) NSString *connectStateString;
@property (nonatomic, strong) NSString *firmwareVersionString;

@property (nonatomic, assign) BOOL isFirmwareNeedUpdate;

- (RACSignal *)verifyFirmwareVersionNeedUpdateSignal;

- (RACSignal *)networkAndBLEConnectionSignal;

- (RACSignal *)networkConnectionSignal;

- (RACSignal *)verifyDeleteDeviceSignal;

- (RACSignal *)deleteDeviceSignal;

- (void)updateFirmware;


@end
