//
//  CSTDetailDataViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/22.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface CSTDetailDataViewModel : NSObject

@property (nonatomic, copy) NSArray *historyDrinkArray;//处理过的历史饮水数据，插入了0值
@property (nonatomic, copy) NSArray *historyDrinkShowDateArray;//显示在collectionView 上的日期数组
@property (nonatomic, copy) NSArray *historyDrinkDetail;//历史饮水的详细信息，包括每天具体时刻的信息

@property (nonatomic, copy) NSArray *historySuggestDrink;//历史建议饮水量

@property (nonatomic, copy) NSArray *barchartDrinkArray;//某天详细饮水量的分段信息
@property (nonatomic, copy) NSArray *barchartSuggestArray;//某天建议引水量的分段信息

@property (nonatomic, copy) NSArray *barchartXTicks;
@property (nonatomic, copy) NSArray *barchartXStrings;


- (void)refreshCurrentPageData;

//从每日饮水数组获取默认选中的日期
- (NSDate *)defaultSelectedDateWithArry:(NSArray *)array;

//从每日饮水数组获取默认选中的日期在该数组中的序号
- (NSInteger)defaultSelectedIndexWithArry:(NSArray *)array;

//从每日详细饮水数组获取默认选中的日期
- (NSDate *)defaultSelectedDateWithDetailArry:(NSArray *)array;

//从每日详细饮水数组中获取给定日期的分段显示数据，总共6段
- (NSArray *)segmentArrayWithDetail:(NSArray *)detailArray inDate:(NSDate *)date;

//从建议饮水数组中获取给定日期的分段显示数据，总共6段
- (NSArray *)segmentArraywithSuggests:(NSArray *)suggests inDate:(NSDate *)date;

- (NSString *)todayUserDrinkShareText;

@end
