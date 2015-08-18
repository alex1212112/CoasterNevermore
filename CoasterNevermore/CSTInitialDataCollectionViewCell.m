//
//  CSTInitialDataCollectionViewCell.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTInitialDataCollectionViewCell.h"
#import "CSTInitialDataCellModel.h"
#import <ReactiveCocoa.h>
#import "Colours.h"
#import "NSDate+CSTTransformString.h"

@interface CSTInitialDataCollectionViewCell ()<UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentDetailLabel;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *famaleButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *nomalPicker;

@end

@implementation CSTInitialDataCollectionViewCell
@synthesize viewModel = _viewModel;

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self p_bindData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self p_bindData];
    }
    return self;
}

- (void)awakeFromNib
{
    self.nomalPicker.delegate = self;
    [self p_configFamaleButtonEvent];
    [self p_configMaleButtonEvent];
    [self p_configDatePicker];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self p_configNomalPicker];
}

#pragma mark - Private Method
- (void)p_bindData
{
    
    RAC(self,titleLabel.text) = RACObserve(self, viewModel.title);
    RAC(self,contentLabel.text) = RACObserve(self, viewModel.content);
    RAC(self,contentDetailLabel.text) = RACObserve(self, viewModel.detail);
    
    [RACObserve(self, viewModel.type) subscribeNext:^(id x) {
       
        if ([x integerValue] == CSTUserProfileTypeGender) {
            
            self.datePicker.hidden = YES;
            self.nomalPicker.hidden = YES;
            self.maleButton.hidden = NO;
            self.famaleButton.hidden = NO;
        }else if ([x integerValue] == CSTUserProfileTypeHeight){
        
            self.datePicker.hidden = YES;
            self.nomalPicker.hidden = NO;
            self.maleButton.hidden = YES;
            self.famaleButton.hidden = YES;
        }else if ([x integerValue] == CSTUserProfileTypeWeight){
        
            self.datePicker.hidden = YES;
            self.nomalPicker.hidden = NO;
            self.maleButton.hidden = YES;
            self.famaleButton.hidden = YES;
        
        }else if ([x integerValue] == CSTUserProfileTypeBirthday){
           
            self.datePicker.hidden = NO;
            self.nomalPicker.hidden = YES;
            self.maleButton.hidden = YES;
            self.famaleButton.hidden = YES;
        
        }
    }];
}

- (void)p_configMaleButtonEvent{

    @weakify(self);
    [[self.maleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.maleButton.selected = YES;
        self.famaleButton.selected = NO;
        self.viewModel.userInfo.gender = @(CSTUserGenderMale);
    }];
}

- (void)p_configFamaleButtonEvent{

    @weakify(self);
    [[self.famaleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.famaleButton.selected = YES;
        self.maleButton.selected = NO;
        self.viewModel.userInfo.gender = @(CSTUserGenderFemale);
    }];
}

- (void)p_configDatePicker{

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
    
    @weakify(self);
    [[self.datePicker rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        
        self.viewModel.userInfo.birthday = [self.datePicker.date  cst_stringWithFormat:@"yyyy-MM-dd"];
    }];
    
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
}


- (void)p_configNomalPicker{
    
    if ([self.nomalPicker.subviews count] > 0) {
        
        ((UIView *)[self.nomalPicker.subviews objectAtIndex:1]).backgroundColor = [UIColor lightTextColor];
        ((UIView *)[self.nomalPicker.subviews objectAtIndex:2]).backgroundColor = [UIColor lightTextColor];
    }
}

#pragma mark - UIPickerView delegate


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
 
    NSAttributedString *string;
    if (self.viewModel.type == CSTUserProfileTypeWeight) {
        
      string = [self.viewModel attributedStringWithNumber:row + 10 string:@"公斤"] ;
        
    }else if (self.viewModel.type == CSTUserProfileTypeHeight){
        
      string = [self.viewModel attributedStringWithNumber:row + 70 string:@"厘米"];
    }
    
    UILabel *label = [[UILabel alloc]init];
    
    label.attributedText = string;
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    if (self.viewModel.type == CSTUserProfileTypeWeight) {
        
        self.viewModel.userInfo.weight = @(row + 10);
    }else if (self.viewModel.type == CSTUserProfileTypeHeight){
    
        self.viewModel.userInfo.height = @(row + 70);
    }
}


#pragma mark - Setters and getters

- (CSTInitialDataCellModel *)viewModel
{
    if (!_viewModel) {
        
        _viewModel = [[CSTInitialDataCellModel alloc] init];
    }
    
    return _viewModel;
}

- (void)setViewModel:(CSTInitialDataCellModel *)viewModel
{
    if (_viewModel != viewModel) {
        
        _viewModel = viewModel;
        self.nomalPicker.dataSource = _viewModel;
        if (_viewModel.type == CSTUserProfileTypeHeight) {
            
            [self.nomalPicker selectRow:95 inComponent:0 animated:NO];
        }else if (_viewModel.type == CSTUserProfileTypeWeight){
        
            [self.nomalPicker selectRow:55 inComponent:0 animated:NO];
        }
    }
}


@end
