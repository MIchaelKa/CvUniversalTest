//
//  UIBezierPath+CVUTBezierPath.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 09/06/15.
//  Copyright (c) 2015 Michael. All rights reserved.
//

#import "UIBezierPath+CVUTBezierPath.h"

@implementation UIBezierPath (CVUTBezierPath)

- (CGFloat)distanceFromPath: (UIBezierPath*)path
{
    CGPoint currentPathTL = path.bounds.origin;
    CGPoint selfPathTL    = self.bounds.origin;
    
    CGFloat xDistance = selfPathTL.x - currentPathTL.x;
    CGFloat yDistance = selfPathTL.y - currentPathTL.y;
    
    CGFloat distance = sqrt((xDistance * xDistance) + (yDistance * yDistance));
    
    return distance;
}

@end
