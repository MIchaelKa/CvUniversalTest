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

@end

@implementation FindContoursSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI
{
    self.cannySwitch.on = self.parent.usingCanny;
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

@end
