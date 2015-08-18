//
//  CSTWebViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/12.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTWebViewController.h"
#import <NSArray+LinqExtensions.h>
#import "Colours.h"
@import WebKit;

@interface CSTWebViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSArray *webViewLayoutConstraints;

@end

@implementation CSTWebViewController

#pragma mark - Life cycle
- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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


#pragma mark - Private method
- (void)p_configSubviews{
    [self p_configNavigationBar];
    [self p_configWebView];
}

- (void)p_configNavigationBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromRGBAArray:@[@0,@(185.0 / 255.0),@(249.0/255.0),@1]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]
                                                                    };
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"用户协议";
    
}

- (void)p_configWebView{

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
    [self p_configWebViewLayout];
    
    self.webView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.scalesPageToFit = YES;

    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NevermoreProtocol" ofType:@"doc"];
    
    [self p_loadFile:filePath inView:self.webView];
}

-(void)p_loadFile:(NSString*)filePath inView:(UIWebView *)webView
{
    NSString *utf8String = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:utf8String];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

#pragma mark - NSLayout constraints

- (void)p_configWebViewLayout{

    UIWebView *webView = self.webView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(webView);
    
    NSString *vfv = @"V:|-0-[webView]-0-|";
    NSString *vfh = @"H:|-0-[webView]-0-|";
    
    
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:vfv options:0 metrics:nil views:viewsDictionary];
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:vfh options:0 metrics:nil views:viewsDictionary];
    [NSLayoutConstraint activateConstraints:constraintsV];
    [NSLayoutConstraint activateConstraints:constraintsH];
}


#pragma mark - Setters and getters

- (UIWebView *)webView{

    if (!_webView) {
        
        _webView = [[UIWebView alloc] init];
    }
    
    return _webView;
}
@end
