//
//  CSTUpdateFirmwareView.h
//  Coaster
//
//  Created by Ren Guohua on 14/11/9.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTUpdateFirmwareView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIProgressView *progressView;

- (void)setProgressWithDownloadProgressOfTask:(NSURLSessionDownloadTask *)task
                                     animated:(BOOL)animated;

@end
