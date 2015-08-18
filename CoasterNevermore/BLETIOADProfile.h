/*
 BLETIOADProfile.h
 TIOADExample

 Created by Ole Andreas Torvmark on 11/22/12.
 Copyright (c) 2013 Texas Instruments. All rights reserved.

 */

#import "oad.h"
#import "BLEDevice.h"
#import "BLETIOADProgressViewController.h"
#import "CSTUpdateFirmwareView.h"
#import "MBProgressHUD.h"

#define HI_UINT16(a) (((a) >> 8) & 0xff)
#define LO_UINT16(a) ((a) & 0xff)

@interface BLETIOADProfile : NSObject <UIActionSheetDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) NSData *imageFile;

@property (strong,nonatomic) BLEDevice *d;
@property (strong,nonatomic) UIView *view;
//@property (strong,nonatomic) BLETIOADProgressViewController *progressView;
//@property (strong,nonatomic) CSTUpdateFirmwareView *updateFirmwareView;
@property (strong,nonatomic) MBProgressHUD *hud;

@property int nBlocks;
@property int nBytes;
@property int iBlocks;
@property int iBytes;
@property BOOL canceled;
@property BOOL inProgramming;
@property BOOL start;
@property (nonatomic,retain) NSTimer *imageDetectTimer;
@property uint16_t imgVersion;
@property UINavigationController *navCtrl;

@property (nonatomic, strong) NSString *filePath;

//In case of iOS 7.0

-(id) initWithDevice:(BLEDevice *) dev;
-(void) makeConfigurationForProfile;
-(void) configureProfile;
-(void) deconfigureProfile;
-(void) didUpdateValueForProfile:(CBCharacteristic *)characteristic;
-(void)deviceDisconnected:(CBPeripheral *)peripheral;

-(void) uploadImage:(NSString *)filename;

-(IBAction)selectImagePressed:(id)sender;

-(void) programmingTimerTick:(NSTimer *)timer;
-(void) imageDetectTimerTick:(NSTimer *)timer;

-(NSMutableArray *) findFWFiles;

-(BOOL) validateImage:(NSString *)filename;
-(BOOL) isCorrectImage;
-(void) completionDialog;



@end
