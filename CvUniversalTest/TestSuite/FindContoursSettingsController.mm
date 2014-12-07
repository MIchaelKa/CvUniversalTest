//
//  FindContoursSettingsController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 19/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "FindContoursSettingsController.h"

@interface FindContoursSettingsController ()

@property (weak, nonatomic) IBOutlet UISwitch *cannySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pointDrawingSwitch;

@property (weak, nonatomic) IBOutlet UISlider *tresholdSlider;
@property (weak, nonatomic) IBOutlet UITextField *firstTreshTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondTreshTextField;

@property (weak, nonatomic) IBOutlet UILabel *approxMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *retrievalModeLabel;

@end

@implementation FindContoursSettingsController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ApproxMethodsSegue"]) {
        ApproxMethodsController *amvc = segue.destinationViewController;
        amvc.delegate = self;
        amvc.methods = self.parent.approximationMethods;
        amvc.currentIndex = self.parent.currentApproxMethodIndex;
    }
    else if ([segue.identifier isEqualToString:@"RetrModeSegue"])
    {
        RetrievalModeController *rmvc = segue.destinationViewController;
        rmvc.delegate = self;
        rmvc.modes = self.parent.retrievalModes;
        rmvc.currentIndex = self.parent.currentRetrievalModeIndex;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI
{
    self.cannySwitch.on = self.parent.usingCanny;
    self.pointDrawingSwitch.on = self.parent.usingPointDrawing;
    
    self.tresholdSlider.minimumValue = 0.0;
    self.tresholdSlider.maximumValue = 250.0;
    self.tresholdSlider.value = self.parent.firstTreshold;
    
    [self updateTreshTextFields];
    
    self.approxMethodLabel.text = self.parent.currentMethodName;
    self.retrievalModeLabel.text = self.parent.currentModeName;
}

- (void)updateTreshTextFields
{
    self.firstTreshTextField.text = [NSString stringWithFormat: @"%d",
                                     self.parent.firstTreshold];
    
    self.secondTreshTextField.text = [NSString stringWithFormat: @"%d",
                                      self.parent.secondTreshold];
}

- (IBAction)saveAndExit:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated: YES completion: ^{
    }];
}

- (IBAction)useCannyStateDidChange:(UISwitch *)sender
{
    self.parent.usingCanny = sender.isOn;
}

- (IBAction)pointDrawingStateDidChange:(UISwitch *)sender
{
    self.parent.usingPointDrawing = sender.isOn;
}

- (IBAction)takeTresholdValue:(UISlider *)sender
{
    self.parent.firstTreshold = sender.value;
    [self updateTreshTextFields];
}

#pragma mark - ApproxMethodsControllerDelegate

-(void)selectApproxMethod: (NSUInteger)methodIndex
{
    self.parent.currentApproxMethodIndex = methodIndex;
    self.approxMethodLabel.text = self.parent.currentMethodName;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RetrievalModeControllerDelegate

-(void)selectRetrievalMode: (NSUInteger)modeIndex
{
    self.parent.currentRetrievalModeIndex = modeIndex;
    self.retrievalModeLabel.text = self.parent.currentModeName;
    [self.navigationController popViewControllerAnimated:YES];
}


@end
