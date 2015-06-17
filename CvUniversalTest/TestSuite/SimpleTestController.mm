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
        case THRESHOLD:
        {
            [self threshold: frame];
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
    
    cv::goodFeaturesToTrack(frameGrayScale, corners, 100, 0.3, 10);
    
    for (size_t i = 0; i < corners.size(); i++) {
        cv::circle(image, corners[i], 4, cv::Scalar(255, 0, 0));
    }
}

- (void)cannyEdgeDetection: (cv::Mat&)image
{
    int thresh = 500;
    
    cv::cvtColor(image, image, CV_BGR2GRAY);
    cv::Canny(image, image, thresh, thresh * 3, 5);
}

- (void)morphologicalTransform: (cv::Mat&)image
{
    [self cannyEdgeDetection: image];
    
    cv::Mat element = cv::getStructuringElement (cv::MORPH_RECT, cv::Size(3, 3));
    
    //cv::erode(image, image, element);
    cv::dilate(image, image, element);
    //cv::morphologyEx(image, image, CV_MOP_CLOSE, element);
    //cv::morphologyEx(image, image, CV_MOP_OPEN, element);
}

- (void)threshold: (cv::Mat&)image
{
    cv::cvtColor(image, image, CV_BGR2GRAY);
    
    cv::threshold(image, image, 150, 250, CV_THRESH_BINARY);
    
    //cv::adaptiveThreshold(image, image, 250, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 11, 2);
    
    cv::Mat element = cv::getStructuringElement (cv::MORPH_ELLIPSE, cv::Size(5, 5));
    //cv::erode(image, image, element);
    cv::morphologyEx(image, image, CV_MOP_OPEN, element);
    //cv::morphologyEx(image, image, CV_MOP_CLOSE, element);
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
