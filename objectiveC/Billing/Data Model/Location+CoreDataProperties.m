//
//  Location+CoreDataProperties.m
//  
//
//  Created by .D. .D. on 4/17/18.
//
//

#import "Location+CoreDataProperties.h"

@implementation Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Location"];
}

@dynamic address1;
@dynamic city;
@dynamic country;
@dynamic number;
@dynamic state;
@dynamic zipcode;

@end
