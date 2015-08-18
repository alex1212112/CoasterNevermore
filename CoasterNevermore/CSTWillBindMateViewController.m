//
//  CSTWillBindMateViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/3.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTWillBindMateViewController.h"
#import "Colours.h"
#import "CSTWillBindMateViewModel.h"
#import "CSTRelationship.h"
#import "CSTDataManager.h"
#import "CSTValidateHelper.h"
#import "CSTUserProfile.h"

#import "UIViewController+CSTDismissKeyboard.h"

#import <ReactiveCocoa.h>

@interface CSTWillBindMateViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mateIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *inviteOrCancelButton;


@property (weak, nonatomic) IBOutlet UIImageView *mateIDTextLineView;
@property (weak, nonatomic) IBOutlet UIButton *refuseButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UILabel *inviteDescriptionLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end


@implementation CSTWillBindMateViewController

#pragma mark - Life cycle
- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configSubViews];
    [self.view addGestureRecognizer:self.tap];
}


#pragma mark - Private method

- (void)p_configSubViews{

    [self p_configMateIDTextField];
    [self p_configinviteOrCancelButton];
    [self p_configInviteDescriptionLabel];
    [self p_configRefuseButton];
    [self p_configAcceptButton];

}

- (void)p_configMateIDTextField{

    @weakify(self);
    [[[RACObserve(self.viewModel, relationship) distinctUntilChanged] map:^id(id value) {
        
        return @(value ? YES : NO);
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.mateIDTextField.hidden = [x boolValue];
        self.mateIDTextLineView.hidden = [x boolValue];
        if ([x boolValue]) {
            
            self.mateIDTextField.text = @"";
            self.inviteOrCancelButton.enabled = NO;
            self.inviteOrCancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
    }];
}

- (void)p_configinviteOrCancelButton{

    self.inviteOrCancelButton.layer.cornerRadius = 22.0;
    self.inviteOrCancelButton.layer.borderWidth = 1.0;
    self.inviteOrCancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inviteOrCancelButton.enabled = NO;
    
    @weakify(self);
    [RACObserve(self.viewModel, relationship) subscribeNext:^(id x) {
        
        @strongify(self);
        CSTRelationship *relationship = x;
        if([relationship.status integerValue] == 1 && [relationship.fromUid isEqualToString:[CSTDataManager shareManager].userProfile.uid]){
            self.inviteOrCancelButton.hidden = NO;
            [self.inviteOrCancelButton setTitle:@"取消邀请" forState:UIControlStateNormal];
            
            
        }else if (!relationship){
            self.inviteOrCancelButton.hidden = NO;
            [self.inviteOrCancelButton setTitle:@"发送邀请" forState:UIControlStateNormal];
            
        }else{
            self.inviteOrCancelButton.hidden = YES;
        }
    }];
    
    RACSignal *signal =[[self.mateIDTextField.rac_textSignal map:^id(id value) {
        
        @strongify(self);
        if (!self.viewModel.relationship) {
            return @([CSTValidateHelper isPhoneNumberValid:value]);
        }else{
            return @YES;
        }
    }] doNext:^(id x) {
        
        self.inviteOrCancelButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
    }];
    
    
    self.inviteOrCancelButton.rac_command = [[RACCommand alloc] initWithEnabled:signal signalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        [self p_disableUserInteractionWithButton:self.inviteOrCancelButton];
        
        if (!self.viewModel.relationship) {
            return [[[self.viewModel inviteRelationshipSignalWithUsername:self.mateIDTextField.text] doNext:^(id x) {
                
                [self p_enanbleUserInteractionWithButton:self.inviteOrCancelButton];
            }] doError:^(NSError *error) {
                
                [self p_enanbleUserInteractionWithButton:self.inviteOrCancelButton];
            }];
            
        }else{
            
            return [[[self.viewModel cancelRelationshipSignal] doNext:^(id x) {
                
                [self p_enanbleUserInteractionWithButton:self.inviteOrCancelButton];
            }] doError:^(NSError *error) {
                [self p_enanbleUserInteractionWithButton:self.inviteOrCancelButton];
            }];
        }
    }];
}


- (void)p_configInviteDescriptionLabel{
    
    @weakify(self);
    [[RACObserve(self.viewModel, relationship) map:^id(id value) {
        
        return @([((CSTRelationship *)value).status integerValue] != 1);
    }]subscribeNext:^(id x) {
        @strongify(self);
        
        self.inviteDescriptionLabel.hidden = [x boolValue];
    }];
    
    RAC(self.inviteDescriptionLabel, text) = RACObserve(self.viewModel, pendingRelationshipDescription);
}


- (void)p_configRefuseButton{
    
    self.refuseButton.layer.borderWidth = 1.0;
    self.refuseButton.layer.borderColor = [UIColor redColor].CGColor;
    self.refuseButton.layer.cornerRadius = 22.0;
    self.refuseButton.tintColor = [UIColor redColor];
    
    @weakify(self);
    [[RACObserve(self.viewModel, relationship)map:^id(id value) {
        
        CSTRelationship *relationship = value;
        return  @([relationship.status integerValue] == 1 && [relationship.toUid isEqualToString:[CSTDataManager shareManager].userProfile.uid]);
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.refuseButton.hidden = ![x boolValue];
    }];
    
    self.refuseButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        [self p_disableUserInteractionWithButton:self.refuseButton];
        
        return [[[self.viewModel refuseRalationshiSignal] doNext:^(id x) {
            
            [self p_enanbleUserInteractionWithButton:self.refuseButton];
        }] doError:^(NSError *error) {
            [self p_enanbleUserInteractionWithButton:self.refuseButton];
        }];
    }];
}

- (void)p_configAcceptButton{
    
    self.acceptButton.layer.borderWidth = 1.0;
    self.acceptButton.layer.borderColor = [UIColor waveColor].CGColor;
    self.acceptButton.layer.cornerRadius = 22.0;
    
    @weakify(self);
    [[RACObserve(self.viewModel, relationship)map:^id(id value) {
        
        CSTRelationship *relationship = value;
        return  @([relationship.status integerValue] == 1 && [relationship.toUid isEqualToString:[CSTDataManager shareManager].userProfile.uid]);
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.acceptButton.hidden = ![x boolValue];
    }];
    
    self.acceptButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        [self p_disableUserInteractionWithButton:self.acceptButton];
        return [[[self.viewModel acceptRelationshipSignal] doNext:^(id x) {
            
            [self p_enanbleUserInteractionWithButton:self.acceptButton];
        }] doError:^(NSError *error) {
            [self p_enanbleUserInteractionWithButton:self.acceptButton];
        }];
    }];
}


- (void)p_enanbleUserInteractionWithButton:(UIButton *)button
{
    self.refuseButton.layer.borderColor = [UIColor redColor].CGColor;
    self.refuseButton.enabled = YES;
    
    self.acceptButton.layer.borderColor = [UIColor waveColor].CGColor;
    self.acceptButton.enabled = YES;
    
    if (!self.viewModel.relationship && ![CSTValidateHelper isPhoneNumberValid:self.mateIDTextField.text] ) {
        self.inviteOrCancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.inviteOrCancelButton.enabled = NO;
    }else{
        self.inviteOrCancelButton.layer.borderColor = [UIColor waveColor].CGColor;
        self.inviteOrCancelButton.enabled = YES;
    }
    
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
    
    if (button == self.inviteOrCancelButton){
        
        if (!self.viewModel.relationship) {
            [button setTitle:@"发送邀请" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"取消邀请" forState:UIControlStateNormal];
        }
    }else if (button == self.refuseButton){
        [button setTitle:@"拒绝" forState:UIControlStateNormal];
    }else if (button == self.acceptButton){
        [button setTitle:@"同意" forState:UIControlStateNormal];
    }
    
    self.navigationController.view.userInteractionEnabled = YES;
}


- (void)p_disableUserInteractionWithButton:(UIButton *)button
{
    
    [button setTitle:@"" forState:UIControlStateNormal];
    
    self.indicatorView.center = CGPointMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds));
    [button addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    
    self.inviteOrCancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inviteOrCancelButton.enabled = NO;
    
    self.refuseButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.refuseButton.enabled = NO;
    
    self.acceptButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.acceptButton.enabled = NO;
    
    self.navigationController.view.userInteractionEnabled = NO;
    
}



#pragma mark Setters and getters

- (CSTWillBindMateViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTWillBindMateViewModel alloc] init];
    }
    return _viewModel;
}

- (UITapGestureRecognizer *)tap{
    
    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] init];
        
        @weakify(self);
        
        [[_tap rac_gestureSignal]subscribeNext:^(id x) {
            
            @strongify(self);
            
            [self cst_dismissKeyboard];
        }];
    }
    
    return _tap;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _indicatorView;
}



@end
