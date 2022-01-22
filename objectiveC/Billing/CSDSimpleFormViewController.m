//
//  CSDSimpleFormViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDSimpleFormViewController.h"
#import "InputCell.h"
#import "InputCellWithId.h"
#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"
#import "RCOValuesListViewController.h"
#import "NSDate+TKCategory.h"
#import "TrainingStudent+CoreDataClass.h"
#import "TrainingCompany+CoreDataClass.h"
#import "Settings.h"
#import "TrainingCompanyAggregate.h"
#import "TrainingEquipmentReviewedAggregate.h"
#import "TrainingEquipmentAggregate.h"
#import "TrainingEquipmentReviewed+CoreDataClass.h"
#import "TrainingEquipment+CoreDataClass.h"
#import "TrainingTestInfo+CoreDataClass.h"
#import "DriverMedicalForm+CoreDataClass.h"
#import "DriverMedicalFormAggregate.h"


#define Key_Company @"company"
#define Key_Student @"employeeId"
#define Key_Instructor @"instructorEmployeeId"

@interface CSDSimpleFormViewController ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *fieldsNames;
@property (nonatomic, strong) NSMutableArray *categoryFields;
@property (nonatomic, strong) NSMutableArray *categoryFieldsNames;

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *disabledFields;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *percentageFields;
@property (nonatomic, strong) NSArray *numericFields;

@property (nonatomic, strong) NSArray *datePickerFieldsNames;

@property (nonatomic, strong) NSDate *dateTime;

@property (nonatomic, strong) TrainingCompany *company;
@property (nonatomic, strong) User *student;
@property (nonatomic, strong) User *instructor;

@property (nonatomic, assign) BOOL isSaveEnabled;

@property (nonatomic, strong) UIAlertController *al;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *reloadBtn;

@property (nonatomic, assign) BOOL needsToSave;
@property (nonatomic, assign) NSInteger index;

@end

@implementation CSDSimpleFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveButtonPressed:)];
    [self.saveBtn setEnabled:NO];
    
    self.reloadBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                   target:self
                                                                   action:@selector(reloadButtonPressed:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveBtn, self.reloadBtn, nil];
    
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveBtn, nil];

    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.values = [NSMutableDictionary dictionary];

    [self loadCodingFields];
    
    //self.pickerFields = [NSArray arrayWithObjects:@"company", @"instructorEmployeeId", @"employeeId", @"transmissionType", @"vehicleType", @"vehicleManufacturer", @"singleTrailerLength", @"lVCType", @"lVCLength", @"dollyGearType", nil];

    [self loadObject];
    
    self.title = @"Driver Medical";
}

-(IBAction)infoButtonPressed:(id)sender {
    return;
    NSString *msg = @"1. To Add a new Equipment please tap on the Add button from bottom toolbar.\n\n2. To navigate through Equipments please use '<<' and '>>' buttons";
    [self showSimpleMessage:msg];
}


-(void)loadCodingFields {
        self.fields = [NSArray arrayWithObjects:@"carrierName",
        @"doctorsName",
        @"sPEApplicantName",
        @"vehicleTypeStraightTruck",
        @"vehicleTypeTruckTrailerover10klbs",
        @"vehicleTypeTrucklessthan10klbsandhazardousmaterials",
        @"vehicleTypeTruckover10klbs",
        @"vehicleTypeMotorHome10klbs",
        @"vehicleTypeTractorTrailer",
        @"vehicleTypePassengerVehicle",
        @"vehicleTypePassengerSeatingCapacity",
        @"vehicleTypePassengerMotorCoach",
        @"vehicleTypePassengerBus",
        @"vehicleTypePassengerVan",
        @"vehicleTypeshortrelaydrives",
        @"vehicleTypelongrelaydrives",
        @"vehicleTypestraightthrough",
        @"vehicleTypenightsawayfromhome",
        @"vehicleTypesleeperteamdrives",
        @"vehicleTypenumberofnightsawayfromhome",
        @"vehicleTypeclimbinginandoutoftruck",
        @"environmentalFactorsabruptduty",
        @"environmentalFactorssleepdeprivation",
        @"environmentalFactorsunbalancedwork",
        @"environmentalFactorstemperature",
        @"environmentalFactorslongtrips",
        @"environmentalFactorsshortnotice",
        @"environmentalFactorstightdelivery",
        @"environmentalFactorsdelayenroute",
        @"environmentalFactorsothers",
        @"physicalDemandGearShifting",
        @"physicalDemandNumberspeedtransmission",
        @"physicalDemandsemiautomatic",
        @"physicalDemandfullyautomatic",
        @"physicalDemandsteeringwheelcontrol",
        @"physicalDemandbrakeacceleratoroperation",
        @"physicalDemandvarioustasks",
        @"physicalDemandbackingandparking",
        @"physicalDemandvehicleinspections",
        @"physicalDemandcargohandling",
        @"physicalDemandchangingtires",
        @"physicalDemandvehiclemodifications",
        @"physicalDemandvehiclemodnotes",
        @"muscleStrengthyes",
        @"muscleStrengthno",
        @"muscleStrengthrightupperextremity",
        @"muscleStrengthleftupperextremity",
        @"muscleStrengthrightlowerextremity",
        @"muscleStrengthleftlowerextremity",
        @"mobilityyes",
        @"mobilityno",
        @"mobilityrightupperextremity",
        @"mobilityleftupperextremity",
        @"mobilityrightlowerextremity",
        @"mobilityleftlowerextremity",
        @"mobilitytrunk",
        @"stabilityyes",
        @"stabilityno",
        @"stabilityrightupperextremity",
        @"stabilityleftupperextremity",
        @"stabilityrightlowerextremity",
        @"stabilityleftlowerextremity",
        @"stabilitytrunk",
        @"impairmenthand",
        @"impairmentupperlimb",
        @"amputationhand",
        @"amputationpartial",
        @"amputationfull",
        @"amputationupperlimb",
        @"powergriprightyes",
        @"powergriprightno",
        @"powergripleftyes",
        @"powergripleftno",
        @"surgicalreconstructionyes",
        @"surgicalreconstructionno",
        @"hasupperimpairment",
        @"haslowerlimbimpairment",
        @"hasrightimpairment",
        @"hasleftimpairment",
        @"hasupperamputation",
        @"haslowerlimbamputation",
        @"hasrightamputation",
        @"hasleftamputation",
        @"appropriateprosthesisyes",
        @"appropriateprosthesisno",
        @"appropriateterminaldeviceyes",
        @"appropriateterminaldeviceno",
        @"prosthesisfitsyes",
        @"prosthesisfitsno",
        @"useprostheticproficientlyyes",
        @"useprostheticproficientlyno",
        @"abilitytopowergraspno",
        @"abilitytopowergraspyes",
        @"prostheticrecommendations",
        @"prostheticclinicaldescription",
        @"medicalconditionsinterferewithtasksno",
        @"medicalconditionsinterferewithtasksyes",
        @"medicalconditionsinterferewithtasksexplanation",
        @"medicalfindingsandevaluation",
        @"physicianlastname",
        @"physicianfirstname",
        @"physicianmiddlename",
        @"physicianaddress",
        @"physiciancity",
        @"physicianstate",
        @"physicianzipcode",
        @"physiciantelephonenumber",
        @"physicianalternatenumber",
        @"physiatrist",
        @"orthopedicsurgeon",
        @"boardCertifiedyes",
        @"boardCertifiedno",
        @"boardEligibleyes",
        @"boardEligibleno",
        @"physiciandate", nil];
    
        self.fieldsNames = [NSArray arrayWithObjects: @"carrierName",
        @"doctorsName",
        @"sPEApplicantName",
        @"vehicleTypeStraightTruck",
        @"vehicleTypeTruckTrailerover10klbs",
        @"vehicleTypeTrucklessthan10klbsandhazardousmaterials",
        @"vehicleTypeTruckover10klbs",
        @"vehicleTypeMotorHome10klbs",
        @"vehicleTypeTractorTrailer",
        @"vehicleTypePassengerVehicle",
        @"vehicleTypePassengerSeatingCapacity",
        @"vehicleTypePassengerMotorCoach",
        @"vehicleTypePassengerBus",
        @"vehicleTypePassengerVan",
        @"vehicleTypeshortrelaydrives",
        @"vehicleTypelongrelaydrives",
        @"vehicleTypestraightthrough",
        @"vehicleTypenightsawayfromhome",
        @"vehicleTypesleeperteamdrives",
        @"vehicleTypenumberofnightsawayfromhome",
        @"vehicleTypeclimbinginandoutoftruck",
        @"environmentalFactorsabruptduty",
        @"environmentalFactorssleepdeprivation",
        @"environmentalFactorsunbalancedwork",
        @"environmentalFactorstemperature",
        @"environmentalFactorslongtrips",
        @"environmentalFactorsshortnotice",
        @"environmentalFactorstightdelivery",
        @"environmentalFactorsdelayenroute",
        @"environmentalFactorsothers",
        @"physicalDemandGearShifting",
        @"physicalDemandNumberspeedtransmission",
        @"physicalDemandsemiautomatic",
        @"physicalDemandfullyautomatic",
        @"physicalDemandsteeringwheelcontrol",
        @"physicalDemandbrakeacceleratoroperation",
        @"physicalDemandvarioustasks",
        @"physicalDemandbackingandparking",
        @"physicalDemandvehicleinspections",
        @"physicalDemandcargohandling",
        @"physicalDemandchangingtires",
        @"physicalDemandvehiclemodifications",
        @"physicalDemandvehiclemodnotes",
        @"muscleStrengthyes",
        @"muscleStrengthno",
        @"muscleStrengthrightupperextremity",
        @"muscleStrengthleftupperextremity",
        @"muscleStrengthrightlowerextremity",
        @"muscleStrengthleftlowerextremity",
        @"mobilityyes",
        @"mobilityno",
        @"mobilityrightupperextremity",
        @"mobilityleftupperextremity",
        @"mobilityrightlowerextremity",
        @"mobilityleftlowerextremity",
        @"mobilitytrunk",
        @"stabilityyes",
        @"stabilityno",
        @"stabilityrightupperextremity",
        @"stabilityleftupperextremity",
        @"stabilityrightlowerextremity",
        @"stabilityleftlowerextremity",
        @"stabilitytrunk",
        @"impairmenthand",
        @"impairmentupperlimb",
        @"amputationhand",
        @"amputationpartial",
        @"amputationfull",
        @"amputationupperlimb",
        @"powergriprightyes",
        @"powergriprightno",
        @"powergripleftyes",
        @"powergripleftno",
        @"surgicalreconstructionyes",
        @"surgicalreconstructionno",
        @"hasupperimpairment",
        @"haslowerlimbimpairment",
        @"hasrightimpairment",
        @"hasleftimpairment",
        @"hasupperamputation",
        @"haslowerlimbamputation",
        @"hasrightamputation",
        @"hasleftamputation",
        @"appropriateprosthesisyes",
        @"appropriateprosthesisno",
        @"appropriateterminaldeviceyes",
        @"appropriateterminaldeviceno",
        @"prosthesisfitsyes",
        @"prosthesisfitsno",
        @"useprostheticproficientlyyes",
        @"useprostheticproficientlyno",
        @"abilitytopowergraspno",
        @"abilitytopowergraspyes",
        @"prostheticrecommendations",
        @"prostheticclinicaldescription",
        @"medicalconditionsinterferewithtasksno",
        @"medicalconditionsinterferewithtasksyes",
        @"medicalconditionsinterferewithtasksexplanation",
        @"medicalfindingsandevaluation",
        @"physicianlastname",
        @"physicianfirstname",
        @"physicianmiddlename",
        @"physicianaddress",
        @"physiciancity",
        @"physicianstate",
        @"physicianzipcode",
        @"physiciantelephonenumber",
        @"physicianalternatenumber",
        @"physiatrist",
        @"orthopedicsurgeon",
        @"boardCertifiedyes",
        @"boardCertifiedno",
        @"boardEligibleyes",
        @"boardEligibleno",
        @"physiciandate", nil];

        self.requiredFields = nil;
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipmentReviewed"] registerForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"] registerForCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipmentReviewed"] unRegisterForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"] unRegisterForCallback:self];
}


-(void)loadObject {
    for (NSString *field in self.fields) {
        NSString *value = nil;
        value = [self.form valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }
    [self.tableView reloadData];
}

-(IBAction)cancelButtonPressed:(id)sender {
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)reloadButtonPressed:(id)sender {

    return;
    
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:@"Reload the most recent Test Info?"
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        
        [self loadCodingFields];

        [self loadObject];
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                        }];

    [al addAction:cancelAction];
    [al addAction:yesAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(IBAction)saveButtonPressed:(id)sender {
    if (!self.needsToSave) {
        // if the button is not enabled then we should not try to save anything ....
        return;
    }
    
    NSString *message = [self validateInputs];
    
    if (message) {
        // 03.02.2020 add the sender check not to show the message if is an "auto" save
        if (sender) {
            [self showSimpleMessage:message];
        }
        return;
    }
    if (sender) {
        if (self.form) {
            self.progressHUD.labelText = @"Update record...";
        } else {
            self.progressHUD.labelText = @"Create record...";
        }
    
        [self.view addSubview:self.progressHUD];
        [self.progressHUD show:YES];
    
        [self performSelector:@selector(createOrUpdateRecord) withObject:nil afterDelay:0.1];
    } else {
        [self createOrUpdateRecord];
    }
}

-(IBAction)addButtonPressed:(id)sender {
    if (self.saveBtn.enabled) {
        NSString *msg = nil;
        
        msg = @"Form is not saved. Changes will be lost. Do you want to continue?";

        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
            
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        }];
            
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                // we should select back
                return;
        }];
            
        [al addAction:cancelAction];
        [al addAction:yesAction];
        [self presentViewController:al animated:YES completion:nil];
    } else {
        NSString *msg = nil;
            msg = @"Add new Form?";
            UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                        message:msg
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
            }];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                // we should select back
                return ;
                                                                 }];
            
            [al addAction:cancelAction];
            [al addAction:yesAction];
            [self presentViewController:al animated:YES completion:nil];
        }
}

-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)createOrUpdateRecord {
    
    if (!self.form) {
        self.form = (Driver*)[[self aggregate] createNewObject];
        self.form.dateTime = [NSDate date];
    }
        
    for (NSString *field in self.fields) {
        id val = [self.values objectForKey:field];
        if (val) {
            if ([self.switchFields containsObject:field]) {
                [self.form setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [self.form setValue:val forKey:field];
            }
        }
    }
        
    [[self aggregate] createNewRecord:self.form];
    
    [self.saveBtn setEnabled:NO];
    self.needsToSave = NO;
}

-(NSString*)validateInputs {
    
    for (NSString *key in self.requiredFields) {
        NSObject *obj = [self.values objectForKey:key];
        if (!obj) {
            //get the coding field name
            NSInteger index = [self.fields indexOfObject:key];
            NSString *fieldName = [self.fieldsNames objectAtIndex:index];
            NSString *message = [NSString stringWithFormat:@"%@ was not set!", fieldName];
            return message;
        }
    }
    return nil;
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fields.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [self.fieldsNames objectAtIndex:section];
    title = [NSString stringWithFormat:@"%d. %@", (int)(section + 1), title];
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [TrainingTestInfo lightColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    //Set the background color of the View
    view.tintColor = [UIColor yellowColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *key = nil;
    NSString *value = nil;
    key = [self.fields objectAtIndex:indexPath.section];
    value = [self.values objectForKey:[NSString stringWithFormat:@"%@", key]];
    
    BOOL requiredField = [self.requiredFields containsObject:key];
    
    UILabel *requiredLbl = nil;
    if (requiredField) {
        requiredLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        requiredLbl.text = @"*";
        [requiredLbl setTextColor:[UIColor redColor]];
    }
    
    if ([self.switchFields containsObject:key]) {
        
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"switchCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCell"];
        }

        NSInteger keyIndex = [self.switchFields indexOfObject:key];

        UISwitch *sw = [[UISwitch alloc] init];
        
        sw.tag = keyIndex;
        sw.on = [value boolValue];

        [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = key;
        // 27.05.2019 there is no point in displaying extra text for switch
        cell.textLabel.text = nil;
        cell.imageView.image = nil;
        return cell;

    } else if ([self.datePickerFieldsNames containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"dateCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
        }
        
        NSDate *date = [self.values objectForKey:key];
        
        if (date) {
            if ([key isEqualToString:@"dateTime"]) {
                cell.textLabel.text = [[self aggregate] rcoDateAndTimeToString:date];
            } else {
                cell.textLabel.text = [[self aggregate] rcoDateToString:date];
            }
        } else {
            cell.textLabel.text = nil;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = requiredLbl;
        cell.imageView.image = [UIImage imageNamed:@"CALENDAR"];
        return cell;
        
    } else if ([self.pickerFields containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"PickerCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PickerCell"];
        }
        
        if ([key isEqualToString:Key_Student]) {
            if (self.student) {
                value = [NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname];
                cell.textLabel.text = value;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.student.driverLicenseState, self.student.driverLicenseNumber];
            } else {
                cell.textLabel.text = nil;
                cell.detailTextLabel.text = nil;
            }
        } else if ([key isEqualToString:Key_Instructor]) {
            if (self.instructor) {
                value = [NSString stringWithFormat:@"%@ %@", self.instructor.surname, self.instructor.firstname];
                cell.textLabel.text = value;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.instructor.employeeNumber];
            } else {
                cell.textLabel.text = nil;
                cell.detailTextLabel.text = nil;
            }
        } else {
            cell.textLabel.text = value;
            cell.detailTextLabel.text = nil;
        }
        
        if (value) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = requiredLbl;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = nil;
        return cell;
    }
    
    // we have input cell
    InputCell *inputCell = nil;
    
    inputCell = (InputCell*)[theTableView dequeueReusableCellWithIdentifier:@"InputCell"];
    
    if (inputCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InputCell"
                                                     owner:self
                                                   options:nil];
        inputCell = (InputCell *)[nib objectAtIndex:0];
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [NSString stringWithFormat:@"%@", value];
    }

    //configure input
    CGRect frame = inputCell.titleLabel.frame;
    // hide title label
    frame.size.width = 0;
    inputCell.titleLabel.frame = frame;
    // resize input field
    frame = inputCell.inputTextField.frame;
    frame.origin.x = 10;
    // we should maximize the width
    frame.size.width = inputCell.frame.size.width - 20;
    
    [inputCell.requiredLabel setHidden:!requiredField];
    
    inputCell.inputTextField.frame = frame;
    
    inputCell.inputTextField.delegate = self;
    
    [inputCell.inputTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    inputCell.inputTextField.tag = indexPath.section;
    
    inputCell.inputTextField.font = [UIFont boldSystemFontOfSize:19];
    
    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    inputCell.inputTextField.text = value;
    inputCell.inputTextField.inputAccessoryView = self.keyboardToolbar;

    if ([self.numericFields containsObject:key]) {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDefault;
    }

    if ([self.disabledFields containsObject:key]) {
        inputCell.inputTextField.enabled = NO;
        [inputCell.inputTextField setTextColor:[UIColor grayColor]];
    } else {
        inputCell.inputTextField.enabled = YES;
        [inputCell.inputTextField setTextColor:[UIColor darkTextColor]];
    }
    
    inputCell.inputTextField.font = [UIFont systemFontOfSize:15];
    
    if ([self.percentageFields containsObject:key]) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        lbl.text = @"%";
        inputCell.accessoryView = lbl;
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDecimalPad;
    } else {
        inputCell.accessoryView = nil;
    }
    
    return inputCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSString *key = [self.fields objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
     if ([key isEqualToString:Key_Company]) {
        [self showCompanyPickerFromView:cell];
    }else if ([key isEqualToString:Key_Student]) {
        if (!self.company) {
            [self showSimpleMessage:@"Please select company first!"];
            return;
        }
        [self showUserPickerFromView:cell forKey:key];
    } else if ([key isEqualToString:Key_Instructor]) {
        [self showUserPickerFromView:cell forKey:key];
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        [self showDatePickerFromView:cell andKey:key];
    } else {
        if ([self.pickerFields containsObject:key]) {
            [self showKeyPickerFromView:cell forKey:key];
        }
    }
}

-(IBAction)showKeyPickerFromView:(UIView*)fromView forKey:(NSString*)key {
    
    SEL sel = NSSelectorFromString(key);
    NSArray *values = nil;
    if ([self respondsToSelector:sel]) {
        values = [self performSelector:sel];
    } else {
        return;
    }
    
    NSInteger index = [self.fields indexOfObject:key];
    NSString *title = nil;
    
    if (index != NSNotFound) {
        title = [self.fieldsNames objectAtIndex:index];
    }
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:values
                                                                                                forKey:key];
    
    listController.selectDelegate = self;
    listController.title = title;
    //listController.showIndex = YES;
    listController.newLogic = YES;
    NSString *value = [self.values objectForKey:key];
    if (value) {
        listController.selectedValue = value;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(void)switchValueChanged:(UISwitch*)aSwitch {
    NSInteger keyIndex = aSwitch.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    [self.values setObject:[NSNumber numberWithBool:aSwitch.on] forKey:key];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showUserPickerFromView:(UIView*)fromView forKey:(NSString*)key{
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    id selectedObject = nil;
    
    if ([key isEqualToString:Key_Student]) {
        aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
        title = @"Students";
        fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
        detailFields = [NSArray arrayWithObjects:@"driverLicenseState", @"driverLicenseNumber", @"employeeNumber", nil];
        sortKey = @"surname";
        selectedObject = self.student;
        predicate = [NSPredicate predicateWithFormat:@"company=%@", self.company.name];
    } else {
        title = @"Instructors";
        aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];
        fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
        detailFields = [NSArray arrayWithObjects:@"employeeNumber", nil];
        sortKey = @"surname";
        selectedObject = self.instructor;
    }
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:key
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = key;
    listController.title = title;
    listController.selectedItem = selectedObject;

    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showCompanyPickerFromView:(UIView*)fromView{
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    title = @"Students";
    fields = [NSArray arrayWithObjects:@"name", @"number", nil];
    detailFields = nil;
    sortKey = @"name";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:Key_Company
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = Key_Company;
    listController.title = title;
    listController.selectedItem = self.company;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}



-(void)showDatePickerFromView:(UIView*)fromView andKey:(NSString*)key  {
    DateSelectorViewController *controller = [[DateSelectorViewController alloc] initWithNibName:@"DateSelectorViewController"
                                                                                          bundle:nil
                                                                                        forDates:[NSArray arrayWithObject:key]];
    controller.selectDelegate = self;
    controller.shouldPopUpOnIpad = YES;
    
    NSDate *date = [self.values objectForKey:key];
    
    if (!date) {
        date = [NSDate date];
    }
    
    controller.title = @"Date";
    controller.isSimpleDatePicker = YES;

    NSInteger index = [self.fields indexOfObject:key];
    if (index != NSNotFound) {
        NSString *name = [self.fieldsNames objectAtIndex:index];
        controller.dateNames = [NSArray arrayWithObject:name];
    }
    
    controller.currentDate = date;
    
    if (DEVICE_IS_IPHONE) {
        controller.isCancelNewLogic = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showPopoverForViewController:controller fromView:fromView];
    }
}

-(void)loadCompanyWithName:(NSString*)name {
    TrainingCompanyAggregate *agg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    self.company = [agg getTrainingCompanyWithName:name];
}

#pragma mark -
#pragma mark UItextFieldDelegate Methods

- (IBAction)textFieldChanged:(UITextField*) textField {
    NSString *value = textField.text;
    NSString *key = nil;
    
    if ([textField isKindOfClass:[TextField class]]) {
        key = ((TextField*)textField).fieldId;
    } else {
        key = [self.fields objectAtIndex:textField.tag];
    }
    [self.values setObject:[value stringByReplacingOccurrencesOfString:@"\n" withString:@" "] forKey:key];
    [self enableSaveBtn];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.currentIndexPath = nil;
    if ([[[textField superview] superview] isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
        self.currentIndexPath = [self.tableView indexPathForCell:cell];
    }

    return YES;
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([object isKindOfClass:[NSDate class]]) {
        [self.values setObject:object forKey:key];
    } else if (key && [self.pickerFields containsObject:key]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    }

    [self enableSaveBtn];
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self.tableView reloadData];
}

-(void)enableSaveBtn {
    [self.saveBtn setEnabled:YES];
    self.needsToSave = YES;
}

-(Aggregate*)aggregate {
    
    return [[DataRepository sharedInstance] getAggregateForClass:@"DriverMedicalForm"];
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:FMD]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
        [self loadCodingFields];
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObject:self.form forKey:self.addDelegateKey];
        }

    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    //NSString *errorMessage = [messageInfo objectForKey:@"errorMessage"];
    NSString *message = [messageInfo objectForKey:@"message"];
   
    if ([message isEqualToString:FMD]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
    }
}

#pragma mark Keyboard Methods
- (void)keyboardWillHide:(NSNotification *)notif {
    self.currentIndexPath = nil;
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

- (void)keyboardWillShow:(NSNotification *)notif{
    self.keyboardInfo = notif.userInfo;
    NSInteger keyBoardHeight = [[self.keyboardInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height;
    UIEdgeInsets contentInset = UIEdgeInsetsMake(0.0, 0.0, keyBoardHeight, 0.0);
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
    if (self.currentIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
@end
