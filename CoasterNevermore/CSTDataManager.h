//
//  CSTDataManager.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/6.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSTUserProfile;
@class CSTRelationship;
@class CSTHealthRank;
@class RACSignal;

typedef NS_ENUM(NSInteger, CSTLoginType) {
    CSTLoginTypeCoaster,
    CSTLoginTypeQQ,
};
typedef NS_ENUM(NSInteger, CSTUserCurrentPeriodDrinkPercentState){
    
    CSTUserCurrentPeriodDrinkPercentStateZeroToFifty,
    CSTUserCurrentPeriodDrinkPercentStateFifityToHundred,
    CSTUserCurrentPeriodDrinkPercentStateOverhundred,
    
};

extern NSString *const CSTUserProfileKey;
extern NSString *const CSTMateProfileKey;
extern NSString *const CSTNcoinCountKey;
extern NSString *const CSTRelationshipKey;
extern NSString *const CSTTodayUserDrinkWaterKey;
extern NSString *const CSTTodayUserSuggestWaterKey;
extern NSString *const CSTTodayMateDrinkWaterKey;
extern NSString *const CSTTodayMateSuggestWaterKey;
extern NSString *const CSTHistoryMateDrinkWaterKey;
extern NSString *const CSTHistoryUserDrinkWaterKey;
extern NSString *const CSTUserHealthRankKey;
extern NSString *const CSTUserHealthDrinkKey;
extern NSString *const CSTHistoryUserDrinkDetailKey;
extern NSString *const CSTHistoryUserSuggestWaterKey;

@interface CSTDataManager : NSObject

@property (nonatomic, strong) CSTUserProfile *userProfile;
@property (nonatomic, strong) CSTUserProfile *mateProfile;
@property (nonatomic, strong) CSTRelationship *relationship;

@property (nonatomic, copy) NSArray *todayUserDrinkWater;
@property (nonatomic, copy) NSArray *todayMateDrinkWater;

@property (nonatomic, copy) NSArray *historyMateDrinkWater;
@property (nonatomic, copy) NSArray *historyUserDrinkWater;
@property (nonatomic, copy) NSArray *historyUserDrinkDetail;
@property (nonatomic, copy) NSArray *historyUserSuggestWater;

@property (nonatomic, strong) CSTHealthRank *userHealthRank;
@property (nonatomic, strong) NSArray *userHealthDrink;

@property (nonatomic, assign) NSInteger nCoinCount;
@property (nonatomic, assign) NSInteger todayUserSuggestWater;
@property (nonatomic, assign) NSInteger todayMateSuggestWater;
@property (nonatomic, assign) CSTLoginType loginType;
@property (nonatomic, assign) CSTUserCurrentPeriodDrinkPercentState userCurrentPeriodDrinkPercentState;
@property (nonatomic, assign) CSTUserCurrentPeriodDrinkPercentState mateCurrentPeriodDrinkPercentState;


+ (instancetype)shareManager;

+ (BOOL)isLogin;

+ (void)removeAllData;

+ (void)prepareLaunchData;

+ (RACSignal *)refreshUserProfileSignal;
+ (RACSignal *)refreshRelationshipSignal;
+ (RACSignal *)refreshMateProfileSignalWithRelationship:(CSTRelationship *)relationship;

+ (NSString *)todayUserDrinkCacheFileName;

+ (NSString *)documentCacheFileName;


+ (void)removeRelationship;

@end
