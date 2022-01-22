//
//  StaffAggregate.m
//  Billing2
//
//  Created by .R.H. on 9/16/11.
//  Copyright 2011 RCO All rights reserved.
//

#import "StaffAggregate.h"


@implementation StaffAggregate
- (id) init
{
    if ((self = [super init]) != nil){
		
        self.rcoObjectClass = @"staff";
        self.aggregateRight = kStaffRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kStaffSyncRight, nil];
	}
	return self;
    
}

@end
