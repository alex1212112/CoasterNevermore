//
//  CSTDetailDataViewController.m
//  CoasterNevermore
//
//  Created by Ren Guohua on 15/7/20.
//  Copyright (c) 2015年 Ren guohua. All rights reserved.
//

#import "CSTDetailDataViewController.h"
#import "CSTDetailDateCell.h"
#import "CSTDetailDataViewModel.h"
#import "Colours.h"
#import "CSTUmeng.h"

#import "CPTLineStyle+CSTExtention.h"
#import "NSString+CSTExtention.h"
#import <NSArray+LinqExtensions.h>
#import "NSDate+CSTTransformString.h"
#import "UIView+CSTExtention.h"

#import <CorePlot/ios/CorePlot-CocoaTouch.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString *const CSTScatterPlotIdentifier = @"com.nevermore.Coaster.CSTScatterPlotIdentifier";
static NSString *const CSTPlanBarPlotIdentifier = @"com.nevermore.Coaster.CSTPlanBarPlotIdentifier";
static NSString *const CSTDrinkBarPlotIdentifier = @"com.nevermore.Coaster.CSTDrinkBarPlotIdentifier";
static const NSTimeInterval kSecondsInOneDay = 24 * 60 * 60;

@interface CSTDetailDataViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,CPTPlotDataSource, CPTAxisDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet CPTGraphHostingView *plotHostingView;
@property (weak, nonatomic) IBOutlet UIView *plotBackgroundView;

@property (weak, nonatomic) IBOutlet UIImageView *topLineView;

@property (weak, nonatomic) IBOutlet UILabel *plotDrinkLabel;
@property (weak, nonatomic) IBOutlet UIImageView *plotMiddleLineView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *barChartHostingView;

@property (nonatomic, strong) UISegmentedControl *titleSegment;
@property (nonatomic, strong) CPTXYGraph *plotGraph;
@property (nonatomic, strong) CPTScatterPlot *scatterPlot;
@property (nonatomic, strong) CPTPlotSymbol *normalSymbol;
@property (nonatomic, strong) CPTPlotSymbol *selectedSymbol;

@property (nonatomic, strong) CPTXYGraph *barchartGraph;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger oldSelectedIndex;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, assign) NSInteger collectionViewSelectedIndex;

@property (nonatomic, strong) CPTBarPlot *planBarPlot;
@property (nonatomic, strong) CPTBarPlot *drinkBarPlot;
@property (nonatomic, copy) NSSet *barchartXLabelSet;



@end
@implementation CSTDetailDataViewController

#pragma mark - Life cycle

- (void)viewDidLoad{

    [super viewDidLoad];
    [self.viewModel refreshCurrentPageData];
    [self p_configSubViews];

}
#pragma mark - CollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [self.viewModel.historyDrinkShowDateArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    CSTDetailDateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSTDetailDateCell" forIndexPath:indexPath];

    [self p_configCell:cell indexPath:indexPath];
    
    return cell;
}


#pragma mark - CollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.view.bounds) / 7 * 60.0 / 106.0 , 30.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{

    return CGRectGetWidth(self.view.bounds) / 7 * 46.0 / 106.0;
}

#pragma mark - CollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.item < 3 || indexPath.item >= [self.viewModel.historyDrinkShowDateArray count] - 3){
    
        return;
    }
    
    if (indexPath.item == self.collectionViewSelectedIndex) {
        
        return;
    }

    [self p_scrollCollectionViewBySelectedIndexWithIndexPath:indexPath];
    [self p_resetSymbolBySelectedIndexWithScatterPlot];
    [self p_resetXrangeBySelectedIndexWithScatterPlot];
    [self p_loadDataWithTopDrinkLabel];
    [self p_resetDrinkBarPlotBySelectedIndex];
    [self p_resetPlanBarPlotBySelectedIndex];
}


#pragma mark - Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([plot.identifier isEqual:CSTScatterPlotIdentifier])
    {
        return [self.viewModel.historyDrinkArray count];
    }
    
    if ([plot.identifier isEqual:CSTPlanBarPlotIdentifier]) {
        
        return 6;
    }
    if ([plot.identifier isEqual:CSTDrinkBarPlotIdentifier]) {
        
        return 6;
    }
    
    return 0;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    
    if ([(NSString *)plot.identifier isEqualToString:CSTScatterPlotIdentifier]){
 
        if (fieldEnum == CPTScatterPlotFieldX) {
            
            NSDate *beginDate = [self.viewModel.historyDrinkArray[0] valueForKey:@"date"];
            NSDate *date =  [[self.viewModel.historyDrinkArray objectAtIndex:index] valueForKey:@"date"];
            
            return @([date timeIntervalSinceDate:beginDate]);
            
        }else if (fieldEnum == CPTScatterPlotFieldY){
        
            NSNumber *value = [[self.viewModel.historyDrinkArray objectAtIndex:index] valueForKey:@"weight"];
            
            value = @([value integerValue] / 1000.0);
            
            if ([value integerValue] > 3000) {
                return @3000;
            }
            return value;
        }
       
        return nil;
    }
    
    if ([plot.identifier isEqual:CSTPlanBarPlotIdentifier]) {
        
        
        if (fieldEnum == CPTScatterPlotFieldX) {
            
            return @(index * 3 + 1.5);
            
        }else if (fieldEnum == CPTScatterPlotFieldY){
            
            NSInteger suggest = [self.viewModel.barchartSuggestArray[index] integerValue] + 20.0;
            if (suggest > 800) {
                
                return @800;
            }
            if (suggest < 80 && suggest > 20) {
                
                return @80;
            }
            return @(suggest);
        }
    }
    
    if ([plot.identifier isEqual:CSTDrinkBarPlotIdentifier]) {
        
        
        if (fieldEnum == CPTScatterPlotFieldX) {
            
            return @(index * 3 + 1.5);
            
        }else if (fieldEnum == CPTScatterPlotFieldY){
            
            NSInteger drink = [self.viewModel.barchartDrinkArray[index] integerValue] / 1000.0 + 20.0;
            if (drink > 800) {
                
                return @800;
            }
            if (drink < 80 && drink > 20) {
                
                return @80;
            }
            return @(drink);
        }
    }
    
    return nil;
}

#pragma mark - Plot delegate

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    if ( [(NSString *)plot.identifier isEqualToString : CSTScatterPlotIdentifier] ) {
        self.oldSelectedIndex = self.selectedIndex;
        self.selectedIndex = (NSInteger)index;
        if ( self.oldSelectedIndex != NSNotFound ) {
            [self.scatterPlot reloadPlotSymbolsInIndexRange:NSMakeRange( (NSUInteger)self.oldSelectedIndex, 1 )];
        }
        if ( self.selectedIndex != NSNotFound ) {
            [self.scatterPlot reloadPlotSymbolsInIndexRange:NSMakeRange( (NSUInteger)self.selectedIndex, 1 )];
        }
    }
}


-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index
{
    if ( [(NSString *)plot.identifier isEqualToString : CSTScatterPlotIdentifier] && ((NSInteger)index == self.selectedIndex)) {
        return self.selectedSymbol;
    }
    return self.normalSymbol;
}



#pragma mark - Privte method

- (void)p_configSubViews{

    [self p_configNavigationBar];
    [self p_configCollectionView];
    [self p_configPlotView];
    [self p_configTopLineView];
    [self p_configTopDrinkLabel];
    [self p_configBarchartView];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)p_configCollectionView{

    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    CGFloat inset = CGRectGetWidth(self.view.bounds) / 7 * 46.0 / 106.0 / 2.0;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, inset, 0.0, inset);
    
    @weakify(self);
    
    
    [[RACObserve(self.viewModel, historyDrinkShowDateArray) ignore:nil] subscribeNext:^(id x) {
        
        @strongify(self);
        
        if (self.collectionViewSelectedIndex <= 2 || self.collectionViewSelectedIndex >= [x count] - 3) {
            
            if ([x count] >= 13) {
                
                self.collectionViewSelectedIndex = [x count] - 6 - 1;
            }else if ([x count] >= 7)
                self.collectionViewSelectedIndex = [x count] - 3 - 1;
        }
        
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.collectionViewSelectedIndex + 3 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        
        
    }];
}

- (void)p_configNavigationBar{

    self.navigationItem.titleView = self.titleSegment;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(p_share:)];
}

- (void)p_configTopLineView{


}

- (void)p_configTopDrinkLabel{
    
    self.plotDrinkLabel.layer.cornerRadius = 11.0;
    self.plotDrinkLabel.layer.masksToBounds = YES;
}

- (void)p_configPlotView{

    self.plotHostingView.hostedGraph = self.plotGraph;
 
    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)self.plotGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0f) length:CPTDecimalFromDouble(kSecondsInOneDay * 6 )];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-80.0f) length:CPTDecimalFromFloat(3200.0f)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.plotGraph.axisSet;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 1.0;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:178.0/255.0 green:229.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    CPTXYAxis * x = axisSet.xAxis;
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.axisLineStyle = lineStyle;
    
    
    CPTXYAxis * y = axisSet.yAxis;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.axisLineStyle = lineStyle;
    
    y.hidden = YES;
    
    self.scatterPlot.dataSource = self;
    self.scatterPlot.delegate = self;
    self.scatterPlot.identifier = CSTScatterPlotIdentifier;
    
    lineStyle.lineColor = [CPTColor whiteColor];
    self.scatterPlot.dataLineStyle = lineStyle;

    CPTColor * topColor = [CPTColor colorWithComponentRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0];
    CPTColor * bottomColor = [CPTColor colorWithComponentRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:0.1f];
    CPTGradient * areaGradient = [CPTGradient gradientWithBeginningColor:topColor  endingColor:bottomColor];
    areaGradient.angle = -90.0f;
    CPTFill * areaGradientFill  = [CPTFill fillWithGradient:areaGradient];
    self.scatterPlot.areaFill      = areaGradientFill;
    self.scatterPlot.areaBaseValue = CPTDecimalFromDouble(0.0); // 渐变色的起点位置
   
    self.scatterPlot.plotSymbol = self.normalSymbol;
    
    [self.plotGraph addPlot:self.scatterPlot];
    
    self.plotHostingView.hidden = NO;
    self.plotDrinkLabel.hidden = NO;
    self.plotMiddleLineView.hidden = NO;
    
    @weakify(self);
    [[RACObserve(self.viewModel, historyDrinkArray) ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        
        if (self.selectedIndex == 0 || self.selectedIndex >= [x count]) {
            self.selectedIndex = [self.viewModel defaultSelectedIndexWithArry:x];
            self.selectedDate = [self.viewModel defaultSelectedDateWithArry:x];
        }
        [self p_reloadScatterPlot];
        [self p_loadDataWithTopDrinkLabel];
    }];
}



- (void)p_reloadScatterPlot{

    NSDate *refDate = [self.viewModel.historyDrinkArray[0] valueForKey:@"date"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    
    CPTXYAxisSet *resetAxisSet = (CPTXYAxisSet *)self.plotGraph.axisSet;
    
    CPTXYAxis * resetX = resetAxisSet.xAxis;
    resetX.labelFormatter = timeFormatter;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.plotGraph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(([self.viewModel.historyDrinkArray count] - 7) * kSecondsInOneDay) length:CPTDecimalFromDouble(kSecondsInOneDay * 6)];
    
    [self.plotGraph reloadData];
}



- (void)p_configCell:(CSTDetailDateCell *)cell indexPath:(NSIndexPath *)indexPath{
    
    cell.date = self.viewModel.historyDrinkShowDateArray[indexPath.row];
    
    if (indexPath.row == self.collectionViewSelectedIndex) {
        
        cell.titleColor =  [UIColor colorFromHexString:@"15aaf2"];
        
    }else if (indexPath.row < 3 || indexPath.row >= [self.viewModel.historyDrinkShowDateArray count] - 3){
        
        cell.titleColor =  [UIColor lightGrayColor];
        
    }else{
        
        cell.titleColor =  [UIColor darkGrayColor];
    }
}


- (void)p_scrollCollectionViewBySelectedIndexWithIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item > self.collectionViewSelectedIndex) {
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item + 3 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }else{
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item - 3 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    
    self.collectionViewSelectedIndex = indexPath.item;
    [self.collectionView reloadData];
}

- (void)p_loadDataWithTopDrinkLabel{

    if ([self.viewModel.historyDrinkArray count] == 0) {
        
        return;
    }
    
    NSNumber *weightNumber = [self.viewModel.historyDrinkArray[self.selectedIndex] valueForKey:@"weight"];
    
    NSInteger weightInteger = [weightNumber integerValue] / 1000;
    
    NSString *weight = [NSString stringWithFormat:@"%ldml",(long)weightInteger];
    
    self.plotDrinkLabel.text = weight;
}

- (void)p_resetSymbolBySelectedIndexWithScatterPlot{

    self.oldSelectedIndex = self.selectedIndex;
    self.selectedIndex = self.collectionViewSelectedIndex - 3;
    self.selectedDate = [self.viewModel.historyDrinkArray[self.selectedIndex] valueForKey:@"date"];
    [self.scatterPlot reloadPlotSymbolsInIndexRange:NSMakeRange( (NSUInteger)self.selectedIndex, 1 )];
    [self.scatterPlot reloadPlotSymbolsInIndexRange:NSMakeRange( (NSUInteger)self.oldSelectedIndex, 1 )];
}

- (void)p_resetXrangeBySelectedIndexWithScatterPlot{

    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.plotGraph.defaultPlotSpace;
    
    CPTPlotRange *oldRange = plotSpace.xRange;
    CPTPlotRange *currentRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble((self.selectedIndex - 3) * kSecondsInOneDay) length:CPTDecimalFromDouble(kSecondsInOneDay * 6)];
    
    [CPTAnimation animate:plotSpace
                 property:@"xRange"
            fromPlotRange:oldRange
              toPlotRange:currentRange
                 duration:0.2];
}

- (void)p_resetDrinkBarPlotBySelectedIndex{

    NSDate *date = [self.viewModel.historyDrinkArray[self.selectedIndex] valueForKey:@"date"];
    self.viewModel.barchartDrinkArray = [self.viewModel segmentArrayWithDetail:self.viewModel.historyDrinkDetail inDate:date];
    
    [self.drinkBarPlot reloadData];
}
- (void)p_resetPlanBarPlotBySelectedIndex{
    
    NSDate *date = [self.viewModel.historyDrinkArray[self.selectedIndex] valueForKey:@"date"];
    
    self.viewModel.barchartSuggestArray = [self.viewModel segmentArraywithSuggests:self.viewModel.historySuggestDrink inDate:date];
    
  //  NSLog(@"suggest == %@",self.viewModel.barchartSuggestArray);
    [self.planBarPlot reloadData];
}


- (void)p_configBarchartView{

    self.barChartHostingView.hostedGraph = self.barchartGraph;
    self.barchartGraph.plotAreaFrame.masksToBorder = NO;

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.barchartGraph. defaultPlotSpace ;
    //plotSpace.allowsUserInteraction = YES;
  
    plotSpace.yRange = [ CPTPlotRange plotRangeWithLocation : CPTDecimalFromFloat ( 0.0f ) length : CPTDecimalFromFloat ( 800.0f )];
    plotSpace.xRange = [ CPTPlotRange plotRangeWithLocation : CPTDecimalFromFloat ( 0.0f ) length : CPTDecimalFromFloat (18.0f )];
    
    // 坐标系
    CPTXYAxisSet *axisSet = ( CPTXYAxisSet *)self.barchartGraph.axisSet ;
    //x 轴：为坐标系的 x 轴
    CPTXYAxis *x = axisSet. xAxis ;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.0f ;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:178.0f/255.0f green:229.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    x.axisLineStyle = lineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.axisLabels = self.barchartXLabelSet;
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    
    //y 轴
    CPTXYAxis *y = axisSet. yAxis ;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.hidden = YES;

    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 0.0;
    barLineStyle.lineColor = [CPTColor clearColor];

    
    self.planBarPlot.fill  = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:178.0 / 255.0 green:229.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]];
    self.planBarPlot.lineStyle = barLineStyle;
   
    self.planBarPlot.baseValue = CPTDecimalFromDouble(20.0);
    self.planBarPlot.barWidth = CPTDecimalFromFloat(1.0f);
    //self.planBarPlot.barOffset = CPTDecimalFromFloat ( 2.0f ) ;
    // 数据源，必须实现 CPPlotDataSource 协议
    self.planBarPlot.dataSource = self ;

    self.planBarPlot.identifier = CSTPlanBarPlotIdentifier ;
    self.planBarPlot.barCornerRadius = 10.0;
    self.planBarPlot.barBaseCornerRadius = 10.0;
    // 添加图形到绘图空间
    [self.barchartGraph addPlot:self.planBarPlot];
    
    
    
    self.drinkBarPlot.fill  = [CPTFill fillWithColor:[CPTColor whiteColor]];
    self.drinkBarPlot.lineStyle = barLineStyle;
    
    // 数据源，必须实现 CPPlotDataSource 协议
    self.drinkBarPlot. dataSource = self ;
    // 柱子的起始基线：即最下沿的 y 坐标
    self.drinkBarPlot. baseValue = CPTDecimalFromDouble(20.0);
    self.drinkBarPlot.barWidth   = CPTDecimalFromFloat(1.0f);
    self.drinkBarPlot.barCornerRadius = 10.0;
    self.drinkBarPlot.barBaseCornerRadius = 10.0f;

    self.drinkBarPlot. identifier = CSTDrinkBarPlotIdentifier;
    [self.barchartGraph addPlot:self.drinkBarPlot];
    
    self.barChartHostingView.hidden = YES;
    
    @weakify(self);
    [[RACObserve(self.viewModel, historyDrinkDetail) ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        if (!self.selectedDate) {
            self.selectedDate = [self.viewModel defaultSelectedDateWithDetailArry:x];
        }
        self.viewModel.barchartDrinkArray = [self.viewModel segmentArrayWithDetail:x inDate:self.selectedDate];
        [self.drinkBarPlot reloadData];
        
        self.viewModel.barchartSuggestArray = [self.viewModel segmentArraywithSuggests:self.viewModel.historySuggestDrink inDate:self.selectedDate];
        
        [self.planBarPlot reloadData];
        
    }];
    
    [RACObserve(self.viewModel, historySuggestDrink) subscribeNext:^(id x) {
       
        @strongify(self);
        if (self.selectedDate) {
            
            self.viewModel.barchartSuggestArray = [self.viewModel segmentArraywithSuggests:x inDate:self.selectedDate];
            [self.planBarPlot reloadData];
        }
    }];
}

#pragma mark - Event response

- (void)p_configEventWithSegment:(UISegmentedControl *)segment{
    
    
    @weakify(self);
    [[segment rac_newSelectedSegmentIndexChannelWithNilValue:nil]subscribeNext:^(id x) {
        @strongify(self);
        
        if ([x integerValue] == 0) {
            
            self.plotHostingView.hidden = NO;
            self.plotDrinkLabel.hidden = NO;
            self.plotMiddleLineView.hidden = NO;
            self.barChartHostingView.hidden = YES;
        }else if ([x integerValue] == 1){
            self.plotHostingView.hidden = YES;
            self.plotDrinkLabel.hidden = YES;
            self.plotMiddleLineView.hidden = YES;
            self.barChartHostingView.hidden = NO;
            
        }
    }];
}

- (void)p_share:(id)sender{

    [CSTUmeng  shareText:[self.viewModel todayUserDrinkShareText] image:[self.view cst_snapshotImage]presentSnsIconSheetView:self];
}


#pragma mark - Setters and getters

- (CSTDetailDataViewModel *)viewModel{
    
    if (!_viewModel) {
        
        _viewModel = [[CSTDetailDataViewModel alloc] init];
    }
    return _viewModel;
}

- (UISegmentedControl *)titleSegment{
    
    if (!_titleSegment) {
        
        _titleSegment = [[UISegmentedControl alloc] initWithItems:@[@"时间段",@"每日饮水"]];
        
        _titleSegment.selectedSegmentIndex = 0;
        _titleSegment.tintColor = [UIColor whiteColor];
        _titleSegment.layer.cornerRadius = 15.0;
        _titleSegment.layer.masksToBounds = YES;
        _titleSegment.layer.borderColor = [UIColor whiteColor].CGColor;
        _titleSegment.layer.borderWidth = 1.0;
        [self p_configEventWithSegment:_titleSegment];
        
    }
    return _titleSegment;
}


- (CPTXYGraph *)plotGraph{

    if (!_plotGraph) {
        
        _plotGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    }
    return _plotGraph;
}

- (CPTScatterPlot *)scatterPlot{
    
    if (!_scatterPlot) {
        
        _scatterPlot  = [[CPTScatterPlot alloc] init];
    }
    
    return _scatterPlot;
}

- (CPTPlotSymbol *)normalSymbol{

    if (!_normalSymbol) {
        
        _normalSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        
        _normalSymbol.fill = [CPTFill fillWithColor: [CPTColor colorWithComponentRed:140.0f/255.0f green:216.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        _normalSymbol.lineStyle = [CPTLineStyle cst_linestyleWithColor:[CPTColor whiteColor] width:1.0f];
        
        _normalSymbol.size = CGSizeMake(8.0, 8.0);
    }
    return _normalSymbol;
}


- (CPTPlotSymbol *)selectedSymbol{

    if (!_selectedSymbol) {
        
        _selectedSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        
        _selectedSymbol.lineStyle = [CPTLineStyle cst_linestyleWithColor:[CPTColor colorWithComponentRed:140.0f/255.0f green:216.0f/255.0f blue:255.0f/255.0f alpha:1.0f] width:2.5];
        
        _selectedSymbol.fill = [CPTFill fillWithColor: [CPTColor whiteColor]];
        _selectedSymbol.size = CGSizeMake(8.0, 8.0);
        
    }
    return _selectedSymbol;
}


- (CPTXYGraph *)barchartGraph{
    if (!_barchartGraph) {
        
        _barchartGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    }
    return _barchartGraph;
}

- (CPTBarPlot *)planBarPlot{
    if (!_planBarPlot) {
        
        _planBarPlot = [[CPTBarPlot alloc] init];
    }
    return _planBarPlot;
}

- (CPTBarPlot *)drinkBarPlot{
    if (!_drinkBarPlot) {
        
        _drinkBarPlot = [[CPTBarPlot alloc] init];
    }
    return _drinkBarPlot;
}

- (NSSet *)barchartXLabelSet{

    if (!_barchartXLabelSet) {
        
        CPTMutableTextStyle * textStye = [[CPTMutableTextStyle alloc] init];
        textStye.color = [CPTColor whiteColor];
        textStye.fontSize = 11.0;
        textStye.textAlignment = CPTTextAlignmentCenter;
        NSMutableSet *mutableSet = [NSMutableSet set];
        
        @weakify(self);
        [self.viewModel.barchartXTicks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            @strongify(self);
            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:self.viewModel.barchartXStrings[idx] textStyle:textStye];
            newLabel.tickLocation = ((NSNumber *)obj).decimalValue;
            newLabel.offset = 0.0;
            [mutableSet addObject:newLabel];
        }];
    
        _barchartXLabelSet = mutableSet;
    }
    
    return _barchartXLabelSet;
}


@end
