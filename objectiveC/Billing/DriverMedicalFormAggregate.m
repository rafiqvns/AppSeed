//
//  DriverMedicalFormAggregate.m
//  CSD
//
//  Created by .D. .D. on 3/12/20.
//  Copyright © 2020 RCO. All rights reserved.
//

#import "DriverMedicalFormAggregate.h"
#import "DriverMedicalForm+CoreDataClass.h"
#import "DataRepository.h"

@implementation DriverMedicalFormAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"DriverMedicalForm";
        self.rcoObjectClass = @"DriverMedicalForm";
        self.rcoRecordType = @"Driver Medical Form";
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    DriverMedicalForm *form = (DriverMedicalForm *) object;

    if( [fieldName isEqualToString:@"SPE Applicant Name"] )
    {
        form.sPEApplicantName = fieldValue;
        [form addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Doctors Name"] )
    {
        form.doctorsName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Form Date"] )
    {
        form.dateTime = [self rcoStringToDate:fieldValue];;
    }
    else if( [fieldName isEqualToString:@"Carrier Name"] )
    {
        form.carrierName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Straight Truck"] )
    {
        form.vehicleTypeStraightTruck = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Truck Trailer over 10k lbs"] )
    {
        form.vehicleTypeTruckTrailerover10klbs = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Truck less than 10k lbs and hazardous materials"] )
    {
        form.vehicleTypeTrucklessthan10klbsandhazardousmaterials = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Truck over 10k lbs"] )
    {
        form.vehicleTypeTruckTrailerover10klbs = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Motor Home 10k lbs"] )
    {
        form.vehicleTypeMotorHome10klbs = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Tractor Trailer"] )
    {
        form.vehicleTypeTractorTrailer = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Passenger Vehicle"] )
    {
        form.vehicleTypePassengerVehicle = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Passenger Vehicle"] )
    {
        form.vehicleTypePassengerVehicle = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Passenger Seating Capacity"] )
    {
        form.vehicleTypePassengerSeatingCapacity = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Passenger Motor Coach"] )
    {
        form.vehicleTypePassengerMotorCoach = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Passenger Bus"] )
    {
        form.vehicleTypePassengerBus = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Passenger Van"] )
    {
        form.vehicleTypePassengerVan = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type short relay drives"] )
    {
        form.vehicleTypeshortrelaydrives = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type long relay drives"] )
    {
        form.vehicleTypelongrelaydrives = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type straight through"] )
    {
        form.vehicleTypestraightthrough = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type nights away from home"] )
    {
        form.vehicleTypenightsawayfromhome = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type sleeper team drives"] )
    {
        form.vehicleTypesleeperteamdrives = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type number of nights away from home"] )
    {
        form.vehicleTypenumberofnightsawayfromhome = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type climbing in and out of truck"] )
    {
        form.vehicleTypeclimbinginandoutoftruck = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors abrupt duty"] )
    {
        form.environmentalFactorsabruptduty = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors sleep deprivation"] )
    {
        form.environmentalFactorssleepdeprivation = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors unbalanced work"] )
    {
        form.environmentalFactorsunbalancedwork = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors temperature"] )
    {
        form.environmentalFactorstemperature = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors long trips"] )
    {
        form.environmentalFactorslongtrips = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors short notice"] )
    {
        form.environmentalFactorsshortnotice = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors tight delivery"] )
    {
        form.environmentalFactorstightdelivery = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Environmental Factors delay en route"] )
    {
        form.environmentalFactorsdelayenroute = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand Gear Shifting"] )
    {
        form.physicalDemandGearShifting = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand Number speed transmission"] )
    {
        form.physicalDemandNumberspeedtransmission = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand semi-automatic"] )
    {
        form.physicalDemandsemiautomatic = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand fully automatic"] )
    {
        form.physicalDemandfullyautomatic = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand steering wheel control"] )
    {
        form.physicalDemandsteeringwheelcontrol = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand brake accelerator operation"] )
    {
        form.physicalDemandbrakeacceleratoroperation = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand various tasks"] )
    {
        form.physicalDemandvarioustasks = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand backing and parking"] )
    {
        form.physicalDemandbackingandparking = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand vehicle inspections"] )
    {
        form.physicalDemandvehicleinspections = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand cargo handling"] )
    {
        form.physicalDemandcargohandling = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand coupling"] )
    {
        //form.physicalDemandcou = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand changing tires"] )
    {
        form.physicalDemandchangingtires = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand vehicle modifications"] )
    {
        form.physicalDemandvehiclemodifications = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Physical Demand vehicle mod notes"] )
    {
        form.physicalDemandvehiclemodnotes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Muscle Strength yes"] )
    {
        form.muscleStrengthyes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Muscle Strength no"] )
    {
        form.muscleStrengthno = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Muscle Strength right upper extremity"] )
    {
        form.muscleStrengthrightupperextremity = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Muscle Strength right lower extremity"] )
    {
        form.muscleStrengthrightlowerextremity = fieldValue;
    }


}

- (id) createNewRecord: (RCOObject *) obj {
    DriverMedicalForm *form = (DriverMedicalForm*)obj;
    
    if (!obj) {
        return nil;
    }
    
    NSString *formCSVFormat = [form CSVFormat];
        
    NSData *data = [formCSVFormat dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:F_S
                                                  withMsg:FMD
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}
- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: FMD]) {
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
    
    if ([msg isEqualToString: FMD]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

@end
