//
//  CSDTurnsViewController.m
//  CSD
//
//  Created by .D. .D. on 6/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDTurnsViewController.h"
#import "UIImage+Resize.h"
#import "Annotation.h"
#import "DataRepository.h"
#import "MKMapView+Utilities.h"
#import "User_Imp.h"
#import "DriverTurnsAggregate.h"
#import "DriverTurn+CoreDataClass.h"
#import "Settings.h"
#import "NSDate+Misc.h"


@interface CSDTurnsViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL shouldMakeScreenShoot;
@property (nonatomic, strong) NSMutableDictionary *turnsInfo;
@property (nonatomic, strong) NSString *masterMobileRecordId;

@end

@implementation CSDTurnsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.masterMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(closeButtonPressed:)];
    self.navigationItem.leftBarButtonItem = closeBtn;

    UIBarButtonItem *emailBtn = [[UIBarButtonItem alloc] initWithTitle:@"Email"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(emailButtonPressed:)];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(actionButtonPressed:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:actionButton, emailBtn, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:actionButton, nil];

    self.title = @"Turns";
    self.shouldMakeScreenShoot = YES;
    [self loadItems];
    if (DEVICE_IS_IPHONE) {
        NSMutableDictionary *attribute = [NSMutableDictionary dictionary];
        [attribute setObject:[UIFont systemFontOfSize:8.5] forKey:NSFontAttributeName];
        [attribute setObject:[UIFont systemFontOfSize:6] forKey:NSFontAttributeName];
        [self.segController setTitleTextAttributes:attribute forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"DriverTurn"] registerForCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"DriverTurn"] unRegisterForCallback:self];
}

-(IBAction)emailButtonPressed:(id)sender {

}

-(IBAction)actionButtonPressed:(id)sender {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sync Turns?", nil)
                                                  message:nil
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          DriverTurnsAggregate *agg = (DriverTurnsAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"DriverTurn"];
                                                          //16.12.2019 we should use the "Test Info record" [agg getTurnsForHeaderWithMobileRecordId:self.testMobileRecordId];
                                                          [agg getTurnsForHeaderWithMobileRecordId:self.masterMobileRecordId];

    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [al addAction:yesAction];
    [al addAction:cancelAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(IBAction)closeButtonPressed:(id)sender {
    [self makeScreenShoot];
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)turnsButtonPressed:(UIButton*)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:[NSNumber numberWithInt:sender.tag] forKey:self.addDelegateKey];
    }    
}

-(IBAction)turnsChanged:(UISegmentedControl*)sender {
    
    NSInteger index = 0;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        index = ((UISegmentedControl*)sender).selectedSegmentIndex;
        NSLog(@"option = %d", (int)((UISegmentedControl*)sender).selectedSegmentIndex);
    } else if ([sender isKindOfClass:[NSNumber class]]){
        index = [(NSNumber*)sender integerValue];
    }
    
    
    NSArray *turns = [NSArray arrayWithObjects:DrivingTurnLeftWide, DrivingTurnLeftOk, DrivingTurnLeftShort, DrivingTurnRightWide, DrivingTurnRightOk, DrivingTurnRightShort,nil];
    //NSArray *turns2 = [NSArray arrayWithObjects:DrivingTurnLeftWide1, DrivingTurnLeftShort1, DrivingTurnLeftOk1,  DrivingTurnRightWide1, DrivingTurnRightShort1, DrivingTurnRightOk1, nil];

    NSString *turn = [turns objectAtIndex:index];
    //NSString *turn = [turns2 objectAtIndex:index];

    //DriverTurn
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"DriverTurn"];
    DriverTurn *obj = (DriverTurn*)[agg createNewObject];
    
    /*
     30.07.2019 employee number!
     obj.instructorId = self.instructor.rcoObjectId;
     */
    obj.instructorId = self.instructor.employeeNumber;
    obj.instructorLastName = self.instructor.surname;
    obj.instructorFirstName = self.instructor.firstname;
    
    /*
     30.07.2019 employee Id or rcooBjectId?
     obj.employeeId = self.student.rcoObjectId;
     */
    obj.employeeId = self.student.employeeNumber;
    obj.studentLastName = self.student.surname;
    obj.studentFirstName = self.student.firstname;
    
    obj.turnType = turn;
    obj.company = [self.values objectForKey:@"company"];
    obj.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
    obj.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
    obj.dateTime = [NSDate date];
    obj.rcoObjectParentId = self.testMobileRecordId;
    obj.masterMobileRecordId = self.masterMobileRecordId;

    [agg createNewRecord:obj];
    
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        [(UISegmentedControl*)sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
    NSString *msg = [NSString stringWithFormat:@"%@ saved!", [turn capitalizedString]];
    [self showSimpleMessage:msg];
    self.shouldMakeScreenShoot = YES;
    [self loadItems];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)loadItems {
    double minLatitude = 9999;
    double maxLatitude = -9999;
    double minLongitude = 9999;
    double maxLongitude = -9999;
    
    DriverTurnsAggregate *agg = (DriverTurnsAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"DriverTurn"];
    //16.12.2019 NSArray *turns = [agg getTurnsForTest:self.testMobileRecordId];
    NSArray *turns = [agg getTurnsForTest:self.masterMobileRecordId];
    
    // 13.01.2020 force a redraw
    NSArray *annotations = self.mapView.annotations;
    [self.mapView removeAnnotations:annotations];

    self.items = [NSMutableArray arrayWithArray:turns];
    
    if (!self.items.count) {
        
        [self setMapToLat:[[[DataRepository sharedInstance] getCurrentLatitude] doubleValue]
                   andLon:[[[DataRepository sharedInstance] getCurrentLongitude] doubleValue]
                withTitle:nil
                andDetail:nil];
        return;
    }
    
    
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
    
    self.turnsInfo = [NSMutableDictionary dictionary];
    
    for (DriverTurn *obj in self.items) {
        
        NSInteger count = [[self.turnsInfo objectForKey:obj.turnType] integerValue];
        count += 1;
        [self.turnsInfo setObject:[NSNumber numberWithInteger:count] forKey:obj.turnType];
        
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
    
    [self.mapView setNeedsDisplay];
    [self.mapView centerMapForInfo:latLonInfo];
    [self configureBottomToolbar];
}

-(void)configureBottomToolbar {
    NSArray *turns = [NSArray arrayWithObjects:DrivingTurnLeftWide, DrivingTurnLeftOk, DrivingTurnLeftShort, DrivingTurnRightWide, DrivingTurnRightOk, DrivingTurnRightShort,nil];
    NSMutableArray *turnsFormatted = [NSMutableArray array];
    for (NSString *turnType in turns) {
        NSNumber *count = [self.turnsInfo objectForKey:turnType];
        NSString *turnFormatted = [turnType stringByReplacingOccurrencesOfString:@"turn " withString:@""];
        if (![count integerValue]) {
            [turnsFormatted addObject:[turnFormatted capitalizedString]];
        } else {
            [turnsFormatted addObject:[NSString stringWithFormat:@"%@(%d)", [turnFormatted capitalizedString], (int)[count integerValue]]];
        }
    }
    for (NSInteger i = 0; i < turnsFormatted.count; i++) {
        NSString *title = [turnsFormatted objectAtIndex:i];
        [self.segController setTitle:title forSegmentAtIndex:i];
    }
}

-(void)makeScreenShoot {
    
    [self.segController setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self makeImagefromView:self.mapView];
    
    return;
    NSString *path = [self getFilePathToSave];
    NSData *fileContent = [self makePDFfromView:self.mapView];
    BOOL res = [fileContent writeToFile:path atomically:YES];
    self.shouldMakeScreenShoot = NO;
    NSLog(@"Path = %@", path);
}

- (void) setMapToLat: (double) toLatitude andLon: (double) toLongitude withTitle: (NSString *) titleText andDetail: (NSString *) detailText
{
    CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:toLatitude longitude:toLongitude];
    
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    
    region.center = currentLocation.coordinate;
    
    region.span.longitudeDelta = 0.05f;
    region.span.latitudeDelta  = 0.05f;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
}


#pragma mark MapView delegate/datasourec methods
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    //[self makeScreenShoot];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    if (fullyRendered && self.shouldMakeScreenShoot) {
        [self makeScreenShoot];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKAnnotationView *view = nil; // return nil for the current user location
    Annotation *annotationTmp = (Annotation*)annotation;
    
    BOOL usePinAnnotation = NO;
    NSString *imageName = nil;
    
    
    if (annotation != mapView.userLocation) {
        
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

- (void)setCurrentLocation:(CLLocation *)location {
    
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    
    region.center = location.coordinate;
    
    region.span.longitudeDelta = 0.05f;
    region.span.latitudeDelta  = 0.05f;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
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

-(NSString*)getDateTimeEscapedFromDate:(NSDate*)dateTime {
    if (!dateTime) {
        return @"";
    }
    NSString *str = [NSDate rcoDateTimeString:dateTime];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    return str;
}

-(NSString*)getEmailSubject {
    return [NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname];;
}

-(NSString*)getFilePathToSave {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *layOutPath=[NSString stringWithFormat:@"%@/Turns",[paths objectAtIndex:0]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:layOutPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:layOutPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [layOutPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Turns_%@_%@.pdf", self.student.rcoRecordId, [self getDateTimeEscapedFromDate:self.testDateTime]]];
}

-(NSString*)getImageFilePathToSave {
    return [DriverTurn imagePathForStudentRecordId:self.student.rcoRecordId andDateTime:self.testDateTime];
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

-(void)makeImagefromView:(UIView*)view {
    
    NSString *path = [self getImageFilePathToSave];
    //UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    CGSize size = self.navigationController.view.frame.size;
    // we need to remove the top part
    size.height -= (44 + 20);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);

    //[view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    CGRect frame = self.navigationController.view.bounds;
    frame.origin.y -= (44 + 20);
    //frame.origin.y = 0;
    frame.size.height -= (44 + 20);
    [self.navigationController.view drawViewHierarchyInRect:frame afterScreenUpdates:NO];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];

    NSLog(@"Pathhhh = %@", path);
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:RD_G_R_U_X_F] ) {
        NSLog(@"");
        NSString *objId = [messageInfo objectForKey:@"objId"];
        if (objId.length) {
            self.shouldMakeScreenShoot = YES;
            [aggregate save];
            [self loadItems];
        }
        NSLog(@"objId = %@", objId);
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
}


@end
