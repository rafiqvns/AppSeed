//
//  TrainingTestInfo+CoreDataClass.h
//  CSD
//
//  Created by .D. .D. on 11/7/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrainingTestInfo : RCOObject
-(NSString*)CSVFormat;
+(UIColor*)lightColor;
-(BOOL)isPaused;
-(void)addPauseDateTime:(NSDate*)dateTime;
-(NSString*)calculateElaspsedTime;
@end

NS_ASSUME_NONNULL_END

#import "TrainingTestInfo+CoreDataProperties.h"
