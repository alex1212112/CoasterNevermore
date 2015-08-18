//
//  CSTBLEScanResultViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBLEScanResultViewModel.h"
#import "CSTBLEManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <NSArray+LinqExtensions.h>
#import "CBPeripheral+CSTBLE.h"

@implementation CSTBLEScanResultViewModel


- (instancetype)init{
    
    if (self = [super init]) {
        
        [self p_configObserverWithBLEDevices];
    }
    
    return self;
}


#pragma mark - Observers

- (void)p_configObserverWithBLEDevices{
    
    RAC(self,deviceDescriptions) = [RACObserve([CSTBLEManager shareManager], devices)map:^id(id value) {
        
        NSArray *array = (NSArray *)value;
        
        return [array linq_select:^id(CBPeripheral *periphera) {
            
            
            NSString *title = periphera.cst_deviceId;
            
            if ([periphera.cst_deviceId hasPrefix:@"CUP-MAT"]) {
                
                title = [NSString stringWithFormat:@"ID:%@",[periphera.cst_deviceId stringByReplacingOccurrencesOfString:@"CUP-MAT" withString:@""]];
            }
            
            NSInteger rssi = [periphera.cst_discoverRSSI integerValue];
            
            NSString *detail = nil;
            if (rssi < 0 && rssi > -50) {
                
                detail = [NSString stringWithFormat:@"信号强度:高"];
            }else if (rssi <= -50 && rssi > -90){
                
                detail = [NSString stringWithFormat:@"信号强度:中"];
            }else{
            
                detail = [NSString stringWithFormat:@"信号强度:低"];
            }
            
            return @{@"title" : title,
                     @"detail" : detail
                     };
        }];
    }];
    
    RAC(self,devices) = RACObserve([CSTBLEManager shareManager], devices);
}

#pragma mark - Public

- (NSString *)PeriphralIDWithIndexPath:(NSIndexPath *)indexPath{

    return [[CSTBLEManager shareManager].devices[indexPath.row] valueForKey:@"cst_deviceId"];
}

- (CGFloat)widthWithConnectStateString:(NSString *)string Font:(UIFont *)font{

     CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 25.0) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil];
    
    return CGRectGetWidth(rect);
}

@end
