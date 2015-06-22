//
//  DynamicResultView.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 15/06/15.
//  Copyright (c) 2015 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
    #import <opencv2/opencv.hpp>
#endif

using namespace std;
using namespace cv;

@interface DynamicResultView : UIView

@property (nonatomic) CGSize frameSize;

- (void)setPointsForDisplay: (vector<Point2f>)points;

- (void)setPoints: (vector<Point2f>)points
   andRectForDisp: (cv::Rect)rect;

@end
