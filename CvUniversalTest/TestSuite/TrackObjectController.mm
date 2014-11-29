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

@property (strong, nonatomic) UITapGestureRecognizer* tapGestureRecognizer;
@property (strong, nonatomic) PointConvertor* pointConvertor;

@end

@implementation TrackObjectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer: self.tapGestureRecognizer];
}

- (void)tap: (UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint gesturePoint = [tapGestureRecognizer locationInView: self.view];
    
    vector<cv::Point> objectContour;
    objectContour = [self contourAtPoint:[self.pointConvertor CVPointFromCGPoint: gesturePoint]
                                 onImage:[self currentFrame]];

    
    [self.animatedPathView setPathForDisplay: objectContour];
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
