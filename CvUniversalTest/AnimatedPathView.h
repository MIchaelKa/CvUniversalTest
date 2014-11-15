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

- (void)setPathForDisplay: (std::vector<cv::Point2f>)path;

- (void)updateConversionRateForSize: (CGSize)size;

@end
