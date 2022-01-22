//
//  DriverMedicalForm+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/10/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverMedicalForm+CoreDataProperties.h"

@implementation DriverMedicalForm (CoreDataProperties)

+ (NSFetchRequest<DriverMedicalForm *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverMedicalForm"];
}

@dynamic carrierName;
@dynamic doctorsName;
@dynamic sPEApplicantName;
@dynamic vehicleTypeStraightTruck;
@dynamic vehicleTypeTruckTrailerover10klbs;
@dynamic vehicleTypeTrucklessthan10klbsandhazardousmaterials;
@dynamic vehicleTypeTruckover10klbs;
@dynamic vehicleTypeMotorHome10klbs;
@dynamic vehicleTypeTractorTrailer;
@dynamic vehicleTypePassengerVehicle;
@dynamic vehicleTypePassengerSeatingCapacity;
@dynamic vehicleTypePassengerMotorCoach;
@dynamic vehicleTypePassengerBus;
@dynamic vehicleTypePassengerVan;
@dynamic vehicleTypeshortrelaydrives;
@dynamic vehicleTypelongrelaydrives;
@dynamic vehicleTypestraightthrough;
@dynamic vehicleTypenightsawayfromhome;
@dynamic vehicleTypesleeperteamdrives;
@dynamic vehicleTypenumberofnightsawayfromhome;
@dynamic vehicleTypeclimbinginandoutoftruck;
@dynamic environmentalFactorsabruptduty;
@dynamic environmentalFactorssleepdeprivation;
@dynamic environmentalFactorsunbalancedwork;
@dynamic environmentalFactorstemperature;
@dynamic environmentalFactorslongtrips;
@dynamic environmentalFactorsshortnotice;
@dynamic environmentalFactorstightdelivery;
@dynamic environmentalFactorsdelayenroute;
@dynamic environmentalFactorsothers;
@dynamic physicalDemandGearShifting;
@dynamic physicalDemandNumberspeedtransmission;
@dynamic physicalDemandsemiautomatic;
@dynamic physicalDemandfullyautomatic;
@dynamic physicalDemandsteeringwheelcontrol;
@dynamic physicalDemandbrakeacceleratoroperation;
@dynamic physicalDemandvarioustasks;
@dynamic physicalDemandbackingandparking;
@dynamic physicalDemandvehicleinspections;
@dynamic physicalDemandcargohandling;
@dynamic physicalDemandchangingtires;
@dynamic physicalDemandvehiclemodifications;
@dynamic physicalDemandvehiclemodnotes;
@dynamic muscleStrengthyes;
@dynamic muscleStrengthno;
@dynamic muscleStrengthrightupperextremity;
@dynamic muscleStrengthleftupperextremity;
@dynamic muscleStrengthrightlowerextremity;
@dynamic muscleStrengthleftlowerextremity;
@dynamic mobilityyes;
@dynamic mobilityno;
@dynamic mobilityrightupperextremity;
@dynamic mobilityleftupperextremity;
@dynamic mobilityrightlowerextremity;
@dynamic mobilityleftlowerextremity;
@dynamic mobilitytrunk;
@dynamic stabilityyes;
@dynamic stabilityno;
@dynamic stabilityrightupperextremity;
@dynamic stabilityleftupperextremity;
@dynamic stabilityrightlowerextremity;
@dynamic stabilityleftlowerextremity;
@dynamic stabilitytrunk;
@dynamic impairmenthand;
@dynamic impairmentupperlimb;
@dynamic amputationhand;
@dynamic amputationpartial;
@dynamic amputationfull;
@dynamic amputationupperlimb;
@dynamic powergriprightyes;
@dynamic powergriprightno;
@dynamic powergripleftyes;
@dynamic powergripleftno;
@dynamic surgicalreconstructionyes;
@dynamic surgicalreconstructionno;
@dynamic hasupperimpairment;
@dynamic haslowerlimbimpairment;
@dynamic hasrightimpairment;
@dynamic hasleftimpairment;
@dynamic hasupperamputation;
@dynamic haslowerlimbamputation;
@dynamic hasrightamputation;
@dynamic hasleftamputation;
@dynamic appropriateprosthesisyes;
@dynamic appropriateprosthesisno;
@dynamic appropriateterminaldeviceyes;
@dynamic appropriateterminaldeviceno;
@dynamic prosthesisfitsyes;
@dynamic prosthesisfitsno;
@dynamic useprostheticproficientlyyes;
@dynamic useprostheticproficientlyno;
@dynamic abilitytopowergraspno;
@dynamic abilitytopowergraspyes;
@dynamic prostheticrecommendations;
@dynamic prostheticclinicaldescription;
@dynamic medicalconditionsinterferewithtasksno;
@dynamic medicalconditionsinterferewithtasksyes;
@dynamic medicalconditionsinterferewithtasksexplanation;
@dynamic medicalfindingsandevaluation;
@dynamic physicianlastname;
@dynamic physicianfirstname;
@dynamic physicianmiddlename;
@dynamic physicianaddress;
@dynamic physiciancity;
@dynamic physicianstate;
@dynamic physicianzipcode;
@dynamic physiciantelephonenumber;
@dynamic physicianalternatenumber;
@dynamic physiatrist;
@dynamic orthopedicsurgeon;
@dynamic boardCertifiedyes;
@dynamic boardCertifiedno;
@dynamic boardEligibleyes;
@dynamic boardEligibleno;
@dynamic physiciandate;

@end
