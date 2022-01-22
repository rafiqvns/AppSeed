//
//  AccidentWitness+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 5/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentWitness+CoreDataProperties.h"

@implementation AccidentWitness (CoreDataProperties)

+ (NSFetchRequest<AccidentWitness *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AccidentWitness"];
}


@end
