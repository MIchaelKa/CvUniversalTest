//
//  AnimatedPathView.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 08/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "AnimatedPathView.h"
#import "PointConvertor.h"

@interface AnimatedPathView()
{    
    UIBezierPath* currentPath;
    UIBezierPath* pathForDisplay;
}

@property (nonatomic, strong) CAShapeLayer* pathLayer;
@property (nonatomic, strong) PointConvertor* pointConvertor;

@end

@implementation AnimatedPathView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (CAShapeLayer *)pathLayer
{
    if (!_pathLayer)
    {
        _pathLayer = [CAShapeLayer layer];
        
        _pathLayer.path = [currentPath CGPath];
        _pathLayer.strokeColor = [[UIColor grayColor] CGColor];
        _pathLayer.fillColor = nil;
        _pathLayer.lineWidth = 3.0f;
        _pathLayer.lineJoin = kCALineJoinRound;
        
        [self.layer addSublayer: _pathLayer];
    }
    return _pathLayer;
}

- (void)setPathForDisplay: (std::vector<cv::Point2f>)path
{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    size_t i = 0;
    while (!(path[i].x > 0 || path[i].y > 0))
    {
        //TODO: investigate why we have a lot of zero point at the start
        ++i;
    }
    
    [bezierPath moveToPoint: [self.pointConvertor CGPointFromCVPoint: path[i]]];
    i++;
    
    for ( ; i < path.size(); ++i)
    {
        [bezierPath addLineToPoint: [self.pointConvertor CGPointFromCVPoint: path[i]]];
    }
    
    if (!currentPath)
    {
        // first path: nothing to animate
        currentPath = bezierPath;
        [self pathLayer];
        return;
    }

    currentPath = pathForDisplay;
    pathForDisplay = bezierPath;
    [self animate];
}

- (void)animate
{
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath: @"path"];
    
    pathAnimation.duration = 0.5;
    pathAnimation.fromValue = (id)[currentPath CGPath];
    pathAnimation.toValue   = (id)[pathForDisplay CGPath];
    
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [self.pathLayer addAnimation: pathAnimation forKey: @"animatePath"];
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
