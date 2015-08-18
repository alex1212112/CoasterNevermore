//
//  CSTTodayWaterDataViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMainDataViewController.h"
#import "CSTMainContentViewController.h"
#import "CSTMainContentViewModel.h"
#import "CSTWillBindMateViewController.h"
#import <ReactiveCocoa.h>
#import "CSTUserToken.h"
#import "Colours.h"
#import "CSTRouter.h"
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import "CSTMainDataViewModel.h"
#import "CSTUserCenterViewController.h"
#import "CSTDetailDataViewController.h"

@interface CSTMainDataViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UISegmentedControl *titleSegment;
@property (nonatomic, strong) UIViewController *leftViewController;
//@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, strong) UIViewController *willBindMateViewController;
@property (nonatomic, strong) UIViewController *mateContentViewController;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) NSArray *constraints;

@end

@implementation CSTMainDataViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_configNavigationBar];
    [self p_configScrollView];
    [self p_configLeftViewController];
    [self p_configWillBindMateViewController];
    [self p_configMateContentViewController];
    [self p_configRightViewController];

    [self p_configConstraints];
    [self.view addGestureRecognizer:self.tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.viewModel refreshUserAvatar];
}

- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"toUserCenter"]) {
        
        CSTUserCenterViewController *userCenterVC = segue.destinationViewController;
        userCenterVC.transitionType = VVBlurTransitionTypeTypeLeftToRight;
    }else{
    
        [super prepareForSegue:segue sender:sender];
    }
}

#pragma mark - Runtime

- (id)forwardingTargetForSelector:(SEL)aSelector{

    
    if ([NSStringFromSelector(aSelector) isEqualToString:@"reAnimateSubviews"]) {
        
        return self.leftViewController;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - Event Response

- (void)p_configEventWithLeftButton:(UIButton *)button{

    @weakify(self);
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        [self performSegueWithIdentifier:@"toUserCenter" sender:nil];
        
    }];
}


- (void)p_configEventWithRightButton:(UIButton *)button{
    
    @weakify(self);
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        CSTDetailDataViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"CSTDetailDataViewController"];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }];
}

- (void)p_configEventWithSegment:(UISegmentedControl *)segment{

    
    @weakify(self);
    [[segment rac_newSelectedSegmentIndexChannelWithNilValue:nil]subscribeNext:^(id x) {
        @strongify(self);
        
        if ([x integerValue] == 0) {
            
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            
        }else if ([x integerValue] == 1){
        
            [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds), 0) animated:NO];
        }
    }];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x  >= CGRectGetWidth(self.view.bounds)) {
        
        self.navigationItem.rightBarButtonItem = nil;
        self. titleSegment.selectedSegmentIndex = 1;
        
    }else if(scrollView.contentOffset.x == 0){
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
        self. titleSegment.selectedSegmentIndex = 0;
    }
}

#pragma mark - Public method

- (void)resetOffset{

    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)showRightViewController{

    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds), 0) animated:NO];
}

- (BOOL)isShowRightViewController{

    if (self.scrollView.contentOffset.x == CGRectGetWidth(self.view.bounds)) {
        
        return YES;
    }
    
    return NO;
}

- (void)refreshCurrentPageData{
    
    [self.viewModel refreshCurrentPageData];
}

#pragma mark - Private method

- (void)p_configNavigationBar{

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    
    self.navigationItem.titleView = self.titleSegment;

}

- (void)p_configConstraints{

    [self.leftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.willBindMateViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mateContentViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:self.constraints];
}

- (NSArray *)p_constraints{

    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.leftViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.leftViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.leftViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.leftViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    
    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:self.willBindMateViewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:self.willBindMateViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:self.willBindMateViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:self.willBindMateViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:self.willBindMateViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.leftViewController.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:self.willBindMateViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:self.willBindMateViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:self.mateContentViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.willBindMateViewController.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *constraint13 = [NSLayoutConstraint constraintWithItem:self.mateContentViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.willBindMateViewController.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *constraint14 = [NSLayoutConstraint constraintWithItem:self.mateContentViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.willBindMateViewController.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *constraint15 = [NSLayoutConstraint constraintWithItem:self.mateContentViewController.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.willBindMateViewController.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    
   return @[constraint1,constraint2,constraint3,constraint4,constraint5,constraint6,constraint7,constraint8,constraint9,constraint10,constraint11,constraint12,constraint13,constraint14,constraint15];
}

- (void)p_configScrollView{
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    //self.scrollView.scrollEnabled = NO;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
}


- (void)p_configLeftViewController{
    
    [self addChildViewController:self.leftViewController];
    [self.scrollView addSubview:self.leftViewController.view];
}

- (void)p_configWillBindMateViewController{

    [self addChildViewController:self.willBindMateViewController];
    [self.scrollView addSubview:self.willBindMateViewController.view];
}

- (void)p_configMateContentViewController{

    [self addChildViewController:self.mateContentViewController];
    [self.scrollView addSubview:self.mateContentViewController.view];
};


- (void)p_configRightViewController{
    
    
    @weakify(self);
    [RACObserve(self.viewModel, hasMate) subscribeNext:^(id x) {
        @strongify(self);
        
        self.willBindMateViewController.view.hidden = [x boolValue];
        self.mateContentViewController.view.hidden = ![x boolValue];
    }];
}


- (void)p_configImageWithButton:(UIButton *)button{

    [[RACObserve(self.viewModel, avatarImage) ignore:nil] subscribeNext:^(id x) {
        
        [button setImage:x forState: UIControlStateNormal];
    }];

}

#pragma mark -Setters and getters


- (UIButton *)leftButton{
    
    if (!_leftButton) {
        
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.bounds =  (CGRect){
            .origin.x = 0.0,
            .origin.y = 0.0,
            .size.width =  32.0,
            .size.height = 32.0,
        };
        _leftButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _leftButton.layer.borderWidth = 1.0;
        _leftButton.layer.cornerRadius = 16.0;
        _leftButton.layer.masksToBounds = YES;
        [_leftButton setImage:[UIImage imageNamed:@"AvatarIcon"] forState:UIControlStateNormal];
        
        [self p_configImageWithButton:_leftButton];
        
        [self p_configEventWithLeftButton:_leftButton];
    }

    return _leftButton;
}


- (UIButton *)rightButton{

    if (!_rightButton) {
        
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.bounds =  (CGRect){
            .origin.x = 0.0,
            .origin.y = 0.0,
            .size.width =  32.0,
            .size.height = 32.0,
        };
        _rightButton.layer.cornerRadius = 16.0;
        _rightButton.layer.masksToBounds = YES;
        [_rightButton setImage:[UIImage imageNamed:@"DetailIcon"] forState:UIControlStateNormal];
        
        [self p_configEventWithRightButton:_rightButton];

    }
    return _rightButton;
}


- (UISegmentedControl *)titleSegment{

    if (!_titleSegment) {
        
        _titleSegment = [[UISegmentedControl alloc] initWithItems:@[@"我的饮水",@"我的伴侣"]];
        
        _titleSegment.selectedSegmentIndex = 0;
        _titleSegment.tintColor = [UIColor whiteColor];
        _titleSegment.layer.cornerRadius = 15.0;
        _titleSegment.layer.masksToBounds = YES;
        _titleSegment.layer.borderColor = [UIColor whiteColor].CGColor;
        _titleSegment.layer.borderWidth = 1.0;
        [self p_configEventWithSegment:_titleSegment];
        
    }
    return _titleSegment;
}

- (UIViewController *)leftViewController{

    if (!_leftViewController) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        _leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"CSTMainContentViewController"];
        
        ((CSTMainContentViewController *)_leftViewController).viewModel = self.viewModel.userContentViewModel;
    }
    
    return _leftViewController;
}

- (UIViewController *)mateContentViewController{

    if (!_mateContentViewController) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        _mateContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"CSTMainContentViewController"];
        ((CSTMainContentViewController *)_mateContentViewController).viewModel = self.viewModel.mateContentViewModel;
    }
    
    return _mateContentViewController;

}

- (UIViewController *)willBindMateViewController{

    if (!_willBindMateViewController) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        _willBindMateViewController = [storyboard instantiateViewControllerWithIdentifier:@"CSTWillBindMateViewController"];
    }
    
    return _willBindMateViewController;

}

- (UITapGestureRecognizer *)tap{
    
    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] init];
        
        @weakify(self);
        
        [[_tap rac_gestureSignal]subscribeNext:^(id x) {
            
            @strongify(self);
            
            [((CSTMainContentViewController *)self.leftViewController) reAnimateSubviews];
        }];
    }
    
    return _tap;
}


- (CSTMainDataViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTMainDataViewModel alloc] init];
    }
    
    return _viewModel;
}


- (NSArray *)constraints{

    if (!_constraints) {
        
        _constraints = [self p_constraints];
    }
    return _constraints;

}


@end
