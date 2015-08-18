//
//  UIViewController+CSTDismissKeyboard.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "UIViewController+CSTDismissKeyboard.h"

@implementation UIViewController (CSTDismissKeyboard)


- (void)cst_dismissKeyboard
{
    for (id textField in [self.view subviews])
    {
        if ([textField isKindOfClass:[UITextField class]])
        {
            UITextField *theTextField = (UITextField*)textField;
            if ([theTextField isFirstResponder]) {
             
                [theTextField resignFirstResponder];
            }
        }
    }
}
@end
