//
//  FindContoursSettingsController.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 19/11/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FindContoursController.h"

#import "ApproxMethodsController.h"
#import "RetrievalModeController.h"

@interface FindContoursSettingsController : UITableViewController <ApproxMethodsControllerDelegate,
                                                                   RetrievalModeControllerDelegate>

@property (weak, nonatomic) FindContoursController* parent;

@end
