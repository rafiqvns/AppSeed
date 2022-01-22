//
//  CSDAccidentVehicleAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 5/22/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDAccidentVehicleAggregate.h"
#import "AccidentVehicle+CoreDataClass.h"
#import "DataRepository.h"


@implementation CSDAccidentVehicleAggregate

- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"AccidentVehicle";
        self.rcoObjectClass = @"AccidentVehicle";
        self.rcoRecordType = @"Vehicle involved in Accident";
        self.aggregateRight = kTrainingAccident;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    AccidentVehicle *op = (AccidentVehicle *) object;
    
    if( [fieldName isEqualToString:@"DateTime"] ) {
        op.dateTime = [self rcoStringToDateTime:fieldValue];
    } else if( [fieldName isEqualToString:@"Driver First Name"] ) {
        op.firstName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver Last Name"] ) {
        op.lastName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License Number"] ) {
        op.driverLicenseNumber = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver Address"] ) {
        op.address1 = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver City"] ) {
        op.city = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License State"] ) {
        op.driverLicenseState = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver Zipcode"] ) {
        op.zip = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"License Class"] ) {
        op.driverLicenseClass = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver Home Phone Number"] ) {
        op.homePhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver Work Phone Number"] ) {
        op.workPhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver Mobile Phone Number"] ) {
        op.mobilePhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Vehicle Type"] ) {
        op.vehicleType = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Vehicle Make"] ) {
        op.vehicleMake = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Vehicle Model"] ) {
        op.vehicleModel = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Vehicle Year"] ) {
        op.vehicleYear = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Combination Vehicle"] ) {
        op.combinationVehicle = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Description of damages"] ) {
        op.descriptionOfDamage = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Description of damages"] ) {
        op.descriptionOfDamage = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"License Plate Number"] ) {
        op.number = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance Company"] ) {
        op.insuranceCompany = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance Agent"] ) {
        op.insuranceAgent = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance Phone Number"] ) {
        op.insurancePhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance Policy Number"] ) {
        op.insurancePolicyNumber = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance Expiration Date"] ) {
        op.insuranceExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance Address"] ) {
        op.insuranceAddress = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance City"] ) {
        op.insuranceCity = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance State"] ) {
        op.insuranceState = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insurance Zipcode"] ) {
        op.insuranceZipcode = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Insured by driver"] ) {
        op.insuredByDriver = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration Number"] ) {
        op.registrationNumber = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration Expiration Date"] ) {
        op.registrationExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration Name"] ) {
        op.registrationName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration Address"] ) {
        op.registrationAddress = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration City"] ) {
        op.registrationCity = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration State"] ) {
        op.registrationState = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration Zipcode"] ) {
        op.registrationZipcode = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Employed by"] ) {
        op.employedBy = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Assigned location"] ) {
        op.assignedLocation = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Company Address"] ) {
        op.companyAddress = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Company City"] ) {
        op.companyCity = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Company State"] ) {
        op.companyState = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Company Zipcode"] ) {
        op.companyZipcode = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Company Phone Number"] ) {
        op.companyPhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Notes"] ) {
        op.notes = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Date of Birth"] ) {
        op.dateofBirth = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"VIN"] ) {
        op.vin = fieldValue;
        [op addSearchString:fieldValue];
    }

}

- (id) createNewRecord: (RCOObject *) obj {
    AccidentVehicle *form = (AccidentVehicle*)obj;
    
    if (!obj) {
        return nil;
    }
    
    NSString *formCSVFormat = [form CSVFormat];
    
    NSData *data = [formCSVFormat dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:A_S
                                                  withMsg:V_I_A
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}
- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: V_I_A]) {
        NSString *rcoObjectId = [self parseSetRequest:request];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        if (rcoObjectId) {
            [result setObject:rcoObjectId forKey:@"objId"];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:rcoObjectId];
    } else {
        return [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: V_I_A]) {
        NSLog(@"");
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

@end
