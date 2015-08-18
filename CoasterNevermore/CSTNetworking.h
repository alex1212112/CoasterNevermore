//
//  CSTNetworking.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@class RACSignal;

extern NSString *const CSTCoasterBaseURLString;
extern NSString *const CSTWeatherBaseURLString;
extern NSString *const CSTQQHealthBaseURLString;
extern NSString *const CSTAQIBaseURLString;
extern NSString *const CSTNotReacableErrorKey;
extern const NSInteger CSTNotReachableCode;


@interface CSTNetworking : NSObject

@end

@interface CSTNetworkManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

+ (instancetype)shareManager;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)requestMothod serializer:(AFHTTPRequestSerializer *)requestSerializer baseURLString:(NSString *)urlString apiName:(NSString *)apiName parameters:(NSDictionary *)parameters;

- (NSURLSessionTask *)dataTaskWithURLRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithURLRequest:(NSURLRequest *)request toFilePath:(NSString *)path completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

+ (RACSignal *)reachableSignal;

- (RACSignal *)reachableStateSignal;

- (RACSignal *)reachableBOOLStateSignal;

- (void)enable;

@end
