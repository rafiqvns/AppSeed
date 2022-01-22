//
//  Photo+CoreDataProperties.m
//  
//
//  Created by Dragos Dragos on 12/5/18.
//
//

#import "Photo+CoreDataProperties.h"

@implementation Photo (CoreDataProperties)

+ (NSFetchRequest<Photo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
}

@dynamic category;
@dynamic parentBarcode;
@dynamic parentObjectId;
@dynamic parentObjectType;
@dynamic title;

@end
