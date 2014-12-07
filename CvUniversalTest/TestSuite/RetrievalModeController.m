//
//  RetrievalModeController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 07/12/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "RetrievalModeController.h"

@interface RetrievalModeController ()

@end

@implementation RetrievalModeController

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
    return self.modes.count;
}

- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RetrModeCell"];
    
    cell.textLabel.text = self.modes[indexPath.row];    
    
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
    
    [self.delegate selectRetrievalMode: self.currentIndex];
}

@end
