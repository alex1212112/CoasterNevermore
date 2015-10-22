//
//  CSTUserInformation.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle/Mantle.h>
@import UIKit;

typedef NS_ENUM(NSInteger, CSTUserGender) {
    CSTUserGenderFemale,
    CSTUserGenderMale
};

typedef NS_ENUM(NSInteger, CSTUserProfileType) {
    CSTUserProfileTypeNickname,
    CSTUserProfileTypeGender,
    CSTUserProfileTypeHeight,
    CSTUserProfileTypeWeight,
    CSTUserProfileTypeBirthday,
};


@interface CSTUserProfile : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *birthday;

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *imageURLString;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *username;

@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) UIImage *avatarImage;

- (NSData *)last4DataBytes;

@end
