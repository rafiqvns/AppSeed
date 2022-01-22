//
//  CSDTestInfoViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/2019.
//  Copyright (c) 2019 RCO. All rights reserved.
//

#import "CSDTestInfoViewController.h"
#import "InputCellWithId.h"
#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"
#import "RCOValuesListViewController.h"
#import "NSDate+TKCategory.h"
#import "SignatureViewController.h"
#import "SignatureDetailAggregate.h"
#import "SignatureDetail.h"
#import "NotesAggregate.h"
#import "Note+CoreDataClass.h"
#import "NSDate+Misc.h"
#import "TrainingInstructor+CoreDataClass.h"
#import "TrainingStudent+CoreDataClass.h"

#import "TrainingDriverStudentAggregate.h"
#import "TrainingDriverInstructorAggregate.h"

#import "TrainingCompany+CoreDataClass.h"
#import "TrainingCompanyAggregate.h"
#import "Settings.h"
#import "TrainingTestInfo+CoreDataClass.h"
#import "TrainingTestInfoAggregate.h"
#import "CSDTestSelectObject.h"

#import "UserAggregate.h"
#import "User_Imp.h"
#import "UserGroupsListViewController.h"
#import "AttachmentAggregate.h"
#import "Attachment+CoreDataClass.h"

#import "TrainingBreakLocation+CoreDataClass.h"
#import "TrainingBreakLocationAggregate.h"

#define Key_Class @"driverLicenseClass"
#define Key_State @"driverLicenseState"
#define Key_Student @"employeeId"
#define Key_Instructor @"instructorEmployeeId"
#define Key_Company @"company"
#define Key_Endorsements @"endorsements"
#define Key_CurrentSection @"currentSection"


#define KeyStartDateTime @"startDateTime"
#define KeyEndDateTime @"endDateTime"
#define KEY_Group @"group"


#define TAG_EVENT_BREAK -9875

#define TEST_PAUSED 1
#define TEST_NOT_PAUSED -1


@interface CSDTestInfoViewController ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *fieldsNA;
@property (nonatomic, strong) NSArray *typeOfTraining;
@property (nonatomic, strong) NSArray *typeOfTrainingNames;

@property (nonatomic, strong) NSArray *reason;
@property (nonatomic, strong) NSArray *reasonNames;

@property (nonatomic, strong) NSArray *fieldsNames;
@property (nonatomic, strong) NSArray *fieldsNamesShort;

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *percentageFields;
@property (nonatomic, strong) NSArray *numericFields;

@property (nonatomic, strong) NSArray *datePickerFieldsNames;

@property (nonatomic, strong) NSDate *dateTime;
@property (nonatomic, strong) NSDate *driverLicenseExpirationDate;
@property (nonatomic, strong) NSDate *dotExpirationDate;
@property (nonatomic, strong) User *student;
@property (nonatomic, strong) User *instructor;
@property (nonatomic, strong) TrainingCompany *company;
@property (nonatomic, strong) TrainingTestInfo *testInfo;
@property (nonatomic, strong) UIAlertController *al;

@property (nonatomic, assign) BOOL isEnded;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *pauseBtn;
@property (nonatomic, strong) UIBarButtonItem *previewBtn;

@property (nonatomic, strong) NSDate *pausedDate;
@property (nonatomic, strong) NSArray *endorsements;

@property (nonatomic, assign) BOOL useNADefault;
@property (nonatomic, assign) BOOL autoSaveEnabled;
@property (nonatomic, assign) BOOL needsToSave;
@property (nonatomic, assign) BOOL isDrivingSchool;
@property (nonatomic, assign) BOOL searchStudentLastTest;
@property (nonatomic, assign) BOOL isAddingNewTest;
@property (nonatomic, assign) BOOL setStartDateTime;

@property (nonatomic, assign) BOOL useNewLogic;

@property (nonatomic, strong) NSIndexPath *studentIndexPath;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupNumber;

@end

@implementation CSDTestInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.useNADefault = YES;
    self.isDrivingSchool = [[Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL] boolValue];
    
    if (self.isDrivingSchool) {
        self.autoSaveEnabled = NO;
    } else {
        self.autoSaveEnabled = YES;
    }
    
    self.groupName = [Settings getSetting:CSD_TEST_GROUP_NAME];
    if (self.groupName.length) {
        [self.groupBtn setTitle:self.groupName];
    }
        
    self.groupNumber = [Settings getSetting:CSD_TEST_GROUP_RECORDID];

    self.previewBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Preview", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(emailButtonPressed:)];
    
    self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                 target:self
                                                                 action:@selector(saveButtonPressed:)];
    [self.saveBtn setEnabled:NO];

    //07.01.2020 we need to add pause button for driving schools
    self.pauseBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                  target:self
                                                                  action:@selector(pauseButtonPressed:)];
    
    
    self.fieldsNA = [NSArray arrayWithObjects:@"dotExpirationDate", nil];
    
    self.fields = [NSArray arrayWithObjects: @"dateTime", @"company", @"employeeId", @"driverLicenseExpirationDate", @"driverLicenseNumber", @"driverLicenseState",  @"driverHistoryReviewed", @"driverLicenseClass", @"endorsements", @"dotExpirationDate", KeyStartDateTime, KeyEndDateTime,  @"evaluationLocation", @"correctiveLensRequired", @"restrictions", @"instructorEmployeeId", @"comments", nil];

    self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Company", @"Student", @"Driver License Expiration Date", @"Driver License Number", @"Driver License State", @"History Reviewed", @"Class", @"Endorsements", @"DOT Expiration Date", @"Start Time", @"End Time", @"Location", @"Corrective Lens Required", @"Restrictions", @"Instructor", @"Comments", @"Select the type of training completed", @"Select the reason for training and enter dates if applicable", nil];
    
    self.typeOfTraining = [NSArray arrayWithObjects:@"trainingEquipment", @"trainingPreTrip", @"trainingBehindTheWheel", @"trainingEye", @"trainingSWP", @"trainingProd", @"trainingVRT", @"trainingPassengerEvacuation", @"trainingPassengerPreTrip", nil];
    self.typeOfTrainingNames = [NSArray arrayWithObjects:@"Equipment", @"Pre/Trip - Post/Trip", @"Behind the Wheel", @"Eye Movement", @"Safe Work Practice", @"Production", @"Vehicle Road Test", @"Passenger Evacuation", @"Passenger Pre/Trip",  nil];

    self.reason = [NSArray arrayWithObjects:@"trainingNewHire", @"trainingNearMiss", @"trainingIncidentFollowUp", @"trainingChangeJob", @"trainingChangeOfEquipment", @"trainingAnnual", @"trainingInjuryDate", @"trainingAccidentDate", @"trainingTAWStartDate", @"trainingTAWEndDate", @"trainingLostTimeStartDate", @"trainingReturnToWorkDate",  nil];
    self.reasonNames = [NSArray arrayWithObjects:@"New Hire", @"Near Miss", @"Incident Follow-up", @"Change Job", @"Change of Equipment", @"Annual", @"Injury Date", @"Accident Date", @"TAW Start Date", @"TAW End Date", @"Lost Time Start Date", @"Return to Work Date",  nil];

    self.values = [NSMutableDictionary dictionary];
    
    self.datePickerFieldsNames = [NSArray arrayWithObjects:@"dateTime", @"driverLicenseExpirationDate", @"dotExpirationDate", @"trainingInjuryDate", @"trainingAccidentDate", @"trainingTAWStartDate", @"trainingTAWEndDate", @"trainingLostTimeStartDate", @"trainingReturnToWorkDate", nil];
    self.switchFields = [NSArray arrayWithObjects:@"driverHistoryReviewed", @"correctiveLensRequired", @"trainingPreTrip", @"trainingBehindTheWheel", @"trainingEye", @"trainingSWP", @"trainingNewHire", @"trainingNearMiss", @"trainingIncidentFollowUp", @"trainingChangeJob", @"trainingChangeOfEquipment", @"trainingAnnual",@"trainingEquipment", @"trainingProd", @"trainingVRT", @"trainingPassengerEvacuation", @"trainingPassengerPreTrip", nil];
    self.numericFields = nil;
    
    self.pickerFields = [NSArray arrayWithObjects: @"company", @"employeeId", @"endorsements", @"instructorEmployeeId", @"driverLicenseClass", @"driverLicenseState",nil];

    self.requiredFields = [NSArray arrayWithObjects:@"dateTime", @"company", @"driverLicenseExpirationDate", @"instructorEmployeeId", @"driverLicenseState", @"driverLicenseNumber", nil];
    
    self.endorsements = [NSArray arrayWithObjects:@"NA", @"(P) Passenger Transport Endorsement", @"(S) School Bus/Passenget Transport Combo Endorsement", @"(T) Double/Triples Endorsement", @"(N) Tank Vehicle Endorsement", @"(H) Hazardous Materials Endorsement (HAZMAT)", @"(X) Tanke/HZMAT Combo Endorsement", nil];
    
    [self loadObject];
    
    if (self.testInfo.startDateTime) {
        [self.startBtn setEnabled:NO];
        [self.stopBtn setEnabled:YES];
    } else {
        [self.startBtn setEnabled:YES];
        [self.stopBtn setEnabled:NO];
    }
    
    if (self.testInfo.endDateTime) {
        [self.startBtn setEnabled:NO];
        [self.stopBtn setEnabled:NO];
    }
    
    if (self.isDrivingSchool) {
        if (self.testInfo && ([self.testInfo isPaused] || !self.testInfo.startDateTime)) {
            [self.startBtn setEnabled:YES];
            [self.stopBtn setEnabled:NO];
        }
    }
    
    if (self.isDrivingSchool) {
        UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                   target:self
                                                                                   action:@selector(actionButtonPressed:)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveBtn, actionBtn, nil];
    }
}

-(IBAction)actionButtonPressed:(id)sender {
    
    TrainingBreakLocationAggregate *agg = (TrainingBreakLocationAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingBreakLocation"];
    //06.04.2020 we should load: breaks that are saved or not on the server
    
    NSArray *events = [agg getBreaksForTestMobileRecordId:self.testInfo.rcoMobileRecordId orTestBarcode:self.testInfo.rcoBarcode];
    NSMutableArray *infos = [NSMutableArray array];
    for (TrainingBreakLocation *ev in events) {
        NSString *msg = [NSString stringWithFormat:@"From: %@\nTo:%@", [ev rcoDateTimeString:ev.startDateTime], [ev rcoDateTimeString:ev.endDateTime]];
        [infos addObject:msg];
    }
    [self showSimpleMessage:[infos componentsJoinedByString:@"\n\n"] andTitle:@"Breaks"];
}

-(void)loadPrevInstructor{
    NSString *prevInstructorRecordId = [Settings getSetting:CSD_PREV_INSTRUCTOR];
    BOOL saveCurrentUser = NO;
    if (prevInstructorRecordId.length == 0) {
        // 13.01.2020 we should search to see if the current logged use is a instructor or not
        NSString *currentUserRecordId = [Settings getSetting:CLIENT_USER_RECORDID_KEY];
        if (!currentUserRecordId.length) {
            return;
        }
        NSString *currentUserItemType = [Settings getSetting:USER_TYPE];
        if (!currentUserItemType.length) {
            return;
        }
        if ([currentUserItemType isEqualToString:kUserTypeInstructor]) {
            prevInstructorRecordId = currentUserRecordId;
            saveCurrentUser = YES;
        }
    }
    UserAggregate *instrAgg = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];

    self.instructor = (User*)[instrAgg getObjectWithRecordId:prevInstructorRecordId];
    if (saveCurrentUser && self.instructor.rcoRecordId.length) {
        [Settings setSetting:self.instructor.rcoRecordId forKey:CSD_PREV_INSTRUCTOR];
        [Settings save];
    }

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
    if (self.student.company) {
        [self.values setObject:self.student.company forKey:@"company"];
        [self loadCompanyWithName:self.student.company];
    }
    if (self.student.driverLicenseNumber) {
        [self.values setObject:self.student.driverLicenseNumber forKey:@"driverLicenseNumber"];
    }
    if (self.student.driverLicenseState) {
        [self.values setObject:self.student.driverLicenseState forKey:@"driverLicenseState"];
    }
    if (self.student.driverLicenseClass) {
        [self.values setObject:self.student.driverLicenseClass forKey:Key_Class];
    }
    if (self.student.correctiveLensRequired) {
        [self.values setObject:self.student.correctiveLensRequired forKey:@"correctiveLensRequired"];
    }

    if ([self.student.driverLicenseExpirationDate isKindOfClass:[NSDate class]]) {
        [self.values setObject:self.student.driverLicenseExpirationDate forKey:@"driverLicenseExpirationDate"];
        self.driverLicenseExpirationDate = self.student.driverLicenseExpirationDate;
    }
}

-(BOOL)testStarted {
    NSString *startTime = [self.values objectForKey:@"startTime"];
    if (startTime.length) {
        return YES;
    } else {
        return NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"] registerForCallback:self];
    [[self aggregate] registerForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"SignatureDetail"] registerForCallback:self];
    [[self aggregate] registerForCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"] unRegisterForCallback:self];
    [[self aggregate] unRegisterForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"SignatureDetail"] unRegisterForCallback:self];
    [[self aggregate] unRegisterForCallback:self];
    if ([self.testInfo endDateTime]) {
        // 31.01.2020 we should reste the prev student and prev test
        [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
        [Settings resetKey:CSD_TEST_INFO_START_DATE];
        [Settings resetKey:CSD_TEST_INFO_STOP_DATE];
        [Settings resetKey:CSD_TEST_INFO_END_DATE];
        [Settings resetKey:CSD_PREV_STUDENT];
        [Settings resetKey:CSD_TEST_GROUP_RECORDID];
        [[DataRepository sharedInstance] resetTrainingTestInfo];
        [Settings save];
    }
}

-(void)syncAttachment {
    if (self.testInfo.rcoRecordId) {
        AttachmentAggregate *attAgg = (AttachmentAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Attachment"];
        NSArray *atts = [attAgg getAttachmentsForObject:self.testInfo.rcoRecordId];
        if (atts.count) {
            // 31.03.2020 we have an attachment so we don't need to download anything ...
            NSLog(@"");
        } else {
            //31.03.2020 we need to get the Attachments
            [attAgg getAttachmentsForParent:self.testInfo.rcoRecordId];
        }
    }
}

-(void)loadPreviusSavedTest {
    if (self.searchStudentLastTest) {
        if (!self.student) {
            return;
        }
        // 07.01.2020 we should search the last test for selected student
        TrainingTestInfoAggregate *agg = (TrainingTestInfoAggregate*)[self aggregate];
        
        self.testInfo = [agg getMostRecentTestForDriverLicenseNumber:self.student.driverLicenseNumber
                                               andDriverLicenseState:self.student.driverLicenseState];
        if (self.testInfo.rcoMobileRecordId.length) {
            [Settings setSetting:self.testInfo.rcoMobileRecordId forKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
        } else {
            [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
            [[DataRepository sharedInstance] resetTrainingTestInfo];
        }
        [Settings save];
    } else {
        // 07.01.2020 the old logic ...
        NSString *prevTestInfoMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
        if (!prevTestInfoMobileRecordId.length) {
            return;
        }
        
        self.testInfo = (TrainingTestInfo*)[[self aggregate] getObjectWithMobileRecordId:prevTestInfoMobileRecordId];
    }
    
    if (!self.testInfo) {
        // this is strange somehow the previus test was deleted
        if (self.isDrivingSchool) {
            [self addStartButton];
        }
        return;
    } else {
        [self syncAttachment];
        if (self.isDrivingSchool) {
            // we should add/enable pause/start button
            if ([self.testInfo isPaused] || !self.testInfo.startDateTime) {
                [self addStartButton];
            } else {
                [self addPauseButton];
            }
        } else {
            NSLog(@"");
            // 29.01.2020 we should enable start/stop after loading the test for selected student at the first install of the app
            if (self.testInfo.startDateTime) {
                [self.startBtn setEnabled:NO];
                [self.stopBtn setEnabled:YES];
            } else {
                [self.startBtn setEnabled:YES];
                [self.stopBtn setEnabled:NO];
            }
        }
    }
}

-(void)loadDefaultValuesForSwitches {
    if (!self.testInfo) {
        for (NSString *key in self.switchFields) {
        // 29.11.2019 we should set those to no
            [self.values setObject:@"no" forKey:key];
        }
    }
}

-(void)loadObject {
    [self loadPreviusSavedTest];
    
    self.values = [NSMutableDictionary dictionary];
    
    self.dotExpirationDate = self.testInfo.dotExpirationDate;
    
    self.dateTime = self.testInfo.dateTime;
    if (!self.dateTime) {
        self.dateTime = [NSDate date];
    }
    [self.values setObject:self.dateTime forKey:@"dateTime"];
    
    [self loadPrevInstructor];
    [self loadPrevStudent];
    [self loadDefaultValuesForSwitches];
        
    if (self.testInfo.rcoMobileRecordId) {
        [Settings setSetting:self.testInfo.rcoMobileRecordId forKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
        [Settings save];
    }

    if (self.testInfo.driverLicenseNumber.length && self.testInfo.driverLicenseState.length) {
        // we should load the stident based on driver license state and driver license number. this should be unique
        UserAggregate *studentAggregate = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
        self.student = [studentAggregate getUserWithdDriverLicenseNumber:self.testInfo.driverLicenseNumber andState:self.testInfo.driverLicenseState];
        
        if (self.student.employeeNumber) {
            [self.values setObject:self.student.employeeNumber forKey:@"employeeId"];
        }
    }
    // 14.02.2020 we shouls save in the settings these values
    if (self.testInfo.evaluationLocation) {
        [Settings setSetting:self.testInfo.evaluationLocation forKey:CSD_TEST_INFO_LOCATION];
    } else {
        [Settings resetKey:CSD_TEST_INFO_LOCATION];
    }

    if (self.testInfo.endorsements) {
        [Settings setSetting:self.testInfo.endorsements forKey:CSD_TEST_INFO_ENDORSEMENTS];
    } else {
        [Settings resetKey:CSD_TEST_INFO_ENDORSEMENTS];
    }

    if (self.testInfo.dotExpirationDate) {
        [Settings setSetting:self.testInfo.dotExpirationDate forKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    } else {
        [Settings resetKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    }

    if (self.testInfo.correctiveLensRequired) {
        [Settings setSetting:self.testInfo.correctiveLensRequired forKey:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    } else {
        [Settings resetKey:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    }
    
    [Settings save];
    
    for (NSString *field in self.fields) {
        NSString *value = [self.testInfo valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }

    for (NSString *field in self.typeOfTraining) {
        NSString *value = [self.testInfo valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }

    for (NSString *field in self.reason) {
        NSString *value = [self.testInfo valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }
    
    if (self.student.company) {
        [self loadCompanyWithName:self.student.company];
        if (!self.company) {
            [self.values removeObjectForKey:@"company"];
        } else {
            [self.values setObject:self.student.company forKey:@"company"];
        }
    }
            
    [self.tableView reloadData];
}

-(void)addPauseButton {
    if (self.testInfo.endDateTime) {
        return;
    }
    // we should replace start button with pause button
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
    NSInteger index = [items indexOfObject:self.startBtn];
    if (index != NSNotFound) {
        [items replaceObjectAtIndex:index withObject:self.pauseBtn];
        [self.bottomToolbar setItems:items];
    }
}

-(void)addStartButton {
    // we should replace pause button with start button
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
    NSInteger index = [items indexOfObject:self.pauseBtn];
    if (index != NSNotFound) {
        [items replaceObjectAtIndex:index withObject:self.startBtn];
        [self.bottomToolbar setItems:items];
    }
    [self.startBtn setEnabled:YES];
    [self.stopBtn setEnabled:NO];
}

#pragma mark Actions
-(IBAction)pauseButtonPressed:(id)sender {
    [self.testInfo addPauseDateTime:[NSDate date]];
    [Settings setSetting:[NSDate date] forKey:CSD_TEST_INFO_PAUSE_DATE];
    [[DataRepository sharedInstance] setTrainingTestInfoPaused:1];
    [Settings save];
    [self addStartButton];
    
    [self showBreakEventPopup];
    [self.stopBtn setEnabled:NO];
    // SAVE
    [self saveButtonPressed:nil];
    //22.01.2020 we should save the rests of the tests if they pause the test
    if ([self.addDelegate respondsToSelector:@selector(didSaveObject:)]) {
        [self.addDelegate didSaveObject:self.testInfo];
    }
    
    
}

-(void)showBreakEventPopup {
        self.al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Location", nil)
                                                      message:@"Notes"
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        __weak typeof(self) weakSelf = self;
        
        [self.al addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"notes";
            //textField.text = sod.quantity;
            if (@available(iOS 13,*)) {
            textField.textColor = [UIColor labelColor];
            } else {
            textField.textColor = [UIColor darkTextColor];
            }
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.tag = TAG_EVENT_BREAK;
           // [textField addTarget:weakSelf action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [textField setDelegate:weakSelf];
        }];
        
        UIAlertAction* addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               UITextField *input = self.al.textFields[0];
                                                               [self addBreakEventLocationForLocation:input.text];
                                                           }];
        [addAction setEnabled:NO];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        
        [self.al addAction:addAction];
        [self.al addAction:cancelAction];
        [self presentViewController:self.al animated:YES completion:nil];
}

-(void)endBreakEventLocation {
    TrainingBreakLocationAggregate *agg = (TrainingBreakLocationAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingBreakLocation"];
    NSArray *events = [agg getBreaksForTestMobileRecordId:self.testInfo.rcoMobileRecordId orTestBarcode:self.testInfo.rcoBarcode];
    TrainingBreakLocation *ev = [events lastObject];
    
    if (ev.endDateTime) {
        NSLog(@"This is not OK!");
    } else {
        ev.endDateTime = [NSDate date];
        double duration = [ev.endDateTime timeIntervalSince1970] - [ev.startDateTime timeIntervalSince1970];
        ev.elapsedMinutes = [NSString stringWithFormat:@"%0.1f", duration /60];
        [agg createNewRecord:ev];
    }
    NSLog(@"");
}

-(void)addBreakEventLocationForLocation:(NSString*)location {
    NSLog(@"");
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingBreakLocation"];
    TrainingBreakLocation *pauseEvent = (TrainingBreakLocation*)[agg createNewObject];
    pauseEvent.dateTime = [NSDate date];
    
    pauseEvent.rcoObjectParentId = self.testInfo.rcoMobileRecordId;
    
    //02.04.2020 this needs to be "fixed"
    
    if ([self.testInfo existsOnServerNew]) {
        pauseEvent.headerBarcode = self.testInfo.rcoBarcode;
        pauseEvent.headerObjectId = self.testInfo.rcoObjectId;
        pauseEvent.headerObjectType = self.testInfo.rcoObjectType;
    } else {
        pauseEvent.headerBarcode = nil;
        pauseEvent.headerObjectId = self.testInfo.rcoObjectId;
        pauseEvent.headerObjectType = self.testInfo.rcoObjectClass;
    }
    
    pauseEvent.title = [NSString stringWithFormat:@"%@ %@", @"Break", location];
    pauseEvent.location = location;
    pauseEvent.itemType = @"trainingBreak";
    pauseEvent.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
    pauseEvent.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
    
    pauseEvent.firstName = self.testInfo.studentFirstName;
    pauseEvent.lastName = self.testInfo.studentLastName;
    pauseEvent.driverLicenseState = self.testInfo.driverLicenseState;
    pauseEvent.driverLicenseNumber = self.testInfo.driverLicenseNumber;

    pauseEvent.instructorLastName = self.testInfo.instructorLastName;
    pauseEvent.instructorFirstName = self.testInfo.instructorFirstName;
    pauseEvent.instructorEmployeeId = self.testInfo.instructorEmployeeId;

    pauseEvent.startDateTime = [NSDate date];
    
    [agg createNewRecord:pauseEvent];
}

-(void)setTestInfoStartDateTime:(NSDate*)dateTime {
    if (!dateTime) {
        return;
    }
    [self.values setObject:dateTime forKey:KeyStartDateTime];
    [Settings setSetting:dateTime forKey:CSD_TEST_INFO_START_DATE];
    [Settings resetKey:CSD_TEST_INFO_STOP_DATE];
    [Settings resetKey:CSD_TEST_INFO_END_DATE];
    [Settings save];
}

-(IBAction)startButtonPressed:(id)sender {
    NSDate *startDateTime = [NSDate date];
    
    [Settings setSetting:startDateTime forKey:CSD_TEST_INFO_START_DATE];
    [Settings resetKey:CSD_TEST_INFO_PAUSE_DATE];
    [Settings save];
    [[DataRepository sharedInstance] setTrainingTestInfoPaused:-1];
    
    if (!self.testInfo) {
        // 07.01.2020 this is the first start
        self.setStartDateTime = YES;
    } else if (self.isDrivingSchool){
        [self.testInfo addPauseDateTime:startDateTime];
        [self endBreakEventLocation];
    } else {
        //13.01.2020 testInfo exists and is not driving school
        NSDate *start = [Settings getSettingAsDate:CSD_TEST_INFO_START_DATE];
        if (!start || ![self.values objectForKey:KeyStartDateTime]) {
            [self setTestInfoStartDateTime:startDateTime];
        }
    }
    
    self.needsToSave = YES;
    // SAVE
    [self saveButtonPressed:sender];
    if (self.setStartDateTime) {
        [self setTestInfoStartDateTime:startDateTime];
    }

    if (!self.testInfo) {
        // 10.12.2019 the creation of test info failedso we should not continue
        [self.values removeObjectForKey:KeyStartDateTime];
        self.needsToSave = NO;
        return;
    }
        
    [self.stopBtn setEnabled:YES];
    [self.startBtn setEnabled:NO];
    if (self.isDrivingSchool) {
        // 07.01.2020 we should replace the start btn with stop button
        [self addPauseButton];
    }
    
    if (self.testInfo.rcoMobileRecordId) {
        [Settings setSetting:self.testInfo.rcoMobileRecordId forKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
        [Settings save];
    }
    self.isAddingNewTest = NO;
    
    NSLog(@"Test Info %@", self.testInfo);
    
    [self.tableView reloadData];
    [self enableSaving];
}

-(IBAction)groupButtonPressed:(id)fromView {
    if (!self.company) {
        [self showSimpleMessage:@"Please select company first!"];
        return;
    }
    UserGroupsListViewController *controller = [[UserGroupsListViewController alloc] initWithNibName:@"UserGroupsListViewController" bundle:nil];
    
    controller.addDelegateKey = KEY_Group;
    controller.addDelegate = self;
    controller.isSelectMode = YES;
    controller.company = self.company.name;
    
    if (self.groupNumber) {
        controller.selectedGroupRecordId = self.groupNumber;
    }
    [self showPopoverModalForViewController:controller];
}

-(IBAction)stopButtonPressed:(id)sender {
    NSString *msg = @"Are you finished with the Class?";
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:msg
                                                         preferredStyle:UIAlertControllerStyleAlert];
        
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {

        //getSaveSignatureMessage
        if ([self.addDelegate respondsToSelector:@selector(getSaveSignatureMessage)]) {
            id res = [self.addDelegate performSelector:@selector(getSaveSignatureMessage)];
            NSLog(@"");
            NSArray *arr = (NSArray*)res;

            if ([arr count]) {
                [self showSimpleMessage:[NSString stringWithFormat:@"Please sign the following tests:\n%@", [arr componentsJoinedByString:@"\n"]]];
            } else {
                [self.stopBtn setEnabled:NO];
                [self.startBtn setEnabled:NO];
                [self.pauseBtn setEnabled:NO];
                self.needsToSave = YES;
                NSDate *stopDateTime = [NSDate date];
                self.testInfo.endDateTime = stopDateTime;
                [self.values setObject:stopDateTime forKey:KeyEndDateTime];
                [Settings setSetting:stopDateTime forKey:CSD_TEST_INFO_STOP_DATE];
                [Settings save];

                [self.tableView reloadData];
                [self enableSaving];
            }
        }
    }];
        
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                            }];
        
    [al addAction:noAction];
    [al addAction:yesAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(IBAction)addButtonPressed:(id)sender {
    if (self.saveBtn.enabled) {
        NSString *msg = @"Current Class is not saved and changes will be lost. Do you want to continue?";
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
            self.isAddingNewTest = YES;
            [self resetTest];
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                style:UIAlertActionStyleCancel
                                                                handler:^(UIAlertAction * action) {
                                                            }];
        
        [al addAction:cancelAction];
        [al addAction:yesAction];
        [self presentViewController:al animated:YES completion:nil];
    } else {
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:@"Add new Class?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
            [self resetTest];
        }];
    
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                            }];
    
        [al addAction:cancelAction];
        [al addAction:yesAction];
        [self presentViewController:al animated:YES completion:nil];
    }
}

-(void)resetTest {
    self.values = [NSMutableDictionary dictionary];
    self.dateTime = [NSDate date];
    [self.values setObject:self.dateTime forKey:@"dateTime"];
    self.testInfo = nil;
    self.driverLicenseExpirationDate = nil;
    self.dotExpirationDate = nil;
    self.student = nil;
    self.instructor = nil;
    self.company = nil;
    [self loadDefaultValuesForSwitches];
    [self.tableView reloadData];
    [self.saveBtn setEnabled:NO];
    [self addStartButton];
    [self.startBtn setEnabled:YES];
    [self.stopBtn setEnabled:NO];
    self.needsToSave = NO;

    [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
    [Settings resetKey:CSD_TEST_PAUSED_DATE];
    
    [Settings resetKey:CSD_TEST_INFO_START_DATE];
    [Settings resetKey:CSD_TEST_INFO_STOP_DATE];
    [Settings resetKey:CSD_PREV_INSTRUCTOR];
    [Settings resetKey:CSD_PREV_STUDENT];
    [[DataRepository sharedInstance] resetTrainingTestInfo];

    [Settings save];
    /*
     12.11.2019 should we post the notification to reload or not?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetCSDTest" object:nil];
     */
}

-(IBAction)infoButtonPressed:(id)sender {
    NSString *msg = @"Scores reflect what the instructor needed to insure the drivers demonstration and understanding of each element\n\n5 = No correction with no reinforcement\n\n4 = Reinforced understanding\n\n3 = Corrected and reinforced understanding\n\n2 = Multiple corrections needed until demonstrated correctly, reinforced understanding\n\n1 = unacceptable or critical error, driver failed to demonstrate element correctly or failed to convey understanding\n\nNA = Element was not applicable";
    [self showSimpleMessage:msg];
}

-(NSString*)getCurrentTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    return dateStr;
}

-(IBAction)cancelButtonPressed:(id)sender {
    if (self.saveBtn.enabled) {
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:@"Test is not saved. Changes will be lost. Do you want to continue?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                                                                   [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
                                                               }
                                                           }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        
        [al addAction:cancelAction];
        [al addAction:yesAction];
        [self presentViewController:al animated:YES completion:nil];
    } else {
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
        }
    }
}

-(IBAction)saveButtonPressed:(id)sender {
    
    NSString *message = [self validateInputs];
    if (message) {
        if (sender) {
            [self showSimpleMessage:message];
        } else {
            NSLog(@"");
        }
        return;
    }
    
    if(!self.student) {
        if (sender) {
            [self showSimpleMessage:@"Please select Student!"];
        } else {
            NSLog(@"");
        }
        return;
    }

    if(!self.instructor) {
        if (sender) {
            [self showSimpleMessage:@"Please select Instructor!"];
        } else {
            NSLog(@"");
        }
        return;
    }
    
    if (sender == self.saveBtn) {
        //10.12.2019 we should show the spinner just in the case when we tap on the button not when is called with nil argument
        if (self.testInfo) {
            self.progressHUD.labelText = @"Update Form...";
        } else {
            self.progressHUD.labelText = @"Create Form...";
        }
        
        self.progressHUD.labelText = @"Saving Class...";

        [self.view addSubview:self.progressHUD];
        [self.progressHUD show:YES];
        [self performSelector:@selector(createRecord:) withObject:nil afterDelay:0.1];
    } else {
        [self createRecord:nil];
    }
    
}

-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)createRecord:(NSNumber*)isAutoSave {
    if (!self.testInfo) {
        self.testInfo = (TrainingTestInfo*)[[self aggregate] createNewObject];
        self.testInfo.dateTime = [NSDate date];
        if (self.setStartDateTime) {
            NSDate *startDateTime = [Settings getSettingAsDate:CSD_TEST_INFO_START_DATE];
            [self.values setObject:startDateTime forKey:KeyStartDateTime];
            self.setStartDateTime = NO;
        }
        
        [Settings resetKey:CSD_TEST_INFO_STOP_DATE];
        [Settings resetKey:CSD_TEST_INFO_END_DATE];
        [Settings save];
    }
    
    if (self.testInfo.endDateTime) {
        // 27.04.2020 ugly fix to make sute we are not reseting the enddateTime
        NSDate *endDateTime = [self.values objectForKey:KeyEndDateTime];
        if (!endDateTime) {
            [self.values setObject:self.testInfo.endDateTime forKey:KeyEndDateTime];
        }
        NSLog(@"");
    }
    
    for (NSString *field in self.fields) {
        id val = [self.values objectForKey:field];
        if (val) {
            if ([self.switchFields containsObject:field]) {
                [self.testInfo setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [self.testInfo setValue:val forKey:field];
            }
        }
    }

    for (NSString *field in self.typeOfTraining) {
        id val = [self.values objectForKey:field];
        if (val) {
            if ([self.switchFields containsObject:field]) {
                [self.testInfo setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [self.testInfo setValue:val forKey:field];
            }
        }
    }

    for (NSString *field in self.reason) {
        id val = [self.values objectForKey:field];
        if (val) {
            if ([self.switchFields containsObject:field]) {
                [self.testInfo setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [self.testInfo setValue:val forKey:field];
            }
        }
    }
    
    self.testInfo.studentLastName = self.student.surname;
    self.testInfo.studentFirstName = self.student.firstname;
    self.testInfo.driverLicenseState = self.student.driverLicenseState;
    self.testInfo.driverLicenseNumber = self.student.driverLicenseNumber;
    self.testInfo.driverLicenseClass = self.student.driverLicenseClass;

    self.testInfo.employeeId = self.student.employeeNumber;
    
    self.testInfo.instructorLastName = self.instructor.surname;
    self.testInfo.instructorFirstName = self.instructor.firstname;
    self.testInfo.instructorEmployeeId = self.instructor.employeeNumber;
    
    NSArray *positions = [[DataRepository sharedInstance] getTrainingTestInfoLog];
    
    NSLog(@"Positions = %@", positions);
    
    // 30.03.2020 should we reset this flag here?
    [self addAttachment];
    [[DataRepository sharedInstance] resetTrainingTestInfo];
    
    NSString *groupName =  [Settings getSetting:CSD_TEST_GROUP_NAME];
    NSString *groupNumber =  [Settings getSetting:CSD_TEST_GROUP_RECORDID];

    if (!self.testInfo.groupName.length && (groupName.length && groupNumber.length) ) {
        self.testInfo.groupName = groupName;
        self.testInfo.groupNumber = groupNumber;
    }
    
    if (self.testInfo.rcoMobileRecordId.length) {
        [Settings setSetting:self.testInfo.rcoMobileRecordId forKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
        [Settings setSetting:[[NSDate date] dateAsDateWithoutTime] forKey:CSD_TEST_INFO_MOBILE_RECORD_ID_DATE];
        [Settings save];
    }
    
    if (self.testInfo.endorsements.length) {
        [Settings setSetting:self.testInfo.endorsements forKey:CSD_TEST_INFO_ENDORSEMENTS];
    } else {
        [Settings resetKey:CSD_TEST_INFO_ENDORSEMENTS];
    }

    if (self.testInfo.evaluationLocation.length) {
        [Settings setSetting:self.testInfo.evaluationLocation forKey:CSD_TEST_INFO_LOCATION];
    } else {
        [Settings resetKey:CSD_TEST_INFO_LOCATION];
    }

    if (self.testInfo.dotExpirationDate) {
        [Settings setSetting:self.testInfo.dotExpirationDate forKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    } else {
        [Settings resetKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    }

    [Settings save];
    [self saveStudentExtraInfos];
    self.testInfo.elapsedTime = [self.testInfo calculateElaspsedTime];
    [[self aggregate] save];
    
    for (UIViewController *v in self.listeners) {
        if ([v respondsToSelector:@selector(CSDInfoDidSavedObject:)]) {
            [v performSelector:@selector(CSDInfoDidSavedObject:) withObject:self.testInfo.rcoMobileRecordId];
        }
    }
    
    [[self aggregate] createNewRecord:self.testInfo];
    [self.saveBtn setEnabled:NO];
    self.needsToSave = NO;
}

-(void)addAttachment {
    AttachmentAggregate *agg = (AttachmentAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Attachment"];
    NSArray *atts = nil;
    NSString *parentRecordId = nil;
    
    if ([self.testInfo existsOnServerNew]) {
        parentRecordId = self.testInfo.rcoRecordId;
    } else {
        parentRecordId = self.testInfo.rcoMobileRecordId;
    }
    atts = [agg getAttachmentsForObject:parentRecordId];

    Attachment *att = nil;
    if (atts.count) {
        att = [atts objectAtIndex:0];
    } else {
        att = (Attachment*)[agg createNewObject];
        att.dateTime = [NSDate date];
        att.parentBarcode = parentRecordId;
    }
    /*
     [agg appendObjectContent:eld dataString:csvString];

     */
    
    att.name = @"Route.csv";
    att.title = @"Training Route Content";
    // 31.03.2020 we need a link to the Student
    att.title = [NSString stringWithFormat:@"%@_%@", self.testInfo.driverLicenseNumber, self.testInfo.driverLicenseState];
    att.itemType = @"attachment";
    
    if ([self.testInfo existsOnServerNew]) {
        att.parentBarcode = self.testInfo.rcoRecordId;
        att.parentObjectId = self.testInfo.rcoObjectId;
        att.parentObjectType = self.testInfo.rcoObjectType;
    }

    NSArray *pos = [[DataRepository sharedInstance] getTrainingTestInfoLog];
    if (pos.count) {
        NSString *str = [pos componentsJoinedByString:@"\n"];
        str = [NSString stringWithFormat:@"%@\n", str];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [agg appendObjectContent:att data:data];
    }
    [agg createNewRecord:att];
}

-(void)saveStudentExtraInfos {

    if (self.testInfo.endorsements) {
        [Settings setSetting:self.testInfo.endorsements forKey:CSD_TEST_INFO_ENDORSEMENTS];
    } else {
        [Settings resetKey:CSD_TEST_INFO_ENDORSEMENTS];
    }
    if (self.testInfo.evaluationLocation) {
        [Settings setSetting:self.testInfo.evaluationLocation forKey:CSD_TEST_INFO_LOCATION];
    } else {
        [Settings resetKey:CSD_TEST_INFO_LOCATION];
    }

    if (self.testInfo.endorsements) {
        [Settings setSetting:self.testInfo.endorsements forKey:CSD_TEST_INFO_ENDORSEMENTS];
    } else {
        [Settings resetKey:CSD_TEST_INFO_ENDORSEMENTS];
    }
    if (self.testInfo.powerUnit) {
        [Settings setSetting:self.testInfo.powerUnit forKey:CSD_TEST_INFO_POWER_UNIT];
    } else {
        [Settings resetKey:CSD_TEST_INFO_POWER_UNIT];
    }
    if (self.testInfo.dotExpirationDate) {
        [Settings setSetting:self.testInfo.dotExpirationDate forKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    } else {
        [Settings resetKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    }
    if (self.testInfo.driverHistoryReviewed) {
        [Settings setSetting:self.testInfo.driverHistoryReviewed forKey:CSD_TEST_INFO_HISTORY_REVIEWED];
    } else {
        [Settings resetKey:CSD_TEST_INFO_HISTORY_REVIEWED];
    }
    if (self.testInfo.correctiveLensRequired) {
        [Settings setSetting:self.testInfo.correctiveLensRequired forKey:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    } else {
        [Settings resetKey:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    }
    if (self.testInfo.driverLicenseClass) {
        [Settings setSetting:self.testInfo.driverLicenseClass forKey:CSD_TEST_INFO_LICENSE_CLASS];
    } else {
        [Settings resetKey:CSD_TEST_INFO_LICENSE_CLASS];
    }

    [Settings save];
}

#pragma mark Reset Keys

-(void)resetStudentExtraInfos {
    [Settings resetKey:CSD_TEST_INFO_ENDORSEMENTS];
    [Settings resetKey:CSD_TEST_INFO_POWER_UNIT];
    [Settings resetKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    [Settings resetKey:CSD_TEST_INFO_HISTORY_REVIEWED];
    [Settings resetKey:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    [Settings resetKey:CSD_TEST_INFO_LICENSE_CLASS];

    [Settings save];
}

-(void)resetPrevInstructor {
    [Settings resetKey:CSD_PREV_INSTRUCTOR];
    [Settings save];
}

-(void)resetPrevStudent {
    [Settings resetKey:CSD_PREV_STUDENT];
    [Settings save];
}

-(IBAction)deleteButtonPressed:(id)sender {
}

-(void)deleteCurrentItem  {
    /*
    [[self aggregate] destroyObj:self.prospect];
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
    */
}

-(NSString*)validateInputs {
    
    if (!self.student) {
        return @"Student is not set!";
    }
    
    for (NSString *key in self.requiredFields) {
        NSObject *obj = [self.values objectForKey:key];
        if (!obj) {
            //get the coding field name
            NSInteger index = [self.fields indexOfObject:key];
            NSString *fieldName = [self.fieldsNames objectAtIndex:index];
            NSString *message = [NSString stringWithFormat:@"%@ is not set!", fieldName];
            return message;
        }
    }
    return nil;
}

#pragma mark UITableView methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}

-(void)deleteItem:(id)itemToDelete {
    
    if (!itemToDelete) {
        return;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == (self.fieldsNames.count -1)) {
        
        NSLog(@"Reasons %@", self.reason);
        
        return self.reason.count;
        
        
        
        
    } else if (section == (self.fieldsNames.count -2)) {
        NSLog(@"field %@", self.fieldsNames);
        return self.typeOfTraining.count;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fieldsNames.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < self.fields.count) {
        NSString *key = [self.fields objectAtIndex:section];
        if ([self.switchFields containsObject:key]) {
            return nil;
        }
    }
    NSString *sectionName = [self.fieldsNames objectAtIndex:section];
    return sectionName;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [TrainingTestInfo lightColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}


-(NSString*)getKeyForIndexPath:(NSIndexPath*)indexPath {
    NSString *key = nil;
    
    if (indexPath.section == (self.fieldsNames.count -2)) {
        key = [self.typeOfTraining objectAtIndex:indexPath.row];
    } else if (indexPath.section == (self.fieldsNames.count -1)) {
        key = [self.reason objectAtIndex:indexPath.row];
    } else {
        key = [self.fields objectAtIndex:indexPath.section];
    }
    return key;
}

-(NSString*)getLabelForIndexPath:(NSIndexPath*)indexPath {
    NSString *key = nil;
    
    if (indexPath.section == (self.fieldsNames.count -2)) {
        key = [self.typeOfTrainingNames objectAtIndex:indexPath.row];
    } else if (indexPath.section == (self.fieldsNames.count -1)) {
        key = [self.reasonNames objectAtIndex:indexPath.row];
    } else {
        key = [self.fieldsNames objectAtIndex:indexPath.section];
    }
    return key;
}

-(id)getNAValue:(id)value forKey:(NSString*)key {
    if (value) {
        return value;
    }
    if ([self.fieldsNA containsObject:key]) {
        return @"NA";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = nil;
    NSString *value = nil;
    
    key = [self getKeyForIndexPath:indexPath];
    
    value = [self.values objectForKey:[NSString stringWithFormat:@"%@", key]];
    
    // 12.05.2020 return NA for some fields that are not set
    value = [self getNAValue:value forKey:[NSString stringWithFormat:@"%@", key]];
        
    NSString *title = nil;
    NSInteger index = [self.fields indexOfObject:key];
    if (index != NSNotFound) {
        title = [self.fieldsNamesShort objectAtIndex:index];
    }
    
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
        NSString *label = [self getLabelForIndexPath:indexPath];
        
        //NSString *label = [self.fieldsNames objectAtIndex:indexPath.section];

        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"No", @"Yes", nil]];
        seg.tag = keyIndex;
        //08.11.2019 seg.selectedSegmentIndex = [value integerValue];
        seg.selectedSegmentIndex = [value boolValue];
        [seg addTarget:self
                action:@selector(segmentedControllerValueChanged:)
      forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = seg;
                        
        cell.textLabel.text = label;
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;

    } else if ([self.datePickerFieldsNames containsObject:key]) {
        NSString *identifier = nil;
        if ([self.reason containsObject:key]) {
            identifier = @"dateCell1";
        } else {
            identifier = @"dateCell";
        }

        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            if ([self.reason containsObject:key]) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
        }
        
        NSDate *date = nil;
        
        if ([key isEqualToString:@"dateTime"]) {
            date = self.dateTime;
        } else if ([key isEqualToString:@"driverLicenseExpirationDate"]) {
            date = self.driverLicenseExpirationDate;
        } else if ([key isEqualToString:@"dotExpirationDate"]) {
            date = self.dotExpirationDate;
        } else {
            date = [self.values objectForKey:key];
        }
        
        NSString *label = [self getLabelForIndexPath:indexPath];

        if ([self.reason containsObject:key]) {
            cell.textLabel.text = label;
            if (date) {
                cell.detailTextLabel.text = [[self aggregate] rcoDateToString:date];
            } else {
                cell.detailTextLabel.text = nil;
            }
        } else {
            if (date) {
                cell.textLabel.text = [[self aggregate] rcoDateToString:date];
            } else {
                if ([self.fieldsNA containsObject:key]) {
                    cell.textLabel.text = @"NA";
                } else {
                    cell.textLabel.text = nil;
                }
            }
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
        
        NSString *detailStr = nil;
        if ([key isEqualToString:Key_State]) {
            NSString *abbreviation = value;
            value = [RCOObject getStateNameForAbbreviation:abbreviation andFormatted:YES];
        } else if ([key isEqualToString:Key_Instructor]) {
            value = [self.instructor Name];
            detailStr = self.instructor.employeeNumber;
            cell.imageView.image = [UIImage imageNamed:@"INSTRUCTORS"];
         } else if ([key isEqualToString:Key_Student]) {
            value = [self.student Name];
            detailStr = self.student.employeeNumber;
            cell.imageView.image = [UIImage imageNamed:@"STUDENTS"];
         } else {
             cell.imageView.image = nil;
         }
        
        cell.textLabel.text = value;
        cell.detailTextLabel.text = detailStr;
        
        if (value) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = requiredLbl;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    
    return [self configureInputCellForTableView:theTableView
                          cellForRowAtIndexPath:indexPath
                                       forValue:value
                                            key:key
                                       andTitle:title
                                      isRequire:requiredField
                                    placeholder:nil];
}

- (UITableViewCell *)configureInputCellForTableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forValue:(NSString*)value key:(NSString*)key andTitle:(NSString*)title isRequire:(BOOL)requiredField placeholder:(NSString*)placeholder{
    // we have input cell
    InputCellWithId *inputCell = nil;
    
    inputCell = (InputCellWithId*)[theTableView dequeueReusableCellWithIdentifier:@"InputCellWithId"];
    
    if (inputCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InputCellWithId"
                                                     owner:self
                                                   options:nil];
        inputCell = (InputCellWithId *)[nib objectAtIndex:0];
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [NSString stringWithFormat:@"%@", value];
    } else if ([value isKindOfClass:[NSDate class]]) {
        NSDate *d = (NSDate*)value;
        value = [NSString stringWithFormat:@"%@", [[self aggregate] rcoTimeHHmmssToString:d]];
    }
    
    //configure input
    CGRect frame = inputCell.titleLabel.frame;
    // hide title label
    frame.size.width = 0;
    inputCell.titleLabel.frame = frame;
    //resize input field
    frame = inputCell.inputTextField.frame;
    // we should maximize the width
    
    frame.origin.x = 10;
    frame.size.width = inputCell.frame.size.width - 20;
    inputCell.inputTextField.frame = frame;
    [inputCell.requiredLabel setHidden:!requiredField];
    inputCell.inputTextField.delegate = self;
    
    [inputCell.inputTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    inputCell.inputTextField.tag = indexPath.section;
    inputCell.inputTextField.font = [UIFont boldSystemFontOfSize:19];
    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    inputCell.inputTextField.text = value;
    inputCell.inputTextField.placeholder = placeholder;
    inputCell.inputTextField.fieldId = key;
    inputCell.titleLabel.text = title;
    [inputCell.titleLabel setNumberOfLines:2];
    [inputCell.titleLabel setFont:[UIFont systemFontOfSize:13]];
    inputCell.inputTextField.inputAccessoryView = self.keyboardToolbar;
    if ([self.numericFields containsObject:key]) {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    } else {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDefault;
    }
    
    //inputCell.inputTextField.enabled = NO;
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

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.studentIndexPath = nil;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //NSInteger index = indexPath.section - (self.fields.count + self.detailsNames.count);
    NSString *key = nil;
    
    if (indexPath.section == (self.fieldsNames.count -2)) {
        key = [self.typeOfTraining objectAtIndex:indexPath.row];
    } else if (indexPath.section == (self.fieldsNames.count -1)) {
        key = [self.reason objectAtIndex:indexPath.row];
    } else {
        key = [self.fields objectAtIndex:indexPath.section];
    }
    
    if ([key isEqualToString:Key_Endorsements]) {
        [self showEndorsementsPickerFromView:cell];
    } else if ([key isEqualToString:Key_Company]) {
        if ([self.testInfo existsOnServerNew]) {
            [self showSimpleMessage:@"Company can't be changed. Please create new test Info!"];
            return;
        } else {
            [self showCompanyPickerFromView:cell];
        }
    } else if ([key isEqualToString:Key_State]) {
        // 25.10.2019 we should not allow changing the state. it should be changed bu editing user info
        [self showSimpleMessage:@"Driver license state can't be changed. It can be updated by editing the Student info!"];
        return;
        [self showDriverLicenseStatePickerFromView:cell];
    } else if ([key isEqualToString:Key_Class]) {
        [self showClassPickerFromView:cell];
    } else if ([key isEqualToString:Key_Student]) {
        if (self.isDrivingSchool) {
            if (self.testInfo) {
                if (self.testInfo.endDateTime) {
                    [self showSimpleMessage:@"Class is ended!"];
                    return;
                } else if ([self.testInfo isPaused]) {
                    NSLog(@"we should allow choosing the student");
                    self.searchStudentLastTest = YES;
                } else {
                    NSString *msg = @"\nClass needs to be paused first!\n\nDo you want to pause it?";
                    self.studentIndexPath = indexPath;
                    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Change Student", nil)
                                                                                message:msg
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                        
                    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                        [self pauseButtonPressed:nil];
                        self.searchStudentLastTest = YES;
                        [self showUserPickerFromView:nil forKey:Key_Student];
                    }];
                        
                    UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                            }];
                        
                    [al addAction:noAction];
                    [al addAction:yesAction];
                    [self presentViewController:al animated:YES completion:nil];
                    //[self showSimpleMessage:@"Please pause the test first!"];
                }
            }
        } else {
            if ([self.testInfo existsOnServerNew]) {
                [self showSimpleMessage:@"Student can't be changed. Please create new Class!"];
                return;
            }
        }
        if (!self.company) {
            [self showSimpleMessage:@"Please select company first!"];
            return;
        }
        [self showUserPickerFromView:cell forKey:key];
    } else if ([key isEqualToString:Key_Instructor]) {
        
        NSString *currentUserItemType = [Settings getSetting:USER_TYPE];
        if ([currentUserItemType isEqualToString:kUserTypeInstructor]) {
            NSString *message = @"Current logged user is a Instructor.\nInstructor can't be changed!";
            [self showSimpleMessage:message];
            return;
        }
                
        if ([self.testInfo existsOnServerNew]) {
            [self showSimpleMessage:@"Instructor can't be changed.\n\nPlease create new Class!"];
            return;
        }
        [self showUserPickerFromView:cell forKey:key];
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        if ([key isEqualToString:@"driverLicenseExpirationDate"]) {
            [self showSimpleMessage:@"Driver License Expiration Date can't be changed. It can be updated by editing the Student info!"];
            return;
        } else {
            [self showDatePickerFromView:cell andKey:key];
        }
    }
    NSLog(@"");
}

-(IBAction)valueChanged:(UISegmentedControl*)sender {
    NSLog(@"");
}

-(void)switchValueChanged:(UISwitch*)aSwitch {
    //19.08.2019 changed from switch to segmented controller TODO:REMOVE
    NSInteger keyIndex = aSwitch.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    [self.values setObject:[NSNumber numberWithBool:aSwitch.on] forKey:key];
    [self enableSaving];
}

-(void)segmentedControllerValueChanged:(UISegmentedControl*)segCtrl {
    NSInteger keyIndex = segCtrl.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    //17.12.2019 we should allow just one switch to be on yes
    NSArray *specialSwitches =[NSArray arrayWithObjects:@"trainingNewHire", @"trainingNearMiss", @"trainingIncidentFollowUp", @"trainingChangeJob", @"trainingChangeOfEquipment", @"trainingAnnual", nil];

    [self.values setObject:[NSNumber numberWithBool:segCtrl.selectedSegmentIndex] forKey:key];
    
    if ([specialSwitches containsObject:key]) {
        if (segCtrl.selectedSegmentIndex) {
            for (NSString *keyTmp in specialSwitches) {
                if ([keyTmp isEqualToString:key]) {
                    continue;
                }
                [self.values setObject:[NSNumber numberWithBool:0] forKey:keyTmp];
            }
        }
        [self.tableView reloadData];
    }
    
    [self enableSaving];
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
    NSString *groupName = nil;
    
    if ([key isEqualToString:Key_Student] && !fromView) {
        if (self.studentIndexPath) {
            fromView = [self.tableView cellForRowAtIndexPath:self.studentIndexPath];
            self.studentIndexPath = nil;
        }
    }
    
    if ([key isEqualToString:Key_Student]) {
        aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
        title = @"Students";
        fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
        detailFields = [NSArray arrayWithObject:@"employeeNumber"];
        sortKey = @"surname";
        selectedObject = self.student;
        predicate = [NSPredicate predicateWithFormat:@"company=%@", self.company.name];
        NSArray *studentIds = [Settings getSettingAsArray:CSD_TEST_GROUP_MEMBERS];
        groupName = [Settings getSetting:CSD_TEST_GROUP_NAME];
        if (studentIds.count) {
            NSPredicate *recordIdPredicate = [NSPredicate predicateWithFormat:@"rcoRecordId in %@", studentIds];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, recordIdPredicate, nil]];
            if (groupName.length) {
                title = [NSString stringWithFormat:@"%@ Students", groupName];
            }
        }
    } else {
        title = @"Instructors";
        aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];
        fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
        detailFields = [NSArray arrayWithObject:@"employeeNumber"];
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
    TrainingCompanyAggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = (TrainingCompanyAggregate *) [[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    
    //(TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    title = @"Companies";
    fields = [NSArray arrayWithObjects:@"name", @"number", nil];
    detailFields = nil;
    sortKey = @"name";
    
    NSArray *companies = [aggregate getAll];
    if (!companies.count) {
        [aggregate createDefaultCompany];
    }
    
    NSLog(@"Companies %@", companies);
    
    // 21.10.2019 we should show just the company of the current logged in user if the current user company is not the same as organization name
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    if (![[userCompany lowercaseString] containsString:[organizationName lowercaseString]]) {
        predicate = [NSPredicate predicateWithFormat:@"name=%@", userCompany];
    }
    
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

- (void)showDriverLicenseStatePickerFromView:(UIView*)fromView {

    NSArray *states = [RCOObject getStatesList:YES andAbbreviation:YES];
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:states
                                                                                                forKey:Key_State];
    
    listController.selectDelegate = self;
    listController.title = @"State";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *state = [self.values objectForKey:Key_State];
    
    if (state) {
        state = [NSString stringWithFormat:@"%@",[RCOObject getStateNameForAbbreviation:state andFormatted:YES]];
        listController.selectedValue = state;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showClassPickerFromView:(UIView*)fromView {
    
    NSArray *values = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:values
                                                                                                forKey:Key_Class];
    
    listController.selectDelegate = self;
    listController.title = @"Class";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *class = [self.values objectForKey:Key_Class];
    if (class) {
        listController.selectedValue = class;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showEndorsementsPickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.endorsements
                                                                                                forKey:Key_Endorsements];
    
    listController.selectDelegate = self;
    listController.title = @"Endorsements";
    listController.showIndex = NO;
    listController.newLogic = YES;
    listController.allowMultipleSelections = YES;
    NSString *endorsement = [self.values objectForKey:Key_Endorsements];
    NSArray *endorsements = nil;

    if (endorsement.length) {
        endorsements = [endorsement componentsSeparatedByString:@","];
    }
    
    listController.selectedValues = [NSMutableArray arrayWithArray:endorsements];
    /*
    if (endorsement) {
        listController.selectedValue = endorsement;
    }
    */
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(void)showDatePickerFromView:(UIView*)fromView andKey:(NSString*)key  {
    DateSelectorViewController *controller = [[DateSelectorViewController alloc] initWithNibName:@"DateSelectorViewController"
                                                                                          bundle:nil
                                                                                        forDates:[NSArray arrayWithObject:key]];
    controller.selectDelegate = self;
    controller.shouldPopUpOnIpad = YES;
    
    NSDate *date = nil;
    controller.isSimpleDatePicker = YES;
    NSString *title = @"Date";

    if ([self.reason containsObject:key]) {
        date = [self.values objectForKey:key];
        NSInteger index = [self.reason indexOfObject:key];
        NSString *str = [self.reasonNames objectAtIndex:index];
        controller.dateNames = [NSArray arrayWithObject:str];
    } else if ([key isEqualToString:@"dateTime"]) {
        title = @"Date";
        date = self.dateTime;
        controller.dateNames = [NSArray arrayWithObject:@"Test"];
    } else if ([key isEqualToString:@"driverLicenseExpirationDate"]) {
        title = @"Date";
        date = self.driverLicenseExpirationDate;
        controller.dateNames = [NSArray arrayWithObject:@"License Expiration"];
    } else if ([key isEqualToString:@"dotExpirationDate"]) {
        title = @"Date";
        date = self.dotExpirationDate;
        controller.dateNames = [NSArray arrayWithObject:@"DOT Expiration"];
    }
    
    controller.title = title;
    
    if (!date) {
        date = [NSDate date];
    }
    
    controller.currentDate = date;
    
    if (DEVICE_IS_IPHONE) {
        controller.isCancelNewLogic = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showPopoverForViewController:controller fromView:fromView];
    }
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
    [self enableSaving];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == TAG_EVENT_BREAK) {
        NSArray *actions = self.al.actions;
        UIAlertAction *addAction = [actions objectAtIndex:0];
        if (string.length > 0) {
            [addAction setEnabled:YES];
        } else {
            [addAction setEnabled:NO];
        }
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSString *key = nil;
    
    if ([textField isKindOfClass:[TextField class]]) {
        TextField *fieldInput = (TextField*)textField;
        key = fieldInput.fieldId;
        
        if ([key isEqualToString:@"driverLicenseNumber"]) {
            // 25.10.2019 we should not allow changing the state. it should be changed bu editing user info
            [self showSimpleMessage:@"Driver license number can't be changed. It can be updated by editing the Student info!"];
            return NO;
        }
        
        if ([fieldInput.fieldId isEqualToString:KeyStartDateTime] || [fieldInput.fieldId isEqualToString:KeyEndDateTime]) {
            // start time and end time should not be editable; they are set automatically when tapping on the start/ stop button
            return NO;
        }
    }
    
    return YES;
}


-(void)loadCompanyWithName:(NSString*)name {
    TrainingCompanyAggregate *agg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    self.company = [agg getTrainingCompanyWithName:name];
}

#pragma mark AddObject delegate
-(void)didCancelObject:(RCOObject*)object {
    if (DEVICE_IS_IPHONE) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didAddObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    if ([keys containsObject:KEY_Group]) {
        NSLog(@"");
        if (objects.count) {
            NSDictionary *grpInfo = [objects objectAtIndex:0];
            
            self.groupName = [grpInfo objectForKey:@"ObjectName"];
            if (self.groupName.length) {
                [Settings setSetting:self.groupName forKey:CSD_TEST_GROUP_NAME];
                [self.groupBtn setTitle:self.groupName];
            } else {
                [Settings resetKey:CSD_TEST_GROUP_NAME];
                [self.groupBtn setTitle:@"Group"];
            }
            self.groupNumber = [grpInfo objectForKey:@"RecordId"];
            if (self.groupNumber.length) {
                [Settings setSetting:self.groupNumber forKey:CSD_TEST_GROUP_RECORDID];
            } else {
                [Settings resetKey:CSD_TEST_GROUP_RECORDID];
            }
            
            NSMutableArray *userIds = [NSMutableArray array];
            for (NSInteger i = 1; i < objects.count; i++) {
                NSDictionary *userInfo = [objects objectAtIndex:i];
                NSString *recordId = [userInfo objectForKey:@"userRecordId"];
                if (recordId) {
                    [userIds addObject:recordId];
                }
            }
            
            [Settings setSetting:userIds forKey:CSD_TEST_GROUP_MEMBERS];
            [Settings save];
        }
    } else if ([keys containsObject:Key_Endorsements]) {
        NSString *endorsement = nil;
        if (objects.count) {
            endorsement = [objects componentsJoinedByString:@","];
            [self.values setObject:endorsement forKey:Key_Endorsements];
        } else {
            [self.values removeObjectForKey:Key_Endorsements];
        }
    }
    
    [self enableSaving];
    if (DEVICE_IS_IPAD || [keys containsObject:KEY_Group]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tableView reloadData];

}

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {

    if ([key isEqualToString:KEY_Group]) {
        NSLog(@"");
        if ([object isKindOfClass:[NSDictionary class]]) {
            //self.groupInfo = (NSDictionary*)object;
            //[self.groupBtn setTitle:[self.groupInfo objectForKey:@"ObjectName"]];
        }
    } else if ([self.datePickerFieldsNames containsObject:key] && [self.reason containsObject:key]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_Endorsements]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:@"dateTime"]) {
        if (object) {
            self.dateTime = (NSDate*)object;
            [self.values setObject:self.dateTime forKey:key];
        }
    } else if ([key isEqualToString:@"driverLicenseExpirationDate"]) {
        if (object) {
            self.driverLicenseExpirationDate = (NSDate*)object;
            [self.values setObject:self.driverLicenseExpirationDate forKey:key];
        }
    } else if ([key isEqualToString:@"dotExpirationDate"]) {
        if (object) {
            self.dotExpirationDate = (NSDate*)object;
            [self.values setObject:self.dotExpirationDate forKey:key];
            [Settings setSetting:self.dotExpirationDate forKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
            [Settings save];
        }
    } else if ([key isEqualToString:Key_Company]) {
        if ([object isKindOfClass:[TrainingCompany class]]) {
            self.company = (TrainingCompany*)object;
            if (self.company.name) {
                // 22.10.2019 we should check if the "company name" is the same as "student company name" if not then we should reset the student
                if (self.student) {
                    if (![[self.student.company lowercaseString] isEqualToString:[self.company.name lowercaseString]]) {
                        [self resetStudentsFields];
                        self.student = nil;
                    }
                }
                [self.values setObject:self.company.name forKey:key];
            }
            
        }
    } else if ([key isEqualToString:Key_Class]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_State]) {
        if (object) {
            NSString *state = [RCOObject getStateAbbreviationFromString:(NSString*)object];
            if (state.length) {
                [self.values setObject:state forKey:key];
            } else {
                [self.values setObject:object forKey:key];
            }
        }
    }  else if ([key isEqualToString:Key_Instructor]) {
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
            [self resetStudentsFields];
            self.student = (User*)object;
            
            // populate the student coding fields
            if (self.student.employeeNumber) {
                [self.values setObject:self.student.employeeNumber forKey:@"employeeId"];
            }
            if (self.student.company) {
                [self.values setObject:self.student.company forKey:@"company"];

                if (!self.company) {
                    [self loadCompanyWithName:self.student.company];
                }
            }
            if (self.student.driverLicenseNumber) {
                [self.values setObject:self.student.driverLicenseNumber forKey:@"driverLicenseNumber"];
            }
            if (self.student.driverLicenseState) {
                [self.values setObject:self.student.driverLicenseState forKey:@"driverLicenseState"];
            }
            if (self.student.correctiveLensRequired) {
                [self.values setObject:self.student.correctiveLensRequired forKey:@"correctiveLensRequired"];
            }
            if (self.student.driverLicenseClass) {
                [self.values setObject:self.student.driverLicenseClass forKey:Key_Class];
            }
            
            if ([self.student.driverLicenseExpirationDate isKindOfClass:[NSDate class]]) {
                [self.values setObject:self.student.driverLicenseExpirationDate forKey:@"driverLicenseExpirationDate"];
                self.driverLicenseExpirationDate = self.student.driverLicenseExpirationDate;
            }
            
            if ([self.student.rcoRecordId length]) {
                [Settings setSetting:self.student.rcoRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            } else  if ([self.student.rcoMobileRecordId length]){
                // this is a local student
                [Settings setSetting:self.student.rcoMobileRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            }

            if (self.testInfo && [self.testInfo isPaused]) {
                NSLog(@"load the previous test info for this student !!!");
                // 22.01.2020 we reset the Class we should force the user to tap a start
                [Settings resetKey:CSD_TEST_INFO_START_DATE];
                [Settings save];
                [self loadObject];
                self.searchStudentLastTest = NO;
            }
            // 29.01.2020 after we install the app on the tablet we should search the prev unfinished test for that student
            BOOL searchThePrevTestForTheStudentAfterInstall = YES;
            
            if (!self.testInfo) {
                if (searchThePrevTestForTheStudentAfterInstall && !self.isAddingNewTest) {
                    self.searchStudentLastTest = YES;
                    [self loadObject];
                    self.searchStudentLastTest = NO;
                }

                if (!self.testInfo) {
                    // 29.01.2020 if we still didin't found any open test for that Student that means that we don't have an open test for that student
                    [Settings resetKey:CSD_TEST_INFO_START_DATE];
                    [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
                    [[DataRepository sharedInstance] resetTrainingTestInfo];
                    [Settings save];
                } else {
                    if (self.testInfo.startDateTime) {
                        [Settings setSetting:self.testInfo.startDateTime forKey:CSD_TEST_INFO_START_DATE];
                    }
                    if (self.testInfo.endDateTime) {
                        [Settings setSetting:self.testInfo.endDateTime forKey:CSD_TEST_INFO_END_DATE];
                    }
                    [Settings save];
                }
            }
        }
    }
    if (key) {
        [self enableSaving];
    }
    
    if (DEVICE_IS_IPAD || [key isEqualToString:KEY_Group]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tableView reloadData];
}

-(void)resetStudentsFields {
    self.driverLicenseExpirationDate = nil;
    [self.values removeObjectForKey:@"employeeId"];
    [self.values removeObjectForKey:@"company"];
    [self.values removeObjectForKey:@"driverLicenseNumber"];
    [self.values removeObjectForKey:@"correctiveLensRequired"];
    [self.values removeObjectForKey:@"driverLicenseExpirationDate"];
    [self.values removeObjectForKey:Key_Class];
}

-(void)enableSaving {
    [self.saveBtn setEnabled:YES];
    self.needsToSave = YES;
}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"TrainingTestInfo"];
}

- (void) contentDownloadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate{
    if ([aggregate isKindOfClass:[SignatureDetailAggregate class]]) {
        [self.tableView reloadData];
    }
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:CLAS] ) {
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObject:self.testInfo forKey:self.addDelegateKey];
        }
        [self.progressHUD hide:YES];
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:CLAS] ) {
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            //[self.addDelegate didAddObject:self.detail forKey:self.addDelegateKey];
            [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
        }
        [self.progressHUD hide:YES];
    }
}

#pragma mark Keyboard Methods

- (void)keyboardWillHide:(NSNotification *)notif {
    if (DEVICE_IS_IPHONE) {
        CGRect frame = self.tableView.frame;
        if (self.bottomToolbar) {
            frame.size.height = self.bottomToolbar.frame.origin.y;
        } else {
            //15.11.2018 workaround...
            frame.size.height = self.view.frame.size.height - 44;
        }
        self.tableView.frame = frame;
    }
}

- (void)keyboardWillShow:(NSNotification *)notif{
    
    self.keyboardInfo = notif.userInfo;
    
    NSInteger keyBoardHeight = [[self.keyboardInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    
    CGRect frame = self.tableView.frame;
    if (DEVICE_IS_IPHONE) {
        frame.size.height = self.view.frame.size.height - keyBoardHeight;
        self.tableView.frame = frame;
    } else {
    }
}

#pragma mark CSDSelectObject

-(BOOL)CSDInfoCanSelectScreen {
    return !self.needsToSave;
    //return !(self.saveBtn.enabled);
}

-(NSString*)CSDInfoScreenTitle {
    return @"Class Info";
}

-(void)CSDSaveRecordOnServer:(BOOL)onServer {
    [self saveButtonPressed:nil];
}

@end
