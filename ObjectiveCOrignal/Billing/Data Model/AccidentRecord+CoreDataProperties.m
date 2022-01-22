//
//  AccidentRecord+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/5/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "AccidentRecord+CoreDataProperties.h"

@implementation AccidentRecord (CoreDataProperties)

+ (NSFetchRequest<AccidentRecord *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AccidentRecord"];
}

@dynamic accidentType;
@dynamic fatilities;
@dynamic injuries;

@end
