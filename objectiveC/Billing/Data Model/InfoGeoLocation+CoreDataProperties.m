//
//  InfoGeoLocation+CoreDataProperties.m
//  
//
//  Created by .D. .D. on 5/9/18.
//
//

#import "InfoGeoLocation+CoreDataProperties.h"

@implementation InfoGeoLocation (CoreDataProperties)

+ (NSFetchRequest<InfoGeoLocation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"InfoGeoLocation"];
}

@dynamic latitude;
@dynamic longitude;

@end
