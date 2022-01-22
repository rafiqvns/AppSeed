//
//  Attachment+CoreDataProperties.m
//  
//
//  Created by .D. .D. on 8/2/18.
//
//

#import "Attachment+CoreDataProperties.h"

@implementation Attachment (CoreDataProperties)

+ (NSFetchRequest<Attachment *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Attachment"];
}


@end
