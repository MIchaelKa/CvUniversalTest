//
//  PointConvertor.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 28/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "PointConvertor.h"

@implementation PointConvertor
{
    CGFloat conversionRate;
    NSInteger offset;
}

- (instancetype)initWithFrameSize: (CGSize)frameSize
                AndTargetViewSize: (CGSize)viewSize
{
    self = [super init];
    if (self)
    {
        [self setFrameSize: frameSize
         AndTargetViewSize: viewSize];
    }
    return self;
    
}

- (void)setFrameSize: (CGSize)frameSize
   AndTargetViewSize: (CGSize)viewSize
{
    CGFloat frameWidth  = frameSize.width;
    CGFloat frameHeight = frameSize.height;
    
    CGFloat viewWidth  = viewSize.width;
    CGFloat viewHeight = viewSize.height;
    
    CGFloat frameAspectRatio = frameHeight / frameWidth;
    CGFloat viewAspectRatio  = viewHeight / viewWidth;
    
    if (viewAspectRatio > frameAspectRatio)
    {
        conversionRate = viewHeight / frameHeight;
        CGFloat convertedFrameWidth = frameWidth * conversionRate;
        offset = (convertedFrameWidth - viewWidth) / 2;
    }
}

- (CGPoint)CGPointFromCVPoint: (cv::Point2f)point
{
    return CGPointMake((point.x * conversionRate) - offset,
                        point.y * conversionRate);
}

- (cv::Point2f)CVPointFromCGPoint: (CGPoint)point
{
    return cv::Point2f((point.x + offset) / conversionRate,
                        point.y / conversionRate);
}



@end
