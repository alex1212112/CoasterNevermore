//
//  CSTNetworking.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTNetworking.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/UIKit+AFNetworking.h>

//NSString *const CSTCoasterBaseURLString = @"http://121.41.94.186:10001/";

//NSString *const CSTCoasterBaseURLString = @"http://121.40.130.249:10001/";
//NSString *const CSTCoasterBaseURLString = @"http://www.adminchao.com:2017/";
NSString *const CSTCoasterBaseURLString = @"http://192.168.31.10/";




NSString *const CSTWeatherBaseURLString = @"http://api.openweathermap.org/data/2.5/weather";
NSString *const CSTQQHealthBaseURLString = @"https://openmobile.qq.com/v3/health/report_drinking";
NSString *const CSTAQIBaseURLString = @"http://apis.baidu.com/apistore/aqiservice/aqi";

NSString *const CSTNotReacableErrorKey = @"com.nevermore.Coaster.error.notReachable";

const NSInteger CSTNotReachableCode = 10000404;


@implementation CSTNetworking

@end


@interface CSTNetworkManager ()

@end

@implementation CSTNetworkManager

static CSTNetworkManager *instance = nil;

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
    
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager)
    {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",nil];
    }

    return _sessionManager;
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)requestMothod
                                serializer:(AFHTTPRequestSerializer *)requestSerializer
                             baseURLString:(NSString *)baseURLString
                                   apiName:(NSString *)apiName
                                parameters:(NSDictionary *)parameters
{
    
    return [requestSerializer requestWithMethod:requestMothod
                                      URLString:[baseURLString stringByAppendingString:apiName]
                                     parameters:parameters error:nil];
}

- (NSURLSessionTask *)dataTaskWithURLRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
    
    return dataTask;
}


- (NSURLSessionDownloadTask *)downloadTaskWithURLRequest:(NSURLRequest *)request toFilePath:(NSString *)path completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSString *filepath = [[[NSURL fileURLWithPath:path isDirectory:YES] URLByAppendingPathComponent:[NSString stringWithFormat:@"Coaster%@",[response suggestedFilename]]] path];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
        }
        
        return [NSURL fileURLWithPath:filepath];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (completionHandler)
        {
            completionHandler(response,filePath,error);
        }
    }];
    
    [downloadTask resume];
    
    return downloadTask;
}


+ (RACSignal *)reachableSignal
{
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        NSString *domain = AFStringFromNetworkReachabilityStatus([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus);
        NSError *error = [NSError errorWithDomain:domain code:CSTNotReachableCode userInfo:@{CSTNotReacableErrorKey:@"not reachable"}];
       
        if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)
        {
            [subscriber sendError:error];
        }
        else
        {
            [subscriber sendNext:@([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus)];
            [subscriber sendCompleted];
        }
       return nil;
    }];
}

- (RACSignal *)reachableStateSignal{

 return  RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus);
}

- (RACSignal *)reachableBOOLStateSignal{

    return RACObserve([AFNetworkReachabilityManager sharedManager], reachable);
}

- (void)enable
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
