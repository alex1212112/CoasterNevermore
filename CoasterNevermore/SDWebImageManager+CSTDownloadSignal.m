//
//  SDWebImageManager+CSTDownloadSignal.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "SDWebImageManager+CSTDownloadSignal.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation SDWebImageManager (CSTDownloadSignal)


+ (RACSignal *)cst_imageSignalWithURLString:(NSString *)urlString{

    return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlString] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                [subscriber sendNext:image];
                [subscriber sendCompleted];
        }];
    
    return nil;
    }];

}
@end
