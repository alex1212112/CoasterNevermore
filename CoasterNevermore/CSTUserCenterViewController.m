//
//  CSTUserCenterViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/1.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserCenterViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTRouter.h"

@interface CSTUserCenterViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end


@implementation CSTUserCenterViewController

#pragma mark - Life cycle


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    
    [self.view addGestureRecognizer:self.tap];
    [self.view addGestureRecognizer:self.pan];
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
    if (touch.view == self.view && gestureRecognizer == self.tap) {
        return YES;
    }
    if (gestureRecognizer == self.pan) {
        
        return YES;
    }
    return NO;
}

#pragma mark - Event response

- (void)p_configEventWithTap:(UITapGestureRecognizer *)tap{

    @weakify(self);
    
    [[tap rac_gestureSignal]subscribeNext:^(id x) {
        
        @strongify(self);
        
        [CSTRouter disMissViewController:self];
    }];
}

- (void)p_configEventWithPan:(UIPanGestureRecognizer *)pan{

    if (pan.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
    
        CGPoint point = [pan translationInView:pan.view];
        if (point.x < -20.0) {
            
            [CSTRouter disMissViewController:self];
        }
        [pan setTranslation:CGPointZero inView:pan.view];
    }
    
}

#pragma mark - Setters and getters

- (UITapGestureRecognizer *)tap{

    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] init];
        [_tap requireGestureRecognizerToFail:self.pan];
        _tap.delegate = self;
        [self p_configEventWithTap:_tap];
    }
    
    return _tap;
}

- (UIPanGestureRecognizer *)pan{

    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] init];
        _pan.delegate = self;
        [_pan addTarget:self action:@selector(p_configEventWithPan:)];
    }
    return _pan;
}

@end
