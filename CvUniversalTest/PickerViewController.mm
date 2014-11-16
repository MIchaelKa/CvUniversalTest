//
//  PickerViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 23/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "PickerViewController.h"

#import "CameraViewController.h"
#import "TestSuite/TestSuite.h"

@interface PickerViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) TestSuite* testSuite;

@property (strong, nonatomic) NSArray* availableTestNames;
@property (nonatomic) NSInteger currentTestIndex;

@property (strong, nonatomic) CameraViewController* cameraViewController;

@end

@implementation PickerViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Camera controller"])
    {
        CameraViewController* cvc = segue.destinationViewController;
        if (cvc.testSuite == nil)
        {
            cvc.testSuite = self.testSuite;
        }
        cvc.testSuite.currentTestIndex = self.currentTestIndex;
    }
}

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
    self.cameraViewController = [[CameraViewController alloc] init];
    if (self.cameraViewController.testSuite == nil)
    {
        self.cameraViewController.testSuite = self.testSuite;
    }
    self.cameraViewController.testSuite.currentTestIndex = self.currentTestIndex;
    
    [self presentViewController: self.cameraViewController
                       animated: YES
                     completion: nil];
}

#pragma mark UIPickerViewDelegate

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

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.availableTestNames.count;
}

@end
