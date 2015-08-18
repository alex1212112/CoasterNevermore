//
//  CSTRouter.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, CSTRouterViewControllerType) {
    CSTRouterViewControllerTypeLogin,
    CSTRouterViewControllerTypeMain,
};

@interface CSTRouter : NSObject

+ (instancetype)shareRouter;

// Test method
+ (void)routerFromViewController:(id)currentViewController;


+ (void)routerToViewControllerType:(CSTRouterViewControllerType)type fromViewController:(id)viewController;


+ (void)disMissViewController:(UIViewController *)presentedViewController;

+ (void)routerToMateContentViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController;

+ (void)routerToAboutUsViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController;

+ (void)routerToDeviceViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController;

+ (void)routerToMateProfileViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController;

+ (void)routerToUserProfileViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController;

+ (void)routerToBLEConnectViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController;

+ (void)routerToBLEConnectViewControllerFromDeviceStateTableViewController:(id)deviceTableViewController;

+ (void)routerToDeviceStateTableViewControllerFromBLEConnectViewController:(id)bleConnectViewController;

//+ (void)loginWithQQFromViewController:(id)loginVC;

+ (id)loginViewController;

+ (UIViewController *)appTopViewController;

+ (UIViewController *)routerToLoginViewControllerWithLogin;

+ (UIViewController *)rootViewController;


@end
