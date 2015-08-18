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

@end

@implementation CSTDetailDateCell

#pragma mark - Life cycle

- (void)awakeFromNib{

    [self p_configTitleLabel];

}


#pragma mark - Private method

- (void)p_configTitleLabel{
    
    if ([CSTIOSDevice isIPhone5]) {
        
        self.titleLabel.font = [UIFont systemFontOfSize:9.0];
    }else if ([CSTIOSDevice isIPhone6]){
    
        self.titleLabel.font = [UIFont systemFontOfSize:11.0];
    }else{
    
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
    }

    
    self.titleLabel.textColor = [UIColor darkGrayColor];
    
    RAC(self.titleLabel,text) = [RACObserve(self, date) map:^id(id value) {
        
        return [value cst_stringWithFormat:@"MM-dd"];
    }];
}

#pragma mark - Setters and getters

//- (void)setCanSelect:(BOOL)canSelect{
//
//    if (_canSelect != canSelect) {
//        
//        _canSelect = canSelect;
//        
//        if (_canSelect) {
//            
//            self.titleLabel.textColor = [UIColor darkGrayColor];
//        }else{
//            self.titleLabel.textColor = [UIColor lightGrayColor];
//        }
//    }
//}


- (void)setTitleColor:(UIColor *)titleColor{

    if (_titleColor != titleColor) {
        
        _titleColor = titleColor;
        self.titleLabel.textColor = titleColor;
    }
}
@end
