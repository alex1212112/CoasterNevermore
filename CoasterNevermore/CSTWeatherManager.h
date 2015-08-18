//
//  CSTWeatherManager.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/11.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@class CSTWeather;
@class RACSignal;
@class CSTUserProfile;
@class CSTAQI;

extern NSString *const CSTAQIErrorKey;
extern const NSInteger CSTAQIErrorCode;

@interface CSTWeatherManager : NSObject

@property (nonatomic, copy) NSString *cityName;//城市名称
@property (nonatomic, copy) NSString *locationName;//当前位置的名称
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) CSTWeather *weather;
@property (nonatomic, strong, readonly) CSTAQI *aqi;

+ (instancetype)shareManager;

- (void)findCurrentLocation;

- (RACSignal *)calculateSuggestWaterSignalWithUserProfile:(CSTUserProfile *)userProfile weather:(CSTWeather *)weather;

- (NSInteger)calculateSuggestWaterWithUserProfile:(CSTUserProfile *)userProfile weather:(CSTWeather *)weather;

@end
