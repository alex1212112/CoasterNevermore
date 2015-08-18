//
//  CSTMainContentViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/29.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;

@class RACSignal;

typedef NS_ENUM(NSInteger, CSTContentType) {
    CSTContentTypeUser,
    CSTContentTypeMate,
};

@interface CSTMainContentViewModel : NSObject

@property (nonatomic, assign,readonly) CSTContentType contentType;
@property (nonatomic, assign) CGFloat  thicknessRatio;

@property (nonatomic, strong) UIImage *topImage;
@property (nonatomic, strong) UIImage *middleImage;
@property (nonatomic, strong) UIImage *bottomImage;

@property (nonatomic, copy) NSString *topTitle;
@property (nonatomic, copy) NSString *middleTitle;
@property (nonatomic, copy) NSString *bottomTitle;
@property (nonatomic, copy) NSString *topDetailText;
@property (nonatomic, copy) NSString *middleDetailText;
@property (nonatomic, copy) NSString *bottomDetailText;

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSAttributedString *todayDrinkWaterString;
@property (nonatomic, copy) NSString *topDetail;
@property (nonatomic, copy) NSString *middleDetail;
@property (nonatomic, copy) NSString *bottomDetail;

@property (nonatomic, copy) NSString *suggestWater;
@property (nonatomic, copy) NSString *remainWater;
@property (nonatomic, copy) NSString *progress;
@property (nonatomic, copy) NSString *bleStateString;
@property (nonatomic, copy) NSString *remindMessage;

@property (nonatomic, strong) UIColor * trackTintColor;
@property (nonatomic, strong) UIColor *bleStateColor;
@property (nonatomic, assign) CGFloat circleProgress;

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *weatherDescrithion;
@property (nonatomic, copy) NSString *tempratureText;
@property (nonatomic, copy) NSString *humidityText;
@property (nonatomic, copy) NSString *aqiText;

@property (nonatomic, strong) UIImage *weatherIcon;


- (instancetype)initWithContentType:(CSTContentType)type;

- (void)refresCurrentPageData;

- (RACSignal *)sendeMessageToMateSignal;

- (RACSignal *)sendeMessageToMateSignalWithMessage:(NSString *)message;

- (NSString *)sendMessage;

@end
