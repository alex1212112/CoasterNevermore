//
//  CSTDetailTableViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/20.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTDetailTableViewController.h"
#import "CSTIOSDevice.h"
#import "CSTDetailTableViewModel.h"

@interface CSTDetailTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *drinkLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDrinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceUsedDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *drinkIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;

@end

@implementation CSTDetailTableViewController

#pragma mark - Life cycle
- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configSubViews];
}

- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
}


#pragma TableView datasorce


#pragma TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGRectGetHeight(self.view.bounds) / 5;
}


#pragma mark - Pravite mathod

- (void)p_configSubViews{

    [self p_configTableView];
    [self p_configDrinkLevelLabel];
    [self p_configDrinkIndexLabel];
    [self p_configTotalDrinkLabel];
    [self p_configDeviceUsedDaysLabel];
    [self p_configRankLabel];
}

- (void)p_configTableView{

    self.tableView.scrollEnabled = NO;
}


- (void)p_configDrinkLevelLabel{
    
     RAC(self.drinkLevelLabel,text) = RACObserve(self.viewModel,drinkLevel);
}
- (void)p_configTotalDrinkLabel{
    
    RAC(self.totalDrinkLabel,text) = RACObserve(self.viewModel,historyTotalDrink);
}
- (void)p_configDeviceUsedDaysLabel{
    
    RAC(self.deviceUsedDaysLabel,text) = RACObserve(self.viewModel, deviceUsedDays);
}
- (void)p_configDrinkIndexLabel{
    
    RAC(self.drinkIndexLabel,text) = RACObserve(self.viewModel,healthIndex);
}

- (void)p_configRankLabel{
    
    RAC(self.rankLabel,text) = RACObserve(self.viewModel,rankString);
}


#pragma mark - Setters and getters

- (CSTDetailTableViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTDetailTableViewModel alloc] init];
    }
    
    return _viewModel;
}

@end
