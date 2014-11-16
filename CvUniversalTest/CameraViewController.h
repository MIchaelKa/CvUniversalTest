//
//  CameraViewController.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestSuite/TestSuite.h"

@protocol CameraViewControllerDelegate <NSObject>

- (void)cameraViewControllerDidFinished;

@end

@interface CameraViewController : UIViewController

@property (weak, nonatomic) TestSuite* testSuite;
@property (weak, nonatomic) id<CameraViewControllerDelegate> delegate;

// UI - to separate view controller!???
@property (nonatomic, strong) UIButton* undoButton;
@property (nonatomic, strong) UIButton* startButton;
@property (nonatomic, strong) UIButton* settingsButton;

- (void)setupUI;
- (void)addButtons: (NSArray *)buttons;

@end
