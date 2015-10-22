//
//  CSTFindPasswordViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/14.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTFindPasswordViewController.h"
#import "CSTFindPasswordViewModel.h"
#import "Colours.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+CSTDismissKeyboard.h"
#import "CSTValidateHelper.h"
#import "CSTFindPasswordViewModel.h"
#import "CSTTimerManager.h"


@interface CSTFindPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifiedCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *modifyPasswordButton;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) UIButton *smsVerifiedCodeButton;
@property (strong, nonatomic) UILabel *leftTimeLabel;

@end

@implementation CSTFindPasswordViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_configNavigationBar];
    [self p_configSubViews];
    [self.view addGestureRecognizer:self.tap];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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



#pragma mark - Event response


#pragma mark - Private Methods

- (void)p_configNavigationBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromRGBAArray:@[@0,@(185.0 / 255.0),@(249.0/255.0),@1]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]
                                                        };
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
 
}
- (void)p_configSubViews
{
    [self p_configUsernameTextFiled];
    [self p_configVerifiedCodeTextFiled];
    [self p_configCurrentPasswordTextFiled];
    [self p_configModifyPasswordButton];
}

- (void)p_configUsernameTextFiled
{
    [self p_configTextField:self.usernameTextField withLeftString:@"手机号"];
    RAC(self.viewModel,userName) = self.usernameTextField.rac_textSignal;
}
- (void)p_configVerifiedCodeTextFiled
{
    [self p_configTextField:self.verifiedCodeTextField withLeftString:@"验证码"];
    
    RAC(self.viewModel,verifiedCode) = self.verifiedCodeTextField.rac_textSignal;
    
    [self p_configSmsVifiriedButton];
    [self p_configLeftTimeLabel];
    
    if ([CSTTimerManager shareManager].modifyPasswordSMSTimer && [CSTTimerManager shareManager].modifyPasswordSMSInterval > 0 && [CSTTimerManager shareManager].modifyPasswordSMSInterval < CSTSMSTimeInteval) {
        
        self.verifiedCodeTextField.rightView = self.leftTimeLabel;
    }else {
        self.verifiedCodeTextField.rightView = self.smsVerifiedCodeButton;
    }
    
    self.verifiedCodeTextField.rightViewMode = UITextFieldViewModeAlways;
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
                     [[CSTTimerManager  shareManager] startTimer:CSTSMSTimerModifyPassword];
                     
                 }] doError:^(NSError *error) {
                     
                     [self p_enanbleUserInteractionWithButton:self.smsVerifiedCodeButton];
                 }];
    }];
    
}

- (void)p_configLeftTimeLabel
{
    @weakify(self);
    RAC(self,leftTimeLabel.text) = [[RACObserve([CSTTimerManager shareManager], modifyPasswordSMSInterval) doNext:^(id x) {
        
        @strongify(self);
        if ([x integerValue] <= 0) {
            
            [[CSTTimerManager shareManager] stopTimer:CSTSMSTimerModifyPassword];
            self.verifiedCodeTextField.rightView = self.smsVerifiedCodeButton;
        }
    }] map:^id(id value) {
        
        return [value stringValue];
    }];
}


- (void)p_configCurrentPasswordTextFiled
{
    [self p_configTextField:self.currentPasswordTextField withLeftString:@"新密码"];
    
    RAC(self.viewModel,currentPassword) = self.currentPasswordTextField.rac_textSignal;
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

- (void)p_configModifyPasswordButton
{
    self.modifyPasswordButton.layer.cornerRadius = 22.0;
    self.modifyPasswordButton.layer.borderColor = [UIColor waveColor].CGColor;
    self.modifyPasswordButton.layer.borderWidth = 1.0;
    
    @weakify(self)
    RACSignal *signal = [[self.viewModel  validateSignal]
                          doNext:^(id x) {
                           
                           @strongify(self);
                           
                           self.modifyPasswordButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
                          }];
    
    self.modifyPasswordButton.rac_command = [[RACCommand alloc] initWithEnabled:signal signalBlock:^RACSignal *(id input) {
    
        @strongify(self);
        
        [self cst_dismissKeyboard];
        [self p_disableUserInteractionWithButton:self.modifyPasswordButton];
        
        return [[[self.viewModel changePasswordSignal] doNext:^(id x) {
            
            [self p_enanbleUserInteractionWithButton:self.modifyPasswordButton];
            
        }] doError:^(NSError *error) {
            
             [self p_enanbleUserInteractionWithButton:self.modifyPasswordButton];
        }];
    }];
}


- (void)p_disableUserInteractionWithButton:(UIButton *)button
{
    
    [button setTitle:@"" forState:UIControlStateNormal];
    self.usernameTextField.enabled = NO;
    self.verifiedCodeTextField.enabled = NO;
    self.currentPasswordTextField.enabled = NO;
    if ([self.verifiedCodeTextField.rightView isKindOfClass:[UIButton class]])
    {
        ((UIButton *)self.verifiedCodeTextField.rightView).enabled = NO;
    }
    self.modifyPasswordButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.modifyPasswordButton.enabled = NO;
    
    self.navigationController.view.userInteractionEnabled = NO;
    
    if (button == self.modifyPasswordButton)
    {
        self.indicatorView.center = CGPointMake(CGRectGetMidX(self.modifyPasswordButton.bounds), CGRectGetMidY(self.modifyPasswordButton.bounds));
    }
    else if(button == self.verifiedCodeTextField.rightView)
    {
        self.indicatorView.center = CGPointMake(CGRectGetMaxX(button.bounds) - CGRectGetMidX(self.indicatorView.bounds), CGRectGetMidY(button.bounds));
    }
    
    [button addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    
}
- (void)p_enanbleUserInteractionWithButton:(UIButton *)button
{
    
    @weakify(self)
    [[self.viewModel validateSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        self.modifyPasswordButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
        
        self.modifyPasswordButton.enabled = [x boolValue];
    }];
    
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
    self.usernameTextField.enabled = YES;
    self.verifiedCodeTextField.enabled = YES;
    self.currentPasswordTextField.enabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    
    if (button == self.modifyPasswordButton) {
        
        [button setTitle:@"修改密码" forState:UIControlStateNormal];
        
    }else if (button == self.verifiedCodeTextField.rightView){
    
        [button setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
    
    if ([self.verifiedCodeTextField.rightView isKindOfClass:[UIButton class]])
    {
        ((UIButton *)self.verifiedCodeTextField.rightView).enabled = YES;
    }
    
}


#pragma mark - Setters and getters

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

- (CSTFindPasswordViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [[CSTFindPasswordViewModel alloc] init];
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
