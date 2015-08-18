//
//  CSTUpdateFirmwareView.m
//  Coaster
//
//  Created by Ren Guohua on 14/11/9.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import "CSTUpdateFirmwareView.h"

@implementation CSTUpdateFirmwareView


- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect viewFrame = (CGRect){
    
        .origin.x = 0.0f,
        .origin.y = 0.0f,
        .size.width = 200.0f,
        .size.height = 80.0f,
    };
    
    if (self = [super initWithFrame:viewFrame])
    {
        [self initTitleLabel];
        [self initDetailLabel];
        [self initProgrssView];
    }
    
    return self;
}


- (void)initTitleLabel
{
    _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){
    
        .origin.x = 0.0f,
        .origin.y = 0.0f,
        .size.width = 200.0f,
        .size.height = 20.0f,
    }];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_titleLabel];
}

- (void)initDetailLabel
{
    _detailLabel = [[UILabel alloc] initWithFrame:(CGRect){
    
        .origin.x = 0.0f,
        .origin.y = CGRectGetMaxY(_titleLabel.frame) + 5.0f,
        .size.width = 200.0f,
        .size.height = 20.0f,
    
    }];
    
    _detailLabel.textColor = [UIColor blackColor];
    _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_detailLabel];
}

- (void)initProgrssView
{
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView .center = CGPointMake(CGRectGetMidX(self.frame),60.0f);
    
    [self addSubview:_progressView];
}


- (void)setProgressWithDownloadProgressOfTask:(NSURLSessionDownloadTask *)task
                                     animated:(BOOL)animated
{
    [task addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptions)0 context:(__bridge void*)self];
    [task addObserver:self forKeyPath:@"countOfBytesReceived" options:(NSKeyValueObservingOptions)0 context:(__bridge void*)self];
    
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(__unused NSDictionary *)change
                       context:(void *)context
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            if ([object countOfBytesExpectedToReceive] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView setProgress:[object countOfBytesReceived] / ([object countOfBytesExpectedToReceive] * 1.0f) / 2.0f animated:YES];
                });
            }
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
            if ([(NSURLSessionTask *)object state] == NSURLSessionTaskStateCompleted) {
                @try {
                    [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
                    
                    if (context == (__bridge void*)self) {
                        [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
                    }
                }
                @catch (NSException * __unused exception) {}
            }
        }
#endif
}

@end
