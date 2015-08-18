//
//  CSTBLEVersion+CSTNetworkSignal.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/16.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTBLEVersion+CSTNetworkSignal.h"
#import "CSTAPIBaseManager.h"
#import "NSData+CSTParsedJsonDataSignal.h"
#import "RACSignal+CSTModel.h"

@implementation CSTBLEVersion (CSTNetworkSignal)

+ (RACSignal *)cst_serviceFirmwareVersionSignal{


  return  [[[[CSTBLEVersion cst_firmwareVersionAPIManager] fetchDataSignal] flattenMap:^RACStream *(id value) {
      
      return [value cst_parsedJsonDataSignal];
      
  }] flattenMap:^RACStream *(id value) {
      
      return [RACSignal cst_transformSignalWithModelClass:[CSTBLEVersion class] dictionary:value];
  }];
    
}


+ (CSTBLEFirmwareVersionAPIManager *)cst_firmwareVersionAPIManager{

   return [[CSTBLEFirmwareVersionAPIManager alloc] init];
}
@end
