//
//  PickerViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "PickerViewController.h"

#import "TestSuite/TestSuite.h"
#import "TestSuite/FindContoursViewController.h"

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
        _testViewController = [[FindContoursViewController alloc] init];
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

- (void)cameraViewControllerDidFinished
{
    [self.testViewController dismissViewControllerAnimated: YES completion: nil];
    self.testViewController.delegate = nil;
    self.testViewController = nil;
}

@end
