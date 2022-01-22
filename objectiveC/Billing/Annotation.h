//
//  Annotation.h
//  Maps
//
//  Created by Thomas Smallwood on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject<MKAnnotation> {
  CLLocationCoordinate2D _coordinate;
  NSString *_title;
  NSString *_subtitle;
}

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSInteger pinId;
@property (nonatomic, strong) NSString *objectType;
@property (nonatomic, strong) NSString *objectId;

@end
