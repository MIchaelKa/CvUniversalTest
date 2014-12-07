//
//  ApproxMethodsController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 07/12/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "ApproxMethodsController.h"

@interface ApproxMethodsController ()

@end

@implementation ApproxMethodsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.methods.count;
}

- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApproxMethodCell"];
    
    cell.textLabel.text = self.methods[indexPath.row];
    
    if (indexPath.row == 0) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor grayColor];
    }
    
    if (self.currentIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:
                             [NSIndexPath indexPathForRow: self.currentIndex
                                                inSection: 0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    self.currentIndex = indexPath.row;
    
    cell = [tableView cellForRowAtIndexPath: indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.delegate selectApproxMethod: self.currentIndex];
}

@end
