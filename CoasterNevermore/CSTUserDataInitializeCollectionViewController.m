//
//  CSTUserdataInitializeCollectionViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/6/21.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTUserDataInitializeCollectionViewController.h"
#import "CSTUserDataInitialViewModel.h"
#import "CSTInitialDataCollectionViewCell.h"
#import "Colours.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSTBLEConnectViewController.h"
#import "CSTRouter.h"

@interface CSTUserDataInitializeCollectionViewController ()

@property (nonatomic, strong) UIButton *backwardButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIImageView *separater;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSArray *forwardButtonConstraints;
@property (nonatomic, strong) NSArray *allButtonsConstraints;

@end

@implementation CSTUserDataInitializeCollectionViewController

static NSString * const reuseIdentifier = @"InitialDataCell";

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_configSubviews];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.viewModel.userDataInitialCellModels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSTInitialDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.viewModel = self.viewModel.userDataInitialCellModels[indexPath.row];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentPage = floor(self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.frame));
   [self  p_modifyConstraintsWithCurrentPage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.currentPage = floor(self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.frame));
    [self  p_modifyConstraintsWithCurrentPage];
}


#pragma mark - Private method
- (void)p_configSubviews{
    
    [self p_configCollectionView];
    [self p_configForwardButton];
    [self p_configBackwardButton];
    [self p_configSeparater];
    [self p_configConstraints];
}

- (void)p_configCollectionView{

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.minimumLineSpacing = 0.0f;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
}

- (void)p_configForwardButton{

    [self.view addSubview:self.forwardButton];
    
    @weakify(self);
    self.forwardButton.rac_command = [[RACCommand alloc] initWithEnabled:[self p_forwardSignal] signalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        if (self.currentPage < 3) {
            
            [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds) * (self.currentPage + 1) , 0.0f) animated:YES];
            //self.currentPage ++;
            //[self  p_modifyConstraintsWithCurrentPage];
            return [RACSignal empty];
        }
        if (self.currentPage == 3){
            
            if ([self.viewModel isUserOwndevice]) {
                
                [CSTRouter routerToViewControllerType:CSTRouterViewControllerTypeMain fromViewController:self];
            }
            UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"CSTLogin" bundle:nil];
            
            UIViewController *vc = [storybard instantiateViewControllerWithIdentifier:@"CSTBLEConnectViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        
            return [[[self.viewModel updateUserInformationSignal] deliverOnMainThread] doNext:^(id x) {
                
            }];
        }
        return [RACSignal empty];
    }];
}

- (void)p_configBackwardButton{
    
    [self.view addSubview:self.backwardButton];
    
    @weakify(self);
    [[self.backwardButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds) * (self.currentPage - 1) , 0.0f) animated:YES];
        //self.currentPage --;
        //[self  p_modifyConstraintsWithCurrentPage];
    }];
}

- (void)p_configSeparater{
    
    [self.view addSubview:self.separater];

}

- (void)p_configConstraints{
    
    [NSLayoutConstraint activateConstraints:self.forwardButtonConstraints];
}

- (void)p_modifyConstraintsWithCurrentPage{

    if (self.currentPage < 0)
    {
        return;
    }
    
    if (self.currentPage == 0) {
        
        [NSLayoutConstraint deactivateConstraints:self.allButtonsConstraints];
        [NSLayoutConstraint activateConstraints:self.forwardButtonConstraints];
        [self.view layoutSubviews];
        return;
    }
    
    if (self.currentPage > 0) {
        
        [NSLayoutConstraint deactivateConstraints:self.forwardButtonConstraints];
        [NSLayoutConstraint activateConstraints:self.allButtonsConstraints];
        [self.view layoutSubviews];
        return;
    }
}

- (RACSignal *)p_forwardSignal{

    @weakify(self);
    return [RACObserve(self,currentPage) flattenMap:^RACStream *(id value) {
        
        @strongify(self);
        return [self.viewModel forwardSignalWithCurrentPage: [value integerValue]];
    }];
}

#pragma mark - Setters and getters

- (CSTUserDataInitialViewModel *)viewModel
{
    if (!_viewModel) {
        
        _viewModel = [[CSTUserDataInitialViewModel alloc] init];
    }

    return _viewModel;
}



- (UIButton *)forwardButton{

    if (!_forwardButton) {
        
        _forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_forwardButton setTitle:@"下一步" forState:UIControlStateNormal];
        _forwardButton.tintColor = [UIColor whiteColor];
        _forwardButton.backgroundColor = [UIColor colorFromHexString:@"2baef0"];
    }
    
    return _forwardButton;
}

- (UIButton *)backwardButton{
    if (!_backwardButton) {
        
        _backwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backwardButton setTitle:@"上一步" forState:UIControlStateNormal];
        _backwardButton.tintColor = [UIColor whiteColor];
        _backwardButton.backgroundColor = [UIColor colorFromHexString:@"2baef0"];
    }
    
    return _backwardButton;
}

- (UIImageView *)separater
{
    if (!_separater) {
        
        _separater = [[UIImageView alloc] init];
        _separater.backgroundColor = [UIColor lightTextColor];
    }
  return  _separater;
}

- (NSArray *)forwardButtonConstraints{
    if (!_forwardButtonConstraints) {
        
        self.separater.translatesAutoresizingMaskIntoConstraints = NO;
        self.forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.backwardButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_separater,_forwardButton,_backwardButton);
        
        NSString *vf1 = @"V:[_forwardButton(60)]-|";
        NSString *vf2 = @"H:|-0-[_backwardButton(0)]-0-[_forwardButton]-0-|";
        NSString *vf3 = @"V:[_backwardButton(0)]-|";
        NSString *vf4 = @"V:[_separater(0)]-0-|";
        
       
        NSArray *constraints1 = [NSLayoutConstraint constraintsWithVisualFormat:vf1 options:0 metrics:nil views:viewsDictionary];
        NSArray *constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:vf2 options:0 metrics:nil views:viewsDictionary];
        NSArray *constraints3 = [NSLayoutConstraint constraintsWithVisualFormat:vf3 options:0 metrics:nil views:viewsDictionary];
        NSArray *constraints4 = [NSLayoutConstraint constraintsWithVisualFormat:vf4 options:0 metrics:nil views:viewsDictionary];
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        [mutableArray addObjectsFromArray:constraints1];
        [mutableArray addObjectsFromArray:constraints2];
        [mutableArray addObjectsFromArray:constraints3];
        [mutableArray addObjectsFromArray:constraints4];
        
        _forwardButtonConstraints = [NSArray arrayWithArray:mutableArray];
    }
    
    return _forwardButtonConstraints;
}

- (NSArray *)allButtonsConstraints{

    if (!_allButtonsConstraints) {
        
        self.separater.translatesAutoresizingMaskIntoConstraints = NO;
        self.forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.backwardButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_separater,_forwardButton,_backwardButton);
        
        NSString *midWidth =  [NSString stringWithFormat:@"%f",CGRectGetMidX(self.view.bounds)];
        
        NSString *vf1 = @"V:[_forwardButton(60)]-|";
        NSString *vf2 = [NSString stringWithFormat:@"H:|-0-[_backwardButton(%@)]-0-[_forwardButton]-0-|",midWidth];
        NSString *vf3 = @"V:[_backwardButton(60)]-|";
        NSString *vf4 = @"V:[_separater(30)]-15-|";
        
        NSLayoutConstraint *separaterConstraintCenterX = [NSLayoutConstraint constraintWithItem:self.separater attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
     
        NSLayoutConstraint *separaterConstraintWidth = [NSLayoutConstraint constraintWithItem:self.separater attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5];
        
        
        NSArray *constraints1 = [NSLayoutConstraint constraintsWithVisualFormat:vf1 options:0 metrics:nil views:viewsDictionary];
        NSArray *constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:vf2 options:0 metrics:nil views:viewsDictionary];
        
        NSArray *constraints3 = [NSLayoutConstraint constraintsWithVisualFormat:vf3 options:0 metrics:nil views:viewsDictionary];
        NSArray *constraints4 = [NSLayoutConstraint constraintsWithVisualFormat:vf4 options:0 metrics:nil views:viewsDictionary];
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        [mutableArray addObjectsFromArray:constraints1];
        [mutableArray addObjectsFromArray:constraints2];
        [mutableArray addObjectsFromArray:constraints3];
        [mutableArray addObjectsFromArray:constraints4];
        [mutableArray addObject:separaterConstraintCenterX];
        [mutableArray addObject:separaterConstraintWidth];
        
        
        _allButtonsConstraints = [NSArray arrayWithArray:mutableArray];
    }
    
    return _allButtonsConstraints;
}

@end
