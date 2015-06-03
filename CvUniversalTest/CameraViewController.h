//
//  CameraViewController.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TestSuite/TestSuite.h"
#import "AnimatedPathView.h"

using namespace std;

@protocol CameraViewControllerDelegate <NSObject>

- (void)cameraViewControllerDidFinishedWithCompletion:(void (^)(void))completion;

@end


@interface CameraViewController : UIViewController

@property (weak, nonatomic) TestSuite* testSuite;

@property (weak, nonatomic) id<CameraViewControllerDelegate> delegate;

@property (nonatomic, strong) UIButton* undoButton;
@property (nonatomic, strong) UIButton* startButton;
@property (nonatomic, strong) UIButton* settingsButton;

@property (nonatomic, strong) UILabel* testNameLabel;

@property (nonatomic, strong) AnimatedPathView* animatedPathView;

@property (nonatomic) CGSize frameSize;

- (void)setupUI;
- (void)addButtons: (NSArray *)buttons;

- (cv::Mat&)currentFrame;
- (void)processCurrentFrame: (cv::Mat&)frame;

@end
