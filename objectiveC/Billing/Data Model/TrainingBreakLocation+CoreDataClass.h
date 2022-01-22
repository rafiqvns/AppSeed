//
//  TrainingBreakLocation+CoreDataClass.h
//  CSD
//
//  Created by .D. .D. on 4/14/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "Driver+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrainingBreakLocation : Driver
- (NSString*)CSVFormat;
@end

NS_ASSUME_NONNULL_END

#import "TrainingBreakLocation+CoreDataProperties.h"
