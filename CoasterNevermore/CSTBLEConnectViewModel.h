//
//  CSTBLEConnectViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSTBLEConnectViewModel : NSObject

@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, assign) BOOL isScanning;

- (void)runMethodAfterDelay:(float)delay withMethod:(void(^)())method;

- (void)startScan;

- (void)stopScan;

@end
