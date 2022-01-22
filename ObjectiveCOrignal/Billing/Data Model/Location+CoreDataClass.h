//
//  Location+CoreDataClass.h
//  
//
//  Created by .D. .D. on 4/17/18.
//
//

#import <Foundation/Foundation.h>
#import "InfoGeoLocation.h"

#define LocationRanch @"ranch"
#define LocationField @"field"
#define LocationArea @"area"
#define LocationShip @"ship"

#define KEY_RanchRecordId @"ranchRecordId"


NS_ASSUME_NONNULL_BEGIN

@interface Location : InfoGeoLocation

-(NSString*)CSVFormat;

@end

NS_ASSUME_NONNULL_END

#import "Location+CoreDataProperties.h"
