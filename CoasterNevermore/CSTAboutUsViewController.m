//
//  CSTAboutUsViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/2.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTAboutUsViewController.h"
#import "Colours.h"
#import "CSTMessageBox.h"
#import "CSTAPIBaseManager.h"
#import "CSTAboutUsViewModel.h"
#import "MBProgressHUD.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CSTAboutUsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *wechatButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *introduceButton;
@property (weak, nonatomic) IBOutlet UIButton *suggestButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end


@implementation CSTAboutUsViewController

#pragma mark - Life cycle

- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configSubViews];
    [self p_configNavigationBar];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}




#pragma mark - Private method


- (void)p_configNavigationBar{

    self.navigationItem.title = @"关于我们";
}

- (void)p_configSubViews{

    [self p_configWechatButton];
    [self p_configRateButton];
    [self p_configIntroduceButton];
    [self p_configSuggestButton];
    [self p_configVersionLabel];
    
}

- (void)p_configWechatButton{

    self.wechatButton.layer.cornerRadius = 22.0;
    self.wechatButton.layer.borderWidth = 1.0;
    self.wechatButton.layer.borderColor = [UIColor waveColor].CGColor;
}

- (void)p_configRateButton{
    
    self.rateButton.layer.cornerRadius = 22.0;
    self.rateButton.layer.borderWidth = 1.0;
    self.rateButton.layer.borderColor = [UIColor waveColor].CGColor;
    [[self.rateButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%ld&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",(long)938106799];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }];
}


- (void)p_configIntroduceButton{
    
    self.introduceButton.layer.cornerRadius = 22.0;
    self.introduceButton.layer.borderWidth = 1.0;
    self.introduceButton.layer.borderColor = [UIColor waveColor].CGColor;
    [[self.introduceButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.nevermore.cn"]];
    }];
}


- (void)p_configSuggestButton{
    
    self.suggestButton.layer.cornerRadius = 22.0;
    self.suggestButton.layer.borderWidth = 1.0;
    self.suggestButton.layer.borderColor = [UIColor waveColor].CGColor;
    
    @weakify(self);
    [[self.suggestButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {

        
        CSTMessageBox *messageBox = [CSTMessageBox showInView:self.navigationController.view];
        messageBox.content = @"";
        messageBox.title = @"帮助与反馈";
        
        @weakify(messageBox);
        messageBox.doneBlock = ^{
            
            @strongify(self);
            @strongify(messageBox);
            
            if (messageBox.content.length == 0) {
                
                return ;
            }
            
            
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
            HUD.removeFromSuperViewOnHide = YES;
            [[UIApplication sharedApplication].keyWindow addSubview:HUD];
            [HUD show:YES];
            
            [[self.viewModel feedbackSignalWithContent:messageBox.content] subscribeNext:^(id x) {
                
                HUD.mode = MBProgressHUDModeCustomView;;
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MBPCheckmark"]];
                HUD.labelText = @"非常感谢您的支持";
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
                
                dispatch_after(time, dispatch_get_main_queue(), ^{
                
                    [HUD hide:YES];
                });
                
            }error:^(NSError *error) {
                
                HUD.mode = MBProgressHUDModeCustomView;;
                HUD.labelText = @"发送失败";
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
                
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                });
            }];
        };
    }];
}

- (void)p_configVersionLabel{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
   self.versionLabel.text = [NSString stringWithFormat:@"Version %@",infoDictionary[@"CFBundleShortVersionString"]];
}

#pragma mark - Setters and getters

- (CSTAboutUsViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTAboutUsViewModel alloc] init];
    }
    
    return _viewModel;
}

@end
