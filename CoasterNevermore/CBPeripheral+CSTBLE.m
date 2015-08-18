//
//  CBPeripheral+CSTBLE.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CBPeripheral+CSTBLE.h"
#import <objc/runtime.h>

static char discoverRSSIKey;
static char deviceIdKey;
static char fmVersionKey;

@implementation CBPeripheral (CSTBLE)

- (void)setCst_discoverRSSI:(NSNumber *)discoverRSSI
{
    objc_setAssociatedObject (self,&discoverRSSIKey,discoverRSSI,OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)cst_discoverRSSI
{
    return (id)objc_getAssociatedObject(self, &discoverRSSIKey);
}


- (void)setCst_deviceId:(NSString *)deviceId
{
    objc_setAssociatedObject (self,&deviceIdKey,deviceId,OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)cst_deviceId
{
    return (id)objc_getAssociatedObject(self, &deviceIdKey);
}


- (void)setCst_fmVersion:(CSTBLEVersion *)fmVersion
{
    objc_setAssociatedObject (self,&fmVersionKey,fmVersion,OBJC_ASSOCIATION_RETAIN);
}

- (CSTBLEVersion *)cst_fmVersion
{
    
    return (id)objc_getAssociatedObject(self, &fmVersionKey);
}

@end
