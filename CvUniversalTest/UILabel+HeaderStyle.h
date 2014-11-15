//
//  UILabel+HeaderStyle.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 26/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (HeaderStyle)

+ (UILabel *)headerLabelWithTitle: (NSString *)title
                   onViewWithSize: (CGSize)size;

@end
