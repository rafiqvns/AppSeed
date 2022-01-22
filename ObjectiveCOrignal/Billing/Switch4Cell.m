//
//  Switch4Cell.m
//  MobileOffice
//
//  Created by .D. .D. on 9/17/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "Switch4Cell.h"

@implementation Switch4Cell

@synthesize switch1;
@synthesize switch2;
@synthesize switch3;
@synthesize switch4;

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

-(void)setDelegate:(id<Switch4CellProtocol>)delegate {
    [self.switch1 addTarget:delegate
                       action:@selector(switchSelected:)
             forControlEvents:UIControlEventValueChanged];
    [self.switch2 addTarget:delegate
                     action:@selector(switchSelected:)
           forControlEvents:UIControlEventValueChanged];
    [self.switch3 addTarget:delegate
                     action:@selector(switchSelected:)
           forControlEvents:UIControlEventValueChanged];
    [self.switch4 addTarget:delegate
                     action:@selector(switchSelected:)
           forControlEvents:UIControlEventValueChanged];
}

/*
-(UIButton*)getButtonForTag:(NSInteger)tag {
    switch (tag) {
        case 0:
            return self.monButton;
            break;
        case 1:
            return self.tueButton;
            break;
        case 2:
            return self.wenButton;
            break;
        case 3:
            return self.thuButton;
            break;
        case 4:
            return self.friButton;
            break;
        case 5:
            return self.satButton;
            break;
        case 6:
            return self.sunButton;
            break;
    }
    return nil;
}
*/

@end
