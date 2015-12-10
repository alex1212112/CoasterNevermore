//
//  CSTShowContentView.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/11/4.
//  Copyright © 2015年 Ren guohua. All rights reserved.
//

#import "CSTShowContentView.h"
#import "Colours.h"
#define kAlertWidth 270.0f
#define kAlertHeight 300.0f

@interface CSTShowContentView ()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *backImageView;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation CSTShowContentView

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorFromHexString:@"ffaf5e"];
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

- (UIViewController *)p_appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


- (void)p_configSubViews{

    [self addSubview:self.closeButton];
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.cancelButton];
    [self p_configLayoutConstraints];

}

- (void)p_configLayoutConstraints{
    
    [self p_configCloseButtonLayout];
    [self p_configImageViewLayout];
    [self p_configTitleLabelLayout];
    [self p_configContentLabelLayout];
    [self p_configCancelButtonLayout];
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


- (void)p_configImageViewLayout{

    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:45.0];
    
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0.0];
    
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:37.0 / 44.0 constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintTop,constraintWidth,constraintHeight]];
}

- (void)p_configTitleLabelLayout{

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:15.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintCenterX,constraintTop]];

}

- (void)p_configContentLabelLayout{
    
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
//    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
//    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:15.0];
    
    
    NSLayoutConstraint *constraintLeading = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintTrailing = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintTop,constraintLeading,constraintTrailing]];
    
}

- (void)p_configCancelButtonLayout{
    
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44.0];
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[constraintHeight,constraintWidth,constraintCenterX,constraintBottom]];
    
}

#pragma mark - Event response

- (void)p_closeButtonClicked:(id)sender{

    [self dismiss];
}

- (void)p_tap:(UITapGestureRecognizer *)tap{

    [self dismiss];
}


#pragma mark - Setters and getters

- (UIButton *)closeButton{
    
    if (!_closeButton) {
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _closeButton.tintColor = [UIColor whiteColor];
        [_closeButton setImage:[UIImage imageNamed:@"Xicon"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(p_closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}


- (UIImageView *)imageView{

    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] init];
    }
    
    return _imageView;
}

- (UILabel *)titleLabel{

    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)contentLabel{

    if (!_contentLabel) {
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13.0];
        _contentLabel.textColor = [UIColor colorFromHexString:@"ffedde"];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.numberOfLines = 0;
        _contentLabel.preferredMaxLayoutWidth = kAlertWidth - 16.0 * 2;
        
    }
    
    return _contentLabel;
}

- (UIButton *)cancelButton{

    if (!_cancelButton) {
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_cancelButton setTitle:@"确定" forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor colorFromHexString:@"e89746"];
        [_cancelButton addTarget:self action:@selector(p_closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelButton;
}
- (UITapGestureRecognizer *)tap{
    
    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tap:)];
    }
    
    return _tap;
}

- (void)setTitle:(NSString *)title{
    
    _title = [title copy];
    
    self.titleLabel.text = title;
    
}

- (void)setContent:(NSString *)content{
    
    _content = [content copy];
    self.contentLabel.text = content;
}

- (void)setImage:(UIImage *)image{

    if (_image != image) {
        
        _image = image;
        
        self.imageView.image = _image;
    }
}

- (void)setCancelTitle:(NSString *)cancelTitle{

    _cancelTitle = [cancelTitle copy];
    
    [self.cancelButton setTitle:_title forState:UIControlStateNormal];
}


@end
