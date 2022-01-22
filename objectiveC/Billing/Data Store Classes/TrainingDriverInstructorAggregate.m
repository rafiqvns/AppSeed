//
//  TrainingDriverInstructorAggregate.m
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TrainingDriverInstructorAggregate.h"
#import "TrainingInstructor+CoreDataClass.h"
#import "RCOObject+RCOObject_Imp.h"
#import "Settings.h"

@implementation TrainingDriverInstructorAggregate
- (id) init {
    if ((self = [super init]) != nil){
        self.rcoObjectClass = kUserTypeInstructor;
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, kTrainingInstructorsRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(BOOL)FFFilter {
    
    return NO;
    return YES;

    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    if (![[organizationName lowercaseString] isEqualToString:[userCompany lowercaseString]]) {
        return YES;
    }
    return NO;
}
-(User*)getInstructorWithId:(NSString*)instructorId {
    if (instructorId.length == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"instructorId=%@", instructorId];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}

-(User*)getInstructorWithEmployeeId:(NSString*)employeeId {
    if (employeeId.length == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"employeeNumber=%@", employeeId];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}


@end
