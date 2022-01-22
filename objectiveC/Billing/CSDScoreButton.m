//
//  CSDScoreButton.m
//  CSD
//
//  Created by .D. .D. on 2/25/20.
//  Copyright © 2020 RCO. All rights reserved.
//

#import "CSDScoreButton.h"

@implementation CSDScoreButton

@synthesize selectedSegmentIndex = _selectedSegmentIndex;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setSelectedSegmentIndex:(NSInteger)index {
    if (index == -1) {
        [self setTitle:@"Not Set" forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15]];
    } else {
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        if (index < self.items.count) {
            NSString *title = [self.items objectAtIndex:index];
            [self setTitle:title forState:UIControlStateNormal];
        } else {
            NSLog(@"");
        }
    }
    [self setBackgroundColor:[UIColor orangeColor]];
    _selectedSegmentIndex = index;
}

-(NSInteger)numberOfSegments {
    return self.items.count;
}

@end
