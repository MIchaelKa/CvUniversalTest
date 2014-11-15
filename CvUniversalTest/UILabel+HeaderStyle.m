//
//  UILabel+HeaderStyle.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 26/10/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "UILabel+HeaderStyle.h"

@implementation UILabel (HeaderStyle)

+ (UILabel *)headerLabelWithTitle: (NSString *)title
                   onViewWithSize: (CGSize)size
{
    UIFont* font = [UIFont fontWithName: @"Helvetica"
                                   size: 25.0];
    
    CGRect frame;
    frame.size = [title sizeWithAttributes: @{ NSFontAttributeName : font }];
    frame.origin = CGPointMake((size.width / 2) - (frame.size.width / 2),
                               60);
    
    UILabel* headerLabel = [[UILabel alloc] initWithFrame: frame];
    
    headerLabel.font = font;
    headerLabel.text = title;
    
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.numberOfLines = 1;
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.hidden = NO;
    
    return headerLabel;
}

@end
