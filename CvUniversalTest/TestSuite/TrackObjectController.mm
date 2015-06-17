//
//  TrackObjectController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 17/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "TrackObjectController.h"
#import "PointConvertor.h"


@interface TrackObjectController ()
{
    cv::Mat previousFrameGray;
    std::vector<cv::Point2f> previousPoints;
    
    BOOL start;
}

@property (strong, nonatomic) UITapGestureRecognizer* tapGestureRecognizer;
@property (strong, nonatomic) PointConvertor* pointConvertor;

@end

@implementation TrackObjectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer: self.tapGestureRecognizer];
    
    start = NO;
}

- (void)processImage:(cv::Mat&)image
{
    if(start)
    {
        [self calcOpticalFlow:image];
    }
}

- (void)tap: (UITapGestureRecognizer *)tapGestureRecognizer
{
    start = YES;
}

- (void)calcOpticalFlow: (cv::Mat&)image
{
    // First frame
    if (previousFrameGray.empty())
    {
        cv::Mat frameGrayScale;
        cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
        
        frameGrayScale.copyTo(previousFrameGray);
        
        cv::goodFeaturesToTrack(frameGrayScale, previousPoints, 10, 0.3, 10);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dynamicResultView setPointsForDisplay: previousPoints];
        });
    }
    
    // Calc optical flow
    cv::Mat frameGrayScale;
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    
    std::vector<cv::Point2f> nextPoints;
    std::vector<uchar> status;
    cv::Mat err;
    
    cv::calcOpticalFlowPyrLK(previousFrameGray,
                             frameGrayScale,
                             previousPoints,
                             nextPoints,
                             status,
                             err);
    
    // Find good points
    std::vector<cv::Point2f> goodPoints;
    for (size_t i = 0; i < status.size(); i++)
    {
        if (status[i] == 1)
        {
            goodPoints.push_back(nextPoints[i]);
        }
    }
    
    // Draw found points
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dynamicResultView setPointsForDisplay: goodPoints];
    });
    
    // Save current frame and points
    frameGrayScale.copyTo(previousFrameGray);
    previousPoints = goodPoints;
}
 

- (vector<cv::Point>)contourAtPoint: (cv::Point)point
                            onImage: (cv::Mat&)image
{
    vector<vector<cv::Point>> contours;
    vector<cv::Point>   contour;
    
    contours = [self findContoursOnImage: image];
    
    for (int i = 0; i < contours.size(); i++)
    {
        cv::Rect rect = cv::boundingRect(contours[i]);
        if (rect.contains(point))
        {
            contour = contours[i];
        }
    }
    
    return contour;    
}

- (vector<vector<cv::Point>>)findContoursOnImage: (cv::Mat&)image
{
    vector<vector<cv::Point>> contours;
    
    cv::Mat frameGrayScale;
    cv::Mat frameCanny;
    
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    cv::Canny(frameGrayScale, frameCanny, 100, 200, 3);
    
    cv::findContours(frameCanny, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE );//zeros??
    
    return contours;
}

- (void)setupUI
{
    [super setupUI];
    // Views
    [self.view addSubview: self.dynamicResultView];
    
    // Buttons
    [self addButtons: @[
                        self.undoButton
                        ]];
}

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!_tapGestureRecognizer)
    {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                        action: @selector(tap:)];
    }
    return _tapGestureRecognizer;
}

- (PointConvertor *)pointConvertor
{
    if (!_pointConvertor)
    {
        _pointConvertor = [[PointConvertor alloc] initWithFrameSize: self.frameSize
                                                  AndTargetViewSize: self.view.bounds.size];
    }
    return _pointConvertor;
}




@end
