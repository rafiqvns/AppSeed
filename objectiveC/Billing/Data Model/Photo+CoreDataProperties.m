//
//  Photo+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 4/11/19.
//  Copyright © 2019 RCO. All rights reserved.
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
