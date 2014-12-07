//
//  FindContoursController.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 17/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "CameraViewController.h"

@interface FindContoursController : CameraViewController

// Settings
@property (nonatomic) BOOL usingCanny;

// Canny settings
@property (nonatomic) int firstTreshold;
@property (nonatomic, readonly) int secondTreshold;
@property (nonatomic) int ratio;

// Approx settings
@property (nonatomic, strong) NSArray* approximationMethods;
@property (nonatomic) NSUInteger currentApproxMethodIndex;
@property (nonatomic, strong) NSString* currentMethodName;

@end
