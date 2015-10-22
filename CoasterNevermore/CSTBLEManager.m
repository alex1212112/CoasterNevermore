//
//  CSTBLEManager.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/15.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//


#import "CSTBLEManager.h"
#import "BLETIOADProfile.h"
#import "CSTDataManager.h"
#import "CSTUserProfile.h"
#import "NSDate+CSTTransformString.h"
#import "CSTBLEVersion.h"
#import "CBPeripheral+CSTBLE.h"
#import "GHDocumentCache.h"
#import "CSTAPIBaseManager.h"
#import "CSTDrinkModel+CSTNetworkSignal.h"
#import "CSTDrinkModel+CSTCache.h"
#import "CSTBLEVersion+CSTNetworkSignal.h"
#import "GHCache.h"
#import "CSTQQManager.h"
#import "DXAlertView.h"

#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


static NSString *const CSTCBCentralManagerRestoreKey = @"CSTCBCentralManagerRestoreKey";
NSString *const CSTBLEBindErrorReasonKey = @"com.nevermore.Coaster.error.BLEErrorReasonDescription";
const NSInteger CSTBLEBindErrorTargetIsBindedCode = 100053;
const NSInteger CSTBLEBindErrorUnknowCode = 100054;

@interface CSTBLEManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{

    HandleEvent didDeleteBind;
    NSTimer *deleteBindTimer;
    NSTimer *bindTimer;
    HandleEvent didBind;
    HandleEvent bindOccurError;
    
}

@property (nonatomic, strong) NSNumber *weightG;
@property (nonatomic, strong) NSNumber *weightB;
@property (nonatomic, strong) NSData *unCalculateData;
@property (nonatomic, getter  = isCalibrateNow) BOOL calibrateNow;
@property (nonatomic, getter = isBindNow) BOOL bindNow;
@property (nonatomic, strong) CSTBLEVersion *curentVersion;

@end

@implementation CSTBLEManager

#pragma mark - Life cycle
+ (instancetype)shareManager{
    
    static CSTBLEManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    
    if (self = [super init]) {
        
    }

    return self;
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        
        self.scanning = NO;
        self.firmwareNeedUpdate = NO;
        self.peripheral = nil;
        self.devices = nil;
        self.battery = nil;
        return;
    }
    
    if ([CSTDataManager isLogin])
    {
        [self scan];
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
   // NSLog(@"per == %@",peripheral.description);
    
    NSString *deviceId = advertisementData[CBAdvertisementDataLocalNameKey];
    if (![deviceId hasPrefix:@"CUP-MAT"])
    {
        return;
    }
    
    
    CSTBLEVersion *fmVersion = [[CSTBLEVersion alloc] init];
    fmVersion.type = [deviceId substringFromIndex:deviceId.length - 1];
    
    peripheral.cst_deviceId = [deviceId substringToIndex:deviceId.length - 1 ];
    
    peripheral.cst_discoverRSSI = RSSI;
    
    
    peripheral.cst_fmVersion = fmVersion;
    
    NSString *userDeviceId = [CSTDataManager shareManager].userProfile.deviceId;
    
    
    if ([peripheral.cst_deviceId isEqualToString:userDeviceId])
    {
        [self connectPeripheral:peripheral Options:nil];
    }
    
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.devices];
    if (!mutableArray)
    {
        mutableArray = [NSMutableArray array];
        [mutableArray addObject:peripheral];
        self.devices = [NSArray arrayWithArray:mutableArray] ;
    }
    else
    {
        if (![self.devices containsObject:peripheral])
        {
            [mutableArray addObject:peripheral];
            self.devices = [NSArray arrayWithArray:mutableArray] ;
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self stopScan];
    
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    [self.oadProfile deviceDisconnected:peripheral];
    self.firmwareNeedUpdate = NO;
    self.peripheral = nil;
    self.devices = nil;
    self.battery = nil;
    self.bindNow = NO;
    
    if ([CSTDataManager isLogin]) {
        
         [self scan];
    }
    
    if (didDeleteBind)
    {
        didDeleteBind();
        didDeleteBind = nil;
        [deleteBindTimer invalidate];
    }
   
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.peripheral = nil;
    
    if ([CSTDataManager isLogin]) {
        
        [self scan];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
        return;
    }
    
    for (CBService *service in aPeripheral.services) {
        
        [aPeripheral discoverCharacteristics:nil forService:service];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if (error) {
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFFB"]])
            {
                
                if ([CSTDataManager shareManager].userProfile.deviceId)
                {
                    [self p_matchCoasterToUser:[CSTDataManager shareManager].userProfile];
                }
                else
                {
                    [self p_bindCoasterToUser:[CSTDataManager shareManager].userProfile];
                }
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error)
    {
        return;
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        return;
    }
    
    [self.oadProfile didUpdateValueForProfile:characteristic];
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFFC"]])
    {
        [self p_handleWeightData:characteristic.value];
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFFA"]])
    {
        
        [self p_handleVersionData:characteristic.value];
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFF9"]])
    {
        [self p_handleACK:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error) {
        
        NSLog(@"Error discovering characteristics: %@", [error description]);
        
        return;
    }
}


#pragma mark - Private method

- (void)p_bindCoasterToUser:(CSTUserProfile *)user
{
    NSData *uidData = [user last4DataBytes];
    
    [self p_writeData:uidData withfirstCmd:0X0B secondCmd:0X0C thirdCmd:0X0D forthCmd:0X0E];
}

- (void)p_matchCoasterToUser:(CSTUserProfile *)user
{
    NSLog(@"SendMatch!!!");
    
    NSData *uidData = [user last4DataBytes];
    
    [self p_writeData:uidData withfirstCmd:0X0F secondCmd:0X10 thirdCmd:0X11 forthCmd:0X12];
    
}


- (void)p_handleVersionData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"version === %@",string);
    
    if ([string hasPrefix:@"Ver"])
    {
        
        self.peripheral.cst_fmVersion.version = string;
        
        @weakify(self);
        [[CSTBLEVersion cst_serviceFirmwareVersionSignal] subscribeNext:^(id x) {
            
            @strongify(self);
            CSTBLEVersion *serviceVersion = x;
            self.firmwareNeedUpdate = ![ self.peripheral.cst_fmVersion.version isEqualToString:serviceVersion.version];
  
        } error:^(NSError *error) {
            
            @strongify(self);
            self.firmwareNeedUpdate = NO;
        }];
    }
    
    [self p_runMethodAfterDelay:0.5f withMethod:^{
        
        [self writeByte:0x0100 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
    }];
}



- (void)p_handleWeightData:(NSData*)data
{
    NSData *data12 = [data subdataWithRange:(NSRange){12,1}];
    
    NSInteger flag =  *(Byte *)[data12 bytes];
    
    if (flag == 0)
    {
        if (self.weightB && self.weightG)
        {
            [self p_saveWaterData:data];
            
            [self p_runMethodAfterDelay:0.5f withMethod:^{
                
                [self writeByte:0X0200 toPeripheral:self.peripheral characteristicUUID:0XFFFB];
            }];
        }
        else
        {
            self.unCalculateData = data;
        }
    }
    else if (flag == 1)
    {
        
    }
    else if (flag == 2)
    {
        NSDictionary *dic = [self p_parseToGBWithData:data];
        
        self.weightG = dic[@"G"];
        self.weightB = dic[@"B"];
        if (_unCalculateData)
        {
            [self p_saveWaterData:self.unCalculateData];
            self.unCalculateData = nil;
        }
        
        [self p_runMethodAfterDelay:0.5 withMethod:^{
            
            [self writeByte:0X0200 toPeripheral:self.peripheral characteristicUUID:0XFFFB];
            
        }];
    }
}

- (void)p_handleACK:(NSData*)data
{
    UInt16 *bindMessage = (UInt16*)[data bytes];
    
    NSLog(@"ACK == %lX",(long)*bindMessage);
    
    if (self.peripheral.state != CBPeripheralStateConnected )
    {
        return;
    }
    
    if (*bindMessage == [self swap:0x0201])         //绑定成功
    {
        [self didBindSucces];
    }
    else if (*bindMessage == [self swap:0x0202])   //绑定失败
    {
        [self didBindFail];
    }
    else if (*bindMessage == [self swap:0x0204])   //匹配成功
    {
        [self didMatchSuccess];
    }
    else if (*bindMessage == [self swap:0x0205])   //匹配失败
    {
        [self didMatchFail];
    }
    else if (*bindMessage == [self swap:0x0200])   //匹配时候发现杯垫未绑定
    {
        static NSInteger receiveBindAckCount = 0;
        if (receiveBindAckCount == 0)
        {
            [self p_bindCoasterToUser:[CSTDataManager shareManager].userProfile];
        }
        receiveBindAckCount ++;
        if (receiveBindAckCount == 4)
        {
            receiveBindAckCount = 0;
        }
    }
    else if (*bindMessage == [self swap:0x0203])   //绑定时候发现杯垫已经绑定，需要match
    {
        [self didBindFail];
    }
    else if (*bindMessage == [self swap:0x0208])   //时间设置成功
    {
        NSLog(@"time set OK!");
    }
    else if (*bindMessage == [self swap:0x020A])   //测量周期设置成功
    {
     
    }
    else if (*bindMessage == [self swap:0x020B])   //测量周期设置失败
    {
       
    }
    else if ((*bindMessage & 0X00FF) == 0X0001) //电量
    {
        NSLog(@"battery == %lX",(long)*bindMessage);
        
        self.battery = @(*bindMessage >> 8);
    }
    else if (*bindMessage == [self swap:0x0206]) //GB设置成功
    {
    
    }
    else if (*bindMessage == [self swap:0x0207]) //GB设置失败
    {
      
    }
    else if (*bindMessage == [self swap:0x020C]) //容差设置成功
    {
       
    }
    else if (*bindMessage == [self swap:0x020D]) //容差设置失败
    {
      
    }
}



- (void)deleteBind
{
    if (self.peripheral)
    {
        [self writeByte:0X1300 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

- (void)didBindSucces
{
    if (![CSTDataManager shareManager].userProfile.deviceId)
    {
        [bindTimer invalidate];
        [[self p_bindDeviceSignalWithID:self.peripheral.cst_deviceId]subscribeNext:^(id x) {
            
            [self p_runMethodAfterDelay:5.0 withMethod:^{
               
                if (self->didBind) {
                    
                    self->didBind();
                    
                    self->didBind = nil;
                }
            }];
            
           [CSTDataManager shareManager].userProfile.deviceId = self.peripheral.cst_deviceId;
        }error:^(NSError *error) {
            
            [self deleteBindWithHandler:^{
                
                if (self->bindOccurError) {
                    
                    self->bindOccurError(error);
                }
            }];
        }];
    }
    
    [self p_matchCoasterToUser:[CSTDataManager shareManager].userProfile];
    self.bindNow = YES;
}
- (void)didBindFail
{
    NSLog(@"绑定失败！！！");
    if (![CSTDataManager shareManager].userProfile.deviceId)
    {
        [bindTimer invalidate];
        if (bindOccurError) {
            
            NSString *domain = @"目标杯垫已绑定";
            NSError *error = [NSError errorWithDomain:domain code:CSTBLEBindErrorTargetIsBindedCode userInfo:@{CSTBLEBindErrorReasonKey : domain}];
            
            bindOccurError(error);
            bindOccurError = nil;
        }
    }
    if (self.peripheral)
    {
        NSLog(@"cancel!");
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}
- (void)didMatchSuccess
{
    NSLog(@"匹配成功！！！");
    if (self.bindNow)
    {
        self.bindNow = NO;
        [self removeFlash];
        [self p_runMethodAfterDelay:0.5f withMethod:^{
            
            [self updateTime];
        }];
        
        [self p_runMethodAfterDelay:3.0f withMethod:^{
            
            [self setMesureInteval];
        }];
        
        [self p_runMethodAfterDelay:4.0f withMethod:^{
            
            [self setTolerance];
        }];
        
        [self p_runMethodAfterDelay:4.5f withMethod:^{
            
            [self requestGBValue];
        }];
    }
    else
    {
        [self p_runMethodAfterDelay:0.5f withMethod:^{
            
            [self updateTime];
        }];
        
        [self p_runMethodAfterDelay:2.5f withMethod:^{
            
            [self requestGBValue];
        }];
    }
}

- (void)removeFlash
{
    [self p_runMethodAfterDelay:0.5f withMethod:^{
        
        [self writeByte:0x2700 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
    }];
    
}

- (void)didMatchFail
{
    self.bindNow = NO;
    
    if (_peripheral)
    {
        [self.centralManager cancelPeripheralConnection:_peripheral];
    }
}



- (void)requestGBValue
{
    NSLog(@"requestGB!!!!");
    [self p_runMethodAfterDelay:0.5f withMethod:^{
        
        [self writeByte:0X2600 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
    }];
}

- (void)setMesureInteval
{
    [self p_runMethodAfterDelay:0.5f withMethod:^{
        
        [self writeByte:0X180A toPeripheral:self.peripheral characteristicUUID:0xFFFB];
        
    }];
}

- (void)setTolerance
{
    
    long long timeStamp = 0X0F;
    
    NSData *timeData = [NSData dataWithBytes:&timeStamp length:4];
    NSLog(@"setTolerance!!!!");
    [self p_writeData:timeData withfirstCmd:0x14 secondCmd:0X15 thirdCmd:0X16 forthCmd:0X17];
}



- (void)setMeasureCycle:(UInt16)seconds
{
    [self writeByte:seconds toPeripheral:self.peripheral characteristicUUID:0xFFFB];
}


- (void)updateTime
{
    
    long long timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSData *timeData = [NSData dataWithBytes:&timeStamp length:4];
    
    [self p_writeData:timeData withfirstCmd:0X07 secondCmd:0X08 thirdCmd:0X09 forthCmd:0X0A];
}


- (void)p_saveWaterData:(NSData *)data{

    NSDictionary *dic = [self p_parseData:data];
    NSLog(@"Data == %@",dic);
    self.testDic = dic;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_testArray];
    if (!mutableArray)
    {
        mutableArray = [NSMutableArray array];
    }
    [mutableArray addObject:_testDic];
    self.testArray = [mutableArray copy];
    
    if ([dic[@"weight"] integerValue] > 150000 && [dic[@"weight"] integerValue] < 1500000 && ![dic[@"datetime"] hasPrefix:@"1970"])
    {
        NSDictionary *calculateWeightDic = [self calculatCurrentDrinkWithData:dic];
        
        NSLog(@"calculateweight === %@",calculateWeightDic.description);
        
        if (!calculateWeightDic)
        {
            return;
        }
        
        if (![[NSDate cst_dateWithOriginString:calculateWeightDic[@"datetime"] Format:@"yyyy-MM-dd HH:mm:ss"] cst_isTheSameDayWithDate:[NSDate date]]) {
            
            [[self p_uploadWaterSignalWithParamters:calculateWeightDic] subscribeNext:^(id x) {
            }];
            return;
        }
        
        [[self p_uploadAndFetchTodayWaterSignalWithParamters:calculateWeightDic] subscribeNext:^(id x) {

            [CSTDataManager shareManager].todayUserDrinkWater = [[CSTDrinkModel cst_drinkModelArrayWithDocument:[CSTDataManager documentCacheFileName] currentModelArray:x] linq_where:^BOOL(id item) {
                
                return [[NSDate date] cst_isTheSameDayWithDate:[item valueForKey:@"date"]];
            }];
            
            
        } error:^(NSError *error) {
            [CSTDataManager shareManager].todayUserDrinkWater = [[CSTDrinkModel cst_drinkModelArrayWithDocument:[CSTDataManager documentCacheFileName] cache:[CSTDataManager todayUserDrinkCacheFileName]] linq_where:^BOOL(id item) {
                
                 return [[NSDate date] cst_isTheSameDayWithDate:[item valueForKey:@"date"]];
            }];
        }];
    }
}

- (NSDictionary *)p_parseData:(NSData *)data
{
    
    NSData *data0t3 = [data subdataWithRange:(NSRange){0,4}];
    NSData *data4t7 = [data subdataWithRange:(NSRange){4,4}];
    NSData *data8t11 = [data subdataWithRange:(NSRange){8,4}];
    
    
    UInt32 *time = (UInt32 *)[data0t3 bytes];
    UInt32 *preWeight = (UInt32 *)[data4t7 bytes];
    UInt32 *lastWeight = (UInt32 *)[data8t11 bytes];
    
    NSInteger G = [self.weightG integerValue];
    NSInteger B = [self.weightB integerValue];
    
    NSInteger sumWeight = *preWeight + *lastWeight;
    
    NSInteger w;
    
    if (G == 0 || B == 0)
    {
        w = sumWeight * 4000 + (-1025235);
    }
    else
    {
        w = sumWeight * G + B;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:*time];

    NSString *dateString = [date cst_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    
    return @{@"datetime":dateString,@"weight":@(w),@"AD":@(sumWeight),@"G":@(G),@"B":@(B)};
}



- (NSDictionary *)p_parseToGBWithData:(NSData *)data
{
    
    NSData *data0t3 = [data subdataWithRange:(NSRange){0,4}];
    NSData *data4t7 = [data subdataWithRange:(NSRange){4,4}];
    SInt32 *G = (SInt32 *)[data0t3 bytes];
    SInt32 *B = (SInt32 *)[data4t7 bytes];
    
    return @{ @"G":[NSNumber numberWithInteger:*G],
              @"B":[NSNumber numberWithInteger:*B]
              };
    
}



- (void)p_runMethodAfterDelay:(float)delay withMethod:(void(^)())method
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), method);
}



- (void)p_writeData:(NSData*)data withfirstCmd:(Byte)cmd1 secondCmd:(Byte)cmd2 thirdCmd:(Byte)cmd3 forthCmd:(Byte)cmd4
{
    NSData *data1 = [data subdataWithRange:(NSRange){0,1}];
    NSData *data2 = [data subdataWithRange:(NSRange){1,1}];
    
    NSData *data3 = [data subdataWithRange:(NSRange){2,1}];
    NSData *data4 = [data subdataWithRange:(NSRange){3,1}];
    
    
    
    UInt16 number1 = [self spliceInt16WithFirstData:data1 secondData:[NSData dataWithBytes:&cmd1 length:1]];
    
    UInt16 number2 = [self spliceInt16WithFirstData:data2 secondData:[NSData dataWithBytes:&cmd2 length:1]];
    
    UInt16 number3 = [self spliceInt16WithFirstData:data3 secondData:[NSData dataWithBytes:&cmd3 length:1]];
    
    UInt16 number4 = [self spliceInt16WithFirstData:data4 secondData:[NSData dataWithBytes:&cmd4 length:1]];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        [self writeByte:number1 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
        
        dispatch_after(time, dispatch_get_main_queue(), ^{
            
            [self writeByte:number2 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
            
            dispatch_after(time, dispatch_get_main_queue(), ^{
                
                [self writeByte:number3 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
                
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    
                    [self writeByte:number4 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
                });
                
            });
            
        });
    });
}



#pragma mark - BLE help method 

- (void)writeByte:(UInt16)byte toPeripheral:(CBPeripheral *)p characteristicUUID:(int)characteristicUUID
{
    UInt16 num = [self swap:byte];
    
    NSData *data = [[NSData alloc] initWithBytes:&num length:2];
    
    [self writeValue:0xFFF0 characteristicUUID:0xFFFB p:p data:data];
}

- (void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    
    
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    
    CBService *service = [self findServiceFromUUID:su p:p];
    
    if (!service) {
        
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        
        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}


-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1 length:2];
    [UUID2.data getBytes:b2 length:2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(UInt16)swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}


-(void)readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        // printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p readValueForCharacteristic:characteristic];
}

- (UInt16)spliceInt16WithFirstData:(NSData *)first secondData:(NSData *)second
{
    NSMutableData *mutableData = [NSMutableData dataWithData:first];
    [mutableData appendData:second];
    
    UInt16 result;
    
    [mutableData getBytes:&result length:2];
    return result;
}



#pragma mark - Public method

- (void)scan
{
    if (self.scanning)
    {
        NSLog(@"already Scanning...");
        return;
    }
    
    @weakify(self);
    [self p_runMethodAfterDelay:1.0 withMethod:^{
        
        @strongify(self);
        if (self.centralManager.state == CBCentralManagerStatePoweredOn)
        {
            [self.centralManager scanForPeripheralsWithServices:nil
                                                        options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
            self.scanning = YES;
            NSLog(@"Scanning started");
        }
        
    }];
}

- (void)stopScan
{
    if (!self.scanning)
    {
        return;
    }
    
    [self.centralManager stopScan];
    self.scanning = NO;
}

- (void)configCentralManager
{
    if (!_centralManager)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey : CSTCBCentralManagerRestoreKey}];
    }
    else if(![self isSCanning] && _centralManager.state == CBCentralManagerStatePoweredOn)
    {
        [self scan];
    }
}


- (void)connectPeripheral:(CBPeripheral*)peripheral Options:(NSDictionary*)options
{
    if (self.centralManager && peripheral)
    {
        self.peripheral = peripheral;
        [self.centralManager connectPeripheral:peripheral options:options];
    }
}

- (void)cancelPeripheralConnect
{
    if (self.peripheral)
    {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}


- (void)deleteBindWithHandler:(HandleEvent)handler
{
    if (self.peripheral.state ==  CBPeripheralStateDisconnected )
    {
        if (handler)
        {
            handler();
        }
        return;
    }
    
    if (self.peripheral.state == CBPeripheralStateConnecting)
    {
        if (self.peripheral)
        {
            [self.centralManager cancelPeripheralConnection:self.peripheral];
        }
        if (handler)
        {
            handler();
        }
        return;
    }
    
    [self writeByte:0X1300 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
    
    deleteBindTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(deleteBindTimerFired:) userInfo:@{@"deleteBindInteval" : @1} repeats:NO];
    
    if (handler)
    {
        didDeleteBind = handler;
    }
}

- (void)deleteBindTimerFired:(NSTimer *)timer
{
    
    NSInteger deleteBindInteval = [timer.userInfo[@"deleteBindInteval"] integerValue];
    deleteBindInteval --;
    
    if (deleteBindInteval == 0)
    {
        if (self.peripheral)
        {
            [self.centralManager cancelPeripheralConnection:self.peripheral];
        }
    }
}

- (void)bindPeripheral:(CBPeripheral*)peripheral Options:(NSDictionary*)options success:(HandleEvent)success fail:(HandleEvent)fail
{
    bindTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerFired:) userInfo:@{@"sustainedTime" : @1} repeats:NO];
    [self connectPeripheral:peripheral Options:nil];
    
    didBind = success;
    bindOccurError = fail;
}

- (void)timerFired:(NSTimer *)timer
{
    
    NSInteger sustainedTime = [timer.userInfo[@"sustainedTime"] integerValue];
    
    sustainedTime --;
    if (sustainedTime == 0)
    {
        [bindTimer invalidate];
        NSString *domain = @"蓝牙通信异常，配对失败";
        NSError *error = [NSError errorWithDomain:domain code:CSTBLEBindErrorUnknowCode userInfo:@{CSTBLEBindErrorReasonKey : domain}];
        
        if (bindOccurError) {
            bindOccurError(error);
            bindOccurError = nil;
        }
        
        if (self.peripheral)
        {
            [self.centralManager cancelPeripheralConnection:self.peripheral];
        }
    }
}


#pragma mark - Signals

- (RACSignal *)p_uploadUserDrinkToQQSignalWithCurrentDrink:(NSDictionary *)dic{

    NSDate *date = [NSDate cst_dateWithOriginString:dic[@"datetime"] Format:@"yyyy-MM-dd HH:mm:ss"];
    
    return [[CSTDrinkModel cst_userDrinkWaterSignalWithDate:date] flattenMap:^RACStream *(id value) {
        
        return [[CSTQQManager shareManager] uploadUserDrinkWaterWithParameters:[CSTQQManager upLoadDrinkToQQParametersWithDrinkArray:value date:date]];
    }];
}


- (RACSignal *)p_uploadWaterSignalWithParamters:(NSDictionary *)paramters{
    
    return [[[[self p_uploadWaterAPIManagerWithParamters:paramters] fetchDataSignal] doError:^(NSError *error) {
        
        [CSTDrinkModel cst_saveUserDrink:paramters withDocumentFilName:[CSTDataManager documentCacheFileName]];
        
        if ([CSTDataManager shareManager].loginType == CSTLoginTypeQQ) {
            [[self p_uploadUserDrinkToQQSignalWithCurrentDrink:paramters] subscribeNext:^(id x) {
            }];
        }
    }] doNext:^(id x) {
        
        if ([CSTDataManager shareManager].loginType == CSTLoginTypeQQ) {
            [[self p_uploadUserDrinkToQQSignalWithCurrentDrink:paramters] subscribeNext:^(id x) {
            }];
        }
    }];
}

- (RACSignal *)p_uploadAndFetchTodayWaterSignalWithParamters:(NSDictionary *)paramters{
    
    return [[[self p_uploadWaterSignalWithParamters:paramters]
        flattenMap:^RACStream *(id value) {
        
        return [CSTDrinkModel cst_todayUserDrinkWaterSignal];
        
    }] doNext:^(id x) {
        
        [CSTDrinkModel cst_cacheDrinkModelArray:x withFileName:[CSTDataManager todayUserDrinkCacheFileName]];
    }];

}


- (CSTUploadWaterAPIManager *)p_uploadWaterAPIManagerWithParamters:(NSDictionary *)parameters{

    CSTUploadWaterAPIManager *apiManager = [[CSTUploadWaterAPIManager alloc] init];
    apiManager.parameters = parameters;
    
    return apiManager;
}


- (RACSignal *)p_bindDeviceSignalWithID:(NSString *)deviceID{

    return [[self p_bindDeviceAPIManagerWithID:deviceID] fetchDataSignal];
}


- (CSTBindDeviceAPIManager *)p_bindDeviceAPIManagerWithID:(NSString *)deviceID{

    CSTBindDeviceAPIManager *apiManager = [[CSTBindDeviceAPIManager alloc] init];
    apiManager.parameters = @{@"deviceId":deviceID};
    
    return apiManager;
}






#pragma mark - Water data handler


- (NSDictionary *)calculatCurrentDrinkWithData:(NSDictionary *)waterDic
{
    NSString *userId = [CSTDataManager shareManager].userProfile.uid;
    NSString *lastCacheFile = [NSString stringWithFormat:@"%@-lastWeight",userId];
    NSData *lastData = [[GHDocumentCache shareCache] dataFromFile:lastCacheFile];
    NSMutableDictionary *currentDrinkDic = [NSMutableDictionary dictionary];

    NSDate *thisDate = [NSDate cst_dateWithOriginString:waterDic[@"datetime"] Format:@"yyyy-MM-dd HH:mm:ss"];
    
    
    if ([self lastMeasureIsvalidWithCurrentDate:thisDate])
    {
        NSDictionary *lastDic = [NSKeyedUnarchiver unarchiveObjectWithData:lastData]
        ;
        NSInteger drinkWeight = - ([waterDic[@"weight"] integerValue] - [lastDic[@"weight"] integerValue]);
        
        if (drinkWeight > 0 && drinkWeight < 400 * 1000)
        {
            currentDrinkDic[@"weight"] = @(drinkWeight);
            currentDrinkDic [@"datetime"] = waterDic[@"datetime"];
        }
    }
    
    NSData *currentData = [NSKeyedArchiver archivedDataWithRootObject:waterDic];
    [[GHDocumentCache shareCache] cacheData:currentData tofile:lastCacheFile];
    
    if ([currentDrinkDic count] <= 0)
    {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:currentDrinkDic];
}

- (BOOL)lastMeasureIsvalidWithCurrentDate:(NSDate *)date
{
    NSString *userId = [CSTDataManager shareManager].userProfile.uid;
    NSString *lastCacheFile = [NSString stringWithFormat:@"%@-lastWeight",userId];
    NSData *lastData = [[GHDocumentCache shareCache] dataFromFile:lastCacheFile];
    if (!lastData)
    {
        return NO;
    }
    
    NSDictionary *lastDic = [NSKeyedUnarchiver unarchiveObjectWithData:lastData]
    ;
    
    if ([lastDic[@"datetime"] hasPrefix:@"1970"])
    {
        return NO;
    }

    NSDate *lastDate =  [NSDate cst_dateWithOriginString:lastDic[@"datetime"]  Format:@"yyyy-MM-dd HH:mm:ss"];
    
    NSLog(@"lastDate == %@",lastDate.description);
    
    if (fabs([lastDate timeIntervalSinceDate:date]) >  (60 * 60 * 4))
    {
        return NO;
    }

    NSData *data = [[GHCache shareCache] dataFromFile:[CSTDataManager todayUserDrinkCacheFileName]];
    
    if (data)
    {
        NSArray *orderArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        CSTDrinkModel *drink = [orderArray lastObject];
        if (drink)
        {
            if ([drink.date compare:lastDate] == NSOrderedDescending)
            {
                return NO;
            }
            return YES;
        }
        return YES;
    }
    return YES;
}
#pragma mark - Firmware update

- (void)downLoadAndUpdateFirmware
{
    MBProgressHUD *hud = (MBProgressHUD*)[self configHud];
    
    [self configOADProfileWithHud:hud];
    CSTUpdateFirmwareView *updateView = (CSTUpdateFirmwareView*)hud.customView;
    
    
    NSString *downloadAdress = nil;
    
    if ([self.peripheral.cst_fmVersion.type isEqualToString:@"A"])
    {
        downloadAdress = self.serviceVersion.downloadAddressB;
        updateView.detailLabel.text = @"杯垫里的固件为A版本,正在下载B版本";
    }
    else
    {
        downloadAdress = self.serviceVersion.downloadAddressA;
        updateView.detailLabel.text = @"杯垫里的固件为B版本,正在下载A版本";
    }
    
    NSString *urlString = [downloadAdress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    @weakify(self);
    
    NSURLSessionDownloadTask *task = [[CSTNetworkManager shareManager] downloadTaskWithURLRequest:request toFilePath:[GHCache cachePath] completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        @strongify(self);
        if (error)
        {
            [hud hide:NO];
            [DXAlertView showAlertWithTitle:@"网络异常" contentText:@"网络出现故障，更新中断" leftButtonTitle:nil rightButtonTitle:@"确定"];
            return ;
        }
        
        if (self.peripheral.state != CBPeripheralStateConnected)
        {
            [hud hide:NO];
            [DXAlertView showAlertWithTitle:@"蓝牙断开" contentText:@"蓝牙断开连接，更新中断" leftButtonTitle:nil rightButtonTitle:@"确定"];
            return;
        }
        
        updateView.detailLabel.text = @"正在升级固件...";
        
        [self p_prepareForUpdateFirmware];
        
        [self p_runMethodAfterDelay:60.0f withMethod:^{
            
            [self updateFirmwareWithFilePath:[filePath path]];
        }];
    }];
    
    [updateView setProgressWithDownloadProgressOfTask:task animated:YES];
}

- (void)p_prepareForUpdateFirmware
{
    [self p_runMethodAfterDelay:0.5f withMethod:^{
        [self setMeasureIntervalToMax];
    }];
    
    [self p_runMethodAfterDelay:1.0f withMethod:^{
        [self setBleChangeRateWithoutautomatic];
    }];
    
    [self p_runMethodAfterDelay:1.5f withMethod:^{
        [self setBleHighRate];
    }];
}


- (void)setMeasureIntervalToMax//设置测量间隔最大
{
    [self writeByte:0x18FF toPeripheral:self.peripheral characteristicUUID:0xFFFB];
}

- (void)setBleChangeRateWithoutautomatic //设置蓝牙不自动更新连接频率
{
    [self writeByte:0x2B00 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
}

- (void)setBleHighRate //设置蓝牙高频通信
{
    [self writeByte:0x2A00 toPeripheral:self.peripheral characteristicUUID:0xFFFB];
}



- (UIView*)configHud
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    hud.removeFromSuperViewOnHide = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    
    CSTUpdateFirmwareView *updateView = [[CSTUpdateFirmwareView alloc] initWithFrame:CGRectZero];
    
    hud.cornerRadius = 4.0f;
    
    
    hud.customView = updateView;
    updateView.titleLabel.text = @"固件升级";
    updateView.detailLabel.text = @"正在下载对应版本固件";
    
    updateView.titleLabel.textColor = [UIColor whiteColor];
    updateView.detailLabel.textColor = [UIColor whiteColor];
    
    hud.color = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.9f];
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
    return hud;
}

- (void)updateFirmwareWithFilePath:(NSString *)filePath
{
    [self.oadProfile validateImage:filePath];
}


- (void)configOADProfileWithHud:(MBProgressHUD *)hud
{
    BLEDevice *dev = [[BLEDevice alloc]init];
    dev.p = self.peripheral;
    dev.manager = self.centralManager;
    self.oadProfile = [[BLETIOADProfile alloc]initWithDevice:dev];
    //self.oadProfile.progressView = [[BLETIOADProgressViewController alloc]init];
    self.oadProfile.hud = hud;
    [self.oadProfile makeConfigurationForProfile];
    [self.oadProfile configureProfile];
}



#pragma mark - Setters and getters


@end
