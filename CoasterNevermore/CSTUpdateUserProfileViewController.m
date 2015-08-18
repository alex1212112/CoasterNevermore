//
//  CSTUpdateUserProfileViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUpdateUserProfileViewController.h"
#import "CSTUpdateUserProfileViewModel.h"
#import <ReactiveCocoa.h>
#import "NSDate+CSTTransformString.h"
#import "CSTUserProfile.h"
#import "UIViewController+CSTDismissKeyboard.h"
#import "Colours.h"

@interface CSTUpdateUserProfileViewController ()<UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UIImageView *topLineView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineViewConstraintHeight;

@end

@implementation CSTUpdateUserProfileViewController

#pragma mark - Life cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [self p_configSubViews];
    [self.view addGestureRecognizer:self.tap];
}


- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
}

#pragma mark - UIPickerView delegate


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    
    NSAttributedString *string;
    if (self.viewModel.userProfileType == CSTUserProfileTypeWeight) {
        
        string = [self.viewModel attributedStringWithNumber:row + 10 string:@"公斤"] ;
        
    }else if (self.viewModel.userProfileType == CSTUserProfileTypeHeight){
        
        string = [self.viewModel attributedStringWithNumber:row + 70 string:@"厘米"];
    }
    
    UILabel *label = [[UILabel alloc]init];
    
    label.attributedText = string;
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (self.viewModel.userProfileType == CSTUserProfileTypeWeight) {
        
        self.viewModel.weight = @(row + 10);
    }else if (self.viewModel.userProfileType == CSTUserProfileTypeHeight){
        
        self.viewModel.height = @(row + 70);
    }
}

#pragma mark - Private method


- (void)p_configSubViews{

    
    [self p_configPickerView];
    [self p_configDatePicker];
    [self p_configTextField];
    [self p_configMaleButton];
    [self p_configFemleButton];
    [self p_configGenderButtonState];
}

- (void)p_configPickerView{

    self.pickerView.hidden = self.viewModel.userProfileType != CSTUserProfileTypeHeight && self.viewModel.userProfileType != CSTUserProfileTypeWeight;
    self.pickerView.dataSource = self.viewModel;
    self.pickerView.delegate = self;
    
    if (self.viewModel.userProfileType == CSTUserProfileTypeHeight) {
        
        [self.pickerView selectRow:95 inComponent:0 animated:NO];
    }else if (self.viewModel.userProfileType == CSTUserProfileTypeWeight){
        
        [self.pickerView selectRow:55 inComponent:0 animated:NO];
    }
}

- (void)p_configDatePicker{

    self.datePicker.hidden = self.viewModel.userProfileType != CSTUserProfileTypeBirthday;
    

    self.datePicker.maximumDate = [NSDate date];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 1940;
    components.month = 1;
    components.day = 1;
    self.datePicker.minimumDate = [cal dateFromComponents:components];
    
    components.year = 1987;
    components.month = 1;
    components.day = 1;
    
    self.datePicker.date = [cal dateFromComponents:components];
    
    [self.datePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    SEL selector = NSSelectorFromString( @"setHighlightsToday:" );
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature :
                                [UIDatePicker
                                 instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.datePicker];
    
    if ([self.datePicker.subviews count] > 0) {
        
        UIView *view = self.datePicker.subviews[0];
        
        ((UIView *)[view.subviews objectAtIndex:1]).backgroundColor = [UIColor lightTextColor];
        ((UIView *)[view.subviews objectAtIndex:2]).backgroundColor = [UIColor lightTextColor];
    }
    
    @weakify(self);
    [[self.datePicker rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.viewModel.birthday = self.datePicker.date;
    }];
}

- (void)p_configTextField{

    self.nicknameTextField.hidden = self.viewModel.userProfileType != CSTUserProfileTypeNickname;
    self.topLineView.hidden = self.viewModel.userProfileType != CSTUserProfileTypeNickname;
    self.bottomLineView.hidden = self.viewModel.userProfileType != CSTUserProfileTypeNickname;
    
    self.topLineViewConstraintHeight.constant = 0.5;
    self.bottomLineViewConstraintHeight.constant = 0.5;
;
    
    
    self.nicknameTextField.text = self.viewModel.nickname;
    if (!self.nicknameTextField.hidden) {
        
        [self.nicknameTextField  becomeFirstResponder];
    }
    
    @weakify(self);
    [self.nicknameTextField.rac_textSignal subscribeNext:^(id x) {
        @strongify(self);
        self.viewModel.nickname = x;
    }];
}

- (void)p_configMaleButton{

    self.maleButton.hidden = self.viewModel.userProfileType != CSTUserProfileTypeGender;
    
    @weakify(self);
    [[self.maleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.maleButton.selected = YES;
        self.femaleButton.selected = NO;
        self.viewModel.gender = @(CSTUserGenderMale);
    }];
}

- (void)p_configFemleButton{

    self.femaleButton.hidden = self.viewModel.userProfileType != CSTUserProfileTypeGender;
    @weakify(self);
    [[self.femaleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.maleButton.selected = NO;
        self.femaleButton.selected = YES;
        self.viewModel.gender = @(CSTUserGenderFemale);
    }];
}

- (void)p_configGenderButtonState{

    if ([self.viewModel.gender isEqual:@(CSTUserGenderMale)]) {
        
        self.maleButton.selected = YES;
        self.femaleButton.selected = NO;
    }else if([self.viewModel.gender isEqual:@(CSTUserGenderFemale)]){
        self.maleButton.selected = NO;
        self.femaleButton.selected = YES;
    }
}


#pragma mark - Setters and getters

- (UITapGestureRecognizer *)tap{
    
    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] init];
        
        @weakify(self);
        [[_tap rac_gestureSignal] subscribeNext:^(id x) {
            
            @strongify(self);
            
            [self  cst_dismissKeyboard];
        }];
    }
    
    return _tap;
}



@end
