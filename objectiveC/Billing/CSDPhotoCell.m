//
//  CSDPhotoCell.m
//  MobileOffice
//
//  Created by .D. .D. on 8/16/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "CSDPhotoCell.h"

@implementation CSDPhotoCell

@synthesize imgView;

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
