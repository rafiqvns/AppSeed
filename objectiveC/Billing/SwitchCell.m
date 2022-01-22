//
//  SwitchCell.m
//  MobileOffice
//
//  Created by .D. .D. on 5/4/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

@synthesize optionLabel;
@synthesize optionSwitch;

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
