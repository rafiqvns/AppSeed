//
//  CSDEquipmentViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDEquipmentViewController.h"
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

#define Key_Company @"company"
#define Key_Student @"employeeId"
#define Key_Instructor @"instructorEmployeeId"

@interface CSDEquipmentViewController ()
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

@property (nonatomic, assign) BOOL isReviewed;

@property (nonatomic, assign) BOOL isSaveEnabled;

@property (nonatomic, strong) UIAlertController *al;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *reloadBtn;
@property (nonatomic, strong) NSMutableArray *reviews;
@property (nonatomic, strong) NSMutableArray *used;

@property (nonatomic, strong) NSArray *transmissionType;
@property (nonatomic, strong) NSArray *vehicleType;
@property (nonatomic, strong) NSArray *vehicleManufacturer;
@property (nonatomic, strong) NSArray *singleTrailerLength;
@property (nonatomic, strong) NSArray *lVCType;
@property (nonatomic, strong) NSArray *lVCLength;
@property (nonatomic, strong) NSArray *dollyGearType;

@property (nonatomic, assign) BOOL needsToSave;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) TrainingEquipment *equipment;
@property (nonatomic, strong) TrainingEquipmentReviewed *equipmentReviewed;


@end

@implementation CSDEquipmentViewController

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
    
    NSNumber *isDrivingSchool = [Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL];
    if ([isDrivingSchool boolValue]) {
        // 09.12.2019 remove reload button
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveBtn, nil];
    } else {
        //12.12.2019 we should not show the Save button anymore will be saved automatically
        self.navigationItem.rightBarButtonItems = [NSArray array];
    }

    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.values = [NSMutableDictionary dictionary];

    [self loadPrevStudent];
    [self loadPrevInstructor];

    [self loadEquipmentReviews];
    [self loadEquipmentUsed];
    [self loadCodingFields];
    
    self.transmissionType = [NSArray arrayWithObjects:@"Automatic", @"Manual", @"Other", nil];
    self.vehicleType = [NSArray arrayWithObjects:@"Sedan", @"Pick-up truck", @"Cargo Van", @"Passenger Van", @"Utility Truck", @"Passenger Bus", @"Straight Truck", @"Tractor (Day Cab)",  @"Tractor (Sleeper)", @"Yard Shifter", @"Other",  nil];
    self.vehicleManufacturer = [NSArray arrayWithObjects:@"Freightliner", @"International", @"Mack", @"Ottowa", @"Sterling",  @"Other", nil];

    //06.01.2020 self.singleTrailerLength = [NSArray arrayWithObjects:@"Multiple Choice", @"28", @"40", @"45", @"48", @"53", @"Other", nil];
    self.singleTrailerLength = [NSArray arrayWithObjects:@"28", @"40", @"45", @"48", @"53", @"Other", nil];

    // 06.01.2020 self.lVCType = [NSArray arrayWithObjects:@"Multiple Choice", @"Doubles", @"Thriples", @"Rocky Mountain", @"Other", nil];
    self.lVCType = [NSArray arrayWithObjects:@"Doubles", @"Thriples", @"Rocky Mountain", @"Other", nil];

    //06.01.2020 self.lVCLength = [NSArray arrayWithObjects:@"Multiple Choice", @"28", @"40", @"45", @"Other", nil];
    self.lVCLength = [NSArray arrayWithObjects:@"28", @"40", @"45", @"Other", nil];

    //06.01.2020 self.dollyGearType = [NSArray arrayWithObjects:@"Multiple Choice", @"Converter", @"Low-Loader", @"Expanding/Contracting", @"Other", nil];
    self.dollyGearType = [NSArray arrayWithObjects:@"Converter", @"Low-Loader", @"Expanding/Contracting", @"Other", nil];

    self.pickerFields = [NSArray arrayWithObjects:@"company", @"instructorEmployeeId", @"employeeId", @"transmissionType", @"vehicleType", @"vehicleManufacturer", @"singleTrailerLength", @"lVCType", @"lVCLength", @"dollyGearType", nil];

    [self loadObject];
    
    self.title = @"Equipment";
}

-(void)loadPrevInstructor{
    NSString *prevInstructor = [Settings getSetting:CSD_PREV_INSTRUCTOR];
    if (prevInstructor.length == 0) {
        return;
    }
    UserAggregate *instrAgg = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];

    self.instructor = (User*)[instrAgg getObjectWithRecordId:prevInstructor];
    
    if (self.instructor.employeeNumber) {
        [self.values setObject:self.instructor.employeeNumber forKey:@"instructorEmployeeId"];
    }
}

-(void)loadPrevStudent{
    NSString *prevStudent = [Settings getSetting:CSD_PREV_STUDENT];
    if (prevStudent.length == 0) {
        return;
    }
    UserAggregate *studentAggregate = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];

    if ([prevStudent longLongValue]) {
        self.student = (User*)[studentAggregate getObjectWithRecordId:prevStudent];
    } else {
        self.student = (User*)[studentAggregate getObjectWithMobileRecordId:prevStudent];
    }
    
    if (self.student.employeeNumber) {
        [self.values setObject:self.student.employeeNumber forKey:@"employeeId"];
    }
    if (self.student.driverLicenseState) {
        [self.values setObject:self.student.driverLicenseState forKey:@"studentDriverLicenseState"];
    }
    if (self.student.driverLicenseNumber) {
        [self.values setObject:self.student.driverLicenseNumber forKey:@"studentDriverLicenseNumber"];
    }

    if (self.student.company) {
        [self.values setObject:self.student.company forKey:@"company"];
        [self loadCompanyWithName:self.student.company];
    }
}

-(void)loadEquipmentReviews {
    if (!self.student) {
        return;
    }
    
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!parentMobileRecordId.length) {
        return;
    }

    TrainingEquipmentReviewedAggregate *agg = (TrainingEquipmentReviewedAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipmentReviewed"];
    /*
     //12/12.2019 we should use the mobileRecordId of the testInfo
    NSArray *reviews = [agg getTrainingEquipmentForDrivingLicenseNumber:self.student.driverLicenseNumber
                                                     driverLicenseState:self.student.driverLicenseState
                                                          andInstructor:self.instructor.employeeNumber];
    */
    NSArray *reviews = [agg getEquipmentReviewedForTestInfo:parentMobileRecordId];
    self.reviews = [NSMutableArray arrayWithArray:reviews];
    self.index = self.reviews.count;
    
    if (self.reviews.count) {
        [self.prevBtn setEnabled:YES];
    }
}

-(void)loadEquipmentUsed {
    if (!self.student) {
        return;
    }
    
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!parentMobileRecordId.length) {
        return;
    }
    
    TrainingEquipmentAggregate *agg = (TrainingEquipmentAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"];
    /*
     //12/12.2019 we should use the mobileRecordId of the testInfo
    NSArray *reviews = [agg getTrainingEquipmentForDrivingLicenseNumber:self.student.driverLicenseNumber
                                                     driverLicenseState:self.student.driverLicenseState
                                                          andInstructor:self.instructor.employeeNumber];
    */
    
    NSArray *reviews = [agg getEquipmentUsedForTestInfo:parentMobileRecordId];
    self.used = [NSMutableArray arrayWithArray:reviews];
    self.index = self.used.count;
    
    if (self.used.count) {
        [self.prevBtn setEnabled:YES];
    }
}

-(IBAction)infoButtonPressed:(id)sender {
    NSString *msg = @"1. To Add a new Equipment please tap on the Add button from bottom toolbar.\n\n2. To navigate through Equipments please use '<<' and '>>' buttons";
    [self showSimpleMessage:msg];
}

-(IBAction)viewChanged:(UISegmentedControl*)sender {
    self.isReviewed = sender.selectedSegmentIndex;
    
    if (self.saveBtn.enabled) {
        // we need to show a popup
        NSString *msg = nil;
        if (self.isReviewed) {
            msg = @"Review is not saved. Changes will be lost. Do you want to continue?";
        } else {
            msg = @"Equipment is not saved. Changes will be lost. Do you want to continue?";
        }
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
            [self loadCodingFields];
            [self resetEquipmentFields];
            [self.saveBtn setEnabled:NO];
            self.needsToSave = NO;
            [self.tableView reloadData];
                                                           }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                            // we should select back
            [sender setSelectedSegmentIndex:(1-sender.selectedSegmentIndex)];
            return ;
                                                             }];
        
        [al addAction:cancelAction];
        [al addAction:yesAction];
        [self presentViewController:al animated:YES completion:nil];
    } else {
        [self loadCodingFields];
        [self.tableView reloadData];
    }
}

-(void)loadCodingFields {
    if (self.isReviewed) {
        self.fields = [NSArray arrayWithObjects:@"company", @"instructorEmployeeId", @"employeeId", @"transmissionType", @"transmissionTypeNotes", @"vehicleType", @"vehicleTypeNotes", @"vehicleManufacturer", @"vehicleManufacturerNotes", @"singleTrailerLength", @"singleTrailerNotes", @"lVCType", @"lVCTypeNotes", @"lVCLength", @"lVCLengthNotes", @"dollyGearType", @"dollyGearTypeNotes", nil];
        //17.01.2020 replaced LVC string self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"Instructor", @"Student", @"Transmission Type", @"Notes", @"Vehicle Type", @"Notes", @"Vehicle Manufacturer", @"Notes", @"Single Trailer Length", @"Notes", @"LVC", @"Notes", @"LVC Length", @"Notes", @"Dolly Gear Type", @"Notes", nil];
        self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"Instructor", @"Student", @"Transmission Type", @"Notes", @"Vehicle Type", @"Notes", @"Vehicle Manufacturer", @"Notes", @"Single Trailer Length", @"Notes", @"Combination Vehicles", @"Notes", @"Combination Vehicles Length", @"Notes", @"Dolly Gear Type", @"Notes", nil];

        self.requiredFields = nil;
    } else {
        self.fields = [NSArray arrayWithObjects:@"company", @"instructorEmployeeId", @"employeeId", @"powerUnit", @"transmissionType", @"transmissionTypeOther",  @"vehicleType", @"vehicleTypeOther", @"vehicleManufacturer", @"vehicleManufacturerOther", @"singleTrailerLength", @"singleTrailerLengthOther", @"lVCType", @"lVCTypeOther", @"lVCLength", @"lVCLengthOther", @"dollyGearType", @"dollyGearTypeOther",  @"trailer1Number", @"dolly1Number", @"trailer2Number", @"dolly2Number", @"trailer3Number", nil];
        
        //17.01.2020 replaced LVC string self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"Instructor", @"Student", @"Number", @"Transmission Type", @"Transmission Type Other",  @"Vehicle Type", @"Vehicle Type Other", @"Vehicle Manufacturer", @"Vehicle Manufacturer Other", @"Single Trailer Length", @"Single Trailer Length Other", @"LVC", @"LVC Other", @"LVC Length", @"LVC Length Other", @"Dolly/Gear Type", @"Dolly/Gear Type Other",  @"Trailer 1", @"Dolly 1", @"Trailer 2", @"Dolly 2", @"Trailer 3", nil];
        self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"Instructor", @"Student", @"Power Unit Number", @"Transmission Type", @"Transmission Type Other",  @"Vehicle Type", @"Vehicle Type Other", @"Vehicle Manufacturer", @"Vehicle Manufacturer Other", @"Single Trailer Length", @"Single Trailer Length Other", @"Combination Vehicles", @"Combination Vehicles Other", @"Combination Vehicles Length", @"Combination Vehicles Length Other", @"Dolly/Gear Type", @"Dolly/Gear Type Other",  @"Trailer 1", @"Dolly 1", @"Trailer 2", @"Dolly 2", @"Trailer 3", nil];

        self.requiredFields = [NSArray arrayWithObjects:@"powerUnit", nil];
    }
    
    [self.tableView reloadData];
    if (self.isReviewed) {
        self.index = self.reviews.count;
    } else {
        self.index = self.used.count;
    }
    [self.countBtn setTitle:[NSString stringWithFormat:@"%d", (int)self.index]];
    
    [self.prevBtn setEnabled:NO];
    [self.nextBtn setEnabled:NO];
    if (self.index > 0) {
        [self.prevBtn setEnabled:YES];
    }
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
        if (self.isReviewed) {
            value = [self.equipmentReviewed valueForKey:field];
        } else {
            value = [self.equipment valueForKey:field];
        }
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

    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:@"Reload the most recent Test Info?"
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        
        [self loadPrevStudent];
        [self loadPrevInstructor];

        [self loadEquipmentReviews];
        [self loadEquipmentUsed];
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
    
    if (self.addParentMobileRecordId) {
        NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
        if (!parentMobileRecordId.length) {
            [self showSimpleMessage:@"Please add test info first!"];
            return;
        }
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
        if (self.equipment) {
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
        
        if (self.isReviewed) {
            msg = @"Equipment Review is not saved. Changes will be lost. Do you want to continue?";
        } else {
            msg = @"Equipment Used is not saved. Changes will be lost. Do you want to continue?";
        }

        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
            
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                [self resetEquipmentFields];
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
        if (self.isReviewed) {
            msg = @"Add new Equipment Review?";
        } else {
            msg = @"Add new Equipment Used?";
        }
            UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                        message:msg
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                [self resetEquipmentFields];
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

-(void)resetEquipmentFields {
    NSLog(@"New");
    NSArray *fieldsToClear = nil;
    
    if (self.isReviewed) {
        fieldsToClear = [NSArray arrayWithObjects: @"transmissionType", @"transmissionTypeNotes", @"vehicleType", @"vehicleTypeNotes", @"vehicleManufacturer", @"vehicleManufacturerNotes", @"singleTrailerLength", @"singleTrailerNotes", @"lVCType", @"lVCTypeNotes", @"lVCLength", @"lVCLengthNotes", @"dollyGearType", @"dollyGearTypeNotes", nil];
    } else {
        fieldsToClear = [NSArray arrayWithObjects:@"transmissionType", @"transmissionTypeOther",  @"vehicleType", @"vehicleTypeOther", @"vehicleManufacturer", @"vehicleManufacturerOther", @"singleTrailerLength", @"singleTrailerLengthOther", @"lVCType", @"lVCTypeOther", @"lVCLength", @"lVCLengthOther", @"dollyGearType", @"dollyGearTypeOther",  @"powerUnit", @"trailer1Number", @"dolly1Number", @"trailer2Number", @"dolly2Number", @"trailer3Number", nil];
    }

    for (NSString *key in fieldsToClear) {
        [self.values removeObjectForKey:key];
    }
    
    self.equipment = nil;
    self.equipmentReviewed = nil;
    [self.tableView reloadData];
}

-(IBAction)prevButtonPressed:(id)sender {
    
    NSString *msg = nil;
    
    if (self.saveBtn.enabled) {
        if (self.isReviewed) {
            msg = @"Review is not saved. Changes will be lost. Do you want to continue?";
        } else {
            msg = @"Equipment is not saved. Changes will be lost. Do you want to continue?";
        }
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
            [self loadCodingFields];
            [self resetEquipmentFields];
            [self.saveBtn setEnabled:NO];
            [self.tableView reloadData];
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
    
    if (self.index > 0) {
        
        if (self.isReviewed) {
            if (!self.equipmentReviewed ) {
                //06.11.2019 this is the case when we just entered the screen and we
                //self.index -= 2;
                self.index -= 1;
            } else {
                self.index--;
            }
        } else {
            if (!self.equipment) {
                //06.11.2019 this is the case when we just entered the screen and we
                //self.index -= 2;
                self.index -= 1;
            } else {
                self.index--;
            }
        }
        
        [self.nextBtn setEnabled:YES];
        if (self.index == 0) {
            [self.prevBtn setEnabled:NO];
        }
    } else {
        [self.prevBtn setEnabled:NO];
    }
    
    if (self.isReviewed) {
        self.equipmentReviewed = [self.reviews objectAtIndex:self.index];
    } else {
        self.equipment = [self.used objectAtIndex:self.index];
    }
    [self loadObject];
    [self.tableView reloadData];

    [self updateCountTitle];
}

-(void)updateCountTitle {
    NSInteger total = 0;
    if (self.isReviewed) {
        total = self.reviews.count;
    } else {
        total = self.used.count;
    }

    NSInteger formattedIndex = 0;
    if (total) {
        formattedIndex = self.index + 1;
        if (formattedIndex > total) {
            formattedIndex = total;
        }
    }
    
    [self.countBtn setTitle:[NSString stringWithFormat:@"%d/%d", (int)formattedIndex, (int)total]];
}

-(NSArray*)getEquipment{
    if (self.isReviewed) {
        return self.reviews;
    } else {
        return self.used;
    }
}

-(IBAction)nextButtonPressed:(id)sender {
    if (self.index < ([self getEquipment].count - 1)) {
        self.index ++;
        [self.prevBtn setEnabled:YES];
        if (self.index == ([self getEquipment].count - 1)) {
            [self.nextBtn setEnabled:NO];
        }
    } else {
        [self.nextBtn setEnabled:NO];
    }
    
    if (self.isReviewed) {
        self.equipmentReviewed = [self.reviews objectAtIndex:self.index];
    } else {
        self.equipment = [self.used objectAtIndex:self.index];
    }
    [self loadObject];
    [self.tableView reloadData];
    [self updateCountTitle];
}

-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)createOrUpdateRecord {
    
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    
    if (self.isReviewed) {
        if (!self.equipmentReviewed) {
            self.equipmentReviewed = (TrainingEquipmentReviewed*)[[self aggregate] createNewObject];
            self.equipmentReviewed.dateTime = [NSDate date];
        }
        
        for (NSString *field in self.fields) {
            id val = [self.values objectForKey:field];
            if (val) {
                if ([self.switchFields containsObject:field]) {
                    [self.equipmentReviewed setValue:[self getBooleanFromValue:val] forKey:field];
                } else {
                    [self.equipmentReviewed setValue:val forKey:field];
                }
            }
        }
        
        self.equipmentReviewed.studentLastName = self.student.surname;
        self.equipmentReviewed.studentFirstName = self.student.firstname;
        self.equipmentReviewed.studentDriverLicenseState = self.student.driverLicenseState;
        self.equipmentReviewed.studentDriverLicenseNumber = self.student.driverLicenseNumber;
        self.equipmentReviewed.employeeId = self.student.employeeNumber;
        
        self.equipmentReviewed.instructorLastName = self.instructor.surname;
        self.equipmentReviewed.instructorFirstName = self.instructor.firstname;
        self.equipmentReviewed.instructorEmployeeId = self.instructor.employeeNumber;
        
        // link to the "parent" Training Test Info record
        self.equipmentReviewed.parentMobileRecordId = parentMobileRecordId;
        
        [[self aggregate] createNewRecord:self.equipmentReviewed];
    } else {
                
        if (!self.equipment) {
            self.equipment = (TrainingEquipment*)[[self aggregate] createNewObject];
            self.equipment.dateTime = [NSDate date];
        }
    
        for (NSString *field in self.fields) {
            id val = [self.values objectForKey:field];
            if (val) {
                if ([self.switchFields containsObject:field]) {
                    [self.equipment setValue:[self getBooleanFromValue:val] forKey:field];
                } else {
                    [self.equipment setValue:val forKey:field];
                }
            }
        }
    
        self.equipment.studentLastName = self.student.surname;
        self.equipment.studentFirstName = self.student.firstname;
        self.equipment.studentDriverLicenseState = self.student.driverLicenseState;
        self.equipment.studentDriverLicenseNumber = self.student.driverLicenseNumber;
        self.equipment.employeeId = self.student.employeeNumber;
    
        self.equipment.instructorLastName = self.instructor.surname;
        self.equipment.instructorFirstName = self.instructor.firstname;
        self.equipment.instructorEmployeeId = self.instructor.employeeNumber;
        
        // link to the "parent" Training Test Info record
        self.equipment.parentMobileRecordId = parentMobileRecordId;
    
        [[self aggregate] createNewRecord:self.equipment];
    }
    
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
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.isReviewed) {
        return nil;
    }
    
    if (section == 2) {
        return @"Power Unit";
    }
    
    if (section == 9) {
        return @"Combination Vehicle - Train or Chain";
    }

    if (section == 17) {
        return @"Vehicle Numbers";
    }
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
    if (self.isReviewed) {
        return 0;
    }
    
    if (section == 2) {
        return 40;
    }
    
    if (section == 9) {
        return 40;
    }

    if (section == 17) {
        return 40;
    }
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
    } else if ([key isEqualToString:Key_Company]) {
           if ([object isKindOfClass:[TrainingCompany class]]) {
               self.company = (TrainingCompany*)object;
               if (self.company.name) {
                   // 22.10.2019 we should check if the "company name" is the same as "student company name" if not then we should reset the student
                   if (self.student) {
                       if (![[self.student.company lowercaseString] isEqualToString:[self.company.name lowercaseString]]) {
                           [self resetEquipmentFields];
                           self.student = nil;
                       }
                   }
                   [self.values setObject:self.company.name forKey:key];
               }
           }
    } else if ([key isEqualToString:Key_Instructor]) {
        if ([object isKindOfClass:[User class]]) {
            self.instructor = (User*)object;
            if (self.instructor.employeeNumber) {
                [self.values setObject:self.instructor.employeeNumber forKey:@"instructorEmployeeId"];
            }
            
            if ([self.instructor.rcoRecordId length]) {
                [Settings setSetting:self.instructor.rcoRecordId forKey:CSD_PREV_INSTRUCTOR];
                [Settings save];
            }
        }
    } else if ([key isEqualToString:Key_Student]) {
        if ([object isKindOfClass:[User class]]) {
            [self resetEquipmentFields];
            self.student = (User*)object;
            
            if ([self.student.rcoRecordId length]) {
                [Settings setSetting:self.student.rcoRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            } else if ([self.student.rcoMobileRecordId length]) {
                [Settings setSetting:self.student.rcoMobileRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            }
            
            // populate the student coding fields
            if (self.student.employeeNumber) {
                [self.values setObject:self.student.employeeNumber forKey:@"employeeId"];
            }
            if (self.student.driverLicenseNumber) {
                [self.values setObject:self.student.driverLicenseNumber forKey:@"studentDriverLicenseNumber"];
            }
            if (self.student.driverLicenseState) {
                [self.values setObject:self.student.driverLicenseState forKey:@"studentDriverLicenseState"];
            }

            if (self.student.company) {
                [self.values setObject:self.student.company forKey:@"company"];

                if (!self.company) {
                    [self loadCompanyWithName:self.student.company];
                }
            }
        }
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
    if (self.isReviewed) {
        return [[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipmentReviewed"];
    } else {
        return [[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"];
    }
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:SET_EQUIPMENT_REVIEWED] || [message isEqualToString:EQU]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
        [self loadEquipmentReviews];
        [self loadCodingFields];
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObject:self.equipment forKey:self.addDelegateKey];
        }

        if (self.isReviewed) {
            [self loadEquipmentReviews];
        } else {
            [self loadEquipmentUsed];
        }
        [self updateCountTitle];
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    //NSString *errorMessage = [messageInfo objectForKey:@"errorMessage"];
    NSString *message = [messageInfo objectForKey:@"message"];
   
    if ([message isEqualToString:SET_EQUIPMENT_REVIEWED] || [message isEqualToString:EQU]) {
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

#pragma Mark CSD Selection Protocol

-(void)CSDInfoDidSelectObject:(NSString *)parentMobileRecordId {
    NSLog(@"%@", parentMobileRecordId);
    [self loadPrevStudent];
    [self loadPrevInstructor];

    [self loadEquipmentReviews];
    [self loadEquipmentUsed];
    [self loadCodingFields];

    [self loadObject];
    [self.tableView reloadData];
}

-(void)CSDInfoDidSavedObject:(NSString *)parentMobileRecordId {
    NSLog(@"");
}

-(BOOL)CSDInfoCanSelectScreen {
    return !self.needsToSave;
}

-(NSString*)CSDInfoScreenTitle{
    if (self.isReviewed) {
        return @"Equipment Reviewed";
    } else {
        return @"Equipment Used";
    }
}

-(void)CSDSaveRecordOnServer:(BOOL)onServer {
    [self saveButtonPressed:nil];
}

@end
