//
//  ResultViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 26/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "ResultViewController.h"

#import "UIButton+CircularStyle.h"

@interface ResultViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *resultScrollView;

@end

@implementation ResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setupButtons];
}

- (void)setResultImageView:(UIImageView *)resultImageView
{
    _resultImageView = resultImageView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultScrollView.contentSize = resultImageView.image.size;
        [self.resultScrollView addSubview: resultImageView];
    });
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.resultImageView;
}

- (void)setupUI
{
    [self setNeedsStatusBarAppearanceUpdate];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.resultScrollView.minimumZoomScale = 0.2;
    self.resultScrollView.maximumZoomScale = 2.0;
    
    self.resultScrollView.delegate = self;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setupButtons
{
    CGSize viewSize = self.view.bounds.size;
    CGPoint point = CGPointMake(viewSize.width / 2 - [UIButton buttonSize] / 2,
                                viewSize.height - 80);
    // Undo
    UIButton* undoButton = [UIButton circularButtonWithImageNamed: @"Undo"];
    [undoButton setPositionAtPoint: point];
    [undoButton addTarget: self
                   action: @selector(backToCameraView)
         forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: undoButton];
}

- (void)backToCameraView
{
    [self dismissViewControllerAnimated: YES completion: ^{
    }];
}

@end
