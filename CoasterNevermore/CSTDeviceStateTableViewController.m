//
//  CSTDeviceStateTableViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/2.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDeviceStateTableViewController.h"
#import "Colours.h"
#import "CSTDeviceStateTableViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "DXAlertView.h"
#import "CSTBLEConnectViewController.h"
#import "CSTRouter.h"

@interface CSTDeviceStateTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *firmwareUpdateButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteDeviceButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *deviceIdDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *operationStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firmwareNeedUpdateImageView;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation CSTDeviceStateTableViewController


#pragma mark - Life cycle

- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configNavigationBar];
    [self p_configSubViews];
    
}

#pragma mark - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        
        return 62.0 / 667.0 * CGRectGetHeight([UIScreen mainScreen].bounds);
    }
    return  50.0 / 667.0 * CGRectGetHeight([UIScreen mainScreen].bounds);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Event Response

- (void)p_backItemClicked:(id)sender{

    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Private method


- (void)p_configNavigationBar{
    
    self.navigationItem.title = @"我的Coaster";
    
    NSInteger viewControllerCount = [self.navigationController.viewControllers count];
    if ([self.navigationController.viewControllers[viewControllerCount - 2] isKindOfClass:[CSTBLEConnectViewController class]]) {
        
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(p_backItemClicked:)];
    }
    
}


- (void)p_configSubViews{

    [self p_configTableView];
    [self p_configTableHeaderView];
    [self p_configTableFooterView];
    [self p_configfirmwareUpdateButton];
    [self p_configBottomView];
    [self p_configDeviceIDLabel];
    [self p_configOperationStateLabel];
    [self p_configPowerStateLabel];
    [self p_configConnectionStateLabel];
    [self p_configfirmwareVersionLabel];
    [self p_configFirmwareNeedUpdateImageView];
    [self p_configDeleteDeviceButton];

}


- (void)p_configTableView{

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.scrollEnabled = NO;
}

- (void)p_configTableHeaderView{

    
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    
    self.tableView.tableHeaderView.frame = (CGRect){
        .origin.x = 0.0f,
        .origin.y = 0.0,
        .size.width =  CGRectGetWidth(self.view.bounds),
        .size.height = height * 230.0 / 667.0,
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

- (void)p_configfirmwareUpdateButton{

    self.firmwareUpdateButton.layer.cornerRadius = 22.0;
    self.firmwareUpdateButton.layer.borderColor = [UIColor waveColor].CGColor;
    self.firmwareUpdateButton.layer.borderWidth = 1.0;
    
    
    @weakify(self)
    RACSignal *signal =[[self.viewModel networkAndBLEConnectionSignal]doNext:^(id x) {
        
        @strongify(self);
        
        self.firmwareUpdateButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
    }];
    
    self.firmwareUpdateButton.rac_command = [[RACCommand alloc] initWithEnabled:signal signalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        
        [self p_disableUserInterfaceWithButton:self.firmwareUpdateButton];
        return [[[self.viewModel verifyFirmwareVersionNeedUpdateSignal] doNext:^(id x) {
            
            if ([x boolValue]) {
                
                DXAlertView *alert =  [self p_showAlertViewWithTitle:@"发现新版本" titleColor:[UIColor  redColor] content:@"有新的固件版本供您的Coaster使用" leftButtonTitle:@"升级" rightButtonTitle:@"暂不升级"];
                alert.leftBlock = ^{
                
                    [self.viewModel updateFirmware];
                };
                
            }else{
                [self p_showAlertViewWithTitle:@"未发现新版本" titleColor:[UIColor  redColor] content:@"您的Coaster已经是最新的版本" buttonTitle:@"确定"];
            }
            
            [self p_enableUserInterfaceWithButton:self.firmwareUpdateButton];
        
        }] doError:^(NSError *error) {
            
            [self p_showAlertViewWithTitle:@"网络错误" titleColor:[UIColor  redColor] content:@"获取网络数据错误，请检查网络是否连接正常" buttonTitle:@"确定"];
            [self p_enableUserInterfaceWithButton:self.firmwareUpdateButton];
        }];
    }];
}

- (void)p_configBottomView{
    
    
    self.bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomView.layer.shadowOffset = CGSizeMake(0.0, -0.5);
    self.bottomView.layer.shadowOpacity = 0.1;
}

- (void)p_configDeviceIDLabel{
    
    RAC(self.deviceIdDataLabel,text) = RACObserve(self.viewModel, deviceIDString);
}

- (void)p_configOperationStateLabel{

    RAC(self.operationStateLabel,text) = RACObserve(self.viewModel, operationStateString);
}

- (void)p_configPowerStateLabel{
    
    RAC(self.batteryStateLabel,text) = RACObserve(self.viewModel, batteryStateString);
}

- (void)p_configConnectionStateLabel{
    
    RAC(self.connectStateLabel,text) = RACObserve(self.viewModel, connectStateString);
}

- (void)p_configfirmwareVersionLabel{
    
    RAC(self.firmwareVersionLabel,text) = RACObserve(self.viewModel, firmwareVersionString);
}

- (void)p_configFirmwareNeedUpdateImageView{


    RAC(self.firmwareNeedUpdateImageView,hidden) = [RACObserve(self.viewModel, isFirmwareNeedUpdate) map:^id(id value) {
        
        return @(![value boolValue]);
    }];
}

- (void)p_configDeleteDeviceButton{
    
    @weakify(self);

    RACSignal *signal =[self.viewModel verifyDeleteDeviceSignal];
    
    self.deleteDeviceButton.rac_command = [[RACCommand alloc] initWithEnabled:signal signalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        
        [self p_disableUserInterfaceWithButton:self.deleteDeviceButton];
        return [[[self.viewModel deleteDeviceSignal] doNext:^(id x) {
            
            [CSTRouter routerToBLEConnectViewControllerFromDeviceStateTableViewController:self];
            [self p_enableUserInterfaceWithButton:self.deleteDeviceButton];
            
        }] doError:^(NSError *error) {
            
            [self p_showAlertViewWithTitle:@"解除绑定失败" titleColor:[UIColor  redColor] content:@"解除绑定失败，有可能网络出现问题，请检查网络病稍后再试" buttonTitle:@"确定"];
            [self p_enableUserInterfaceWithButton:self.deleteDeviceButton];
        }];
    }];
}


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

- (void)p_disableUserInterfaceWithButton:(UIButton *)button{
    
    if (button == self.firmwareUpdateButton) {
    
        [self.firmwareUpdateButton setTitle:@"" forState:UIControlStateNormal];
        
        self.indicatorView.center = CGPointMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds));
        [self.firmwareUpdateButton addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
        
    }else if (button == self.deleteDeviceButton) {
    
        self.indicatorView.center = CGPointMake(CGRectGetMidX(button.frame), CGRectGetMidY(button.frame));
        [self.deleteDeviceButton.superview addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
        self.deleteDeviceButton.hidden = YES;
    }
    
    self.deleteDeviceButton.enabled = NO;
    self.firmwareUpdateButton.enabled = NO;
    self.firmwareUpdateButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.navigationController.view.userInteractionEnabled = NO;

}


- (void)p_enableUserInterfaceWithButton:(UIButton *)button{
    
    if (button == self.firmwareUpdateButton) {
        [self.firmwareUpdateButton setTitle:@"固件更新" forState:UIControlStateNormal];
        
        
    }else if (button == self.deleteDeviceButton) {
        self.deleteDeviceButton.hidden = NO;
    }
    
    [self.indicatorView removeFromSuperview];
    [self.indicatorView stopAnimating];
    
    self.deleteDeviceButton.enabled = NO;
    self.firmwareUpdateButton.enabled = NO;
    
    @weakify(self);
    [[self.viewModel verifyDeleteDeviceSignal] subscribeNext:^(id x) {
        
        @strongify(self);
           self.deleteDeviceButton.enabled = [x boolValue];
    }];
    
    [[self.viewModel networkAndBLEConnectionSignal] subscribeNext:^(id x) {
       
        @strongify(self);
        self.firmwareUpdateButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
        self.firmwareUpdateButton.enabled = [x boolValue];
        
    }];
    
    self.navigationController.view.userInteractionEnabled = YES;
}



#pragma mark - Setters and getters

- (CSTDeviceStateTableViewModel *)viewModel{
    
    if (!_viewModel) {
        
        _viewModel = [[CSTDeviceStateTableViewModel alloc] init];
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
@end
