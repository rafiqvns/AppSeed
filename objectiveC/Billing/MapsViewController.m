//
//  MapsViewController.m
//  Billing2
//
//  Created by Thomas Smallwood on 7/22/11.
//  Copyright 2011 RCO All rights reserved.
//

#import "MapsViewController.h"
#import "Annotation.h"
#import "DataRepository.h"
#import "User_Imp.h"
#import "RCOObjectListViewController.h"
#import "MKMapView+Utilities.h"

#import "RCOObjectListViewController.h"
#import "UIImage+Resize.h"

#define RCOObjectSearchKey @"searchKey"
#define TruckParts @"truckParts"


#define Key_BillOfLadings @"billOfladings"
#define Key_BillOfLading @"billOflading"


@implementation MapsViewController

@synthesize mapView         = _mapView;
@synthesize anAnnotation   = _newAnnotation;
@synthesize locationManager = _locationManager;
@synthesize latitude;
@synthesize longitude;
@synthesize objectAggregate;

@synthesize items;
@synthesize addDelegate;

@synthesize object;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil object:(RCOObject*)objectParam
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.object = objectParam;
    }
    return self;
}

- (void)dealloc {
    _locationManager.delegate = nil;
    self.object = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = self.showCurrentLocation;
    
    if ([self.title length] == 0) {
        // we should set the title name just in the case when we have't done it when created the screen
        if ([self.items count] == 0 ) {
            
        } else {
            NSObject *obj = [self.items objectAtIndex:0];
    
        }
    }
    
    if ((_latitude == nil) && (_longitude == nil)) {
        needsToSearchLocation = YES;
    }
    
    if (([_latitude doubleValue] != 0) && ([_longitude doubleValue] != 0)) {
        needsToSearchLocation = NO;
    } else {
        needsToSearchLocation = YES;
    }
    
    if (self.showEmailButton) {
        UIBarButtonItem *emailBtn = [[UIBarButtonItem alloc] initWithTitle:@"Email"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(emailButtonPressed:)];
        self.navigationItem.rightBarButtonItem = emailBtn;
    } else if (!self.object && (self.items.count == 0)) {
        // no object we should not show any info button
    }  else if (!self.hideInfoButton){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [btn addTarget:self action:@selector(infoPressed:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 0, 30, 30);
        UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = infoBtn;
    }

    if (DEVICE_IS_IPAD) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(closeButtonPressed:)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    _isFirstLoad = YES;
    if (self.selectMapType) {
        [self.mapTypeSegmentedController setSelectedSegmentIndex:self.mapType];
        [self mapSatelliteSegmentControlTapped:self.mapTypeSegmentedController];
    }
    
    if (self.hideMapType) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
        [items removeObject:self.mapTypeBtn];
        [self.bottomToolbar setItems:items];
    }
}


-(void)viewWillDisappear:(BOOL)animated {
    [[self aggregate] unRegisterForCallback:self];
    [super viewWillDisappear:animated];
}

#pragma mark Actions

-(IBAction)emailButtonPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        [self showEmailModalView];
    } else {
        [self showSimpleMessage:@"Please configure your email account"];
        NSString *path = [self getFilePathToSave];
        NSLog(@"Email file Path = %@", path);
        NSData *fileContent = [self makePDFfromView:self.mapView];
        
        BOOL res = [fileContent writeToFile:path atomically:YES];
        if (res) {
            NSLog(@"PDF sucessfully saved!");
        }
    }
}

-(IBAction)searchButtonPressed:(id)sender {
    
    
}

-(IBAction)infoPressed:(id)sender {
}

-(void)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didCancelObject:)]) {
        [self.addDelegate didCancelObject:nil];
    }
}

- (void)setCurrentLocation:(CLLocation *)location {
    
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    
    region.center = location.coordinate;
    
    region.span.longitudeDelta = 0.05f;
    region.span.latitudeDelta  = 0.05f;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
        
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate        = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    CLLocationDegrees lat  = kPOILat;
    CLLocationDegrees lon = kPOILong;
    
    if (!self.object && ([self.items count] == 0)) {
        self.items = [self.objectAggregate getAll];
    }
    
    if (needsToSearchLocation) {
        [self.locationManager startUpdatingLocation];
    } else {
        lat = [_latitude doubleValue];
        lon = [_longitude doubleValue];
    }
    
    if (_isFirstLoad) {
        CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:[[[DataRepository sharedInstance] getCurrentLatitude] doubleValue]
                                                                 longitude:[[[DataRepository sharedInstance] getCurrentLongitude] doubleValue]];
        
        self.anAnnotation = [Annotation annotationWithCoordinate:currentLocation.coordinate];
        self.anAnnotation.title    = @"Current Location";
        self.anAnnotation.subtitle = @"";
                
        [self setCurrentLocation:currentLocation];
        [[self aggregate] registerForCallback:self];
        
        if ([self.items count] == 0) {
            [self loadObject];
        } else {
            [self loadItems];
        }
        _isFirstLoad = NO;
    }
}

-(void)loadObject {
    if (!self.object && ([self.latitude doubleValue] && [self.longitude doubleValue])) {
        // we have just lat and long, we don't have an object to display
        [self setMapToLat:[self.latitude doubleValue]
                   andLon: [self.longitude doubleValue]
                withTitle:@"Location"
                andDetail:nil];
    }
}


-(void)loadItems {
    
    [self loadObject];
    
    double minLatitude = 9999;
    double maxLatitude = -9999;
    double minLongitude = 9999;
    double maxLongitude = -9999;
    


    NSLog(@"datarepository lat = %f long = %f", [DataRepository sharedInstance].latitude, [DataRepository sharedInstance].longitude);

    if (([DataRepository sharedInstance].latitude > maxLatitude) && ([DataRepository sharedInstance].latitude)) {
        maxLatitude = [DataRepository sharedInstance].latitude;
    }
    
    if (([DataRepository sharedInstance].latitude < minLatitude) && ([DataRepository sharedInstance].latitude)) {
        minLatitude = [DataRepository sharedInstance].latitude;
    }
    
    if (([DataRepository sharedInstance].longitude > maxLongitude) && ([DataRepository sharedInstance].longitude)){
        maxLongitude = [DataRepository sharedInstance].longitude ;
    }
    
    if (([DataRepository sharedInstance].longitude  < minLongitude)  && ([DataRepository sharedInstance].longitude)){
        minLongitude = [DataRepository sharedInstance].longitude ;
    }
    
    NSInteger pinId = 1;
    
    for (RCOObject *obj in self.items) {
        
        Annotation *anAnnotation = nil;
        
        if ([obj respondsToSelector:@selector(turnType)]) {
            // is a turn
            
            double lat = [[obj valueForKey:@"latitude"] doubleValue];
            double lon = [[obj valueForKey:@"longitude"] doubleValue];
            
            CLLocation* jhLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            
            if (lat> maxLatitude) {
                maxLatitude = lat;
            }
            
            if (lat < minLatitude) {
                minLatitude = lat;
            }
            
            if (lon > maxLongitude) {
                maxLongitude = lon;
            }
            
            if (lon < minLongitude) {
                minLongitude = lon;
            }
            
            anAnnotation = [Annotation annotationWithCoordinate:jhLocation.coordinate];
            anAnnotation.title    = [obj valueForKey:@"turnType"];
            anAnnotation.subtitle = @"";
            anAnnotation.pinId = pinId;
            anAnnotation.objectType = @"Turn";

        }
        ++pinId;
        [self.mapView addAnnotation:anAnnotation];
    }
    
    NSMutableDictionary *latLonInfo = [NSMutableDictionary dictionary];
    [latLonInfo setObject:[NSNumber numberWithDouble:minLatitude] forKey:LAT_MIN];
    [latLonInfo setObject:[NSNumber numberWithDouble:minLongitude] forKey:LON_MIN];
    [latLonInfo setObject:[NSNumber numberWithDouble:maxLatitude] forKey:LAT_MAX];
    [latLonInfo setObject:[NSNumber numberWithDouble:maxLongitude] forKey:LON_MAX];

    [self.mapView centerMapForInfo:latLonInfo];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    self.mapView         = nil;
    self.anAnnotation   = nil;
    self.locationManager = nil;
}

#pragma mark Actions

- (IBAction)mapSatelliteSegmentControlTapped:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}


#pragma mark MapView delegate/datasourec methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKAnnotationView *view = nil; // return nil for the current user location
    
    Annotation *annotationTmp = (Annotation*)annotation;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        NSLog(@"");
    }
    
    BOOL usePinAnnotation = YES;

    if (annotation == mapView.userLocation) {
        NSLog(@"");
        UIImage *image = [UIImage imageNamed:self.currentLocationImageName];
        if (nil == view) {
            view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
        }
        [view setImage:image];
        return view;
    } else if (annotation != mapView.userLocation) {
        

        if (usePinAnnotation) {
            view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
            
            if (nil == view) {
                view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
                view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            }
        } else {
            view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
            
            if (nil == view) {
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
                view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            }
        }

        if ([annotationTmp.objectType isEqualToString:@"Turn"]) {
            NSString *imageName = nil;
            
            if ([annotation.title isEqualToString:@"left turn ok"]) {
                imageName = @"left-ok-64x64";
            } else if ([annotation.title isEqualToString:@"left turn short"]) {
                imageName = @"left-short-64x64";
            } else if ([annotation.title isEqualToString:@"left turn wide"]) {
                imageName = @"left-wide-64x64";
            } else if ([annotation.title isEqualToString:@"right turn short"]) {
                imageName = @"right-short-64x64";
            } else if ([annotation.title isEqualToString:@"right turn wide"]) {
                imageName = @"right-wide-64x64";
            } else if ([annotation.title isEqualToString:@"right turn ok"]) {
                imageName = @"right-ok-64x64";
            }
  
            CGSize size = CGSizeMake(30, 30);
            UIImage *image = [UIImage imageNamed:imageName];
            image = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];

            [view setImage:image];
        } else if ([annotationTmp.objectType isEqualToString:@"User"]) {
            [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorPurple];
            [view setImage:[UIImage imageNamed:@"marker_purple"]];
        } else {
            [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorPurple];
        }
        
        [view setCanShowCallout:YES];
        if ([view isKindOfClass:[MKPinAnnotationView class]]) {
            [(MKPinAnnotationView *)view setAnimatesDrop:YES];
        }
    } else {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:mapView.userLocation.coordinate.latitude
                                                          longitude:mapView.userLocation.coordinate.longitude];
        [self setCurrentLocation:location];
    }
    return view;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

}

#pragma mark -
#pragma mark CoreLocation Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"lat/long: %f. %f", [newLocation coordinate].latitude, [newLocation coordinate].longitude);
    
    CLLocationDegrees lat = newLocation.coordinate.latitude;
    CLLocationDegrees lon = newLocation.coordinate.longitude;
    
    self.latitude  = [[NSNumber numberWithDouble:lat] stringValue];
    self.longitude = [[NSNumber numberWithDouble:lon] stringValue];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
	NSLog(@"Error: %@", [error description]);
}

#pragma mark -
#pragma mark RCODataViewController

- (Aggregate *) aggregate
{
    return nil;
}

- (void) setObjectValue: (NSObject *) theValue forKey: (NSString *) theKey;
{
    
}

- (void) objectDownloadComplete: (NSString *) objectId fromAggregate: (Aggregate *) fromAggregate {
    
}

- (void) contentDownloadComplete: (NSString *) objectId fromAggregate: (Aggregate *) aggregate
 {
}

- (void) setMapToLat: (double) toLatitude andLon: (double) toLongitude withTitle: (NSString *) titleText andDetail: (NSString *) detailText
{
    CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:toLatitude longitude:toLongitude];
    
    self.anAnnotation = [Annotation annotationWithCoordinate:currentLocation.coordinate];
    self.anAnnotation.title    = titleText;
    self.anAnnotation.subtitle = detailText;
    
    
    if (nil != self.anAnnotation) {
        
        [self.mapView addAnnotation:self.anAnnotation];
        
        self.anAnnotation = nil;
    }
    
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    
    region.center = currentLocation.coordinate;
    
    region.span.longitudeDelta = 0.05f;
    region.span.latitudeDelta  = 0.05f;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
}

- (void)openCallout:(id <MKAnnotation>)annotation {
    
    CLLocationDistance distance = 100;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance( annotation.coordinate, distance, distance);
    [self.mapView setRegion:region animated:YES];

    [self.mapView deselectAnnotation:annotation
                               animated:NO];
    [self.mapView selectAnnotation:annotation
                             animated:NO];
}


- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    NSLog(@"");

}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView  {
    NSLog(@"");

}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation  {
    NSLog(@"");

}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error  {
    NSLog(@"");

}


#pragma mark AddObjec delegate

-(void)didCancelObject:(RCOObject*)object {
    // this is the GMapDirectionsViewController add delegate
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didAddObject:(NSObject *)objParam forKey:(NSString *)key {
}

#pragma mark Email Methods

-(void)showEmailModalView {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Turns", nil), [self getEmailSubject]]];
    
    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat:NSLocalizedString(@"<h3> Attached is the Turns </h3>  <br>", nil)];
    
    [picker setMessageBody:emailBody isHTML:YES];
    
    picker.navigationBar.barStyle = UIBarStyleBlack;
    NSString *path = [self getFilePathToSave];
    
    NSData *fileContent = [self makePDFfromView:self.mapView];
    
    BOOL res = [fileContent writeToFile:path atomically:YES];
    if (res) {
        NSLog(@"PDF sucessfully saved!");
    }
    
    [picker addAttachmentData:fileContent
                     mimeType:@"application/pdf"
                     fileName:path];
    
    [self presentViewController:picker
                       animated:YES
                     completion:nil];
}

-(NSString*)getEmailSubject {
    return self.emailSubject;
}

-(NSString*)getFilePathToSave {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *layOutPath=[NSString stringWithFormat:@"%@/Turns",[paths objectAtIndex:0]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:layOutPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:layOutPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [layOutPath stringByAppendingPathComponent:@"Turns.pdf"];
}

-(NSData*)makePDFfromView:(UIView*)view
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    
    return pdfData;
}


@end
