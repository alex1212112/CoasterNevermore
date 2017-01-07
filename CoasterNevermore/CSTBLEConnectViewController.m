//
//  CSTBLEConnectViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/23.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBLEConnectViewController.h"
#import "CSTRadarView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTRouter.h"
#import "CSTBLEConnectViewModel.h"
#import "CSTBLEScanResultViewController.h"
#import "CSTUserAccessViewController.h"

@interface CSTBLEConnectViewController ()
@property (weak, nonatomic) IBOutlet CSTRadarView *radarView;
@property (weak, nonatomic) IBOutlet UIButton *reScanButton;
@property (weak, nonatomic) IBOutlet UIButton *notNowButton;
@property (weak, nonatomic) IBOutlet UIButton *questionButton;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coasterView;


@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *notNowButtonConstraintsFirst;


@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *reScanButtonConstraintsFirst;

@property (strong, nonatomic) NSArray *notNowButtonConstraintsSecond;

@property (strong, nonatomic) NSArray *reScanButtonConstraintsSecond;

@property (strong, nonatomic) NSTimer *scanTimer;


@end
@implementation CSTBLEConnectViewController

#pragma mark - Life cycle
- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configNavigationBar];
    [self p_configTap];
    [self p_configReScanButton];
    [self p_configNotNowButton];
    
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self p_configCoasterViewAfterViewDidLayout];
    [self.radarView startAnimation];
    [self.viewModel startScan];
    [self p_startTimer];
    [self p_showScanResultAfterDelay:2.0];
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [self.radarView stopAnimation];
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

#pragma mark - CSTBLEConnectDelegate

- (void)userDidCancelScan{

    if (self.reScanButton.hidden) {
        
        self.reScanButton.hidden = NO;
        self.reScanButton.alpha = 0;
        self.detailLabel.text = @"是否重新搜索 ?";
        [self.radarView stopAnimation];
        [self.viewModel stopScan];
        [self p_stopTimer];
        
        [NSLayoutConstraint  deactivateConstraints:self.reScanButtonConstraintsFirst];
        [NSLayoutConstraint  deactivateConstraints:self.notNowButtonConstraintsFirst];
        [NSLayoutConstraint  activateConstraints:self.reScanButtonConstraintsSecond];
        [NSLayoutConstraint  activateConstraints:self.notNowButtonConstraintsSecond];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self.view layoutSubviews];
            self.reScanButton.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            //self.questionButton.hidden = NO;
        }];
    }
}

#pragma mark - Private method

- (void)p_configNavigationBar{

    self.navigationItem.title = @"蓝牙连接";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    //self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;

}


- (void)p_configCoasterViewAfterViewDidLayout{

    [self.coasterView removeFromSuperview];
    [self.view.layer insertSublayer:self.coasterView.layer above:self.radarView.layer];
}


- (void)p_configTap{

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tap];
    
    @weakify(self);
    
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        [self p_stopScan];
    }];
}

- (void)p_stopScan{

    if (self.reScanButton.hidden) {
        
        self.reScanButton.hidden = NO;
        self.reScanButton.alpha = 0;
        self.detailLabel.text = @"未搜索到智能杯垫";
        [self.radarView stopAnimation];
        [self.viewModel stopScan];
        [self p_stopTimer];
        
        [NSLayoutConstraint  deactivateConstraints:self.reScanButtonConstraintsFirst];
        [NSLayoutConstraint  deactivateConstraints:self.notNowButtonConstraintsFirst];
        [NSLayoutConstraint  activateConstraints:self.reScanButtonConstraintsSecond];
        [NSLayoutConstraint  activateConstraints:self.notNowButtonConstraintsSecond];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
//            [self.view layoutIfNeeded];
            self.reScanButton.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            self.questionButton.hidden = NO;
        }];
    }
}


- (void)p_startScan{

    if (!self.reScanButton.hidden) {

        self.questionButton.hidden = YES;
        [self.radarView startAnimation];
        [self.viewModel startScan];
        
        [self p_startTimer];
        [self p_showScanResultAfterDelay:2.0];
        
        self.detailLabel.text = @"正在搜索Coaster智能杯垫...";
        [NSLayoutConstraint  deactivateConstraints:self.reScanButtonConstraintsSecond];
        [NSLayoutConstraint  deactivateConstraints:self.notNowButtonConstraintsSecond];
        [NSLayoutConstraint  activateConstraints:self.reScanButtonConstraintsFirst];
        [NSLayoutConstraint  activateConstraints:self.notNowButtonConstraintsFirst];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
//            [self.view layoutIfNeeded];
            self.reScanButton.alpha = 0;
        } completion:^(BOOL finished) {
            
            self.reScanButton.hidden = YES;
        }];
    }
}

- (void)p_configReScanButton{

    
    NSAttributedString *attibutedString = [[NSAttributedString alloc] initWithString:@"重新搜索" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15.0],NSUnderlineStyleAttributeName : @2}];
    
    [self.reScanButton setAttributedTitle:attibutedString forState:UIControlStateNormal];
    
//    @weakify(self);
//    [[self.reScanButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        @strongify(self);
//        
//        [self p_startScan];
//    }];
    
    [self.reScanButton addTarget:self action:@selector(reScanButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reScanButtonDidClick:(id)sender {

    [self p_startScan];
}

- (void)p_configNotNowButton{

    NSAttributedString *attibutedString = [[NSAttributedString alloc] initWithString:@"暂不绑定" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15.0],NSUnderlineStyleAttributeName : @2}];
    
    [self.notNowButton setAttributedTitle:attibutedString forState:UIControlStateNormal];
    
    @weakify(self);
    [[self.notNowButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        [self p_stopScan];
        
        if ([self.navigationController.viewControllers[0] isKindOfClass:[CSTUserAccessViewController class]]) {
            
             [CSTRouter routerToViewControllerType:CSTRouterViewControllerTypeMain fromViewController:self];
        }else{
        
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }];

}

- (void)p_showScanResultAfterDelay:(CGFloat)delay{

    
    @weakify(self);
    [self.viewModel runMethodAfterDelay:delay withMethod:^{
        
        @strongify(self);
        [[[[[RACObserve(self.viewModel, devices) map:^id(id value) {
            
            return @([value count]);
        }] filter:^BOOL(id value) {
            
            return [value integerValue] != 0;
            
        }] take:1] map:^id(id value) {
            
            return @(self.viewModel.isScanning);
            
        }] subscribeNext:^(id x) {
            
            if (![x boolValue]) {
                
                return ;
            }
            [self p_stopTimer];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil];
            CSTBLEScanResultViewController *scanResultVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTBLEScanResultViewController"];
            scanResultVC.transitionType = VVBlurTransitionTypeTypeBottomToTop;
            scanResultVC.delegate = self;
            
            [self presentViewController:scanResultVC animated:YES completion:nil];
        }];
        
    }];
}

- (void)p_startTimer{
    
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(p_stopScan) userInfo:nil repeats:NO];
}

- (void)p_stopTimer{

    [self.scanTimer invalidate];
    self.scanTimer = nil;
}

#pragma mark - Setters and getters

- (NSArray *)reScanButtonConstraintsSecond{
    if (!_reScanButtonConstraintsSecond) {
        
        
        NSLayoutConstraint *first = self.reScanButtonConstraintsFirst[1];
        CGFloat standardConstant = first.constant;
        
        NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.reScanButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:(2.0f / 3.0 )constant:0];
        
        NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.reScanButton attribute:NSLayoutAttributeBottom multiplier: (25.0 / 24.0) constant:standardConstant];
        _reScanButtonConstraintsSecond = @[constraintCenterX,constraintBottom];
        
    }
    return _reScanButtonConstraintsSecond;
}


- (NSArray *)notNowButtonConstraintsSecond{

    if (!_notNowButtonConstraintsSecond) {
        
        NSLayoutConstraint *first = self.notNowButtonConstraintsFirst[1];
        CGFloat standardConstant = first.constant;
        
        NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.notNowButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:(4.0 / 3.0 )constant:0];
        NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.notNowButton attribute:NSLayoutAttributeBottom multiplier: (25.0 / 24.0) constant:standardConstant];
        _notNowButtonConstraintsSecond = @[constraintCenterX,constraintBottom];
    }
    
    return _notNowButtonConstraintsSecond;
}

- (CSTBLEConnectViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTBLEConnectViewModel alloc] init];
    }
    
    return _viewModel;
}


@end
