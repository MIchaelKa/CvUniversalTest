//
//  DepthMapTestVC.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 25/06/15.
//  Copyright (c) 2015 Michael. All rights reserved.
//

#import "DepthMapTestVC.h"

@interface DepthMapTestVC ()
{
    Mat leftImage;
    Mat rightImage;
    
    BOOL leftImageSaved;
}

@end

@implementation DepthMapTestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    leftImageSaved = NO;
}

#pragma mark - UI

- (void)setupUI
{
    [super setupUI];
    
    // Buttons
    [self addButtons: @[
                        self.undoButton,
                        self.startButton                        
                        ]];
}

- (void)startButtonAction
{
    self.shouldProcessFrames = NO;
    
    if (leftImageSaved == NO)
    {
        self.currentFrame.copyTo(leftImage);
        leftImageSaved = YES;
        
        self.shouldProcessFrames = YES;
    }
    else
    {
        self.currentFrame.copyTo(rightImage);
        [self computeDepthMap];
        
        [self presentResultViewController];
        
        leftImageSaved = NO;
    }
}

- (void)computeDepthMap
{
    //[self computeDepthMapStereoBM];
    [self computeDepthMapOpticalFlow];
}

- (void)computeDepthMapStereoBM
{
    cv::cvtColor(leftImage, leftImage, CV_BGR2GRAY);
    cv::cvtColor(rightImage, rightImage, CV_BGR2GRAY);
    
    // Call the constructor for StereoBM
    int ndisparities = 112; // Range of disparity
    int SADWindowSize = 9; // Size of the block window. Must be odd
    StereoBM sbm(StereoBM::BASIC_PRESET, ndisparities, SADWindowSize);

    sbm.state->SADWindowSize = 9;
    sbm.state->numberOfDisparities = 112;
    sbm.state->preFilterSize = 5;
    sbm.state->preFilterCap = 61;
    sbm.state->minDisparity = -39;
    sbm.state->textureThreshold = 507;
    sbm.state->uniquenessRatio = 0;
    sbm.state->speckleWindowSize = 0;
    sbm.state->speckleRange = 8;
    sbm.state->disp12MaxDiff = 1;
    
    Mat imgDisparity16S = Mat(leftImage.rows, leftImage.cols, CV_16S);
    Mat imgDisparity8U  = Mat(leftImage.rows, leftImage.cols, CV_8UC1);
    
    sbm(leftImage, rightImage, imgDisparity16S);
    normalize(imgDisparity16S, imgDisparity8U, 0, 255, CV_MINMAX, CV_8U);
    
    imgDisparity8U.copyTo(self.currentFrame);
}

- (void)computeDepthMapOpticalFlow
{
    cv::cvtColor(leftImage, leftImage, CV_BGR2GRAY);
    cv::cvtColor(rightImage, rightImage, CV_BGR2GRAY);
    
    Mat flow;
    
    calcOpticalFlowFarneback(leftImage, rightImage, flow, 0.5, 3, 15, 3, 5, 1.2, 0 );
    
    // Separate flow mat. Preparing for cartToPolar
    vector<Mat> flowPlanes;
    split(flow, flowPlanes);
    
    Mat magnitudes;
    Mat angles;
    
    cartToPolar(flowPlanes[0], flowPlanes[1], magnitudes, angles);
    
    Mat resultImage = Mat(leftImage.rows, leftImage.cols, CV_8UC1);
    normalize(magnitudes, resultImage, 0, 255, CV_MINMAX, CV_8U);
    
    resultImage.copyTo(self.currentFrame);
}

@end
