//
//  TrainingScoreAggregate.h
//  CSD
//
//  Created by .D. .D. on 12/27/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"

NS_ASSUME_NONNULL_BEGIN

#define ST @"ST"
#define STG @"STG"

@interface TrainingScoreAggregate : Aggregate
-(void)getScoresForStudent:(NSString*)studentId fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;
@end

NS_ASSUME_NONNULL_END
