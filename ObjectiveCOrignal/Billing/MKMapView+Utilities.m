//
//  MKMapView+Utilities.m
//  MobileOffice
//
//  Created by D. D. on 1/8/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import "MKMapView+Utilities.h"
#import "DataRepository.h"

@implementation MKMapView (Utilities)

-(void)centerMap {
    return [self centerMapForInfo:nil];
}

-(void)centerMapByAddingExtraLocation:(CLLocation*)location{
#define MAP_PADDING 1.1
    
    // we'll make sure that our minimum vertical span is about a kilometer
    // there are ~111km to a degree of latitude. regionThatFits will take care of
    // longitude, which is more complicated, anyway.
#define MINIMUM_VISIBLE_LATITUDE 0.01
    
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:[self annotations]];
    if (location) {
        [annotations addObject:location];
    }
    
    double minLat = 500;
    double maxLat = -500;
    double minLong = 500;
    double maxLong = -500;
    
    for (id<MKAnnotation> annotation in annotations) {
        
        double latitude = 0;
        double longitude = 0;
        
        if ([annotation isKindOfClass:[CLLocation class]]) {
            latitude = ((CLLocation*)annotation).coordinate.latitude;
            longitude = ((CLLocation*)annotation).coordinate.longitude;
        } else {
            latitude = annotation.coordinate.latitude;
            longitude = annotation.coordinate.longitude;
        }
        
        if (latitude > maxLat) {
            maxLat = latitude;
        }
        
        if (longitude > maxLong) {
            maxLong = longitude;
        }
        
        if (latitude < minLat) {
            minLat = latitude;
        }
        
        if (longitude < minLong) {
            minLong = longitude;
        }
    }
    
    CLLocationCoordinate2D currentLocation;
    
    if (self.userLocation.location) {
        currentLocation = CLLocationCoordinate2DMake(self.userLocation.location.coordinate.latitude, self.userLocation.location.coordinate.longitude);
    } else {
        currentLocation = CLLocationCoordinate2DMake([[[DataRepository sharedInstance] getCurrentLatitude] doubleValue], [[[DataRepository sharedInstance] getCurrentLongitude] doubleValue]);
    }
    /*
    if (self.showsUserLocation && self.userLocation.location) {
        if (self.userLocation.location.coordinate.latitude < minLat) {
            minLat = self.userLocation.location.coordinate.latitude;
        }
        if (self.userLocation.location.coordinate.latitude > maxLat) {
            maxLat = self.userLocation.location.coordinate.latitude;
        }
        
        if (self.userLocation.location.coordinate.longitude < minLong) {
            minLong = self.userLocation.location.coordinate.longitude;
        }
        if (self.userLocation.location.coordinate.longitude > maxLong) {
            maxLong = self.userLocation.location.coordinate.longitude;
        }
    }
*/
    if (self.showsUserLocation && (currentLocation.latitude != 0)) {
        if (currentLocation.latitude < minLat) {
            minLat = currentLocation.latitude;
        }
        if (currentLocation.latitude > maxLat) {
            maxLat = currentLocation.latitude;
        }
        
        if (currentLocation.longitude < minLong) {
            minLong = currentLocation.longitude;
        }
        if (currentLocation.longitude > maxLong) {
            maxLong = currentLocation.longitude;
        }
    }

    
    MKCoordinateRegion region;
    
    if (location) {
        region.center.latitude = location.coordinate.latitude;
        region.center.longitude = location.coordinate.longitude;
    } else {
        region.center.latitude = (minLat + maxLat) / 2;
        region.center.longitude = (minLong + maxLong) / 2;
    }
    
    double latitudeDelta = (maxLat - minLat) * MAP_PADDING;
    
    if (latitudeDelta < -90) {
        latitudeDelta = -90;
    } else if (latitudeDelta > 90) {
        latitudeDelta = 90;
    }
    region.span.latitudeDelta = latitudeDelta;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
    ? MINIMUM_VISIBLE_LATITUDE
    : region.span.latitudeDelta;
    
    double longitudeDelta = (maxLong - minLong) * MAP_PADDING;
    
    if (longitudeDelta > 180) {
        longitudeDelta = 180;
    } else if (longitudeDelta < -180) {
        longitudeDelta = -180;
    }
    
    region.span.longitudeDelta = longitudeDelta;
    
    MKCoordinateRegion scaledRegion = [self regionThatFits:region];
    if ([annotations count]) {
        [self setRegion:scaledRegion animated:YES];
    }
}


-(void)centerMapForInfo:(NSDictionary*)latLonInfo {
#define MAP_PADDING 1.1
    
    // we'll make sure that our minimum vertical span is about a kilometer
    // there are ~111km to a degree of latitude. regionThatFits will take care of
    // longitude, which is more complicated, anyway.
#define MINIMUM_VISIBLE_LATITUDE 0.01
    
    NSArray *annotations = [self annotations];
    
    double minLat = 500;
    double maxLat = -500;
    double minLong = 500;
    double maxLong = -500;
    
    if (latLonInfo) {
        minLat = [[latLonInfo objectForKey:LAT_MIN] doubleValue];
        minLong = [[latLonInfo objectForKey:LON_MIN] doubleValue];
        maxLat = [[latLonInfo objectForKey:LAT_MAX] doubleValue];
        maxLong = [[latLonInfo objectForKey:LON_MAX] doubleValue];
    }
    
    for (id<MKAnnotation> annotation in annotations) {
        double latitude = annotation.coordinate.latitude;
        double longitude = annotation.coordinate.longitude;
        
        if (latitude > maxLat) {
            maxLat = latitude;
        }
        
        if (longitude > maxLong) {
            maxLong = longitude;
        }
        
        if (latitude < minLat) {
            minLat = latitude;
        }
        
        if (longitude < minLong) {
            minLong = longitude;
        }
    }
        
    CLLocationCoordinate2D currentLocation;
    
    if (self.userLocation.location) {
        currentLocation = CLLocationCoordinate2DMake(self.userLocation.location.coordinate.latitude, self.userLocation.location.coordinate.longitude);
    } else {
        currentLocation = CLLocationCoordinate2DMake([[[DataRepository sharedInstance] getCurrentLatitude] doubleValue], [[[DataRepository sharedInstance] getCurrentLongitude] doubleValue]);
    }
    /*
     if (self.showsUserLocation && self.userLocation.location) {
     if (self.userLocation.location.coordinate.latitude < minLat) {
     minLat = self.userLocation.location.coordinate.latitude;
     }
     if (self.userLocation.location.coordinate.latitude > maxLat) {
     maxLat = self.userLocation.location.coordinate.latitude;
     }
     
     if (self.userLocation.location.coordinate.longitude < minLong) {
     minLong = self.userLocation.location.coordinate.longitude;
     }
     if (self.userLocation.location.coordinate.longitude > maxLong) {
     maxLong = self.userLocation.location.coordinate.longitude;
     }
     }
     */
    if (self.showsUserLocation && (currentLocation.latitude != 0)) {
        if (currentLocation.latitude < minLat) {
            minLat = currentLocation.latitude;
        }
        if (currentLocation.latitude > maxLat) {
            maxLat = currentLocation.latitude;
        }
        
        if (currentLocation.longitude < minLong) {
            minLong = currentLocation.longitude;
        }
        if (currentLocation.longitude > maxLong) {
            maxLong = currentLocation.longitude;
        }
    }
    
    MKCoordinateRegion region;
    region.center.latitude = (minLat + maxLat) / 2;
    region.center.longitude = (minLong + maxLong) / 2;
    
    double latitudeDelta = (maxLat - minLat) * MAP_PADDING;
    
    if (latitudeDelta < -90) {
        latitudeDelta = -90;
    } else if (latitudeDelta > 90) {
        latitudeDelta = 90;
    }
    region.span.latitudeDelta = latitudeDelta;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
    ? MINIMUM_VISIBLE_LATITUDE
    : region.span.latitudeDelta;
    
    double longitudeDelta = (maxLong - minLong) * MAP_PADDING;
    
    if (longitudeDelta > 180) {
        longitudeDelta = 180;
    } else if (longitudeDelta < -180) {
        longitudeDelta = -180;
    }
    
    region.span.longitudeDelta = longitudeDelta;
    
    MKCoordinateRegion scaledRegion = [self regionThatFits:region];
    if ([annotations count] || latLonInfo) {
        [self setRegion:scaledRegion animated:YES];
    }
}

@end
