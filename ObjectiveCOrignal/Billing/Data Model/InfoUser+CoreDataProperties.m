//
//  InfoUser+CoreDataProperties.m
//  
//
//  Created by .D. .D. on 12/5/18.
//
//

#import "InfoUser+CoreDataProperties.h"

@implementation InfoUser (CoreDataProperties)

+ (NSFetchRequest<InfoUser *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"InfoUser"];
}

@dynamic employeeId;
@dynamic firstName;
@dynamic lastName;
@dynamic userRecordId;
@dynamic city;
@dynamic state;
@dynamic zip;
@dynamic address1;

@end
