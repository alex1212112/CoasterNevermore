//
//  CSTTimerManager.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/19.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTTimerManager.h"

const NSInteger  CSTSMSTimeInteval = 120;

@implementation CSTTimerManager

+ (instancetype)shareManager
{
    static CSTTimerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)startTimer:(CSTSMSTimerType)type
{
    switch (type) {
        case CSTSMSTimerRegiser:
            
            self.registerSMSInterval = CSTSMSTimeInteval;
            self.registerSMSTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
            break;
        case CSTSMSTimerModifyPassword:
            self.modifyPasswordSMSInterval = CSTSMSTimeInteval;
            self.modifyPasswordSMSTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
            break;
        default:
            break;
    }
}

- (void)stopTimer:(CSTSMSTimerType)type
{
    switch (type) {
        case CSTSMSTimerRegiser:
            
            [self.registerSMSTimer invalidate];
            self.registerSMSTimer = nil;
            break;
        case CSTSMSTimerModifyPassword:
            [self.modifyPasswordSMSTimer invalidate];
            self.modifyPasswordSMSTimer = nil;
            break;
        default:
            break;
    }
}



- (void)handleTimer:(NSTimer *)timer
{
    if (timer == self.registerSMSTimer) {
        
        self.registerSMSInterval --;
    }else if (timer == self.modifyPasswordSMSTimer){
    
        self.modifyPasswordSMSInterval --;
    }
}


@end
