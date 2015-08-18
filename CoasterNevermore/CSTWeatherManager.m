//
//  CSTWeatherManager.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/11.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTWeatherManager.h"
#import "CSTIOSDevice.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTWeather.h"
#import "CSTAPIBaseManager.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import "RACSignal+CSTModel.h"
#import "CSTUserProfile.h"
#import "CSTDataManager.h"
#import "CSTAQI.h"


NSString *const CSTAQIErrorKey = @"com.nevermore.Coaster.error.aqiNull";

const NSInteger CSTAQIErrorCode = 10009404;


static const CGFloat weightVar = 0.0326;
static const CGFloat ph = 1.1;
static const CGFloat pl = 0.9;
static const CGFloat tl =  -5;
static const CGFloat th = 35;
static const CGFloat qh = 1.1;
static const CGFloat ql = 0.8;
static const CGFloat hl = 0.0;
static const CGFloat hh = 1.0;

@interface CSTWeatherManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) CSTWeather *weather;
@property (nonatomic, strong, readwrite) CSTAQI *aqi;

@property (nonatomic, assign) BOOL isFirstUpdate;

@end

@implementation CSTWeatherManager

#pragma mark - Life cycle
+ (instancetype)shareManager{
    
    static CSTWeatherManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init{

    if (self = [super init])
    {
        [self p_configObserversWithCurrentLocation];
    }
    return self;
}

#pragma mark - CCLocation delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    
//    if (self.isFirstUpdate) {
//        self.isFirstUpdate = NO;
//        return;
//    }
    
    CLLocation *newLocation = [locations lastObject];
    
    if (newLocation.horizontalAccuracy > 0) {
        [self.locationManager stopUpdatingLocation];
        self.currentCoordinate = newLocation.coordinate;
        self.currentLocation = newLocation;
    }
}



- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}


#pragma mark - Public method
- (void)findCurrentLocation
{
    self.isFirstUpdate = YES;
    if ([CSTIOSDevice systemVersion] > 8.0f)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

- (RACSignal *)calculateSuggestWaterSignalWithUserProfile:(CSTUserProfile *)userProfile weather:(CSTWeather *)weather{
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        NSInteger suggest = [self calculateSuggestWaterWithUserProfile:userProfile weather:weather];
        
        [subscriber sendNext:@(suggest)];
        [subscriber sendCompleted];
        
        return nil;
    }];
}

- (NSInteger)calculateSuggestWaterWithUserProfile:(CSTUserProfile *)userProfile weather:(CSTWeather *)weather
{
    if (!userProfile)
    {
        return 0;
    }
    NSInteger suggestWater;
    
    NSInteger weight = [userProfile.weight integerValue];
    
    NSString *userTempratureString = weather.temp;
    
    NSInteger temprature = (NSInteger)([userTempratureString floatValue]);
    
    double humidity = [weather.humidity doubleValue] / 100;
    
    double tvar,hvar;
    if (!userTempratureString)
    {
        tvar = 1.0f;
    }
    else
    {
        tvar = (pl + (ph - pl) /(th - tl) * (temprature - tl));
    }
    
    if (!weather.humidity)
    {
        hvar = 1.0f;
    }
    else
    {
        hvar = (ql + (qh - ql) / (hh - hl) * (hh - humidity));
    }
    
    suggestWater = weight * weightVar * tvar * hvar * 1000;
    
    return suggestWater;
}


#pragma mark - Observers
- (void)p_configObserversWithCurrentLocation{

    @weakify(self);
    [[RACObserve(self, currentLocation) ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        
        [self p_parseCityNameWithLocation:x];
        [self p_updateWeaterWithLocation:x];
        
    }];
}


#pragma mark - Private method

- (void)p_parseCityNameWithLocation:(CLLocation *)location{

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation: location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         //得到自己当前最近的地名
         
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSString *subLocality = placemark.addressDictionary[@"SubLocality"];
         __block NSString *city = placemark.addressDictionary[@"City"];
         NSString *state = placemark.addressDictionary[@"State"];
         self.locationName = placemark.addressDictionary[@"Name"];
         
         NSString *cityName;
         if (subLocality)
         {
             cityName = subLocality;
         }
         else if (city)
         {
             cityName = city;
         }
         else if (state)
         {
             cityName = state;
         }
         else
         {
             cityName = @"本地";
         }
         self.cityName = cityName;
         
         
         @weakify(self);
         if (subLocality) {
             
             subLocality = [self p_standaredCityNameWithName:subLocality];
             [[self p_aqiSignalWithCity:subLocality] subscribeNext:^(id x) {
                 
                 @strongify(self);
                 self.aqi = x;
                 
             }error:^(NSError *error) {
                 
                @strongify(self);
                 if (city) {
                     
                     city = [self p_standaredCityNameWithName:city];
                     [[self p_aqiSignalWithCity:city] subscribeNext:^(id x) {
                         
                         self.aqi = x;;
                     }];
                 }
             }];
         }else if (city){
         
             city = [self p_standaredCityNameWithName:city];
             [[self p_aqiSignalWithCity:city] subscribeNext:^(id x) {
                 
                @strongify(self);
                 self.aqi = x;;
             }];
         }
     }];
}

- (NSString *)p_standaredCityNameWithName:(NSString *)cityName{

    NSString *result = nil;
    
    if ([cityName hasSuffix:@"市市辖区"]){
        
        result = [cityName stringByReplacingCharactersInRange:(NSRange){cityName.length - 4, 4} withString:@""];
    }else if ([cityName hasSuffix:@"区"] ||[cityName hasSuffix:@"市"] ||[cityName hasSuffix:@"州"] ) {
        
        result = [cityName stringByReplacingCharactersInRange:(NSRange){cityName.length - 1, 1} withString:@""];
    }
    return result;
}


- (RACSignal *)p_aqiSignalWithCity:(NSString *)cityName{
    

    return [[[[[self p_aqiAPIManagerWithCity:cityName] fetchDataSignal] flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
    }] map:^id(id value) {
        
        return value[@"retData"];
        
    }] flattenMap:^RACStream *(id value) {
        
        NSDictionary *dic = value;
        if ([dic count] == 0) {
            
            NSError *error = [NSError errorWithDomain:@"无数据" code:CSTAQIErrorCode userInfo:@{CSTAQIErrorKey : @"无数据"}];
            
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                [subscriber sendError:error];
                return nil;
            }];
        }
        
        return [RACSignal cst_transformSignalWithModelClass:[CSTAQI class] dictionary:value];
    }];
}

- (CSTAQIAPIManager *)p_aqiAPIManagerWithCity:(NSString *)cityName{

    CSTAQIAPIManager *apiManager = [[CSTAQIAPIManager alloc] init];
    apiManager.parameters = @{@"city" : cityName};
    
    return apiManager;
}


- (void)p_updateWeatherAndSuggestWaterWithLocation:(CLLocation *)location{

    @weakify(self);
    
    [[[self p_updateWeatherSignalWithLocation:location] doNext:^(id x) {
        @strongify(self);
        self.weather = x;
    }] flattenMap:^RACStream *(id value) {
        
         return [self calculateSuggestWaterSignalWithUserProfile:[CSTDataManager shareManager].userProfile weather:value];
    }];
}

- (void)p_updateWeaterWithLocation:(CLLocation *)location{

    [[self p_updateWeatherSignalWithLocation:location] subscribeNext:^(id x) {
        
        self.weather = x;
    }];
}

- (RACSignal *)p_updateWeatherSignalWithLocation:(CLLocation *)location{
    
   return  [[[[self p_weatherAPImanagerWithLocaton:location] fetchDataSignal]flattenMap:^RACStream *(id value) {
        
        return [value cst_parsedJsonDataSignal];
        
    }] flattenMap:^RACStream *(id value) {
        
        return [RACSignal cst_transformSignalWithModelClass:[CSTWeather class] dictionary:value];
    }];
}



- (CSTWeatherAPIManager *)p_weatherAPImanagerWithLocaton:(CLLocation *)location{

    CSTWeatherAPIManager *apiManager = [[CSTWeatherAPIManager alloc] init];
    apiManager.parameters = [self p_weaterAPIParametersWithLocation:location];
    
    return apiManager;
}

- (NSDictionary *)p_weaterAPIParametersWithLocation:(CLLocation *)location{

    if (!location) {
        return nil;
    }
    
    NSString *lat = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    return @{
             @"lat" : lat,
             @"lon" : lon,
             @"lang" : NSLocalizedString(@"en_us", @"en_us")
             };
}



#pragma mark - Setters and getters

- (CLLocationManager *)locationManager{

    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        _locationManager.distanceFilter = 10000.0f;
    }
    return _locationManager;
}

@end
