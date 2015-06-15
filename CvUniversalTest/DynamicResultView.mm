//
//  DynamicResultView.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 15/06/15.
//  Copyright (c) 2015 Michael. All rights reserved.
//

#import "DynamicResultView.h"

#import "PointConvertor.h"

@interface DynamicResultView ()
{
    vector<Point2f> pointsForDisplay;
}

@property (nonatomic, strong) PointConvertor* pointConvertor;

@end

@implementation DynamicResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {       
        self.backgroundColor = nil;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setPointsForDisplay: (vector<Point2f>)points
{
    pointsForDisplay = points;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (pointsForDisplay.size() == 0)
    {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetLineWidth(context, 1);
    
    for (size_t i = 0; i < pointsForDisplay.size(); i++)
    {
        CGPoint circleCenter = [self.pointConvertor CGPointFromCVPoint: pointsForDisplay[i]];
        CGContextAddArc(context, circleCenter.x, circleCenter.y, 5, 0, 360, NO);
        
        CGContextStrokePath(context);
    }    
    
    UIGraphicsEndImageContext();
}

- (PointConvertor *)pointConvertor
{
    if (!_pointConvertor)
    {
        _pointConvertor = [[PointConvertor alloc] initWithFrameSize: self.frameSize
                                                  AndTargetViewSize: self.bounds.size];
    }
    return _pointConvertor;
}

@end
