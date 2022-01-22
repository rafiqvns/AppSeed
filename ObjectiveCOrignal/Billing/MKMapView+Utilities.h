//
//  MKMapView+Utilities.h
//  MobileOffice
//
//  Created by D. D. on 1/8/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import <MapKit/MapKit.h>

#define LAT_MIN @"latMin"
#define LAT_MAX @"latMax"

#define LON_MIN @"lonMin"
#define LON_MAX @"lonMax"

@interface MKMapView (Utilities)
-(void)centerMap;
-(void)centerMapByAddingExtraLocation:(CLLocation*)location;
-(void)centerMapForInfo:(NSDictionary*)latLonInfo;
@end
