//
//  CSTUserCenterViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/1.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserCenterViewController.h"
#import <ReactiveCocoa.h>
#import "CSTRouter.h"

@interface CSTUserCenterViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end


@implementation CSTUserCenterViewController

#pragma mark - Life cycle


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    
    [self.view addGestureRecognizer:self.tap];
    //self.blurStyle = UIBlurEffectStyleLight;
}


#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.view) {
        return YES;
    }
    return NO;
}

#pragma mark - Event response

- (void)p_configEventWithTap:(UITapGestureRecognizer *)tap{

    @weakify(self);
    
    [[_tap rac_gestureSignal]subscribeNext:^(id x) {
        
        @strongify(self);
        
        [CSTRouter disMissViewController:self];
    }];
}

#pragma mark - Setters and getters

- (UITapGestureRecognizer *)tap{

    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] init];
        _tap.delegate = self;
        [self p_configEventWithTap:_tap];
    }
    
    return _tap;
}
@end
