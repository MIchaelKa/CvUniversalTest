//
//  UIStoryboard+CvTest.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 16/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "UIStoryboard+CvTest.h"

@implementation UIStoryboard (CvTest)

+ (UIStoryboard*)mainStoryboard
{
    return [UIStoryboard storyboardWithName: @"Main" bundle:nil];
}

+ (UIStoryboard*)settingsStoryboard
{
    return [UIStoryboard storyboardWithName: @"Settings" bundle:nil];
}

@end
