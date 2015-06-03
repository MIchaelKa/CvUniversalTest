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

#import "ResultViewController.h"
#import "UIStoryboard+CvTest.h"

#import "UIButton+CircularStyle.h"
#import "UILabel+HeaderStyle.h"


@interface CameraViewController () <CvVideoCameraDelegate>
{
    cv::Mat currentFrame;
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) UIImageView*   resultImageView;

@property (nonatomic, strong) ResultViewController* resultViewController;

@property (nonatomic) BOOL shouldSaveFrames;

@end

@implementation CameraViewController

- (ResultViewController*)resultViewController
{
    if (!_resultViewController)
    {
        _resultViewController = [[UIStoryboard mainStoryboard]
            instantiateViewControllerWithIdentifier: @"ResultViewController"];
        _resultViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    _resultViewController.resultImageView = self.resultImageView;

    return _resultViewController;
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
    
    self.shouldSaveFrames = NO;
}

- (void)startCamera
{
    [self.videoCamera start];
    self.shouldSaveFrames = YES;
    
    self.frameSize = CGSizeMake(self.videoCamera.imageHeight,
                                self.videoCamera.imageWidth);
}

- (void)processImage:(cv::Mat&)image
{
    if (self.shouldSaveFrames)
    {
       image.copyTo(currentFrame);
    }
}

- (void)processCurrentFrame: (cv::Mat&)frame
{
    //Empty implementation
    NSLog(@"CvTest - WARNING - Using empty implementation of processCurrentFrame");
}

- (cv::Mat&)currentFrame
{
    return currentFrame;
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
        _undoButton = [UIButton circularButtonWithImageNamed: @"Undo"];
        
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
        _startButton = [UIButton circularButtonWithImageNamed: @"Start"];
        
        [_startButton addTarget: self
                         action: @selector(showResults)
               forControlEvents: UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UIButton *)settingsButton
{
    if (!_settingsButton)
    {
        _settingsButton = [UIButton circularButtonWithImageNamed: @"Settings"];
        
        [_settingsButton addTarget: self
                            action: @selector(showSettings)
                  forControlEvents: UIControlEventTouchUpInside];
    }
    return _settingsButton;
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
        _animatedPathView.frameSize = self.frameSize;
    }
    return _animatedPathView;
}

- (void)setupUI
{
    // Labels
    [self.view addSubview: self.testNameLabel];    
}

- (void)addButtons: (NSArray *)buttons
{
    NSInteger buttonSize = [UIButton buttonSize];
    NSInteger buttonInterval = [UIButton buttonInterval];
    NSUInteger buttonCount = buttons.count;
    
    NSInteger allButtonWidth = (buttonSize * buttonCount) +
                               (buttonInterval * (buttonCount - 1));
    
    CGSize viewSize = self.view.bounds.size;
    CGPoint point = CGPointMake(viewSize.width / 2 - allButtonWidth / 2,
                                viewSize.height - 80);
    
    for (NSUInteger i = 0; i < buttonCount; i++)
    {
        UIButton* button = [buttons objectAtIndex: i];
        [button setPositionAtPoint: point];
        point.x += buttonSize + buttonInterval;
        [self.view addSubview: button];
    }    
}

- (void)backToPickerView
{
    self.shouldSaveFrames = NO;
    [self.delegate cameraViewControllerDidFinishedWithCompletion:^{
        [self.videoCamera stop];
    }];    
}

- (void)showResults
{
    self.shouldSaveFrames = NO; 
    
    [self processCurrentFrame: currentFrame];
    
    [self presentViewController: self.resultViewController
                       animated: YES
                     completion: ^{
                         [self.videoCamera stop];
                     }];
}

- (void)showSettings
{
    //Empty implementation
    NSLog(@"CvTest - WARNING - Using empty implementation of showSettings");
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
