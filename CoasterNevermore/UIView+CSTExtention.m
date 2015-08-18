//
//  UIView+CSTExtention.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "UIView+CSTExtention.h"

@implementation UIView (CSTExtention)

- (UIImage *)cst_snapshotImage{

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end
