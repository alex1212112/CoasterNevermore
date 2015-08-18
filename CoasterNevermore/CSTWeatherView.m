//
//  CSTWeatherView.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTWeatherView.h"
#import "Colours.h"

#define kAlertWidth 270.0f
#define kAlertHeight 300.0f

@interface CSTWeatherView ()

@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *weatherIcon;
@property (nonatomic, strong) UILabel *weatherDescriptionLabel;
@property (nonatomic, strong) UIImageView *tempratureIcon;
@property (nonatomic, strong) UILabel *tempratureLabel;
@property (nonatomic, strong) UILabel *humidityDataLabel;
@property (nonatomic, strong) UILabel *humidityLabel;
@property (nonatomic, strong) UILabel *aqiDataLabel;
@property (nonatomic, strong) UILabel *aqiLabel;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *backImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation CSTWeatherView


#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        [self p_configSubViews];
    }
    return self;
}




- (void)removeFromSuperview
{
    
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
    
    [UIView animateWithDuration:0.10f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25f delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            if (self.superview) {
                [super removeFromSuperview];
            }
        }];
    }];
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    UIViewController *topVC = [self p_appRootViewController];
    
    if (!self.backImageView) {
        self.backImageView = [[UIView alloc] initWithFrame:topVC.view.bounds];
        self.backImageView.backgroundColor = [UIColor blackColor];
        self.backImageView.alpha = 0.6f;
        self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backImageView.userInteractionEnabled = YES;
        [self.backImageView addGestureRecognizer:self.tap];
        
    }
    [topVC.view addSubview:self.backImageView];
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);

    [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        
    
    }];
    
    [super willMoveToSuperview:newSuperview];
}


#pragma mark - Public method

- (void)show{
    UIViewController *topVC = [self p_appRootViewController];
    self.frame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
    [topVC.view addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}


#pragma mark - Private method

- (void)p_tap:(UITapGestureRecognizer *)tap{

    [self dismiss];
}

- (UIViewController *)p_appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)p_closeButtonClicked:(UIButton *)sender{

    [self dismiss];
}


- (void)p_configSubViews{
    
    [self addSubview:self.addressLabel];
    [self addSubview:self.closeButton];
    [self addSubview:self.weatherIcon];
    [self addSubview:self.weatherDescriptionLabel];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.lineView];
    [self.bottomView addSubview:self.humidityDataLabel];
    [self.bottomView addSubview:self.humidityLabel];
    [self.bottomView addSubview:self.aqiDataLabel];
    [self.bottomView addSubview:self.aqiLabel];
    [self addSubview:self.tempratureLabel];
    [self addSubview:self.tempratureIcon];
    

    [self p_configLayoutConstraints];
}

- (void)p_configLayoutConstraints{
    [self p_configAddressLabelLayout];
    [self p_configCloseButtonLayout];
    [self p_configWeatherIconLayout];
    [self p_configWeatherDescriptionLabelLayout];
    [self p_configBottomViewLayout];
    [self p_configLineViewLayout];
    [self p_configHumidityDataLabelLayout];
    [self p_configHumidityLabelLayout];
    [self p_configAQIDataLabelLayout];
    [self p_configAQILabelLayout];
    [self p_configTempratureLabelLayout];
    [self p_configtempratureIconLayout];
}

- (void)p_configAddressLabelLayout{

    self.addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_addressLabel);
    
    NSString *vfv = @"V:|-[_addressLabel]";
    NSString *vfh = @"H:|-[_addressLabel]";
    
    
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:vfv options:0 metrics:nil views:viewsDictionary];
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:vfh options:0 metrics:nil views:viewsDictionary];
    [NSLayoutConstraint activateConstraints:constraintsV];
    [NSLayoutConstraint activateConstraints:constraintsH];
}

- (void)p_configCloseButtonLayout{
    
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_closeButton);
    
    NSString *vfv = @"V:|-[_closeButton]";
    NSString *vfh = @"H:[_closeButton]-|";
    
    
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:vfv options:0 metrics:nil views:viewsDictionary];
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:vfh options:0 metrics:nil views:viewsDictionary];
    [NSLayoutConstraint activateConstraints:constraintsV];
    [NSLayoutConstraint activateConstraints:constraintsH];
}

- (void)p_configWeatherIconLayout{
   
    self.weatherIcon.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.weatherIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:self.weatherIcon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:45.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintTop]];
}

- (void)p_configWeatherDescriptionLabelLayout{

    self.weatherDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.weatherDescriptionLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:self.weatherDescriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.weatherIcon attribute:NSLayoutAttributeBottom multiplier:1.0 constant:15.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintTop]];
}


- (void)p_configBottomViewLayout{

    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.3 constant:0.0];
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
     [NSLayoutConstraint activateConstraints:@[constraintHeight,constraintWidth,constraintCenterX,constraintBottom]];
}


- (void)p_configLineViewLayout{
    
    self.lineView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeHeight multiplier:(2.0 / 3.0) constant:0.0];
    
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0];
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintHeight,constraintWidth,constraintCenterX,constraintCenterY]];
}

- (void)p_configHumidityDataLabelLayout{

    self.humidityDataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.humidityDataLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterX multiplier:(1.0 / 2.0) constant:0.0];
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:self.humidityDataLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterY multiplier:(1.5 / 2.0) constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintCenterY]];

}

- (void)p_configHumidityLabelLayout{
    
    self.humidityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.humidityLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterX multiplier:(1.0 / 2.0) constant:0.0];
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:self.humidityLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterY multiplier:(3.0 / 2.0) constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintCenterY]];
}

- (void)p_configAQIDataLabelLayout{
    
    self.aqiDataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.aqiDataLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterX multiplier:(3.0 / 2.0) constant:0.0];
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:self.aqiDataLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterY multiplier:(1.5 / 2.0) constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintCenterY]];
}

- (void)p_configAQILabelLayout{
    
    self.aqiLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.aqiLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterX multiplier:(3.0 / 2.0) constant:0.0];
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:self.aqiLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterY multiplier:(3.0 / 2.0) constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintCenterY]];
}

- (void)p_configTempratureLabelLayout{

    self.tempratureLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:self.tempratureLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.tempratureLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0];
    
    
    [NSLayoutConstraint activateConstraints:@[constraintRight,constraintBottom]];
}

- (void)p_configtempratureIconLayout{

    self.tempratureIcon.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:self.tempratureIcon attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.tempratureLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-7.0];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.tempratureIcon attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintRight,constraintBottom]];
}



#pragma mark - Setters and getters

- (UILabel *)addressLabel{
    if(!_addressLabel){
    
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.text = @"北京";
        _addressLabel.font = [UIFont systemFontOfSize:13.0];
        _addressLabel.textColor = [UIColor colorFromHexString:@"666666"];
    }
    return _addressLabel;
}

- (UIButton *)closeButton{

    if (!_closeButton) {
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"CloseIcon"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(p_closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

- (UIImageView *)weatherIcon {
    if (!_weatherIcon) {
        
        _weatherIcon = [[UIImageView alloc] init];
        _weatherIcon.image = [UIImage imageNamed:@"weather-clear"];
    }
    
    return _weatherIcon;
}


- (UIImageView *)tempratureIcon{

    if (!_tempratureIcon) {
        
        _tempratureIcon = [[UIImageView alloc] init];
        _tempratureIcon.image = [UIImage imageNamed:@"TempratureIcon"];
        
    }
    
    return _tempratureIcon;
}

- (UILabel *)weatherDescriptionLabel{

    if (!_weatherDescriptionLabel) {
        
        _weatherDescriptionLabel = [[UILabel alloc] init];
        _weatherDescriptionLabel.text = @"晴";
        _weatherDescriptionLabel.font = [UIFont systemFontOfSize:13.0];
        _weatherDescriptionLabel.textColor = [UIColor colorFromHexString:@"666666"];
        
    }
    return _weatherDescriptionLabel;
}

- (UILabel *)tempratureLabel{

    if (!_tempratureLabel) {
        
        _tempratureLabel = [[UILabel alloc] init];
        _tempratureLabel.text = @"温度 : 23℃";
        _tempratureLabel.font = [UIFont systemFontOfSize:13.0];
        _tempratureLabel.textColor = [UIColor colorFromHexString:@"666666"];
        
    }
    return _tempratureLabel;
}

- (UILabel *)humidityDataLabel{

    if (!_humidityDataLabel) {
        
        _humidityDataLabel = [[UILabel alloc] init];
        _humidityDataLabel.text = @"40%";
        _humidityDataLabel.font = [UIFont systemFontOfSize:33.0];
        _humidityDataLabel.textColor = [UIColor colorFromHexString:@"666666"];
    }
    
    return _humidityDataLabel;
}

- (UILabel *)humidityLabel{

    if (!_humidityLabel) {
        
        _humidityLabel = [[UILabel alloc] init];
        _humidityLabel.text = @"空气湿度";
        _humidityLabel.font = [UIFont systemFontOfSize:13.0];
        _humidityLabel.textColor = [UIColor colorFromHexString:@"999999"];
    }
    return _humidityLabel;
}

- (UILabel *)aqiDataLabel{

    if (!_aqiDataLabel) {
        
        _aqiDataLabel = [[UILabel alloc] init];
        _aqiDataLabel.text = @"良";
        _aqiDataLabel.font = [UIFont systemFontOfSize:33.0];
        _aqiDataLabel.textColor = [UIColor colorFromHexString:@"666666"];
    }
    
    return _aqiDataLabel;
}

- (UILabel *)aqiLabel{
    if (!_aqiLabel) {
        
        _aqiLabel = [[UILabel alloc] init];
        _aqiLabel.text = @"空气质量";
        _aqiLabel.font = [UIFont systemFontOfSize:13.0];
        _aqiLabel.textColor = [UIColor colorFromHexString:@"999999"];
    }
    
    return _aqiLabel;
}

- (UIView *)bottomView {

    if (!_bottomView) {
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorFromHexString:@"f4f4f4"];
    }
    
    return _bottomView;
}

- (UIView *)lineView{
    if (!_lineView) {
        
        _lineView =[[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromHexString:@"dfdfdf"];
    }
    
    return _lineView;
}


- (void)setAddressText:(NSString *)addressText{

    _addressText = [addressText copy];
    self.addressLabel.text = _addressText;
}

- (void)setWeatherDescription:(NSString *)weatherDescription{

    _weatherDescription = [weatherDescription copy];
    self.weatherDescriptionLabel.text =  _weatherDescription;
}

- (void)setTempratureText:(NSString *)tempratureText{

    _tempratureText = [tempratureText copy];
    self.tempratureLabel.text = _tempratureText;
}

- (void)setHumidityText:(NSString *)humidityText{

    _humidityText = [humidityText copy];
    self.humidityDataLabel.text = _humidityText;
}

- (void)setAqiText:(NSString *)aqiText{
    _aqiText = [aqiText copy];
    self.aqiDataLabel.text = _aqiText;
}

- (void)setWeatherIconImage:(UIImage *)weatherIconImage{

    if (_weatherIconImage != weatherIconImage) {
        
        _weatherIconImage = weatherIconImage;
        
        self.weatherIcon.image = _weatherIconImage;
    }
}


- (UITapGestureRecognizer *)tap{

    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tap:)];
    }
    
    return _tap;
}

@end
