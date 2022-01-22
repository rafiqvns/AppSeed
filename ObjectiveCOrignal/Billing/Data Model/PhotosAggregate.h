//
//  PhotosAggregate.h
//  MobileOffice
//
//  Created by .D. .D. on 11/15/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "Aggregate.h"

#define SET_PHOTOS @"setPhotos"

#define PicturesGroup @"Pictures"

@interface PhotosAggregate : Aggregate

-(NSArray*)getPhotosForObject:(RCOObject*)obj;
-(NSArray*)getPhotosForObjectRecordId:(NSString*)recordId;
-(void)getPhotosForMasterBarcode:(NSString*)masterBarcode;
-(NSInteger)getPhotosCountToUpload;
-(NSArray*)getPhotosToUpload;

@end
