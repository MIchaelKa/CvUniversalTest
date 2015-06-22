//
//  AnimatedPathView.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 08/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
    #import <opencv2/opencv.hpp>
#endif

@interface AnimatedPathView : UIView

@property (nonatomic) CGSize frameSize;

- (void)setPathForDisplay: (std::vector<cv::Point2f>)path;
- (void)setRectsForDisplay: (std::vector<cv::Rect>)rects;

- (void)clear;

@end
