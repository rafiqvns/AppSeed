//
//  UILabelWithInset.m
//  MobileOffice
//
//  Created by .D. .D. on 7/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "UILabelWithInset.h"

@implementation UILabelWithInset

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawTextInRect:(CGRect)rect {
     UIEdgeInsets insets = {0, 5, 0, 5};
     [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
