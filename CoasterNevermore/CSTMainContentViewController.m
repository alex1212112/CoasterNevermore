//
//  CSTMainContentViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/29.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMainContentViewController.h"
#import "CSTMainContentViewModel.h"
#import "CSTCircleProgressView.h"
#import "Colours.h"
#import "CSTWeatherView.h"
#import "CSTWeatherManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CSTMainContentViewController ()
@property (weak, nonatomic) IBOutlet CSTCircleProgressView *circleProgressView;
@property (weak, nonatomic) IBOutlet UILabel *todayDrinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *bleStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bleStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *suggestLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *suggestDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressDataLabel;
@property (weak, nonatomic) IBOutlet UIButton *suggestDetailButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *suggestDataLabelConstraintCenterX;
@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;
@property (weak, nonatomic) IBOutlet UIButton *messageCancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewConstraintHeight;


@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *middleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (weak, nonatomic) IBOutlet UILabel *topDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleViewConstraintTop;
@property (weak, nonatomic) IBOutlet UIView *whiteBgView;

@property (strong, nonatomic) NSLayoutConstraint *topViewConstraintLongHeight;
@property (strong, nonatomic) NSLayoutConstraint *middleViewConstraintLongHeight;
@property (strong, nonatomic) NSLayoutConstraint *bottomViewConstraintLongHeight;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;



@end

@implementation CSTMainContentViewController

#pragma mark - Life circle


- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configBackgroundColor];
    [self p_configSubViews];
    [self p_configConstraints];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    [self p_refreshCurrentPageData];
    [self showMessageView];
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
}


#pragma mark - Event response

- (void)p_configEventWithMessageCancelButton{

    
    @weakify(self);
    [[self.messageCancelButton  rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self hideMessageView];
    }];
}


#pragma mark - Publick method


- (void)reAnimateSubviews{

    [self.circleProgressView setProgress:self.viewModel.circleProgress animated:YES];
}

- (void)showMessageView{

    self.messageViewConstraintHeight.constant = 45;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideMessageView{

    self.messageViewConstraintHeight.constant = 0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Private method


- (void)p_configSubViews{

    [self p_configCicleProgressView];
    [self p_configTodayDrinkLabel];
    [self p_configBLEStateLabel];
    [self p_confiBLEStateImageView];
    [self p_configSuggestLabel];
    [self p_configSuggestDataLabel];
    [self p_configRemainLabel];
    [self p_configRemainDataLabel];
    [self p_configProgressLabel];
    [self p_configProgressDataLabel];
    [self p_configSuggestDetailButton];
    [self p_configTopView];
    [self p_configMiddleView];
    [self p_configBottomView];
    [self p_configNameLabel];
    [self p_configMessageView];
    [self p_configWhiteBgView];
}

- (void)p_configConstraints{

    [self p_configSuggestDataLabelConstraint];
    [self p_configcircleViewConstraint];
}

- (void)p_configCicleProgressView{
    
    self.circleProgressView.progressTintColor = [UIColor whiteColor];
    self.circleProgressView.roundedCorners = 1;
    self.circleProgressView.trackTintColor = self.viewModel.trackTintColor;
    self.circleProgressView.thicknessRatio = self.viewModel.thicknessRatio;
    
    RAC(self.circleProgressView, progress) = RACObserve(self.viewModel, circleProgress);
}

- (void)p_configBackgroundColor{
    
      self.view.backgroundColor = self.viewModel.contentType == CSTContentTypeUser ? [UIColor colorFromHexString:@"88d6ff"] : [UIColor colorFromHexString:@"ffbc73"];
}


- (void)p_configTodayDrinkLabel{

    RAC(self.todayDrinkLabel,attributedText) = RACObserve(self.viewModel, todayDrinkWaterString);
}


- (void)p_configBLEStateLabel{

    self.bleStateLabel.hidden = self.viewModel.contentType != CSTContentTypeUser;
    
    RAC(self.bleStateLabel,text) = RACObserve(self.viewModel, bleStateString);
}

- (void)p_confiBLEStateImageView{

    
    self.bleStateImageView.layer.cornerRadius =  5.0f;
    self.bleStateImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.bleStateImageView.layer.borderWidth = 1.0f;
    //self.bleStateImageView.backgroundColor = [UIColor redColor];
    
    self.bleStateImageView.hidden = self.viewModel.contentType != CSTContentTypeUser;
    
    RAC(self.bleStateImageView,backgroundColor) = RACObserve(self.viewModel, bleStateColor);
}

- (void)p_configSuggestLabel{

    self.suggestLabel.textColor = self.viewModel.contentType == CSTContentTypeUser ? [UIColor colorFromHexString:@"2da0dc"] : [UIColor colorFromHexString:@"dd903d"];
}
- (void)p_configSuggestDataLabel{
    
    self.suggestDataLabel.textColor = [UIColor whiteColor];
    RAC(self.suggestDataLabel,text) = RACObserve(self.viewModel, suggestWater);
}

- (void)p_configRemainLabel{

    self.remainLabel.textColor = self.viewModel.contentType == CSTContentTypeUser ? [UIColor colorFromHexString:@"2da0dc"] : [UIColor colorFromHexString:@"dd903d"];
}

- (void)p_configRemainDataLabel{

    self.remainDataLabel.textColor = [UIColor whiteColor];
    RAC(self.remainDataLabel,text) = RACObserve(self.viewModel, remainWater);
}

- (void)p_configProgressLabel{

    self.progressLabel.textColor = self.viewModel.contentType == CSTContentTypeUser ? [UIColor colorFromHexString:@"2da0dc"] : [UIColor colorFromHexString:@"dd903d"];
}

- (void)p_configProgressDataLabel{
    
    self.progressDataLabel.textColor = [UIColor whiteColor];
    RAC(self.progressDataLabel,text) = RACObserve(self.viewModel, progress);
}

- (void)p_configSuggestDetailButton{

    self.suggestDetailButton.hidden = self.viewModel.contentType != CSTContentTypeUser;
    [[self.suggestDetailButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [[CSTWeatherManager shareManager] findCurrentLocation];
        
        CSTWeatherView *weatherView = [[CSTWeatherView alloc] init];
        
        RAC(weatherView, addressText) = [RACObserve(self.viewModel, address) ignore:nil];
        RAC(weatherView, weatherDescription) = [RACObserve(self.viewModel, weatherDescrithion) ignore:nil];
        RAC(weatherView, tempratureText) = [RACObserve(self.viewModel, tempratureText) ignore:nil];
        RAC(weatherView, humidityText) = [RACObserve(self.viewModel, humidityText) ignore:nil];
        RAC(weatherView, weatherIconImage) = [RACObserve(self.viewModel, weatherIcon) ignore:nil];
        RAC(weatherView, aqiText) = RACObserve(self.viewModel, aqiText);
        
        [weatherView show];
    }];
}

- (void)p_configSuggestDataLabelConstraint{

    if (self.viewModel.contentType == CSTContentTypeUser) {
        
        self.suggestDataLabelConstraintCenterX.constant = -8.0;
    }else{
        self.suggestDataLabelConstraintCenterX.constant = 0.0;
    }
}

- (void)p_configcircleViewConstraint{
    
    CGFloat navigationBarHeight = CGRectGetHeight(self.parentViewController.navigationController.navigationBar.bounds);
    self.circleViewConstraintTop.constant = navigationBarHeight + 20.0;
}

- (void)p_configTopView{

    self.topView.backgroundColor = [UIColor clearColor];
    self.topLabel.text = self.viewModel.topTitle;
    self.topImageView.image = self.viewModel.topImage;
    
    RAC(self.topDetailLabel,text) = RACObserve(self.viewModel,topDetail);
}

- (void)p_configMiddleView{
    
    self.middleView.backgroundColor = [UIColor clearColor];
    self.middleLabel.text = self.viewModel.middleTitle;
    self.middleImageView.image = self.viewModel.middleImage;
    RAC(self.middleDetailLabel,text) = RACObserve(self.viewModel,middleDetail);
}

- (void)p_configBottomView{
    
    self.bottomView.backgroundColor = [UIColor clearColor];
    self.bottomLabel.text = self.viewModel.bottomTitle;
    self.bottomImageView.image = self.viewModel.bottomImage;
    RAC(self.bottomDetailLabel,text) = RACObserve(self.viewModel,bottomDetail);
}

- (void)p_configNameLabel{

    self.nameLabel.hidden = self.viewModel.contentType == CSTContentTypeUser;
    
    RAC(self,nameLabel.text) = RACObserve(self, viewModel.nickname);
}

- (void)p_configMessageView{

    self.messageView.clipsToBounds = YES;
    
    RAC(self, messageLabel.text) = RACObserve(self.viewModel, remindMessage);
    
    [self p_configEventWithMessageCancelButton];
    
    if (self.viewModel.contentType == CSTContentTypeUser) {
        
        self.sendMessageButton.hidden = YES;
    }
    
    self.sendMessageButton.layer.borderWidth = 1.0f;
    self.sendMessageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.sendMessageButton.layer.cornerRadius = 5.0f;
    
    @weakify(self);
    self.sendMessageButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        self.sendMessageButton.hidden = YES;
        self.indicatorView.center = CGPointMake(CGRectGetMaxX(self.sendMessageButton.frame), CGRectGetMidY(self.messageView.bounds));
        [self.indicatorView startAnimating];
        
        [self.messageView addSubview:self.indicatorView];
        
        return [[[self.viewModel sendeMessageToMateSignal] doNext:^(id x) {
            
            [self.indicatorView stopAnimating];
            [self.indicatorView removeFromSuperview];
            self.sendMessageButton.hidden = NO;
        }] doError:^(NSError *error) {
            [self.indicatorView stopAnimating];
            [self.indicatorView removeFromSuperview];
            self.sendMessageButton.hidden = NO;
        }];
    }];
    
}

- (void)p_configWhiteBgView{

    self.whiteBgView.backgroundColor = [UIColor whiteColor];
}


- (void)p_refreshCurrentPageData{

    [self.viewModel refresCurrentPageData];
}

#pragma mark -Setters and getters

- (CSTMainContentViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTMainContentViewModel alloc] init];
    }
    return _viewModel;
}

- (NSLayoutConstraint *)topViewConstraintLongHeight{

    if (!_topViewConstraintLongHeight) {
        
        _topViewConstraintLongHeight = [NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.whiteBgView attribute:NSLayoutAttributeHeight multiplier:1.0 / 3.0 constant:0.0];
    }
    
    return _topViewConstraintLongHeight;
}

- (NSLayoutConstraint *)middleViewConstraintLongHeight{

    if (!_middleViewConstraintLongHeight) {
        
        _middleViewConstraintLongHeight = [NSLayoutConstraint constraintWithItem:self.middleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.whiteBgView attribute:NSLayoutAttributeHeight multiplier:1.0 / 3.0 constant:0.0];
    }
    
    return _middleViewConstraintLongHeight;
}


- (NSLayoutConstraint *)bottomViewConstraintLongHeight{
    
    if (!_bottomViewConstraintLongHeight) {
        
        _bottomViewConstraintLongHeight = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.whiteBgView attribute:NSLayoutAttributeHeight multiplier:1.0 / 3.0 constant:0.0];
    }
    return _bottomViewConstraintLongHeight;
}


- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    return _indicatorView;
}

@end
