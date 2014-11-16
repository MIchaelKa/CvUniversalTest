//
//  FindContoursViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 17/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "FindContoursViewController.h"

@interface FindContoursViewController ()

@end

@implementation FindContoursViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//- (void)processImage:(cv::Mat&)image
//{
//    NSLog(@"FindContoursViewController");
//}

- (void)setupUI
{
    [super setupUI];
    // Buttons
    [self addButtons: @[
                        self.undoButton,
                        self.startButton,
                        self.settingsButton
                        ]];
}


@end
