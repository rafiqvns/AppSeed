//
//  NoteCell.m
//  MobileOffice
//
//  Created by .D. .D. on 4/23/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "NoteCell.h"

@implementation NoteCell

@synthesize noteLabel;
@synthesize photoLabel;
@synthesize editButton;

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
