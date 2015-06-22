//
//  PointConvertor.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 28/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
    #import <opencv2/opencv.hpp>
#endif

@interface PointConvertor : NSObject

- (instancetype)initWithFrameSize: (CGSize)frameSize
                AndTargetViewSize: (CGSize)viewSize;

- (void)setFrameSize: (CGSize)frameSize
   AndTargetViewSize: (CGSize)viewSize;

- (CGPoint)CGPointFromCVPoint: (cv::Point2f)point;
- (cv::Point2f)CVPointFromCGPoint: (CGPoint)point;

- (CGRect)CGRectFromCVRect: (cv::Rect)rect;

@end
