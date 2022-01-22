//
//  DriverMedicalForm+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 3/10/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverMedicalForm+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"
#import "Aggregate.h"

@implementation DriverMedicalForm
-(NSString*)CSVFormat {
    NSMutableArray *result = [NSMutableArray array];

    if ([self existsOnServer]) {
        [result addObject:@"U"];
        [result addObject:@"H"];
        [result addObject:self.rcoObjectId];
        [result addObject:self.rcoObjectType];
    } else {
        [result addObject:@"O"];
        [result addObject:@"H"];
        [result addObject:@""];
        [result addObject:@""];
    }

    //5 MobileRecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoMobileRecordId]];

    //6 functionalGroupName
    [result addObject:@""];

    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];

    // 7 organisation name
    [result addObject:organizationName];

    //8 organisation number
    [result addObject:organizationId];

    //9 Date
    if (self.dateTime) {
        [result addObject:[self rcoDateTimeString:self.dateTime]];
    } else {
        [result addObject:@""];
    }

    //10 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.carrierName]];

    //11
    [result addObject:[self getUploadCodingFieldFomValue:self.doctorsName]];

    //12
    [result addObject:[self getUploadCodingFieldFomValue:self.sPEApplicantName]];

    //13
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeStraightTruck]];

    //14
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeTruckTrailerover10klbs]];

    //15
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeTrucklessthan10klbsandhazardousmaterials]];

    //16
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeTruckover10klbs]];

    //17
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeMotorHome10klbs]];

    //18
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeTractorTrailer]];

    //19
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypePassengerVehicle]];

    //20
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypePassengerSeatingCapacity]];

    //21
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypePassengerMotorCoach]];

    //22
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypePassengerBus]];

    //23
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypePassengerVan]];

    //24
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeshortrelaydrives]];

    //25
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypelongrelaydrives]];

    //26
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypestraightthrough]];

    //27
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypenightsawayfromhome]];

    //28
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypesleeperteamdrives]];

    //29
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypenumberofnightsawayfromhome]];

    //30
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeclimbinginandoutoftruck]];

    //31
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorsabruptduty]];

    //32
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorssleepdeprivation]];

    //33
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorsunbalancedwork]];

    //34
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorstemperature]];

    //35
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorslongtrips]];

    //36
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorsshortnotice]];

    //37
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorstightdelivery]];

    //38
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorsdelayenroute]];

    //39
    [result addObject:[self getUploadCodingFieldFomValue:self.environmentalFactorsothers]];

    //40
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandGearShifting]];

    //41
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandNumberspeedtransmission]];

    //42
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandsemiautomatic]];

    //43
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandfullyautomatic]];

    //44
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandsteeringwheelcontrol]];

    //45
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandbrakeacceleratoroperation]];

    //46
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandvarioustasks]];

    //47
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandbackingandparking]];

    //48
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandvehicleinspections]];

    //49
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandcargohandling]];

    //50
////    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandcoupling]];
    [result addObject:@""];
    
    //51
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandchangingtires]];

    //52
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandvehiclemodifications]];

    //53
    [result addObject:[self getUploadCodingFieldFomValue:self.physicalDemandvehiclemodnotes]];

    //54
    [result addObject:[self getUploadCodingFieldFomValue:self.muscleStrengthyes]];

    //55
    [result addObject:[self getUploadCodingFieldFomValue:self.muscleStrengthno]];

    //56
    [result addObject:[self getUploadCodingFieldFomValue:self.muscleStrengthrightupperextremity]];

    //57
    [result addObject:[self getUploadCodingFieldFomValue:self.muscleStrengthleftupperextremity]];

    //58
    [result addObject:[self getUploadCodingFieldFomValue:self.muscleStrengthrightlowerextremity]];

    //59
    [result addObject:[self getUploadCodingFieldFomValue:self.muscleStrengthleftlowerextremity]];

    //60
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilityyes]];

    //61
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilityno]];

    //62
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilityrightupperextremity]];

    //63
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilityleftupperextremity]];

    //64
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilityrightlowerextremity]];

    //65
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilityleftlowerextremity]];

    //66
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilitytrunk]];

    //67
    [result addObject:[self getUploadCodingFieldFomValue:self.stabilityyes]];

    //68
    [result addObject:[self getUploadCodingFieldFomValue:self.stabilityno]];

    //69
    [result addObject:[self getUploadCodingFieldFomValue:self.stabilityrightupperextremity]];

    //70
    [result addObject:[self getUploadCodingFieldFomValue:self.stabilityleftupperextremity]];

    //71
    [result addObject:[self getUploadCodingFieldFomValue:self.stabilityrightlowerextremity]];

    //72
    [result addObject:[self getUploadCodingFieldFomValue:self.stabilityleftlowerextremity]];

    //73
    [result addObject:[self getUploadCodingFieldFomValue:self.stabilitytrunk]];

    //74
    [result addObject:[self getUploadCodingFieldFomValue:self.impairmenthand]];

    //75
    [result addObject:[self getUploadCodingFieldFomValue:self.impairmentupperlimb]];

    //76
    [result addObject:[self getUploadCodingFieldFomValue:self.amputationhand]];

    //77
    [result addObject:[self getUploadCodingFieldFomValue:self.amputationpartial]];

    //78
    [result addObject:[self getUploadCodingFieldFomValue:self.amputationfull]];

    //79
    [result addObject:[self getUploadCodingFieldFomValue:self.amputationupperlimb]];

    //80
    [result addObject:[self getUploadCodingFieldFomValue:self.powergriprightyes]];

    //81
    [result addObject:[self getUploadCodingFieldFomValue:self.powergriprightno]];

    //82
    [result addObject:[self getUploadCodingFieldFomValue:self.powergripleftyes]];

    //83
    [result addObject:[self getUploadCodingFieldFomValue:self.powergripleftno]];

    //84
    [result addObject:[self getUploadCodingFieldFomValue:self.surgicalreconstructionyes]];

    //85
    [result addObject:[self getUploadCodingFieldFomValue:self.surgicalreconstructionno]];

    //86
    [result addObject:[self getUploadCodingFieldFomValue:self.hasupperimpairment]];

    //87
    [result addObject:[self getUploadCodingFieldFomValue:self.haslowerlimbimpairment]];

    //88
    [result addObject:[self getUploadCodingFieldFomValue:self.hasrightimpairment]];

    //89
    [result addObject:[self getUploadCodingFieldFomValue:self.hasleftimpairment]];

    //90
    [result addObject:[self getUploadCodingFieldFomValue:self.hasupperamputation]];

    //91
    [result addObject:[self getUploadCodingFieldFomValue:self.haslowerlimbamputation]];

    //92
    [result addObject:[self getUploadCodingFieldFomValue:self.hasrightamputation]];

    //93
    [result addObject:[self getUploadCodingFieldFomValue:self.hasleftamputation]];

    //94
    [result addObject:[self getUploadCodingFieldFomValue:self.appropriateprosthesisyes]];

    //95
    [result addObject:[self getUploadCodingFieldFomValue:self.appropriateprosthesisno]];

    //96
    [result addObject:[self getUploadCodingFieldFomValue:self.appropriateterminaldeviceyes]];

    //97
    [result addObject:[self getUploadCodingFieldFomValue:self.appropriateterminaldeviceno]];

    //98
    [result addObject:[self getUploadCodingFieldFomValue:self.prosthesisfitsyes]];

    //99
    [result addObject:[self getUploadCodingFieldFomValue:self.prosthesisfitsno]];

    //100
    [result addObject:[self getUploadCodingFieldFomValue:self.useprostheticproficientlyyes]];

    //101
    [result addObject:[self getUploadCodingFieldFomValue:self.useprostheticproficientlyno]];

    //102
    [result addObject:[self getUploadCodingFieldFomValue:self.abilitytopowergraspno]];

    //103
    [result addObject:[self getUploadCodingFieldFomValue:self.abilitytopowergraspyes]];

    //104
    [result addObject:[self getUploadCodingFieldFomValue:self.prostheticrecommendations]];

    //105
    [result addObject:[self getUploadCodingFieldFomValue:self.prostheticclinicaldescription]];

    //106
    [result addObject:[self getUploadCodingFieldFomValue:self.medicalconditionsinterferewithtasksno]];

    //107
    [result addObject:[self getUploadCodingFieldFomValue:self.medicalconditionsinterferewithtasksyes]];

    //108
    [result addObject:[self getUploadCodingFieldFomValue:self.medicalconditionsinterferewithtasksexplanation]];

    //109
    [result addObject:[self getUploadCodingFieldFomValue:self.medicalfindingsandevaluation]];

    //110
    [result addObject:[self getUploadCodingFieldFomValue:self.physicianlastname]];

    //111
    [result addObject:[self getUploadCodingFieldFomValue:self.physicianfirstname]];

    //112
    [result addObject:[self getUploadCodingFieldFomValue:self.physicianmiddlename]];

    //113
    [result addObject:[self getUploadCodingFieldFomValue:self.physicianaddress]];

    //114
    [result addObject:[self getUploadCodingFieldFomValue:self.physiciancity]];

    //115
    [result addObject:[self getUploadCodingFieldFomValue:self.physicianstate]];

    //116
    [result addObject:[self getUploadCodingFieldFomValue:self.physicianzipcode]];

    //117
    [result addObject:[self getUploadCodingFieldFomValue:self.physiciantelephonenumber]];

    //118
    [result addObject:[self getUploadCodingFieldFomValue:self.physicianalternatenumber]];

    //119
    [result addObject:[self getUploadCodingFieldFomValue:self.physiatrist]];

    //120
    [result addObject:[self getUploadCodingFieldFomValue:self.orthopedicsurgeon]];

    //121
    [result addObject:[self getUploadCodingFieldFomValue:self.boardCertifiedyes]];

    //122
    [result addObject:[self getUploadCodingFieldFomValue:self.boardCertifiedno]];

    //123
    [result addObject:[self getUploadCodingFieldFomValue:self.boardEligibleyes]];

    //124
    [result addObject:[self getUploadCodingFieldFomValue:self.boardEligibleno]];

    //125
    [result addObject:[self getUploadCodingFieldFomValue:self.physiciandate]];

    //126
    [result addObject:[self getUploadCodingFieldFomValue:self.firstName]];

    //127
    [result addObject:[self getUploadCodingFieldFomValue:self.lastName]];

    //128
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilePhone]];


    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
        
    return res;
}


@end
