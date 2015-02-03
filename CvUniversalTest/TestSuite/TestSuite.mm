//
//  TestSuite.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 25/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "TestSuite.h"

using namespace std;

@interface TestSuite()
{
}

@end

@implementation TestSuite

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

# pragma mark - Test name

- (NSString *) currentTestName
{
    return [self testNameFromIndex: self.currentTestIndex];
}

- (NSArray *)availableTestNames
{
    if (_availableTestNames == nil)
    {
        NSMutableArray* names = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < CV_TEST_COUNT; i++)
        {
            [names addObject: [self testNameFromIndex: i]];
        }
        _availableTestNames = names;
    }
    return _availableTestNames;
}

- (NSString *)testNameFromIndex: (NSInteger)index
{
    switch (index)
    {
        case GOOD_FEATURES:
        {
            return @"Good Features to Track";
        }
        case FIND_CONTOURS:
        {
            return @"Find Contours";
        }
        case TRACK_OBJECT:
        {
            return @"Track Object";
        }
        case CANNY_EDGE_DETECTION:
        {
            return @"Canny Edge Detection";
        }
        case MORPH_TRANSFORM:
        {
            return @"Morphological Transform";
        }
        case THRESHOLD:
        {
            return @"Threshold";
        }
        default:
        {
            return @"";
        }
    }
}

- (BOOL)isSimple
{
    switch (self.currentTestIndex)
    {
        case GOOD_FEATURES:
        case CANNY_EDGE_DETECTION:
        case MORPH_TRANSFORM:
        case THRESHOLD:
        {
            return YES;
        }
        case FIND_CONTOURS:
        case TRACK_OBJECT:
        {
            return NO;
        }
        default:
        {
            return NO;
        }
    }
}

@end
