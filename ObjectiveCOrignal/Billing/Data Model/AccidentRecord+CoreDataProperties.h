//
//  AccidentRecord+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/5/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "AccidentRecord+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AccidentRecord (CoreDataProperties)

+ (NSFetchRequest<AccidentRecord *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *accidentType;
@property (nullable, nonatomic, copy) NSString *fatilities;
@property (nullable, nonatomic, copy) NSString *injuries;

@end

NS_ASSUME_NONNULL_END
