//
//  TrainingInstructor+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingInstructor+CoreDataClass.h"

@implementation TrainingInstructor
-(NSString*)info {
    NSMutableArray *arr = [NSMutableArray array];
    if (self.lastName.length) {
        [arr addObject:self.lastName];
    }
    if (self.firstName.length) {
        [arr addObject:self.firstName];
    }
    if (self.instructorId.length) {
        [arr addObject:self.instructorId];
    }
    return [arr componentsJoinedByString:@","];
}

-(NSString*)Name {
    NSMutableArray *arr = [NSMutableArray array];
    if (self.lastName.length) {
        [arr addObject:self.lastName];
    }
    if (self.firstName.length) {
        [arr addObject:self.firstName];
    }
    return [arr componentsJoinedByString:@","];
}

-(NSString*)customId {
    return self.instructorId;
}

@end
