//
//  CSTUserInformation.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserProfile.h"
#import "CSTNetworking.h"
#import <ReactiveCocoa.h>
#import <SDWebImage/SDWebImageManager.h>

@implementation CSTUserProfile

#pragma  mark - Life cycle
- (instancetype)init{

    if (self = [super init]) {
        
       // [self p_configObserverWithImageURLString];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{

    if (self = [super initWithCoder:coder]) {
        
       // [self p_configObserverWithImageURLString];
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"uid" : @"Uid",
             @"birthday" : @"Birthday",
             @"email" : @"Email",
             @"height" : @"Height",
             @"weight" : @"Weight",
             @"nickname" : @"NickName",
             @"phone" : @"Phone",
             @"gender" : @"Gender",
             @"deviceId" : @"DeviceId",
             };
}


#pragma mark - Private method

- (void)p_configObserverWithImageURLString{

    @weakify(self);
    [[RACObserve(self, imageURLString) ignore:nil] subscribeNext:^(id x) {
        @strongify(self);

        self.avatarImage = [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:x] ?: [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:x];
        
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
            
            [[[SDWebImageManager sharedManager] imageCache] clearDisk];
            [[[SDWebImageManager sharedManager] imageCache] clearMemory];
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:x] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                if (error) {
                    return ;
                }
                if (image && !self.avatarImage) {
                    
                    self.avatarImage = image;
                }
            }];
        }
    }];
}

#pragma mark - Public method
- (NSData *)last4DataBytes
{
    NSString *userId = [self.uid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    userId = [userId substringFromIndex:userId.length - 8];
    
    long long uid = strtoul([userId UTF8String],0,16);
    
    NSData *uidData = [NSData dataWithBytes:&uid length:4];
    
    return uidData;
}

#pragma mark - Setters and getters

- (NSString *)imageURLString
{
    if (self.uid) {
        return [NSString stringWithFormat:@"%@api/avatar/%@",CSTCoasterBaseURLString,self.uid];
    }
    return nil;
}

+ (NSSet *)keyPathsForValuesAffectingImageURLString
{
    return [NSSet setWithObject:@"uid"];
}


- (NSString *)username{
    
    if (self.email) {
        
        return self.email;
    }
    
    if (self.phone) {
        
        return self.phone;
    }
    
    return self.nickname;
}

+ (NSSet *)keyPathsForValuesAffectingUsername
{
    return [NSSet setWithObjects:@"email",@"phone",@"nickname", nil];
}

@end
