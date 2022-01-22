//
//  TrainingDriverStudentAggregate.h
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"
#import "UserAggregate.h"

NS_ASSUME_NONNULL_BEGIN

@class TrainingStudent;
@class User;

@interface TrainingDriverStudentAggregate : UserAggregate
-(User*)getStudentWithId:(NSString*)studentId;
-(User*)getStudentWithEmployeeId:(NSString*)employeeId;

@end

NS_ASSUME_NONNULL_END
