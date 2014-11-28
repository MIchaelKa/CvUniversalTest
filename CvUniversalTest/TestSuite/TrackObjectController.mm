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
    NSLog(@"x - %f, y - %f", gesturePoint.x, gesturePoint.y);
    
    cv::Point2f p1 = [self.pointConvertor CVPointFromCGPoint: gesturePoint];
    NSLog(@"x - %f, y - %f", p1.x, p1.y);
    
    CGPoint p2 = [self.pointConvertor CGPointFromCVPoint: p1];
    NSLog(@"x - %f, y - %f", p2.x, p2.y);
    
    //[self.animatedPathView setPathForDisplay: [self trackObject: [self currentFrame]]];
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
