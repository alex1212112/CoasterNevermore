//
//  CSTUserInformation.h
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import <Mantle.h>
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

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSString *username;

- (NSData *)last4DataBytes;

@end
