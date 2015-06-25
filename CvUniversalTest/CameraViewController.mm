//
//  CameraViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "CameraViewController.h"

#import "ResultViewController.h"
#import "UIStoryboard+CvTest.h"

#import "UIButton+CircularStyle.h"
#import "UILabel+HeaderStyle.h"


@interface CameraViewController () <CvVideoCameraDelegate>
{
    cv::Mat currentFrame;
}
@property (nonatomic, strong) UIImageView*   resultImageView;

@property (nonatomic, strong) ResultViewController* resultViewController;



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
    
    self.shouldProcessFrames = NO;
}

- (void)startCamera
{
    [self.videoCamera start];
    self.shouldProcessFrames = YES;
    
    self.frameSize = CGSizeMake(self.videoCamera.imageHeight,
                                self.videoCamera.imageWidth);
}

- (void)processImage:(cv::Mat&)image
{
    if (self.shouldProcessFrames)
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
                         action: @selector(startButtonAction)
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

- (UIButton *)switchCameraButton
{
    if (!_switchCameraButton)
    {
        _switchCameraButton = [UIButton circularButtonWithImageNamed: @"Switch-camera"];
        
        [_switchCameraButton addTarget: self
                                action: @selector(switchCamera)
                      forControlEvents: UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
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

- (DynamicResultView *)dynamicResultView
{
    if(!_dynamicResultView)
    {
        _dynamicResultView = [[DynamicResultView alloc] initWithFrame:self.view.bounds];
        _dynamicResultView.frameSize = self.frameSize;
    }
    return _dynamicResultView;
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
    if (self.shouldProcessFrames == NO)
    {
        while (!self.shouldProcessFrames) {}
    }

    self.shouldProcessFrames = NO;
    
    [self.delegate cameraViewControllerDidFinishedWithCompletion:^{
        [self.videoCamera stop];
    }];    
}

- (void)startButtonAction
{
    self.shouldProcessFrames = NO;
    
    [self processCurrentFrame: currentFrame];
    [self presentResultViewController];
}

- (void)presentResultViewController
{
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

- (void)switchCamera
{
    if (self.shouldProcessFrames == NO)
    {
        while (!self.shouldProcessFrames) {}
    }
    else
    {
        self.shouldProcessFrames = NO;
    }
    [self.videoCamera stop];
   
    AVCaptureDevicePosition currentPosition = self.videoCamera.defaultAVCaptureDevicePosition;
    
    switch (currentPosition)
    {
        case AVCaptureDevicePositionBack:
        {
            self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
            break;
        }
        case AVCaptureDevicePositionFront:
        {
            self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
            break;
        }
        case AVCaptureDevicePositionUnspecified:
        {
            self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
            break;
        }
    }
    
    [self startCamera];
    [self setupUI];
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
