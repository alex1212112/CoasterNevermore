//
//  CSTTimerManager.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/19.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CSTSMSTimerType) {
    CSTSMSTimerRegiser,
    CSTSMSTimerModifyPassword,
};

extern const NSInteger CSTSMSTimeInteval;

@interface CSTTimerManager : NSObject

@property (nonatomic, strong) NSTimer *registerSMSTimer;

@property (nonatomic, strong) NSTimer *modifyPasswordSMSTimer;

@property (nonatomic, assign) NSInteger registerSMSInterval;

@property (nonatomic, assign) NSInteger modifyPasswordSMSInterval;


- (void)startTimer:(CSTSMSTimerType)type;

- (void)stopTimer:(CSTSMSTimerType)type;


+ (instancetype)shareManager;



@end
