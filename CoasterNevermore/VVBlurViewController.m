//
//  VVBlurViewController.m
//
//  Copyright (c) 2015 Wei Wang (http://onevcat.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "VVBlurViewController.h"
#import "VVBlurPresenter.h"

@interface VVBlurViewController ()
@property (nonatomic, strong) VVBlurPresenter *presenter;
@end

@implementation VVBlurViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self vv_commonSetup];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self vv_commonSetup];
    }
    return self;
}

- (void)vv_commonSetup {
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    _presenter = [[VVBlurPresenter alloc] init];
    _blurStyle = UIBlurEffectStyleDark;
    _presenter.blurStyle = _blurStyle;
    _presenter.transitionType = _transitionType;
    
    self.transitioningDelegate = _presenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
}

-(void)setBlurStyle:(UIBlurEffectStyle)blurStyle {
    if (blurStyle != _blurStyle) {
        _blurStyle = blurStyle;
        _presenter.blurStyle = blurStyle;
    }
}

-(void)setTransitionType:(VVBlurTransitionType)transitionType {
    if (transitionType != _transitionType) {
        _transitionType = transitionType;
        _presenter.transitionType = transitionType;
    }
}

@end
