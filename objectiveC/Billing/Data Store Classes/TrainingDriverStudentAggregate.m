//
//  TrainingDriverStudentAggregate.m
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TrainingDriverStudentAggregate.h"
#import "TrainingStudent+CoreDataClass.h"
#import "RCOObject+RCOObject_Imp.h"
#import "DataRepository.h"
#import "Settings.h"

@implementation TrainingDriverStudentAggregate
- (id) init {
    if ((self = [super init]) != nil){
        self.rcoObjectClass = kUserTypeStudent;
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, kTrainingStudentsRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(BOOL)FFFilter {
    
    return NO;
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    if (![[organizationName lowercaseString] isEqualToString:[userCompany lowercaseString]]) {
        return YES;
    }
    if (![[DataRepository sharedInstance] isTheSameUserLogged]) {
        [self resetTimestampParameter];
    }
    return NO;
}

-(TrainingStudent*)getStudentWithId:(NSString*)studentId {
    if (studentId.length == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"studentId=%@", studentId];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}

-(User*)getStudentWithEmployeeId:(NSString*)employeeId {
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
