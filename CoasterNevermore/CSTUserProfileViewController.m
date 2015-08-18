//
//  CSTUserProfileViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/3.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserProfileViewController.h"
#import "Colours.h"
#import "CSTUserProfileViewModel.h"
#import "CSTBasicCellModel.h"
#import <ReactiveCocoa.h>
#import "CSTUpdateUserProfileViewController.h"

@interface CSTUserProfileViewController () <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) UIAlertAction *cancelAction;
@property (strong, nonatomic) UIAlertAction *cameraAction;
@property (strong, nonatomic) UIAlertAction *photoLibararyAction;
@property (strong, nonatomic) UIImagePickerController *imagePickViewController;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;



@end

@implementation CSTUserProfileViewController

#pragma mark - Life cycle
- (void)viewDidLoad{

    [super viewDidLoad];
    [self p_configNavigationBar];
    [self p_configSubViews];
    [self p_configObservers];
    
}

- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    [self p_configAvatarImageViewAfterViewdidLayout];
}



#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.viewModel.profileItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSTUserProfileCell"];
    
    [self p_configCell:cell WithItem:self.viewModel.profileItems[indexPath.row]];
    return cell;
}

#pragma mark - TableView delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 44.0 / 667.0 * CGRectGetHeight([UIScreen mainScreen].bounds);
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0 / 667.0 * CGRectGetHeight([UIScreen mainScreen].bounds);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.avatarImageView.userInteractionEnabled) {
     
        CSTUpdateUserProfileViewController * updateUserProfileViewController = [self p_updateUserprofileViewControllerWithType:(CSTUserProfileType)(indexPath.row)];
        [self.viewModel configCurrentUpdateViewmodel];
        [self.navigationController pushViewController: updateUserProfileViewController animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    self.viewModel.editImage = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private method


- (void)p_configNavigationBar{

    self.navigationItem.title = @"基本资料";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)p_configSubViews{

    [self p_configSaveButton];
    [self p_configTableView];
    [self p_configBottmView];
    [self p_configUsernameLabel];
    [self p_configAvatarImageView];
}

- (void)p_configSaveButton{

    self.saveButton.layer.cornerRadius = 22.0;
    self.saveButton.layer.borderWidth = 1.0;
    self.saveButton.layer.borderColor = [UIColor waveColor].CGColor;
    
    @weakify(self);
    RACSignal *buttonEnableSignal = [[self.viewModel EditSignal] doNext:^(id x) {
        
        @strongify(self);
        if (!self.navigationItem.hidesBackButton) {
         
            self.saveButton.layer.borderColor = [x boolValue] ? [UIColor waveColor].CGColor : [UIColor lightGrayColor].CGColor;
        }
    }];
    
    self.saveButton.rac_command = [[RACCommand alloc] initWithEnabled:buttonEnableSignal signalBlock:^RACSignal *(id input) {
        
        [self p_disableUserInterface];
        return [[[self.viewModel updateUserProfileSignal] doNext:^(id x) {
            
            [self p_enableUserInterface];
            
        }] doError:^(NSError *error) {
            
            [self p_enableUserInterface];
        }];
    }];
}



- (void)p_disableUserInterface{

    [self p_addIndicatorViewToButton:self.saveButton];
    self.saveButton.enabled = NO;
    self.saveButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.saveButton setTitle:@"" forState:UIControlStateNormal];
     self.avatarImageView.userInteractionEnabled = NO;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self.tableView reloadData];
}

- (void)p_enableUserInterface{
    
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
    
    if ([self.viewModel isUserProfieCanBeModified]) {
        
        self.saveButton.enabled = YES;
        self.saveButton.layer.borderColor = [UIColor waveColor].CGColor;
    }
    
    [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
    self.avatarImageView.userInteractionEnabled = YES;
    
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    [self.tableView reloadData];
    
}

- (void)p_addIndicatorViewToButton:(UIButton *)button{

    
    self.indicatorView.center = CGPointMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds));
    [button addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}

- (void)p_configTableView{

    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
    self.tableView.scrollEnabled = NO;
    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tableView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    self.tableView.layer.shadowOpacity = 0.1;
    self.tableView.layer.masksToBounds = NO;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){
    
        .origin.x = 0.0,
        .origin.y = 0.0,
        .size.width = 0.0,
        .size.height = CGFLOAT_MIN,
    
    }];
    
}

- (void)p_configBottmView{

    self.bottomView.layer.shadowOffset = CGSizeMake(0.0, -0.5);
    self.bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomView.layer.shadowOpacity = 0.1;
    self.bottomView.layer.masksToBounds = NO;
}

- (void)p_configUsernameLabel{

    RAC(self.userNameLabel,text) = RACObserve(self.viewModel, username);
}

- (void)p_configAvatarImageView{
    
    [self.avatarImageView addGestureRecognizer:self.tap];
    self.avatarImageView.userInteractionEnabled = YES;

    RAC(self.avatarImageView,image) = [RACObserve(self.viewModel, avatarImage) ignore:nil];
}
- (void)p_configAvatarImageViewAfterViewdidLayout{

    self.avatarImageView.layer.cornerRadius = CGRectGetMidX(self.avatarImageView.bounds);
    self.avatarImageView.layer.masksToBounds = YES;
}


- (void)p_configCell:(UITableViewCell *)cell WithItem:(CSTBasicCellModel *)item{
    
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.detail;
    
    if (!self.navigationItem.hidesBackButton) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
    
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (CSTUpdateUserProfileViewController *)p_updateUserprofileViewControllerWithType:(CSTUserProfileType)type{
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CSTMainStoryboard" bundle:nil];
    
    CSTUpdateUserProfileViewController *p_updateUserprofileViewController = [storyboard instantiateViewControllerWithIdentifier:@"CSTUpdateUserProfileViewController"];
    
    self.viewModel.updateViewModel.userProfileType = type;
    p_updateUserprofileViewController.viewModel = self.viewModel.updateViewModel;
    
    return p_updateUserprofileViewController;
}


#pragma mark - Observers

- (void)p_configObservers{

    [self p_configObserverWithProfileItems];
}

- (void)p_configObserverWithProfileItems{
    
     @weakify(self);
     [RACObserve(self.viewModel, profileItems) subscribeNext:^(id x) {
        
         @strongify(self);
         
         [self.tableView reloadData];
         
     }];
}



#pragma mark - Setters and getters

- (CSTUserProfileViewModel *)viewModel{

    if (!_viewModel) {
        
        _viewModel = [[CSTUserProfileViewModel alloc] init];
    }
    
    return _viewModel;
}

- (UITapGestureRecognizer *)tap{

    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc] init];
        
        @weakify(self);
        [[_tap rac_gestureSignal] subscribeNext:^(id x) {
            
            @strongify(self);
            
            
            [self presentViewController:self.alertController animated:YES completion:nil];
        }];
    }
    
    return _tap;
}


- (UIAlertController*)alertController{

    if (!_alertController) {
        
        _alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [_alertController addAction:self.cancelAction];
        [_alertController addAction:self.photoLibararyAction];
        [_alertController addAction:self.cameraAction];
    }
    return _alertController;
}

- (UIAlertAction *)cancelAction{

    if (!_cancelAction) {
        
       _cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    return _cancelAction;
}

- (UIAlertAction *)cameraAction{
    
    if (!_cameraAction) {
        
        @weakify(self);
        _cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            @strongify(self);
             self.imagePickViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickViewController animated:YES completion:nil];
        }];
    }
    
    return _cameraAction;
}

- (UIAlertAction *)photoLibararyAction{
    
    if (!_photoLibararyAction) {
        
        @weakify(self);
        _photoLibararyAction = [UIAlertAction actionWithTitle:@"照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            @strongify(self);
            self.imagePickViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePickViewController animated:YES completion:nil];
        }];
    }
    
    return _photoLibararyAction;
}

- (UIImagePickerController *)imagePickViewController{

    if (!_imagePickViewController) {
        
        _imagePickViewController = [[UIImagePickerController alloc] init];
        _imagePickViewController.delegate = self;
        _imagePickViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickViewController.allowsEditing = YES;
    }
    return _imagePickViewController;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _indicatorView;
}


@end
