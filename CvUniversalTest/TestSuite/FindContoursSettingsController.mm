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
@property (weak, nonatomic) IBOutlet UISlider *tresholdSlider;
@property (weak, nonatomic) IBOutlet UITextField *firstTreshTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondTreshTextField;

@end

@implementation FindContoursSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI
{
    self.cannySwitch.on = self.parent.usingCanny;
    
    self.tresholdSlider.minimumValue = 0.0;
    self.tresholdSlider.maximumValue = 250.0;
    self.tresholdSlider.value = self.parent.firstTreshold;
    
    [self updateTreshTextFields];
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

- (IBAction)takeTresholdValue:(UISlider *)sender
{
    self.parent.firstTreshold = sender.value;
    [self updateTreshTextFields];
}

@end
