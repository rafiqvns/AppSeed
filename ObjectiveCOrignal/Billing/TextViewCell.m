//
//  TextViewCell.m
//  Jobs
//
//  Created by .D. .D. on 4/11/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "TextViewCell.h"

@implementation TextViewCell

@synthesize textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
