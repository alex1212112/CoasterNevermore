//
//  CBPeripheral+CSTBLE.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "CSTBLEVersion.h"

@interface CBPeripheral (CSTBLE)

@property (nonatomic, strong) NSNumber *cst_discoverRSSI;
@property (nonatomic, strong) NSString *cst_deviceId;
@property (nonatomic, strong) CSTBLEVersion *cst_fmVersion;
@end
