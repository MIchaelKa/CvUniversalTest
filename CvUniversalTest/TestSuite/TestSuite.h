//
//  TestSuite.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 25/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif


NS_ENUM(NSInteger, CvTest)
{
    GOOD_FEATURES = 0,
    FIND_CONTOURS,
    TRACK_OBJECT,
    CANNY_EDGE_DETECTION,
    MORPH_TRANSFORM,
    THRESHOLD,
    
    CV_TEST_COUNT

};


@interface TestSuite : NSObject

@property (nonatomic, strong) NSArray* availableTestNames;
@property (nonatomic, strong) NSString* currentTestName;

@property (nonatomic) NSInteger currentTestIndex;
@property (nonatomic) BOOL isSimple;

@end
