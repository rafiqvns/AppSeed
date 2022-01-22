//
//  TrainingCompanyAggregate.h
//  MobileOffice
//
//  Created by .D. .D. on 6/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"


@class TrainingCompany;
NS_ASSUME_NONNULL_BEGIN

@interface TrainingCompanyAggregate : Aggregate

-(TrainingCompany*)getTrainingCompanyWithName:(NSString*)name;
-(TrainingCompany*)getCurrentDrivingSchool;
-(void)createDefaultCompany;

@end

NS_ASSUME_NONNULL_END
