//
//  CSTAboutUsViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@class RACSignal;

@interface CSTAboutUsViewModel : NSObject

- (RACSignal *)feedbackSignalWithContent:(NSString *)content;

@end
