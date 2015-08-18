//
//  CSTWeather.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/11.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTWeather.h"

@implementation CSTWeather

#pragma mark - Life cycle
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"maxTemp" : @"main.temp_max",
             @"minTemp" : @"main.temp_min",
             @"temp" : @"main.temp",
             @"humidity" : @"main.humidity",
             @"weatherDescription" : @"weather",
             @"iconName" : @"weather"
             };
}

+ (NSValueTransformer *)weatherDescriptionJSONTransformer {
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *value, BOOL *success, NSError *__autoreleasing *error) {
        
       return [value firstObject][@"description"];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return @[value];
    }];
}


+ (NSValueTransformer *)maxTempJSONTransformer {
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSString stringWithFormat:@"%ld",(long)([value floatValue] - 273.15)];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSNumber numberWithFloat:([value floatValue] + 273.15)];
    }];
}

+ (NSValueTransformer *)minTempJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSString stringWithFormat:@"%ld",(long)([value floatValue] - 273.15)];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSNumber numberWithFloat:([value floatValue] + 273.15)];
    }];
}

+ (NSValueTransformer *)tempJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSString stringWithFormat:@"%ld",(long)([value floatValue] - 273.15)];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        return [NSNumber numberWithFloat:([value floatValue] + 273.15)];
    }];
}

+ (NSValueTransformer *)iconNameJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSString *key = [value firstObject][@"icon"];
        return [CSTWeather p_imageMap][key];
        
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        __block NSString *iconIdentify = nil;
        [[CSTWeather p_imageMap] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if ([obj isEqualToString:value]) {
                
                iconIdentify = key;
                *stop = YES;
            }
        }];
        return iconIdentify;
    }];
}




#pragma mark - Private method
+ (NSDictionary *)p_imageMap {
    static NSDictionary *_imageMap = nil;
    if (!_imageMap) {
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"10dd" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}


@end
