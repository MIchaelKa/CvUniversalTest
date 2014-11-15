//
//  UIButton+CircularStyle.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "UIButton+CircularStyle.h"

@implementation UIButton (CircularStyle)

static const int CIRCULAR_BUTTON_SIZE = 60;

+ (UIButton *)circularButtonAtPoint: (CGPoint)point
                     withImageNamed: (NSString *)imageName
{
    UIButton* customButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    CGRect frame;
    frame.origin = CGPointMake(point.x - CIRCULAR_BUTTON_SIZE / 2,
                               point.y - CIRCULAR_BUTTON_SIZE / 2);
    frame.size = CGSizeMake(CIRCULAR_BUTTON_SIZE, CIRCULAR_BUTTON_SIZE);
    
    [customButton setFrame: frame];
    
    [customButton setImage: [UIImage imageNamed: imageName]
                  forState: UIControlStateNormal];
    
    customButton.backgroundColor = [UIColor whiteColor];
    customButton.layer.cornerRadius = customButton.bounds.size.width / 2.0;
    
    return customButton;
}

- (void)setPositionAtPoint: (CGPoint)point
{
    CGRect frame = self.frame;
    frame.origin = CGPointMake(point.x - CIRCULAR_BUTTON_SIZE / 2,
                               point.y - CIRCULAR_BUTTON_SIZE / 2);
    
    [self setFrame: frame];
}

@end
