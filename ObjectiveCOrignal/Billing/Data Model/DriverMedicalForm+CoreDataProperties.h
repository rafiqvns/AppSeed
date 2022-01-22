//
//  DriverMedicalForm+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/10/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverMedicalForm+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverMedicalForm (CoreDataProperties)

+ (NSFetchRequest<DriverMedicalForm *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *carrierName;
@property (nullable, nonatomic, copy) NSString *doctorsName;
@property (nullable, nonatomic, copy) NSString *sPEApplicantName;
@property (nullable, nonatomic, copy) NSString *vehicleTypeStraightTruck;
@property (nullable, nonatomic, copy) NSString *vehicleTypeTruckTrailerover10klbs;
@property (nullable, nonatomic, copy) NSString *vehicleTypeTrucklessthan10klbsandhazardousmaterials;
@property (nullable, nonatomic, copy) NSString *vehicleTypeTruckover10klbs;
@property (nullable, nonatomic, copy) NSString *vehicleTypeMotorHome10klbs;
@property (nullable, nonatomic, copy) NSString *vehicleTypeTractorTrailer;
@property (nullable, nonatomic, copy) NSString *vehicleTypePassengerVehicle;
@property (nullable, nonatomic, copy) NSString *vehicleTypePassengerSeatingCapacity;
@property (nullable, nonatomic, copy) NSString *vehicleTypePassengerMotorCoach;
@property (nullable, nonatomic, copy) NSString *vehicleTypePassengerBus;
@property (nullable, nonatomic, copy) NSString *vehicleTypePassengerVan;
@property (nullable, nonatomic, copy) NSString *vehicleTypeshortrelaydrives;
@property (nullable, nonatomic, copy) NSString *vehicleTypelongrelaydrives;
@property (nullable, nonatomic, copy) NSString *vehicleTypestraightthrough;
@property (nullable, nonatomic, copy) NSString *vehicleTypenightsawayfromhome;
@property (nullable, nonatomic, copy) NSString *vehicleTypesleeperteamdrives;
@property (nullable, nonatomic, copy) NSString *vehicleTypenumberofnightsawayfromhome;
@property (nullable, nonatomic, copy) NSString *vehicleTypeclimbinginandoutoftruck;
@property (nullable, nonatomic, copy) NSString *environmentalFactorsabruptduty;
@property (nullable, nonatomic, copy) NSString *environmentalFactorssleepdeprivation;
@property (nullable, nonatomic, copy) NSString *environmentalFactorsunbalancedwork;
@property (nullable, nonatomic, copy) NSString *environmentalFactorstemperature;
@property (nullable, nonatomic, copy) NSString *environmentalFactorslongtrips;
@property (nullable, nonatomic, copy) NSString *environmentalFactorsshortnotice;
@property (nullable, nonatomic, copy) NSString *environmentalFactorstightdelivery;
@property (nullable, nonatomic, copy) NSString *environmentalFactorsdelayenroute;
@property (nullable, nonatomic, copy) NSString *environmentalFactorsothers;
@property (nullable, nonatomic, copy) NSString *physicalDemandGearShifting;
@property (nullable, nonatomic, copy) NSString *physicalDemandNumberspeedtransmission;
@property (nullable, nonatomic, copy) NSString *physicalDemandsemiautomatic;
@property (nullable, nonatomic, copy) NSString *physicalDemandfullyautomatic;
@property (nullable, nonatomic, copy) NSString *physicalDemandsteeringwheelcontrol;
@property (nullable, nonatomic, copy) NSString *physicalDemandbrakeacceleratoroperation;
@property (nullable, nonatomic, copy) NSString *physicalDemandvarioustasks;
@property (nullable, nonatomic, copy) NSString *physicalDemandbackingandparking;
@property (nullable, nonatomic, copy) NSString *physicalDemandvehicleinspections;
@property (nullable, nonatomic, copy) NSString *physicalDemandcargohandling;
@property (nullable, nonatomic, copy) NSString *physicalDemandchangingtires;
@property (nullable, nonatomic, copy) NSString *physicalDemandvehiclemodifications;
@property (nullable, nonatomic, copy) NSString *physicalDemandvehiclemodnotes;
@property (nullable, nonatomic, copy) NSString *muscleStrengthyes;
@property (nullable, nonatomic, copy) NSString *muscleStrengthno;
@property (nullable, nonatomic, copy) NSString *muscleStrengthrightupperextremity;
@property (nullable, nonatomic, copy) NSString *muscleStrengthleftupperextremity;
@property (nullable, nonatomic, copy) NSString *muscleStrengthrightlowerextremity;
@property (nullable, nonatomic, copy) NSString *muscleStrengthleftlowerextremity;
@property (nullable, nonatomic, copy) NSString *mobilityyes;
@property (nullable, nonatomic, copy) NSString *mobilityno;
@property (nullable, nonatomic, copy) NSString *mobilityrightupperextremity;
@property (nullable, nonatomic, copy) NSString *mobilityleftupperextremity;
@property (nullable, nonatomic, copy) NSString *mobilityrightlowerextremity;
@property (nullable, nonatomic, copy) NSString *mobilityleftlowerextremity;
@property (nullable, nonatomic, copy) NSString *mobilitytrunk;
@property (nullable, nonatomic, copy) NSString *stabilityyes;
@property (nullable, nonatomic, copy) NSString *stabilityno;
@property (nullable, nonatomic, copy) NSString *stabilityrightupperextremity;
@property (nullable, nonatomic, copy) NSString *stabilityleftupperextremity;
@property (nullable, nonatomic, copy) NSString *stabilityrightlowerextremity;
@property (nullable, nonatomic, copy) NSString *stabilityleftlowerextremity;
@property (nullable, nonatomic, copy) NSString *stabilitytrunk;
@property (nullable, nonatomic, copy) NSString *impairmenthand;
@property (nullable, nonatomic, copy) NSString *impairmentupperlimb;
@property (nullable, nonatomic, copy) NSString *amputationhand;
@property (nullable, nonatomic, copy) NSString *amputationpartial;
@property (nullable, nonatomic, copy) NSString *amputationfull;
@property (nullable, nonatomic, copy) NSString *amputationupperlimb;
@property (nullable, nonatomic, copy) NSString *powergriprightyes;
@property (nullable, nonatomic, copy) NSString *powergriprightno;
@property (nullable, nonatomic, copy) NSString *powergripleftyes;
@property (nullable, nonatomic, copy) NSString *powergripleftno;
@property (nullable, nonatomic, copy) NSString *surgicalreconstructionyes;
@property (nullable, nonatomic, copy) NSString *surgicalreconstructionno;
@property (nullable, nonatomic, copy) NSString *hasupperimpairment;
@property (nullable, nonatomic, copy) NSString *haslowerlimbimpairment;
@property (nullable, nonatomic, copy) NSString *hasrightimpairment;
@property (nullable, nonatomic, copy) NSString *hasleftimpairment;
@property (nullable, nonatomic, copy) NSString *hasupperamputation;
@property (nullable, nonatomic, copy) NSString *haslowerlimbamputation;
@property (nullable, nonatomic, copy) NSString *hasrightamputation;
@property (nullable, nonatomic, copy) NSString *hasleftamputation;
@property (nullable, nonatomic, copy) NSString *appropriateprosthesisyes;
@property (nullable, nonatomic, copy) NSString *appropriateprosthesisno;
@property (nullable, nonatomic, copy) NSString *appropriateterminaldeviceyes;
@property (nullable, nonatomic, copy) NSString *appropriateterminaldeviceno;
@property (nullable, nonatomic, copy) NSString *prosthesisfitsyes;
@property (nullable, nonatomic, copy) NSString *prosthesisfitsno;
@property (nullable, nonatomic, copy) NSString *useprostheticproficientlyyes;
@property (nullable, nonatomic, copy) NSString *useprostheticproficientlyno;
@property (nullable, nonatomic, copy) NSString *abilitytopowergraspno;
@property (nullable, nonatomic, copy) NSString *abilitytopowergraspyes;
@property (nullable, nonatomic, copy) NSString *prostheticrecommendations;
@property (nullable, nonatomic, copy) NSString *prostheticclinicaldescription;
@property (nullable, nonatomic, copy) NSString *medicalconditionsinterferewithtasksno;
@property (nullable, nonatomic, copy) NSString *medicalconditionsinterferewithtasksyes;
@property (nullable, nonatomic, copy) NSString *medicalconditionsinterferewithtasksexplanation;
@property (nullable, nonatomic, copy) NSString *medicalfindingsandevaluation;
@property (nullable, nonatomic, copy) NSString *physicianlastname;
@property (nullable, nonatomic, copy) NSString *physicianfirstname;
@property (nullable, nonatomic, copy) NSString *physicianmiddlename;
@property (nullable, nonatomic, copy) NSString *physicianaddress;
@property (nullable, nonatomic, copy) NSString *physiciancity;
@property (nullable, nonatomic, copy) NSString *physicianstate;
@property (nullable, nonatomic, copy) NSString *physicianzipcode;
@property (nullable, nonatomic, copy) NSString *physiciantelephonenumber;
@property (nullable, nonatomic, copy) NSString *physicianalternatenumber;
@property (nullable, nonatomic, copy) NSString *physiatrist;
@property (nullable, nonatomic, copy) NSString *orthopedicsurgeon;
@property (nullable, nonatomic, copy) NSString *boardCertifiedyes;
@property (nullable, nonatomic, copy) NSString *boardCertifiedno;
@property (nullable, nonatomic, copy) NSString *boardEligibleyes;
@property (nullable, nonatomic, copy) NSString *boardEligibleno;
@property (nullable, nonatomic, copy) NSDate *physiciandate;

@end

NS_ASSUME_NONNULL_END
