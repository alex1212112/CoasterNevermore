//
//  UIImage+CSTTransformBase64String.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "UIImage+CSTTransformBase64String.h"

@implementation UIImage (CSTTransformBase64String)

- (NSString *)cst_base64StringLessThanFiftyKb{

    NSData *originData = UIImageJPEGRepresentation(self,1.0f);
    NSData *compressionData = originData.length > 50000.0f ? UIImageJPEGRepresentation(self,50000.0f / originData.length) : originData;
    NSString *base64String = [compressionData base64EncodedStringWithOptions:0];
    return base64String;
}

- (NSString *)cst_base64String{
    
    NSData *originData = UIImageJPEGRepresentation(self,1.0f);
    NSString *base64String = [originData base64EncodedStringWithOptions:0];
    return base64String;
}
@end
