//
//  TrainingDriverInstructorAggregate.h
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"
#import "UserAggregate.h"

NS_ASSUME_NONNULL_BEGIN

@class TrainingInstructor;
@class User;

@interface TrainingDriverInstructorAggregate : UserAggregate

-(User*)getInstructorWithId:(NSString*)instructorId;
-(User*)getInstructorWithEmployeeId:(NSString*)employeeId;

@end

NS_ASSUME_NONNULL_END
