//
//  CSTUserAccessViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserAccessViewController.h"
#import "Colours.h"
#import <ReactiveCocoa.h>
#import <RACEXTScope.h>
#import "UIViewController+CSTDismissKeyboard.h"
#import "CSTValidateHelper.h"
#import "CSTRouter.h"
#import "DXAlertView.h"
#import <AFNetworking/AFNetworking.h>
#import "CSTNetworking.h"
#import "CSTAPIBaseManager.h"
#import "CSTTimerManager.h"
#import "CSTUserProfile.h"
#import "MBProgressHUD.h"
#import "CSTUmeng.h"
#import "CSTWebViewController.h"

@interface CSTUserAccessViewController ()
@property (weak, nonatomic) IBOutlet UIButton *regButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifiedCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *triangleImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *triangleLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verifiedCodeTextFiedShowConstraint;
@property (weak, nonatomic) IBOutlet UILabel *verifiedCodeLine;
@property (weak, nonatomic) IBOutlet UILabel *protocolLabel;
@property (weak, nonatomic) IBOutlet UIButton *protocolButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomOrlabel;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLeftLineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomRightLineImageView;
@property (weak, nonatomic) IBOutlet UIButton *qqLoinButton;
@property (weak, nonatomic) IBOutlet UILabel *qqLoginLabel;
@property (weak, nonatomic) IBOutlet UILabel *qqLoginDetailLabel;

@property (strong, nonatomic) NSLayoutConstraint *triangleRightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *verifiedCodeTextFiedHideConstraint;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) UIButton *smsVerifiedCodeButton;
@property (strong, nonatomic) UILabel *leftTimeLabel;


@end

@implementation CSTUserAccessViewController

#pragma mark - Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
         //self.accessType = CSTAccessTypeRegister;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
       // self.accessType = CSTAccessTypeRegister;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_configSubViews];
    [self p_configAccessState];
    [self.view addGestureRecognizer:self.tap];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.viewModel.userName = nil;
    self.viewModel.password = nil;
    self.viewModel.verifiedCode = nil;
    self.usernameTextField.text = nil;
    self.passwordTextField.text = nil;
    self.verifiedCodeTextField.text = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.viewModel.accessType == CSTAccessTypeLogin)
    {
        [self p_changeTypeFromRegToLoginWithAnimated:NO];
    }
    else if (self.viewModel.accessType == CSTAccessTypeRegister)
    {
        [self p_changeTypeFromLoginToRegWithAnimated:NO];
    }
    
    self.triangleImageView.hidden = NO;
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

#pragma mark - CSTThirdPartyLoginDelegate

- (void)userDidLoginWithUserProfile:(CSTUserProfile *)userProfile{

    [self p_routeToNextVCWithUserProfile:userProfile];
    [self.viewModel configBLEWithUserProfile:userProfile];
}


#pragma mark - Event response


#pragma mark - Publick method


- (RACSignal *)qqLoginSignalWithQQTokenDic:(NSDictionary *)qqToken{

    self.viewModel.qqTokenParameters = qqToken;
    @weakify(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    return [[[[self.viewModel qqLoginSignalWithQQTokenDic:qqToken]doNext:^(id x) {
        
        @strongify(self);
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        [self p_routeToNextVCWithUserProfile:x];
        [self.viewModel configBLEWithUserProfile:x];
    }] doError:^(NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
    }] flattenMap:^RACStream *(id value) {
        
        return  [self.viewModel relationShipAndMateProfileSignal];
    }];
}

#pragma mark - Private Methods


- (void)p_configSubViews
{
    [self p_configDoneButton];
    [self p_configUsernameTextField];
    [self p_configPasswordTextField];
    [self p_configVerifiedCodeTextField];
    [self p_configRegButton];
    [self p_configLoginButton];
    [self p_configQQloginButton];
    [self p_hideBottonViews];
    [self p_configBottomViewsWithAlpha:0.0];
    [self p_configTriangleView];
    [self p_configProtocolButton];
}

- (void)p_configTriangleView
{
    self.triangleImageView.hidden = YES;
}

- (void)p_configProtocolButton{

    @weakify(self);
    self.protocolButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        
        CSTWebViewController *webViewController = [[CSTWebViewController alloc] init];
        
        [self.navigationController pushViewController:webViewController animated:YES];
        
        return [RACSignal empty];
    }];
}


- (void)p_configRegButton
{
    @weakify(self);
    [[self.regButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        self.viewModel.accessType = CSTAccessTypeRegister;
    }];
}

- (void)p_configLoginButton
{
    @weakify(self);
    
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.viewModel.accessType = CSTAccessTypeLogin;
    }];
}


- (void)p_configDoneButton
{
    self.doneButton.layer.cornerRadius = 22.0;
    self.doneButton.layer.borderColor = [UIColor waveColor].CGColor;
    self.doneButton.layer.borderWidth = 1.0;
    
    @weakify(self)
    RACSignal *signal =[[self.viewModel validateSignal]doNext:^(id x) {
        
        @strongify(self);
        
        self.doneButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
    }];
    
    self.doneButton.rac_command = [[RACCommand alloc] initWithEnabled:signal signalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        
        [self cst_dismissKeyboard];
        [self p_disableUserInteractionWithButton:self.doneButton];
        
        RACSignal *signal = self.viewModel.accessType == CSTAccessTypeLogin ? [self.viewModel loginSignal] : [self.viewModel registerSignal];
        
        CSTAccessEventErrorType errorTyoe = self.viewModel.accessType == CSTAccessTypeLogin ? CSTAccessEventErrorLogin :CSTAccessEventErrorRegister;
        
        return [[[signal doNext:^(id x) {
            
                    [self p_routeToNextVCWithUserProfile:x];
                    [self.viewModel configBLEWithUserProfile:x];
                    [self p_enanbleUserInteractionWithButton:self.doneButton];
            
                }] doError:^(NSError *error) {
            
                    [self.viewModel handleError:error withEventType:errorTyoe];
                    [self p_enanbleUserInteractionWithButton:self.doneButton];
                }] flattenMap:^RACStream *(id value) {
                    
                    return [self.viewModel relationShipAndMateProfileSignal];
                }];
    }];
}

- (void)p_routeToNextVCWithUserProfile:(CSTUserProfile *)userProfile{

    if (userProfile.birthday) {
        [CSTRouter routerToViewControllerType:CSTRouterViewControllerTypeMain fromViewController:self];
    }else{
        [self performSegueWithIdentifier:@"toInitializeUserData" sender:nil];
    }
}

- (void)p_enanbleUserInteractionWithButton:(UIButton *)button
{
    
    @weakify(self)
    [[self.viewModel validateSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        self.doneButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
        
        self.doneButton.enabled = [x boolValue];
    }];
    
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];

    self.loginButton.enabled = YES;
    self.regButton.enabled = YES;
    self.qqLoinButton.enabled = YES;
    self.protocolButton.enabled = YES;
    self.usernameTextField.enabled = YES;
    self.passwordTextField.enabled = YES;
    
    
    ((UIButton *)self.passwordTextField.rightView).enabled = YES;
    
    if (self.viewModel.accessType == CSTAccessTypeRegister)
    {
        if ([self.verifiedCodeTextField.rightView isKindOfClass:[UIButton class]])
        {
           ((UIButton *)self.verifiedCodeTextField.rightView).enabled = YES;
        }
        self.verifiedCodeTextField.enabled = YES;
    }
    
    if (button == self.doneButton && self.viewModel.accessType == CSTAccessTypeRegister)
    {
        [self.doneButton setTitle:@"注册" forState:UIControlStateNormal];
    }
    else if (button == self.doneButton && self.viewModel.accessType == CSTAccessTypeLogin)
    {
        [self.doneButton setTitle:@"登录" forState:UIControlStateNormal];
    }
    else if (button == self.verifiedCodeTextField.rightView)
    {
        [button setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}


- (void)p_disableUserInteractionWithButton:(UIButton *)button
{
   
    [button setTitle:@"" forState:UIControlStateNormal];
    self.doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.doneButton.enabled = NO;
    if ([self.verifiedCodeTextField.rightView isKindOfClass:[UIButton class]])
    {
        ((UIButton *)self.verifiedCodeTextField.rightView).enabled = NO;
    }
    
    if (button == self.doneButton)
    {
        self.indicatorView.center = CGPointMake(CGRectGetMidX(self.doneButton.bounds), CGRectGetMidY(self.doneButton.bounds));
    }
    else if(button == self.verifiedCodeTextField.rightView)
    {
        self.indicatorView.center = CGPointMake(CGRectGetMaxX(button.bounds) - CGRectGetMidX(self.indicatorView.bounds), CGRectGetMidY(button.bounds));
    }
    [button addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    
    self.loginButton.enabled = NO;
    self.regButton.enabled = NO;
    self.qqLoinButton.enabled = NO;
    self.protocolButton.enabled = NO;
    self.usernameTextField.enabled = NO;
    self.passwordTextField.enabled = NO;
    
    ((UIButton *)self.passwordTextField.rightView).enabled = NO;
    
    if (self.viewModel.accessType == CSTAccessTypeRegister)
    {
        if ([self.verifiedCodeTextField.rightView isKindOfClass:[UIButton class]])
        {
            ((UIButton *)self.verifiedCodeTextField.rightView).enabled = NO;
        }
        self.verifiedCodeTextField.enabled = NO;
    }

}
- (void)p_configUsernameTextField
{
    [self p_configTextField:self.usernameTextField withLeftString:@"用户名"];
    
    RAC(self,viewModel.userName) = self.usernameTextField.rac_textSignal;
}

- (void)p_configPasswordTextField
{
   [self p_configTextField:self.passwordTextField withLeftString:@"密码"];
    RAC(self,viewModel.password) = self.passwordTextField.rac_textSignal;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    rightButton.bounds = (CGRect){
        .origin.x = 0.0f,
        .origin.y = 0.0,
        .size.width =  CGRectGetWidth(self.view.bounds) / 5,
        .size.height = 50,
    };
    [rightButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    self.passwordTextField.rightView = rightButton;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.rightView.alpha = 0.0;
    self.passwordTextField.rightView.hidden = YES;
    
    
    [[rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self performSegueWithIdentifier:@"toFindPasswordVC" sender:nil];
    }];
}

- (void)p_configVerifiedCodeTextField
{
    [self p_configTextField:self.verifiedCodeTextField withLeftString:@"验证码"];
    RAC(self,viewModel.verifiedCode) = self.verifiedCodeTextField.rac_textSignal;
    
    [self p_configSmsVifiriedButton];
    [self p_configLeftTimeLabel];
    self.verifiedCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    
    if ([CSTTimerManager shareManager].registerSMSTimer && [CSTTimerManager shareManager].registerSMSInterval > 0 && [CSTTimerManager shareManager].registerSMSInterval < CSTSMSTimeInteval) {
        
        self.verifiedCodeTextField.rightView = self.leftTimeLabel;
    }else {
        self.verifiedCodeTextField.rightView = self.smsVerifiedCodeButton;
    }
    
    
}

- (void)p_configSmsVifiriedButton
{
    
    RACSignal *signal = [self.usernameTextField.rac_textSignal map:^id(NSString *username) {
        return @([CSTValidateHelper isPhoneNumberValid:username]);
    }];
    
    @weakify(self);
    self.smsVerifiedCodeButton.rac_command = [[RACCommand alloc] initWithEnabled:signal signalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        [self p_disableUserInteractionWithButton:self.smsVerifiedCodeButton];
        
        return [[[self.viewModel smsSignal]
                 doNext:^(id x) {
                     
                     [self p_enanbleUserInteractionWithButton:self.smsVerifiedCodeButton];
                     self.verifiedCodeTextField.rightView = self.leftTimeLabel;
                     [[CSTTimerManager shareManager] stopTimer:CSTSMSTimerRegiser];
                     
                 }] doError:^(NSError *error) {
                     
                     [self.viewModel handleError:error withEventType:CSTAccessEventErrorSMS];
                     
                     [self p_enanbleUserInteractionWithButton:self.smsVerifiedCodeButton];
                 }];
    }];

}

- (void)p_configLeftTimeLabel
{
    @weakify(self);
    RAC(self,leftTimeLabel.text) = [[RACObserve([CSTTimerManager shareManager], registerSMSInterval) doNext:^(id x) {
        
        @strongify(self);
        if ([x integerValue] <= 0) {
            
            [[CSTTimerManager shareManager] stopTimer:CSTSMSTimerRegiser];
            self.verifiedCodeTextField.rightView = self.smsVerifiedCodeButton;
        }
    }] map:^id(id value) {
        
        return [value stringValue];
    }];
    
}


- (void)p_configTextField:(UITextField *)textField withLeftString:(NSString *)string
{
    textField.borderStyle = UITextBorderStyleNone;
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:(CGRect){
        .origin.x = 0.0f,
        .origin.y = 0.0,
        .size.width =  CGRectGetWidth(self.view.bounds) / 5,
        .size.height = 50,
    }];
    leftLabel.text = string;
    leftLabel.textColor = [UIColor lightGrayColor];
    textField.leftView = leftLabel;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)p_configQQloginButton
{
    
    @weakify(self);
    self.qqLoinButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        
        return [[[[[self.viewModel qqTokenSignalWithViewController:self] flattenMap:^RACStream *(id value) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            return [self.viewModel qqLoginSignalWithQQTokenDic:value];
            
        }] doNext:^(id x) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            [self p_routeToNextVCWithUserProfile:x];
            [self.viewModel configBLEWithUserProfile:x];
            
        }] doError:^(NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            
        }] flattenMap:^RACStream *(id value) {
            
            return  [self.viewModel relationShipAndMateProfileSignal];
        }];
    }];
    
}

- (void)p_showBottomViews
{
    self.qqLoinButton.hidden = NO;
    self.qqLoginLabel.hidden = NO;
    self.qqLoginDetailLabel.hidden = NO;
    self.bottomOrlabel.hidden = NO;
    self.bottomLeftLineImageView.hidden = NO;
    self.bottomRightLineImageView.hidden = NO;
}
- (void)p_hideBottonViews
{
    self.qqLoinButton.hidden = YES;
    self.qqLoginLabel.hidden = YES;
    self.qqLoginDetailLabel.hidden = YES;
    self.bottomOrlabel.hidden = YES;
    self.bottomLeftLineImageView.hidden = YES;
    self.bottomRightLineImageView.hidden = YES;
}

- (void)p_configBottomViewsWithAlpha:(CGFloat)alpha
{
    self.qqLoinButton.alpha = alpha;
    self.qqLoginLabel.alpha = alpha;
    self.qqLoginDetailLabel.alpha = alpha;
    self.bottomOrlabel.alpha = alpha;
    self.bottomLeftLineImageView.alpha = alpha;
    self.bottomRightLineImageView.alpha = alpha;
}

- (void)p_configAccessState
{
    self.viewModel.accessType = CSTAccessTypeLogin;
    
    @weakify(self);
    
    [RACObserve(self, viewModel.accessType) subscribeNext:^(id x) {
        
        @strongify(self);
        
        if ((CSTAccessType)[x integerValue] == CSTAccessTypeLogin)
        {
            [self p_changeTypeFromRegToLoginWithAnimated:YES];
        }
        else if ((CSTAccessType)[x integerValue] == CSTAccessTypeRegister)
        {
            [self p_changeTypeFromLoginToRegWithAnimated:YES];
        }
    }];
}


- (void)p_changeTypeFromLoginToRegWithAnimated:(BOOL)animated
{
    BOOL needUpdate = NO;
    if (self.triangleRightConstraint.active)
    {
        needUpdate = YES;
        [NSLayoutConstraint deactivateConstraints:@[self.triangleRightConstraint]];
        [NSLayoutConstraint activateConstraints:@[self.triangleLeftConstraint]];
    }
    
    if (self.verifiedCodeTextFiedHideConstraint.active)
    {
        [NSLayoutConstraint deactivateConstraints:@[self.verifiedCodeTextFiedHideConstraint]];
        [NSLayoutConstraint activateConstraints:@[self.verifiedCodeTextFiedShowConstraint]];
    }
    
    if (needUpdate)
    {
        self.verifiedCodeLine.hidden = NO;
        self.protocolButton.hidden = NO;
        self.protocolLabel.hidden = NO;
        self.passwordTextField.secureTextEntry = NO;
        self.passwordTextField.text = @"";
        self.viewModel.password = nil;
        self.verifiedCodeTextField.placeholder = @"6位验证码";
        self.verifiedCodeTextField.text = @"";
        self.viewModel.verifiedCode = nil;
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [self.view layoutIfNeeded];
                self.passwordTextField.rightView.alpha = 0.0;
                [self p_configBottomViewsWithAlpha:0.0];
                
            } completion:^(BOOL finished) {
                self.passwordTextField.rightView.hidden = YES;
                [self p_hideBottonViews];
                [UIView setAnimationsEnabled:NO];
                [self.doneButton setTitle:@"注册" forState:UIControlStateNormal];
                self.doneButton.enabled = NO;
                self.doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
                [self.doneButton layoutIfNeeded];
                [UIView setAnimationsEnabled:YES];
            }];
        }
        else
        {
            [self.view layoutIfNeeded];
            self.passwordTextField.rightView.alpha = 0.0;
            self.passwordTextField.rightView.hidden = YES;
            [self p_configBottomViewsWithAlpha:0.0];
            [self p_hideBottonViews];
            [UIView setAnimationsEnabled:NO];
            [self.doneButton setTitle:@"注册" forState:UIControlStateNormal];
            self.doneButton.enabled = NO;
            self.doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [self.doneButton layoutIfNeeded];
            [UIView setAnimationsEnabled:YES];
        }
    }
}

- (void)p_changeTypeFromRegToLoginWithAnimated:(BOOL)animated
{
    BOOL needUpdate = NO;
    if (self.triangleLeftConstraint.active)
    {
        needUpdate = YES;
        [NSLayoutConstraint deactivateConstraints:@[self.triangleLeftConstraint]];
        [NSLayoutConstraint activateConstraints:@[self.triangleRightConstraint]];
    }
    
    if (self.verifiedCodeTextFiedShowConstraint.active)
    {
        [NSLayoutConstraint deactivateConstraints:@[self.verifiedCodeTextFiedShowConstraint]];
        [NSLayoutConstraint activateConstraints:@[self.verifiedCodeTextFiedHideConstraint]];
    }
    
    if (needUpdate)
    {
        self.verifiedCodeLine.hidden = YES;
        self.protocolButton.hidden = YES;
        self.protocolLabel.hidden = YES;
        self.passwordTextField.rightView.hidden = NO;
        self.passwordTextField.secureTextEntry = YES;
        self.passwordTextField.text = @"";
        self.viewModel.password = nil;
        self.verifiedCodeTextField.placeholder = @"";
        self.verifiedCodeTextField.text = @"";
        self.viewModel.verifiedCode = nil;
        if ([CSTUmeng isQQInstalled]) {
            [self p_showBottomViews];
        }


        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [self.view layoutIfNeeded];
                self.passwordTextField.rightView.alpha = 1.0;
                [self p_configBottomViewsWithAlpha:1.0];
            } completion:^(BOOL finished) {
                
                [UIView setAnimationsEnabled:NO];
                [self.doneButton setTitle:@"登录" forState:UIControlStateNormal];
                self.doneButton.enabled = NO;
                self.doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
                [self.doneButton layoutIfNeeded];
                [UIView setAnimationsEnabled:YES];
            }];
        }
        else
        {
            [self.view layoutIfNeeded];
            self.passwordTextField.rightView.alpha = 1.0;
            [self p_configBottomViewsWithAlpha:1.0];
            [UIView setAnimationsEnabled:NO];
            [self.doneButton setTitle:@"登录" forState:UIControlStateNormal];
            self.doneButton.enabled = NO;
            self.doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [self.doneButton layoutIfNeeded];
            [UIView setAnimationsEnabled:YES];
        }
    }
}


#pragma mark - Setters and getters

- (NSLayoutConstraint *)triangleRightConstraint
{
    if (!_triangleRightConstraint)
    {
        _triangleRightConstraint = [NSLayoutConstraint constraintWithItem:self.triangleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    }
    return _triangleRightConstraint;
}

- (NSLayoutConstraint *)verifiedCodeTextFiedHideConstraint
{
    if (!_verifiedCodeTextFiedHideConstraint)
    {
        _verifiedCodeTextFiedHideConstraint = [NSLayoutConstraint constraintWithItem:self.verifiedCodeTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    }
    return _verifiedCodeTextFiedHideConstraint;
}

- (UITapGestureRecognizer *)tap
{
    if (!_tap)
    {
        _tap = [[UITapGestureRecognizer alloc] init];
        
        @weakify(self);
        
        [[_tap rac_gestureSignal] subscribeNext:^(id x) {
            
            @strongify(self);
            [self cst_dismissKeyboard];
        }];
    }
    return _tap;
}

- (CSTUserAccessViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [[CSTUserAccessViewModel alloc] initWithAccessType:CSTAccessTypeRegister userName:nil password:nil verifiedCode:nil];
        _viewModel.delegate = self;
    }
    return _viewModel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _indicatorView;
}


- (UIButton *)smsVerifiedCodeButton
{
    if (!_smsVerifiedCodeButton)
    {
        
        _smsVerifiedCodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _smsVerifiedCodeButton.bounds = (CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width =  CGRectGetWidth(self.view.bounds) / 4,
            .size.height = 50,
        };
        [_smsVerifiedCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
    return _smsVerifiedCodeButton;
}


- (UILabel *)leftTimeLabel
{
    if (!_leftTimeLabel)
    {
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.bounds = (CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width =  CGRectGetWidth(self.view.bounds) / 4,
            .size.height = 50,
        };
        _leftTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _leftTimeLabel;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
