//
//  CameraViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "CameraViewController.h"

#import <opencv2/highgui/ios.h>
#ifdef __cplusplus
    #import <opencv2/opencv.hpp>
#endif

#import "UIButton+CircularStyle.h"
#import "UILabel+HeaderStyle.h"
#import "AnimatedPathView.h"

@interface CameraViewController () <CvVideoCameraDelegate>
{
    cv::Mat currentFrame;
    int count;
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) UIImageView*   resultImageView;

@property (nonatomic, strong) UIButton* undoButton;
@property (nonatomic, strong) UIButton* startButton;

@property (nonatomic, strong) UILabel* testNameLabel;

@property (nonatomic, strong) AnimatedPathView* animatedPathView;

@end

@implementation CameraViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Result controller"])
    {
        ResultViewController* rvc = segue.destinationViewController;        
        rvc.resultImageView = self.resultImageView;
    }
}

- (UIImageView *)resultImageView
{
    if (!_resultImageView) _resultImageView = [[UIImageView alloc] init];
    
    _resultImageView.image = MatToUIImage(currentFrame);
    [_resultImageView sizeToFit];
    
    return _resultImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initCamera];
    [self setNeedsStatusBarAppearanceUpdate];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver: self
           selector: @selector(orientationDidChange:)
               name: @"UIDeviceOrientationDidChangeNotification"
             object: nil];
    
    count = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self startCamera];
    [self setupUI];
}

#pragma mark - CvVideoCamera

- (void)initCamera
{
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView: self.view];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.defaultAVCaptureVideoOrientation = [self captureOrientation];
    self.videoCamera.useAVCaptureVideoPreviewLayer = YES;
}

- (void)startCamera
{
    [self.videoCamera start];
}

- (void)processImage:(cv::Mat&)image
{
    // implement callback in test suite
    // +pass view(for dynamic?)
    image.copyTo(currentFrame);
    
    if ([self.testSuite isDynamic])
    {
        //get path if any;
    }
    else
    {
        
    }
}

#pragma mark -  UI

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIButton *) undoButton
{
    if (!_undoButton)
    {
        CGSize viewSize = self.view.bounds.size;
        CGPoint point = CGPointMake(viewSize.width / 2 - 40,
                                    viewSize.height - 50);
        
        _undoButton = [UIButton circularButtonAtPoint: point
                                       withImageNamed: @"Undo"];
        
        [_undoButton addTarget: self
                        action: @selector(backToPickerView)
              forControlEvents: UIControlEventTouchUpInside];
        
    }
    return _undoButton;
}

- (UIButton *)startButton
{
    if (!_startButton)
    {
        CGSize viewSize = self.view.bounds.size;
        CGPoint point = CGPointMake(viewSize.width / 2 + 40,
                                    viewSize.height - 50);
        
        _startButton = [UIButton circularButtonAtPoint: point
                                        withImageNamed: @"Start"];
        
        [_startButton addTarget: self
                         action: @selector(startTest)
               forControlEvents: UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UILabel *)testNameLabel
{
    if (!_testNameLabel)
    {
        _testNameLabel = [UILabel headerLabelWithTitle: self.testSuite.currentTestName
                                        onViewWithSize: self.view.bounds.size];
        
    }
    return _testNameLabel;
}

- (AnimatedPathView *)animatedPathView
{
    if (!_animatedPathView)
    {
        _animatedPathView = [[AnimatedPathView alloc] initWithFrame: self.view.bounds];
        [_animatedPathView updateConversionRateForSize:CGSizeMake(self.videoCamera.imageHeight,
                                                                  self.videoCamera.imageWidth)];
    }
    return _animatedPathView;
}

- (void)setupUI
{
    // Views
    [self.view addSubview: self.animatedPathView];
    // Buttons
    [self.view addSubview: self.undoButton];
    [self.view addSubview: self.startButton];
    // Labels
    [self.view addSubview: self.testNameLabel];    
}

- (void)backToPickerView
{
    [self dismissViewControllerAnimated: YES completion: ^{
        [self.videoCamera stop];
    }];
}

- (void)startTest
{
    if ([self.testSuite isDynamic])
    {
        std::vector<cv::Point2f> path =
            [self.testSuite pointsForDisplayFromImage: currentFrame];
        
        if (path.size() > 0)
        {
            [self.animatedPathView setPathForDisplay: path];
        }
    }
    else
    {
        [self.videoCamera stop];
        [self.testSuite processImageWithCurrentTest: currentFrame];        
        [self performSegueWithIdentifier: @"Result controller" sender: self];
    }
}

- (void)orientationDidChange: (NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        {
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        {
            self.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
            self.view.frame = CGRectMake(0, 0, 500, 200);

            break;
        }            
        default:
        {
            break;
        }
    }
}

- (AVCaptureVideoOrientation)captureOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIInterfaceOrientationLandscapeLeft:
        {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight:
        {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        default:
        {
            return AVCaptureVideoOrientationPortrait;
        }
    }
}

@end
