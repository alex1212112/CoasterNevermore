//
//  CSTMateProfileViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/3.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTMateProfileViewController.h"
#import "Colours.h"
#import "CSTMateProfileViewModel.h"
#import "CSTRelationship.h"
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import "CSTValidateHelper.h"

#import "UIViewController+CSTDismissKeyboard.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CSTMateProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstBindDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bindDaysLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UITextField *mateIDTextField;

@property (weak, nonatomic) IBOutlet UIImageView *mateIDTextFieldLineView;

@property (weak, nonatomic) IBOutlet UIImageView *leftTopLineView;

@property (weak, nonatomic) IBOutlet UIImageView *rightTopLineView;

@property (weak, nonatomic) IBOutlet UIImageView *leftBottomLineView;

@property (weak, nonatomic) IBOutlet UIImageView *rightBottomLineView;
@property (weak, nonatomic) IBOutlet UILabel *bindDateDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bindDaysDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *inviteOrCancelButton;

@property (weak, nonatomic) IBOutlet UILabel *inviteDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *refuseButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;

@end


@implementation CSTMateProfileViewController

#pragma mark - Life cycle

- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configNavigationBar];
    [self p_configSubviews];
    [self.view addGestureRecognizer:self.tap];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    [self p_configAvatarImageViewAfterViewdidlayout];
}

#pragma mark - Public method

- (void)refreshCurrentPageData{
    
    [self.viewModel refreshCurrentPageData];
}

#pragma mark - Private method

- (void)p_configNavigationBar{

    self.navigationItem.title = @"伴侣资料";

}

- (void)p_configSubviews{

    [self p_configDeleteButton];
    [self p_configBottomView];
    [self p_configUsernameLabel];
    [self p_configNicknameLabel];
    [self p_configFirstBindDateLabel];
    [self p_configbBindDaysLabel];
    [self p_configAvatarImageViewAferViewDidLoad];
    [self p_configInviteOrCancelButton];
    [self p_configInviteDescriptionLabel];
    [self p_configMateIDTextField];
    [self p_configRefuseButton];
    [self p_configAcceptButton];
    
    [self p_configObserverWithHasMate];
}

- (void)p_configDeleteButton{

    self.deleteButton.layer.cornerRadius = 22.0;
    self.deleteButton.layer.borderWidth = 1.0;
    self.deleteButton.layer.borderColor = [UIColor colorFromHexString:@"FF7570"].CGColor;
    
    @weakify(self);
    self.deleteButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        [self p_disableUserInteractionWithButton:self.deleteButton];
        
        return [[[self.viewModel deleteRelationshipSignal] doNext:^(id x) {
            
            [self p_enanbleUserInteractionWithButton:self.deleteButton];
            
        }] doError:^(NSError *error) {
            
             [self p_enanbleUserInteractionWithButton:self.deleteButton];
        }];
    }];
}

- (void)p_configAvatarImageViewAfterViewdidlayout{

    self.avatarImageView.layer.cornerRadius = CGRectGetMidX(self.avatarImageView.bounds);
    self.avatarImageView.layer.masksToBounds = YES;
    
}
- (void)p_configAvatarImageViewAferViewDidLoad{

    RAC(self.avatarImageView,image) = RACObserve(self.viewModel,avatarImage);
}

- (void)p_configBottomView{


    self.bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomView.layer.shadowOffset = CGSizeMake(0.0, -0.5);
    self.bottomView.layer.shadowOpacity = 0.1;
}

- (void)p_configUsernameLabel{

    RAC(self.usernameLabel,text) = RACObserve(self.viewModel,mateUsername);
}
- (void)p_configNicknameLabel{
    
    RAC(self.nicknameLabel,text) = RACObserve(self.viewModel,mateNickname);
}
- (void)p_configFirstBindDateLabel{
    
    RAC(self.firstBindDateLabel,text) = RACObserve(self.viewModel,startDateString);
}
- (void)p_configbBindDaysLabel{
    
    RAC(self.bindDaysLabel,text) = RACObserve(self.viewModel,shareDaysString);
}

- (void)p_configInviteOrCancelButton{
    
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

- (void)p_configMateIDTextField{

    @weakify(self);
    [[RACObserve(self.viewModel, relationship) map:^id(id value) {
       
        return @(value ? YES : NO);
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        
        self.mateIDTextField.hidden = [x boolValue];
        self.mateIDTextFieldLineView.hidden = [x boolValue];
    }];
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

- (void)p_configObserverWithHasMate{

    @weakify(self);
    [RACObserve(self.viewModel, hasMate) subscribeNext:^(id x) {
        @strongify(self);
        
        if ([x boolValue]) {
            
            self.leftTopLineView.hidden = NO;
            self.leftBottomLineView.hidden = NO;
            self.rightBottomLineView.hidden = NO;
            self.rightTopLineView.hidden = NO;
            self.bindDateDescriptionLabel.hidden = NO;
            self.bindDaysDescriptionLabel.hidden = NO;
            self.firstBindDateLabel.hidden = NO;
            self.bindDaysLabel.hidden = NO;
            self.bottomView.hidden = NO;
        }else
        {
            self.leftTopLineView.hidden = YES;
            self.leftBottomLineView.hidden = YES;
            self.rightBottomLineView.hidden = YES;
            self.rightTopLineView.hidden = YES;
            self.bindDateDescriptionLabel.hidden = YES;
            self.bindDaysDescriptionLabel.hidden = YES;
            self.firstBindDateLabel.hidden = YES;
            self.bindDaysLabel.hidden = YES;
            self.bottomView.hidden = YES;
        }
    }];
}


- (void)p_enanbleUserInteractionWithButton:(UIButton *)button
{
    self.deleteButton.layer.borderColor = [UIColor colorFromHexString:@"FF7570"].CGColor;
    self.deleteButton.enabled = YES;
    
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
    
    if (button == self.deleteButton) {
        [button setTitle:@"解除绑定" forState:UIControlStateNormal];
    }else if (button == self.inviteOrCancelButton){
    
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
    
    self.deleteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.deleteButton.enabled = NO;
    
    self.inviteOrCancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inviteOrCancelButton.enabled = NO;
    
    self.refuseButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.refuseButton.enabled = NO;
    
    self.acceptButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.acceptButton.enabled = NO;
    
    self.navigationController.view.userInteractionEnabled = NO;
    
}



#pragma mark - Setters and getters

- (CSTMateProfileViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTMateProfileViewModel alloc] init];
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

@end
