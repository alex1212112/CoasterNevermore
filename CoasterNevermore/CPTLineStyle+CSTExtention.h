//
//  CPTLineStyle+CSTExtention.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/27.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <CorePlot/ios/CorePlot-CocoaTouch.h>

@interface CPTLineStyle (CSTExtention)

+ (CPTLineStyle *)cst_linestyleWithColor:(CPTColor *)color width:(CGFloat)lineWidth;
@end
