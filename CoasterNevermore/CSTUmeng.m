//
//  CSTUmeng.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/8/4.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUmeng.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "MobClick.h"
#import "WXApi.h"

NSString *const CSTUmengKey = @"53ec22e2fd98c559fd0181cf";
NSString *const CSTQQAppId = @"1103468026";
NSString *const CSTQQAppKey = @"BxtUmoF2hzSLg3ds";
NSString *const CSTWXAppId = @"wx89fb1b06c2cb7c91";
NSString *const CSTWXAppSecret = @"fe5ca54333986cc1b6bcdd6f38ac6f29";

@implementation CSTUmeng
+ (void)configUmeng{

    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:CSTUmengKey];
    
    
    //设置微信AppId，url地址传nil，将默认使用友盟的网址，需要#import "UMSocialWechatHandler.h"
    
    [UMSocialQQHandler setSupportWebView:YES];
    [UMSocialWechatHandler setWXAppId:CSTWXAppId appSecret:CSTWXAppSecret url:@"http://www.nevermore.cn/coaster"];
    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
    [UMSocialQQHandler setQQWithAppId:CSTQQAppId appKey:CSTQQAppKey url:@"http://www.nevermore.cn/coaster"];
    
    //使用友盟统计
    
    [MobClick startWithAppkey:CSTUmengKey];

}

+ (void)shareText:(NSString *)text image:(UIImage *)image presentSnsIconSheetView:(UIViewController *)vc{
    
    NSArray *snsNames = @[UMShareToSina,UMShareToDouban];
    
    NSMutableArray *mutableSnsNames = [NSMutableArray arrayWithArray:snsNames];
    
    if ([QQApiInterface isQQInstalled])
    {
        [mutableSnsNames insertObject:UMShareToQQ atIndex:0];
        [mutableSnsNames insertObject:UMShareToQzone atIndex:0];
    }
    if ([WXApi isWXAppInstalled])
    {
        [mutableSnsNames insertObject:UMShareToWechatSession atIndex:0];
        [mutableSnsNames insertObject:UMShareToWechatTimeline atIndex:0];
    }
    
    snsNames = [NSArray arrayWithArray:mutableSnsNames];
    
    [UMSocialData defaultData].extConfig.title = @"专注于饮水健康的智能杯垫";
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://www.nevermore.cn/coaster";
    
    [UMSocialSnsService presentSnsIconSheetView:vc
                                         appKey:CSTUmengKey
                                      shareText:text
                                     shareImage:image
                                shareToSnsNames:snsNames
                                       delegate:nil];
 

}

+ (BOOL)isQQInstalled{

    return [QQApiInterface isQQInstalled];
    
}
@end
