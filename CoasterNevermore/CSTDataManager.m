//
//  CSTDataManager.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/6.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDataManager.h"
#import "CSTUserToken.h"
#import "CSTBLEManager.h"
#import "GHCache.h"
#import "CSTNetworking.h"
#import "CSTHealthRank.h"
#import "CSTQQToken.h"
#import "CSTAPIBaseManager.h"
#import "DXAlertView.h"
#import "CSTJPushManager.h"
#import "CSTLocalNotification.h"

#import "NSData+CSTParsedJsonDataSignal.h"
#import "CSTDrinkModel+CSTCache.h"
#import "NSDate+CSTTransformString.h"
#import "CSTUserProfile+CSTNetworkSignal.h"
#import "CSTRelationship+CSTNetworkSignal.h"
#import "CSTDayPeriod+CSTExtention.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDWebImage/SDWebImageManager.h>

NSString *const CSTUserProfileKey = @"CSTUserProfileKey";
NSString *const CSTMateProfileKey = @"CSTMateProfileKey";
NSString *const CSTNcoinCountKey = @"CSTNcoinCountKey";
NSString *const CSTRelationshipKey = @"CSTRelationshipKey";
NSString *const CSTTodayUserDrinkWaterKey = @"CSTTodayUserDrinkWaterKey";
NSString *const CSTTodayUserSuggestWaterKey = @"CSTTodayUserSuggestWaterKey";
NSString *const CSTTodayMateDrinkWaterKey = @"CSTTodayMateDrinkWaterKey";
NSString *const CSTTodayMateSuggestWaterKey = @"CSTTodayMateSuggestWaterKey";
NSString *const CSTHistoryMateDrinkWaterKey = @"CSTHistoryMateDrinkWaterKey";
NSString *const CSTHistoryUserDrinkWaterKey = @"CSTHistoryUserDrinkWaterKey";
NSString *const CSTUserHealthRankKey = @"CSTUserHealthRankKey";
NSString *const CSTUserHealthDrinkKey = @"CSTUserHealthDrinkKey";
NSString *const CSTHistoryUserDrinkDetailKey = @"CSTHistoryUserDrinkDetailKey";
NSString *const CSTHistoryUserSuggestWaterKey = @"CSTHistoryUserSuggestWaterKey";

@implementation CSTDataManager

#pragma mark - Life cycle
+ (instancetype)shareManager{
    
    static CSTDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


- (instancetype)init{

    if (self = [super init]) {
        
        [self p_configObservers];
    }
    
    return self;
}


#pragma mark - Observer


- (void)p_configObservers{

    [self p_configObserverWithUserProfile];
    [self p_configObserverWithNCoinCount];
    [self p_configObserverWithRelationship];
    [self p_configObserverWithMateProfile];
    
    [self p_configObserverWithTodayMateDrinkWater];
    [self p_configObserverWithTodayUserDrinkWater];
    [self p_configObserverWithTodayUserSuggestWater];
    [self p_configObserverWithTodayMateSuggestWater];
    
    [self p_configObserverWithHistoryUserDrinkWater];
    [self p_configObserverWithHistoryMateDrinkWater];
    
    [self p_configObserverWithHistoryUserDrinkDetail];
    [self p_configObserverWithHistoryUserSuggestWater];
    
    [self p_configObserverWithUserHealthRank];
    [self p_configObserverWithUserHealthDrink];
    
}


- (void)p_configObserverWithUserProfile{

    @weakify(self);
    [[[RACObserve(self, userProfile) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTUserProfileKey];
    }];
}

- (void)p_configObserverWithRelationship{

    @weakify(self);
    [[[[RACObserve(self, relationship) skip:1] ignore:nil] distinctUntilChanged] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTRelationshipKey];
    }];
    
}

- (void)p_configObserverWithMateProfile{

    @weakify(self);
    [[[RACObserve(self, mateProfile) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTMateProfileKey];
    }];
}
- (void)p_configObserverWithTodayUserDrinkWater{
    
    @weakify(self);
    [[[[[RACObserve(self, todayUserDrinkWater) skip:1] ignore:nil] doNext:^(id x) {
        @strongify(self);
        
         [self p_saveToUserDefaultsWithObject:x identify:CSTTodayUserDrinkWaterKey];
        
    }] flattenMap:^RACStream *(id value) {
        
        if (self.todayUserSuggestWater > 0 &&  [[value valueForKeyPath:@"@sum.weight"] floatValue] / 1000.0 / (CGFloat)(self.todayUserSuggestWater) >= 0.6) {
         
            return [[self p_uploadNCoinsSignalWithNumber:1] merge:[[self p_uploadTodayHealthDrinkAPIManager] fetchDataSignal]];
        }
        return [RACSignal empty];
        
    }] subscribeNext:^(id x) {
        
    }];
}

- (void)p_configObserverWithTodayMateDrinkWater{
    
    @weakify(self);
    [[[RACObserve(self, todayMateDrinkWater) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTTodayMateDrinkWaterKey];
    }];
}



- (void)p_configObserverWithNCoinCount{
    
    @weakify(self);
    [[[RACObserve(self, nCoinCount) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTNcoinCountKey];
    }];
}

- (void)p_configObserverWithTodayUserSuggestWater{
    
    @weakify(self);
    [[[RACObserve(self, todayUserSuggestWater) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTTodayUserSuggestWaterKey];
    }];
}


- (void)p_configObserverWithUserHealthRank{
    
    @weakify(self);
    [[[RACObserve(self, userHealthRank) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTUserHealthRankKey];
    }];
}

- (void)p_configObserverWithUserHealthDrink{
    
    @weakify(self);
    [[[RACObserve(self, userHealthDrink) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTUserHealthDrinkKey];
    }];
}

- (void)p_configObserverWithTodayMateSuggestWater{
    
    @weakify(self);
    [[[RACObserve(self, todayMateSuggestWater) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTTodayMateSuggestWaterKey];
    }];
}

- (void)p_configObserverWithHistoryMateDrinkWater{
    
    @weakify(self);
    [[[RACObserve(self, historyMateDrinkWater) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTHistoryMateDrinkWaterKey];
    }];
}

- (void)p_configObserverWithHistoryUserDrinkWater{
    
    @weakify(self);
    [[[RACObserve(self, historyUserDrinkWater) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTHistoryUserDrinkWaterKey];
    }];
}

- (void)p_configObserverWithHistoryUserDrinkDetail{
    
    @weakify(self);
    [[[RACObserve(self, historyUserDrinkDetail) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTHistoryUserDrinkDetailKey];
    }];
}

- (void)p_configObserverWithHistoryUserSuggestWater{
    
    @weakify(self);
    [[[RACObserve(self, historyUserSuggestWater) skip:1] ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self p_saveToUserDefaultsWithObject:x identify:CSTHistoryUserSuggestWaterKey];
    }];
}


#pragma mark - Public methed

+ (BOOL)isLogin{

    return [CSTUserToken isLogin];
}

+ (void)removeRelationship{

    [[CSTDataManager shareManager] p_removeRelationship];
}
+ (void)removeAllData{

    [CSTUserToken removeToken];
    [CSTQQToken removeToken];
    
    [[CSTDataManager shareManager] p_removeUserProfile];
    [[CSTDataManager shareManager] p_removeMateProfile];
    [[CSTDataManager shareManager] p_removeRelationship];
    [[CSTDataManager shareManager] p_removeTodayUserDrinkWater];
    [[CSTDataManager shareManager] p_removeTodayMateDrinkWater];
    [[CSTDataManager shareManager] p_removeHistoryMateDrinkWater];
    [[CSTDataManager shareManager] p_removeHistoryUserDrinkWater];
    [[CSTDataManager shareManager] p_removeHistoryUserDrinkDetail];
    [[CSTDataManager shareManager] p_removeHistoryUserSuggestWater];
    
    [[CSTDataManager shareManager] p_removeUserHealthRank];
    [[CSTDataManager shareManager] p_removeUserHealthDrink];
    
    [[CSTDataManager shareManager] p_removeNCoinCount];
    [[CSTDataManager shareManager] p_removeTodayUserSuggestWater];
    [[CSTDataManager shareManager] p_removeTodayMateSuggestWater];
    
    [[GHCache shareCache] clearCache];
    
    [[CSTBLEManager shareManager] cancelPeripheralConnect];
    [[CSTBLEManager shareManager] stopScan];
    
    [CSTJPushManager configJpushAlias:nil];
    [[CSTLocalNotification  shareNotification] removeNotifications];
    
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];

}

+ (void)prepareLaunchData{

    if ([CSTDataManager isLogin]) {
     
        [[[[CSTDataManager refreshUserProfileSignal]flattenMap:^RACStream *(id value) {
            
            return [CSTDataManager refreshRelationshipSignal];
            
        }] flattenMap:^RACStream *(id value) {
            
            return [CSTDataManager refreshMateProfileSignalWithRelationship:value];
            
        }] subscribeNext:^(id x) {
            
        }];
        
        [[CSTBLEManager shareManager] configCentralManager];
    }
}


+ (RACSignal *)refreshUserProfileSignal{
    
  return  [[CSTUserProfile cst_networkDataSignalWithUid:[CSTUserToken token].uid] doNext:^(id x) {
      
      if (![[CSTDataManager shareManager].userProfile isEqual:x]) {
       
          [CSTDataManager shareManager].userProfile = x;
          [CSTJPushManager configJpushAlias:[CSTUserToken token].uid];
      }
  }];
}

+ (RACSignal *)refreshRelationshipSignal{
    
    return [[[CSTRelationship cst_networkDataSignal] doNext:^(id x) {
        
        if (![[CSTDataManager shareManager].relationship isEqual:x]) {
         
            [CSTDataManager shareManager].relationship = x;
        }
    }] doError:^(NSError *error) {
        
        if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]]){
            
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)(error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
            if (response.statusCode == 404){
                
                [[CSTDataManager shareManager] p_removeRelationship];
            }
        }
    }];
}

+ (RACSignal *)refreshMateProfileSignalWithRelationship:(CSTRelationship *)relationship{

    NSString *uid = [CSTDataManager p_mateUidWithRelationship:relationship];
    if (!uid) {
        
        [[CSTDataManager shareManager] p_removeMateProfile];
        return [RACSignal empty];
    }
    if ([relationship.status isEqual:@2]) {
        
        return [[[CSTUserProfile cst_networkDataSignalWithUid:uid] doNext:^(id x) {
            
            if (![[CSTDataManager shareManager].mateProfile isEqual:x]) {
                
                [CSTDataManager shareManager].mateProfile = x;
            }
        }] doError:^(NSError *error) {
            
            [[CSTDataManager shareManager] p_removeMateProfile];
        }];
    }
    [[CSTDataManager shareManager] p_removeMateProfile];
    return [RACSignal empty];
}

+ (NSString *)todayUserDrinkCacheFileName{

    NSString *today = [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd"];
    if ([CSTDataManager shareManager].userProfile.uid) {
     
        return [NSString stringWithFormat:@"userDrink-%@-%@",[CSTDataManager shareManager].userProfile.uid,today];
    }
    return nil;
}

+ (NSString *)documentCacheFileName{

    if ([CSTDataManager shareManager].userProfile.uid) {
        
        return [NSString stringWithFormat:@"%@-documentWaterData",[CSTDataManager shareManager].userProfile.uid];;
    }
    return nil;
}



#pragma mark - Private method

- (void)p_saveToUserDefaultsWithObject:(id)object identify:(NSString *)identify{

    if (object)
    {
        NSData *data =  [NSKeyedArchiver archivedDataWithRootObject:object];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:identify];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)p_removeFromUserDefaultsWithidentify:(NSString *)identify{

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:identify];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)p_removeUserProfile{
    
    [self p_removeFromUserDefaultsWithidentify:CSTUserProfileKey];
    self.userProfile = nil;
}
- (void)p_removeMateProfile{
    
    [self p_removeFromUserDefaultsWithidentify:CSTMateProfileKey];
    self.mateProfile = nil;
}
- (void)p_removeRelationship{
    
    [self p_removeFromUserDefaultsWithidentify:CSTRelationshipKey];
    self.relationship = nil;
    [self p_removeMateProfile];
    
}
- (void)p_removeTodayUserDrinkWater{
    
    [self p_removeFromUserDefaultsWithidentify:CSTTodayUserDrinkWaterKey];
    self.todayUserDrinkWater = nil;
}

- (void)p_removeTodayMateDrinkWater{
    
    [self p_removeFromUserDefaultsWithidentify:CSTTodayMateDrinkWaterKey];
    self.todayMateDrinkWater = nil;
}


- (void)p_removeHistoryMateDrinkWater{
    
    [self p_removeFromUserDefaultsWithidentify:CSTTodayMateDrinkWaterKey];
    self.historyMateDrinkWater = nil;
}

- (void)p_removeHistoryUserDrinkWater{
    
    [self p_removeFromUserDefaultsWithidentify:CSTHistoryUserDrinkWaterKey];
    self.historyUserDrinkWater = nil;
}

- (void)p_removeUserHealthRank{

    [self p_removeFromUserDefaultsWithidentify:CSTUserHealthRankKey];
    self.userHealthRank = nil;
}

- (void)p_removeUserHealthDrink{
    
    [self p_removeFromUserDefaultsWithidentify:CSTUserHealthDrinkKey];
    self.userHealthDrink = nil;
}

- (void)p_removeHistoryUserDrinkDetail{
    
    [self p_removeFromUserDefaultsWithidentify:CSTHistoryUserDrinkDetailKey];
    self.historyUserDrinkDetail = nil;
}

- (void)p_removeHistoryUserSuggestWater{

    [self p_removeFromUserDefaultsWithidentify:CSTHistoryUserSuggestWaterKey];
    self.historyUserSuggestWater = nil;
}








- (void)p_removeNCoinCount{
    
    [self p_removeFromUserDefaultsWithidentify:CSTNcoinCountKey];
    self.nCoinCount = 0;
}

- (void)p_removeTodayUserSuggestWater{
    
    [self p_removeFromUserDefaultsWithidentify:CSTTodayUserSuggestWaterKey];
    self.todayUserSuggestWater = 0;
}

- (void)p_removeTodayMateSuggestWater{
    
    [self p_removeFromUserDefaultsWithidentify:CSTTodayMateSuggestWaterKey];
    self.todayMateSuggestWater = 0;
}



+ (NSString *)p_mateUidWithRelationship:(CSTRelationship *)relationship{

    return [relationship.fromUid isEqualToString:[CSTDataManager shareManager].userProfile.uid] ? relationship.toUid : relationship.fromUid;
}

#pragma mark - Private signal

- (RACSignal *)p_uploadNCoinsSignalWithNumber:(NSInteger)nCoinCout{

    @weakify(self);
   return [[[[self p_uploadNcoinsAPIManagerWithNumber:nCoinCout] fetchDataSignal] flattenMap:^RACStream *(id value) {
       
       return [value  cst_parsedJsonDataSignal];
       
   }] doNext:^(id x) {
        @strongify(self);
        
        self.nCoinCount = [x[@"ScoreValue"] integerValue];
    }];
}

- (CSTUploadNcoinsAPIManager *)p_uploadNcoinsAPIManagerWithNumber:(NSInteger)nCoinCount{

    CSTUploadNcoinsAPIManager *apiManager = [[CSTUploadNcoinsAPIManager alloc] init];
    apiManager.parameters = @{@"Delta" : @(nCoinCount),
                              @"Type" : @1
                              };

    return apiManager;
}

- (CSTUploadHealthDrinkAPIManager *)p_uploadTodayHealthDrinkAPIManager{
    
    CSTUploadHealthDrinkAPIManager *apiManager = [[CSTUploadHealthDrinkAPIManager alloc] init];
    
    apiManager.parameters = @{@"datetime" : [[NSDate date] cst_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"]};
    
    return apiManager;
}
#pragma mark - Setters and getters

- (CSTUserProfile *)userProfile{

    if (!_userProfile) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTUserProfileKey];
        if (!data)
        {
            return nil;
        }
        _userProfile = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _userProfile;
}



- (CSTUserProfile *)mateProfile{
    if (!_mateProfile) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTMateProfileKey];
        if (!data)
        {
            return nil;
        }
        _mateProfile = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _mateProfile;
}

- (CSTRelationship *)relationship{

    if (!_relationship) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTRelationshipKey];
        if (!data)
        {
            return nil;
        }
        _relationship = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _relationship;
}


- (NSArray *)todayUserDrinkWater{
    
    if (!_todayUserDrinkWater) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTTodayUserDrinkWaterKey];
        if (!data)
        {
            return nil;
        }
        _todayUserDrinkWater = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _todayUserDrinkWater;
}



- (NSArray *)todayMateDrinkWater{
    
    if (!_todayMateDrinkWater) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTTodayMateDrinkWaterKey];
        if (!data)
        {
            return nil;
        }
        _todayMateDrinkWater = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _todayMateDrinkWater;
}

- (NSArray *)historyMateDrinkWater{
    
    if (!_historyMateDrinkWater) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTHistoryMateDrinkWaterKey];
        if (!data)
        {
            return nil;
        }
        _historyMateDrinkWater = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _historyMateDrinkWater;
}


- (NSArray *)historyUserDrinkWater{
    
    if (!_historyUserDrinkWater) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTHistoryUserDrinkWaterKey];
        if (!data)
        {
            return nil;
        }
        _historyUserDrinkWater = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _historyUserDrinkWater;
}

- (NSArray *)historyUserDrinkDetail{
    
    if (!_historyUserDrinkDetail) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTHistoryUserDrinkDetailKey];
        if (!data)
        {
            return nil;
        }
        _historyUserDrinkDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _historyUserDrinkDetail;
}

- (NSArray *)historyUserSuggestWater{

    if (!_historyUserSuggestWater) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTHistoryUserSuggestWaterKey];
        if (!data)
        {
            return nil;
        }
        _historyUserSuggestWater = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _historyUserSuggestWater;
}

- (CSTHealthRank *)userHealthRank{
    
    if (!_userHealthRank) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTUserHealthRankKey];
        if (!data)
        {
            return nil;
        }
        _userHealthRank = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _userHealthRank;
}

- (NSArray *)userHealthDrink{
    
    if (!_userHealthDrink) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTUserHealthDrinkKey];
        if (!data)
        {
            return nil;
        }
        _userHealthDrink = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _userHealthDrink;
}




- (NSInteger)nCoinCount{
    
    if (_nCoinCount == 0) {
        
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTNcoinCountKey];
        if (!data)
        {
            _nCoinCount = 0;
        }else{
            _nCoinCount = [[NSKeyedUnarchiver unarchiveObjectWithData:data] integerValue];
        }
    }
    
    return _nCoinCount;
}


- (NSInteger)todayUserSuggestWater{
    
    if (_todayUserSuggestWater == 0) {
        
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTTodayUserSuggestWaterKey];
        if (!data)
        {
            _todayUserSuggestWater = 0;
        }else{
            _todayUserSuggestWater = [[NSKeyedUnarchiver unarchiveObjectWithData:data] integerValue];
        }
    }
    
    return _todayUserSuggestWater;
}

- (NSInteger)todayMateSuggestWater{
    
    if (_todayMateSuggestWater == 0) {
        
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CSTTodayMateSuggestWaterKey];
        if (!data)
        {
            _todayMateSuggestWater = 0;
        }else{
            _todayMateSuggestWater = [[NSKeyedUnarchiver unarchiveObjectWithData:data] integerValue];
        }
    }
    
    return _todayMateSuggestWater;
}


- (CSTLoginType)loginType{

    if ([CSTQQToken token]) {
        
        return CSTLoginTypeQQ;
    }
    return CSTLoginTypeCoaster;
}

+ (NSSet *)keyPathsForValuesAffectingCurrentPeriodDrinkPercentState{

    return [NSSet setWithObject:@"todayUserDrinkWater"];
}

- (CSTUserCurrentPeriodDrinkPercentState)userCurrentPeriodDrinkPercentState{

    CGFloat percent = [CSTDayPeriod cst_drinkPercentWithDrinkArray:self.todayUserDrinkWater suggest:self.todayUserSuggestWater inPeriod:[CSTDayPeriod cst_periodWithDate:[NSDate date]]];
    
    if (percent < 0.5)
    {
        return  CSTUserCurrentPeriodDrinkPercentStateZeroToFifty;
    }
    
    if (percent >= 0.5 && percent < 1.0)
    {
      return CSTUserCurrentPeriodDrinkPercentStateFifityToHundred;
    }
    return CSTUserCurrentPeriodDrinkPercentStateOverhundred;
}

+ (NSSet *)keyPathsForValuesAffectingMateCurrentPeriodDrinkPercentState{

     return [NSSet setWithObject:@"todayMateDrinkWater"];
}

- (CSTUserCurrentPeriodDrinkPercentState)mateCurrentPeriodDrinkPercentState{
    
    CGFloat percent = [CSTDayPeriod cst_drinkPercentWithDrinkArray:self.todayMateDrinkWater suggest:self.todayMateSuggestWater inPeriod:[CSTDayPeriod cst_periodWithDate:[NSDate date]]];
    if (percent < 0.5)
    {
        return  CSTUserCurrentPeriodDrinkPercentStateZeroToFifty;
    }
    
    if (percent >= 0.5 && percent < 1.0)
    {
        return CSTUserCurrentPeriodDrinkPercentStateFifityToHundred;
    }
    return CSTUserCurrentPeriodDrinkPercentStateOverhundred;
}



@end
