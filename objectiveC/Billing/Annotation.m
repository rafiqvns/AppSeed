//
//  Annotation.m
//  Maps
//
//  Created by Thomas Smallwood on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"


@implementation Annotation

@synthesize coordinate = _coordinate;
@synthesize title      = _title;
@synthesize subtitle   = _subtitle;
@synthesize pinId;
@synthesize objectType;

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
  return [[[self class] alloc] initWithCoordinate:coordinate];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  
  self = [super init];
  
  if(nil != self) {
    self.coordinate = coordinate;
  }
  
  return self;
}

@end
