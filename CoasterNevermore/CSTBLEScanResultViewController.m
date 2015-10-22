//
//  CSTBLEScanResultViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBLEScanResultViewController.h"
#import "CSTBLEScanResultViewModel.h"
#import "CSTBLEManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTDeviceStateTableViewController.h"
#import "CSTUserAccessViewController.h"
#import "DXAlertView.h"
#import "CSTRouter.h"

@interface CSTBLEScanResultViewController () <UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *cancleButton;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIView *topLineView;
@property (strong, nonatomic) UIView *bottomLineView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) UIActivityIndicatorView *footerIndicatorView;
@property (strong, nonatomic) UIActivityIndicatorView *headerIndicatorView;
@property (strong, nonatomic) UILabel *connectStateLabel;
@end

@implementation CSTBLEScanResultViewController

#pragma mark - Life cycle

- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configSubViews];
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


#pragma mark - TableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.viewModel.deviceDescriptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSTBLEScanResultCell" forIndexPath:indexPath];
    
    [self p_configCell:cell withIndexPath:indexPath];
    
    return cell;
}


#pragma mark - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.viewModel.selectedPeriphralID) {
     
        self.viewModel.selectedPeriphralID = [self.viewModel PeriphralIDWithIndexPath:indexPath];
        [tableView reloadData];
        
        [[CSTBLEManager shareManager] bindPeripheral:self.viewModel.devices[indexPath.row] Options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES, CBConnectPeripheralOptionNotifyOnNotificationKey : @YES} success:^{
            
            if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
                
                UINavigationController *nav = (UINavigationController *)self.presentingViewController;
                [CSTRouter routerToDeviceStateTableViewControllerFromBLEConnectViewController:nav.topViewController];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            
        } fail:^(NSError *error){
            
            if (error.code != CSTBLEBindErrorTargetIsBindedCode || error.code != CSTBLEBindErrorUnknowCode) {
                
                [self p_showAlertViewWithTitle:@"绑定失败" titleColor:[UIColor redColor] content:error.userInfo[CSTBLEBindErrorReasonKey] buttonTitle:@"确定"];
            }else{
            
                [self p_showAlertViewWithTitle:@"网络错误" titleColor:[UIColor redColor] content:@"服务器通信异常，有可能您的网络出现了问题，请检查您的网络并稍后再试" buttonTitle:@"确定"];
            }
            
            self.viewModel.selectedPeriphralID = nil;
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.tableView reloadData];
}


#pragma mark - Alert

- (DXAlertView *)p_showAlertViewWithTitle:(NSString *)title titleColor:(UIColor *)titleColor content:(NSString *)content  buttonTitle:(NSString *)buttonTitle
{
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:nil rightButtonTitle:buttonTitle];
    alertView.alertTitleLabel.textColor = titleColor;
    
    [alertView show];
    
    return alertView;
    
}

- (DXAlertView *)p_showAlertViewWithTitle:(NSString *)title titleColor:(UIColor *)titleColor content:(NSString *)content  leftButtonTitle:(NSString *)leftButtonTitle rightButtonTitle:(NSString *)rightButtonTitle
{
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:leftButtonTitle rightButtonTitle:rightButtonTitle];
    
    alertView.alertTitleLabel.textColor = titleColor;
    
    [alertView show];
    
    return alertView;
}


#pragma mark - Private method

- (void)p_configCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *dic = self.viewModel.deviceDescriptions[indexPath.row];
    
    cell.textLabel.text = dic[@"title"];
    cell.backgroundColor = [UIColor clearColor];
    
    if (self.viewModel.selectedPeriphralID) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    
    if ([[self.viewModel PeriphralIDWithIndexPath:indexPath] isEqualToString:self.viewModel.selectedPeriphralID]) {
        
        cell.accessoryView = self.indicatorView;
        [self.indicatorView startAnimating];
        cell.detailTextLabel.text = nil;
    }else{
        cell.accessoryView = nil;
        cell.detailTextLabel.text = dic[@"detail"];
    }
}


- (void)p_configSubViews{

    [self p_configTableView];
    [self p_configFooterView];
    [self p_configHeaderView];
}

- (void)p_configTableView{

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;

    self.tableView.contentInset = UIEdgeInsetsMake(85.0, 0.0, 0.0, 0.0);

    @weakify(self);
    [RACObserve(self.viewModel, deviceDescriptions) subscribeNext:^(id x) {
        @strongify(self);
        
        if (!self.tableView.dragging && !self.tableView.decelerating && !self.viewModel.selectedPeriphralID) {
         
              [self.tableView reloadData];
        }
    }];
}

- (void)p_configFooterView{

    self.cancleButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.footerView.bounds));
    [self.footerView addSubview:self.cancleButton];
    
    self.connectStateLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds) + CGRectGetWidth(self.footerIndicatorView.bounds) / 2 + 10.0, CGRectGetMidY(self.footerView.bounds));
    [self.footerView addSubview:self.connectStateLabel];
    self.connectStateLabel.hidden = YES;
    
    
    CGFloat stringWidth = [self.viewModel widthWithConnectStateString:self.connectStateLabel.text Font:self.connectStateLabel.font];
    
    self.footerIndicatorView.center =  CGPointMake(CGRectGetMidX(self.view.bounds) - stringWidth / 2 + 5.0 , CGRectGetMidY(self.footerView.bounds));
    [self.footerView addSubview:self.footerIndicatorView];
    self.footerIndicatorView.hidden = YES;
    
    @weakify(self);
    [[RACObserve(self.viewModel, selectedPeriphralID) map:^id(id value) {
        
        return value ? @YES : @NO;
        
    }] subscribeNext:^(id x) {
        @strongify(self);
        
        self.connectStateLabel.hidden = ![x boolValue];
        self.cancleButton.hidden = [x boolValue];
        if ([x boolValue]) {
            
            self.footerIndicatorView.hidden = NO;
            [self.footerIndicatorView startAnimating];
        }else{
            self.footerIndicatorView.hidden = YES;
            [self.footerIndicatorView stopAnimating];
        }
    }];
    
    self.bottomLineView.center = CGPointMake(CGRectGetMidX(self.view.bounds) + 8.0, 0.0);
    [self.footerView addSubview:self.bottomLineView];
}

- (void)p_configHeaderView{

    self.headerLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.headerView.bounds) - CGRectGetMidY(self.headerLabel.bounds));
    [self.headerView addSubview:self.headerLabel];
    
    self.topLineView.center = CGPointMake(CGRectGetMidX(self.view.bounds) + 8.0, CGRectGetMaxY(self.headerView.bounds) - 0.25);
    [self.headerView addSubview:self.topLineView];
    
    self.headerIndicatorView.center = CGPointMake(CGRectGetMaxX(self.view.bounds) - 15.0, CGRectGetHeight(self.headerView.bounds) - CGRectGetMidY(self.headerLabel.bounds));
    
    [self.headerView addSubview:self.headerIndicatorView];
    
    @weakify(self);
    
    [[RACSignal combineLatest:@[self.viewModel.bleCentralManagerOnsignal,self.viewModel.deviceDescriptionsSignal] reduce:^id(NSNumber *bleManagerOn, NSNumber *devicesNotNull){
        
        if ([bleManagerOn boolValue]  && [devicesNotNull boolValue]) {
            return @1;
        }else if([bleManagerOn boolValue]  && ![devicesNotNull boolValue]){
            return @0;
        }else {
            return @-1;
        }
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        if ([x integerValue] == 0) {
            
            self.headerIndicatorView.hidden = NO;
            [self.headerIndicatorView startAnimating];
            self.headerLabel.text = @"扫描结果列表";
        }else if([x integerValue] == 1){
            
            self.headerIndicatorView.hidden = YES;
            self.headerLabel.text = @"扫描结果列表";
        }else {
            self.headerLabel.text = @"系统蓝牙未开启";
            self.headerIndicatorView.hidden = YES;
        }
    }];
}

#pragma mark - Event response

- (void)p_configEventWithCancelButton:(UIButton *)button{

    @weakify(self);
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        [self.delegate userDidCancelScan];
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];

}


#pragma mark - Setters and getters

- (CSTBLEScanResultViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTBLEScanResultViewModel alloc] init];
    }
    
    return _viewModel;
}

- (UIView *)footerView{

    if (!_footerView) {
        
        _footerView = [[UIView alloc] initWithFrame:(CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width =  CGRectGetWidth(self.view.bounds),
            .size.height = 100,
        }];
        
        _footerView.backgroundColor = [UIColor clearColor];
    }
    
    return _footerView;
}

- (UIButton *)cancleButton{

    if (!_cancleButton) {
        
        _cancleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        _cancleButton.bounds = (CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width =  30.0,
            .size.height = 30.0,
        };
        _cancleButton.tintColor = [UIColor whiteColor];
        [_cancleButton setImage:[UIImage imageNamed:@"BLEScanXIcon"] forState:UIControlStateNormal];
        
        [self p_configEventWithCancelButton:_cancleButton];
    }
    
    return _cancleButton;
}

- (UIView *)headerView{
    
    if (!_headerView) {
        
        _headerView = [[UIView alloc] initWithFrame:(CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width =  CGRectGetWidth(self.view.bounds),
            .size.height = 30.0,
        }];
        
        _headerView.backgroundColor = [UIColor clearColor];
    }
    
    return _headerView;
}

- (UILabel *)headerLabel{
    
    if (!_headerLabel) {
        
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.textColor = [UIColor whiteColor];
        _headerLabel.text = @"扫描结果列表";
        _headerLabel.font = [UIFont systemFontOfSize:13.0];
        
        _headerLabel.bounds = (CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width = CGRectGetWidth(self.view.bounds) - 32.0,
            .size.height = 30.0,
        };
    }
    
    return _headerLabel;
}


- (UIView *)topLineView{
    
    if (!_topLineView) {
        
        _topLineView = [[UIView alloc] init];
        _topLineView.bounds = (CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width = CGRectGetWidth(self.view.bounds) - 16.0,
            .size.height = 0.5,
        };
        _topLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    return _topLineView;

}

- (UIView *)bottomLineView{
    
    if (!_bottomLineView) {
        
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.bounds = (CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width =  CGRectGetWidth(self.view.bounds) - 16.0,
            .size.height = 0.5,
        };
        _bottomLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    return _bottomLineView;
    
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    return _indicatorView;
}

- (UIActivityIndicatorView *)footerIndicatorView
{
    if (!_footerIndicatorView)
    {
        _footerIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _footerIndicatorView.hidesWhenStopped = YES;
    }
    
    return _footerIndicatorView;
}

- (UIActivityIndicatorView *)headerIndicatorView
{
    if (!_headerIndicatorView)
    {
        _headerIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _headerIndicatorView.hidesWhenStopped = YES;
    }
    
    return _headerIndicatorView;
}


- (UILabel *)connectStateLabel{

    if (!_connectStateLabel) {
        
        _connectStateLabel = [[UILabel alloc] init];
        _connectStateLabel.textColor = [UIColor lightGrayColor];
        _connectStateLabel.text = @"正在绑定...";
        _connectStateLabel.font = [UIFont systemFontOfSize:17.0];
        _connectStateLabel.textAlignment = NSTextAlignmentCenter;
        
        _connectStateLabel.bounds = (CGRect){
            .origin.x = 0.0f,
            .origin.y = 0.0,
            .size.width =   CGRectGetWidth(self.view.bounds),
            .size.height = 30.0,
        };
    }
    
    return _connectStateLabel;
}


@end
