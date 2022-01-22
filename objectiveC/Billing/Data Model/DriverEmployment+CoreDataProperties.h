//
//  DriverEmployment+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverEmployment+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverEmployment (CoreDataProperties)

+ (NSFetchRequest<DriverEmployment *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *lastEmployerName;
@property (nullable, nonatomic, copy) NSString *lastEmployerAddress;
@property (nullable, nonatomic, copy) NSString *lastEmployerCity;
@property (nullable, nonatomic, copy) NSString *lastEmployerState;
@property (nullable, nonatomic, copy) NSString *lastEmployerZipcode;
@property (nullable, nonatomic, copy) NSString *lastEmployerTelephoneNumber;
@property (nullable, nonatomic, copy) NSString *lastEmployerReasonsforleaving;
@property (nullable, nonatomic, copy) NSString *secondLastEmployerName;
@property (nullable, nonatomic, copy) NSString *secondLastEmployerAddress;
@property (nullable, nonatomic, copy) NSString *secondLastEmployerCity;
@property (nullable, nonatomic, copy) NSString *secondLastEmployerState;
@property (nullable, nonatomic, copy) NSString *secondLastEmployerZipcode;
@property (nullable, nonatomic, copy) NSString *secondLastEmployerTelephoneNumber;
@property (nullable, nonatomic, copy) NSString *secondLastEmployerReasonsforleaving;
@property (nullable, nonatomic, copy) NSString *thirdLastEmployerName;
@property (nullable, nonatomic, copy) NSString *thirdLastEmployerAddress;
@property (nullable, nonatomic, copy) NSString *thirdLastEmployerCity;
@property (nullable, nonatomic, copy) NSString *thirdLastEmployerState;
@property (nullable, nonatomic, copy) NSString *thirdLastEmployerZipcode;
@property (nullable, nonatomic, copy) NSString *thirdLastEmployerTelephoneNumber;
@property (nullable, nonatomic, copy) NSString *thirdLastEmployerReasonsforleaving;

@end

NS_ASSUME_NONNULL_END
