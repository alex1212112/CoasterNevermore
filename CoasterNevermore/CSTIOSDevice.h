//
//  CSTIOSDevice.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/3.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;

extern const NSInteger kiPhone6Width;
extern const NSInteger kiPhone6PWidth;
extern const NSInteger kiPhone5Width;

@interface CSTIOSDevice : NSObject

+ (BOOL)isIPhone5;
+ (BOOL)isIPhone6;
+ (BOOL)isIPhone6P;

+ (CGFloat)systemVersion;

+ (CGRect)mainScreenBounds;

@end
