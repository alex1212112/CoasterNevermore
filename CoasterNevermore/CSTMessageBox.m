//
//  CSTMessageBox.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMessageBox.h"
#import "Colours.h"


@interface CSTMessageBox ()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIVisualEffectView *shaderView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIBlurEffect *blurEffect;

@end

@implementation CSTMessageBox

@synthesize content = _content;

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        [self p_configSubViews];
        self.backgroundColor = [UIColor colorFromHexString:@"efefef"];
        [self addNotifications];
    }
    return self;
}


#pragma mark - Public method
+ (instancetype)showInView:(UIView *)view
{
    CSTMessageBox *messageBox = [[CSTMessageBox alloc] init];
    [messageBox showInView:view];
    return  messageBox;
}

+ (void)hideInview:(UIView *)view
{
    for (UIView * subView in view.subviews)
    {
        if ([subView isKindOfClass:[CSTMessageBox class]])
        {
            [((CSTMessageBox*)subView) hideInView:view];
            return;
        }
    }
}


- (void)showInView:(UIView *)view
{
    [self setHidden:NO];
    
    [view addSubview:self.shaderView];
    
    self.shaderView.bounds = view.bounds;
    self.shaderView.center = view.center;
    [self.shaderView.contentView addSubview:self];
    
//    self.shaderView.alpha = 0.0;
    
    self.bounds =  CGRectMake(0.0, 0.0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds) * 180.0 / 568.0);
    
    self.center = CGPointMake(CGRectGetWidth(view.bounds) / 2, CGRectGetHeight(view.bounds) + CGRectGetHeight(self.bounds) / 2 );
    
    [self.textView becomeFirstResponder];
    
}

- (void)hideInView:(UIView *)view
{
    
    [self setHidden:YES];
    [self removeFromSuperview];
    [self.shaderView removeFromSuperview];
}



#pragma mark - Private method

- (void)p_configSubViews{
    
    [self addSubview:self.cancelButton];
    [self addSubview:self.doneButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.textView];
    
    [self p_configLayoutConstraints];


}

- (void)p_configLayoutConstraints{
    
    [self p_configCancelButtonLayout];
    [self p_configDoneButtonLayout];
    [self p_configTitleLabelLayout];
    [self p_configTextViewLayout];
}

- (void)p_configCancelButtonLayout{
    
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cancelButton);
    
    NSString *vflv = @"V:|-0-[_cancelButton(50)]";
    NSString *vflh = @"H:|-0-[_cancelButton(50)]";
    
    NSArray *vflvs = [NSLayoutConstraint constraintsWithVisualFormat:vflv options:0 metrics:nil views:viewDictionary];
    
    NSArray *vflhs = [NSLayoutConstraint constraintsWithVisualFormat:vflh options:0 metrics:nil views:viewDictionary];
    
    [NSLayoutConstraint activateConstraints:vflvs];
    [NSLayoutConstraint activateConstraints:vflhs];
    
}

- (void)p_configDoneButtonLayout{
    
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_doneButton);
    
    NSString *vflv = @"V:|-0-[_doneButton(50)]";
    NSString *vflh = @"H:[_doneButton(50)]-0-|";
    
    NSArray *vflvs = [NSLayoutConstraint constraintsWithVisualFormat:vflv options:0 metrics:nil views:viewDictionary];
    
    NSArray *vflhs = [NSLayoutConstraint constraintsWithVisualFormat:vflh options:0 metrics:nil views:viewDictionary];
    
    [NSLayoutConstraint activateConstraints:vflvs];
    [NSLayoutConstraint activateConstraints:vflhs];
    
}

- (void)p_configTitleLabelLayout{

    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintcenterY = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.cancelButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    

    [NSLayoutConstraint activateConstraints:@[constraintcenterY, constraintCenterX]];
    
}

- (void)p_configTextViewLayout{
    
    
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:16.0];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0];
    
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:16.0];
    
    NSLayoutConstraint *constrainRight = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-16.0];
    
    
    [NSLayoutConstraint activateConstraints:@[constraintTop, constraintBottom, constraintLeft, constrainRight]];
    
}


#pragma mark - observer keyboard
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    keyboardFrame = [self convertRect:keyboardFrame toView:nil];
    
    double keyboardHeight = keyboardFrame.size.height;
    double animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    if (animationDuration == 0)
    {
        self.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.superview.frame) - keyboardHeight - CGRectGetMidY(self.bounds));
        self.shaderView.effect = self.blurEffect;
    }
    else
    {
        [UIView animateWithDuration:animationDuration
                              delay:0.0f
                            options:animationOptionsWithCurve(animationCurve)
                         animations:^{
                             
                             if (!self.hidden)
                             {
                                 self.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.superview.frame) - keyboardHeight - CGRectGetMidY(self.bounds));
                                 self.shaderView.effect = self.blurEffect;
                                 
                             }
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             NSLog(@"animated == %@",self.description);
                         }];
    }
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    keyboardFrame = [self convertRect:keyboardFrame toView:nil];
    
    double animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:animationOptionsWithCurve(animationCurve)
                     animations:^{
                         
                         self.center =  CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.superview.frame) + CGRectGetHeight(self.frame) / 2 );
                         self.shaderView.effect = nil;
                     }
                     completion:^(BOOL finished){
                         
                         [self hideInView:self.superview];
                     }];
    
}



static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve)
{
    UIViewAnimationOptions opt = (UIViewAnimationOptions)curve;
    return opt << 16;
}


- (void)dealloc
{
    [self removeNotifications];
}


#pragma mark - Event response
- (void)p_tap:(UITapGestureRecognizer *)tap{

    [self.textView resignFirstResponder];

}

- (void)p_cancelButtonClicked:(UIButton *)sender{

     [self.textView resignFirstResponder];
}

- (void)p_doneButtonClicked:(UIButton *)sender{
    
     [self.textView resignFirstResponder];
    
    if (self.doneBlock) {
        
        self.doneBlock();
    }
}


#pragma mark - Setters and getters

- (UIButton *)cancelButton{

    if (!_cancelButton) {
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(p_cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelButton;
}

- (UIButton *)doneButton{
    
    if (!_doneButton) {
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_doneButton setTitle:@"发送" forState:UIControlStateNormal];

        [_doneButton addTarget:self action:@selector(p_doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _doneButton;
}

- (UITextView *)textView{

    if (!_textView) {
        
        _textView = [[UITextView  alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:17.0f];
    }
    return _textView;
}

- (UIVisualEffectView *)shaderView{

    if (!_shaderView) {
        
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        
        _shaderView = [[UIVisualEffectView alloc] initWithEffect:nil];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tap:)];
        [_shaderView addGestureRecognizer:tap];
    }
    
    return _shaderView;
}

- (UIBlurEffect *)blurEffect {

    if (!_blurEffect) {
        _blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    return _blurEffect;
}

- (UILabel *)titleLabel{

    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (void)setTitle:(NSString *)title{
    
    _title = [title copy];
    _titleLabel.text = _title;
}

- (void)setContent:(NSString *)content{

    _content = [content copy];
    _textView.text = _content;
}

- (NSString *)content{

    return self.textView.text;
}



@end
