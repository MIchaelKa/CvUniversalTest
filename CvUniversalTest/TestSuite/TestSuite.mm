//
//  TestSuite.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 25/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "TestSuite.h"

using namespace std;

@interface TestSuite()
{
    cv::Mat* savedFrameForTracking;
    std::vector<cv::Point2f> prevPoints;
}

@end

@implementation TestSuite

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        savedFrameForTracking = nullptr;
    }
    return self;
}

- (void)processImageWithCurrentTest: (cv::Mat&)image
{
    if ([self isDynamic])
    {
        return;
    }
    switch (self.currentTestIndex)
    {
        case GOOD_FEATURES:
        {
            [self goodFeaturesToTrack: image];
            break;
        }
        case FIND_CONTOURS:
        {
            [self findContours: image];
            break;
        }
        case CANNY_EDGE_DETECTION:
        {
            [self cannyEdgeDetection: image];
            break;
        }
    }
}

- (vector<cv::Point2f>)pointsForDisplayFromImage: (cv::Mat&)image
{
    vector<cv::Point2f> points;
    if (![self isDynamic])
    {
        return points;
    }
    switch (self.currentTestIndex)
    {
        case OPTICAL_FLOW_TEST:
        {
            points = [self calcOpticalFlow: image];
            break;
        }
        case TRACK_OBJECT:
        {
            points = [self trackObject: image];
            break;
        }
    }
    return points;
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

- (void)findContours: (cv::Mat&)image
{
    vector<vector<cv::Point>> contours;
    vector<cv::Vec4i> hierarchy;  //settings!
    
    bool usingCanny = true;
    
    cv::Mat frameGrayScale;
    cv::Mat frameForFindContours;
    
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    
    if (usingCanny)
    {
        int thresh = 100;
        cv::Canny(frameGrayScale, frameForFindContours, thresh, thresh * 2, 3 );
    }
    else
    {
        cv::threshold(frameGrayScale, frameForFindContours, 127, 250, CV_THRESH_BINARY);
    }
    
    cv::findContours(frameForFindContours, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
    
    cv::Scalar color = cv::Scalar(0, 0, 255);
    for( int i = 0; i< contours.size(); i++ )
    {
        if (hierarchy[i][3] == -1)
        cv::drawContours(image, contours, i, color, 2);
    }
}

- (void)cannyEdgeDetection: (cv::Mat&)image
{
    int thresh = 100;
    
    cv::cvtColor(image, image, CV_BGR2GRAY);
    cv::Canny(image, image, thresh, thresh * 2, 3 );
}

# pragma mark - Available tests - Dynamic

- (std::vector<cv::Point2f>)calcOpticalFlow: (cv::Mat&)image
{
    if (savedFrameForTracking == nullptr)
    {
        savedFrameForTracking = new cv::Mat();
        image.copyTo(*savedFrameForTracking);
        
        cv::Mat frameGrayScale;
        cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
        
        cv::goodFeaturesToTrack(frameGrayScale, prevPoints, 3, 0.01, 10);
        
        return prevPoints;
    }

    cv::Mat frameGrayScale;
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    
    std::vector<cv::Point2f> nextPoints;
    std::vector<uchar> status;
    cv::Mat err;
    
    cv::calcOpticalFlowPyrLK(*savedFrameForTracking,
                             image,
                             prevPoints,
                             nextPoints,
                             status,
                             err);
    
    for (size_t i = 0; i < nextPoints.size(); i++)
    {
        if (status[i])
        {
            cv::line(image, prevPoints[i], nextPoints[i], cv::Scalar(255, 0, 0));
        }
    }
    
    return nextPoints;
}

- (std::vector<cv::Point2f>)trackObject: (cv::Mat&)image
{
    vector<vector<cv::Point>> contours;
    vector<cv::Point>   contour;
    
    cv::Mat frameGrayScale;
    cv::Mat frameThreshold;
    
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    cv::threshold(frameGrayScale, frameThreshold, 127, 250, CV_THRESH_BINARY);
    
    cv::findContours(frameThreshold, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE );
    
    for( int i = 0; i< contours.size(); i++ )
    {
        int area = cv::contourArea(contours[i]);
        if (area < 5000 && area > 3000)
        {
            contour = contours[i];
        }
    }
    
    vector<cv::Point2f> points(contour.size());
    for (size_t i = 0; i < contour.size(); i++)
    {
        points.push_back(cv::Point2f(contour[i].x, contour[i].y));
    }
    
    return points;
}

# pragma mark - Test name

- (NSString *) currentTestName
{
    return [self testNameFromIndex: self.currentTestIndex];
}

- (NSArray *)availableTestNames
{
    if (_availableTestNames == nil)
    {
        NSMutableArray* names = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < CV_TEST_COUNT; i++)
        {
            [names addObject: [self testNameFromIndex: i]];
        }
        _availableTestNames = names;
    }
    return _availableTestNames;
}

- (NSString *)testNameFromIndex: (NSInteger)index
{
    switch (index)
    {
        case GOOD_FEATURES:
        {
            return @"Good Features to Track";
        }
        case OPTICAL_FLOW_TEST:
        {
            return @"Optical Flow";
        }
        case FIND_CONTOURS:
        {
            return @"Find Contours";
        }
        case TRACK_OBJECT:
        {
            return @"Track Object";
        }
        case CANNY_EDGE_DETECTION:
        {
            return @"Canny Edge Detection";
        }
        default:
        {
            return @"";
        }
    }
}

- (BOOL)isDynamic
{
    switch (self.currentTestIndex)
    {
        case OPTICAL_FLOW_TEST:
        case TRACK_OBJECT:
        {
            return YES;
        }
        case GOOD_FEATURES:
        case FIND_CONTOURS:
        case CANNY_EDGE_DETECTION:
        {
            return NO;
        }
        default:
        {
            return NO;
        }
    }
}

@end
