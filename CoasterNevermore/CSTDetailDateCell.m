//
//  CSTDetailDateCell.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDetailDateCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSDate+CSTTransformString.h"
#import "Colours.h"
#import "CSTIOSDevice.h"

@interface CSTDetailDateCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *circleImageView;

@end

@implementation CSTDetailDateCell

#pragma mark - Life cycle

- (void)awakeFromNib{
    
    [super awakeFromNib];
    [self p_configTitleLabel];
    [self p_configCircleImageView];
    
}

- (void)didMoveToSuperview{

    [super didMoveToSuperview];
    [self setNeedsLayout];
    [self layoutSubviews];
}



#pragma mark - Private method

- (void)p_configTitleLabel{
    
    if ([CSTIOSDevice isIPhone5]) {
        
        self.titleLabel.font = [UIFont systemFontOfSize:7.0];
    }else if ([CSTIOSDevice isIPhone6]){
    
        self.titleLabel.font = [UIFont systemFontOfSize:9.0];
    }else{
    
        self.titleLabel.font = [UIFont systemFontOfSize:11.0];
    }

    self.titleLabel.textColor = [UIColor darkGrayColor];
    
    RAC(self.titleLabel,text) = [RACObserve(self, date) map:^id(id value) {
        
        return [value cst_stringWithFormat:@"MM-dd"];
    }];
}

- (void)p_configCircleImageView{

    self.circleImageView.layer.cornerRadius = 3.0;
    self.circleImageView.backgroundColor = [UIColor colorFromHexString:@"15aaf2"];

    self.circleImageView.hidden = YES;
}


#pragma mark - Setters and getters



- (void)setTitleColor:(UIColor *)titleColor{

    if (_titleColor != titleColor) {
        
        _titleColor = titleColor;
        self.titleLabel.textColor = titleColor;
    }
}

- (void)setShouldShowCircleView:(BOOL)shouldShowCircleView{

    _shouldShowCircleView = shouldShowCircleView;
    self.circleImageView.hidden = !_shouldShowCircleView;
}

@end
