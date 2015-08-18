//
//  SDWebImageManager+CSTDownloadSignal.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
@class RACSignal;

@interface SDWebImageManager (CSTDownloadSignal)


+ (RACSignal *)cst_imageSignalWithURLString:(NSString *)urlString;

@end
