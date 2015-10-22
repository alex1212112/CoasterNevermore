//
//  CSTRouter.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/17.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTRouter.h"
#import "CSTUserAccessViewController.h"
#import "CSTMainDataViewController.h"
#import "CSTMainContentViewController.h"
#import "CSTUserCenterTableViewController.h"
#import "CSTAboutUsViewController.h"
#import "CSTDeviceStateTableViewController.h"
#import "CSTMateProfileViewController.h"
#import "CSTUserProfileViewController.h"
#import "CSTBLEConnectViewController.h"
#import "CSTDataManager.h"
#import "DXAlertView.h"
#import "CSTUserProfile.h"

#import "CSTRelationship+CSTNetworkSignal.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation CSTRouter

static CSTRouter *instance = nil;

#pragma mark - Life cycle
+ (instancetype)shareRouter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self p_configObservers];
    }
    return self;
}

#pragma mark - Observers

- (void)p_configObservers{

    [self p_configObserverWithRelationship];
}
- (void)p_configObserverWithRelationship{

    [[RACObserve([CSTDataManager shareManager], relationship) distinctUntilChanged] subscribeNext:^(id x) {
        
        UIViewController *vc = [CSTRouter appTopViewController];
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)vc;
            
            UIViewController *visibleVC = nav.visibleViewController;
            
            if ([visibleVC isKindOfClass:[CSTMateProfileViewController class]]) {
                
                return ;
            }
            
            if ([visibleVC isKindOfClass:[CSTMainDataViewController class]]){
                
                CSTMainDataViewController *mainDataVC = (CSTMainDataViewController *)visibleVC;
                if ([mainDataVC isShowRightViewController]) {
                    
                    return;
                }
            }
        }
        
        [self p_showAlertForRelationshipDidChanged:x];
        
    }];
}

- (void)p_showAlertForRelationshipDidChanged:(CSTRelationship *)relationship{
    
    if ([relationship.status integerValue] == 1)
    {
        if ([relationship.toUid isEqualToString:[CSTDataManager shareManager].userProfile.uid])
        {
            NSString *title = [NSString stringWithFormat:@"%@邀请您作为Ta的饮水伴侣！",relationship.fromNickname];
            
            DXAlertView *alert = [DXAlertView showAlertWithTitle:nil contentText:title leftButtonTitle:@"拒绝" rightButtonTitle:@"同意"];
            
            alert.leftBlock = ^{
                
                [[[[CSTRelationship cst_refuseRelationshipSignaFromUid:relationship.fromUid] flattenMap:^RACStream *(id value) {
                    
                    return [CSTDataManager refreshRelationshipSignal];
                    
                }] flattenMap:^RACStream *(id value) {
                    
                    return [CSTDataManager refreshMateProfileSignalWithRelationship:value];
                    
                }] subscribeNext:^(id x) {
                    
                }];
            };
            
            alert.rightBlock = ^{
                
                [[[[CSTRelationship cst_acceptRelationshipSignalFromUid:relationship.fromUid] flattenMap:^RACStream *(id value) {
                    
                    return [CSTDataManager refreshRelationshipSignal];
                }] flattenMap:^RACStream *(id value) {
                    
                    return [CSTDataManager refreshMateProfileSignalWithRelationship:value];
                    
                }] subscribeNext:^(id x) {
                    
                }];
            };
        }
    }
}


#pragma mark - Test
+ (void)routerFromViewController:(id)currentViewController
{
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *nextVC = [nav.viewControllers[0] isKindOfClass:[CSTUserAccessViewController class]] ? [[UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil] instantiateInitialViewController] :[[UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil] instantiateInitialViewController] ;
    
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[UINavigationController class]])
    {
        if ([nav.viewControllers[0] isKindOfClass:[currentViewController class]])
        {
            [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:nextVC animated:NO completion:nil];
        }
        else
        {
            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }
    else if([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[currentViewController class]])
    {
        [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:nextVC animated:NO completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
}


#pragma mark - Public method
+ (void)routerToViewControllerType:(CSTRouterViewControllerType)type fromViewController:(id)viewController{

    
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentRootViewController = nav.viewControllers[0];
    
    UIViewController *nextVC = [currentRootViewController isKindOfClass:[CSTUserAccessViewController class]] ? [[UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil] instantiateInitialViewController] :[[UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil] instantiateInitialViewController] ;
    
    if (type == CSTRouterViewControllerTypeLogin) {
        if ([currentRootViewController isKindOfClass:[CSTUserAccessViewController class]]) {
            
            [nav popToRootViewControllerAnimated:NO];
            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
        }else{
        
            [viewController presentViewController:nextVC animated:NO completion:nil];
        }
    }else{
        if ([currentRootViewController isKindOfClass:[CSTUserAccessViewController class]]) {
            
            [viewController presentViewController:nextVC animated:NO completion:nil];
        }else{
            
            [((CSTMainDataViewController *)currentRootViewController) resetOffset];
            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
        
                [currentRootViewController performSelector:@selector(refreshCurrentPageData)];
            }];
        }
    }
}


+ (void)disMissViewController:(UIViewController *)presentedViewController{

    UIViewController *presentingViewController = presentedViewController.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


+ (void)disMissViewController:(UIViewController *)presentedViewController completion:(void(^)(void))completion{
    
    UIViewController *presentingViewController = presentedViewController.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES completion:completion];
}



+ (void)routerToMateContentViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController{

    if ([userCenterTableViewController isKindOfClass:[CSTUserCenterTableViewController class]]) {
        
        CSTUserCenterTableViewController *vc = userCenterTableViewController;
        
        UINavigationController *nav = (UINavigationController *)vc.parentViewController.presentingViewController;
        CSTMainDataViewController *mainDataVC = nav.viewControllers[0];
        [mainDataVC showRightViewController];
        
        [CSTRouter disMissViewController: vc.parentViewController];
    }
}


+ (void)routerToAboutUsViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController{

    if ([userCenterTableViewController isKindOfClass:[CSTUserCenterTableViewController class]]) {
        
        CSTUserCenterTableViewController *vc = userCenterTableViewController;
        
        UINavigationController *nav = (UINavigationController *)vc.parentViewController.presentingViewController;
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        
        CSTAboutUsViewController *aboutUsVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTAboutUsViewController"];
        
        [nav pushViewController:aboutUsVC animated:NO];
        
        [CSTRouter disMissViewController: vc.parentViewController];
    }
}

+ (void)routerToDeviceViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController{

    if ([userCenterTableViewController isKindOfClass:[CSTUserCenterTableViewController class]]) {
        
        CSTUserCenterTableViewController *vc = userCenterTableViewController;
        
        UINavigationController *nav = (UINavigationController *)vc.parentViewController.presentingViewController;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        
        CSTAboutUsViewController *deviceVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTDeviceStateTableViewController"];
        
        [nav pushViewController:deviceVC animated:NO];
        
        [CSTRouter disMissViewController: vc.parentViewController];
    }
}

+ (void)routerToMateProfileViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController{


    if ([userCenterTableViewController isKindOfClass:[CSTUserCenterTableViewController class]]) {
        
        CSTUserCenterTableViewController *vc = userCenterTableViewController;
        
        UINavigationController *nav = (UINavigationController *)vc.parentViewController.presentingViewController;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        
        CSTMateProfileViewController *mateVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTMateProfileViewController"];
        
        [nav pushViewController:mateVC animated:NO];
        
        [CSTRouter disMissViewController: vc.parentViewController completion:^{
            [mateVC refreshCurrentPageData];
        }];
    }
}


+ (void)routerToUserProfileViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController{
    

    if ([userCenterTableViewController isKindOfClass:[CSTUserCenterTableViewController class]]) {
        
        CSTUserCenterTableViewController *vc = userCenterTableViewController;
        
        UINavigationController *nav = (UINavigationController *)vc.parentViewController.presentingViewController;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
        
        CSTUserProfileViewController *userVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTUserProfileViewController"];
        
        [nav pushViewController:userVC animated:NO];
        
        [CSTRouter disMissViewController: vc.parentViewController];
    }

}

+ (void)routerToBLEConnectViewControllerFromUserCenterTableViewController:(id)userCenterTableViewController{
    
    
    if ([userCenterTableViewController isKindOfClass:[CSTUserCenterTableViewController class]]) {
        
        CSTUserCenterTableViewController *vc = userCenterTableViewController;
        
        UINavigationController *nav = (UINavigationController *)vc.parentViewController.presentingViewController;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil];
        
        CSTBLEConnectViewController *bleConnectVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTBLEConnectViewController"];
        
        [nav pushViewController:bleConnectVC animated:NO];
        
        [CSTRouter disMissViewController: vc.parentViewController];
    }
}


+ (void)routerToBLEConnectViewControllerFromDeviceStateTableViewController:(id)deviceTableViewController{

    if ([deviceTableViewController isKindOfClass:[CSTDeviceStateTableViewController class]]) {
        
        CSTDeviceStateTableViewController *deviceVC = (CSTDeviceStateTableViewController *)deviceTableViewController;
        
        NSInteger viewControllerCount = [deviceVC.navigationController.viewControllers count];
        
        if ([deviceVC.navigationController.viewControllers[viewControllerCount - 2]  isKindOfClass:[CSTBLEConnectViewController class]]) {
            
            [deviceVC.navigationController popViewControllerAnimated:NO];
            
        }else{
        
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil];
            CSTBLEConnectViewController *bleConnectVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTBLEConnectViewController"];
            
            [deviceVC.navigationController pushViewController:bleConnectVC animated:NO];
        }
    }
}


+ (void)routerToDeviceStateTableViewControllerFromBLEConnectViewController:(id)bleConnectViewController{

    if ([bleConnectViewController isKindOfClass:[CSTBLEConnectViewController class]]) {
        
        CSTBLEConnectViewController *bleVC = (CSTBLEConnectViewController *)bleConnectViewController;
        
        NSInteger viewControllerCount = [bleVC.navigationController.viewControllers count];
        
        if ([bleVC.navigationController.viewControllers[viewControllerCount - 2]  isKindOfClass:[CSTDeviceStateTableViewController class]]) {
            
            [bleVC.navigationController popViewControllerAnimated:NO];
            
        }else{
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
            CSTDeviceStateTableViewController *deviceVC = [storyboard instantiateViewControllerWithIdentifier:@"CSTDeviceStateTableViewController"];
            
            [bleVC.navigationController pushViewController:deviceVC animated:NO];
        }
    }

}


+ (id)loginViewController{

    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentRootViewController = nav.viewControllers[0];
    
    if ([currentRootViewController isKindOfClass:[CSTUserAccessViewController class]]) {
        
        return currentRootViewController;
    }
    
    UINavigationController *topVC = (UINavigationController *)[CSTRouter appTopViewController];
    
    return topVC.viewControllers[0];
}

+ (UIViewController *)appTopViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

+ (UIViewController *)routerToLoginViewControllerWithLogin{

    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentRootViewController = nav.viewControllers[0];
    CSTUserAccessViewController *accessVC = nil;
    
    if ([currentRootViewController isKindOfClass:[CSTUserAccessViewController class]]) {
        [nav popToRootViewControllerAnimated:NO];
        [nav dismissViewControllerAnimated:NO completion:nil];
        accessVC = (CSTUserAccessViewController *)currentRootViewController;
    }else{
        
        UINavigationController *presentedNav = [[UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil] instantiateInitialViewController];
        UIViewController *topVC = [CSTRouter appTopViewController];
        [topVC presentViewController:presentedNav animated:NO completion:nil];
        accessVC = presentedNav.viewControllers[0];
    }

    return accessVC;
}


+ (UIViewController *)rootViewController{

    UIStoryboard *storyboard =  [CSTDataManager isLogin] ?[UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil] : [UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil];
    
    return [storyboard instantiateInitialViewController];
}
@end
