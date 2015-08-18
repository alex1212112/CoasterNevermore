//
//  CSTBLEManager.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

@class BLETIOADProfile;
@class CSTBLEVersion;

typedef  void(^HandleEvent)();


extern NSString *const CSTBLEBindErrorReasonKey;
extern const NSInteger CSTBLEBindErrorTargetIsBindedCode;
extern const NSInteger CSTBLEBindErrorUnknowCode;

@interface CSTBLEManager : NSObject

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) BLETIOADProfile *oadProfile;
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, strong) NSNumber *battery;

@property (nonatomic, strong) NSDictionary *testDic;
@property (nonatomic, strong) NSArray *testArray;

@property (nonatomic, strong) CSTBLEVersion *serviceVersion;


@property (nonatomic, assign, getter=isFirmwareNeedUpdate) BOOL firmwareNeedUpdate;

@property (nonatomic, assign,getter = isSCanning) BOOL scanning;

+ (instancetype)shareManager;

- (void)scan;

- (void)stopScan;

- (void)configCentralManager;

- (void)cancelPeripheralConnect;

- (void)deleteBindWithHandler:(HandleEvent)handler;

- (void)bindPeripheral:(CBPeripheral*)peripheral Options:(NSDictionary*)options success:(HandleEvent)success fail:(HandleEvent)fail;

- (void)downLoadAndUpdateFirmware;


@end
