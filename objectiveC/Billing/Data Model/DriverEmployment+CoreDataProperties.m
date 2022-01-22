//
//  DriverEmployment+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverEmployment+CoreDataProperties.h"

@implementation DriverEmployment (CoreDataProperties)

+ (NSFetchRequest<DriverEmployment *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverEmployment"];
}

@dynamic lastEmployerName;
@dynamic lastEmployerAddress;
@dynamic lastEmployerCity;
@dynamic lastEmployerState;
@dynamic lastEmployerZipcode;
@dynamic lastEmployerTelephoneNumber;
@dynamic lastEmployerReasonsforleaving;
@dynamic secondLastEmployerName;
@dynamic secondLastEmployerAddress;
@dynamic secondLastEmployerCity;
@dynamic secondLastEmployerState;
@dynamic secondLastEmployerZipcode;
@dynamic secondLastEmployerTelephoneNumber;
@dynamic secondLastEmployerReasonsforleaving;
@dynamic thirdLastEmployerName;
@dynamic thirdLastEmployerAddress;
@dynamic thirdLastEmployerCity;
@dynamic thirdLastEmployerState;
@dynamic thirdLastEmployerZipcode;
@dynamic thirdLastEmployerTelephoneNumber;
@dynamic thirdLastEmployerReasonsforleaving;

@end
