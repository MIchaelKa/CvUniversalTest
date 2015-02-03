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
    cv::Mat previousFrame;
    std::vector<cv::Point2f> previousPoints;
    std::vector<cv::Point2f> pathToDisplay;
    
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.animatedPathView setPathForDisplay: [self calcOpticalFlow:image]];
        });
        //start = NO;
    }
}

- (void)tap: (UITapGestureRecognizer *)tapGestureRecognizer
{
    start = YES;
    /*
    CGPoint gesturePoint = [tapGestureRecognizer locationInView: self.view];
    
    vector<cv::Point> objectContour;
    objectContour = [self contourAtPoint:[self.pointConvertor CVPointFromCGPoint: gesturePoint]
                                 onImage:[self currentFrame]];
    
    [self.animatedPathView setPathForDisplay: objectContour];*/
}


- (std::vector<cv::Point2f>)calcOpticalFlow: (cv::Mat&)image
{
    if (previousFrame.empty())
    {
        image.copyTo(previousFrame);
        
        cv::Mat frameGrayScale;
        cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
        
        cv::goodFeaturesToTrack(frameGrayScale, previousPoints, 3, 0.01, 10);
        
        return previousPoints;
    }
    
    cv::Mat frameGrayScale;
    cv::cvtColor(image, frameGrayScale, CV_BGR2GRAY);
    
    std::vector<cv::Point2f> nextPoints;
    std::vector<uchar> status;
    cv::Mat err;
    
    cv::calcOpticalFlowPyrLK(previousFrame,
                             image,
                             previousPoints,
                             nextPoints,
                             status,
                             err);
    
//    for (size_t i = 0; i < nextPoints.size(); i++)
//    {
//        if (status[i])
//        {
//            cv::line(image, previousPoints[i], nextPoints[i], cv::Scalar(255, 0, 0));
//        }
//    }
    
    return nextPoints;
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
    [self.view addSubview: self.animatedPathView];
    
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
