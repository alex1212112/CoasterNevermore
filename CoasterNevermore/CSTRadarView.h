//
//  CSTRadarView.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/24.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTRadarView : UIView

@property (nonatomic, assign, getter = isAnimated) BOOL animated;

- (void)startAnimation;

- (void)stopAnimation;
@end
