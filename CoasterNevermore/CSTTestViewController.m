//
//  CSTTestViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/18.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTTestViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTRouter.h"
#import "CSTUserToken.h"

@interface CSTTestViewController ()

@end

@implementation CSTTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:button];
    
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [NSLayoutConstraint activateConstraints:@[constraint1,constraint2]];
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [CSTUserToken removeToken];
        
        [CSTRouter routerFromViewController:self];
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
