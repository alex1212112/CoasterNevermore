//
//  CSTBLEScanResultViewModel.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;
@class RACSignal;

@interface CSTBLEScanResultViewModel : NSObject

@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, strong) NSArray *deviceDescriptions;
@property (nonatomic, strong) NSString *selectedPeriphralID;

- (NSString *)PeriphralIDWithIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)widthWithConnectStateString:(NSString *)string Font:(UIFont *)font;

- (RACSignal *)bleCentralManagerOnsignal;

- (RACSignal *)deviceDescriptionsSignal;


@end
