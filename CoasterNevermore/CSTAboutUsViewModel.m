//
//  CSTAboutUsViewModel.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTAboutUsViewModel.h"
#import "CSTAPIBaseManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation CSTAboutUsViewModel




#pragma mark - Feedback

- (RACSignal *)feedbackSignalWithContent:(NSString *)content{

    if (!content) {
        
        return [RACSignal empty];
    }
    return [[self p_feedbackAPIManagerWithContent:content] fetchDataSignal];
}


- (CSTFeedBackAPIManager *)p_feedbackAPIManagerWithContent:(NSString *)content{

    
    if (!content) {
        return nil;
    }
    CSTFeedBackAPIManager *apiManager = [[CSTFeedBackAPIManager alloc] init];
    
    apiManager.parameters = @{@"content" : content};
    
    return apiManager;
}

@end
