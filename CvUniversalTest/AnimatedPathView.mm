//
//  AnimatedPathView.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 08/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "AnimatedPathView.h"

#import "PointConvertor.h"
#import "UIBezierPath+CVUTBezierPath.h"

@interface AnimatedPathView()
{    
    UIBezierPath* currentPath;
    UIBezierPath* pathForDisplay;
}

@property (nonatomic, strong) CAShapeLayer* pathLayer;

@property (nonatomic, strong) NSMutableArray* paths;
@property (nonatomic, strong) NSMutableArray* pathsForSearch;
@property (nonatomic, strong) NSMutableArray* shapeLayers;

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
        
        self.paths = [NSMutableArray array];
        self.shapeLayers = [NSMutableArray array];
    }
    return self;
}

- (void)setPathForDisplay: (std::vector<cv::Point2f>)path
{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    size_t i = 0;
    while (!(path[i].x > 0 || path[i].y > 0))
    {
        //TODO: investigate why we have a lot of zero points at the start        
        ++i;
    }
    
    [bezierPath moveToPoint: [self.pointConvertor CGPointFromCVPoint: path[i]]];
    i++;
    
    for ( ; i < path.size(); ++i)
    {
        [bezierPath addLineToPoint: [self.pointConvertor CGPointFromCVPoint: path[i]]];
    }
    
    [self animateBezierPath: bezierPath];
}

- (void)setRectForDisplay: (cv::Rect)rect
{
    CGPoint convertedTL = [self.pointConvertor CGPointFromCVPoint: cv::Point2f(rect.tl().x, rect.tl().y)];
    CGRect convertedRect = CGRectMake(convertedTL.x,
                                      convertedTL.y,
                                      rect.width,
                                      rect.height);
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRect: convertedRect];
    
    [self animateBezierPath: bezierPath];
}

- (void)setRectsForDisplay: (std::vector<cv::Rect>)rects;
{
    // 1 - Add new layers
    for (size_t i = self.paths.count; i < rects.size(); i++)
    {
        UIBezierPath* bezierPath = [self bezierPathFromRect:rects[i]];
        CAShapeLayer* shapeLayer = [self shapeLayerWithInintialPath: [bezierPath CGPath]];
        
        [self.paths addObject:bezierPath];
        [self.shapeLayers addObject: shapeLayer];
    }

    self.pathsForSearch = [[NSMutableArray alloc] initWithArray: self.paths];
    
    NSMutableArray* currentPaths = [[NSMutableArray alloc] initWithArray: self.paths];
    
    NSMutableIndexSet *layersInUse = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *layersToRemove = [NSMutableIndexSet indexSet];
    
    // 2 - Find layers to animate
    for (size_t i = 0; i < rects.size(); i++)
    {
        UIBezierPath* bezierPath = [self bezierPathFromRect:rects[i]];
        UIBezierPath* previousPath = [self findPreviousPathFor:bezierPath];
        
        NSInteger index = [self.paths indexOfObject:previousPath];
        [layersInUse addIndex:index];
        [currentPaths replaceObjectAtIndex:index withObject:bezierPath];
        
        NSLog(@"index: %d", index);
    }
    
    // 4 - Find layers to remove
    for (NSInteger i = 0; i < self.paths.count; i++)
    {
        if (![layersInUse containsIndex:i])
        {
            [layersToRemove addIndex:i];
        }
    }
    
    // 5 - Remove unused layers and paths
    [currentPaths removeObjectsAtIndexes: layersToRemove];
    [self.paths removeObjectsAtIndexes: layersToRemove];
    
    __weak typeof(self) weakSelf = self;
    
    [layersToRemove enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
        CAShapeLayer* shapeLayer = weakSelf.shapeLayers[idx];
        shapeLayer.path = nil;
        [shapeLayer removeAllAnimations];
        [shapeLayer removeFromSuperlayer];
    }];
    
    [self.shapeLayers removeObjectsAtIndexes: layersToRemove];
    
    // 6 - Animate
    for (NSInteger i = 0; i < self.shapeLayers.count; i++)
    {
        CAShapeLayer* shapeLayer = self.shapeLayers[i];
        
        // Create Animation
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath: @"path"];
        
        pathAnimation.duration = 0.3;
        pathAnimation.fromValue = (id)[self.paths[i] CGPath];
        pathAnimation.toValue   = (id)[currentPaths[i] CGPath];
        
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = NO;
        
        // Animate
        [shapeLayer addAnimation: pathAnimation forKey: @"animatePath"];
    }
    
    self.paths = currentPaths;
}

- (UIBezierPath *)bezierPathFromRect: (cv::Rect)rect
{
    CGPoint convertedTL = [self.pointConvertor CGPointFromCVPoint: cv::Point2f(rect.tl().x, rect.tl().y)];
    CGRect convertedRect = CGRectMake(convertedTL.x,
                                      convertedTL.y,
                                      rect.width,
                                      rect.height);
    
    return [UIBezierPath bezierPathWithRect: convertedRect];
}

- (UIBezierPath *)findPreviousPathFor: (UIBezierPath *)path
{
    if (self.pathsForSearch.count == 0)
    {
        NSLog(@"ERROR: There are no paths to search!");
        return nil;
    }
    
    UIBezierPath * previousPath = self.pathsForSearch[0];
    CGFloat minDistance = [path distanceFromPath:previousPath];
    NSInteger index = 0;
    
    for (NSInteger i = 1; i < self.pathsForSearch.count; i++)
    {
        UIBezierPath * currPath = self.pathsForSearch[i];
        CGFloat currDistance = [path distanceFromPath:currPath];
        
        if (currDistance < minDistance)
        {
            minDistance = currDistance;
            previousPath = currPath;
            index = i;
        }
    }
    
    [self.pathsForSearch removeObjectAtIndex:index];
    return previousPath;
}

- (CAShapeLayer *)shapeLayerWithInintialPath: (CGPathRef)path
{
    CAShapeLayer* shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path = path;
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 3.0f;
    shapeLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer: shapeLayer];
    
    return shapeLayer;
}

#pragma mark - Single path animation

- (void)clear
{
    self.pathLayer.path = nil;
    [self.pathLayer removeAllAnimations];
}

- (void)animateBezierPath: (UIBezierPath *)bezierPath
{
    if (!currentPath)
    {
        // first path: nothing to animate
        currentPath = bezierPath;
        [self pathLayer];
        return;
    }
    
    currentPath = pathForDisplay;
    pathForDisplay = bezierPath;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath: @"path"];
    
    pathAnimation.duration = 0.3;
    pathAnimation.fromValue = (id)[currentPath CGPath];
    pathAnimation.toValue   = (id)[pathForDisplay CGPath];
    
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [self.pathLayer addAnimation: pathAnimation forKey: @"animatePath"];
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
