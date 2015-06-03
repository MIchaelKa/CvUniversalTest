//
//  PickerViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "PickerViewController.h"

#import "TestSuite/TestSuite.h"
#import "TestSuite/FindContoursController.h"
#import "TestSuite/SimpleTestController.h"
#import "TestSuite/TrackObjectController.h"

@interface PickerViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) TestSuite* testSuite;

@property (strong, nonatomic) NSArray* availableTestNames;
@property (nonatomic) NSInteger currentTestIndex;

@property (strong, nonatomic) CameraViewController* testViewController;

@end

@implementation PickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.testSuite = [[TestSuite alloc] init];
    
    self.availableTestNames = self.testSuite.availableTestNames;
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    NSInteger component = 0;
    self.currentTestIndex = [self.pickerView numberOfRowsInComponent: component] / 2;
    [self.pickerView selectRow: self.currentTestIndex
                   inComponent: component
                      animated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tap:(UITapGestureRecognizer *)sender
{
    [self presentViewController: self.testViewController
                       animated: YES
                     completion: nil];
}

- (CameraViewController*)testViewController
{
    if (!_testViewController)
    {
        _testViewController = [self createTestController];
        _testViewController.delegate = self;
        _testViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    if (!_testViewController.testSuite)
    {
        _testViewController.testSuite = self.testSuite;
    }
    _testViewController.testSuite.currentTestIndex = self.currentTestIndex;
    return _testViewController;
}

- (CameraViewController*)createTestController
{
    switch (self.currentTestIndex)
    {
        case GOOD_FEATURES:
        case CANNY_EDGE_DETECTION:
        case MORPH_TRANSFORM:
        case THRESHOLD:
        {
            return [[SimpleTestController alloc] init];
            
        }
        case FIND_CONTOURS:
        {
            return [[FindContoursController alloc] init];
        }
        case TRACK_OBJECT:
        {
            return [[TrackObjectController alloc] init];
        }
        default:
        {
            return [[CameraViewController alloc] init];
        }
    }
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return self.availableTestNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    self.currentTestIndex = row;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.availableTestNames.count;
}

#pragma mark - CameraViewControllerDelegate

- (void)cameraViewControllerDidFinishedWithCompletion:(void (^)(void))completion
{
    [self.testViewController dismissViewControllerAnimated: YES completion: completion];
    self.testViewController.delegate = nil;
    self.testViewController = nil;
}

@end
