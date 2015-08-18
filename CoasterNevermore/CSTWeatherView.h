//
//  CSTWeatherView.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/13.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTWeatherView : UIView


@property (nonatomic, copy) NSString *addressText;
@property (nonatomic, copy) NSString *weatherDescription;
@property (nonatomic, copy) NSString *tempratureText;
@property (nonatomic, copy) NSString *humidityText;
@property (nonatomic, copy) NSString *aqiText;

@property (nonatomic, strong) UIImage *weatherIconImage;

- (void)show;

- (void)dismiss;

@end
