//
//  AnnotationView.h
//  MobileOffice
//
//  Created by .D. .D. on 4/1/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol MKAnnotation;

@interface AnnotationView : MKAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier image:(UIImage *)image;

@end
