//
//  MapsViewController.h
//  Billing2
//
//  Created by Thomas Smallwood on 7/22/11.
//  Copyright 2011 RCO All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RCOObject.h"
#import "Aggregate.h"
#import "AddObject.h"
#import "BaseViewController.h"
#import <MessageUI/MessageUI.h>

#define kPOILat 34.043032
#define kPOILong -118.2668459

@class Annotation;
@class JobHeader;

@interface MapsViewController : BaseViewController <CLLocationManagerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, RCODataDelegate, AddObject, MFMailComposeViewControllerDelegate> {
    
    Annotation *_newAnnotation;
    CLLocationManager *_locationManager;
    NSString *_latitude;
    NSString *_longitude;
    
    BOOL needsToSearchLocation;
    BOOL _isFirstLoad;
}

@property (nonatomic, strong) Annotation *anAnnotation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, weak) Aggregate *objectAggregate;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, weak) id <AddObject> addDelegate;

@property (nonatomic, strong) RCOObject *object;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) BOOL hideInfoButton;
@property (nonatomic, assign) BOOL showEmailButton;
@property (nonatomic, strong) NSString *emailSubject;
@property (nonatomic, assign) BOOL selectMapType;
@property (nonatomic, assign) MKMapType mapType;
@property (nonatomic, assign) BOOL hideMapType;
@property (nonatomic, strong) NSString *currentLocationImageName;
@property (nonatomic, assign) BOOL showCurrentLocation;
@property (nonatomic, strong) NSString *customImageName;

@property (nonatomic, strong) IBOutlet UISegmentedControl *mapTypeSegmentedController;
@property (nonatomic, strong) IBOutlet UIBarItem *mapTypeBtn;

@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;


- (void)setCurrentLocation:(CLLocation *)location;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil object:(RCOObject*)object;

- (IBAction)infoPressed:(id)sender;

- (IBAction)mapSatelliteSegmentControlTapped:(UISegmentedControl *)sender;
@end
