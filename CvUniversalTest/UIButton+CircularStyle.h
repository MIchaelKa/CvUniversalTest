//
//  UIButton+CircularStyle.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (CircularStyle)

+ (UIButton *)circularButtonWithImageNamed: (NSString *)imageName;

+ (NSInteger)buttonSize;
+ (NSInteger)buttonInterval;

- (void)setPositionAtPoint: (CGPoint)point;

@end
