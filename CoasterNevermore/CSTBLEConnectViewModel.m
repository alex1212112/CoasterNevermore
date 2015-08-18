//
//  CSTBLEConnectViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBLEConnectViewModel.h"
#import "CSTBLEManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CSTBLEConnectViewModel ()

@end

@implementation CSTBLEConnectViewModel


#pragma mark - Life cycle

- (instancetype)init{
    
    if (self = [super init]) {

        [self p_configObserverWithBLEDevices];
    }
    
    return self;
}


#pragma mark - Observers

- (void)p_configObserverWithBLEDevices{

    RAC(self,devices) = RACObserve([CSTBLEManager shareManager], devices);
}

#pragma mark - Public method
- (void)runMethodAfterDelay:(float)delay withMethod:(void(^)())method
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), method);
}

- (void)startScan{

    [[CSTBLEManager shareManager] scan];
    self.isScanning = YES;
}

- (void)stopScan{

    [[CSTBLEManager shareManager] stopScan];
    self.isScanning = NO;
}


@end
