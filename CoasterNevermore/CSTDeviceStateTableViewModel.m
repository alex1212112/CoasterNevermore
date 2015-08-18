//
//  CSTDeviceStateTableViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDeviceStateTableViewModel.h"
#import <ReactiveCocoa.h>
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import "CSTBLEManager.h"
#import "CBPeripheral+CSTBLE.h"
#import "CSTNetworking.h"
#import "CSTBLEVersion+CSTNetworkSignal.h"
#import "CSTAPIBaseManager.h"

@implementation CSTDeviceStateTableViewModel


#pragma mark - Life cycle
- (instancetype)init{
    
    if (self = [super init]) {
        
        [self p_configObserverWithUserProfile];
        [self p_configObserverWithDeviceState];
        [self p_configObserverWithDevicePower];
        [self p_configObserverWithFMVersion];
        [self p_configObserverWithFirmwareNeddUpdate];
    }
    return self;
}

#pragma mark -Observer
- (void)p_configObserverWithUserProfile{
    
   // @weakify(self);

    RAC(self,deviceIDString) = [RACObserve([CSTDataManager shareManager], userProfile.deviceId) map:^id(id value) {
        NSString *deviceIDString = [self p_coasterStringWithString:value];
        return deviceIDString ?: @"00000000";
    }];
}

- (void)p_configObserverWithDeviceState{

    RAC(self,connectStateString) = [RACObserve([CSTBLEManager shareManager], peripheral.state) map:^id(id value) {
        
        if ([value integerValue] == CBPeripheralStateDisconnected) {
            
            return @"未连接";
        }else if ([value integerValue] == CBPeripheralStateConnected){
            
            return @"已连接";
        }
        return @"正在连接";
    }];
    
    RAC(self,operationStateString) = [RACObserve([CSTBLEManager shareManager], peripheral.state) map:^id(id value) {
        
        if ([value integerValue] == CBPeripheralStateDisconnected) {
            
            return @"未连接";
        }else if ([value integerValue] == CBPeripheralStateConnected){
            
            return @"正常";
        }
        return @"正在连接";
    }];
}

- (void)p_configObserverWithDevicePower{

    RAC(self,batteryStateString) = [RACObserve([CSTBLEManager shareManager], battery) map:^id(id value) {
        
        if ([value integerValue] > 75) {
            
            return @"充足";
        }else if ([value integerValue] > 50){
            
            return @"中";
        }else if ([value integerValue] == 0){
            return @"未知";
        }
        return @"低";
    }];
}

- (void)p_configObserverWithFMVersion{

    RAC(self,firmwareVersionString) = [RACObserve([CSTBLEManager shareManager], peripheral.cst_fmVersion.version) map:^id(id value) {
        
        return value ?: @"未知";
    }];
}
- (void)p_configObserverWithFirmwareNeddUpdate{
    
    RAC(self,isFirmwareNeedUpdate) = RACObserve([CSTBLEManager shareManager], firmwareNeedUpdate);
}


#pragma mark - Private method
- (NSString *)p_coasterStringWithString:(NSString *)originDeviceString{

    if ([originDeviceString hasPrefix:@"CUP-MAT"]) {
        
        return[originDeviceString stringByReplacingOccurrencesOfString:@"CUP-MAT" withString:@"Coaster-"];
    }
    return originDeviceString;
}

- (CSTDeleteDeviceAPIManager *)p_deleteDeviceAPIManager{

    return [[CSTDeleteDeviceAPIManager alloc]init];
}


#pragma mark - Publick method

- (void)updateFirmware{

    [[CSTBLEManager shareManager] downLoadAndUpdateFirmware];
}

- (RACSignal *)networkAndBLEConnectionSignal{


    return [RACSignal combineLatest:@[[CSTNetworkManager shareManager].reachableBOOLStateSignal,RACObserve([CSTBLEManager shareManager], peripheral.state)] reduce:^id(NSNumber *reachableState, NSNumber *peripheralState){
        
        if ([reachableState integerValue] == NO || [peripheralState integerValue] != CBPeripheralStateConnected) {
            
            return @NO;
        }
        return @YES;
    }];
}


- (RACSignal *)verifyFirmwareVersionNeedUpdateSignal{

    return [[[CSTBLEVersion cst_serviceFirmwareVersionSignal] doNext:^(id x) {
        
        [CSTBLEManager shareManager].serviceVersion = x;
        
    }] map:^id(id value) {
      
        CSTBLEVersion * serviceVersion = value;
        
        if (serviceVersion.version.length == 0) {
            return @NO;
        }
        if ([CSTBLEManager shareManager].peripheral.cst_fmVersion.version.length == 0) {
            return @NO;
        }
        if ([serviceVersion.version isEqualToString:[CSTBLEManager shareManager].peripheral.cst_fmVersion.version]) {
            
            return @NO;
        }
        return @YES;
    }];
}

- (RACSignal *)networkConnectionSignal{

    return [[CSTNetworkManager shareManager] reachableBOOLStateSignal];
}

- (RACSignal *)verifyDeleteDeviceSignal{

    return [RACSignal combineLatest:@[[[CSTNetworkManager shareManager] reachableBOOLStateSignal], RACObserve([CSTDataManager shareManager], userProfile.deviceId)] reduce:^id(NSNumber *networkState, NSString *deviceID){
        
        return  deviceID ? networkState : @(NO);
    }];
}


- (RACSignal *)deleteDeviceSignal{

    return [[[[self p_deleteDeviceAPIManager] fetchDataSignal] doNext:^(id x) {
        
        [[CSTBLEManager shareManager] deleteBindWithHandler:nil];
        [CSTDataManager shareManager].userProfile.deviceId = nil;
        
    }] flattenMap:^RACStream *(id value) {
        
        return [[RACObserve([CSTBLEManager shareManager], peripheral.state) filter:^BOOL(id value) {
            
            return [value integerValue] == CBPeripheralStateDisconnected;
        }] take:1];
    }];
}


@end
