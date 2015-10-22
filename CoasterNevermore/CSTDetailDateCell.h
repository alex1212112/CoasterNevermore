//
//  CSTDetailDateCell.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTDetailDateCell : UICollectionViewCell

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) BOOL shouldShowCircleView;

@end
