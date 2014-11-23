//
//  FindContoursController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 17/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "FindContoursController.h"

#import "FindContoursSettingsController.h"
#import "UIStoryboard+CvTest.h"

@interface FindContoursController ()

@end

@implementation FindContoursController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usingCanny = true;
    
    self.ratio = 2;
    self.firstTreshold = 100;
}

- (void)processCurrentFrame: (cv::Mat&)frame
{
    [self findContours: frame];
}

- (void)findContours: (cv::Mat&)image
{
    vector<vector<cv::Point>> contours;
    vector<cv::Vec4i> hierarchy;
    
    cv::Mat frameGrayScale;
    cv::Mat frameForFindContours;
    
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    
    if (self.usingCanny)
    {
        cv::Canny(frameGrayScale, frameForFindContours, self.firstTreshold, self.secondTreshold, 3);
    }
    else
    {
        // only for tresh
        cv::threshold(frameGrayScale, frameForFindContours, 127, 250, CV_THRESH_BINARY);
    }
    
    cv::findContours(frameForFindContours, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
  
    
    cv::Scalar color = cv::Scalar(0, 0, 255);
    for( int i = 0; i < contours.size(); i++ )
    {
        if (hierarchy[i][3] == -1)
            cv::drawContours(image, contours, i, color, 2);
    }
}

- (void)setupUI
{
    [super setupUI];
    // Buttons
    [self addButtons: @[
                        self.undoButton,
                        self.startButton,
                        self.settingsButton
                        ]];
}

- (void)showSettings
{
    UIStoryboard* sb = [UIStoryboard settingsStoryboard];
    
    UINavigationController* nvc = [sb instantiateViewControllerWithIdentifier: @"SettingsViewController"];
    nvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    FindContoursSettingsController* fcsc = (FindContoursSettingsController*)[nvc viewControllers][0];
    fcsc.parent = self;
    
    [self presentViewController: nvc
                       animated: YES
                     completion: nil];
}

- (void)setFirstTreshold: (int)firstTreshold
{
    _firstTreshold = firstTreshold;
    _secondTreshold = self.ratio * _firstTreshold;
}

@end
