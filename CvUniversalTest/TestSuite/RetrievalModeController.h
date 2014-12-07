//
//  RetrievalModeController.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 07/12/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RetrievalModeControllerDelegate <NSObject>

-(void)selectRetrievalMode: (NSUInteger)modeIndex;

@end

@interface RetrievalModeController : UITableViewController

@property (nonatomic, strong) NSArray* modes;
@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic, weak) id<RetrievalModeControllerDelegate> delegate;

@end
