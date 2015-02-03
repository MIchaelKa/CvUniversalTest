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
    
    self.usingCanny = YES;
    self.usingPointDrawing = NO;
    
    self.ratio = 3;
    self.firstTreshold = 100;
    
    self.currentApproxMethodIndex = CV_CHAIN_APPROX_SIMPLE;
    self.currentRetrievalModeIndex = CV_RETR_TREE;
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
        cv::threshold(frameGrayScale, frameForFindContours, 127, 250, CV_THRESH_BINARY);
    }
    
    cv::findContours(frameForFindContours,
                     contours,
                     hierarchy,
                     (int)self.currentRetrievalModeIndex,
                     (int)self.currentApproxMethodIndex);
    
    [self drawContours:contours onImage:image];
}

- (void)drawContours: (vector<vector<cv::Point>>) contours
             onImage: (cv::Mat&)image
{
    cv::Scalar colors[3] = {cv::Scalar(255, 0, 0),
                            cv::Scalar(0, 255, 0),
                            cv::Scalar(0, 0, 255)};
    
    for (int i = 0; i < contours.size(); i++)
    {
        if (self.usingPointDrawing)
        {
            [self drawContour: contours[i]
                      onImage: image
                    withColor: colors[i%3]];
        }
        else
        {
            cv::drawContours(image, contours, i, colors[i%3], 2);
        }
    }
}

- (void)drawContour: (vector<cv::Point>)contour
            onImage: (cv::Mat&)image
          withColor: (cv::Scalar)color
{
    for (int i = 0; i < contour.size(); i++)
    {
        [self drawPoint: contour[i]
                atImage: image
              withColor: color];
    }
}

- (void)drawPoint: (cv::Point)point
          atImage: (cv::Mat&)image
        withColor: (cv::Scalar)color
{
    int rectPointX = point.x;
    int rectPointY = point.y;
    
    image.at<cv::Vec4b>(rectPointY, rectPointX)[0] = color[0];
    image.at<cv::Vec4b>(rectPointY, rectPointX)[1] = color[1];
    image.at<cv::Vec4b>(rectPointY, rectPointX)[2] = color[2];
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

- (NSArray *)approximationMethods
{
    if (!_approximationMethods)
    {
        _approximationMethods = @[
                                  @"Code",
                                  @"None",
                                  @"Simple",
                                  @"TC89 L1",
                                  @"TC89 KCOS",
                                  @"LINK RUNS",
                                  ];
    }
    return _approximationMethods;
}

- (NSString *)currentMethodName
{
    return self.approximationMethods[self.currentApproxMethodIndex];
}

- (NSArray *)retrievalModes
{
    if (!_retrievalModes)
    {
        _retrievalModes = @[
                            @"External",
                            @"List",
                            @"Ccomp",
                            @"Tree",
                            @"Flood Fill",
                            ];
    }
    return _retrievalModes;
}

- (NSString *)currentModeName
{
    return self.retrievalModes[self.currentRetrievalModeIndex];
}

@end
