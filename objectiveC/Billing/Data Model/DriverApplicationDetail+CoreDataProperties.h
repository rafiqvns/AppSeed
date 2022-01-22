//
//  DriverApplicationDetail+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/5/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverApplicationDetail+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverApplicationDetail (CoreDataProperties)

+ (NSFetchRequest<DriverApplicationDetail *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSString *charge;
@property (nullable, nonatomic, copy) NSString *penalty;

@end

NS_ASSUME_NONNULL_END
