//
//  SimpleTestController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 17/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "SimpleTestController.h"

@interface SimpleTestController ()

@end

@implementation SimpleTestController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)processCurrentFrame: (cv::Mat&)frame
{
    switch (self.testSuite.currentTestIndex)
    {
        case GOOD_FEATURES:
        {
            [self goodFeaturesToTrack: frame];
            break;
        }
        case CANNY_EDGE_DETECTION:
        {
            [self cannyEdgeDetection: frame];
            break;
        }
        case MORPH_TRANSFORM:
        {
            [self morphologicalTransform: frame];
            break;
        }
    }
}

# pragma mark - Available tests

- (void)goodFeaturesToTrack: (cv::Mat&)image
{
    vector<cv::Point2f> corners;
    cv::Mat frameGrayScale;
    
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    
    cv::goodFeaturesToTrack(frameGrayScale, corners, 25, 0.01, 10);
    
    for (size_t i = 0; i < corners.size(); i++) {
        cv::circle(image, corners[i], 4, cv::Scalar(0, 0, 255));
    }
}

- (void)cannyEdgeDetection: (cv::Mat&)image
{
    int thresh = 100;
    
    cv::cvtColor(image, image, CV_BGR2GRAY);
    cv::Canny(image, image, thresh, thresh * 2, 3 );
}

- (void)morphologicalTransform: (cv::Mat&)image
{
    //[self cannyEdgeDetection: image];
    
    cv::Mat element = cv::getStructuringElement (cv::MORPH_RECT, cv::Size(5, 5));
    cv::erode(image, image, element );
}

# pragma mark - UI

- (void)setupUI
{
    [super setupUI];
    // Buttons
    [self addButtons: @[
                        self.undoButton,
                        self.startButton
                        ]];
}

@end
