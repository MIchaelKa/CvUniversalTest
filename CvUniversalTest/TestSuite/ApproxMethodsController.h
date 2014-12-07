//
//  ApproxMethodsController.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 07/12/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ApproxMethodsControllerDelegate <NSObject>

-(void)selectApproxMethod: (NSUInteger)methodIndex;

@end

@interface ApproxMethodsController : UITableViewController

@property (nonatomic, strong) NSArray* methods;
@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic, weak) id<ApproxMethodsControllerDelegate> delegate;

@end
