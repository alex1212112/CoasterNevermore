//
//  CSTUserCenterTableViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/1.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserCenterTableViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTRouter.h"
#import "CSTDataManager.h"
#import "CSTUserCenterTableViewModel.h"

@interface CSTUserCenterTableViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinsLabel;
@property (weak, nonatomic) IBOutlet UIButton *coinDetailButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;

@property (strong, nonatomic) UITapGestureRecognizer *avatarTap;

@end

@implementation CSTUserCenterTableViewController


#pragma mark - Life cycle

- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configTableHeaderView];
    [self p_configTableFooterView];
    [self p_configTableView];
    [self p_configEventWithSignoutButton];
    [self p_configAvatarViewAfterViewDidLoad];
    [self p_configUsernameLabel];
    [self p_configNicknameLabel];
    [self p_configAvatarView];
    [self p_configCoinsLabel];
    [self p_configEditButton];
    [self p_refreshCurrentPageData];
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    [self p_configAvatarViewAfterViewDidLayout];

}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 3;
}


#pragma mark - TableView Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        if ([self.viewModel isUserOwnDevice]) {
            [CSTRouter routerToDeviceViewControllerFromUserCenterTableViewController:self];
        }else{
            
            [CSTRouter routerToBLEConnectViewControllerFromUserCenterTableViewController:self];
        }
    }else if (indexPath.row == 2){
    
        [CSTRouter routerToAboutUsViewControllerFromUserCenterTableViewController:self];
    }else if (indexPath.row == 1){
    
           [CSTRouter routerToMateProfileViewControllerFromUserCenterTableViewController:self];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

     
    return 60.0f;
}


#pragma mark - Event response


- (void)p_configEventWithSignoutButton{
    
    
    @weakify(self);
    [[self.signoutButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);

        [CSTRouter routerToViewControllerType:CSTRouterViewControllerTypeLogin fromViewController:self.parentViewController];
        
        [CSTDataManager removeAllData];
    }];
    
}

- (void)p_configEventWithAvatarTap:(UITapGestureRecognizer *)tap{

    @weakify(self);
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [CSTRouter routerToUserProfileViewControllerFromUserCenterTableViewController:self];
        
    }];
    
}

#pragma mark - Private method


- (void)p_configTableView{

    self.tableView.scrollEnabled = NO;
    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tableView.layer.shadowOffset = CGSizeMake(1.0, 0);
    self.tableView.layer.shadowOpacity = 0.3;
    self.tableView.layer.masksToBounds = NO;
}

- (void)p_configTableHeaderView{
    
    self.tableView.tableHeaderView.frame = (CGRect){
        .origin.x = 0.0f,
        .origin.y = 0.0,
        .size.width =  CGRectGetWidth(self.view.bounds),
        .size.height = 250,
    };
}

- (void)p_configTableFooterView{
    
    CGRect rect = [self.tableView rectForSection:0];
    
    CGFloat footerHeight = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(rect) - CGRectGetHeight(self.tableView.tableHeaderView.bounds);
    
    self.tableView.tableFooterView.frame = (CGRect){
        .origin.x = 0.0f,
        .origin.y = 0.0,
        .size.width =  CGRectGetWidth(self.view.bounds),
        .size.height = footerHeight,
    };
    
    self.tableView.tableFooterView = nil;
    
    self.footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = self.footerView;
}

- (void)p_configAvatarViewAfterViewDidLayout{

    self.avatarView.layer.cornerRadius = CGRectGetMidX(self.avatarView.bounds);
    self.avatarView.layer.masksToBounds = YES;
}

- (void)p_configAvatarViewAfterViewDidLoad{

    self.avatarView.userInteractionEnabled = YES;
    [self.avatarView addGestureRecognizer:self.avatarTap];
}

- (void)p_configEditButton{
    
    //self.editButton.hidden = YES;
    
    [[self.editButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [CSTRouter routerToUserProfileViewControllerFromUserCenterTableViewController:self];
    }];
}

- (void)p_configUsernameLabel{

    RAC(self.userNameLabel,text) = RACObserve(self.viewModel ,username);
}

- (void)p_configNicknameLabel{

    RAC(self.nickNameLabel,text) = RACObserve(self.viewModel, nickname);
}

- (void)p_configAvatarView{

    RAC(self.avatarView,image) = RACObserve(self.viewModel, avatarImage);
}

- (void)p_configCoinsLabel{

    RAC(self.coinsLabel,text) = RACObserve(self.viewModel, nCointCount);
}

- (void)p_refreshCurrentPageData{

    [self.viewModel refreshCurrentPageData];
}

#pragma mark - Setters and getters

- (UITapGestureRecognizer *)avatarTap{

    if (!_avatarTap) {
        
        _avatarTap = [[UITapGestureRecognizer alloc] init];
        
        [self p_configEventWithAvatarTap:_avatarTap];
    }
    
    return _avatarTap;
}


- (CSTUserCenterTableViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTUserCenterTableViewModel alloc] init];
    }
    return _viewModel;
}

@end
