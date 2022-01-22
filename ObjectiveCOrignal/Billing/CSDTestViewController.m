//
//  CSDTestViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/2019.
//  Copyright (c) 2019 RCO. All rights reserved.
//

#import "CSDTestViewController.h"
#import "InputCellWithId.h"
#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"
#import "RCOValuesListViewController.h"
#import "TestSetupAggregate.h"
#import "TestFormAggregate.h"
#import "TestDataHeaderAggregate.h"

#import "TestDataHeader+CoreDataClass.h"
#import "TestDataDetail+CoreDataClass.h"
#import "TestForm+CoreDataClass.h"
#import "Testsetup+CoreDataClass.h"
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
#import "WebViewViewController.h"

#import "DriverTurn+CoreDataClass.h"
#import "TrainingCompany+CoreDataClass.h"
#import "TrainingCompanyAggregate.h"
#import "Settings.h"

#import "CSDTurnsViewController.h"
#import "UserAggregate.h"
#import "User_Imp.h"
#import "DriverTurnsAggregate.h"
#import "TestDataDetailAggregate.h"
#import "TrainingTestInfo+CoreDataClass.h"
#import "TrainingEquipment+CoreDataClass.h"
#import "TrainingScoreAggregate.h"
#import "TrainingScore+CoreDataClass.h"
#import "TextViewCell.h"
#import "CSDScoreButton.h"

#import "MapsViewController.h"

#define Key_Class @"driverLicenseClass"
#define Key_State @"driverLicenseState"
#define Key_Student @"employeeId"
#define Key_Instructor @"instructorEmployeeId"
#define Key_Company @"company"
#define Key_Setup @"setup"
#define Key_Preview @"preview"
#define Key_Turns @"turns"
#define Key_Endorsements @"endorsements"
#define Key_CurrentSection @"currentSection"
#define Key_CompanyRepresentative @"companyRepresentative"
#define Key_Print @"evaluatorName"
#define Key_Title @"evaluatorTitle"

#define ValueYes 5
#define ValueNo 2

#define KeyLocation @"location"
#define KeyTrailerNumber @"trailerNumber"
#define KeyOdometer @"odometer"

#define KeyStartDateTime @"startDateTime"
#define KeyEndDateTime @"endDateTime"
#define KeyEquipmentUsed @"equipmentUsed"
#define KeyQualifiedOrNot @"qualifiedYesNo"
#define KeyTestState @"testState"

@interface CSDTestViewController ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *fieldsAll;
@property (nonatomic, strong) NSMutableArray *notes;
@property (nonatomic, strong) NSMutableDictionary *detailsInfo;

@property (nonatomic, strong) NSMutableArray *detailsNames;
@property (nonatomic, strong) NSMutableDictionary *scores;

@property (nonatomic, strong) NSArray *bottomSection;
@property (nonatomic, strong) NSArray *bottomSectionNames;

@property (nonatomic, strong) NSArray *fieldsNames;
@property (nonatomic, strong) NSArray *fieldsNamesAll;
@property (nonatomic, strong) NSArray *fieldsNamesShort;

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *textFields;
@property (nonatomic, strong) NSArray *percentageFields;
@property (nonatomic, strong) NSArray *numericFields;
@property (nonatomic, strong) NSArray *fieldsInherited;

@property (nonatomic, strong) NSArray *datePickerFieldsNames;

@property (nonatomic, strong) NSDate *dateTime;
@property (nonatomic, strong) NSDate *driverLicenseExpirationDate;
@property (nonatomic, strong) NSDate *dotExpirationDate;
//@property (nonatomic, strong) TrainingStudent *student;
@property (nonatomic, strong) User *student;
//@property (nonatomic, strong) TrainingInstructor *instructor;
@property (nonatomic, strong) User *instructor;
@property (nonatomic, strong) TrainingCompany *company;

@property (nonatomic, assign) BOOL isEnded;

@property (nonatomic, strong) UIImage *driverSignature;
@property (nonatomic, strong) UIImage *evaluatorSignature;
@property (nonatomic, strong) UIImage *compRepSignature;

@property (nonatomic, assign) NSInteger possiblePoints;
@property (nonatomic, assign) NSInteger receivedPoints;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *pauseBtn;
@property (nonatomic, strong) UIBarButtonItem *previewBtn;
@property (nonatomic, strong) UIBarButtonItem *reloadBtn;
@property (nonatomic, strong) UIBarButtonItem *addSectionBtn;
@property (nonatomic, strong) UIBarButtonItem *signatureBtn;
@property (nonatomic, strong) UIBarButtonItem *turnsBtn;
@property (nonatomic, strong) UIBarButtonItem *addNewTestBtn;

@property (nonatomic, strong) NSArray *testFormItems;
@property (nonatomic, strong) NSMutableArray *details;
@property (nonatomic, strong) NSDate *pausedDate;

@property (nonatomic, strong) NSArray *endorsements;
@property (nonatomic, assign) NSInteger currentSection;

@property (nonatomic, assign) BOOL useNADefault;
@property (nonatomic, assign) BOOL autoSaveEnabled;
@property (nonatomic, strong) NSTimer *autoSaveTimer;

@property (nonatomic, assign) BOOL showTrainingInfofields;
@property (nonatomic, assign) BOOL showTestAlertNotification;
@property (nonatomic, assign) BOOL showSignatireFieldsAllTheTime;

@property (nonatomic, strong) NSMutableArray *specialSectionValues;
@property (nonatomic, strong) NSMutableDictionary *criticalItems;
@property (nonatomic, strong) NSMutableDictionary *criticalItemsNewFormat;

@property (nonatomic, assign) BOOL useTheNewLogicForStartingAndLoading;
@property (nonatomic, assign) BOOL showStartStopButtonsSeparately;
@property (nonatomic, strong) NSMutableDictionary *equipmentUsed;

@property (nonatomic, assign) BOOL needsToSave;
@property (nonatomic, assign) BOOL saveOnServer;
@property (nonatomic, assign) BOOL saveSignature;
@property (nonatomic, assign) BOOL isDrivingSchool;
@property (nonatomic, assign) BOOL isNewCreated;
@property (nonatomic, assign) BOOL isDebugging;
@property (nonatomic, assign) BOOL saveScores;

@end

@implementation CSDTestViewController

-(void)customizeTopToolbar {
    if (self.header) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, self.reloadBtn, nil];
        
        if (self.isDrivingSchool) {
            [self.addNewTestBtn setEnabled:YES];
            //08.01.2020 self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.addNewTestBtn, self.previewBtn, self.saveBtn, nil];
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, nil];

        } else {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, nil];
        }
        if (![self.header existsOnServerNew]) {
            // 17.10.2019 we should enable save button for records that were saved just locally
            //[self.saveBtn setEnabled:YES];
            if (self.isDrivingSchool) {
                // 23.01.2020 should we enable this for training company also?
                self.needsToSave = YES;
            }
        }
        [self.previewBtn setEnabled:YES];
    } else {
        [self.previewBtn setEnabled:NO];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, self.reloadBtn, nil];
        if (self.isDrivingSchool) {
            [self.addNewTestBtn setEnabled:NO];
            //08.01.2020 self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.addNewTestBtn, self.previewBtn, self.saveBtn, nil];
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, nil];
        } else {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *usr = [Settings getSetting:CLIENT_LOGIN_KEY];
    if ([usr isEqualToString:@"zzz"]) {
        self.isDebugging = YES;
    }
    
    // Do any additional setup after loading the view from its nib.
    if ([self.formNumber isEqualToString:TestVRT]) {
        self.useNADefault = NO;
    } else {
        self.useNADefault = YES;
    }
    
    self.autoSaveEnabled = YES;
    self.autoSaveEnabled = NO;
    
    self.showSignatireFieldsAllTheTime = YES;
    self.useTheNewLogicForStartingAndLoading = YES;
    
    NSNumber *isDrivingSchool = [Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL];
    
    if ([isDrivingSchool boolValue]) {
        self.showStartStopButtonsSeparately = YES;
        self.isDrivingSchool = YES;
    } else {
        self.showStartStopButtonsSeparately = NO;
        self.isDrivingSchool = NO;
    }

    self.signatureBtn = [[UIBarButtonItem alloc] initWithTitle:@"Sign"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(signButtonPressed:)];
    
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                   target:self
                                                                   action:@selector(actionButtonPressed:)];
    
    self.addSectionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(addSectionButtonPressed:)];
    

    self.previewBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Preview", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(emailButtonPressed:)];
    
    self.addNewTestBtn = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(newTestButtonPressed:)];
    
    if (self.isDrivingSchool) {
        self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                 target:self
                                                                 action:@selector(saveButtonPressed:)];
        [self.saveBtn setEnabled:NO];
    }
    
    self.needsToSave = NO;
    
    [self showLoading];
    
    self.reloadBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                   target:self
                                                                   action:@selector(reloadButtonPressed:)];
    [self customizeTopToolbar];
    
    self.showTrainingInfofields = NO;
    
    BOOL enableEditingEndedTests = YES;

    // should we allow edinting a test that was ended?
    enableEditingEndedTests = NO;
    
    self.pauseBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                 target:self
                                                                 action:@selector(pauseButtonPressed:)];

    if (self.isDrivingSchool) {
        if ([self.header isPaused]) {
            self.pausedDate = [self.header getPauseDate];
        } else {
            self.pausedDate = nil;
        }
    } else {
        self.pausedDate = [Settings getSettingAsDate:CSD_TEST_PAUSED_DATE];
    }
    
    if ([self.header existsOnServerNew] && [self testEnded] && enableEditingEndedTests) {
    // 22.03.2019 should we add an edit button?
        UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                 target:self
                                                                                 action:@selector(editButtonPressed:)];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, editBtn, nil];
    }
    
    NSString *closeBtnTitle = NSLocalizedString(@"Cancel", nil);
    if (self.header) {
        closeBtnTitle = NSLocalizedString(@"Close", nil);
    }
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:closeBtnTitle
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(cancelButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.scores = [NSMutableDictionary dictionary];
    
    self.fieldsInherited = [NSArray arrayWithObjects:@"location", nil];
    self.fieldsNA = [NSArray arrayWithObjects:@"dotExpirationDate", nil];
    
    if (self.showTrainingInfofields) {
        
        self.fields = [NSArray arrayWithObjects: @"dateTime", @"company", @"employeeId", @"driverLicenseExpirationDate", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseClass", @"endorsements", @"driverHistoryReviewed", @"dotExpirationDate", @"powerUnit", KeyStartDateTime, KeyEndDateTime, @"location", @"correctiveLensRequired", @"instructorEmployeeId", nil];
    } else {
        
        if ([self.formNumber isEqualToString:TestProd]) {
            
            self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, @"department", @"routeNumber", @"onTime", @"keysReady", @"timecardSystemReady", @"equipmentReady", @"equipmentClean", @"startOdometer", @"finishOdometer", @"miles", nil];
        } else if ([self.formNumber isEqualToString:TestVRT]) {
            
            //self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, KeyEquipmentUsed, nil];
            // 04.02.2020
            self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, KeyEquipmentUsed, KeyQualifiedOrNot, @"testRemarks", nil];
            self.textFields = [NSArray arrayWithObjects:@"testRemarks", @"disqualifiedRemarks", nil];
        } else {
            
            self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, nil];
        }

        self.fieldsAll = [NSArray arrayWithObjects: @"dateTime", @"company", @"employeeId", @"driverLicenseExpirationDate", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseClass", @"endorsements", @"driverHistoryReviewed", @"dotExpirationDate", @"powerUnit", KeyStartDateTime, KeyEndDateTime, @"location", @"correctiveLensRequired", @"instructorEmployeeId", @"onTime", @"keysReady", @"timecardSystemReady", @"equipmentReady", @"equipmentClean", @"startOdometer", @"finishOdometer", @"miles", KeyQualifiedOrNot, @"testRemarks", @"department", @"routeNumber", @"disqualifiedRemarks", nil];
    }
    if (self.showTrainingInfofields) {
        
        self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Company", @"Student", @"Driver License Expiration Date", @"Driver License Number", @"Driver License State", @"Class", @"Endorsements",@"History Reviewed", @"DOT Expiration Date", @"Power Unit", @"Start Time", @"End Time", @"Location", @"Corrective Lens Required", @"Instructor", nil];
    } else {
        
        if ([self.formNumber isEqualToString:TestProd]) {
            
            
            self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Department", @"Route Number", @"On Time", @"Keys Ready", @"Timecard System Ready", @"Equipment Ready", @"Equipment Clean", @"Start Odometer", @"Finish Odometer", @"Miles", nil];
        } else if ([self.formNumber isEqualToString:TestVRT]) {
            
            //self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Equipment Used", nil];
            // 04.02.2020
            self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Equipment Used", @"Qualified", @"Remarks",  nil];
        } else  {
            
            self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", nil];
        }

        self.fieldsNamesAll = [NSArray arrayWithObjects: @"Date", @"Company", @"Student", @"Driver License Expiration Date", @"Driver License Number", @"Driver License State", @"Class", @"Endorsements",@"History Reviewed", @"DOT Expiration Date", @"Power Unit", @"Start Time", @"End Time", @"Location", @"Corrective Lens Required", @"Instructor", nil];
    }

    if ([self.formNumber isEqualToString:TestProd]) {
        
        
        self.bottomSection = [NSArray arrayWithObjects:TestSignatureDriver, TestSignatureEvaluator, TestSignatureCompanyRep, Key_CompanyRepresentative, @"observerFirstName", @"observerLastName", nil];
        self.bottomSectionNames = [NSArray arrayWithObjects:@"Driver Signature", @"Evaluator Signature", @"Company Rep. Signature", @"Company Rep. Name", @"Observer First Name", @"Observer Last Name", nil];
    } else if ([self.formNumber isEqualToString:TestVRT]) {
        
        self.bottomSection = [NSArray arrayWithObjects: @"medicalCardExpirationDate", @"testState", @"powerUnit", @"trailerLength", @"numberofTrailers", @"testMiles", TestSignatureDriver, TestSignatureEvaluator,  Key_Print, Key_Title, nil];
        self.bottomSectionNames = [NSArray arrayWithObjects:@"Medical Card Expiration Date", @"State", @"Type Of Power Unit", @"Trailer Length", @"Number of Trailers", @"Miles", @"Driver Signature", @"Evaluator Signature", @"Print", @"Title", nil];
    } else {
        
        self.bottomSection = [NSArray arrayWithObjects:TestSignatureDriver, TestSignatureEvaluator, TestSignatureCompanyRep, Key_CompanyRepresentative, nil];
        self.bottomSectionNames = [NSArray arrayWithObjects:@"Driver Signature", @"Evaluator Signature", @"Company Rep. Signature", @"Company Rep. Name", nil];
    }
    
    self.values = [NSMutableDictionary dictionary];
    
    //BOOL isOffline = [[DataRepository sharedInstance] workOffline];
    
    self.datePickerFieldsNames = [NSArray arrayWithObjects:@"dateTime", @"driverLicenseExpirationDate", @"dotExpirationDate", @"medicalCardExpirationDate", @"testDate", nil];
    self.switchFields = [NSArray arrayWithObjects:@"driverHistoryReviewed", @"correctiveLensRequired", @"onTime", @"keysReady", @"timecardSystemReady", @"equipmentReady", @"equipmentClean", KeyQualifiedOrNot, nil];
    self.numericFields = [NSArray arrayWithObjects:@"startOdometer", @"finishOdometer", nil];
    
    //self.pickerFields = [NSArray arrayWithObjects: @"instructorEmployeeId", @"driverLicenseClass", @"driverLicenseState", nil];
    if ([self.formNumber isEqualToString:TestVRT]) {
        self.pickerFields = [NSArray arrayWithObjects: @"company", @"employeeId", @"endorsements", @"instructorEmployeeId", @"driverLicenseClass", @"driverLicenseState", KeyEquipmentUsed, KeyTestState, nil];
    } else {
        self.pickerFields = [NSArray arrayWithObjects: @"company", @"employeeId", @"endorsements", @"instructorEmployeeId", @"driverLicenseClass", @"driverLicenseState",nil];
    }

    self.requiredFields = [NSArray arrayWithObjects:@"dateTime", @"company", @"driverLicenseExpirationDate", @"instructorEmployeeId", @"driverLicenseState", @"driverLicenseNumber", nil];

    self.endorsements = [NSArray arrayWithObjects:@"NA", @"(P) Passenger Transport Endorsement", @"(S) School Bus/Passenget Transport Combo Endorsement", @"(T) Double/Triples Endorsement", @"(N) Tank Vehicle Endorsement", @"(H) Hazardous Materials Endorsement (HAZMAT)", @"(X) Tank/HAZMAT Combo Endorsement", nil];

    //self.endorsements = [NSArray arrayWithObjects:@"NA", @"P", @"S", @"T", @"N", @"H", @"X", nil];
    self.scores = [NSMutableDictionary dictionary];
    
    if ([self.formNumber isEqualToString:TestProd]) {
        self.specialSectionValues = [NSMutableArray array];
    }

    if (!self.useTheNewLogicForStartingAndLoading) {
        
        [self loadObjectSequence];
    }
}

-(void)showLoading {
    self.progressHUD.labelText = @"Loading test...";
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
}

-(void)loadCriticalItems {
    self.criticalItems = [NSMutableDictionary dictionary];
    self.criticalItemsNewFormat = [NSMutableDictionary dictionary];
    
    for (TestForm *tf in self.testFormItems) {
        if ([tf.categName17 isEqualToString:@"Critical Section"] && [tf.categValue17 isEqualToString:@"yes"]) {
            NSString *key = [NSString stringWithFormat:@"%@%@", tf.sectionNumber, tf.itemNumber];
            [self.criticalItems  setObject:[NSNumber numberWithBool:YES] forKey:key];
            NSMutableArray *items = [self.criticalItemsNewFormat objectForKey:tf.sectionNumber];
            if (!items) {
                items = [NSMutableArray array];
            }
            // remove the "0" from front
            NSString *key1 = [NSString stringWithFormat:@"%d%@", (int)[tf.sectionNumber intValue], tf.itemNumber];

            [items addObject:key1];
            [self.criticalItemsNewFormat setObject:items forKey:tf.sectionNumber];
        }
    }
}

-(void)loadEquipmentUsed {
    self.equipmentUsed = [NSMutableDictionary dictionary];
    
    if (![self.formNumber isEqualToString:TestProd] && ![self.formNumber isEqualToString:TestVRT]) {
        return;
    }
    
    for (TestDataDetail *tdd in self.self.details) {
        if (tdd.equipmentUsedMobileRecordId.length) {
            TrainingEquipment *te = [self.equipmentUsed objectForKey:tdd.testSectionName];
            if (!te) {
                NSString *key = tdd.testSectionName;
                if ([self.formNumber isEqualToString:TestVRT]) {
                    // 19.12.2019 we have just one equipment per test
                    key = KeyEquipmentUsed;
                }
                te = [self getTrainingEquipmentWithMobileRecordId:tdd.equipmentUsedMobileRecordId];
                if (te) {
                    [self.equipmentUsed setObject:te forKey:key];
                    if ([self.formNumber isEqualToString:TestVRT]) {
                        //19.12.2019 we should not lod the equipments for all the details because is the same one! there is just one equipment
                        [self.values setObject:te forKey:key];
                        return;
                    }
                }
            }
        }
    }
}

-(TrainingEquipment*)getTrainingEquipmentWithMobileRecordId:(NSString*)mobileRecordId {
    if (!mobileRecordId.length) {
        return nil;
    }
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"];
    TrainingEquipment *te = (TrainingEquipment*)[agg getObjectMobileRecordId:mobileRecordId];
    return te;
}

-(void)loadObjectSequence {
    [self loadPrevTestHeader];
    [self syncNotes];

    [self loadCriticalItems];

    [self loadNotes];

    [self syncSignatures];
    [self loadSignatures];
    
    self.title = [self getScreenTitle];
    
    [self customizeBottomToolbar];
}

-(void)startAutoSave {
    if (!self.autoSaveEnabled) {
        return;
    }
    
    NSInteger autoSyncMinutes = 1;
    
    if ([self.autoSaveTimer isValid]) {
        [self.autoSaveTimer invalidate];
        self.autoSaveTimer = nil;
    }
    self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:60*autoSyncMinutes
                                                          target:self
                                                        selector:@selector(saveButtonPressed:)
                                                        userInfo:nil
                                                         repeats:YES];
}

-(void)stopAutoSave {
    if (!self.autoSaveEnabled) {
        return;
    }
    if ([self.autoSaveTimer isValid]) {
        [self.autoSaveTimer invalidate];
        self.autoSaveTimer = nil;
    }
}


-(void)loadPrevInstructor{
    NSString *prevInstructor = [Settings getSetting:CSD_PREV_INSTRUCTOR_ID];
    if (prevInstructor.length == 0) {
        return;
    }
    UserAggregate *instrAgg = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];

    self.instructor = (User*)[instrAgg getObjectWithUserId:prevInstructor];
    
    if (self.instructor.userId) {
        [self.values setObject:self.instructor.userId forKey:@"instructorEmployeeId"];
    }
}

-(void)loadPrevStudent{
    NSString *prevStudent = [Settings getSetting:CSD_PREV_STUDENT_ID];
    if (prevStudent.length == 0) {
        return;
    }
    UserAggregate *studentAggregate = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];

    if ([prevStudent longLongValue]) {
        self.student = (User*)[studentAggregate getObjectWithUserId:prevStudent];
    } else {
        self.student = (User*)[studentAggregate getObjectWithUserId:prevStudent];
    }
    
    if (self.student.userId) {
        [self.values setObject:self.student.userId forKey:@"employeeId"];
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
    [self loadPrevStudentExtraFields];
}

-(void)loadPrevStudentExtraFields {
    if (!self.student) {
        return;
    }
    NSDate *dotExpirationDate = [Settings getSettingAsDate:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    if (dotExpirationDate) {
        [self.values setObject:dotExpirationDate forKey:@"dotExpirationDate"];
        self.dotExpirationDate = dotExpirationDate;
    }
    NSString *endorsements = [Settings getSetting:CSD_TEST_INFO_ENDORSEMENTS];
    if (endorsements) {
        [self.values setObject:endorsements forKey:@"endorsements"];
    }
    NSString *driverHistoryReviewed = [Settings getSetting:CSD_TEST_INFO_HISTORY_REVIEWED];
    if (driverHistoryReviewed) {
        [self.values setObject:driverHistoryReviewed forKey:@"driverHistoryReviewed"];
    }
    NSString *powerUnit = [Settings getSetting:CSD_TEST_INFO_POWER_UNIT];
    if (powerUnit) {
        [self.values setObject:powerUnit forKey:@"powerUnit"];
    }
    NSString *correctiveLensRequired = [Settings getSetting:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    if (correctiveLensRequired) {
        [self.values setObject:correctiveLensRequired forKey:@"correctiveLensRequired"];
    }
}

-(BOOL)testStarted {
    NSDate *startDateTime = [self.values objectForKey:KeyStartDateTime];
    if (startDateTime) {
        return YES;
    } else {
        return NO;
    }
}

-(void)customizeBottomToolbarOld {
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
    
    BOOL removePlayAnStopButtons = YES;
    
    if (self.showStartStopButtonsSeparately) {
        //27.12.2019
        removePlayAnStopButtons = NO;
    }
    
    if (removePlayAnStopButtons) {
        if (self.playBtn && [items containsObject:self.playBtn]) {
            [items removeObject:self.playBtn];
        }
        if (self.stopBtn && [items containsObject:self.stopBtn]) {
            [items removeObject:self.stopBtn];
        }
        if (self.pauseBtn && [items containsObject:self.pauseBtn]) {
            [items removeObject:self.pauseBtn];
        }
    }
    
    if ([self.formNumber isEqualToString:TestBTW] || [self.formNumber isEqualToString:TestBusEval]) {
        if (!self.turnsBtn) {
            self.turnsBtn = [[UIBarButtonItem alloc] initWithTitle:@"Turns"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(turnsButtonPressed:)];
        }
        if (![items containsObject:self.turnsBtn]) {
            [items insertObject:self.turnsBtn atIndex:0];
        }
    }
    
    if ([self testStarted]) {
        NSInteger index = NSNotFound;
        if (self.pausedDate) {
            if (![self testEnded]) {
                // we should change play to pause only if the test is not ended
                index = [items indexOfObject:self.pauseBtn];
                if (index != NSNotFound) {
                    [items replaceObjectAtIndex:index withObject:self.playBtn];
                }
            }
        } else {
            if (![self testEnded]) {
                index = [items indexOfObject:self.playBtn];
                if (index != NSNotFound) {
                    [items replaceObjectAtIndex:index withObject:self.pauseBtn];
                }
            }
        }
        
        if ([self testEnded]) {
            [self.stopBtn setEnabled:NO];
            [self.playBtn setEnabled:NO];
            [self.pauseBtn setEnabled:NO];
            [self.turnsBtn setEnabled:NO];
        } else {
            [self.turnsBtn setEnabled:YES];
            [self.stopBtn setEnabled:YES];
            [self.playBtn setEnabled:YES];
            [self.pauseBtn setEnabled:YES];
        }
    } else if (![self testStarted]) {
        [self.turnsBtn setEnabled:NO];
        [self.playBtn setEnabled:YES];
        [self.stopBtn setEnabled:NO];
        if (![items containsObject:self.playBtn]) {
            NSInteger index = [items indexOfObject:self.pauseBtn];
            if (index != NSNotFound) {
                [items replaceObjectAtIndex:index withObject:self.playBtn];
            }
        }
    }
    // 21.05.2019 remove the turns
    if (self.actionButton && (![items containsObject:self.actionButton])) {
        UIBarButtonItem *flexiblebtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil];
        
        [items addObject:flexiblebtn];
        [items addObject:self.actionButton];
    }
    
    if ([self.formNumber isEqualToString:TestProd]) {
        if ([items containsObject:self.currentSectionBtn]) {
            [items replaceObjectAtIndex:0 withObject:self.addSectionBtn];
        }
    }
    [self.bottomToolbar setItems:items];
}

-(void)customizeBottomToolbar {
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
    
    BOOL removePlayAnStopButtons = YES;
    
    if (self.showStartStopButtonsSeparately) {
        //27.12.2019
        removePlayAnStopButtons = NO;
    }
    
    if (removePlayAnStopButtons) {
        if (self.playBtn && [items containsObject:self.playBtn]) {
            [items removeObject:self.playBtn];
        }
        if (self.stopBtn && [items containsObject:self.stopBtn]) {
            [items removeObject:self.stopBtn];
        }
        if (self.pauseBtn && [items containsObject:self.pauseBtn]) {
            [items removeObject:self.pauseBtn];
        }
    }
    
    if ([self.formNumber isEqualToString:TestBTW] || [self.formNumber isEqualToString:TestBusEval]) {
        if (!self.turnsBtn) {
            self.turnsBtn = [[UIBarButtonItem alloc] initWithTitle:@"Turns"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(turnsButtonPressed:)];
        }
        if (![items containsObject:self.turnsBtn]) {
            [items insertObject:self.turnsBtn atIndex:0];
        }
    }
    if (self.isDrivingSchool) {
        NSLog(@"Do nothing .....");
    } else if ([self testStarted]) {
        NSInteger index = NSNotFound;
        if (self.pausedDate) {
            if (![self testEnded]) {
                // we should change play to pause only if the test is not ended
                index = [items indexOfObject:self.pauseBtn];
                if (index != NSNotFound) {
                    [items replaceObjectAtIndex:index withObject:self.playBtn];
                }
            }
        } else {
            if (![self testEnded]) {
                index = [items indexOfObject:self.playBtn];
                if (index != NSNotFound) {
                    [items replaceObjectAtIndex:index withObject:self.pauseBtn];
                }
            }
        }
        
        if ([self testEnded]) {
            [self.stopBtn setEnabled:NO];
            [self.playBtn setEnabled:NO];
            [self.pauseBtn setEnabled:NO];
            [self.turnsBtn setEnabled:NO];
        } else {
            [self.turnsBtn setEnabled:YES];
            [self.stopBtn setEnabled:YES];
            [self.playBtn setEnabled:YES];
            [self.pauseBtn setEnabled:YES];
        }
    } else {
        [self.turnsBtn setEnabled:NO];
        [self.playBtn setEnabled:YES];
        [self.stopBtn setEnabled:NO];
        if (![items containsObject:self.playBtn]) {
            NSInteger index = [items indexOfObject:self.pauseBtn];
            if (index != NSNotFound) {
                [items replaceObjectAtIndex:index withObject:self.playBtn];
            }
        }
    }
    // 21.05.2019 remove the turns
    if (self.actionButton && (![items containsObject:self.actionButton])) {
        UIBarButtonItem *flexiblebtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil];
        
        [items addObject:flexiblebtn];
        [items addObject:self.actionButton];
    }
    
    if ([self.formNumber isEqualToString:TestProd]) {
        if ([items containsObject:self.currentSectionBtn]) {
            [items replaceObjectAtIndex:0 withObject:self.addSectionBtn];
        }
    }

    [self.bottomToolbar setItems:items];
    
    if (self.isDrivingSchool) {
        if ([self.header isPaused]) {
            [self addStartButton];
        } else if (self.header.endDateTime || [self.values objectForKey:KeyEndDateTime]) {
            [self.playBtn setEnabled:NO];
            [self.stopBtn setEnabled:NO];
            [self.pauseBtn setEnabled:NO];
        } else if ([self testStarted]){
            [self addPauseButton];
            [self.stopBtn setEnabled:YES];
        } else {
            NSLog(@"");
            [self addStartButton];
        }
    }
}

-(IBAction)newTestButtonPressed:(id)sender {
    if (self.header.endDateTime) {
        if (self.needsToSave) {
            [self showSimpleMessage:@"Please save the test first"];
        } else {
            UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil)
                                                                        message:@"Add new test?"
                                                                 preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                [self addNewTest];
                                                            }];
            UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                            }];
        
            [al addAction:action1];
            [al addAction:action2];
            [self presentViewController:al animated:YES completion:nil];
        }
    } else {
        [self showSimpleMessage:@"Please end the test first"];
    }
}

-(void)addNewTest {
    self.header = nil;
    self.details = [NSMutableArray array];
    self.detailsNames = [NSMutableArray array];
    [self.values removeObjectForKey:KeyStartDateTime];
    [self.values removeObjectForKey:KeyEndDateTime];
    [self loadObject];
    [self syncNotes];
    [self loadCriticalItems];
    [self loadNotes];
    [self syncSignatures];
    [self loadSignatures];
    [self customizeBottomToolbar];
    self.driverSignature = nil;
    self.compRepSignature = nil;
    self.evaluatorSignature = nil;
    [self.tableView reloadData];
}

-(IBAction)addSectionButtonPressed:(id)sender {
    NSLog(@"");
    [self addNewSection];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:(self.fields.count + self.detailsNames.count -1)];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

-(IBAction)signButtonPressed:(id)sender {
    if (![self testStarted]) {
        [self showSimpleMessage:@"Please start the test first!"];
        return;
    }

    if (!self.header) {
        [self showSimpleMessage:@"Please save the test first!"];
        return;
    }

    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign", nil)
                                                                message:@"Signature options:"
                                                         preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Driver Signature", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Evaluator Signature", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                    }];
    UIAlertAction* action3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Company Rep. Signature", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [al addAction:action1];
    [al addAction:action2];
    [al addAction:action3];

    [al addAction:cancelAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(IBAction)actionButtonPressed:(UIBarButtonItem*)sender {
    
    NSNumber *notificationOn = [Settings getSettingAsNumber:CSD_TEST_NOTIFICATIONS];
    NSString *msg = nil;
    if ([notificationOn boolValue]) {
        msg = NSLocalizedString(@"Turn Notifications Off", nil);
    } else {
        msg = NSLocalizedString(@"Turn Notifications On", nil);
    }
    
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Options", nil)
                                                                message:msg
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        NSLog(@"");
        if (notificationOn) {
            [Settings resetKey:CSD_TEST_NOTIFICATIONS];
            self.showTestAlertNotification = NO;
        } else {
            [Settings setSetting:[NSNumber numberWithBool:YES] forKey:CSD_TEST_NOTIFICATIONS];
            self.showTestAlertNotification = YES;
        }
        [Settings save];
        
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [al addAction:cancelAction];
    [al addAction:yesAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(IBAction)mapButtonPressed:(id)sender {
    
    // 19.08.2019 removed
    
    DriverTurnsAggregate *agg = (DriverTurnsAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"DriverTurn"];
    NSArray *turns = [agg getTurnsForTest:self.header.rcoMobileRecordId];
    
    if (!turns.count) {
        //[self showSimpleMessage:@"No turns found for this session!"];
        //return;
    }
    
    MapsViewController *controller = [[MapsViewController alloc] initWithNibName:@"MapsViewController" bundle:nil];
    controller.objectAggregate = nil;
    controller.items = turns;
    controller.hideInfoButton = YES;
    controller.showEmailButton = YES;
    controller.emailSubject = [NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname];
    controller.selectMapType = YES;

    controller.title = @"Turns";
    
    if (DEVICE_IS_IPHONE) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        controller.addDelegate = self;
        [self showPopoverModalForViewController:controller];
    }

    NSLog(@"");
}

-(IBAction)equipmentUsedButtonPressed:(UIBarButtonItem*)sender {
    NSString *testInfoMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"];
    predicate = [NSPredicate predicateWithFormat:@"parentMobileRecordId=%@", testInfoMobileRecordId];
    fields = [NSArray arrayWithObjects:@"powerUnit", @"trailer1Number", @"dolly1Number", @"trailer2Number", @"dolly2Number", @"trailer3Number", nil];
    sortKey = @"dateTime";
    title = @"Equipment Used";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:KeyEquipmentUsed
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = KeyEquipmentUsed;
    listController.title = title;
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:sender];
    } else {
        listController.iPhoneNewLogic = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }

}

-(IBAction)turnsButtonPressed:(UIBarButtonItem*)sender {
    
    if (!self.header.rcoMobileRecordId) {
        [self showSimpleMessage:@"Please save the test first!"];
        return;
    }
    
    CSDTurnsViewController *controller = [[CSDTurnsViewController alloc] initWithNibName:@"CSDTurnsViewController"
                                                                                  bundle:nil];
    //[controller setPreferredContentSize:CGSizeMake(375,375)];
    controller.addDelegateKey = Key_Turns;
    controller.addDelegate = self;
    controller.testMobileRecordId = self.header.rcoMobileRecordId;
    controller.values = self.values;
    controller.student = self.student;
    controller.instructor = self.instructor;
    controller.testDateTime = self.header.dateTime;
    
    //[self showPopoverForViewController:controller fromBarButton:sender];

    if (DEVICE_IS_IPHONE) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        controller.addDelegate = self;
        [self showPopoverModalForViewController:controller];
    }
}

-(void)syncNotes {
    if (!self.header || (self.header.rcoBarcode.length == 0)) {
        return;
    }
    NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
    [agg getNotesForMasterBarcode:self.header.rcoBarcode];
}

-(void)syncSignatures {
    if (!self.header || (self.header.rcoBarcode.length == 0)) {
        return;
    }
    SignatureDetailAggregate *agg = (SignatureDetailAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"SignatureDetail"];
    [agg getSignaturesForMasterBarcode:self.header.rcoBarcode];
}

-(void)loadNotes {
    if (!self.header) {
        return;
    }
    NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
    NSArray *items = [agg getNotesForObject:self.header];
    self.notes = [NSMutableArray arrayWithArray:items];

    for (NSInteger i = 0; i < self.detailsNames.count; i++) {
        NSString *section = [self.detailsNames objectAtIndex:i];
        // populate the notes ...
        Note *note = [self getNoteForSection:section];
        if (note.notes.length) {
            NSInteger sectionIndex = [self.detailsNames indexOfObject:section];
            if (sectionIndex != NSNotFound) {
                NSString *noteKey = [NSString stringWithFormat:@"%@%d", @"Notes", (int)sectionIndex];
                [self.values setObject:note.notes forKey:noteKey];
            }
        }
    }
}

-(Note*)getNoteForSection:(NSString*)sectionName {
    if (sectionName.length == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category=%@", sectionName];
    NSArray *res = [self.notes filteredArrayUsingPredicate:predicate];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}


-(UIImage *)getSignatureImageForTestHeader:(TestDataHeader*)header andType:(NSString*)type {
    if (!header) {
        return nil;
    }

    SignatureDetailAggregate *signatureAgg = [[self aggregate].detailAggregates objectAtIndex:1];
    
    SignatureDetail *detail = nil;
    
    if ([header.rcoBarcode length]) {
        detail = [signatureAgg getDetailForParentBarcode:header.rcoBarcode andType:type];
    } else {
        detail = [signatureAgg getDetailForParentId:header.rcoObjectId andType:type];
    }
    
    UIImage *img = [signatureAgg getObjectImage:detail];
    return img;
}

-(void)loadSignatures {
    if (!self.header) {
        return;
    }

    SignatureDetailAggregate *signatureAgg = [[self aggregate].detailAggregates objectAtIndex:1];
    
    SignatureDetail *detail = nil;
    
    if ([self.header.rcoBarcode length]) {
        detail = [signatureAgg getDetailForParentBarcode:self.header.rcoBarcode andType:TestSignatureDriver];
    } else {
        detail = [signatureAgg getDetailForParentId:self.header.rcoObjectId andType:TestSignatureDriver];
    }
    
    self.driverSignature = [signatureAgg getObjectImage:detail];
    
    detail = nil;
    
    if ([self.header.rcoBarcode length]) {
        detail = [signatureAgg getDetailForParentBarcode:self.header.rcoBarcode andType:TestSignatureEvaluator];
    } else {
        detail = [signatureAgg getDetailForParentId:self.header.rcoObjectId andType:TestSignatureEvaluator];
    }
    
    self.evaluatorSignature = [signatureAgg getObjectImage:detail];

    detail = nil;
    
    if ([self.header.rcoBarcode length]) {
        detail = [signatureAgg getDetailForParentBarcode:self.header.rcoBarcode andType:TestSignatureCompanyRep];
    } else {
        detail = [signatureAgg getDetailForParentId:self.header.rcoObjectId andType:TestSignatureCompanyRep];
    }
    
    self.compRepSignature = [signatureAgg getObjectImage:detail];
    if (detail.signatureName) {
        [self.values setObject:detail.signatureName forKey:Key_CompanyRepresentative];
    }
}

-(void)addNote:(NSString*)noteStr forCategory:(NSString*)category {
    
    if (category.length == 0) {
        return;
    }
    
    NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];

    Note *note = [self getNoteForSection:category];
    if (!note) {
        // is a new note...
        note = (Note*)[agg createNewObject];
        note.dateTime = [NSDate date];
    }
    
    note.notes = noteStr;
    note.title = noteStr;
    note.category = category;
    note.parentBarcode = self.header.rcoBarcode;
    note.parentObjectId = self.header.rcoObjectId;
    note.parentObjectType = self.header.rcoObjectType;
    // 18.03.2020 this is actually the userRecordId of the stydent and is not the creatorRecordId
    note.creatorRecordId = self.student.rcoRecordId;
    [agg save];
    
    // 28.11.2019 we should save it in the memory also, because of the auto saving it might create multiple times the same note
    if (!self.notes) {
        self.notes = [NSMutableArray array];
    }
    if (![self.notes containsObject:note]) {
        [self.notes addObject:note];
    }

    if ([self.header existsOnServerNew]) {
        [agg createNewRecord:note];
    }
}

-(NSString*)getScreenTitle {
    if (self.header) {
        NSString *tmp = nil;
        if ([self.formNumber isEqualToString:TestBTW]) {
            tmp = @"Behind Wheel";
        } else {
            tmp = [NSString stringWithFormat:@"%@", self.header.name];
        }
        if (![self.header existsOnServerNew]) {
            tmp = [NSString stringWithFormat:@"%@ (Not Saved)", tmp];
        }
        return tmp;
    } else {
        return @"New";
    }
}

-(BOOL)testEnded {
    // 22.03.2019 we should allow editing the test ...
    if (self.header.startDateTime && self.header.endDateTime && !self.isEditing) {
        return YES;
    }
    return NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"] registerForCallback:self];
    [[self aggregate] registerForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"SignatureDetail"] registerForCallback:self];
    [self startAutoSave];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"] unRegisterForCallback:self];
    [[self aggregate] unRegisterForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"SignatureDetail"] unRegisterForCallback:self];
    [self stopAutoSave];
}

-(void)loadPrevTestHeader {
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (parentMobileRecordId.length) {
        TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[self aggregate];
        self.header = [agg getStartedTestDataHeaderForTestInfo:parentMobileRecordId andFormNumber:self.formNumber];
        BOOL isDrivingSchool = [[Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL] boolValue];

        if (self.useTheNewLogicForStartingAndLoading && !self.header && !isDrivingSchool) {
            self.specialSectionValues = [NSMutableArray array];
            [self createTestDataHeaderRecordLocaly];
        }
    }
}

-(TrainingTestInfo*)getPreviusSavedTest {
    
    NSString *prevTestInfoMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!prevTestInfoMobileRecordId.length) {
        return nil;
    }
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingTestInfo"];
    TrainingTestInfo *testInfo = (TrainingTestInfo*)[agg getObjectWithMobileRecordId:prevTestInfoMobileRecordId];
    return testInfo;
}

-(void)loadObject {
    self.values = [NSMutableDictionary dictionary];
    
    self.dateTime = self.header.dateTime;
    if (!self.dateTime) {
        self.dateTime = [NSDate date];
    }
    [self.values setObject:self.dateTime forKey:@"dateTime"];
    
    if (!self.header) {
        [self loadPrevTestHeader];
        [self loadPrevInstructor];
        [self loadPrevStudent];
        [self.values removeObjectForKey:KeyStartDateTime];
        self.pausedDate = nil;
        //20.01.2020 we should load some defaults
        [self loadDefaultValuesForSwitches];
    }
    if (self.header.dotExpirationDate) {
        self.dotExpirationDate = self.header.dotExpirationDate;
    }
    if (self.dotExpirationDate) {
        [self.values setObject:self.dotExpirationDate forKey:@"dotExpirationDate"];
    }
    if (self.header.driverLicenseExpirationDate) {
        self.driverLicenseExpirationDate = self.header.driverLicenseExpirationDate;
    }
    
    if (self.driverLicenseExpirationDate) {
        [self.values setObject:self.driverLicenseExpirationDate forKey:@"driverLicenseExpirationDate"];
    }

    if (self.header.startDateTime) {
        [self.values setObject:self.header.startDateTime forKey:KeyStartDateTime];
    }
    
    if (self.header && !self.student) {
        //11/12/2019 just for backup
        [self loadPrevStudent];
    }
    
    if (self.header.driverLicenseNumber.length && self.header.driverLicenseState.length) {
        // we should load the stident based on driver license state and driver license number. this should be unique
        /*
         11.12.2019 we already loaded the student
        UserAggregate *studentAggregate = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
        self.student = [studentAggregate getUserWithdDriverLicenseNumber:self.header.driverLicenseNumber andState:self.header.driverLicenseState];
        */
        if (self.student.userId) {
            [self.values setObject:self.student.userId forKey:@"employeeId"];
        }
    }
    
    if (self.header.instructorEmployeeId.length) {
        

        if (self.instructor.userId) {
            [self.values setObject:self.instructor.userId forKey:@"instructorEmployeeId"];
        }
        if (self.header && !self.instructor) {
            //11/12/2019 just for backup
            [self loadPrevInstructor];
        }
    }
    
    if ([self.formNumber isEqualToString:TestVRT] && self.header.qualifiedYesNo) {
        if ([self.header.qualifiedYesNo boolValue] || !self.header.qualifiedYesNo.length) {
            self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, KeyEquipmentUsed, KeyQualifiedOrNot, @"testRemarks", nil];
            self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Equipment Used", @"Qualified", @"Remarks",  nil];
        } else {
            self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, KeyEquipmentUsed, KeyQualifiedOrNot, @"testRemarks", @"disqualifiedRemarks",@"location", nil];
            self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Equipment Used", @"Qualified", @"Remarks", @"Disqualified Notes", @"Location",  nil];
        }
    }

    for (NSString *field in self.fields) {
        if ([field isEqualToString:KeyEquipmentUsed]) {
            // 19.12.2019 this is actually in the detail  is an ugly workaround
            continue;
        }
        NSString *value = [self.header valueForKey:field];
        if ([self.textFields containsObject:field]) {
            value = [TestDataHeader decodeText:value];
        }
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }
    
    // we should load the fields
    for (NSString *key in self.bottomSection) {
        SEL sel = NSSelectorFromString(key);
        if ([self.header respondsToSelector:sel]) {
            id object = [self.header valueForKey:key];
            if (object) {
                [self.values setObject:object forKey:key];
            }
        }
    }

    if (self.student.company) {
        [self loadCompanyWithName:self.student.company];
        if (!self.company) {
            [self.values removeObjectForKey:@"company"];
        } else {
            [self.values setObject:self.student.company forKey:@"company"];
        }
    } else if (self.header.company.length){
        // bad data ....
        [self loadCompanyWithName:self.header.company];
        if (!self.company) {
            [self.values removeObjectForKey:@"company"];
        } else {
            [self.values setObject:self.header.company forKey:@"company"];
        }
    }
    
    self.detailsInfo = [NSMutableDictionary dictionary];
    self.scores = [NSMutableDictionary dictionary];
    self.detailsNames = [NSMutableArray array];
    
    // 25.03.2019 we should keep all the forms in memroy to be able to access quickly..
    self.testFormItems = nil;
    TestFormAggregate *agg = (TestFormAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestForm"];
    
    self.testFormItems = [agg getTestItems:self.formNumber];

    if (self.header) {
        NSArray *formDetails = [[self aggregate] getObjectDetails:self.header.rcoObjectId];
                
        // there is testdata detail and signature detail
        NSPredicate *classPredicate = [NSPredicate predicateWithFormat:@"class == %@", [TestDataDetail class]];
        formDetails = [formDetails filteredArrayUsingPredicate:classPredicate];
        
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"testSectionNumber" ascending:YES];
        //NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"testItemNumber" ascending:YES];
        
        NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"testItemNumber"
                                                             ascending:YES
                                                            comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *str1 = (NSString*)obj1;
            NSString *str2 = (NSString*)obj2;
            if (str1.length < str2.length) {
                return NSOrderedAscending;
            } else if (str1.length == str2.length) {
                return [str1 compare:str2];
            } else {
                return NSOrderedDescending;
            }
        }];

        formDetails = [formDetails sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];

        self.details = [NSMutableArray arrayWithArray:formDetails];
        NSInteger currentSection = 0;
        
        for (NSInteger i = 0; i < formDetails.count; i++) {

            TestDataDetail *tdd = [formDetails objectAtIndex:i];
            NSString *section = tdd.testSectionName;
                        
            if (![self.detailsNames containsObject:section]) {
                if (!section) {
                    continue;
                }
                [self.detailsNames addObject:section];
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [self.specialSectionValues addObject:dict];
            }
            
            currentSection = [self.detailsNames indexOfObject:section];
            NSArray *specialInputFields = [NSArray arrayWithObjects:@"Location", @"Trailer", @"Odometer", nil];

            if ([specialInputFields containsObject:tdd.testItemName]) {
                
                if (currentSection != NSNotFound) {
                    NSMutableDictionary *dict = [self.specialSectionValues objectAtIndex:currentSection];
                    if (tdd.location.length) {
                        [dict setObject:tdd.location forKey:@"location"];
                    }
                    if (tdd.trailerNumber.length) {
                        [dict setObject:tdd.trailerNumber forKey:@"trailerNumber"];
                    }
                    if (tdd.odometer.length) {
                        [dict setObject:tdd.odometer forKey:@"odometer"];
                    }
                    [self.specialSectionValues replaceObjectAtIndex:currentSection withObject:dict];
                }
            }
            
            NSMutableArray *sectionItems = [self.detailsInfo objectForKey:section];
            if (!sectionItems) {
                sectionItems = [NSMutableArray array];
            }
            [sectionItems addObject:tdd];
            [self.detailsInfo setObject:sectionItems forKey:section];
            
            NSMutableArray *sc = [self.scores objectForKey:section];
            if (!sc) {
                sc = [NSMutableArray array];
            }
            NSInteger score = [tdd.score integerValue];

            /*
             24.04.2019 we will use -1 for NA
            if (score == 0) {
                //22.04.2019 we should set to -1 to select N/A
                //scoreIndex = 0;
                score = -1;
            }
             */
            [sc addObject:[NSNumber numberWithInteger:score]];
            [self.scores setObject:sc forKey:section];
        }
        
        if (self.header.startDateTime) {
        // is started
            if (self.header.endDateTime) {
                self.isEnded = YES;
                NSString *btnTitle = [NSString stringWithFormat:@"%@/%@", self.header.pointsReceived, self.header.pointsPossible];
                [self.possRecvBtn setTitle:btnTitle];
            } else {
            }
            [self customizeBottomToolbar];
        }
        
        if (formDetails.count < self.testFormItems.count) {
            //30.10.2019 we need to load the missing sections. This is what happen if they started a test from webportal and they didin't finished
            NSLog(@"");
            [self loadDetailsFromTestSetupAndCheckExisting:YES];
        }
    } else {
        // we should use the prev instructor ....
        // 30.10.2019 we should use this function
        if ([self.formNumber isEqualToString:TestProd]) {
            [self addNewSection];
        } else {
            [self loadDetailsFromTestSetupAndCheckExisting:NO];
        }
    }
    
    [self calculateScores];
    [self customizeTopToolbar];
    [self.tableView reloadData];
}

-(BOOL)isTestItemCritical:(NSString*)itemNumber forSectionNumber:(NSString*)testSectionNumber {

    if (!itemNumber.length || !testSectionNumber.length) {
        return NO;
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"itemNumber = %@ and sectionNumber = %@", itemNumber, testSectionNumber];
    NSArray *res = [self.testFormItems filteredArrayUsingPredicate:p];
    if (res.count) {
        TestForm *tf = [res objectAtIndex:0];
        if ([tf.categName17 isEqualToString:@"Critical Section"] && [tf.categValue17 isEqualToString:@"yes"]) {
            return YES;
        }
    }
    return NO;
}

-(void)loadObjectDetailsAndReload:(BOOL)reload {
            
    self.detailsInfo = [NSMutableDictionary dictionary];
    self.scores = [NSMutableDictionary dictionary];
    self.detailsNames = [NSMutableArray array];
    
    // 25.03.2019 we should keep all the forms in memroy to be able to access quickly..
    self.testFormItems = nil;
    TestFormAggregate *agg = (TestFormAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestForm"];
    
    self.testFormItems = [agg getTestItems:self.formNumber];

    if (self.header) {
        NSArray *formDetails = [[self aggregate] getObjectDetails:self.header.rcoObjectId];
                
        // there is testdata detail and signature detail
        NSPredicate *classPredicate = [NSPredicate predicateWithFormat:@"class == %@", [TestDataDetail class]];
        formDetails = [formDetails filteredArrayUsingPredicate:classPredicate];
        
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"testSectionNumber" ascending:YES];
        //NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"testItemNumber" ascending:YES];
        
        NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"testItemNumber"
                                                             ascending:YES
                                                            comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *str1 = (NSString*)obj1;
            NSString *str2 = (NSString*)obj2;
            if (str1.length < str2.length) {
                return NSOrderedAscending;
            } else if (str1.length == str2.length) {
                return [str1 compare:str2];
            } else {
                return NSOrderedDescending;
            }
        }];


        formDetails = [formDetails sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];

        self.details = [NSMutableArray arrayWithArray:formDetails];
        NSInteger currentSection = 0;
        
        for (NSInteger i = 0; i < formDetails.count; i++) {

            TestDataDetail *tdd = [formDetails objectAtIndex:i];
            NSString *section = tdd.testSectionName;
            
            if (![self.detailsNames containsObject:section]) {
                [self.detailsNames addObject:section];
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [self.specialSectionValues addObject:dict];
            }
            
            currentSection = [self.detailsNames indexOfObject:section];
            NSArray *specialInputFields = [NSArray arrayWithObjects:@"Location", @"Trailer", @"Odometer", nil];

            if ([specialInputFields containsObject:tdd.testItemName]) {
                
                if (currentSection != NSNotFound) {
                    NSMutableDictionary *dict = [self.specialSectionValues objectAtIndex:currentSection];
                    if (tdd.location) {
                        [dict setObject:tdd.location forKey:@"location"];
                    }
                    if (tdd.trailerNumber) {
                        [dict setObject:tdd.trailerNumber forKey:@"trailerNumber"];
                    }
                    if (tdd.odometer) {
                        [dict setObject:tdd.odometer forKey:@"odometer"];
                    }
                    [self.specialSectionValues replaceObjectAtIndex:currentSection withObject:dict];
                }
            }
            
            NSMutableArray *sectionItems = [self.detailsInfo objectForKey:section];
            if (!sectionItems) {
                sectionItems = [NSMutableArray array];
            }
            [sectionItems addObject:tdd];
            [self.detailsInfo setObject:sectionItems forKey:section];
            
            NSMutableArray *sc = [self.scores objectForKey:section];
            if (!sc) {
                sc = [NSMutableArray array];
            }
            NSInteger score = [tdd.score integerValue];

            [sc addObject:[NSNumber numberWithInteger:score]];
            [self.scores setObject:sc forKey:section];
        }
        
        if (self.header.startDateTime) {
        // is started
            if (self.header.endDateTime) {
                self.isEnded = YES;
                NSString *btnTitle = [NSString stringWithFormat:@"%@/%@", self.header.pointsReceived, self.header.pointsPossible];
                [self.possRecvBtn setTitle:btnTitle];
            } else {
            }
            [self customizeBottomToolbar];
        }
        
        if (formDetails.count < self.testFormItems.count) {
            //30.10.2019 we need to load the missing sections. This is what happen if they started a test from webportal and they didin't finished
            NSLog(@"");
            [self loadDetailsFromTestSetupAndCheckExisting:YES];
        }
    } else {
        // we should use the prev instructor ....
        // 30.10.2019 we should use this function
        if ([self.formNumber isEqualToString:TestProd]) {
            [self addNewSection];
        } else {
            [self loadDetailsFromTestSetupAndCheckExisting:NO];
        }
    }
    
    [self calculateScores];
    [self customizeTopToolbar];
    
    if (reload) {
        [self.tableView reloadData];
    }
}

-(void)loadDetailsFromTestSetupAndCheckExisting:(BOOL)check {
    NSInteger na = 0;
    for (TestForm *tf in self.testFormItems) {
        
        self.title = tf.name;
        
        NSString *section = tf.sectionName;
        if (![self.detailsNames containsObject:section]) {
            [self.detailsNames addObject:section];
        }

        NSMutableArray *sectionItems = [self.detailsInfo objectForKey:section];
        if (!sectionItems) {
            sectionItems = [NSMutableArray array];
        }
        // 30.10.2019 we should check if the section items contains this detail or not
        if (check) {
            NSLog(@"");
            if (sectionItems.count) {
                RCOObject *detail = [sectionItems objectAtIndex:0];
                if ([detail isKindOfClass:[TestDataDetail class]]) {
                    continue;
                }
            }
        }
        [sectionItems addObject:tf];
        [self.detailsInfo setObject:sectionItems forKey:section];
    
        NSMutableArray *sc = [self.scores objectForKey:section];
        if (!sc) {
            sc = [NSMutableArray array];
        }
        if ([self.formNumber isEqualToString:TestVRT]) {
            
            BOOL setDefaultToOk = NO;
            if ([tf.sectionNumber isEqualToString:@"01"]) {
                setDefaultToOk = YES;
            }
            
            // 04.03.2020 we shuld set all to default to ok
            setDefaultToOk = YES;
            
            if ([tf.itemName isEqualToString:@"Score"]) {
                // we should set N/A for Score detail
                [sc addObject:[NSNumber numberWithInteger:-1]];
            } else if (/*[tf.sectionNumber isEqualToString:@"01"]*/setDefaultToOk) {
                // we should prepopulate with "OK" section 1
                [sc addObject:[NSNumber numberWithInteger:1]];
            } else {
                [sc addObject:[NSNumber numberWithInteger:-1]];
            }
        } else if (self.useNADefault) {
            [sc addObject:[NSNumber numberWithInteger:-1]];
        } else if ([tf.pointsPossible integerValue] == 0) {
            // we should make these ones N/A by default
            [sc addObject:[NSNumber numberWithInteger:-1]];
            na += 1;
        } else {
            [sc addObject:[NSNumber numberWithInteger:0]];
        }

        [self.scores setObject:sc forKey:section];
    }
    NSLog(@"");
}

-(void)addNewSection {
    NSInteger na = 0;
    //NSString *sectionName = [[NSDate date] time24HourHormat];
    NSString *sectionName = [[NSDate date] dateTime24HFormat];
    
    NSString *sectionNumber = [NSString stringWithFormat:@"%d", (int)(self.detailsNames.count + 1)];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self.specialSectionValues addObject:dict];
    
    if (!self.detailsNames) {
        self.detailsNames = [NSMutableArray array];
    }
    if (!self.detailsInfo) {
        self.detailsInfo = [NSMutableDictionary dictionary];
    }
    if (!self.scores) {
        self.scores = [NSMutableDictionary dictionary];
    }
    
    if (!self.testFormItems.count) {
        TestFormAggregate *agg = (TestFormAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestForm"];
        self.testFormItems = [agg getTestItems:self.formNumber];
    }
    
    for (TestForm *tfd in self.testFormItems) {
        TestDataDetail *td = [self addUpdateDetail:tfd
                                          andScore:[NSString stringWithFormat:@"%d", 0]
                                    seachForDetail:[NSNumber numberWithBool:YES]
                                    forSectionName:sectionName
                                  andSectionNumber:sectionNumber];

        td.name = sectionName;

        if (![self.details containsObject:td]) {
            [self.details addObject:td];
        }
        
        NSString *section = sectionName;
        if (![self.detailsNames containsObject:section]) {
            [self.detailsNames addObject:section];
        }

        NSMutableArray *sectionItems = [self.detailsInfo objectForKey:section];
        if (!sectionItems) {
            sectionItems = [NSMutableArray array];
        }
        // 30.10.2019 we should check if the section items contains this detail or not
        /*
        if (check) {
            NSLog(@"");
            if (sectionItems.count) {
                RCOObject *detail = [sectionItems objectAtIndex:0];
                if ([detail isKindOfClass:[TestDataDetail class]]) {
                    continue;
                }
            }
        }
        */
        [sectionItems addObject:td];
        [self.detailsInfo setObject:sectionItems forKey:section];
    
        NSMutableArray *sc = [self.scores objectForKey:section];
        if (!sc) {
            sc = [NSMutableArray array];
        }
        if (self.useNADefault) {
            [sc addObject:[NSNumber numberWithInteger:-1]];
        } else if ([tfd.pointsPossible integerValue] == 0) {
            // we should make these ones N/A by default
            [sc addObject:[NSNumber numberWithInteger:-1]];
            na += 1;
        } else {
            [sc addObject:[NSNumber numberWithInteger:0]];
        }

        [self.scores setObject:sc forKey:section];
    }
    NSLog(@"");
}


-(NSString*)getTeachingStringsForSection:(NSString*)section {

    if (!section.length) {
        return nil;
    }
    return nil;
}

-(NSString*)getTeachingStringForSection:(NSString*)section andItem:(NSString*)item {

    if (!section.length || !item.length) {
        return nil;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionName=%@ and itemNumber=%@", section, item];
    NSArray *res = [self.testFormItems filteredArrayUsingPredicate:predicate];
    TestForm *tf = nil;
    if (res.count) {
        tf = [res objectAtIndex:0];
    }
    return tf.testTeachingString;
}

#pragma mark Actions

-(IBAction)previewButtonPressed:(id)sender {
    NSURL *fileURL = nil;
    NSString *tile = nil;
    
    if ([self.formNumber isEqualToString:TestBusEval]) {
        fileURL = [[NSBundle mainBundle] URLForResource:@"busEval" withExtension:@"html"];
        tile = @"busEval";
    } else if ([self.formNumber isEqualToString:TestPreTrip]) {
        fileURL = [[NSBundle mainBundle] URLForResource:@"preTrip" withExtension:@"html"];
        tile = @"preTrip";
    } else if ([self.formNumber isEqualToString:TestBTW]) {
        fileURL = [[NSBundle mainBundle] URLForResource:@"classC" withExtension:@"html"];
        tile = @"classC";
    } else if ([self.formNumber isEqualToString:TestSWP]) {
        fileURL = [[NSBundle mainBundle] URLForResource:@"swp" withExtension:@"html"];
        tile = @"SWP";
    }  else if ([self.formNumber isEqualToString:TestProd]) {
        fileURL = [[NSBundle mainBundle] URLForResource:@"prod" withExtension:@"html"];
        tile = @"Prod";
    }  else if ([self.formNumber isEqualToString:TestVRT]) {
        fileURL = [[NSBundle mainBundle] URLForResource:@"vrt" withExtension:@"html"];
        tile = @"VRT";
       }  else {
        NSString *msg = [NSString stringWithFormat:@"Unknown form number: %@", self.formNumber];
        [self showSimpleMessage:msg];
        return;
    }
    
    BOOL forceSave = self.autoSaveEnabled;
    
    // 30.01.2020 we should not use this flag anymore ....
    forceSave = YES;
    if (forceSave) {
        [self saveButtonPressed:self.autoSaveTimer];
    }
    
    WebViewViewController *controller = [[WebViewViewController alloc] initWithNibName:@"WebViewViewController"
                                                                                bundle:nil
                                                                               fileURL:fileURL];
    controller.htmlName = tile;
    controller.addDelegate = self;
    controller.addDelegateKey = Key_Preview;
    controller.params = nil;
    controller.object = self.header;
    controller.details = self.details;
    controller.showEmailButton = YES;
    controller.aggregate = [self aggregate];
    controller.notes = self.notes;
    controller.formNumber = self.formNumber;
    controller.fieldsNA = self.fieldsNA;

    if ([self.header.number isEqualToString:TestSWP]) {
        // SWP
        controller.chartKeys1 = [self getCategories];
        controller.chartValues1 = [self getChartValues];
        controller.chartKeys2 = self.detailsNames;
        controller.chartValues2 = [self getPercentage];
    } else if ([self.header.number isEqualToString:TestPreTrip]) {
        // Pretrip
        controller.chartKeys1 = self.detailsNames;
        //controller.chartValues1 = [self getChartValues];
        controller.chartValues1 = [self getPercentageCriticalValues];
        
        controller.chartKeys2 = self.detailsNames;
        //controller.chartValues2 = [self getPercentageCriticalValues];
        controller.chartValues2 = [self getPercentage];
        controller.testCristicalItems = self.criticalItemsNewFormat;
    } else {
        controller.chartKeys1 = [self getCategories];
        controller.chartValues1 = [self getChartValues];
        
        controller.chartKeys2 = self.detailsNames;
        controller.chartValues2 = [self getPercentage];
    }

    NSMutableDictionary *extraParameters = [NSMutableDictionary dictionary];
    
    NSString *companyRepresentativeName = [self.values objectForKey:Key_CompanyRepresentative];
    if (!companyRepresentativeName.length) {
        companyRepresentativeName = @" ";
    }
    if (companyRepresentativeName.length && self.compRepSignature) {
        [extraParameters setObject:companyRepresentativeName forKey:@"pdf_company_rep_signature_name"];
        [extraParameters setObject:self.compRepSignature forKey:KeySignatureCompanyRepresentative];
    }
    
    NSString *driverName = [self.student Name];
    if (driverName.length  && self.driverSignature) {
        [extraParameters setObject:driverName forKey:@"pdf_driver_signature_name"];
        [extraParameters setObject:self.driverSignature forKey:KeySignatureDriver];
    }
    
    NSString *instructorName = [self.instructor Name];
    if (instructorName.length  && self.evaluatorSignature) {
        [extraParameters setObject:instructorName forKey:@"pdf_evaluators_signature_name"];
        [extraParameters setObject:self.evaluatorSignature forKey:KeySignatureEvaluator];
    }
    
    NSString *turnsMapPath = [DriverTurn imagePathForStudentRecordId:self.student.rcoRecordId andDateTime:self.header.dateTime];
    if (turnsMapPath) {
        [extraParameters setObject:turnsMapPath forKey:DriverTurnImageMapKey];
    }
    
    [extraParameters setObject:[self getTestReason] forKey:@"reasons"];
    
    NSMutableString *observer = [NSMutableString stringWithString:@""];
    if (self.header.observerLastName.length) {
        [observer appendFormat:@"%@ ", self.header.observerLastName];
    }
    if (self.header.observerFirstName.length) {
        [observer appendFormat:@"%@ ", self.header.observerFirstName];
    }
    
    [extraParameters setObject:observer forKey:@"observer"];

    if (self.student) {
        [extraParameters setObject:[self.student Name] forKey:@"pdf_driver_name"];
        if ([self.formNumber isEqualToString:TestVRT]) {
            [extraParameters setObject:[self.student Name] forKey:@"dmv_driverName"];
        }
    } else {
        [extraParameters setObject:@" " forKey:@"pdf_driver_name"];
        if ([self.formNumber isEqualToString:TestVRT]) {
            [extraParameters setObject:@" " forKey:@"dmv_driverName"];
        }
    }
    
    if ([self.formNumber isEqualToString:TestVRT]) {
        if (self.student.driverLicenseNumber) {
            [extraParameters setObject:self.header.driverLicenseNumber forKey:@"dmv_driverLicenseNumber"];
        } else {
            [extraParameters setObject:@" " forKey:@"dmv_driverLicenseNumber"];
        }
        if (self.student.employeeNumber) {
            [extraParameters setObject:self.student.employeeNumber forKey:@"dmv_employeeId"];
        } else {
            [extraParameters setObject:@" " forKey:@"dmv_employeeId"];
        }
        
        if ([self.header.qualifiedYesNo isEqualToString:@"no"]) {
            [extraParameters setObject:@"X" forKey:@"notQualified1"];
            [extraParameters setObject:@"X" forKey:@"notQualified2"];
            [extraParameters setObject:@" " forKey:@"qualified1"];
            [extraParameters setObject:@" " forKey:@"qualified2"];
        } else if ([self.header.qualifiedYesNo isEqualToString:@"yes"]) {
            [extraParameters setObject:@" " forKey:@"notQualified1"];
            [extraParameters setObject:@" " forKey:@"notQualified2"];
            [extraParameters setObject:@"X" forKey:@"qualified1"];
            [extraParameters setObject:@"X" forKey:@"qualified2"];
        } else {
            [extraParameters setObject:@" " forKey:@"notQualified1"];
            [extraParameters setObject:@" " forKey:@"notQualified2"];
            [extraParameters setObject:@" " forKey:@"qualified1"];
            [extraParameters setObject:@" " forKey:@"qualified2"];
        }
        
        if (self.header.testRemarks) {
            [extraParameters setObject:[TestDataHeader decodeText:self.header.testRemarks] forKey:@"testRemarks"];
            [extraParameters setObject:[self.header.testRemarks stringByReplacingOccurrencesOfString:@"<br>" withString:@" "] forKey:@"testRemarks"];
        } else {
            [extraParameters setObject:@"" forKey:@"testRemarks"];
        }
        
        if (self.header.disqualifiedRemarks) {
            [extraParameters setObject:self.header.disqualifiedRemarks forKey:@"disqualifiedRemarks"];
        } else {
            [extraParameters setObject:@"" forKey:@"disqualifiedRemarks"];
        }
        
        if (self.header.testMiles) {
            [extraParameters setObject:self.header.testMiles forKey:@"miles1"];
            [extraParameters setObject:self.header.testMiles forKey:@"miles2"];
        } else {
            [extraParameters setObject:@" " forKey:@"miles1"];
            [extraParameters setObject:@" " forKey:@"miles2"];
        }
        
        NSInteger day = [NSDate dayAsNumber:self.header.dateTime];
        NSInteger month = [NSDate monthAsNumber:self.header.dateTime];
        NSInteger year = [NSDate yearAsNumber:self.header.dateTime];

        
        

        [extraParameters setObject:[NSString stringWithFormat:@"%02d", (int)month] forKey:@"month1"];
        [extraParameters setObject:[NSString stringWithFormat:@"%02d", (int)month] forKey:@"month2"];

        [extraParameters setObject:[NSString stringWithFormat:@"%02d", (int)day] forKey:@"day1"];
        [extraParameters setObject:[NSString stringWithFormat:@"%02d", (int)day] forKey:@"day2"];

        [extraParameters setObject:[NSString stringWithFormat:@"%02d", (int)year] forKey:@"year1"];
        [extraParameters setObject:[NSString stringWithFormat:@"%02d", (int)year] forKey:@"year2"];
        if (self.student.driverLicenseState) {
            [extraParameters setObject:self.student.driverLicenseState forKey:@"dmv_driverLicenseState"];
        } else {
            [extraParameters setObject:@"" forKey:@"dmv_driverLicenseState"];
        }
    }
    
    if (self.header.powerUnit) {
        [extraParameters setObject:self.header.powerUnit forKey:@"powerUnit"];
    }
    if ([self.formNumber isEqualToString:TestVRT]) {
        NSString *powerUnit = self.header.powerUnit;
        
        if (!powerUnit) {
            powerUnit = @"";
        }
        [extraParameters setObject:powerUnit forKey:@"powerUnit"];
    }

    if (self.header.location) {
        [extraParameters setObject:self.header.location forKey:@"pdf_evaluation_location"];
    } else {
        [extraParameters setObject:@"" forKey:@"pdf_evaluation_location"];
    }

    if (self.header.numberofTrailers) {
        [extraParameters setObject:self.header.numberofTrailers forKey:@"numberofTrailers"];
    } else {
        [extraParameters setObject:@"" forKey:@"numberofTrailers"];
    }

    if (self.header.trailerLength) {
        [extraParameters setObject:self.header.trailerLength forKey:@"trailerLength"];
    } else {
        [extraParameters setObject:@"" forKey:@"trailerLength"];
    }

    if (self.header.evaluatorName) {
        [extraParameters setObject:self.header.evaluatorName forKey:@"evaluatorName"];
    } else {
        [extraParameters setObject:@"" forKey:@"evaluatorName"];
    }

    if (self.header.evaluatorTitle) {
        [extraParameters setObject:self.header.evaluatorTitle forKey:@"evaluatorTitle"];
    } else {
        [extraParameters setObject:@"" forKey:@"evaluatorTitle"];
    }
    
    if (self.header.testState) {
        [extraParameters setObject:self.header.testState forKey:@"testState"];
    } else {
        [extraParameters setObject:@" " forKey:@"testState"];
    }

    if (self.header.medicalCardExpirationDate) {
        NSString *date = [self.header.driverLicenseExpirationDate rcoDateRMSToString:self.header.medicalCardExpirationDate];
        [extraParameters setObject:date forKey:@"medicalCardExpirationDate"];
    } else {
        [extraParameters setObject:@" " forKey:@"testState"];
    }

    
    if (self.header.driverLicenseExpirationDate) {
        NSString *date = [self.header.driverLicenseExpirationDate rcoDateRMSToString:self.header.driverLicenseExpirationDate];
        [extraParameters setObject:date forKey:@"driverLicenseExpirationDateBottom"];
        if ([self.formNumber isEqualToString:TestVRT]) {
            [extraParameters setObject:date forKey:@"dmv_driverLicenseExpirationDate"];
        }
    } else {
        [extraParameters setObject:@"" forKey:@"driverLicenseExpirationDateBottom"];
        if ([self.formNumber isEqualToString:TestVRT]) {
            [extraParameters setObject:@"" forKey:@"dmv_driverLicenseExpirationDate"];
        }
    }
    
    if (self.header.onTime) {
        [extraParameters setObject:self.header.onTime forKey:@"onTime"];
    } else {
        [extraParameters setObject:@"" forKey:@"onTime"];
    }

    if (self.header.keysReady) {
        [extraParameters setObject:self.header.keysReady forKey:@"keysReady"];
    } else {
        [extraParameters setObject:@"" forKey:@"keysReady"];
    }
    
    if (self.header.timecardSystemReady) {
        [extraParameters setObject:self.header.timecardSystemReady forKey:@"timecardSystemReady"];
    } else {
        [extraParameters setObject:@"" forKey:@"timecardSystemReady"];
    }

    if (self.header.equipmentReady) {
        [extraParameters setObject:self.header.equipmentReady forKey:@"equipmentReady"];
    } else {
        [extraParameters setObject:@"" forKey:@"equipmentReady"];
    }

    if (self.header.equipmentClean) {
        [extraParameters setObject:self.header.equipmentClean forKey:@"equipmentClean"];
    } else {
        [extraParameters setObject:@"" forKey:@"equipmentClean"];
    }

    if (self.header.startOdometer) {
        [extraParameters setObject:self.header.startOdometer forKey:@"startOdometer"];
    } else {
        [extraParameters setObject:@"" forKey:@"startOdometer"];
    }

    if (self.header.finishOdometer) {
        [extraParameters setObject:self.header.finishOdometer forKey:@"finishOdometer"];
    } else {
        [extraParameters setObject:@"" forKey:@"finishOdometer"];
    }

    if (self.header.miles) {
        [extraParameters setObject:self.header.miles forKey:@"miles"];
    } else {
        [extraParameters setObject:@"" forKey:@"miles"];
    }

    if (self.header.department) {
        [extraParameters setObject:self.header.department forKey:@"department"];
    } else {
        [extraParameters setObject:@"" forKey:@"department"];
    }
    if (self.header.routeNumber) {
        [extraParameters setObject:self.header.routeNumber forKey:@"routeNumber"];
    } else {
        [extraParameters setObject:@"" forKey:@"routeNumber"];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];

    if (self.header.startDateTime) {
        [extraParameters setObject:[dateFormatter stringFromDate:self.header.startDateTime] forKey:@"startTime"];
    } else {
        [extraParameters setObject:@" " forKey:@"startTime"];
    }

    if (self.header.endDateTime) {
        [extraParameters setObject:[dateFormatter stringFromDate:self.header.endDateTime] forKey:@"endTime"];
    } else {
        [extraParameters setObject:@" " forKey:@"endTime"];
    }

    
    //04.12.2019 we should load extra parameters from TestInfo
    
    TrainingTestInfo *test = [self getPreviusSavedTest];
    if (test.trainingNewHire) {
        [extraParameters setObject:test.trainingNewHire forKey:@"trainingNewHire"];
    }
    if (test.trainingNearMiss) {
        [extraParameters setObject:test.trainingNearMiss forKey:@"trainingNearMiss"];
    }
    if (test.trainingIncidentFollowUp) {
        [extraParameters setObject:test.trainingIncidentFollowUp forKey:@"trainingIncidentFollowUp"];
    }
    if (test.trainingChangeJob) {
        [extraParameters setObject:test.trainingChangeJob forKey:@"trainingChangeJob"];
    }
    if (test.trainingChangeOfEquipment) {
        [extraParameters setObject:test.trainingChangeOfEquipment forKey:@"trainingChangeOfEquipment"];
    }
    if (test.trainingAnnual) {
        [extraParameters setObject:test.trainingAnnual forKey:@"trainingAnnual"];
    }

    // dates
    if (test.trainingInjuryDate) {
        [extraParameters setObject:[NSDate rcoDateDateToString:test.trainingInjuryDate] forKey:@"trainingInjuryDate"];
    } else {
        [extraParameters setObject:@"N/A" forKey:@"trainingInjuryDate"];
    }

    if (test.trainingAccidentDate) {
        [extraParameters setObject:[NSDate rcoDateDateToString:test.trainingAccidentDate] forKey:@"trainingAccidentDate"];
    } else {
        [extraParameters setObject:@"N/A" forKey:@"trainingAccidentDate"];
    }

    if (test.trainingTAWStartDate) {
        [extraParameters setObject:[NSDate rcoDateDateToString:test.trainingTAWStartDate] forKey:@"trainingTAWStartDate"];
    } else {
        [extraParameters setObject:@"N/A" forKey:@"trainingTAWStartDate"];
    }

    if (test.trainingTAWEndDate) {
        [extraParameters setObject:[NSDate rcoDateDateToString:test.trainingTAWEndDate] forKey:@"trainingTAWEndDate"];
    } else {
        [extraParameters setObject:@"N/A" forKey:@"trainingTAWEndDate"];
    }

    if (test.trainingLostTimeStartDate) {
        [extraParameters setObject:[NSDate rcoDateDateToString:test.trainingLostTimeStartDate] forKey:@"trainingLostTimeStartDate"];
    } else {
        [extraParameters setObject:@"N/A" forKey:@"trainingLostTimeStartDate"];
    }

    if (test.trainingReturnToWorkDate) {
        [extraParameters setObject:[NSDate rcoDateDateToString:test.trainingReturnToWorkDate] forKey:@"trainingReturnToWorkDate"];
    } else {
        [extraParameters setObject:@"N/A" forKey:@"trainingReturnToWorkDate"];
    }
    
    
    if ([self.formNumber isEqualToString:TestProd]) {
        //13.12.2019 we should search for the equipment
        NSString *prevOdometer = nil;
        double totalMiles = 0;
        for (NSInteger i=0; i < self.detailsNames.count; i++) {
            NSString *sectionName = [self.detailsNames objectAtIndex:i];
            TrainingEquipment *te = [self.equipmentUsed objectForKey:sectionName];
                NSArray *codingFields = [NSArray arrayWithObjects:@"Trailer", nil];

            for (NSString *field in codingFields) {
                    SEL selector = NSSelectorFromString(field);
                    NSString *val = nil;
                    if ([te respondsToSelector:selector]) {
                        val = [te valueForKey:field];
                    } else {
                        NSLog(@"");
                    }
                    NSString *keyFormatted = [NSString stringWithFormat:@"%d%@", (int)(i+1), field];
                    if (!val) {
                        val = @"N/A";
                    }
                    [extraParameters setObject:val forKey:keyFormatted];
                }
            if (i < self.specialSectionValues.count) {
                NSDictionary *dict = [self.specialSectionValues objectAtIndex:i];
                NSString *location = [dict objectForKey:@"location"];
                NSString *keyFormatted = [NSString stringWithFormat:@"%d%@", (int)(i+1), @"1"];

                if (location) {
                    [extraParameters setObject:location forKey:keyFormatted];
                }
                NSString *odometer = [dict objectForKey:@"odometer"];
                keyFormatted = [NSString stringWithFormat:@"%d%@", (int)(i+1), @"m"];

                if (odometer) {
                    [extraParameters setObject:odometer forKey:keyFormatted];
                }
                keyFormatted = [NSString stringWithFormat:@"%d%@", (int)(i+1), @"Miles"];
                if ([prevOdometer integerValue]) {
                    int miles = [odometer intValue] - [prevOdometer intValue];
                    totalMiles += miles;
                    [extraParameters setObject:[NSString stringWithFormat:@"%d", miles] forKey:keyFormatted];
                } else {
                    [extraParameters setObject:@" " forKey:keyFormatted];
                }
                prevOdometer = odometer;
            }
        }
        // we should calculate the scores
        
        NSMutableArray *totalScores = [NSMutableArray array];
        NSMutableArray *totalScoresPercentages = [NSMutableArray array];

        NSLog(@"");
        for (NSString* section in self.scores.allKeys) {
            NSArray *values = [self.scores objectForKey:section];
            for (NSInteger i = 2; i < values.count - 1; i++) {
                NSInteger j = i-2;
                NSInteger prev = 0;
                NSInteger val = [[values objectAtIndex:i] integerValue];
                if (val < 0) {
                    // we should not subtract negative score like: N/A
                    val = 0;
                }
                NSNumber *v = nil;
                if (j < totalScores.count) {
                    prev = [[totalScores objectAtIndex:j] integerValue];
                    v = [NSNumber numberWithInteger:(val + prev)];
                    [totalScores replaceObjectAtIndex:j withObject:v];
                } else {
                    v = [NSNumber numberWithInteger:val];
                    [totalScores addObject:v];
                }
            }
        }
        NSLog(@"");
        NSInteger max = 5*self.scores.allKeys.count;
        
        for (NSInteger i = 0; i < totalScores.count;i++) {
            NSNumber *s = [totalScores objectAtIndex:i];
            
            // 04.03.2020 we need to calculate the max score for each item, if there are score -1 then we should not add it
            max = [[self getMaxScoresForIndex:i] integerValue];
            
            double p = ([s doubleValue] *100) / (max*1.0);
            [totalScoresPercentages addObject:[NSNumber numberWithInteger:p]];
        }
        NSLog(@"");
        
        for (int i = 0; i < totalScores.count; i++) {
            NSString *key = [NSString stringWithFormat:@"total%d", (i+1)];
            NSString *val = [NSString stringWithFormat:@"%@", [totalScores objectAtIndex:i]];
            [extraParameters setObject:val forKey:key];
        }
        double totalPercentage = 0;
        for (int i = 0; i < totalScoresPercentages.count; i++) {
            NSString *key = [NSString stringWithFormat:@"totalPercentage%d", (i+1)];
            NSNumber *percentage = [totalScoresPercentages objectAtIndex:i];
            NSString *val = [NSString stringWithFormat:@"%@%%", percentage];
            [extraParameters setObject:val forKey:key];
            totalPercentage += [percentage doubleValue];
        }
        
        totalPercentage = totalPercentage/totalScoresPercentages.count;
        
        // set the total percentage
        NSString *key = @"totalPercentage";
        NSNumber *percentage = [NSNumber numberWithInt:totalPercentage];
        NSString *val = [NSString stringWithFormat:@"%@%%", percentage];
        [extraParameters setObject:val forKey:key];

        // set the miles
        key = @"totalMiles";
        NSNumber *miles = [NSNumber numberWithInt:totalMiles];
        val = [NSString stringWithFormat:@"%@", miles];
        [extraParameters setObject:val forKey:key];
        
        NSLog(@"");
    }
    
    controller.htmlExtraKeys = extraParameters;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
}

-(NSNumber*)getMaxScoresForIndex:(NSInteger)scoreIndex {
    // we should not start from the first element, just from the third one
    NSInteger index = scoreIndex + 2;
    NSInteger count = 0;
    for (NSArray *arr in self.scores.allValues) {
        if (index < arr.count) {
            NSInteger score = [[arr objectAtIndex:index] integerValue];
            if (score >= 0) {
                count++;
            }
        } else {
            return [NSNumber numberWithInt:0];
        }
    }
    return [NSNumber numberWithInteger:(count*5)];
}

-(NSString*)getTestReason {
    TrainingTestInfo *test = [self getPreviusSavedTest];
    NSMutableArray *reasons = [NSMutableArray array];
    if (test) {
        if ([test.trainingNewHire boolValue]) {
            [reasons addObject:@"New Hire"];
        }
        if ([test.trainingNearMiss boolValue]) {
            [reasons addObject:@"Near Miss"];
        }
        if ([test.trainingIncidentFollowUp boolValue]) {
            [reasons addObject:@"Incident Follow-up"];
        }
        if ([test.trainingChangeJob boolValue]) {
            [reasons addObject:@"Change Job"];
        }
        if ([test.trainingChangeOfEquipment boolValue]) {
            [reasons addObject:@"Change of Equipment"];
        }
        if ([test.trainingAnnual boolValue]) {
            [reasons addObject:@"Annual"];
        }
    }
    
    if (reasons.count) {
       return [reasons componentsJoinedByString:@","];
    } else {
        return @"";
    }
}

-(TestForm*)getTestItem:(NSString*)itemNumber forSection:(NSString*)testSection {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionNumber=%@ and itemNumber=%@",testSection, itemNumber];
    NSArray *res = [self.testFormItems filteredArrayUsingPredicate:predicate];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}

-(NSArray*)getCategories {
    for (TestDataDetail *td in self.details) {
        TestForm *tt = [self getTestItem:td.testItemNumber forSection:td.testSectionNumber];
        NSArray *categories = [tt getTestCategorieNames];
        if (categories.count) {
            return categories;
        }
    }
    return nil;
}

-(NSArray*)getChartValues {
    NSLog(@"");
    
    NSArray *categories = nil;

    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    NSInteger total = 0;
    
    for (TestDataDetail *td in self.details) {
        TestForm *tt = [self getTestItem:td.testItemNumber forSection:td.testSectionNumber];
        
        if (!categories) {
            categories = [tt getTestCategorieNames];
        }
        for (NSInteger i = 0; i < categories.count; i++) {
            NSString *category = [categories objectAtIndex:i];
            NSInteger existingValue = [[values objectForKey:category] integerValue];
            
            // 04.03.2020 NSString *categValue = [NSString stringWithFormat:@"categoryValue%d", (int)i+1];
            NSString *categValue = [NSString stringWithFormat:@"categValue%d", (int)i+1];

            NSInteger val = [td.score integerValue] * [[tt valueForKey:categValue] integerValue];
            total += val;
            [values setObject:[NSNumber numberWithInteger:(existingValue+val)] forKey:category];
        }
    }
    NSLog(@"");
    NSMutableArray *result = [NSMutableArray array];

    for (NSString *categ in categories) {
        id val = [values objectForKey:categ];

        double percentage = 0;
        if ([val integerValue]) {
            percentage = total*1.0/[val doubleValue];
        }
        [result addObject:[NSNumber numberWithDouble:percentage]];
    }
    return result;
}

-(NSArray*)getPercentageInjuryValues {
    NSMutableArray *percentage = [NSMutableArray array];
    for (NSString *sectionName in self.detailsNames) {
        
        NSArray *scores = [self.scores objectForKey:sectionName];
        NSArray *items = [self.detailsInfo objectForKey:sectionName];
        NSInteger count = 0;
        NSInteger total = 0;
        for (NSInteger i = 0; i < scores.count; i++) {
            NSString *itemNumber = nil;
            NSString *sectionNumber = nil;

            id score = [scores objectAtIndex:i];
            id detail = [items objectAtIndex:i];
            
        }
        if (count) {
            [percentage addObject:[NSNumber numberWithDouble:((total*1.0)/(count*5.0))*100]];
        } else {
            [percentage addObject:[NSNumber numberWithDouble:0]];
        }
    }

    return percentage;
    
}


-(NSArray*)getPercentageCriticalValues {
    NSMutableArray *percentage = [NSMutableArray array];
    for (NSString *sectionName in self.detailsNames) {
        
        NSArray *scores = [self.scores objectForKey:sectionName];
        NSArray *items = [self.detailsInfo objectForKey:sectionName];
        NSInteger count = 0;
        NSInteger total = 0;
        for (NSInteger i = 0; i < scores.count; i++) {
            NSString *itemNumber = nil;
            NSString *sectionNumber = nil;

            id score = [scores objectAtIndex:i];
            id detail = [items objectAtIndex:i];
            
            //04.12.2019 need to check if is critical or not grrr....
            if ([detail isKindOfClass:[TestForm class]]) {
                TestForm *tf = (TestForm*)detail;
                itemNumber = tf.itemNumber;
                sectionNumber = tf.sectionNumber;
            } else {
                TestDataDetail *tdd = (TestDataDetail*)detail;
                itemNumber = tdd.testItemNumber;
                sectionNumber = tdd.testSectionNumber;
            }

            NSString *criticalKey = [NSString stringWithFormat:@"%@%@", sectionNumber, itemNumber];
            BOOL isCritical = [[self.criticalItems objectForKey:criticalKey] boolValue];
            if (!isCritical) {
                continue;
            }

            if ([score integerValue] >= 0) {
                total += [score integerValue];
                count++;
            }
        }
        if (count) {
            [percentage addObject:[NSNumber numberWithDouble:((total*1.0)/(count*5.0))*100]];
        } else {
            [percentage addObject:[NSNumber numberWithDouble:0]];
        }
    }

    return percentage;
    
}


-(NSArray*)getPercentage {
    NSMutableArray *percentage = [NSMutableArray array];
    
    for (NSString *key in /*self.scores.allKeys*/self.detailsNames) {
        
        NSArray *scores = [self.scores objectForKey:key];
        NSInteger count = 0;
        NSInteger total = 0;
        for (id score in scores) {
            if ([score integerValue] >= 0) {
                total += [score integerValue];
                count++;
            }
        }
        if (count) {
            [percentage addObject:[NSNumber numberWithDouble:((total*1.0)/(count*5.0))*100]];
        } else {
            [percentage addObject:[NSNumber numberWithDouble:0]];
        }
    }
    return percentage;
}

-(void)calculateValues_OLD {
    NSString *JSpath = [[NSBundle mainBundle] pathForResource:@"CSD_Chart_Factors" ofType:@"csv"];
    
    NSError *error = nil;
    NSString *val = [NSString stringWithContentsOfFile:JSpath
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    NSArray *lines = [val componentsSeparatedByString:@"\n"];
    NSArray *headers = [[lines objectAtIndex:0] componentsSeparatedByString:@","];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.length>0"];
    
    headers = [headers filteredArrayUsingPredicate:predicate];
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    NSString *currentSection = nil;
    NSInteger subSectionIndex = 0;
    
    for (NSString *line in lines) {
        
        NSArray *lineComp = [line componentsSeparatedByString:@","];
        lineComp = [lineComp filteredArrayUsingPredicate:predicate];

        if (!lineComp.count) {
            continue;
        }
        
        NSString *currentSubsection = nil;
        
        if (lineComp.count <=2) {
            currentSection = [lineComp objectAtIndex:0];
            subSectionIndex = 0;
        } else {
            currentSubsection = [lineComp objectAtIndex:0];
            NSArray *scores = [self.scores objectForKey:currentSection];
            NSLog(@"section %@ Scores %@", currentSection, scores);
            if (!scores) {
                NSLog(@"!!!!!!section %@", currentSection);
            }
            
            if (subSectionIndex < scores.count) {
                NSInteger score = [[scores objectAtIndex:subSectionIndex] integerValue];
                for (NSInteger j = 1; j< lineComp.count; j++) {
                    NSString *v = [lineComp objectAtIndex:j];
                    if (![v integerValue]) {
                        break;
                    }
                    NSString *header = [headers objectAtIndex:(j-1)];

                    NSInteger prevValue = [[values objectForKey:header] integerValue];

                    NSInteger factor = [[lineComp objectAtIndex:j] integerValue];
                    double currentVal = prevValue + score*factor;
                    [values setObject:[NSNumber numberWithInteger:currentVal] forKey:header];
                }
                
            } else {
                NSLog(@"Crashhhhhh -->>>> ");
            }
            subSectionIndex++;
        }
    }
    
    NSLog(@"bla");
    
    NSLog(@"");

}

-(void)addPauseButton {
    if (self.header.endDateTime) {
        return;
    }
    // we should replace start button with pause button
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
    NSInteger index = [items indexOfObject:self.playBtn];
    if (index != NSNotFound) {
        [items replaceObjectAtIndex:index withObject:self.pauseBtn];
        [self.bottomToolbar setItems:items];
    }
    [self.pauseBtn setEnabled:YES];
}

-(void)addStartButton {
    // we should replace pause button with start button
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
    NSInteger index = [items indexOfObject:self.pauseBtn];
    if (index != NSNotFound) {
        [items replaceObjectAtIndex:index withObject:self.playBtn];
        [self.bottomToolbar setItems:items];
    }
    [self.playBtn setEnabled:YES];
    [self.stopBtn setEnabled:NO];
}

-(IBAction)possibleReceivedButtonPressed:(id)sender {
    
    NSString *message = [NSString stringWithFormat:@"%d points received from %d points possible", (int)[self.header.pointsReceived integerValue], (int)[self.header.pointsPossible integerValue]];
    [self showSimpleMessage:message andTitle:@"Info"];
}



-(IBAction)startButtonPressed:(id)sender {
    NSDate *startDateTime = [NSDate date];

    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!parentMobileRecordId.length) {
        [self showSimpleMessage:@"Please add test info first!"];
        return;
    }

    NSString *message = [self validateInputs];
    if (message) {
        [self showSimpleMessage:message];
        return;
    }

    if (self.isDrivingSchool) {
        if (self.header.endDateTime) {
            // we should check if the test info was ended or not
            TrainingTestInfo *test = [self getPreviusSavedTest];
            if (test.endDateTime) {
                [self showSimpleMessage:@"Test Info is ended. New test can't be added!"];
                return;
            }
            //08.01.2020 we should start a new test ....
            self.values = [NSMutableDictionary dictionary];
            [self addNewTest];
            NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView scrollToRowAtIndexPath:top
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:NO];
        } else {
            [self.header addPauseDateTime:startDateTime];
        }
        [self addPauseButton];
    } else if (self.pausedDate) {
        [Settings resetKey:CSD_TEST_PAUSED_DATE];
        [Settings save];
        
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
        
        NSInteger index = [items indexOfObject:self.playBtn];
        if (index != NSNotFound) {
            [items replaceObjectAtIndex:index withObject:self.pauseBtn];
        }
        [self.bottomToolbar setItems:items];
        [self.stopBtn setEnabled:YES];
        self.isEditing  = YES;
        return;
    }

    [self.turnsBtn setEnabled:YES];
    
    if (![self.values objectForKey:KeyStartDateTime]) {
        [self.values setObject:startDateTime forKey:KeyStartDateTime];
    }
    [self.tableView reloadData];
    [self enableSaving];
    [self customizeBottomToolbar];
    [self.stopBtn setEnabled:YES];
}

-(NSString*)getTimeFromDate:(NSDate*)date {
    if (!date) {
        date = [NSDate date];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

- (UIImage*) imageFromImage:(UIImage*)image string:(NSString*)string color:(UIColor*)color
{
    UIFont *font = [UIFont systemFontOfSize:16.0];
    CGSize expectedTextSize = [string sizeWithAttributes:@{NSFontAttributeName: font}];
    int width = expectedTextSize.width + image.size.width + 5;
    int height = MAX(expectedTextSize.height, image.size.width);
    CGSize size = CGSizeMake((float)width, (float)height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    int fontTopPosition = (height - expectedTextSize.height) / 2;
    CGPoint textPoint = CGPointMake(image.size.width + 5, fontTopPosition);
    
    [string drawAtPoint:textPoint withAttributes:@{NSFontAttributeName: font}];
    // Images upside down so flip them
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, (CGRect){ {0, (height - image.size.height) / 2}, {image.size.width, image.size.height} }, [image CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)configureTurnsController {
    /*
    UIImage *imgOriginal = [UIImage imageNamed:@"LeftTurn"];
    UIImage *img = [self imageFromImage:imgOriginal string:@"wide" color:[UIColor blueColor]];
    [self.turnsBtn setImage:img forSegmentAtIndex:0];
    img = [self imageFromImage:imgOriginal string:@"short" color:[UIColor blueColor]];
    [self.turnsBtn setImage:img forSegmentAtIndex:1];
    img = [self imageFromImage:imgOriginal string:@"OK" color:[UIColor blueColor]];
    [self.turnsBtn setImage:img forSegmentAtIndex:2];
    
    imgOriginal = [UIImage imageNamed:@"RightTurn"];
    img = [self imageFromImage:imgOriginal string:@"wide" color:[UIColor blueColor]];
    [self.turnsBtn setImage:img forSegmentAtIndex:3];
    img = [self imageFromImage:imgOriginal string:@"short" color:[UIColor blueColor]];
    [self.turnsBtn setImage:img forSegmentAtIndex:4];
    img = [self imageFromImage:imgOriginal string:@"OK" color:[UIColor blueColor]];
    [self.turnsBtn setImage:img forSegmentAtIndex:5];
    */
}

-(IBAction)currentSectionButtonPressed:(UIBarButtonItem*)sender {
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.detailsNames
                                                                                                forKey:Key_CurrentSection];
    
    listController.selectDelegate = self;
    listController.title = @"Section";
    listController.showIndex = YES;
    listController.newLogic = YES;
    NSString *class = [self.values objectForKey:Key_CurrentSection];
    if (class) {
        listController.selectedValue = class;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:sender];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(IBAction)turnsChanged:(id)sender {
    
    NSInteger index = 0;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        index = ((UISegmentedControl*)sender).selectedSegmentIndex;
        NSLog(@"option = %d", (int)((UISegmentedControl*)sender).selectedSegmentIndex);
    } else if ([sender isKindOfClass:[NSNumber class]]){
        index = [(NSNumber*)sender integerValue];
    }
    
    NSArray *turns = [NSArray arrayWithObjects:DrivingTurnLeftWide, DrivingTurnLeftShort, DrivingTurnLeftOk,  DrivingTurnRightWide, DrivingTurnRightShort, DrivingTurnRightOk, nil];
    //NSArray *turns2 = [NSArray arrayWithObjects:DrivingTurnLeftWide1, DrivingTurnLeftShort1, DrivingTurnLeftOk1,  DrivingTurnRightWide1, DrivingTurnRightShort1, DrivingTurnRightOk1, nil];

    NSString *turn = [turns objectAtIndex:index];
    //NSString *turns2 = [turns objectAtIndex:index];

    
    //DriverTurn
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"DriverTurn"];
    DriverTurn *obj = (DriverTurn*)[agg createNewObject];
    
    obj.instructorId = self.instructor.employeeNumber;
    obj.instructorLastName = self.instructor.surname;
    obj.instructorFirstName = self.instructor.firstname;
    
    obj.employeeId = self.student.employeeNumber;
    obj.studentLastName = self.student.surname;
    obj.studentFirstName = self.student.firstname;
    
    obj.turnType = turn;
    obj.company = [self.values objectForKey:@"company"];
    obj.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
    obj.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
    obj.dateTime = [NSDate date];
    obj.rcoObjectParentId = self.header.rcoMobileRecordId;

    [agg createNewRecord:obj];

    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        [(UISegmentedControl*)sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
    NSString *msg = [NSString stringWithFormat:@"%@ saved!", [turn capitalizedString]];
    [self showSimpleMessage:msg];
}

-(IBAction)pauseButtonPressed:(id)sender {
    self.pausedDate = [NSDate date];
    
    if (self.isDrivingSchool) {
        [self.header addPauseDateTime:self.pausedDate];
        [self addStartButton];
        [self.stopBtn setEnabled:NO];
        [self saveButtonPressed:nil];
        self.pausedDate = nil;
    } else {
        [Settings setSetting:self.pausedDate forKey:CSD_TEST_PAUSED_DATE];
        [Settings save];
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];

        NSInteger index = [items indexOfObject:self.pauseBtn];
        if (index != NSNotFound) {
            [items replaceObjectAtIndex:index withObject:self.playBtn];
        }
        if ([self testEnded]) {
            [self.stopBtn setEnabled:NO];
            [self.turnsBtn setEnabled:NO];
        } else {
            [self.turnsBtn setEnabled:YES];
            [self.stopBtn setEnabled:YES];
        }
        [self.bottomToolbar setItems:items];
        [self.stopBtn setEnabled:YES];
    }
    [self.tableView reloadData];
}

-(IBAction)stopButtonPressed:(id)sender {
    
    if (!self.header) {
        [self showSimpleMessage:@"Please save the test first!"];
        return;
    }
    
    if ([self CSDNeedsToSign]) {
        [self showSimpleMessage:@"Please sign the test first!"];
        return;
    }
    
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:@"Are you sure you want to end the test?"
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        [self endTestWithDate:nil];
                                                       }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [al addAction:cancelAction];
    [al addAction:yesAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(void)endTestWithDate:(NSDate*)dateTime {
    
    if (!dateTime) {
        dateTime = [NSDate date];
    }
    
    [Settings resetKey:CSD_TEST_PAUSED_DATE];
    [Settings save];
        
    [self.playBtn setEnabled:NO];
    [self.stopBtn setEnabled:NO];
    [self.pauseBtn setEnabled:NO];
    self.isEnded = YES;
    
    [self.values setObject:dateTime forKey:KeyEndDateTime];
    
    if (self.header) {
        self.header.endDateTime = dateTime;
        [[self aggregate] save];
    }

    [self.tableView reloadData];
    
    NSInteger bottomSection = self.fields.count + self.detailsNames.count + self.bottomSection.count - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:bottomSection];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self enableSaving];
    
    if (self.isDrivingSchool) {
        self.saveOnServer = YES;
        self.saveSignature = YES;
        self.saveScores = YES;
        [self saveButtonPressed:self.saveBtn];
        [self addStartButton];
    }
}

-(void)showSignatureForOption:(NSString*)option {
    SignatureViewController *controller = [[SignatureViewController alloc] initWithNibName:@"SignatureViewController" bundle:nil];
    controller.addDelegate = self;
    controller.addDelegateKey = option;
    controller.returnOnlyImage = YES;
    
    if ([option isEqualToString:TestSignatureDriver]) {
        controller.signatureImage = self.driverSignature;
    } else if ([option isEqualToString:TestSignatureEvaluator]) {
        controller.signatureImage = self.self.evaluatorSignature;
    } else if ([option isEqualToString:TestSignatureCompanyRep]) {
        controller.signatureImage = self.self.compRepSignature;
    }
    
    if (DEVICE_IS_IPHONE) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showPopoverModalForViewController:controller];
    }
}

-(void)addSignatureForKey:(NSString*)key {
    if (key.length == 0) {
        return;
    }
    // Signature should be the second detail for the Header
    SignatureDetailAggregate *agg = [[self aggregate].detailAggregates objectAtIndex:1];
    
    SignatureDetail *detail = nil;
    
    NSData *imageData = nil;
    
    if ([key isEqualToString:TestSignatureDriver]) {
        imageData = UIImagePNGRepresentation(self.driverSignature);
    } else if ([key isEqualToString:TestSignatureEvaluator]) {
        imageData = UIImagePNGRepresentation(self.evaluatorSignature);
    } else if ([key isEqualToString:TestSignatureCompanyRep]) {
        imageData = UIImagePNGRepresentation(self.compRepSignature);
    }

    if ([self.header.rcoBarcode length]) {
        detail = [agg getDetailForParentBarcode:self.header.rcoBarcode andType:key];
    } else {
        detail = [agg getDetailForParentId:self.header.rcoObjectId andType:key];
    }
    
    if (!imageData) {
        if (detail) {
            NSLog(@"We should delete the signature!");
        } else {
            // we son't have a prev signature and the current image is not set ...
            return;
        }
    }
    
    NSInteger index = [self.bottomSection indexOfObject:key];
    
    NSString *signatureName = nil;
    if (index == 0) {
        signatureName = [self.student Name];
    } else if (index == 1) {
        signatureName = [self.instructor Name];
    } else if (index == 2) {
        signatureName = [self.values objectForKey:Key_CompanyRepresentative];
        if (!signatureName) {
            signatureName = @"Comp Rep.";
        }
    } else if (index != NSNotFound) {
        signatureName = [self.bottomSectionNames objectAtIndex:index];
    }
    
    if (!detail) {
        detail = (SignatureDetail*)[agg createNewObject];
        detail.rcoBarcodeParent = self.header.rcoBarcode;
        detail.rcoObjectParentId = self.header.rcoObjectId;
        
        detail.signatureDate = [[NSDate date] dateAsDateWithoutTime];
        detail.documentDate = [[NSDate date] dateAsDateWithoutTime];
        detail.signatureName = signatureName;
        detail.itemType = TestSignatureItemType;
    }
    
    detail.documentTitle = key;
    detail.documentType = @"document type";
    
    if (imageData) {
        [agg saveImage:imageData forObjectId:detail.rcoObjectId];
        
        [detail setFileNeedsUploading:[NSNumber numberWithBool:YES]];
        [detail setNeedsUploading:YES];
        [agg save];
    } else {
        // should we delete the signature if the current image is nil?
    }
    // the signature is uploaded after we receive the response for saving the header ... from test data header aggregate
}

-(IBAction)emailButtonPressed:(id)sender {
    NSLog(@"");
    [self previewButtonPressed:nil];
}

-(IBAction)signatureButtonPressed:(id)sender {

}

-(IBAction)editButtonPressed:(id)sender {
    self.isEditing = YES;
    self.isEnded = NO;
    self.needsToSave = NO;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, nil];
    //10.12.2019
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, nil];
    [self.tableView reloadData];
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

-(IBAction)reloadButtonPressed:(id)sender {

    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:@"Reload the most recent Test Info?"
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        self.header = nil;
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
    
    // enable saving all the time for this instructor
    NSString *usr = [Settings getSetting:CLIENT_LOGIN_KEY];
    if ([usr isEqualToString:@"instructor@ups.com"]) {
        self.needsToSave = YES;
    }
    
    if (self.isDrivingSchool) {
        if (!self.needsToSave && !self.saveOnServer && !self.header) {
            // if the button is not enabled then we should not try to save anything ....
            return;
        }
    } else {
        if (!self.needsToSave) {
            // if the button is not enabled then we should not try to save anything ....
            return;
        }
    }
    
    BOOL isAutoSave = NO;
    if ([sender isKindOfClass:[NSTimer class]] || !sender) {
        //17.10.2019 we should do an autosave; if is an auto save we should not show messages... we should do a save but jost locally
        isAutoSave = YES;
    }
    
    if (isAutoSave) {
        if (![self testStarted]) {
            // if the test is not started there is no point in saving the test, or is?
            return;
        }
    }
    
    NSString *message = [self validateInputs];
    if (message) {
        if (!isAutoSave) {
            if (self.addParentMobileRecordId) {
                NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
                if (!parentMobileRecordId.length) {
                    [self showSimpleMessage:@"Please add test info first!"];
                    return;
                }
            }
            [self showSimpleMessage:message];
        } else {
            // 09.12.2019 is an auto save. if we don't have the test info record then we should NOT create the record
            NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
            if (!parentMobileRecordId.length) {
                return;
            }
        }
        return;
    }
    
    if(!self.student) {
        if (!isAutoSave) {
            [self showSimpleMessage:@"Please select Student!"];
        }
        return;
    }

    if(!self.instructor) {
        if (!isAutoSave) {
            [self showSimpleMessage:@"Please select Instructor!"];
        }
        return;
    }
    
    if (sender == self.saveBtn) {
        self.saveSignature = YES;
    }
    
    // 18.02.2020 hide the keyboard
    [self.view endEditing:YES];
    
    if (!isAutoSave) {
        if (self.header) {
            self.progressHUD.labelText = @"Update Form...";
        } else {
            self.progressHUD.labelText = @"Create Form...";
        }
//        self.progressHUD.labelText = @"Saving Test...";
//
//        [self.view addSubview:self.progressHUD];
//        [self.progressHUD show:YES];
        [self performSelector:@selector(createRecord:) withObject:[NSNumber numberWithBool:isAutoSave] afterDelay:0.1];
    } else {
        //19.02.2020 we should  not force all the time to save [self createRecord:[NSNumber numberWithBool:isAutoSave]];
        [self createRecord:[NSNumber numberWithBool:NO]];
    }
}

-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val integerValue] < 0) {
        return @"";
    }
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)createTestDataHeaderRecordLocaly {
    
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!parentMobileRecordId.length) {
        // 10.12.2019 there is no point in creating a test if the test info recor was not created
        return;
    }
    
    [self loadPrevStudent];
    [self loadPrevInstructor];
    
    self.isNewCreated = YES;
    self.header = (TestDataHeader*)[[self aggregate] createNewObject];
    self.header.dateTime = [NSDate date];
    self.header.number = self.formNumber;
    self.header.rcoObjectParentId = parentMobileRecordId;

    // 25.11.2019 we should use fieldsAll to have the studentt and instructor fields ...
    NSArray *headerCodingFields = self.fields;
    if (!self.showTrainingInfofields) {
        headerCodingFields = self.fieldsAll;
    }
    
    for (NSString *field in headerCodingFields) {
        // 29.11.2019 I've added extra fields that are not coding fields
        SEL sel = NSSelectorFromString(field);
        if ([self.header respondsToSelector:sel]) {
            id val = [self.values objectForKey:field];
            if (val) {
                if ([self.switchFields containsObject:field]) {
                    if ([field isEqualToString:KeyQualifiedOrNot]) {
                        // 14.02.2020 for this switch I'm not settig anything ....
                        NSLog(@"");
                        [self.header setValue:@"" forKey:field];
                    } else {
                        [self.header setValue:[self getBooleanFromValue:val] forKey:field];
                    }
                } else {
                    [self.header setValue:val forKey:field];
                }
            }
        }
    }
    // instructor infos
    self.header.instructorLastName = self.instructor.surname;
    self.header.instructorFirstName = self.instructor.firstname;
    self.header.instructorEmployeeId = self.instructor.employeeNumber;
    
    // stident infos
    self.header.studentLastName = self.student.surname;
    self.header.studentFirstName = self.student.firstname;
    self.header.employeeId = self.student.employeeNumber;
    
    self.header.driverLicenseClass = self.student.driverLicenseClass;
    self.header.driverLicenseNumber = self.student.driverLicenseNumber;
    self.header.driverLicenseState = self.student.driverLicenseState;

    self.header.driverLicenseExpirationDate = self.driverLicenseExpirationDate;
    self.header.dotExpirationDate = self.dotExpirationDate;

    if ([self.formNumber isEqualToString:TestProd]) {
        [self addNewSection];
    }
    
    // to load the special sections also
    [self loadObjectDetailsAndReload:NO];
    
    NSInteger possiblePoints = 0;
    NSInteger receivedPoints = 0;
        
    for (NSInteger index = 0; index < self.detailsNames.count; index++) {
        NSString *itemSectionName = [self.detailsNames objectAtIndex:index];
        NSArray *details = [self.detailsInfo objectForKey:itemSectionName];
        NSArray *scores = [self.scores objectForKey:itemSectionName];
        
        NSString *noteKey = [NSString stringWithFormat:@"%@%d", @"Notes", (int)index];
        NSString *noteStr = [self.values objectForKey:noteKey];
        
        NSString *equipmentKey = itemSectionName;
        if ([self.formNumber isEqualToString:TestVRT]) {
            equipmentKey = KeyEquipmentUsed;
        }
        
        TrainingEquipment *equipmentUsed = [self.equipmentUsed objectForKey:equipmentKey];

        if (noteStr.length) {
            // we should update or insert
            NSLog(@"");
            [self addNote:noteStr forCategory:itemSectionName];
        }
        
        NSArray *specialInputFields = [NSArray arrayWithObjects:@"Location", @"Trailer", @"Odometer", nil];

        for (NSInteger i = 0; i < details.count; i++) {
            id detail = [details objectAtIndex:i];
            NSNumber *score = [scores objectAtIndex:i];
            //NSInteger val = ([score integerValue] + 1);
            NSInteger val = [score integerValue];

            if (val >= 0) {
                possiblePoints += 5;
            } else {
                // is N/A then we should not increment anything ....
            }
            // index selected + 1

            if (val>0) {
                // if the score is -1 we shoul dnot increment it, is just for not available
                receivedPoints += val;
            }
            TestDataDetail *d = nil;
            d = [self addUpdateDetail:detail
                             andScore:[NSString stringWithFormat:@"%d", (int)val]
                       seachForDetail:[NSNumber numberWithBool:YES]
                       forSectionName:nil
                     andSectionNumber:nil];
            
            if ([specialInputFields containsObject:d.testItemName]) {
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"" forKey:KeyLocation];
                [dict setObject:@"" forKey:KeyTrailerNumber];
                [dict setObject:@"" forKey:KeyOdometer];

                [self.specialSectionValues addObject:dict];
            }
            
            d.equipmentUsedMobileRecordId = equipmentUsed.rcoMobileRecordId;
            
            NSString *teachingString = nil;
            if (val < 5) {
                teachingString = [self getTeachingStringForSection:d.testSectionName andItem:d.testItemNumber];
            }
            d.testTeachingString = teachingString;
        }
    }
    
    if ([self.formNumber isEqualToString:TestVRT]) {
        self.header.pointsReceived = [NSString stringWithFormat:@"%d", (int)self.receivedPoints];
        self.header.pointsPossible = [NSString stringWithFormat:@"%d", (int)self.possiblePoints];
    } else {
        self.header.pointsReceived = [NSString stringWithFormat:@"%d", (int)receivedPoints];
        self.header.pointsPossible = [NSString stringWithFormat:@"%d", (int)possiblePoints];
    }
    /* 23.12.2019 we changed this to endDateTime
    if (!self.header.endTime) {
        self.header.endTime = @"";
    }
    */

    [[self aggregate] save];
    
    [self addSignatureForKey:TestSignatureDriver];
    [self addSignatureForKey:TestSignatureEvaluator];
    [self addSignatureForKey:TestSignatureCompanyRep];
}

-(NSString*)calculateTimeElapsedForCurrentTest {
    NSDate *startDateTime = [self.values objectForKey:KeyStartDateTime];
    NSDate *endDateTime = [self.values objectForKey:KeyEndDateTime];
    int minutes = 0;
    if (startDateTime && endDateTime) {
        double start = [startDateTime timeIntervalSince1970];
        double end = [endDateTime timeIntervalSince1970];
        double seconds = end - start;
        minutes = seconds / 60;
    }
    return [NSString stringWithFormat:@"%d", minutes];
}

-(void)createRecord:(NSNumber*)isAutoSave {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"dateTime"]]) {
        
        [dict setObject:[[self aggregate] rcoDateToString:[self.values valueForKey:@"dateTime"]] forKey:@"date"];
        
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:KeyStartDateTime]]) {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm:ss"];
        
        NSString *date_str =[dateFormat stringFromDate:[self.values valueForKey:KeyStartDateTime]];
        
        [dict setObject:date_str forKey:@"start_time"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:KeyEndDateTime]]) {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm:ss"];
        
        NSString *date_str =[dateFormat stringFromDate:[self.values valueForKey:KeyEndDateTime]];
        
        [dict setObject:date_str forKey:@"end_time"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"department"]]) {
        
        [dict setObject:[self.values valueForKey:@"department"] forKey:@"department"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"companyRepresentative"]]) {
        
        [dict setObject:[self.values valueForKey:@"companyRepresentative"] forKey:@"company_rep_name"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"observerFirstName"]]) {
        
        [dict setObject:[self.values valueForKey:@"observerFirstName"] forKey:@"observer_first_name"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"observerLastName"]]) {
        
        [dict setObject:[self.values valueForKey:@"observerLastName"] forKey:@"observer_last_name"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"onTime"]]) {
        
        [dict setObject:[self.values valueForKey:@"onTime"] forKey:@"on_time"];
    }
        
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"keysReady"]]) {
        
        [dict setObject:[self.values valueForKey:@"keysReady"] forKey:@"keys_ready"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"timecardSystemReady"]]) {
        
        [dict setObject:[self.values valueForKey:@"timecardSystemReady"] forKey:@"timecard_system_ready"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.specialSectionValues valueForKey:@"odometer"]]) {
        
        [dict setObject:[self.specialSectionValues valueForKey:@"odometer"] forKey:@"odometer"];
    }
    
    
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"equipmentReady"]]) {
        
        [dict setObject:[self.values valueForKey:@"equipmentReady"] forKey:@"equipment_ready"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"equipmentClean"]]) {
        
        [dict setObject:[self.values valueForKey:@"equipmentClean"] forKey:@"equipment_clean"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"startOdometer"]]) {
        
        [dict setObject:[self.values valueForKey:@"startOdometer"] forKey:@"start_odometer"];
    }
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"finishOdometer"]]) {
        
        [dict setObject:[self.values valueForKey:@"finishOdometer"] forKey:@"finish_odometer"];
    }
    
    
    if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"miles"]]) {
        
        [dict setObject:[self.values valueForKey:@"miles"] forKey:@"miles"];
    }
    
    NSArray *detailTestInfo = [self.detailsInfo valueForKey: [self.detailsNames firstObject]];
    
    
    
    
    
    if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"routeNumber"]]) {
        [dict setObject:[self.values objectForKey:@"routeNumber"] forKey:@"route_number"];
    }
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlEndPoint = @"";
    
    if ([self.formNumber isEqual:TestProd]) { // Prod Tab
        for (TestDataDetail *td in detailTestInfo) {
            
            if ([td.testItemName isEqual:@"Trailer"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.trailerNumber]) {
                    [dict setObject:td.trailerNumber forKey:@"trailer"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Start Work"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"start_work"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Location"]) {
                
            
                if ([HelperSharedManager isCheckNotNULL:td.location]) {
                    
                    [dict setObject:td.location forKey:@"location"];
                }
            }
            
            if ([td.testItemName isEqual:@"Leave building"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"leave_building"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Leave building"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"leave_building"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Travel Path"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"travel_path"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Speed"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"speed"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Idle Time"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"idle_time"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Plan Ahead"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"plan_ahead"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Turn Around"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"turn_around"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"On Schedule"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"on_schedule"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Customer Contact"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"customer_contact"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Not Ready Situations"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"not_ready_situations"];
                }
                
            }
            
            if ([td.testItemName isEqual:@"Brisk Pace"]) {
                
                if ([HelperSharedManager isCheckNotNULL:td.score]) {
                    [dict setObject:td.score forKey:@"brisk_pace"];
                }
                
            }
            
            
            
            
            
            
            
        }
        
        
        NSLog(@"Special Fields %@", self.specialSectionValues);
        
        if ([HelperSharedManager isCheckNotNULL:self.specialSectionValues]) {
            
            if (self.specialSectionValues.count > 0) {
                NSDictionary *vals = self.specialSectionValues[0];
                if ([HelperSharedManager isCheckNotNULL: [vals valueForKey:@"odometer"]]) {
                    [dict setObject:[vals valueForKey:@"odometer"] forKey:@"odometer"];
                }
                
            }
            
            
        }
        
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        
        for(id key in dict) {
            
            
            if ([[dict objectForKey:key] isKindOfClass:[NSString class]]) {
                
                
                NSString *val = [dict objectForKey:key];
                
                
                if ([val isEqual:@"-1"]) {
                    [newDict setValue:@"0" forKey:key];
                } else {
                    [newDict setValue:[dict objectForKey:key] forKey:key];
                }
            } else {
                [newDict setValue:[dict objectForKey:key] forKey:key];
            }
        }
        
        
        
        
        [dict removeAllObjects];
        
        dict = newDict;
        
        
        
        urlEndPoint = @"prod";
    }
    
    if ([self.formNumber isEqual:TestPreTrip]) { // PreTrip Tab
        
        
        
        
        NSArray *scoresInsideCab = [self.scores objectForKey:@"Inside Cab"];
        NSMutableDictionary * insideCab = [[NSMutableDictionary alloc] init];
        [insideCab setObject:scoresInsideCab[0] forKey:@"hand_rails"];
        [insideCab setObject:scoresInsideCab[1] forKey:@"fire_extinguisher"];
        [insideCab setObject:scoresInsideCab[2] forKey:@"fhwa"];
        [insideCab setObject:scoresInsideCab[3] forKey:@"emergency_response_book"];
        [insideCab setObject:scoresInsideCab[4] forKey:@"dvir"];
        [insideCab setObject:scoresInsideCab[5] forKey:@"parking_brake_applied"];
        [insideCab setObject:scoresInsideCab[6] forKey:@"transmission_neutral_or_park"];
        [insideCab setObject:scoresInsideCab[7] forKey:@"seat_adjustment"];
        [insideCab setObject:scoresInsideCab[8] forKey:@"seat_belt"];
        [insideCab setObject:scoresInsideCab[9] forKey:@"cab_or_berth"];
        [insideCab setObject:scoresInsideCab[10] forKey:@"dome_and_map_lights"];
        [insideCab setObject:scoresInsideCab[11] forKey:@"windows"];
        [insideCab setObject:scoresInsideCab[12] forKey:@"mirros_adjustments"];
        [insideCab setObject:scoresInsideCab[13] forKey:@"steering_wheel"];
        [insideCab setObject:scoresInsideCab[14] forKey:@"horn"];
        [insideCab setObject:scoresInsideCab[15] forKey:@"indicators"];
        [insideCab setObject:scoresInsideCab[16] forKey:@"wipers"];
        [insideCab setObject:scoresInsideCab[17] forKey:@"gauges"];
        [insideCab setObject:scoresInsideCab[18] forKey:@"air_heater_defrost"];
        [insideCab setObject:scoresInsideCab[19] forKey:@"bi_directional_triangles"];
        [insideCab setObject:scoresInsideCab[20] forKey:@"shifter_straight_and_secure"];
        [insideCab setObject:scoresInsideCab[21] forKey:@"splitter"];
        [insideCab setObject:scoresInsideCab[22] forKey:@"clear_floor_board"];
        [insideCab setObject:scoresInsideCab[23] forKey:@"pedals"];
        [insideCab setObject:scoresInsideCab[24] forKey:@"park_brake"];
        [insideCab setObject:scoresInsideCab[25] forKey:@"service_brake_test"];
        [insideCab setObject:scoresInsideCab[26] forKey:@"trailer_brake_test"];
        [insideCab setObject:scoresInsideCab[27] forKey:@"pull_key"];
        [insideCab setObject:scoresInsideCab[28] forKey:@"exit_safely"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes0"]]) {
            [insideCab setObject:[self.values objectForKey:@"Notes0"] forKey:@"notes"];
        }
        
        [dict setObject:insideCab forKey:@"inside_cab"];
        

        NSArray *scoresCoal = [self.scores objectForKey:@"C.O.A.L.S."];
     
        NSMutableDictionary * coalDict = [[NSMutableDictionary alloc] init];
        [coalDict setObject:scoresCoal[0] forKey:@"chock_wheels"];
        [coalDict setObject:scoresCoal[1] forKey:@"cut_in"];
        [coalDict setObject:scoresCoal[2] forKey:@"cut_out"];
        [coalDict setObject:scoresCoal[3] forKey:@"air_leak_test"];
        [coalDict setObject:scoresCoal[4] forKey:@"low_air_warning"];
        [coalDict setObject:scoresCoal[5] forKey:@"spring"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes1"]]) {
            [coalDict setObject:[self.values objectForKey:@"Notes1"] forKey:@"notes"];
        }
        
        [dict setObject:coalDict forKey:@"coals"];
        
        NSArray *scoresEngineCompartment = [self.scores objectForKey:@"Engine Compartment"];
        NSMutableDictionary * engineCompartment = [[NSMutableDictionary alloc] init];
        [engineCompartment setObject:scoresEngineCompartment[0] forKey:@"fuses"];
        [engineCompartment setObject:scoresEngineCompartment[1] forKey:@"hood_latches"];
        [engineCompartment setObject:scoresEngineCompartment[2] forKey:@"hood_locking_device"];
        [engineCompartment setObject:scoresEngineCompartment[3] forKey:@"engine_oil"];
        [engineCompartment setObject:scoresEngineCompartment[4] forKey:@"transmission_oil"];
        [engineCompartment setObject:scoresEngineCompartment[5] forKey:@"power_steering_fluid"];
        [engineCompartment setObject:scoresEngineCompartment[6] forKey:@"washer_fluid"];
        [engineCompartment setObject:scoresEngineCompartment[7] forKey:@"coolant"];
        [engineCompartment setObject:scoresEngineCompartment[8] forKey:@"belts_and_hoses"];
        [engineCompartment setObject:scoresEngineCompartment[9] forKey:@"filters"];
        [engineCompartment setObject:scoresEngineCompartment[10] forKey:@"components"];
        [engineCompartment setObject:scoresEngineCompartment[11] forKey:@"leaks_air_and_fluid"];
        [engineCompartment setObject:scoresEngineCompartment[12] forKey:@"frame"];
        [engineCompartment setObject:scoresEngineCompartment[13] forKey:@"suspension"];
        [engineCompartment setObject:scoresEngineCompartment[14] forKey:@"steering_components"];
        [engineCompartment setObject:scoresEngineCompartment[15] forKey:@"brake_chambers_or_slack_adj"];
        [engineCompartment setObject:scoresEngineCompartment[16] forKey:@"brake_drums_and_pads"];
        [engineCompartment setObject:scoresEngineCompartment[17] forKey:@"wheel_bearings"];
        [engineCompartment setObject:scoresEngineCompartment[18] forKey:@"tire_inflation"];
        [engineCompartment setObject:scoresEngineCompartment[19] forKey:@"tire_and_rin_condition"];
        [engineCompartment setObject:scoresEngineCompartment[20] forKey:@"valve_stems_and_hub_oil"];
        [engineCompartment setObject:scoresEngineCompartment[21] forKey:@"mud_flaps"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes2"]]) {
            [engineCompartment setObject:[self.values objectForKey:@"Notes2"] forKey:@"notes"];
        }
        
        [dict setObject:engineCompartment forKey:@"engine_compartment"];
        
        NSArray *scoresvehicleFront = [self.scores objectForKey:@"Vehicle Front"];
        NSMutableDictionary *vehicleFront = [[NSMutableDictionary alloc] init];
        [vehicleFront setObject:scoresvehicleFront[0] forKey:@"body_damage"];
        [vehicleFront setObject:scoresvehicleFront[1] forKey:@"lights_id_and_others"];
        [vehicleFront setObject:scoresvehicleFront[2] forKey:@"bumper_and_tow_hooks"];
        [vehicleFront setObject:scoresvehicleFront[3] forKey:@"license_plate"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes3"]]) {
            [vehicleFront setObject:[self.values objectForKey:@"Notes3"] forKey:@"notes"];
        }
        
        [dict setObject:vehicleFront forKey:@"vehicle_front"];
        
        NSArray *scoresBothSidesVehicle = [self.scores objectForKey:@"Both Sides Vehicle"];
        NSMutableDictionary *bothSidesVehicle = [[NSMutableDictionary alloc] init];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[0] forKey:@"mirrors"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[1] forKey:@"vehicle_markings_or_decals"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[2] forKey:@"dots"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[3] forKey:@"ifta_permit"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[4] forKey:@"air_tanks"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[5] forKey:@"fuel_tank_alternative"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[6] forKey:@"_def"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[7] forKey:@"battery_box"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[8] forKey:@"deck_plate"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[9] forKey:@"air_lines_lights_cord_spring"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[10] forKey:@"frame"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[11] forKey:@"fifth_wheel"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[12] forKey:@"mud_flaps"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[13] forKey:@"drive_line"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[14] forKey:@"air_cans_or_lines"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[15] forKey:@"brake_chambers_or_slack_adj"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[16] forKey:@"suspension"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[17] forKey:@"brake_drums_and_lining"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[18] forKey:@"tire_inflation"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[19] forKey:@"tire_and_rim_condition"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[20] forKey:@"valve_stem_and_hub_oil"];
        [bothSidesVehicle setObject:scoresBothSidesVehicle[21] forKey:@"body_condition"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes4"]]) {
            [bothSidesVehicle setObject:[self.values objectForKey:@"Notes4"] forKey:@"notes"];
        }
        
        [dict setObject:bothSidesVehicle forKey:@"both_sides_vehicle"];
        
        NSArray *scoresVehicleTractorRear = [self.scores objectForKey:@"Vehicle/Tractor Rear"];
        NSMutableDictionary *vehicleTractorRear = [[NSMutableDictionary alloc] init];
        [vehicleTractorRear setObject:scoresVehicleTractorRear[0] forKey:@"brake_and_others"];
        [vehicleTractorRear setObject:scoresVehicleTractorRear[1] forKey:@"body_condition"];
        [vehicleTractorRear setObject:scoresVehicleTractorRear[2] forKey:@"reflectors_and_work_light"];
        [vehicleTractorRear setObject:scoresVehicleTractorRear[3] forKey:@"mud_flaps"];
        [vehicleTractorRear setObject:scoresVehicleTractorRear[4] forKey:@"couple_devices"];
        [vehicleTractorRear setObject:scoresVehicleTractorRear[5] forKey:@"license_plate_and_light"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes5"]]) {
            [vehicleTractorRear setObject:[self.values objectForKey:@"Notes5"] forKey:@"notes"];
        }
        
        [dict setObject:vehicleTractorRear forKey:@"vehicle_or_tractor_rear"];
        
        
        NSArray *scoresfrontTrailerBox = [self.scores objectForKey:@"Front of trailer or box (header board)"];
        NSMutableDictionary *frontTrailerBox = [[NSMutableDictionary alloc] init];
        [frontTrailerBox setObject:scoresfrontTrailerBox[0] forKey:@"equipment_height_and_condition"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[1] forKey:@"clearance_lights"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[2] forKey:@"reflectors"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[3] forKey:@"chassis_and_locks"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[4] forKey:@"refrigeration_system"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[5] forKey:@"federal_inspection_or_bit"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[6] forKey:@"utility_box"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[7] forKey:@"electric_plug"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[8] forKey:@"glad_hands_and_grommets"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[9] forKey:@"air_lines"];
        [frontTrailerBox setObject:scoresfrontTrailerBox[10] forKey:@"equipement_number_and_markings"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes6"]]) {
            [frontTrailerBox setObject:[self.values objectForKey:@"Notes6"] forKey:@"notes"];
        }
        
        [dict setObject:frontTrailerBox forKey:@"front_trailer_box"];
        
      
        
        NSArray *scoresdriverSideTrailerBox = [self.scores objectForKey:@"Driver Side Trailer or Box"];
        NSMutableDictionary *driverSideTrailerBox = [[NSMutableDictionary alloc] init];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[0] forKey:@"condition"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[1] forKey:@"reflectors"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[2] forKey:@"marker_lights"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[3] forKey:@"coupling"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[4] forKey:@"frame_and_chassis"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[5] forKey:@"landing_gear"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[6] forKey:@"air_cans"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[7] forKey:@"brake_chambers_or_slack_adj"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[8] forKey:@"axel"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[9] forKey:@"suspension"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[10] forKey:@"brake_drums_and_lining"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[11] forKey:@"tire_inflation"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[12] forKey:@"tire_and_rim_condition"];
        [driverSideTrailerBox setObject:scoresdriverSideTrailerBox[13] forKey:@"valve_stem_and_hub_oil"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes7"]]) {
            [driverSideTrailerBox setObject:[self.values objectForKey:@"Notes7"] forKey:@"notes"];
        }
        
        [dict setObject:driverSideTrailerBox forKey:@"driver_side_trailer_box"];
        
        
        NSArray *scoresrearTrailerBox= [self.scores objectForKey:@"Rear Trailer and Box"];
        NSMutableDictionary *rearTrailerBox = [[NSMutableDictionary alloc] init];
        [rearTrailerBox setObject:scoresrearTrailerBox[0] forKey:@"brake_and_others"];
        [rearTrailerBox setObject:scoresrearTrailerBox[1] forKey:@"all_cargo_door"];
        [rearTrailerBox setObject:scoresrearTrailerBox[2] forKey:@"cargo_load_area"];
        [rearTrailerBox setObject:scoresrearTrailerBox[3] forKey:@"all_securing_devices"];
        [rearTrailerBox setObject:scoresrearTrailerBox[4] forKey:@"chassis"];
        [rearTrailerBox setObject:scoresrearTrailerBox[5] forKey:@"coupling_devices_or_plintle"];
        [rearTrailerBox setObject:scoresrearTrailerBox[6] forKey:@"air_elctrical"];
        [rearTrailerBox setObject:scoresrearTrailerBox[7] forKey:@"safety_loops"];
        [rearTrailerBox setObject:scoresrearTrailerBox[8] forKey:@"license_plate"];
        [rearTrailerBox setObject:scoresrearTrailerBox[9] forKey:@"flector_devices"];
        [rearTrailerBox setObject:scoresrearTrailerBox[10] forKey:@"mud_flaps"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes8"]]) {
            [rearTrailerBox setObject:[self.values objectForKey:@"Notes8"] forKey:@"notes"];
        }
        
        [dict setObject:rearTrailerBox forKey:@"rear_trailer_box"];
        
        
        NSArray *scorespassengerSideTrailerBox = [self.scores objectForKey:@"Passenger Side Trailer or Box"];
        NSMutableDictionary *passengerSideTrailerBox = [[NSMutableDictionary alloc] init];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[0] forKey:@"condition"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[1] forKey:@"reflectors"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[2] forKey:@"marker_lights"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[3] forKey:@"coupling"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[4] forKey:@"frame_and_chassis"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[5] forKey:@"landing_gear"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[6] forKey:@"air_cans"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[7] forKey:@"brake_chambers_or_slack_adj"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[8] forKey:@"axel"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[9] forKey:@"suspension"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[10] forKey:@"brake_drums_and_lining"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[11] forKey:@"tire_inflation"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[12] forKey:@"tire_and_rim_condition"];
        [passengerSideTrailerBox setObject:scorespassengerSideTrailerBox[13] forKey:@"valve_stem_and_hub_oil"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes9"]]) {
            [passengerSideTrailerBox setObject:[self.values objectForKey:@"Notes9"] forKey:@"notes"];
        }
        
        [dict setObject:passengerSideTrailerBox forKey:@"passenger_side_trailer_box"];
        
        
        NSArray *scoresdolly = [self.scores objectForKey:@"Dolly"];
        NSMutableDictionary *dolly = [[NSMutableDictionary alloc] init];
        [dolly setObject:scoresdolly[0] forKey:@"condition"];
        [dolly setObject:scoresdolly[1] forKey:@"reflectors"];
        [dolly setObject:scoresdolly[2] forKey:@"brake_and_others"];
        [dolly setObject:scoresdolly[3] forKey:@"markings"];
        [dolly setObject:scoresdolly[4] forKey:@"frame"];
        [dolly setObject:scoresdolly[5] forKey:@"registration"];
        [dolly setObject:scoresdolly[6] forKey:@"air_cans"];
        [dolly setObject:scoresdolly[7] forKey:@"brake_chambers_or_slack_adj"];
        [dolly setObject:scoresdolly[8] forKey:@"wheel"];
        [dolly setObject:scoresdolly[9] forKey:@"suspension"];
        [dolly setObject:scoresdolly[10] forKey:@"brake_drums_and_lining"];
        [dolly setObject:scoresdolly[11] forKey:@"tire_inflation"];
        [dolly setObject:scoresdolly[12] forKey:@"tire_and_rim_condition"];
        [dolly setObject:scoresdolly[13] forKey:@"valve_stem_and_hub_oil"];
        [dolly setObject:scoresdolly[14] forKey:@"handles"];
        [dolly setObject:scoresdolly[15] forKey:@"dolly_eye"];
        [dolly setObject:scoresdolly[16] forKey:@"air_lines_and_light_cord"];
        [dolly setObject:scoresdolly[17] forKey:@"safety_chains"];
        [dolly setObject:scoresdolly[18] forKey:@"fifth_wheel"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes10"]]) {
            [dolly setObject:[self.values objectForKey:@"Notes10"] forKey:@"notes"];
        }
        
        [dict setObject:dolly forKey:@"dolly"];
        
        

        NSArray *scorescombinationVehicles = [self.scores objectForKey:@"Combination Vehicles"];
        NSMutableDictionary *combinationVehicles = [[NSMutableDictionary alloc] init];
        [combinationVehicles setObject:scorescombinationVehicles[0] forKey:@"heavier_trailer_in_front"];
        [combinationVehicles setObject:scorescombinationVehicles[1] forKey:@"builds_equip_properly"];
        [combinationVehicles setObject:scorescombinationVehicles[2] forKey:@"understand_types_of_dollies"];
        [combinationVehicles setObject:scorescombinationVehicles[3] forKey:@"secures_dolly_properly"];
        [combinationVehicles setObject:scorescombinationVehicles[4] forKey:@"speed_control_on_turns"];
        [combinationVehicles setObject:scorescombinationVehicles[5] forKey:@"avoids_abrupt_maneuvers"];
        [combinationVehicles setObject:scorescombinationVehicles[6] forKey:@"air_conditioner"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes11"]]) {
            [combinationVehicles setObject:[self.values objectForKey:@"Notes11"] forKey:@"notes"];
        }
        
        [dict setObject:combinationVehicles forKey:@"combination_vehicles"];
        
        
        NSArray *scorespostTrip = [self.scores objectForKey:@"Post Trip"];
        NSMutableDictionary *postTrip  = [[NSMutableDictionary alloc] init];
        [postTrip setObject:scorespostTrip[0] forKey:@"condition"];
        [postTrip setObject:scorespostTrip[1] forKey:@"all_lights"];
        [postTrip setObject:scorespostTrip[2] forKey:@"tire_condition"];
        [postTrip setObject:scorespostTrip[3] forKey:@"tire_inflation"];
        [postTrip setObject:scorespostTrip[4] forKey:@"hub_heat"];
        [postTrip setObject:scorespostTrip[5] forKey:@"reflective_devices"];
        [postTrip setObject:scorespostTrip[6] forKey:@"fluid_air_leaks"];
        [postTrip setObject:scorespostTrip[7] forKey:@"equipment_parked_secure"];
        [postTrip setObject:scorespostTrip[8] forKey:@"avoid_shifting_lead"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes12"]]) {
            [postTrip setObject:[self.values objectForKey:@"Notes12"] forKey:@"notes"];
        }
        
        [dict setObject:postTrip forKey:@"post_trip"];
        
        
       
        
        
        NSLog(@"Dict %@", dict);
        
        
        
        urlEndPoint = @"pre-trip";
    }
    
    if ([self.formNumber isEqualToString:TestBTW]) {
        

        NSArray *scorescabSafety = [self.scores objectForKey:@"Cab Safety"];
        NSMutableDictionary * cabSafety = [[NSMutableDictionary alloc] init];
        [cabSafety setObject:scorescabSafety[0] forKey:@"seat_belt"];
        [cabSafety setObject:scorescabSafety[1] forKey:@"can_distractions"];
        [cabSafety setObject:scorescabSafety[2] forKey:@"cab_obstructions"];
        [cabSafety setObject:scorescabSafety[3] forKey:@"cab_chemicals"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes0"]]) {
            [cabSafety setObject:[self.values objectForKey:@"Notes0"] forKey:@"notes"];
        }
        
        [dict setObject:cabSafety forKey:@"cab_safety"];
        
        NSArray *scoresstartEngine = [self.scores objectForKey:@"Start Engine"];
        NSMutableDictionary * startEngine = [[NSMutableDictionary alloc] init];
        [startEngine setObject:scoresstartEngine[0] forKey:@"park_brake_applied"];
        [startEngine setObject:scoresstartEngine[1] forKey:@"trans_in_park_or_neutral"];
        [startEngine setObject:scoresstartEngine[2] forKey:@"clutch_depressed"];
        [startEngine setObject:scoresstartEngine[3] forKey:@"uses_starter_properly"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes1"]]) {
            [startEngine setObject:[self.values objectForKey:@"Notes1"] forKey:@"notes"];
        }
        
        [dict setObject:startEngine forKey:@"start_engine"];
        
        
        NSArray *scoresengineOperation = [self.scores objectForKey:@"Engine Operation"];
        NSMutableDictionary * engineOperation = [[NSMutableDictionary alloc] init];
        [engineOperation setObject:scoresengineOperation[0] forKey:@"lugging"];
        [engineOperation setObject:scoresengineOperation[1] forKey:@"over_revving"];
        [engineOperation setObject:scoresengineOperation[2] forKey:@"check_gauges"];
        [engineOperation setObject:scoresengineOperation[3] forKey:@"does_not_ride"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes2"]]) {
            [engineOperation setObject:[self.values objectForKey:@"Notes2"] forKey:@"notes"];
        }
        
        [dict setObject:engineOperation forKey:@"engine_operation"];
        
        
        NSArray *scoresclutchAndTransmission = [self.scores objectForKey:@"Clutch and Transmission"];
        NSMutableDictionary * clutchAndTransmission = [[NSMutableDictionary alloc] init];
        [clutchAndTransmission setObject:scoresclutchAndTransmission[0] forKey:@"start_off_smoothly"];
        [clutchAndTransmission setObject:scoresclutchAndTransmission[1] forKey:@"proper_gear_use"];
        [clutchAndTransmission setObject:scoresclutchAndTransmission[2] forKey:@"shift_smoothly"];
        [clutchAndTransmission setObject:scoresclutchAndTransmission[3] forKey:@"proper_gear_sequence"];
        [clutchAndTransmission setObject:scoresclutchAndTransmission[4] forKey:@"does_not_cost"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes3"]]) {
            [clutchAndTransmission setObject:[self.values objectForKey:@"Notes3"] forKey:@"notes"];
        }
        
        [dict setObject:clutchAndTransmission forKey:@"clutch_and_transmission"];
        
        
        NSArray *scorescoupling = [self.scores objectForKey:@"Coupling"];
        NSMutableDictionary * coupling = [[NSMutableDictionary alloc] init];
        [coupling setObject:scorescoupling[0] forKey:@"check_for_hazards"];
        [coupling setObject:scorescoupling[1] forKey:@"backs_under_slowly"];
        [coupling setObject:scorescoupling[2] forKey:@"secures_equipment"];
        [coupling setObject:scorescoupling[3] forKey:@"physical_check_coupling"];
        [coupling setObject:scorescoupling[4] forKey:@"charges_system_correctly"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes4"]]) {
            [coupling setObject:[self.values objectForKey:@"Notes4"] forKey:@"notes"];
        }
        
        [dict setObject:coupling forKey:@"coupling"];
        
        NSArray *scoresuncoupling = [self.scores objectForKey:@"Uncoupling"];
        NSMutableDictionary * uncoupling = [[NSMutableDictionary alloc] init];
        [uncoupling setObject:scoresuncoupling[0] forKey:@"secures_equipment"];
        [uncoupling setObject:scoresuncoupling[1] forKey:@"chock_wheels"];
        [uncoupling setObject:scoresuncoupling[2] forKey:@"lower_landing_gear"];
        [uncoupling setObject:scoresuncoupling[3] forKey:@"pull_away_or_trailer_secure"];
        [uncoupling setObject:scoresuncoupling[4] forKey:@"leve_or_firm_ground"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes5"]]) {
            [uncoupling setObject:[self.values objectForKey:@"Notes5"] forKey:@"notes"];
        }
        
        [dict setObject:uncoupling forKey:@"uncoupling"];
        
        NSArray *scoresbrakesAndStopping = [self.scores objectForKey:@"Use of Brakes and Stopping"];
        NSMutableDictionary * brakesAndStopping = [[NSMutableDictionary alloc] init];
        [brakesAndStopping setObject:scoresbrakesAndStopping[0] forKey:@"checks_rear_or_gives_warning"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[1] forKey:@"full_stop_or_smooth"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[2] forKey:@"does_not_fan"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[3] forKey:@"down_shifts"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[4] forKey:@"uses_foot_brake_only"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[5] forKey:@"hand_valve_use"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[6] forKey:@"does_not_roll_back"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[7] forKey:@"engine_assist"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[8] forKey:@"avoids_sudden_stops"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes6"]]) {
            [brakesAndStopping setObject:[self.values objectForKey:@"Notes6"] forKey:@"notes"];
        }
        
        [dict setObject:brakesAndStopping forKey:@"brakes_and_stopping"];
        

        NSArray *scoreseyeMovementAndMirror = [self.scores objectForKey:@"Eye Movement and Mirror Use"];
        NSMutableDictionary *eyeMovementAndMirror = [[NSMutableDictionary alloc] init];
        [eyeMovementAndMirror setObject:scoreseyeMovementAndMirror[0] forKey:@"eyes_ahead"];
        [eyeMovementAndMirror setObject:scoreseyeMovementAndMirror[1] forKey:@"follow_up_in_mirror"];
        [eyeMovementAndMirror setObject:scoreseyeMovementAndMirror[2] forKey:@"checks_mirror"];
        [eyeMovementAndMirror setObject:scoreseyeMovementAndMirror[3] forKey:@"scans_does_not_stare"];
        [eyeMovementAndMirror setObject:scoreseyeMovementAndMirror[4] forKey:@"avoid_billboards"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes7"]]) {
            [eyeMovementAndMirror setObject:[self.values objectForKey:@"Notes7"] forKey:@"notes"];
        }
        
        [dict setObject:eyeMovementAndMirror forKey:@"eye_movement_and_mirror"];
        
        
        NSArray *scoresrecognizesHazards = [self.scores objectForKey:@"Recognizes Hazards"];
        NSMutableDictionary *recognizesHazards  = [[NSMutableDictionary alloc] init];
        [recognizesHazards  setObject:scoresrecognizesHazards[0] forKey:@"uses_horn"];
        [recognizesHazards  setObject:scoresrecognizesHazards[1] forKey:@"makes_adjustments"];
        [recognizesHazards  setObject:scoresrecognizesHazards[2] forKey:@"path_of_least_resistance"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes8"]]) {
            [recognizesHazards setObject:[self.values objectForKey:@"Notes8"] forKey:@"notes"];
        }
        
        [dict setObject:recognizesHazards forKey:@"recognizes_hazards"];
        
        
        NSArray *scoreslightsAndSignals = [self.scores objectForKey:@"Lights and Signals"];
        NSMutableDictionary *lightsAndSignals  = [[NSMutableDictionary alloc] init];
        [lightsAndSignals  setObject:scoreslightsAndSignals[0] forKey:@"proper_use_of_lights"];
        [lightsAndSignals  setObject:scoreslightsAndSignals[1] forKey:@"adjust_speed"];
        [lightsAndSignals  setObject:scoreslightsAndSignals[2] forKey:@"signals_well_in_advance"];
        [lightsAndSignals  setObject:scoreslightsAndSignals[3] forKey:@"cancels_signal"];
        [lightsAndSignals  setObject:scoreslightsAndSignals[4] forKey:@"use_of_4_ways"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes9"]]) {
            [lightsAndSignals setObject:[self.values objectForKey:@"Notes9"] forKey:@"notes"];
        }
        
        [dict setObject:lightsAndSignals forKey:@"lights_and_signals"];
        
        NSArray *scoressteering= [self.scores objectForKey:@"Steering"];
        NSMutableDictionary *steering  = [[NSMutableDictionary alloc] init];
        [steering  setObject:scoressteering[0] forKey:@"over_steers"];
        [steering  setObject:scoressteering[1] forKey:@"floats"];
        [steering  setObject:scoressteering[2] forKey:@"poisture_and_grip"];
        [steering  setObject:scoressteering[3] forKey:@"centered_in_lane"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes10"]]) {
            [steering setObject:[self.values objectForKey:@"Notes10"] forKey:@"notes"];
        }
        
        [dict setObject:steering forKey:@"steering"];
        
        NSArray *scoresbacking= [self.scores objectForKey:@"Backing"];
        NSMutableDictionary *backing  = [[NSMutableDictionary alloc] init];
        [backing  setObject:scoresbacking[0] forKey:@"size_of_situation"];
        [backing  setObject:scoresbacking[1] forKey:@"driver_side_back"];
        [backing  setObject:scoresbacking[2] forKey:@"check_rear"];
        [backing  setObject:scoresbacking[3] forKey:@"gets_attention"];
        [backing  setObject:scoresbacking[4] forKey:@"backs_slowly"];
        [backing  setObject:scoresbacking[5] forKey:@"rechecks_conditions"];
        [backing  setObject:scoresbacking[6] forKey:@"uses_other_aids"];
        [backing  setObject:scoresbacking[7] forKey:@"steers_correctly"];
        [backing  setObject:scoresbacking[8] forKey:@"does_not_hit_dock"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes11"]]) {
            [backing setObject:[self.values objectForKey:@"Notes11"] forKey:@"notes"];
        }
        
        [dict setObject:steering forKey:@"backing"];
        
        NSArray *scoresspeed= [self.scores objectForKey:@"Speed"];
        NSMutableDictionary *speed  = [[NSMutableDictionary alloc] init];
        [speed  setObject:scoresspeed[0] forKey:@"adjust_to_conditions"];
        [speed  setObject:scoresspeed[1] forKey:@"speed"];
        [speed  setObject:scoresspeed[2] forKey:@"proper_following_distance"];
        [speed  setObject:scoresspeed[3] forKey:@"speed_on_curves"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes12"]]) {
            [speed setObject:[self.values objectForKey:@"Notes12"] forKey:@"notes"];
        }
        
        [dict setObject:speed forKey:@"speed"];
        
        NSArray *scoresintersections= [self.scores objectForKey:@"Intersections"];
        NSMutableDictionary *intersections  = [[NSMutableDictionary alloc] init];
        [intersections  setObject:scoresintersections[0] forKey:@"approach_decision_point"];
        [intersections  setObject:scoresintersections[1] forKey:@"clear_intersection"];
        [intersections  setObject:scoresintersections[2] forKey:@"check_mirrors"];
        [intersections  setObject:scoresintersections[3] forKey:@"full_stop"];
        [intersections  setObject:scoresintersections[4] forKey:@"times_light_or_starts"];
        [intersections  setObject:scoresintersections[5] forKey:@"steering_axel_staright"];
        [intersections  setObject:scoresintersections[6] forKey:@"yields_right_of_way"];
        [intersections  setObject:scoresintersections[7] forKey:@"proper_speed_or_gear"];
        [intersections  setObject:scoresintersections[8] forKey:@"leaves_space"];
        [intersections  setObject:scoresintersections[9] forKey:@"stop_lines"];
        [intersections  setObject:scoresintersections[10] forKey:@"railroad_crossings"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes13"]]) {
            [intersections setObject:[self.values objectForKey:@"Notes13"] forKey:@"notes"];
        }
        
        [dict setObject:intersections forKey:@"intersections"];
        
        NSArray *scoresturning= [self.scores objectForKey:@"Turning"];
        NSMutableDictionary *turning  = [[NSMutableDictionary alloc] init];
        [turning  setObject:scoresturning[0] forKey:@"signals_correctly"];
        [turning  setObject:scoresturning[1] forKey:@"gets_in_proper_time"];
        [turning  setObject:scoresturning[2] forKey:@"downshifts_to_pulling_gear"];
        [turning  setObject:scoresturning[3] forKey:@"handles_light_correctly"];
        [turning  setObject:scoresturning[4] forKey:@"setup_and_execution"];
        [turning  setObject:scoresturning[5] forKey:@"turn_speed"];
        [turning  setObject:scoresturning[6] forKey:@"mirror_follow_up"];
        [turning  setObject:scoresturning[7] forKey:@"turns_lane_to_lane"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes14"]]) {
            [turning setObject:[self.values objectForKey:@"Notes14"] forKey:@"notes"];
        }
        
        [dict setObject:turning forKey:@"turning"];
        
        NSArray *scoresparking= [self.scores objectForKey:@"Parking"];
        NSMutableDictionary *parking  = [[NSMutableDictionary alloc] init];
        [parking  setObject:scoresparking[0] forKey:@"does_not_hit_curb"];
        [parking  setObject:scoresparking[1] forKey:@"curbs_wheels"];
        [parking  setObject:scoresparking[2] forKey:@"chock_wheels"];
        [parking  setObject:scoresparking[3] forKey:@"park_brake_applied"];
        [parking  setObject:scoresparking[4] forKey:@"trans_in_neutral"];
        [parking  setObject:scoresparking[5] forKey:@"engine_off"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes15"]]) {
            [parking setObject:[self.values objectForKey:@"Notes15"] forKey:@"notes"];
        }
        
        [dict setObject:parking forKey:@"parking"];
        

        NSArray *scoresmultipleTrailers= [self.scores objectForKey:@"Multiple trailers"];
        NSMutableDictionary *multipleTrailers  = [[NSMutableDictionary alloc] init];
        [multipleTrailers  setObject:scoresmultipleTrailers[0] forKey:@"heavier_trailer_in_front"];
        [multipleTrailers  setObject:scoresmultipleTrailers[1] forKey:@"builds_equip_properly"];
        [multipleTrailers  setObject:scoresmultipleTrailers[2] forKey:@"understand_types_of_dollies"];
        [multipleTrailers  setObject:scoresmultipleTrailers[3] forKey:@"secures_dolly_properly"];
        [multipleTrailers  setObject:scoresmultipleTrailers[4] forKey:@"speed_control_on_turns"];
        [multipleTrailers  setObject:scoresmultipleTrailers[5] forKey:@"avoids_abrupt_meneuvers"];
        [multipleTrailers  setObject:scoresmultipleTrailers[6] forKey:@"backs_one_item"];
        [multipleTrailers  setObject:scoresmultipleTrailers[7] forKey:@"safe_while_connecting_dolly"];
        [multipleTrailers  setObject:scoresmultipleTrailers[8] forKey:@"avoid_shifting_load"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes16"]]) {
            [multipleTrailers setObject:[self.values objectForKey:@"Notes16"] forKey:@"notes"];
        }
        
        [dict setObject:multipleTrailers forKey:@"multiple_trailers"];
        
        NSArray *scoreshills= [self.scores objectForKey:@"Hills"];
        NSMutableDictionary *hills  = [[NSMutableDictionary alloc] init];
        [hills  setObject:scoreshills[0] forKey:@"proper_gear_up_down"];
        [hills  setObject:scoreshills[1] forKey:@"avoids_rolling_back"];
        [hills  setObject:scoreshills[2] forKey:@"test_brakes_prior"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes17"]]) {
            [hills setObject:[self.values objectForKey:@"Notes17"] forKey:@"notes"];
        }
        
        [dict setObject:hills forKey:@"hills"];
        
        NSArray *scorepassing= [self.scores objectForKey:@"Passing"];
        NSMutableDictionary *passing  = [[NSMutableDictionary alloc] init];
        [passing  setObject:scorepassing[0] forKey:@"sufficient_space_to_pass"];
        [passing  setObject:scorepassing[1] forKey:@"signals_property"];
        [passing  setObject:scorepassing[2] forKey:@"check_mirrors"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes18"]]) {
            [passing setObject:[self.values objectForKey:@"Notes18"] forKey:@"notes"];
        }
        
        [dict setObject:passing forKey:@"passing"];
        
        NSArray *scoregeneralSafetyAndTot= [self.scores objectForKey:@"General safety and DOT adherence"];
        NSMutableDictionary *generalSafetyAndTot  = [[NSMutableDictionary alloc] init];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[0] forKey:@"avoids_crowding_effect"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[1] forKey:@"stays_right_or_correct_lane"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[2] forKey:@"aware_hours_of_service"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[3] forKey:@"proper_use_off_mirrors"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[4] forKey:@"self_confident_not_complacement"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[5] forKey:@"check_instruments"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[6] forKey:@"uses_horn_properly"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[7] forKey:@"maintains_dot_log"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[8] forKey:@"drives_defensively"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[9] forKey:@"company_haz_mat_protocol"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[10] forKey:@"air_cans_or_line_moisture_free"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[11] forKey:@"avoid_distractions_while_driving"];
        [generalSafetyAndTot  setObject:scoregeneralSafetyAndTot[12] forKey:@"works_safely_to_avoid_injuries"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes19"]]) {
            [generalSafetyAndTot setObject:[self.values objectForKey:@"Notes19"] forKey:@"notes"];
        }
        
        [dict setObject:generalSafetyAndTot forKey:@"general_safety_and_dot_adherence"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        
        for(id key in dict) {
            NSDictionary *item = [dict objectForKey:key];
            
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
            
            if ([item isKindOfClass:[NSDictionary class]]) {
                for(id key1 in item) {
                    
                    NSString *val = [[item valueForKey:key1] stringValue];
                    
                    if ([val isEqual:@"-1"]) {
                        [newDict setObject:@"0" forKey:key1];
                        NSLog(@"key=%@ value=%@", key1, [item objectForKey:key1]);
                    } else {
                        [newDict setObject:val forKey:key1];
                    }
                    
                }
                
                [params setObject:newDict forKey:key];
                
            } else {
                [params setObject:item forKey:key];
            }
            
            
        }
        
        [dict removeAllObjects];
        
        dict = params;
        
        
            
        
        urlEndPoint = @"btw";
    }
    
    
    
    
    if ([self.formNumber isEqualToString:TestSWP]) {
        NSArray *scoresemployeesInterview = [self.scores objectForKey:@"Employees Interview"];
        NSMutableDictionary * employeesInterview = [[NSMutableDictionary alloc] init];
        if ([scoresemployeesInterview[0] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"positive_attitude"];
        } else {
            [employeesInterview setObject:@NO forKey:@"positive_attitude"];
        }
        
        if ([scoresemployeesInterview[1] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"nearest_exit"];
        } else {
            [employeesInterview setObject:@NO forKey:@"nearest_exit"];
        }
        
        if ([scoresemployeesInterview[2] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"eye_wash"];
        } else {
            [employeesInterview setObject:@NO forKey:@"eye_wash"];
        }
        
        if ([scoresemployeesInterview[3] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"evacuation_plan"];
        } else {
            [employeesInterview setObject:@NO forKey:@"evacuation_plan"];
        }
        
        if ([scoresemployeesInterview[4] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"evacuation_assembly"];
        } else {
            [employeesInterview setObject:@NO forKey:@"evacuation_assembly"];
        }
        
        if ([scoresemployeesInterview[5] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"equipment_emergency_shut_offs"];
        } else {
            [employeesInterview setObject:@NO forKey:@"equipment_emergency_shut_offs"];
        }
        
        if ([scoresemployeesInterview[6] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"evacuation_notification"];
        } else {
            [employeesInterview setObject:@NO forKey:@"evacuation_notification"];
        }
        
        if ([scoresemployeesInterview[7] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"demonstrate_power_zone"];
        } else {
            [employeesInterview setObject:@NO forKey:@"demonstrate_power_zone"];
        }
        
        if ([scoresemployeesInterview[8] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"dehydration"];
        } else {
            [employeesInterview setObject:@NO forKey:@"dehydration"];
        }
        
        if ([scoresemployeesInterview[9] intValue] == 5) {
            [employeesInterview setObject:@YES forKey:@"employee_understand_protocol"];
        } else {
            [employeesInterview setObject:@NO forKey:@"employee_understand_protocol"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes0"]]) {
            [employeesInterview setObject:[self.values objectForKey:@"Notes0"] forKey:@"notes"];
        }
        
        [dict setObject:employeesInterview forKey:@"employees_interview"];
        
        NSArray *scorespowerEquipment = [self.scores objectForKey:@"Power Equipment"];
        NSMutableDictionary * powerEquipment = [[NSMutableDictionary alloc] init];
        [powerEquipment setObject:scorespowerEquipment[0] forKey:@"eye_contact_with_operator"];
        [powerEquipment setObject:scorespowerEquipment[1] forKey:@"lock_out_tag_out"];
        [powerEquipment setObject:scorespowerEquipment[2] forKey:@"using_conveyor_equipment"];
        [powerEquipment setObject:scorespowerEquipment[3] forKey:@"system_security"];
        [powerEquipment setObject:scorespowerEquipment[4] forKey:@"equipement_pinch_points"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes1"]]) {
            [powerEquipment setObject:[self.values objectForKey:@"Notes1"] forKey:@"notes"];
        }
        
        [dict setObject:powerEquipment forKey:@"power_equipment"];
        
        NSArray *scoresjobSetup = [self.scores objectForKey:@"Job Setup"];
        NSMutableDictionary * jobSetup = [[NSMutableDictionary alloc] init];
        [jobSetup setObject:scoresjobSetup[0] forKey:@"shoes_slip_resistant"];
        [jobSetup setObject:scoresjobSetup[1] forKey:@"shoes_good_repair"];
        [jobSetup setObject:scoresjobSetup[2] forKey:@"arrives_on_time"];
        [jobSetup setObject:scoresjobSetup[3] forKey:@"organizes_tools"];
        [jobSetup setObject:scoresjobSetup[4] forKey:@"avoids_distractions"];
        [jobSetup setObject:scoresjobSetup[5] forKey:@"focus_on_assignment"];
        [jobSetup setObject:scoresjobSetup[6] forKey:@"start_with_stretching"];
        [jobSetup setObject:scoresjobSetup[7] forKey:@"stretch_after_long_delays"];
        [jobSetup setObject:scoresjobSetup[8] forKey:@"stay_hydrated"];
        [jobSetup setObject:scoresjobSetup[9] forKey:@"breaks_and_lunches_adhered_to"];
        [jobSetup setObject:scoresjobSetup[10] forKey:@"dress_appropriately"];
        [jobSetup setObject:scoresjobSetup[11] forKey:@"clean_work_area"];
        [jobSetup setObject:scoresjobSetup[12] forKey:@"no_tripping_hazards"];
        [jobSetup setObject:scoresjobSetup[13] forKey:@"secure_power_equipment"];
        [jobSetup setObject:scoresjobSetup[14] forKey:@"maintain_daily_routine"];
        [jobSetup setObject:scoresjobSetup[15] forKey:@"proper_tool_storage"];
        [jobSetup setObject:scoresjobSetup[16] forKey:@"report_safety_hazards"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes2"]]) {
            [jobSetup setObject:[self.values objectForKey:@"Notes2"] forKey:@"notes"];
        }
        
        [dict setObject:jobSetup forKey:@"job_setup"];
        
        NSArray *scoresexpectTheUnexpected = [self.scores objectForKey:@"Expect the Unexpected"];
        NSMutableDictionary * expectTheUnexpected = [[NSMutableDictionary alloc] init];
        [expectTheUnexpected setObject:scoresexpectTheUnexpected[0] forKey:@"use_designated_walkways"];
        [expectTheUnexpected setObject:scoresexpectTheUnexpected[1] forKey:@"place_and_secure_objects"];
        [expectTheUnexpected setObject:scoresexpectTheUnexpected[2] forKey:@"face_work_flow"];
        [expectTheUnexpected setObject:scoresexpectTheUnexpected[3] forKey:@"use_caution_when_opening_doors"];
        [expectTheUnexpected setObject:scoresexpectTheUnexpected[4] forKey:@"know_location_of_emergency_equipment"];
        [expectTheUnexpected setObject:scoresexpectTheUnexpected[5] forKey:@"verify_proper_egress"];
        [expectTheUnexpected setObject:scoresexpectTheUnexpected[6] forKey:@"look_for_Sharp_splintery_cutting_hazards"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes3"]]) {
            [expectTheUnexpected setObject:[self.values objectForKey:@"Notes3"] forKey:@"notes"];
        }
        
        [dict setObject:expectTheUnexpected forKey:@"expect_the_unexpected"];
        
        
        NSArray *scorespushingAndPulling = [self.scores objectForKey:@"Pushing and Pulling"];
        NSMutableDictionary * pushingAndPulling = [[NSMutableDictionary alloc] init];
        [pushingAndPulling setObject:scorespushingAndPulling[0] forKey:@"keeps_work_in_front"];
        [pushingAndPulling setObject:scorespushingAndPulling[1] forKey:@"seek_assistant"];
        [pushingAndPulling setObject:scorespushingAndPulling[2] forKey:@"keep_arms_slightly_bent"];
        [pushingAndPulling setObject:scorespushingAndPulling[3] forKey:@"heavy_off_shaped_objects"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes4"]]) {
            [pushingAndPulling setObject:[self.values objectForKey:@"Notes4"] forKey:@"notes"];
        }
        
        [dict setObject:pushingAndPulling forKey:@"pushing_and_pulling"];
        
        NSArray *scoresendRangeMotion = [self.scores objectForKey:@"End Range Motion"];
        NSMutableDictionary * endRangeMotion = [[NSMutableDictionary alloc] init];
        [endRangeMotion setObject:scoresendRangeMotion[0] forKey:@"position_shoulder_parallel"];
        [endRangeMotion setObject:scoresendRangeMotion[1] forKey:@"use_equipment"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes5"]]) {
            [endRangeMotion setObject:[self.values objectForKey:@"Notes5"] forKey:@"notes"];
        }
        
        [dict setObject:endRangeMotion forKey:@"end_range_motion"];
        
        NSArray *scoreskeysLiftingLowering = [self.scores objectForKey:@"Keys to avoiding Slips and Falls"];
        NSMutableDictionary * keysLiftingLowering = [[NSMutableDictionary alloc] init];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[0] forKey:@"close_to_object_shoulders"];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[1] forKey:@"position_feet"];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[3] forKey:@"bend_your_knees"];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[4] forKey:@"test_weight"];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[5] forKey:@"firm_grip"];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[6] forKey:@"smooth_steady_lift"];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[7] forKey:@"pivot_feet_never_twist"];
        [keysLiftingLowering setObject:scoreskeysLiftingLowering[8] forKey:@"use_equipment_designed"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes6"]]) {
            [keysLiftingLowering setObject:[self.values objectForKey:@"Notes6"] forKey:@"notes"];
        }
        
        [dict setObject:keysLiftingLowering forKey:@"keys_lifting_and_lowering"];
        
        
        NSArray *scorescuttingHazards = [self.scores objectForKey:@"Be aware of cutting hazards and sharp objects"];
        NSMutableDictionary * cuttingHazards = [[NSMutableDictionary alloc] init];
        [cuttingHazards setObject:scorescuttingHazards[0] forKey:@"designate_storage_area"];
        [cuttingHazards setObject:scorescuttingHazards[1] forKey:@"use_tabe_guns_properly"];
        [cuttingHazards setObject:scorescuttingHazards[2] forKey:@"aware_of_sharp_edges"];
        [cuttingHazards setObject:scorescuttingHazards[3] forKey:@"wares_gloves_when_possible"];
        [cuttingHazards setObject:scorescuttingHazards[4] forKey:@"keep_blade_short"];
        [cuttingHazards setObject:scorescuttingHazards[5] forKey:@"keep_blade_short"];
        [cuttingHazards setObject:scorescuttingHazards[6] forKey:@"retract_blade"];
        [cuttingHazards setObject:scorescuttingHazards[7] forKey:@"angle_cutting_surface"];
        [cuttingHazards setObject:scorescuttingHazards[8] forKey:@"apply_consisten_firm_pressure"];
        [cuttingHazards setObject:scorescuttingHazards[9] forKey:@"keep_thumbs_away"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes7"]]) {
            [cuttingHazards setObject:[self.values objectForKey:@"Notes7"] forKey:@"notes"];
        }
        
        [dict setObject:cuttingHazards forKey:@"cutting_hazards_and_sharp_objects"];
        
        NSArray *scoresSlipFalls = [self.scores objectForKey:@"Keys to avoiding Slips and Falls"];
        NSMutableDictionary *slipFalls = [[NSMutableDictionary alloc] init];
        [slipFalls setObject:scoresSlipFalls[0] forKey:@"walks_with_intent"];
        [slipFalls setObject:scoresSlipFalls[1] forKey:@"maintain_balance"];
        [slipFalls setObject:scoresSlipFalls[2] forKey:@"stays_off"];
        [slipFalls setObject:scoresSlipFalls[3] forKey:@"scan_work_area"];
        [slipFalls setObject:scoresSlipFalls[4] forKey:@"aware_of_changing_conditions"];
        [slipFalls setObject:scoresSlipFalls[5] forKey:@"keep_walk_paths_clear_and_clean"];
        [slipFalls setObject:scoresSlipFalls[6] forKey:@"face_ladders_and_equipment"];
        [slipFalls setObject:scoresSlipFalls[7] forKey:@"use_three_points_of_contact"];
        [slipFalls setObject:scoresSlipFalls[8] forKey:@"uses_hand_rails"];
        [slipFalls setObject:scoresSlipFalls[9] forKey:@"uses_designated_routes"];
        [slipFalls setObject:scoresSlipFalls[10] forKey:@"safety_chains_and_gates_used_properly"];
        [slipFalls setObject:scoresSlipFalls[11] forKey:@"four_feet_rule"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes8"]]) {
            [slipFalls setObject:[self.values objectForKey:@"Notes8"] forKey:@"notes"];
        }
        
        [dict setObject:slipFalls forKey:@"eys_to_avoidings_lips_and_falls"];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for(id key in dict) {
            NSDictionary *item = [dict objectForKey:key];
            
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
            
            if ([item isKindOfClass:[NSDictionary class]]) {
                for(id key1 in item) {
                    
                    NSString *val = [[item valueForKey:key1] stringValue];
                    
                    if ([val isEqual:@"-1"]) {
                        [newDict setObject:@"0" forKey:key1];
                        NSLog(@"key=%@ value=%@", key1, [item objectForKey:key1]);
                    } else {
                        [newDict setObject:val forKey:key1];
                    }
                    
                }
                
                [params setObject:newDict forKey:key];
                
            } else {
                [params setObject:item forKey:key];
            }
            
            
        }
        
        [dict removeAllObjects];
        
        dict = params;
        
        urlEndPoint = @"swp";
    }
    
    if ([self.formNumber isEqualToString:TestVRT]) {
        
        NSArray *scorespreTrip = [self.scores objectForKey:@"Pre-Trip"];
        NSMutableDictionary * preTrip = [[NSMutableDictionary alloc] init];
        [preTrip setObject:scorespreTrip[0] forKey:@"emergency_device"];
        [preTrip setObject:scorespreTrip[1] forKey:@"documents"];
        [preTrip setObject:scorespreTrip[2] forKey:@"htr_air_dfr"];
        [preTrip setObject:scorespreTrip[3] forKey:@"wipers"];
        [preTrip setObject:scorespreTrip[4] forKey:@"pedals"];
        [preTrip setObject:scorespreTrip[5] forKey:@"gauges"];
        [preTrip setObject:scorespreTrip[6] forKey:@"switches"];
        [preTrip setObject:scorespreTrip[7] forKey:@"steering"];
        [preTrip setObject:scorespreTrip[8] forKey:@"mirrors"];
        [preTrip setObject:scorespreTrip[9] forKey:@"horn"];
        [preTrip setObject:scorespreTrip[10] forKey:@"engine"];
        [preTrip setObject:scorespreTrip[11] forKey:@"fluids"];
        [preTrip setObject:scorespreTrip[12] forKey:@"lights"];
        [preTrip setObject:scorespreTrip[13] forKey:@"reflectors"];
        [preTrip setObject:scorespreTrip[14] forKey:@"air_lines"];
        [preTrip setObject:scorespreTrip[15] forKey:@"coupling_devices"];
        [preTrip setObject:scorespreTrip[16] forKey:@"tires"];
        [preTrip setObject:scorespreTrip[17] forKey:@"wheels"];
        [preTrip setObject:scorespreTrip[18] forKey:@"chassis_undercarriage"];
        [preTrip setObject:scorespreTrip[19] forKey:@"leaks_air_fluid"];
        [preTrip setObject:scorespreTrip[20] forKey:@"drain_air_tanks"];
        [preTrip setObject:scorespreTrip[21] forKey:@"park_or_emer_brake"];
        [preTrip setObject:scorespreTrip[22] forKey:@"serv_brake_test"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes0"]]) {
            [preTrip setObject:[self.values objectForKey:@"Notes0"] forKey:@"notes"];
        }
        
        [dict setObject:preTrip forKey:@"pre_trip"];
        
        NSArray *scorescoupling = [self.scores objectForKey:@"Coupling"];
        NSMutableDictionary * coupling = [[NSMutableDictionary alloc] init];
        [coupling setObject:scorescoupling[0] forKey:@"equipment_alignment"];
        [coupling setObject:scorescoupling[1] forKey:@"air_lines_or_light_cord"];
        [coupling setObject:scorescoupling[2] forKey:@"check_for_hazards"];
        [coupling setObject:scorescoupling[3] forKey:@"back_under_slowly"];
        [coupling setObject:scorescoupling[4] forKey:@"test_tug"];
        [coupling setObject:scorescoupling[5] forKey:@"secures_equip_properly"];
        [coupling setObject:scorescoupling[6] forKey:@"verfiy_couple_secure"];
        [coupling setObject:scorescoupling[7] forKey:@"raise_landing_gear"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes1"]]) {
            [coupling setObject:[self.values objectForKey:@"Notes1"] forKey:@"notes"];
        }
        
        [dict setObject:coupling forKey:@"coupling"];
        
        NSArray *scoresuncoupling = [self.scores objectForKey:@"Uncoupling"];
        NSMutableDictionary * uncoupling = [[NSMutableDictionary alloc] init];
        [uncoupling setObject:scoresuncoupling[0] forKey:@"secure_equip_properly"];
        [uncoupling setObject:scoresuncoupling[1] forKey:@"chock_wheels"];
        [uncoupling setObject:scoresuncoupling[2] forKey:@"lower_landing_gear"];
        [uncoupling setObject:scoresuncoupling[3] forKey:@"air_lanes_or_light_cord"];
        [uncoupling setObject:scoresuncoupling[4] forKey:@"unlock_fifth_gear"];
        [uncoupling setObject:scoresuncoupling[5] forKey:@"lower_trailer_gently"];
        [uncoupling setObject:scoresuncoupling[6] forKey:@"test"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes2"]]) {
            [uncoupling setObject:[self.values objectForKey:@"Notes2"] forKey:@"notes"];
        }
        
        [dict setObject:uncoupling forKey:@"uncoupling"];
        
        NSArray *scoresengineOperations = [self.scores objectForKey:@"Engine Operations"];
        NSMutableDictionary * engineOperations = [[NSMutableDictionary alloc] init];
        [engineOperations setObject:scoresengineOperations[0] forKey:@"lugging"];
        [engineOperations setObject:scoresengineOperations[1] forKey:@"over_revving"];
        [engineOperations setObject:scoresengineOperations[2] forKey:@"check_gauges"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes3"]]) {
            [engineOperations setObject:[self.values objectForKey:@"Notes3"] forKey:@"notes"];
        }
        
        [dict setObject:engineOperations forKey:@"engine_operations"];
        
        NSArray *scoresenginestartEngine = [self.scores objectForKey:@"Start Engine"];
        NSMutableDictionary * startEngine = [[NSMutableDictionary alloc] init];
        [startEngine setObject:scoresenginestartEngine[0] forKey:@"park_brake_applied"];
        [startEngine setObject:scoresenginestartEngine[1] forKey:@"transmission_in_neutral"];
        [startEngine setObject:scoresenginestartEngine[2] forKey:@"clutch_depressed"];
        [startEngine setObject:scoresenginestartEngine[3] forKey:@"starter_used_properly"];
        [startEngine setObject:scoresenginestartEngine[4] forKey:@"reads_gauges"];
        [startEngine setObject:scoresenginestartEngine[5] forKey:@"seat_belt"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes4"]]) {
            [startEngine setObject:[self.values objectForKey:@"Notes4"] forKey:@"notes"];
        }
        
        [dict setObject:startEngine forKey:@"start_engine"];
        
        NSArray *scoresuseOfClutch = [self.scores objectForKey:@"Use of Clutch"];
        NSMutableDictionary * useOfClutch = [[NSMutableDictionary alloc] init];
        [useOfClutch setObject:scoresuseOfClutch[0] forKey:@"disengages_completely"];
        [useOfClutch setObject:scoresuseOfClutch[1] forKey:@"engages_smoothly"];
        [useOfClutch setObject:scoresuseOfClutch[2] forKey:@"double_clutches_properly"];
        [useOfClutch setObject:scoresuseOfClutch[3] forKey:@"rides_clutch"];
        [useOfClutch setObject:scoresuseOfClutch[4] forKey:@"coast"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes5"]]) {
            [useOfClutch setObject:[self.values objectForKey:@"Notes5"] forKey:@"notes"];
        }
        
        [dict setObject:useOfClutch forKey:@"use_of_clutch"];
        
        NSArray *scoresuseOfTransmission = [self.scores objectForKey:@"Use of Transmission"];
        NSMutableDictionary * useOfTransmission = [[NSMutableDictionary alloc] init];
        [useOfTransmission setObject:scoresuseOfTransmission[0] forKey:@"starts_in_low_gear"];
        [useOfTransmission setObject:scoresuseOfTransmission[1] forKey:@"proper_sequence"];
        [useOfTransmission setObject:scoresuseOfTransmission[2] forKey:@"shifts_without_classing"];
        [useOfTransmission setObject:scoresuseOfTransmission[3] forKey:@"timing_up"];
        [useOfTransmission setObject:scoresuseOfTransmission[4] forKey:@"timing_down"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes6"]]) {
            [useOfTransmission setObject:[self.values objectForKey:@"Notes6"] forKey:@"notes"];
        }
        
        [dict setObject:useOfTransmission forKey:@"use_of_transmission"];
        
        NSArray *scoresuseOfBrakes = [self.scores objectForKey:@"Use of Brakes"];
        NSMutableDictionary * useOfBrakes = [[NSMutableDictionary alloc] init];
        [useOfBrakes setObject:scoresuseOfBrakes[0] forKey:@"smoothly_applies"];
        [useOfBrakes setObject:scoresuseOfBrakes[1] forKey:@"stops_smoothly"];
        [useOfBrakes setObject:scoresuseOfBrakes[2] forKey:@"fans_brakes"];
        [useOfBrakes setObject:scoresuseOfBrakes[3] forKey:@"engine_assist_brake"];
        [useOfBrakes setObject:scoresuseOfBrakes[4] forKey:@"foot_brake_only"];
        [useOfBrakes setObject:scoresuseOfBrakes[5] forKey:@"hv_when_stopped_traffic"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes7"]]) {
            [useOfBrakes setObject:[self.values objectForKey:@"Notes7"] forKey:@"notes"];
        }
        
        [dict setObject:useOfBrakes forKey:@"use_of_brakes"];
        
        NSArray *scoresbacking = [self.scores objectForKey:@"Backing"];
        NSMutableDictionary * backing = [[NSMutableDictionary alloc] init];
        [backing setObject:scoresbacking[0] forKey:@"checks_rear"];
        [backing setObject:scoresbacking[1] forKey:@"communicates"];
        [backing setObject:scoresbacking[2] forKey:@"backs_slowly"];
        [backing setObject:scoresbacking[3] forKey:@"checks_mirror"];
        [backing setObject:scoresbacking[4] forKey:@"uses_other_aids"];
        [backing setObject:scoresbacking[5] forKey:@"looks_out_window"];
        [backing setObject:scoresbacking[6] forKey:@"steers_correctly"];
        [backing setObject:scoresbacking[7] forKey:@"does_not_hit_dock"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes8"]]) {
            [backing setObject:[self.values objectForKey:@"Notes8"] forKey:@"notes"];
        }
        
        [dict setObject:backing forKey:@"backing"];
        
        NSArray *scoresparking = [self.scores objectForKey:@"Parking"];
        NSMutableDictionary * parking = [[NSMutableDictionary alloc] init];
        [parking setObject:scoresparking[0] forKey:@"does_not_hit_dock"];
        [parking setObject:scoresparking[1] forKey:@"curbs_wheel"];
        [parking setObject:scoresparking[2] forKey:@"chocks_wheel"];
        [parking setObject:scoresparking[3] forKey:@"parking_brake_applied"];
        [parking setObject:scoresparking[4] forKey:@"transmission_neutral"];
        [parking setObject:scoresparking[5] forKey:@"engine_off_pull_key"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes9"]]) {
            [parking setObject:[self.values objectForKey:@"Notes9"] forKey:@"notes"];
        }
        
        [dict setObject:parking forKey:@"parking"];
        
        NSArray *scoresdrivingHabits = [self.scores objectForKey:@"Driving Habits"];
        NSMutableDictionary * drivingHabits = [[NSMutableDictionary alloc] init];
        [drivingHabits setObject:scoresdrivingHabits[0] forKey:@"trafic_signals"];
        [drivingHabits setObject:scoresdrivingHabits[1] forKey:@"warning_signals"];
        [drivingHabits setObject:scoresdrivingHabits[2] forKey:@"use_of_horn"];
        [drivingHabits setObject:scoresdrivingHabits[3] forKey:@"steering"];
        [drivingHabits setObject:scoresdrivingHabits[4] forKey:@"intersections"];
        [drivingHabits setObject:scoresdrivingHabits[5] forKey:@"use_of_lanes"];
        [drivingHabits setObject:scoresdrivingHabits[6] forKey:@"right_of_way"];
        [drivingHabits setObject:scoresdrivingHabits[7] forKey:@"following"];
        [drivingHabits setObject:scoresdrivingHabits[8] forKey:@"right_of_turns"];
        [drivingHabits setObject:scoresdrivingHabits[9] forKey:@"left_turns"];
        [drivingHabits setObject:scoresdrivingHabits[10] forKey:@"speed_control"];
        [drivingHabits setObject:scoresdrivingHabits[11] forKey:@"use_of_mirrors"];
        [drivingHabits setObject:scoresdrivingHabits[12] forKey:@"passing"];
        [drivingHabits setObject:scoresdrivingHabits[13] forKey:@"alertness"];
        [drivingHabits setObject:scoresdrivingHabits[14] forKey:@"area_knowledge"];
        [drivingHabits setObject:scoresdrivingHabits[15] forKey:@"defensive_driving"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes10"]]) {
            [drivingHabits setObject:[self.values objectForKey:@"Notes10"] forKey:@"notes"];
        }
        
        [dict setObject:drivingHabits forKey:@"driving_habits"];
        
        NSArray *scorespostTrip = [self.scores objectForKey:@"Post-Trip"];
        NSMutableDictionary * postTrip = [[NSMutableDictionary alloc] init];
        [postTrip setObject:scorespostTrip[0] forKey:@"lights"];
        [postTrip setObject:scorespostTrip[1] forKey:@"reflectors"];
        [postTrip setObject:scorespostTrip[2] forKey:@"body_damage"];
        [postTrip setObject:scorespostTrip[3] forKey:@"tires"];
        [postTrip setObject:scorespostTrip[4] forKey:@"hub_heat"];
        [postTrip setObject:scorespostTrip[5] forKey:@"leaks"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes11"]]) {
            [postTrip setObject:[self.values objectForKey:@"Notes11"] forKey:@"notes"];
        }
        
        [dict setObject:postTrip forKey:@"post_trip"];
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"testRemarks"]]) {
            [dict setObject:[self.values valueForKey:@"testRemarks"] forKey:@"remarks"];
        }
        
        
        
        
        if ([HelperSharedManager isCheckNotNULL: [self.equipmentUsed objectForKey:KeyEquipmentUsed]]) {
            TrainingEquipment *te = [self.equipmentUsed objectForKey:KeyEquipmentUsed];
            
            NSMutableArray *equps = [[NSMutableArray alloc] init];
            if (te.powerUnit) {
                [equps addObject:te.powerUnit];
            }
            if (te.trailer1Number) {
                [equps addObject:te.trailer1Number];
            }
            if (te.dolly1Number) {
                [equps addObject:te.dolly1Number];
            }
            if (te.trailer2Number) {
                [equps addObject:te.trailer2Number];
            }
            if (te.dolly2Number) {
                [equps addObject:te.dolly2Number];
            }
            if (te.trailer3Number) {
                [equps addObject:te.trailer3Number];
            }
            if (equps.count > 0) {
                [dict setObject:[equps componentsJoinedByString:@","] forKey:@"equiment_used"];
            }
            
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:KeyQualifiedOrNot]]) {
            [dict setObject:[self.values valueForKey:KeyQualifiedOrNot] forKey:@"qualified_or_not"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"state"]]) {
            [dict setObject:[self.values valueForKey:@"state"] forKey:@"state"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"testMiles"]]) {
            [dict setObject:[self.values valueForKey:@"testMiles"] forKey:@"miles"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"powerUnit"]]) {
            [dict setObject:[self.values valueForKey:@"powerUnit"] forKey:@"type_of_power_unit"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"numberofTrailers"]]) {
            [dict setObject:[self.values valueForKey:@"numberofTrailers"] forKey:@"number_of_trailers"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"trailerLength"]]) {
            [dict setObject:[self.values valueForKey:@"trailerLength"] forKey:@"trailer_length"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"disqualifiedRemarks"]]) {
            [dict setObject:[self.values valueForKey:@"disqualifiedRemarks"] forKey:@"state"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"testState"]]) {
            [dict setObject:[self.values valueForKey:@"testState"] forKey:@"disqualified_remarks"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"medicalCardExpirationDate"]]) {
            NSDate *date = [self.values valueForKey:@"medicalCardExpirationDate"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateString = [dateFormatter stringFromDate:date];
            
            [dict setObject:dateString forKey:@"medical_card_expire_date"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"evaluatorName"]]) {
            [dict setObject:[self.values valueForKey:@"evaluatorName"] forKey:@"print"];
        }
        
        if ([HelperSharedManager isCheckNotNULL: [self.values valueForKey:@"evaluatorTitle"]]) {
            [dict setObject:[self.values valueForKey:@"evaluatorTitle"] forKey:@"title"];
        }
        
        urlEndPoint = @"vrt";
    }
    
    if ([self.formNumber isEqualToString:TestBusEval]) {
        
        NSArray *scorescabSafety = [self.scores objectForKey:@"Cab Safety"];
        NSMutableDictionary * cabSafety = [[NSMutableDictionary alloc] init];
        [cabSafety setObject:scorescabSafety[0] forKey:@"seat_belt"];
        [cabSafety setObject:scorescabSafety[1] forKey:@"can_distractions"];
        [cabSafety setObject:scorescabSafety[2] forKey:@"cab_obstructions"];
        [cabSafety setObject:scorescabSafety[3] forKey:@"cab_chemicals"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes0"]]) {
            [cabSafety setObject:[self.values objectForKey:@"Notes0"] forKey:@"notes"];
        }
        
        [dict setObject:cabSafety forKey:@"cab_safety"];
        
        NSArray *scoresstartEngine= [self.scores objectForKey:@"Start Engine"];
        NSMutableDictionary * startEngine = [[NSMutableDictionary alloc] init];
        [startEngine setObject:scoresstartEngine[0] forKey:@"park_brake_applied"];
        [startEngine setObject:scoresstartEngine[1] forKey:@"trans_in_neutral"];
        [startEngine setObject:scoresstartEngine[2] forKey:@"uses_starter_properly"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes1"]]) {
            [startEngine setObject:[self.values objectForKey:@"Notes1"] forKey:@"notes"];
        }
        
        [dict setObject:startEngine forKey:@"start_engine"];
        
        NSArray *scoresengineOperation = [self.scores objectForKey:@"Engine Operation"];
        NSMutableDictionary * engineOperation = [[NSMutableDictionary alloc] init];
        [engineOperation setObject:scoresengineOperation[0] forKey:@"over_revving"];
        [engineOperation setObject:scoresengineOperation[1] forKey:@"check_gauges"];
        [engineOperation setObject:scoresengineOperation[2] forKey:@"start_off_smoothly"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes2"]]) {
            [engineOperation setObject:[self.values objectForKey:@"Notes2"] forKey:@"notes"];
        }
        
        [dict setObject:engineOperation forKey:@"engine_operation"];
        
        NSArray *scoresbrakesAndStopping = [self.scores objectForKey:@"Use of Brakes and Stopping"];
        NSMutableDictionary * brakesAndStopping = [[NSMutableDictionary alloc] init];
        [brakesAndStopping setObject:scoresbrakesAndStopping[0] forKey:@"checks_rear_or_gives_warning"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[1] forKey:@"full_stop_or_smooth"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[2] forKey:@"does_not_fan"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[3] forKey:@"down_shifts"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[4] forKey:@"uses_foot_brake_only"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[5] forKey:@"hand_valve_use"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[6] forKey:@"does_not_roll_back"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[7] forKey:@"engine_assist"];
        [brakesAndStopping setObject:scoresbrakesAndStopping[8] forKey:@"avoids_sudden_stops"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes3"]]) {
            [brakesAndStopping setObject:[self.values objectForKey:@"Notes3"] forKey:@"notes"];
        }
        
        [dict setObject:brakesAndStopping forKey:@"brakes_and_stopping"];
        
        NSArray *scorespassengerSafety = [self.scores objectForKey:@"Passenger Safety"];
        NSMutableDictionary * passengerSafety = [[NSMutableDictionary alloc] init];
        [passengerSafety setObject:scorespassengerSafety[0] forKey:@"no_one_past_standee_line"];
        [passengerSafety setObject:scorespassengerSafety[1] forKey:@"steps_clear"];
        [passengerSafety setObject:scorespassengerSafety[2] forKey:@"everyone_seated"];
        [passengerSafety setObject:scorespassengerSafety[3] forKey:@"seatbelts_on"];
        [passengerSafety setObject:scorespassengerSafety[4] forKey:@"holding_hand_rails_standing"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes4"]]) {
            [passengerSafety setObject:[self.values objectForKey:@"Notes4"] forKey:@"notes"];
        }
        
        [dict setObject:passengerSafety forKey:@"passenger_safety"];
            
        NSArray *scoreseyeMovement= [self.scores objectForKey:@"Eye Movement and Mirror Use"];
        NSMutableDictionary * eyeMovement = [[NSMutableDictionary alloc] init];
        [eyeMovement setObject:scoreseyeMovement[0] forKey:@"eyes_ahead"];
        [eyeMovement setObject:scoreseyeMovement[1] forKey:@"follow_up_in_mirror"];
        [eyeMovement setObject:scoreseyeMovement[2] forKey:@"checks_mirror"];
        [eyeMovement setObject:scoreseyeMovement[3] forKey:@"scans_does_not_stare"];
        [eyeMovement setObject:scoreseyeMovement[4] forKey:@"avoid_billboards"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes5"]]) {
            [eyeMovement setObject:[self.values objectForKey:@"Notes5"] forKey:@"notes"];
        }
        
        [dict setObject:eyeMovement forKey:@"eye_movement_and_mirror"];
        
        NSArray *scoresrecognizesHazards= [self.scores objectForKey:@"Recognizes Hazards"];
        NSMutableDictionary * recognizesHazards = [[NSMutableDictionary alloc] init];
        [recognizesHazards setObject:scoresrecognizesHazards[0] forKey:@"uses_horn"];
        [recognizesHazards setObject:scoresrecognizesHazards[1] forKey:@"makes_adjustments"];
        [recognizesHazards setObject:scoresrecognizesHazards[2] forKey:@"path_of_least_resistance"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes6"]]) {
            [recognizesHazards setObject:[self.values objectForKey:@"Notes6"] forKey:@"notes"];
        }
        
        [dict setObject:recognizesHazards forKey:@"recognizes_hazards"];
        
        NSArray *scoreslightsAndSignals= [self.scores objectForKey:@"Lights and Signals"];
        NSMutableDictionary * lightsAndSignals = [[NSMutableDictionary alloc] init];
        [lightsAndSignals setObject:scoreslightsAndSignals[0] forKey:@"proper_use_of_lights"];
        [lightsAndSignals setObject:scoreslightsAndSignals[1] forKey:@"adjust_speed"];
        [lightsAndSignals setObject:scoreslightsAndSignals[2] forKey:@"signals_well_in_advance"];
        [lightsAndSignals setObject:scoreslightsAndSignals[3] forKey:@"cancels_signal"];
        [lightsAndSignals setObject:scoreslightsAndSignals[4] forKey:@"use_of_4_ways"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes7"]]) {
            [lightsAndSignals setObject:[self.values objectForKey:@"Notes7"] forKey:@"notes"];
        }
        
        [dict setObject:lightsAndSignals forKey:@"lights_and_signals"];
        
        NSArray *scoresteering = [self.scores objectForKey:@"Steering"];
        NSMutableDictionary * steering = [[NSMutableDictionary alloc] init];
        [steering setObject:scoresteering[0] forKey:@"over_steers"];
        [steering setObject:scoresteering[1] forKey:@"floats"];
        [steering setObject:scoresteering[2] forKey:@"poisture_and_grip"];
        [steering setObject:scoresteering[3] forKey:@"centered_in_lane"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes8"]]) {
            [steering setObject:[self.values objectForKey:@"Notes8"] forKey:@"notes"];
        }
        
        [dict setObject:steering forKey:@"steering"];
        
        NSArray *scoresbacking = [self.scores objectForKey:@"Backing"];
        NSMutableDictionary * backing = [[NSMutableDictionary alloc] init];
        [backing setObject:scoresbacking[0] forKey:@"size_of_situation"];
        [backing setObject:scoresbacking[1] forKey:@"driver_side_back"];
        [backing setObject:scoresbacking[2] forKey:@"check_rear"];
        [backing setObject:scoresbacking[3] forKey:@"gets_attention"];
        [backing setObject:scoresbacking[4] forKey:@"backs_slowly"];
        [backing setObject:scoresbacking[5] forKey:@"rechecks_conditions"];
        [backing setObject:scoresbacking[6] forKey:@"uses_other_aids"];
        [backing setObject:scoresbacking[7] forKey:@"steers_correctly"];
        [backing setObject:scoresbacking[8] forKey:@"does_not_hit_dock"];
        [backing setObject:scoresbacking[9] forKey:@"use_spotter"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes9"]]) {
            [backing setObject:[self.values objectForKey:@"Notes9"] forKey:@"notes"];
        }
        
        [dict setObject:backing forKey:@"backing"];
        
        NSArray *scoresspeed= [self.scores objectForKey:@"Speed"];
        NSMutableDictionary * speed = [[NSMutableDictionary alloc] init];
        [speed setObject:scoresspeed[0] forKey:@"adjust_to_conditions"];
        [speed setObject:scoresspeed[1] forKey:@"speed"];
        [speed setObject:scoresspeed[2] forKey:@"proper_following_distance"];
        [speed setObject:scoresspeed[3] forKey:@"speed_on_curves"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes10"]]) {
            [speed setObject:[self.values objectForKey:@"Notes10"] forKey:@"notes"];
        }
        
        [dict setObject:speed forKey:@"speed"];
        
        NSArray *scoresintersections = [self.scores objectForKey:@"Intersections"];
        NSMutableDictionary * intersections = [[NSMutableDictionary alloc] init];
        [intersections setObject:scoresintersections[0] forKey:@"approach_decision_point"];
        [intersections setObject:scoresintersections[1] forKey:@"clear_intersection"];
        [intersections setObject:scoresintersections[2] forKey:@"check_mirrors"];
        [intersections setObject:scoresintersections[3] forKey:@"full_stop"];
        [intersections setObject:scoresintersections[4] forKey:@"times_light_or_starts"];
        [intersections setObject:scoresintersections[5] forKey:@"steering_axle_staright"];
        [intersections setObject:scoresintersections[6] forKey:@"yields_right_of_way"];
        [intersections setObject:scoresintersections[7] forKey:@"proper_speed_or_gear"];
        [intersections setObject:scoresintersections[8] forKey:@"leaves_space"];
        [intersections setObject:scoresintersections[9] forKey:@"stop_lines"];
        [intersections setObject:scoresintersections[10] forKey:@"railroad_crossings"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes11"]]) {
            [intersections setObject:[self.values objectForKey:@"Notes11"] forKey:@"notes"];
        }
        
        [dict setObject:intersections forKey:@"intersections"];
        
        NSArray *scoresturning = [self.scores objectForKey:@"Turning"];
        NSMutableDictionary * turning = [[NSMutableDictionary alloc] init];
        [turning setObject:scoresturning[0] forKey:@"signals_correctly"];
        [turning setObject:scoresturning[1] forKey:@"gets_in_proper_lane"];
        [turning setObject:scoresturning[2] forKey:@"downshifts_to_pulling_gear"];
        [turning setObject:scoresturning[3] forKey:@"handles_light_correctly"];
        [turning setObject:scoresturning[4] forKey:@"setup_and_execution"];
        [turning setObject:scoresturning[5] forKey:@"turn_speed"];
        [turning setObject:scoresturning[6] forKey:@"mirror_follow_up"];
        [turning setObject:scoresturning[7] forKey:@"turns_lane_to_lane"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes12"]]) {
            [turning setObject:[self.values objectForKey:@"Notes12"] forKey:@"notes"];
        }
        
        [dict setObject:turning forKey:@"turning"];
        
        
        NSArray *scoresparking = [self.scores objectForKey:@"Parking"];
        NSMutableDictionary * parking = [[NSMutableDictionary alloc] init];
        [parking setObject:scoresparking[0] forKey:@"does_not_hit_curb"];
        [parking setObject:scoresparking[1] forKey:@"curbs_wheels"];
        [parking setObject:scoresparking[2] forKey:@"chock_wheels"];
        [parking setObject:scoresparking[3] forKey:@"park_brake_applied"];
        [parking setObject:scoresparking[4] forKey:@"trans_in_neutral"];
        [parking setObject:scoresparking[5] forKey:@"engine_off"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes13"]]) {
            [parking setObject:[self.values objectForKey:@"Notes13"] forKey:@"notes"];
        }
        
        [dict setObject:parking forKey:@"parking"];
        
        NSArray *scoreshills = [self.scores objectForKey:@"Hills"];
        NSMutableDictionary * hills = [[NSMutableDictionary alloc] init];
        [hills setObject:scoreshills[0] forKey:@"proper_gear_up_down"];
        [hills setObject:scoreshills[1] forKey:@"avoids_rolling_back"];
        [hills setObject:scoreshills[2] forKey:@"test_brakes_prior"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes14"]]) {
            [hills setObject:[self.values objectForKey:@"Notes14"] forKey:@"notes"];
        }
        
        [dict setObject:hills forKey:@"hills"];
        
        NSArray *scorespassing = [self.scores objectForKey:@"Passing"];
        NSMutableDictionary * passing = [[NSMutableDictionary alloc] init];
        [passing setObject:scorespassing[0] forKey:@"sufficient_space_to_pass"];
        [passing setObject:scorespassing[1] forKey:@"signals_property"];
        [passing setObject:scorespassing[2] forKey:@"check_mirrors"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes15"]]) {
            [passing setObject:[self.values objectForKey:@"Notes15"] forKey:@"notes"];
        }
        
        [dict setObject:passing forKey:@"passing"];
        
        NSArray *scoresrailRoadCrossing = [self.scores objectForKey:@"Railroad Crossing"];
        NSMutableDictionary * railRoadCrossing = [[NSMutableDictionary alloc] init];
        [railRoadCrossing setObject:scoresrailRoadCrossing[0] forKey:@"signal_and_activate_4_ways"];
        [railRoadCrossing setObject:scoresrailRoadCrossing[1] forKey:@"stop_prior"];
        [railRoadCrossing setObject:scoresrailRoadCrossing[2] forKey:@"open_window_and_door"];
        [railRoadCrossing setObject:scoresrailRoadCrossing[3] forKey:@"look_listen_clear"];
        [railRoadCrossing setObject:scoresrailRoadCrossing[4] forKey:@"signal_and_merge_into_traffic"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes16"]]) {
            [railRoadCrossing setObject:[self.values objectForKey:@"Notes16"] forKey:@"notes"];
        }
        
        [dict setObject:railRoadCrossing forKey:@"rail_road_crossing"];
        
        NSArray *scoresgeneralSafety = [self.scores objectForKey:@"General safety and DOT adherence"];
        NSMutableDictionary * generalSafety = [[NSMutableDictionary alloc] init];
        [generalSafety setObject:scoresgeneralSafety[0] forKey:@"avoids_crowding_effect"];
        [generalSafety setObject:scoresgeneralSafety[1] forKey:@"stays_right_or_correct_lane"];
        [generalSafety setObject:scoresgeneralSafety[2] forKey:@"aware_hours_of_service"];
        [generalSafety setObject:scoresgeneralSafety[3] forKey:@"proper_use_off_mirrors"];
        [generalSafety setObject:scoresgeneralSafety[4] forKey:@"self_confident_not_complacement"];
        [generalSafety setObject:scoresgeneralSafety[5] forKey:@"check_instruments"];
        [generalSafety setObject:scoresgeneralSafety[6] forKey:@"uses_horn_properly"];
        [generalSafety setObject:scoresgeneralSafety[7] forKey:@"maintains_dot_log"];
        [generalSafety setObject:scoresgeneralSafety[8] forKey:@"drives_defensively"];
        [generalSafety setObject:scoresgeneralSafety[9] forKey:@"company_haz_mat_protocol"];
        [generalSafety setObject:scoresgeneralSafety[10] forKey:@"air_cans_or_line_moisture_free"];
        [generalSafety setObject:scoresgeneralSafety[11] forKey:@"avoid_distractions_while_driving"];
        [generalSafety setObject:scoresgeneralSafety[12] forKey:@"works_safely_to_avoid_injuries"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values objectForKey:@"Notes17"]]) {
            [generalSafety setObject:[self.values objectForKey:@"Notes17"] forKey:@"notes"];
        }
        
        [dict setObject:generalSafety forKey:@"general_safety_and_dot_adherence"];
        
        if ([HelperSharedManager isCheckNotNULL:[self.values valueForKey:@"companyRepresentative"]]) {            
            [dict setObject:[self.values valueForKey:@"companyRepresentative"] forKey:@"company_rep_name"];
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for(id key in dict) {
            NSDictionary *item = [dict objectForKey:key];
            
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
            
            if ([item isKindOfClass:[NSDictionary class]]) {
                for(id key1 in item) {
                    
                    NSString *val = [[item valueForKey:key1] stringValue];
                    
                    if ([val isEqual:@"-1"]) {
                        [newDict setObject:[NSNumber numberWithInt:0] forKey:key1];
                        
                    } else {
                        [newDict setObject:[NSNumber numberWithInt:[val intValue]] forKey:key1];
                    }
                    
                }
                
                [params setObject:newDict forKey:key];
                
            } else {
                [params setObject:item forKey:key];
            }
            
            
        }
        
        [dict removeAllObjects];
        
        dict = params;

        urlEndPoint = @"pas";
        
    }
    
    
    NSLog(@"posting dict = %@", dict);
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];

    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", jsonString);
    }
    
    
    NSString *url = [NSString stringWithFormat:@"students/%@/%@/", self.student.userId, urlEndPoint];
    NSString *token = [Settings getSetting:USER_ACCESS_TOKEN];
    
    NSMutableDictionary *signatureImages = [[NSMutableDictionary alloc] init];
    if (self.driverSignature != NULL) {
        [signatureImages setValue:UIImagePNGRepresentation(self.driverSignature) forKey:@"driver_signature"];
    }
    
    if (self.evaluatorSignature != NULL) {
        [signatureImages setValue:UIImagePNGRepresentation(self.evaluatorSignature) forKey:@"evaluator_signature"];
    }
    
    if (self.compRepSignature != NULL) {
        [signatureImages setValue:UIImagePNGRepresentation(self.compRepSignature) forKey:@"company_rep_signature"];
    }
    
    [[ServerManager sharedManager] putRequestWithMultipart:token withUrl:url withDict:dict withImages:signatureImages success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSLog(@"Response %@", responseObject);
            
            // save data as raw data - notes are not being saved - I think this should be post data size issue
            NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PATCH" URLString:[NSString stringWithFormat:@"%@%@", CSD_SERVER, url] parameters:nil error:nil];

            req.timeoutInterval = 30;
            [req setHTTPBody:jsonData];
            
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
            NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
            [req setValue:headerToken forHTTPHeaderField:@"Authorization"];

            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

            [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"%@", responseObject);
                } else {
                    NSLog(@"Error: %@, %@, %@", error, response, responseObject);
                }
            }] resume];
            
        });
    } failure:^(NSString *failureReason, NSInteger statusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        });
    }];
    
//    [[ServerManager sharedManager] patchRequest:token withUrl:url withDict:dict success:^(id responseObject) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//
//            NSLog(@"Response %@", responseObject);
//
//
//
//
//        });
//
//        } failure:^(NSString *failureReason, NSInteger statusCode) {
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//
//            });
//
//        }];
   
    
    
    

    
    
    if (![isAutoSave boolValue]) {
        // we should disable auto saving, the call takes long time to finish ...
        self.needsToSave = NO;
        [self.previewBtn setEnabled:YES];
    } else if (!self.autoSaveEnabled) {
        // 19.02.2020 we should reset the flag that needs to be saved
        self.needsToSave = NO;
        [self.previewBtn setEnabled:YES];
    }
            
    BOOL isNewHeader = NO;
    
    if (!self.header) {
        self.header = (TestDataHeader*)[[self aggregate] createNewObject];
        self.header.dateTime = [NSDate date];
        self.header.number = self.formNumber;
        NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
        self.header.rcoObjectParentId = parentMobileRecordId;
        isNewHeader = YES;
        if (self.pausedDate) {
            [self.header addPauseDateTime:self.dateTime];
        }
    }

    // 25.11.2019 we should use fieldsAll to have the studentt and instructor fields ...
    NSArray *headerCodingFields = self.fields;
    if (!self.showTrainingInfofields) {
        headerCodingFields = self.fieldsAll;
    }
    
    for (NSString *field in headerCodingFields) {
        // 29.11.2019 I've added extra fields that are not coding fields
        SEL sel = NSSelectorFromString(field);
        if ([self.header respondsToSelector:sel]) {
            id val = [self.values objectForKey:field];
            if (val) {
                if ([self.textFields containsObject:field]) {
                    NSString *txt = [TestDataHeader encodeText:val];
                    [self.header setValue:txt forKey:field];
                } else if ([self.switchFields containsObject:field]) {
                    [self.header setValue:[self getBooleanFromValue:val] forKey:field];
                } else {
                    [self.header setValue:val forKey:field];
                }
            }
        }
    }
    
    for (NSString *key in self.bottomSection) {
        SEL sel = NSSelectorFromString(key);
        id object = [self.values objectForKey:key];
        if ([self.header respondsToSelector:sel]) {
            [self.header setValue:object forKey:key];
        }
    }
    
    // instructor infos
    self.header.instructorLastName = self.instructor.surname;
    self.header.instructorFirstName = self.instructor.firstname;
    self.header.instructorEmployeeId = self.instructor.userId;
    
    // student infos
    self.header.studentLastName = self.student.surname;
    self.header.studentFirstName = self.student.firstname;
    self.header.employeeId = self.student.userId;

    self.header.driverLicenseExpirationDate = self.driverLicenseExpirationDate;
    self.header.dotExpirationDate = self.dotExpirationDate;
    
    NSString *endorsements = [Settings getSetting:CSD_TEST_INFO_ENDORSEMENTS];
    self.header.endorsements = endorsements;

    NSString *location = [Settings getSetting:CSD_TEST_INFO_LOCATION];
    if ([self.formNumber isEqualToString:TestVRT]) {
        if (!self.header.location.length) {
            self.header.location = location;
        }
    } else {
        self.header.location = location;
    }

    NSDate *dotExpirationDate = [Settings getSettingAsDate:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    self.header.dotExpirationDate = dotExpirationDate;

    NSString *correctiveLensRequired = [Settings getSetting:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    self.header.correctiveLensRequired = correctiveLensRequired;

    NSInteger possiblePoints = 0;
    NSInteger receivedPoints = 0;
        
    for (NSInteger index = 0; index < self.detailsNames.count; index++) {
        NSString *itemSectionName = [self.detailsNames objectAtIndex:index];
        NSArray *details = [self.detailsInfo objectForKey:itemSectionName];
        NSArray *scores = [self.scores objectForKey:itemSectionName];
        TrainingEquipment *equipmentUsed =  nil;
        NSString *equipmentUsedKey = itemSectionName;
        if ([self.formNumber isEqualToString:TestVRT]) {
            equipmentUsedKey = KeyEquipmentUsed;
        }
        
        equipmentUsed = [self.equipmentUsed objectForKey:equipmentUsedKey];
        
        NSString *noteKey = [NSString stringWithFormat:@"%@%d", @"Notes", (int)index];
        NSString *noteStr = [self.values objectForKey:noteKey];

        if (noteStr.length) {
            // we should update or insert
            NSLog(@"");
            [self addNote:noteStr forCategory:itemSectionName];
        }
        
        NSArray *specialInputFields = [NSArray arrayWithObjects:@"Location", @"Trailer", @"Odometer", nil];
        
        double sectionPointsPossible = 0;
        double sectionPointsReceived = 0;

        for (NSInteger i = 0; i < details.count; i++) {
            id detail = [details objectAtIndex:i];
            NSNumber *score = [scores objectAtIndex:i];
            //NSInteger val = ([score integerValue] + 1);
            NSInteger val = [score integerValue];

            if (val >= 0) {
                possiblePoints += 5;
                sectionPointsPossible += 5;
            } else {
                // is N/A then we should not increment anything ....
            }
            // index selected + 1

            if (val>0) {
                // if the score is -1 we shoul dnot increment it, is just for not available
                receivedPoints += val;
                sectionPointsReceived += val;
            }
            TestDataDetail *d = nil;
            if (!isNewHeader && [isAutoSave boolValue]) {
                d = [self addUpdateDetail:detail
                                 andScore:[NSString stringWithFormat:@"%d", (int)val]
                           seachForDetail:[NSNumber numberWithBool:YES]
                           forSectionName:nil
                         andSectionNumber:nil];
            } else {
                // we should search all the time ... d = [self addUpdateDetail:detail andScore:[NSString stringWithFormat:@"%d", (int)val] seachForDetail:[NSNumber numberWithBool:NO]];
                d = [self addUpdateDetail:detail
                                 andScore:[NSString stringWithFormat:@"%d", (int)val]
                           seachForDetail:[NSNumber numberWithBool:YES]
                           forSectionName:nil
                         andSectionNumber:nil];
            }
            
            if (equipmentUsed) {
                NSLog(@"");
            }
            
            d.equipmentUsedMobileRecordId = equipmentUsed.rcoMobileRecordId;
            d.leg = d.testSectionNumber;
            
            if ([specialInputFields containsObject:d.testItemName]) {
                NSInteger index = [self.detailsNames indexOfObject:d.testSectionName];
                if ((index != NSNotFound) &&  self.specialSectionValues.count) {
                    NSDictionary *dict = [self.specialSectionValues objectAtIndex:index];
                    NSInteger index2 = [specialInputFields indexOfObject:d.testItemName];
                    if (index2 == 0) {
                    // location
                        d.location = [dict objectForKey:KeyLocation];
                    } else if (index2 == 1) {
                        // trailer
                        d.trailerNumber = [dict objectForKey:KeyTrailerNumber];
                    } else {
                        // ODOMETEr
                        d.odometer = [dict objectForKey:KeyOdometer];
                    }
                }
            }
            
            NSString *teachingString = nil;
            if (val < 5) {
                if ([self.formNumber isEqualToString:TestVRT]) {
                    //03.02.2020 for VRT teaching strings are different
                    if (val == 0) {
                        teachingString = [self getTeachingStringForSection:d.testSectionName andItem:d.testItemNumber];
                    } else if (val == -1) {
                        NSLog(@"");
                    } else if (val == 1) {
                        NSLog(@"");
                    }
                } else {
                    teachingString = [self getTeachingStringForSection:d.testSectionName andItem:d.testItemNumber];
                }
            }
            d.testTeachingString = teachingString;
        }

        // 27.04.2020 we should disable saving the scores
        self.saveScores = NO;

        //30.01.2020 we should not use anymore "&& ![isAutoSave boolValue]" I've added saveScores member and that should be enough
        if (self.header.endDateTime /*&& ![isAutoSave boolValue]*/ && self.saveScores) {
            // 27.12.2019 we should save the scores also for each section 
            TrainingScoreAggregate *agg = (TrainingScoreAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingScore"];
            TrainingScore *ts = (TrainingScore*)[agg createNewObject];
            ts.dateTime = [NSDate date];
            NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];

            ts.masterMobileRecordId = parentMobileRecordId;
            ts.company = self.header.company;
            ts.studentLastName = self.header.studentLastName;
            ts.studentFirstName = self.header.studentFirstName;
            ts.driverLicenseState = self.header.driverLicenseState;
            ts.driverLicenseNumber = self.header.driverLicenseNumber;
            ts.employeeId = self.header.employeeId;
            ts.instructorLastName = self.header.instructorLastName;
            ts.instructorFirstName = self.header.instructorFirstName;
            ts.instructorEmployeeId = self.header.instructorEmployeeId;
            ts.pointsReceived = [NSString stringWithFormat:@"%d", (int)sectionPointsReceived];
            ts.pointsPossible = [NSString stringWithFormat:@"%d", (int)sectionPointsPossible];
            
            ts.rcoObjectParentId = self.header.rcoMobileRecordId;
            
            BOOL sendMobileRecordIdInTheName = NO;
            // 14.01.2020 Andrey wants in the name of the scores to have the mobileRecordId (he wanted record id but that Is not possible when working offline)
            if (sendMobileRecordIdInTheName) {
                ts.testName = [NSString stringWithFormat:@"%@_%@", self.header.name, self.header.rcoMobileRecordId];
            } else {
                ts.testName = self.header.name;
            }
            ts.sectionName = itemSectionName;
            
            ts.elapsedTime = self.header.elapsedTime;
            [agg createNewRecord:ts];
        }

    }
    
    if ([self.formNumber isEqualToString:TestVRT]) {
        self.header.pointsReceived = [NSString stringWithFormat:@"%d", (int)self.receivedPoints];
        self.header.pointsPossible = [NSString stringWithFormat:@"%d", (int)self.possiblePoints];
    } else {
        self.header.pointsReceived = [NSString stringWithFormat:@"%d", (int)receivedPoints];
        self.header.pointsPossible = [NSString stringWithFormat:@"%d", (int)possiblePoints];
    }
    
    self.header.elapsedTime = [self calculateTimeElapsedForCurrentTest];
    
    [[self aggregate] save];
    
    // 27.04.2020 we should disable saving the scores
    self.saveScores = NO;
    
    //30.01.2020 we should not use anymore "&& ![isAutoSave boolValue]" I've added saveScores member and that should be enough
    if (self.header.endDateTime /*&& ![isAutoSave boolValue]*/ && self.saveScores) {
        // 27.12.2019 we should save the scores also
        TrainingScoreAggregate *agg = (TrainingScoreAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingScore"];
        TrainingScore *ts = (TrainingScore*)[agg createNewObject];
        ts.dateTime = [NSDate date];
        NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];

        ts.masterMobileRecordId = parentMobileRecordId;
        ts.company = self.header.company;
        ts.studentLastName = self.header.studentLastName;
        ts.studentFirstName = self.header.studentFirstName;
        ts.driverLicenseState = self.header.driverLicenseState;
        ts.driverLicenseNumber = self.header.driverLicenseNumber;
        ts.employeeId = self.header.employeeId;
        ts.instructorLastName = self.header.instructorLastName;
        ts.instructorFirstName = self.header.instructorFirstName;
        ts.instructorEmployeeId = self.header.instructorEmployeeId;
        ts.pointsReceived = self.header.pointsReceived;
        ts.pointsPossible = self.header.pointsPossible;
        
        ts.testName = self.header.name;
        ts.rcoObjectParentId = self.header.rcoMobileRecordId;
        
        ts.elapsedTime = self.header.elapsedTime;
        [agg createNewRecord:ts];
        // 29.01.2020 we should not save the scores again ....
        self.saveScores = NO;
    }
    
    self.header.elapsedTime = [self.header calculateElaspsedTime];
    
    if (![isAutoSave boolValue] || self.saveOnServer) {
        // we should save it on the server just in the case when we are NOT auto save
        [[self aggregate] createNewRecord:self.header];
        if (isNewHeader) {
            //27.11.2019 we should load the details also to load the preview correctly
            [self loadObjectDetailsAndReload:YES];
        }
    } else {
        // is auto save. we should reload the list again
        
        BOOL markRecordToUpload = YES;
        // 09.12.2019 we should mark this "needs to upload"
        if (markRecordToUpload) {
            [self.header setNeedsUploading:YES];
            [[self aggregate] save];
        }
        
        if (isNewHeader) {
            // is the first autosave, we should reload the details... the ones that we just generated ...
            [self loadObject];
        }
    }
    
    if (self.saveSignature) {
        // 17.10.2019 should we save the signatures if is an auto save ???
        [self addSignatureForKey:TestSignatureDriver];
        [self addSignatureForKey:TestSignatureEvaluator];
        [self addSignatureForKey:TestSignatureCompanyRep];
        self.saveSignature = NO;
    }
    // 22.01.2020 we should reset this flag ....
    self.saveOnServer = NO;
    // 16.03.2020 we should reset this flag because after saving the record is not new anymore ....
    if (self.isNewCreated) {
        NSLog(@"");
        self.isNewCreated = NO;
    }
    
    
    
}

-(void)createTrainingScoreForTestDataHeader:(TestDataHeader*)header andSection:(NSString*)section {

}

-(void)createTrainingScoreForTestDataHeader:(TestDataHeader*)header {
    TrainingScoreAggregate *agg = (TrainingScoreAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingScore"];
    TrainingScore *ts = (TrainingScore*)[agg createNewObject];
    ts.dateTime = [NSDate date];
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];

    ts.masterMobileRecordId = parentMobileRecordId;
    ts.company = header.company;
    ts.studentLastName = header.studentLastName;
    ts.studentFirstName = header.studentFirstName;
    ts.driverLicenseState = header.driverLicenseState;
    ts.driverLicenseNumber = header.driverLicenseNumber;
    ts.employeeId = header.employeeId;
    ts.instructorLastName = header.instructorLastName;
    ts.instructorFirstName = header.instructorFirstName;
    ts.instructorEmployeeId = header.instructorEmployeeId;
    ts.pointsReceived = header.pointsReceived;
    ts.pointsPossible = header.pointsPossible;
    
    ts.testName = header.name;
    ts.rcoObjectParentId = header.rcoMobileRecordId;
    
    ts.elapsedTime = header.elapsedTime;
    [agg createNewRecord:ts];
}


-(IBAction)deleteButtonPressed:(id)sender {
}

-(IBAction)noteButtonPressed:(id)sender {
}


-(IBAction)cameraButtonPressed:(id)sender {
    
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
            NSString *fieldName = nil;
            if (index != NSNotFound) {
                fieldName = [self.fieldsNames objectAtIndex:index];
            } else {
                continue;
            }
            NSString *message = [NSString stringWithFormat:@"%@ is not set!", fieldName];
            return message;
        }
    }
    return nil;
}

-(void)loadDefaultValuesForSwitches {
    if (!self.header) {
        NSArray *switchesToIgnoreDefaultValues = [NSArray arrayWithObjects:KeyQualifiedOrNot, nil];
        for (NSString *key in self.switchFields) {
            // 29.11.2019 we should set those to no
            //05.02.2020 we should not set the default vaue for all!
            if ([switchesToIgnoreDefaultValues containsObject:key]) {
                // we should skip this default value
                [self.values setObject:@"" forKey:key];
            } else {
                [self.values setObject:@"no" forKey:key];
            }
        }
    }
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
        /*
        [tableView beginUpdates];
        
        id itemToDelete = nil;
        
        itemToDelete = [self.notes objectAtIndex:indexPath.row];
        
        [self.notes removeObjectAtIndex:indexPath.row];
        
        [self deleteItem:itemToDelete];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
        [tableView reloadData];
        NSLog(@"");
        */
    }
}

-(void)deleteItem:(id)itemToDelete {
    
    if (!itemToDelete) {
        return;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.fields.count) {
        return 1;
    } else {
        if (self.isEnded || self.showSignatireFieldsAllTheTime) {
            NSInteger index = section - self.fields.count;
            if (index < self.detailsNames.count) {
                NSInteger index = section - self.fields.count;
                NSString *sectionName = [self.detailsNames objectAtIndex:index];
                NSArray *details = [self.detailsInfo objectForKey:sectionName];
                if ([self.formNumber isEqualToString:TestVRT]) {
                    // + scores + notes
                    return details.count + 1;
                    // score is included now in details
                    return details.count + 1 + 1;
                } else {
                    // + notes
                    return details.count + 1;
                }
            } else {
                return 1;
            }
        } else {
            NSInteger index = section - self.fields.count;
            NSString *sectionName = [self.detailsNames objectAtIndex:index];
            NSArray *details = [self.detailsInfo objectForKey:sectionName];
            if ([self.formNumber isEqualToString:TestVRT]) {
                // + score + notes
                return details.count + 1;
                // score is included now in details
                return details.count + 1 + 1;
            } else {
                // + notes
                return details.count + 1;
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.detailsNames.count) {
        return 0;
    }
    
    if (self.isEnded || self.showSignatireFieldsAllTheTime) {
        return self.fields.count + self.detailsNames.count + self.bottomSection.count;
    } else {
        return self.fields.count + self.detailsNames.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < self.fields.count) {
        NSString *sectionName = [self.fieldsNames objectAtIndex:section];
        NSString *sectionkey = [self.fields objectAtIndex:section];
        if ([self.switchFields containsObject:sectionkey]) {
            // for switch we don't need section name
            return nil;
        }
        return sectionName;
    } else {
        NSInteger index = section - self.fields.count;
        if (index < self.detailsNames.count) {
            NSString *sectionName = [self.detailsNames objectAtIndex:index];
            return [NSString stringWithFormat:@"%d. %@", (int)(index + 1), sectionName];
        } else {
            index -= self.detailsNames.count;
            NSString *sectionName = [self.bottomSectionNames objectAtIndex:index];
            return [NSString stringWithFormat:@"%@", sectionName];
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    double width = tableView.frame.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 35)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-35-10, 35)];
    lbl.font = [UIFont boldSystemFontOfSize:17];
    
    if (section < self.fields.count) {
        NSString *sectionName = [self.fieldsNames objectAtIndex:section];
        NSString *sectionkey = [self.fields objectAtIndex:section];
        if ([self.switchFields containsObject:sectionkey]) {
            // for switch we don't need section name
            headerView = nil;
        }
        lbl.text = sectionName;
    } else {
        NSInteger index = section - self.fields.count;
        if (index < self.detailsNames.count) {
            NSString *sectionName = [self.detailsNames objectAtIndex:index];
            //return [NSString stringWithFormat:@"%d. %@", (int)(index + 1), sectionName];
            lbl.text = [NSString stringWithFormat:@"%d. %@", (int)(index + 1), sectionName];;

            UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoDark];
            info.tag = index;
            [info addTarget:self
                     action:@selector(infoButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
            
            info.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            CGRect frame = CGRectMake(width-35, 0, 35, 35);
            [info setFrame:frame];
            [headerView addSubview:info];
            
        } else {
            index -= self.detailsNames.count;
            NSString *sectionName = [self.bottomSectionNames objectAtIndex:index];
            //return [NSString stringWithFormat:@"%@", sectionName];
            lbl.text = [NSString stringWithFormat:@"%@", sectionName];
        }
    }

    UIColor *lightColor = nil;
    if (@available(iOS 13,*)) {
        lightColor = [UIColor tertiarySystemFillColor];
    } else {
        lightColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
    }

    // 03.12.2019 light blue
    lightColor = [TrainingTestInfo lightColor];
    [headerView setBackgroundColor:lightColor];
    [headerView addSubview:lbl];

    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{

    if (indexPath.section < self.fields.count) {
        NSString *key = [self.fields objectAtIndex:indexPath.section];
        if ([self.textFields containsObject:key]) {
            return 100;
        }
    }
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0;
    
    if (section == (self.fields.count + self.detailsNames.count + self.bottomSection.count - 1)) {
        // this is for the last section where we are showing the company rep name
        return 0;
    } else if (section >= self.fields.count) {
        return 30;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section < self.fields.count) {
        NSString *sectionkey = [self.fields objectAtIndex:section];
        if ([self.switchFields containsObject:sectionkey]) {
            // for switch we don't need section name
            return 0;
        }
    }
    return 35;
}

- (UITableViewCell *)configureSignaturesForTableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section - self.fields.count - self.self.detailsNames.count;

    NSString *key = [self.bottomSection objectAtIndex:section];
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"SignatureCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SignatureCell"];
    }
    
    UIImage *img = nil;
    
    if ([key isEqualToString:TestSignatureDriver]) {
        img = self.driverSignature;
    } else if ([key isEqualToString:TestSignatureEvaluator]) {
        img = self.evaluatorSignature;
    } else if ([key isEqualToString:TestSignatureCompanyRep]) {
        img = self.compRepSignature;
    }
    
    cell.imageView.image = img;
    cell.textLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(BOOL)configureDetailAsSwitchForSectionNumber:(NSInteger)sectionNumber {
    if ([self.formNumber isEqualToString:TestSWP] && (sectionNumber == 0)) {
        return YES;
    }
    return NO;
}

- (UITableViewCell *)configureDetailsForTableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section - self.fields.count;
    
    if ((section >= self.detailsNames.count) && (self.isEnded || self.showSignatireFieldsAllTheTime) ) {
        
        NSArray *signatures = [NSArray arrayWithObjects:TestSignatureDriver, TestSignatureEvaluator, TestSignatureCompanyRep, nil];
        NSInteger index = indexPath.section - self.fields.count - self.detailsNames.count;
        
        NSString *key = [self.bottomSection objectAtIndex:index];
        if ([signatures containsObject:key]) {
            NSLog(@"");
            return [self configureSignaturesForTableView:theTableView cellForRowAtIndexPath:indexPath];
        } else {
            if ([self.pickerFields containsObject:key]) {
                UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"PickerCell"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PickerCell"];
                }
                
                NSString *detailStr = nil;
                NSString *value = [self.values objectForKey:key];
                cell.textLabel.text = value;
                cell.detailTextLabel.text = detailStr;
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                return cell;
            } else if ([self.datePickerFieldsNames containsObject:key]) {
                UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"dateCell"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
                }
            
                NSDate *date = [self.values objectForKey:key];
            
                if (date) {
                    cell.textLabel.text = [[self aggregate] rcoDateToString:date];
                } else {
                    cell.textLabel.text = nil;
                }
            
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage imageNamed:@"CALENDAR"];

                return cell;
            } else {
                NSString *value = [self.values objectForKey:key];
            
                return [self configureInputCellForTableView:theTableView
                                      cellForRowAtIndexPath:indexPath
                                                   forValue:value
                                                        key:key
                                                   andTitle:nil
                                                  isRequire:NO
                                                placeholder:nil];
            }
        }
        
    }

    BOOL isScoreLine = NO;

    if ([self.formNumber isEqualToString:TestVRT]) {
        NSString *sectionName = [self.detailsNames objectAtIndex:section];
        NSArray *items = [self.detailsInfo objectForKey:sectionName];
        if (indexPath.row == (items.count - 1)) {
            isScoreLine = YES;
        }
    }
    
    NSString *sectionName = [self.detailsNames objectAtIndex:section];
    NSArray *items = [self.detailsInfo objectForKey:sectionName];
    
    if (indexPath.row < items.count) {
        
        NSString *itemNumber = nil;
        NSString *itemName = nil;
        NSString *sectionNumber = nil;
        NSString *trailer = nil;
        NSString *recordId = nil;

        id detail = [items objectAtIndex:indexPath.row];

        if ([detail isKindOfClass:[TestForm class]]) {
            TestForm *tf = (TestForm*)detail;
            itemName = tf.itemName;
            itemNumber = tf.itemNumber;
            sectionNumber = tf.sectionNumber;
            trailer = @"Not Set";
            if (self.isDebugging) {
                recordId = tf.rcoMobileRecordId;
            }
        } else {
            TestDataDetail *tdd = (TestDataDetail*)detail;
            itemName = tdd.testItemName;
            itemNumber = tdd.testItemNumber;
            sectionNumber = tdd.testSectionNumber;
            trailer = tdd.trailerNumber;
            if (self.isDebugging) {
                recordId = tdd.rcoMobileRecordId;
            }
        }
        
        NSInteger segTag = section *100 + indexPath.row;
        NSInteger sectionIndex = [self.detailsNames indexOfObject:sectionName];

        NSArray *specialInputFields = [NSArray arrayWithObjects:@"Location", @"Trailer", @"Odometer", nil];
        
        //BOOL isCritical = [self isTestItemCritical:itemNumber forSectionNumber:sectionNumber];
        
        NSString *criticalKey = [NSString stringWithFormat:@"%@%@", sectionNumber, itemNumber];
        BOOL isCritical = [[self.criticalItems objectForKey:criticalKey] boolValue];
        
        BOOL isSimpleCell = YES;
        NSString *cellIdentifier = @"detailCell";
        
        if ([self.formNumber isEqualToString:TestProd] && [specialInputFields containsObject:itemName] && [itemName isEqualToString:@"Trailer"]) {
            isSimpleCell = NO;
            cellIdentifier = @"detailCell1";
        }
        
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            if (isSimpleCell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
        }
        
        [cell.textLabel setNumberOfLines:2];
        [cell.textLabel setFont:[UIFont systemFontOfSize:17]];

        
        if ([self.formNumber isEqualToString:TestProd] && [specialInputFields containsObject:itemName]) {
            CGRect frame = CGRectMake(0, 0, 210, 35);
            UITextField *input = [[UITextField alloc] initWithFrame:frame];
            input.delegate = self;
            if (DEVICE_IS_IPHONE) {
                input.inputAccessoryView = self.keyboardToolbar;
            }
            [input addTarget:self action:@selector(textFieldChangedForSection:) forControlEvents:UIControlEventEditingChanged];
            NSInteger delta = 0;
            NSString *key = nil;
            if ([itemName isEqualToString:@"Location"]) {
                delta = 100;
                key = KeyLocation;
                input.keyboardType = UIKeyboardTypeDefault;
            } else if ([itemName isEqualToString:@"Trailer"]) {
                delta = 200;
                key = KeyTrailerNumber;
                input.keyboardType = UIKeyboardTypeDefault;
            } else {
                delta = 300;
                key = KeyOdometer;
                input.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }
            input.tag = sectionIndex + delta;
            NSMutableDictionary *valDict = [self.specialSectionValues objectAtIndex:sectionIndex];
            NSString *val = [valDict objectForKey:key];
            input.text = val;

            input.borderStyle = UITextBorderStyleLine;
            if (isSimpleCell) {
                cell.accessoryView = input;
            } else {
                TrainingEquipment *te = [self.equipmentUsed objectForKey:sectionName];
                NSString *trailerInfo = [te trailerNumber];
                // 12.12.2019 we should save it in the trailer coding field also
                if (trailerInfo) {
                    [valDict setObject:trailerInfo forKey:KeyTrailerNumber];
                } else {
                    [valDict removeObjectForKey:KeyTrailerNumber];
                }
                
                if (te) {
                    cell.detailTextLabel.text = trailerInfo;
                } else {
                    cell.detailTextLabel.text = @"Not Set";
                }
            }
            cell.textLabel.text = itemName;
            
        } else if ([self configureDetailAsSwitchForSectionNumber:sectionIndex]) {
            // 12.11.2019 this is a custom section
            UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Yes", @"No", nil]];
            seg.tag = segTag;
            NSNumber *val = [self getScoreForRow:indexPath.row inSection:section];
                    
            if ([val integerValue] < 0){
                // NA
                //[seg setSelectedSegmentIndex:2];
            } else {
                if ([val integerValue] > 0) {
                    if ([val integerValue] == ValueYes) {
                        [seg setSelectedSegmentIndex:0];
                    } else if ([val integerValue] == ValueNo) {
                        [seg setSelectedSegmentIndex:1];
                    }
                } else {
                    [seg setSelectedSegmentIndex:UISegmentedControlNoSegment];
                }
            }
        
            [seg addTarget:self action:@selector(valueChangedForCustomSection:)forControlEvents:UIControlEventValueChanged];
        
            [seg setWidth:35 forSegmentAtIndex:0];
            [seg setWidth:35 forSegmentAtIndex:1];
            if ([self testEnded] || ![self testStarted] || self.pausedDate || [self.header isPaused]) {
                [seg setEnabled:NO];
            }
        
            cell.accessoryView = seg;
            cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", itemNumber, itemName];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        } else {
            UISegmentedControl *seg = nil;
            CSDScoreButton *btn = nil;

            if ([self.formNumber isEqualToString:TestVRT]) {
                if (isScoreLine) {
                    if (DEVICE_IS_IPAD) {
                        seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"N/A", nil]];
                    } else {
                        btn = [CSDScoreButton buttonWithType:UIButtonTypeCustom];
                        [btn setFrame:CGRectMake(0, 0, 60, 40)];
                        btn.items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"N/A", nil];
                    }
                } else {
                    if (DEVICE_IS_IPAD) {
                        seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Ok", @"Imp", @"N/A", nil]];
                    } else {
                        btn = [CSDScoreButton buttonWithType:UIButtonTypeCustom];
                        [btn setFrame:CGRectMake(0, 0, 60, 40)];
                        btn.items = [NSArray arrayWithObjects:@"Ok", @"Imp", @"N/A", nil];
                    }
                }
                seg.tag = segTag;
                btn.tag = segTag;
                
            } else if ([self.formNumber isEqualToString:TestProd]) {
                // 18.12.2019 we should not show NA for the production test
                BOOL showNA = NO;
                
                //03.02.2020 Mike wats to show N/A to production
                showNA = YES;
                
                if (showNA) {
                    if (DEVICE_IS_IPAD) {
                        seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"N/A", nil]];
                    } else {
                        btn = [CSDScoreButton buttonWithType:UIButtonTypeCustom];
                        [btn setFrame:CGRectMake(0, 0, 60, 40)];
                        btn.items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"N/A", nil];
                    }
                } else {
                    if (DEVICE_IS_IPAD) {
                        seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil]];
                    } else {
                        btn = [CSDScoreButton buttonWithType:UIButtonTypeCustom];
                        [btn setFrame:CGRectMake(0, 0, 60, 40)];
                        btn.items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
                    }
                }
            } else {
                if (DEVICE_IS_IPAD) {
                    seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"N/A", nil]];
                } else {
                    btn = [CSDScoreButton buttonWithType:UIButtonTypeCustom];
                    [btn setFrame:CGRectMake(0, 0, 60, 40)];
                    btn.items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"N/A", nil];
                }
            }
            seg.tag = segTag;
            btn.tag = segTag;
            NSNumber *val = [self getScoreForRow:indexPath.row inSection:section];
            NSInteger index = 5;
        
            NSInteger numberOfSegments = seg.numberOfSegments;
            if (DEVICE_IS_IPHONE) {
                numberOfSegments = [btn numberOfSegments];
            }
            
            if ([val integerValue] < 0){
                // NA
                if ([self.formNumber isEqualToString:TestVRT]) {
                    //21.01.2020 [seg setSelectedSegmentIndex:UISegmentedControlNoSegment];
                    if (numberOfSegments == 3) {
                        //@"Ok", @"Imp", @"N/A"
                        [seg setSelectedSegmentIndex:2];
                        [btn setSelectedSegmentIndex:2];
                    } else {
                        //@"1", @"2", @"3", @"4", @"N/A"
                        [seg setSelectedSegmentIndex:4];
                        [btn setSelectedSegmentIndex:4];
                    }
                } else {
                    [seg setSelectedSegmentIndex:5];
                    [btn setSelectedSegmentIndex:5];
                }
            } else {
                if ([self.formNumber isEqualToString:TestVRT]) {
                    if (numberOfSegments == 3) {
                        if ([val integerValue] == 1) {
                            // is "OK"
                            [seg setSelectedSegmentIndex:0];
                            [btn setSelectedSegmentIndex:0];
                        } else {
                            // is "Improper"
                            [seg setSelectedSegmentIndex:1];
                            [btn setSelectedSegmentIndex:1];
                        }
                    } else {
                        // this is Score detail is the same as the other tests
                        if ([val integerValue] > 0) {
                            index = [val integerValue];
                            index -= 1;
                            [seg setSelectedSegmentIndex:index];
                            [btn setSelectedSegmentIndex:index];
                        } else {
                            [seg setSelectedSegmentIndex:UISegmentedControlNoSegment];
                            [btn setSelectedSegmentIndex:UISegmentedControlNoSegment];
                        }
                    }
                } else {
                    if ([val integerValue] > 0) {
                        index = [val integerValue];
                        index -= 1;
                        [seg setSelectedSegmentIndex:index];
                        [btn setSelectedSegmentIndex:index];
                    } else {
                        [seg setSelectedSegmentIndex:UISegmentedControlNoSegment];
                        [btn setSelectedSegmentIndex:UISegmentedControlNoSegment];
                    }
                }
            }
        
            if ([self.formNumber isEqualToString:TestVRT]) {
                [seg setWidth:35 forSegmentAtIndex:0];
                [seg setWidth:35 forSegmentAtIndex:1];
                [seg setWidth:35 forSegmentAtIndex:2];
                [seg addTarget:self action:@selector(valueChangedVRT:)forControlEvents:UIControlEventValueChanged];
            } else {
                [seg setWidth:35 forSegmentAtIndex:0];
                [seg setWidth:35 forSegmentAtIndex:1];
                [seg setWidth:35 forSegmentAtIndex:2];
                [seg setWidth:35 forSegmentAtIndex:3];
                [seg setWidth:35 forSegmentAtIndex:4];
                [seg addTarget:self action:@selector(valueChanged:)forControlEvents:UIControlEventValueChanged];
            }
            if ([self testEnded] || ![self testStarted] || self.pausedDate || [self.header isPaused]) {
                [seg setEnabled:NO];
            }
        
            if (DEVICE_IS_IPAD) {
                cell.accessoryView = seg;
            } else {
                [btn addTarget:self
                        action:@selector(scoreButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
                
                cell.accessoryView = btn;
            }
            if (recordId.length) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@. %@(%@)", itemNumber, itemName, recordId];
            } else {
                if ([[itemName lowercaseString] isEqualToString:@"score"]) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@", itemName];
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", itemNumber, itemName];
                }
            }
                        
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        if (isCritical) {
            cell.textLabel.textColor = [UIColor redColor];
        } else {
            if (@available(iOS 13,*)) {
            cell.textLabel.textColor = [UIColor labelColor];
        } else {
            cell.textLabel.textColor = [UIColor darkTextColor];
        }
        }
        
        if (isSimpleCell) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    } else {
        NSInteger segTag = section *100 + indexPath.row;
        if (isScoreLine) {
            // 20.01.2020 we should add a score cell before notes cell
            NSString *cellIdentifier = @"scoreCell";
            UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }

            cell.textLabel.text = @"Score";
            UISegmentedControl *seg = nil;
            CSDScoreButton *btn = nil;
            if (DEVICE_IS_IPAD) {
                seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"N/A", nil]];
            } else {
                btn = [CSDScoreButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(0, 0, 60, 40)];
                btn.items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"N/A", nil];
            }
            seg.tag = segTag;
            btn.tag = segTag;
            [seg addTarget:self action:@selector(valueChangedVRT:)forControlEvents:UIControlEventValueChanged];

            cell.accessoryView = seg;

            NSNumber *score = [self getVRTScoreForSection:sectionName];
            if ([score integerValue] < 0) {
                [seg setSelectedSegmentIndex:4];
            } else if ([score integerValue] == 4){
                [seg setSelectedSegmentIndex:3];
            } else {
                [seg setSelectedSegmentIndex:[score integerValue]];
            }

            return cell;
        } else {
            NSString *noteKey = [NSString stringWithFormat:@"%@%d", @"Notes", (int)section];
        
            NSString *val = [self.values objectForKey:noteKey];
        
            return [self configureInputCellForTableView:theTableView
                                  cellForRowAtIndexPath:indexPath
                                               forValue:val
                                                    key:noteKey
                                               andTitle:nil
                                              isRequire:NO
                                            placeholder:@"Notes"];
        }
    }
}

-(void)scoreButtonPressed:(CSDScoreButton*)btn {
    
    NSString *startTime = [self.values objectForKey:@"startDateTime"];
    if (!startTime) {
        [self showSimpleMessage:@"Test not started.\nPlease tap on the start button!"];
        return;
    }
    
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Score", nil)
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];

    for (NSString *option in btn.items) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:option
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
            NSInteger index = [btn.items indexOfObject:action.title];
            if (index != NSNotFound) {
                NSLog(@"");
                [btn setSelectedSegmentIndex:index];
                [self valueChangedButton:btn];
            }
                                                           }];
        [al addAction:action];
    }
        
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                        // we should select back
    }];
    [al addAction:cancelAction];
    [self presentViewController:al animated:YES completion:nil];

}

- (UITableViewCell *)configureTextViewInputCellForTableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forValue:(NSString*)value key:(NSString*)key andTitle:(NSString*)title isRequire:(BOOL)requiredField placeholder:(NSString*)placeholder {
    // we have textView cell

    TextViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TextViewCell"
                                                 owner:self
                                               options:nil];
        cell = (TextViewCell *)[nib objectAtIndex:0];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textView.delegate = self;
    cell.textView.layer.borderColor = [UIColor blackColor].CGColor;
    cell.textView.layer.borderWidth = 1;
    if (DEVICE_IS_IPHONE) {
        cell.textView.inputAccessoryView = self.keyboardToolbar;
    }
    cell.textView.text = [self.values objectForKey:key];
    
    NSInteger keyIndex = [self.textFields indexOfObject:key];
    if (keyIndex != NSNotFound) {
        cell.textView.tag = keyIndex;
    }
    
    UITextInputAssistantItem* item = [cell.textView inputAssistantItem];
    item.leadingBarButtonGroups = @[];
    item.trailingBarButtonGroups = @[];
    cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section >= self.fields.count) {
        return [self configureDetailsForTableView:theTableView cellForRowAtIndexPath:indexPath];
    }
    
    NSString *key = nil;
    NSString *value = nil;
    
    key = [self.fields objectAtIndex:indexPath.section];
    value = [self.values objectForKey:[NSString stringWithFormat:@"%@", key]];
    
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
    if ([self.textFields containsObject:key]) {
        if ([self.textFields containsObject:key]);
        return [self configureTextViewInputCellForTableView:theTableView
                                      cellForRowAtIndexPath:indexPath
                                                   forValue:nil
                                                        key:key
                                                   andTitle:nil
                                                  isRequire:NO
                                                placeholder:nil];
    } else if ([self.switchFields containsObject:key]) {
        
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"switchCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCell"];
        }

        NSInteger keyIndex = [self.switchFields indexOfObject:key];
        NSString *label = [self.fieldsNames objectAtIndex:indexPath.section];

        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"No", @"Yes", nil]];
        seg.tag = keyIndex;
        //08.11.2019 seg.selectedSegmentIndex = [value integerValue];
        
        if ([key isEqualToString:KeyQualifiedOrNot]) {
            if (!value || ([value isKindOfClass:[NSString class]] && !value.length)) {
                seg.selectedSegmentIndex = UISegmentedControlNoSegment;
            } else {
                seg.selectedSegmentIndex = [value boolValue];
            }
        } else {
            seg.selectedSegmentIndex = [value boolValue];
        }
        
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
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"dateCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
        }
        
        NSDate *date = nil;
        
        if ([key isEqualToString:@"dateTime"]) {
            date = self.dateTime;
        } else if ([key isEqualToString:@"driverLicenseExpirationDate"]) {
            date = self.driverLicenseExpirationDate;
        } else if ([key isEqualToString:@"dotExpirationDate"]) {
            date = self.dotExpirationDate;
        }
        if (date) {
            cell.textLabel.text = [[self aggregate] rcoDateToString:date];
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
        
        NSString *detailStr = nil;
        if ([key isEqualToString:KeyEquipmentUsed]) {
            // 19.12.2019 this is just for VRT test
            TrainingEquipment *te = [self.values objectForKey:key];
            value = [te trailerNumber];
        } else if ([key isEqualToString:Key_State]) {
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
        value = [[self aggregate] rcoDateAndTimeToString:d];
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
    if (DEVICE_IS_IPHONE) {
        inputCell.inputTextField.inputAccessoryView = self.keyboardToolbar;
    }
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
    if (self.isEnded) {
        if (indexPath.section >= (self.fields.count + self.detailsNames.count)) {
            // for signatures we should enable selecting of a row
            return indexPath;
        }
    }
    
    if (indexPath.section >= self.fields.count) {
        // for the questions we should not enable selectiong of a row
        // 23.07.2019 enable selection
        return indexPath;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger index = indexPath.section - (self.fields.count + self.detailsNames.count);

    if ((self.isEnded || self.showSignatireFieldsAllTheTime) && (index >= 0)) {
    // we should check the signatures
        if (![self testStarted]) {
            [self showSimpleMessage:@"Please start the test first!"];
            return ;
        }

        if (!self.header) {
            [self showSimpleMessage:@"Please save the test first!"];
            return ;
        }

        NSString *key = [self.bottomSection objectAtIndex:index];
        
        NSArray *signatures = [NSArray arrayWithObjects:TestSignatureDriver, TestSignatureEvaluator, TestSignatureCompanyRep, nil];
        if ([key isEqualToString:KeyTestState]) {
            [self showStatePickerFromView:cell forKey:key];
        } else if ([signatures containsObject:key]) {
            [self showSignatureForOption:key];
        } else {
            NSLog(@"");
            if ([self.datePickerFieldsNames containsObject:key]) {
                [self showDatePickerFromView:cell andKey:key];
            }
        }
        return;
    } else if (indexPath.section >= self.fields.count) {
        // for the questions we should not enable selectiong of a row
        if (![self testStarted]) {
            [self showSimpleMessage:@"Please start the test first!"];
        }
        if ([self.formNumber isEqualToString:TestProd]) {
            if (indexPath.row == 1) {
                // is trailer, we should show here a equipment used picker
                self.self.currentIndexPath = indexPath;
                [self showEquipmentUsedPickerFromView:cell];
            }
        }
        return ;
    }
    
    if ([self testEnded]) {
        [self showSimpleMessage:@"Test ended!"];
        return;
    }
    
    NSString *key = [self.fields objectAtIndex:indexPath.section];
    if ([key isEqualToString:KeyEquipmentUsed]) {
        [self showEquipmentUsedPickerFromView:cell];
    } else if ([key isEqualToString:Key_Endorsements]) {
        [self showEndorsementsPickerFromView:cell];
    } else if ([key isEqualToString:Key_Company]) {
        [self showCompanyPickerFromView:cell];
    } else if ([key isEqualToString:Key_State]) {
        // 25.10.2019 we should not allow changing the state. it should be changed bu editing user info
        [self showSimpleMessage:@"Driver license state can't be changed. It can be updated by editing the Student info!"];
        return;
        [self showStatePickerFromView:cell forKey:key];
    } else if ([key isEqualToString:Key_Class]) {
        [self showClassPickerFromView:cell];
    } else if ([key isEqualToString:Key_Student]) {
        if (!self.company) {
            [self showSimpleMessage:@"Please select company first!"];
            return;
        }
        [self showUserPickerFromView:cell forKey:key];
    } else if ([key isEqualToString:Key_Instructor]) {
        [self showUserPickerFromView:cell forKey:key];
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        [self showDatePickerFromView:cell andKey:key];
    }
    NSLog(@"");
}



-(IBAction)valueChanged:(UISegmentedControl*)sender {
    NSInteger tag = sender.tag;
    NSInteger section = tag / 100;
    NSInteger row = tag % 100;
    
    NSString *sectionName = [self.detailsNames objectAtIndex:(NSUInteger)section];
    NSMutableArray *scores = [self.scores objectForKey:sectionName];
    
    
    if (sender.selectedSegmentIndex == 5) {
        // is N/A
        [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:-1]];
    } else {
        NSInteger score = sender.selectedSegmentIndex+1;
        [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:score]];
    }
    [self enableSaving];
    [self calculateScores];
    
    //23.07.2019 select the row to show what option they did
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:(section + self.fields.count)];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    // 19.11.2019 we should configure if we want to show/hide test alert notifications
    if ((sender.selectedSegmentIndex < 4) && self.showTestAlertNotification) {
        // 26.03.2019 we should show a popup message
        NSString *itemNumber = [self getItemNumberFromSection:sectionName andRow:row];
        NSString *msg = [self getTeachingStringForSection:sectionName andItem:itemNumber];
        if (msg) {
            NSArray *comp = [msg componentsSeparatedByString:@". "];
            //15.10.2019 msg = [NSString stringWithFormat:@"%@. %@", itemNumber, msg];

            //msg = [NSString stringWithFormat:@"%@. %@", itemNumber, [comp componentsJoinedByString:@"\n\n"]];
            msg = [NSString stringWithFormat:@"%@. %@", itemNumber, [comp componentsJoinedByString:@"\n"]];

            [self showSimpleMessage:msg];
        }
    }
}

-(IBAction)valueChangedButton:(CSDScoreButton*)sender {
    NSInteger tag = sender.tag;
    NSInteger section = tag / 100;
    NSInteger row = tag % 100;
    
    NSString *sectionName = [self.detailsNames objectAtIndex:(NSUInteger)section];
    NSMutableArray *scores = [self.scores objectForKey:sectionName];
    
    if ([self.formNumber isEqualToString:TestVRT]) {
        if (sender.selectedSegmentIndex == 2) {
            // is N/A
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:-1]];
        } else if (sender.selectedSegmentIndex == 0) {
            // OK value should be set as score:1
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:1]];
        } else {
            // Imp vallue should be set as core:0
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:0]];
        }
    } else {
        if (sender.selectedSegmentIndex == 5) {
            // is N/A
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:-1]];
        } else {
            NSInteger score = sender.selectedSegmentIndex+1;
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:score]];
        }
    }
    
    [self enableSaving];
    [self calculateScores];
    
    //23.07.2019 select the row to show what option they did
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:(section + self.fields.count)];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    // 19.11.2019 we should configure if we want to show/hide test alert notifications
    if ((sender.selectedSegmentIndex < 4) && self.showTestAlertNotification) {
        // 26.03.2019 we should show a popup message
        NSString *itemNumber = [self getItemNumberFromSection:sectionName andRow:row];
        NSString *msg = [self getTeachingStringForSection:sectionName andItem:itemNumber];
        if (msg) {
            NSArray *comp = [msg componentsSeparatedByString:@". "];
            //15.10.2019 msg = [NSString stringWithFormat:@"%@. %@", itemNumber, msg];

            //msg = [NSString stringWithFormat:@"%@. %@", itemNumber, [comp componentsJoinedByString:@"\n\n"]];
            msg = [NSString stringWithFormat:@"%@. %@", itemNumber, [comp componentsJoinedByString:@"\n"]];

            [self showSimpleMessage:msg];
        }
    }
}


-(NSNumber*)getVRTScoreForSection:(NSString*)sectionName {
    NSMutableArray *scores = [self.scores objectForKey:sectionName];
    double total = 0;
    for (NSNumber *score in scores) {
        total += [score doubleValue];
    }
    if (total < 0) {
//        return [NSNumber numberWithInt:-1];
        return [NSNumber numberWithInt:0];
    } else if (total == 0) {
//        return [NSNumber numberWithInt:0];
        return [NSNumber numberWithInt:1];
    } else {
//        return [NSNumber numberWithInt:1];
        return [NSNumber numberWithInt:2];
    }
}

-(IBAction)valueChangedVRT:(UISegmentedControl*)sender {
    NSInteger tag = sender.tag;
    NSInteger section = tag / 100;
    NSInteger row = tag % 100;
    
    NSString *sectionName = [self.detailsNames objectAtIndex:(NSUInteger)section];
    NSMutableArray *scores = [self.scores objectForKey:sectionName];
    
    if (sender.numberOfSegments == 3) {
        if (sender.selectedSegmentIndex == 2) {
            // is N/A
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:-1]];
        } else if (sender.selectedSegmentIndex == 0) {
            // OK value should be set as score:1
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:1]];
        } else {
            // Imp vallue should be set as core:0
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:0]];
        }
    } else {
        if (sender.selectedSegmentIndex == 4) {
            // is N/A
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:-1]];
        } else {
            NSInteger score = sender.selectedSegmentIndex+1;
            [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:score]];
        }
        [self enableSaving];
        [self calculateScores];
    }
    
    [self enableSaving];
    [self calculateScores];
    
    //23.07.2019 select the row to show what option they did
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:(section + self.fields.count)];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(IBAction)valueChangedForCustomSection:(UISegmentedControl*)sender {
    NSInteger tag = sender.tag;
    NSInteger section = tag / 100;
    NSInteger row = tag % 100;
    
    NSString *sectionName = [self.detailsNames objectAtIndex:(NSUInteger)section];
    NSMutableArray *scores = [self.scores objectForKey:sectionName];
    
    if (sender.selectedSegmentIndex == 0) {
        [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:ValueYes]];
    } else if (sender.selectedSegmentIndex == 1) {
        [scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:ValueNo]];
    } else if (sender.selectedSegmentIndex == 2) {
        // is N/A
        //[scores replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:-1]];
    }
    
    [self enableSaving];
    [self calculateScores];
    
    //23.07.2019 select the row to show what option they did
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:(section + self.fields.count)];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(void)calculateScores {
    self.possiblePoints = 0;
    self.receivedPoints = 0;
    
    BOOL isVRT = [self.formNumber isEqualToString:TestVRT] ? YES:NO;

    for (NSArray *scoresForsection in self.scores.allValues) {
        for (NSInteger i = 0; i<scoresForsection.count; i++) {
            NSNumber *score = [scoresForsection objectAtIndex:i];
            
            NSInteger val = 0;
            NSInteger possible = 5;
            if (isVRT) {
                possible = 4;
            }
            if (isVRT) {
                if (!(i == (scoresForsection.count - 1))) {
                    continue;
                } else {
                    NSLog(@"");
                }
            }
            // score 0: not set; score (1-5 valid); -1 N/A
            
            if ([score integerValue] >= 0) {
                val = [score integerValue];
            } else {
                // if is N/A then we should not increase the value ....
                possible = 0;
            }
            self.possiblePoints += possible;
            self.receivedPoints += val;
        }
    }
    NSString *title = [NSString stringWithFormat:@"%d/%d", (int)self.receivedPoints, (int)self.possiblePoints];
    [self.possRecvBtn setTitle:title];
}

-(NSNumber*)getScoreForRow:(NSInteger)row inSection:(NSInteger)section {
    NSString *sectionName = [self.detailsNames objectAtIndex:section];
    NSMutableArray *scores = [self.scores objectForKey:sectionName];
    return [scores objectAtIndex:row];
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
    
    
    [self.values setObject:[NSNumber numberWithBool:segCtrl.selectedSegmentIndex] forKey:key];
    
    if ([self.formNumber isEqualToString:TestVRT]) {
        NSNumber *qualified = [self.values objectForKey:KeyQualifiedOrNot];
        if (qualified) {
            if ([qualified boolValue]) {
                self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, KeyEquipmentUsed, KeyQualifiedOrNot, @"testRemarks", nil];
                self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Equipment Used", @"Qualified", @"Remarks",  nil];
                [self.values  setObject:@"" forKey:@"disqualifiedRemarks"];
            } else {
                self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, KeyEquipmentUsed, KeyQualifiedOrNot, @"testRemarks", @"disqualifiedRemarks", @"location", nil];
                self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Equipment Used", @"Qualified", @"Remarks", @"Disqualified Notes", @"Location", nil];
                [self.values  setObject:@"" forKey:@"disqualifiedRemarks"];
            }
        } else {
            self.fields = [NSArray arrayWithObjects: @"dateTime",  KeyStartDateTime, KeyEndDateTime, KeyEquipmentUsed, KeyQualifiedOrNot, @"testRemarks", nil];
            self.fieldsNames = [NSArray arrayWithObjects: @"Date", @"Start Time", @"End Time", @"Equipment Used", @"Qualified", @"Remarks",  nil];
            [self.values  setObject:@"" forKey:@"disqualifiedRemarks"];
        }
        [self.tableView reloadData];
    }
    
    [self enableSaving];
}

-(NSString*)getItemNumberFromSection:(NSString*)sectionName andRow:(NSInteger)row {
    NSArray *items = [self.detailsInfo objectForKey:sectionName];
    NSString *itemNumber = nil;

    if (row < items.count) {
        id detail = [items objectAtIndex:row];
        
        if ([detail isKindOfClass:[TestForm class]]) {
            itemNumber = [detail valueForKey:@"itemNumber"];
        } else if ([detail isKindOfClass:[TestDataDetail class]]) {
            itemNumber = [detail valueForKey:@"testItemNumber"];
        }
    }
    return itemNumber;
}

-(IBAction)infoButtonPressed:(UIButton*)sender {
    NSString *sectionName = [self.detailsNames objectAtIndex:sender.tag];
    NSArray *scores = [self.scores objectForKey:sectionName];
    
    NSMutableArray *messages = [NSMutableArray array];
    NSArray *items = [self.detailsInfo objectForKey:sectionName];
    
    for (NSInteger i = 0; i < scores.count; i++) {
        NSNumber *sc = [scores objectAtIndex:i];
        NSString *itemNumber = nil;
        //09.01.2020 we should show teaching strings all the time not just in the case when the score is < 4
        if (/*[sc integerValue] < 4*/1) {
            id detail = [items objectAtIndex:i];
            
            if ([detail isKindOfClass:[TestForm class]]) {
                itemNumber = [detail valueForKey:@"itemNumber"];
            } else if ([detail isKindOfClass:[TestDataDetail class]]) {
                itemNumber = [detail valueForKey:@"testItemNumber"];
            }
        }
        NSString *msg = [self getTeachingStringForSection:sectionName andItem:itemNumber];
        if (msg) {
            msg = [NSString stringWithFormat:@"%@. %@", itemNumber, msg];
            [messages addObject:msg];
        }
    }
    if ([messages count]) {
        [self showSimpleMessage:[messages componentsJoinedByString:@"\n\n"]];
    } else {
        [self showSimpleMessage:@"No extra infos!"];
    }
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
        detailFields = [NSArray arrayWithObject:@"userId"];
        sortKey = @"surname";
        selectedObject = self.student;
        predicate = [NSPredicate predicateWithFormat:@"company=%@", self.company.name];
    } else {
        title = @"Instructors";
        aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];
        fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
        detailFields = [NSArray arrayWithObject:@"userId"];
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
    title = @"Companies";
    fields = [NSArray arrayWithObjects:@"name", @"number", nil];
    detailFields = nil;
    sortKey = @"name";
    
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

- (void)showSetupPickerFromView:(UIBarButtonItem*)fromBtn {
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"TestSetup"];
    
    fields = [NSArray arrayWithObjects:@"name", @"number", nil];
    sortKey = @"number";
    title = @"Setup";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:Key_Setup
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = Key_Setup;
    listController.title = title;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:fromBtn];
    } else {
        listController.iPhoneNewLogic = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showEquipmentUsedPickerFromView:(UIView*)fromView {
    
    NSString *testInfoMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"];
    predicate = [NSPredicate predicateWithFormat:@"parentMobileRecordId=%@", testInfoMobileRecordId];
    fields = [NSArray arrayWithObjects:@"powerUnit", @"trailer1Number", @"dolly1Number", @"trailer2Number", @"dolly2Number", @"trailer3Number", nil];
    sortKey = @"dateTime";
    title = @"Equipment Used";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:KeyEquipmentUsed
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = KeyEquipmentUsed;
    listController.title = title;
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showStatePickerFromView:(UIView*)fromView forKey:(NSString*)key{

    NSArray *states = [RCOObject getStatesList:YES andAbbreviation:YES];
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:states
                                                                                                forKey:key];
    
    listController.selectDelegate = self;
    listController.title = @"State";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *state = [self.values objectForKey:key];
    
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
    NSArray *endorsements = [endorsement componentsSeparatedByString:@","];
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

    if ([key isEqualToString:@"dateTime"]) {
        controller.title = @"Date";
        date = self.dateTime;
        controller.dateNames = [NSArray arrayWithObject:@"Test"];
    } else if ([key isEqualToString:@"driverLicenseExpirationDate"]) {
        controller.title = @"Date";
        date = self.driverLicenseExpirationDate;
        controller.dateNames = [NSArray arrayWithObject:@"License Expiration"];
    } else if ([key isEqualToString:@"dotExpirationDate"]) {
        controller.title = @"Date";
        date = self.dotExpirationDate;
        controller.dateNames = [NSArray arrayWithObject:@"DOT Expiration"];
    }
    
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

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textView = %@", textView);
    NSString *key = [self.textFields objectAtIndex:textView.tag];
    
    if (!textView.text) {
        [self.values removeObjectForKey:key];
    } else {
        [self.values setObject:textView.text forKey:key];
    }
    [self enableSaving];
}

#pragma mark -
#pragma mark UItextFieldDelegate Methods

- (IBAction)textFieldChangedForSection:(UITextField*) textField {
    NSString *value = textField.text;
    NSInteger section = textField.tag % 100;
    NSMutableDictionary *dict = [self.specialSectionValues objectAtIndex:section];

    if (textField.tag/300) {
        [dict setObject:value forKey:KeyOdometer];
    } else if (textField.tag/200) {
        [dict setObject:value forKey:KeyTrailerNumber];
    } else {
        [dict setObject:value forKey:KeyLocation];
    }
    
    [self enableSaving];
}

- (IBAction)textFieldChanged:(UITextField*) textField {
    NSString *value = textField.text;
    NSString *key = nil;
    
    if ([textField isKindOfClass:[TextField class]]) {
        key = ((TextField*)textField).fieldId;
    } else {
        if (textField.tag >= 100) {
            return [self textFieldChangedForSection:textField];
        }
        key = [self.fields objectAtIndex:textField.tag];
    }

    [self.values setObject:[value stringByReplacingOccurrencesOfString:@"\n" withString:@" "] forKey:key];

    if ([key isEqualToString:@"startOdometer"] || [key isEqualToString:@"finishOdometer"]) {
        NSString *startOdometer = [self.values objectForKey:@"startOdometer"];
        NSString *finishOdometer = [self.values objectForKey:@"finishOdometer"];
        if (startOdometer.length && finishOdometer.length) {
            double miles = [finishOdometer doubleValue] - [startOdometer doubleValue];
            NSString *milesStr = [NSString stringWithFormat:@"%0.1f", miles];
            [self.values setObject:milesStr forKey:@"miles"];
            NSInteger index = [self.fields indexOfObject:@"miles"];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
                InputCellWithId *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass:[InputCellWithId class]]) {
                    cell.inputTextField.text = milesStr;
                }
            }
        }
    }
    
    [self enableSaving];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSString *key = nil;
    
    if ([textField isKindOfClass:[TextField class]]) {
        TextField *fieldInput = (TextField*)textField;
        key = fieldInput.fieldId;
        
        if ([key isEqualToString:@"miles"]) {
            [self showSimpleMessage:@"Miles are automatically calculated from: Start Odometer and Finish Odometer"];
            return NO;
        }
        
        if ([key isEqualToString:@"driverLicenseNumber"]) {
            // 25.10.2019 we should not allow changing the state. it should be changed bu editing user info
            [self showSimpleMessage:@"Driver license number can't be changed. It can be updated by editing the Student info!"];
            return NO;
        }
        
        if ([fieldInput.fieldId isEqualToString:KeyStartDateTime] || [fieldInput.fieldId isEqualToString:KeyEndDateTime]) {
            // start time and end time should not be editable; they are set automatically when tapping on the start/ stop button
            return NO;
        }
    } else {
        if (textField.tag >=100) {
            if (![self testStarted]) {
                [self showSimpleMessage:@"Test not started!"];
                return NO;
            }
        }
    }
    
    if ([self testEnded] && ![key isEqualToString:Key_CompanyRepresentative]) {
        [self showSimpleMessage:@"Test ended!"];
        return NO;
    }
    
    self.currentIndexPath = nil;
    if ([[[textField superview] superview] isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
        self.currentIndexPath = [self.tableView indexPathForCell:cell];
    }

    return YES;
}

-(TestDataDetail*)addUpdateDetail:(id)testDetail andScore:(NSString*)score seachForDetail:(NSNumber*)search forSectionName:(NSString*)sectionName andSectionNumber:(NSString*)sectionNumber{
    
    Aggregate *detailAgg = [[self aggregate].detailAggregates objectAtIndex:0];
    TestDataDetail *detail = nil;
    if ([search boolValue] && self.autoSaveEnabled) {
        // if we already auto saved an detail we should search it in the details list..
        TestDataDetailAggregate *agg = (TestDataDetailAggregate*)detailAgg;
        NSString *itemNumber = nil;
        NSString *sectionNumber = nil;
        if ([detail isKindOfClass:[TestForm class]]) {
            itemNumber = ((TestForm*)testDetail).itemNumber;
            sectionNumber = ((TestForm*)testDetail).sectionNumber;

        } else if ([detail isKindOfClass:[TestDataDetail class]]) {
            itemNumber = ((TestDataDetail*)testDetail).testItemNumber;
            sectionNumber = ((TestDataDetail*)testDetail).testSectionNumber;
        }

        detail = [agg getTestDetailForHeaderParentId:self.header.rcoObjectId
                                       forItemNumber:itemNumber
                                    andsectionNumber:sectionNumber];
        NSLog(@"");
    }
    
    if (!detail) {
        if ([testDetail isKindOfClass:[TestForm class]]) {
            detail = (TestDataDetail*)[detailAgg createNewObject];
            detail.testNumber = self.formNumber;
            detail.testName = ((TestForm*)testDetail).name;
            detail.dateTime = [NSDate date];
        } else {
            detail = (TestDataDetail*)testDetail;
        }
    }
    
    detail.rcoObjectParentId = self.header.rcoObjectId;
    detail.rcoBarcodeParent = self.header.rcoBarcode;
    
    if ([testDetail isKindOfClass:[TestForm class]]) {
        detail.name = ((TestForm*)testDetail).name;
        //detail.number = ((TestForm*)testDetail).number;
        detail.testNumber = ((TestForm*)testDetail).number;

        detail.testItemName = ((TestForm*)testDetail).itemName;
        detail.testItemNumber = ((TestForm*)testDetail).itemNumber;
        
        if ([self.formNumber isEqualToString:TestProd]) {
            detail.testSectionName = sectionName;
            detail.testSectionNumber = sectionNumber;
        } else {
            detail.testSectionName = ((TestForm*)testDetail).sectionName;
            detail.testSectionNumber = ((TestForm*)testDetail).sectionNumber;
        }
    }
    
    detail.employeeId = self.header.employeeId;
    detail.studentLastName = self.header.studentLastName;
    detail.studentFirstName = self.header.studentFirstName;
    
    detail.instructorLastName = self.instructor.surname;
    detail.instructorFirstName = self.instructor.firstname;
    detail.instructorEmployeeId = self.instructor.employeeNumber;
    
    detail.company = self.header.company;
    
    // we should set the test name&number if it was not set previously
    if (self.header.name.length == 0) {
        self.header.name = detail.name;
    }
    if (self.header.number.length == 0) {
        self.header.number = detail.testNumber;
    }
    
    if (!detail.testName.length) {
        NSLog(@"");
    }
    
    detail.score = score;
    [detailAgg save];
    return detail;
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
    if ([keys containsObject:Key_Endorsements]) {
        NSString *endorsement = nil;
        if (objects.count) {
            endorsement = [objects componentsJoinedByString:@","];
            [self.values setObject:endorsement forKey:Key_Endorsements];
        } else {
            [self.values removeObjectForKey:Key_Endorsements];
        }
    }
    
    [self enableSaving];
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tableView reloadData];

}

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {

    if ([key isEqualToString:KeyTestState]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:KeyEquipmentUsed]) {
        NSLog(@"");
        if (self.currentIndexPath || [self.formNumber isEqualToString:TestVRT]) {
            NSString *sectionName = nil;
            if ([self.formNumber isEqualToString:TestVRT]) {
                // we have just one equipment per test and not per section
                sectionName = key;
            } else {
                NSInteger sectionIndex = self.currentIndexPath.section - self.fields.count;
                sectionName = [self.detailsNames objectAtIndex:sectionIndex];
            }

            if (!self.equipmentUsed) {
                self.equipmentUsed = [NSMutableDictionary dictionary];
            }
            if (object) {
                [self.equipmentUsed setObject:object forKey:sectionName];
                if ([self.formNumber isEqualToString:TestVRT]) {
                    [self.values setObject:object forKey:key];
                }
            }
            NSLog(@"");
        }
        self.currentIndexPath = nil;
    } else if ([key isEqualToString:Key_CurrentSection]) {
        // we should scroll to that section
        if ([object isKindOfClass:[NSString class]]) {
            NSInteger index = [self.detailsNames indexOfObject:object];
            if (index != NSNotFound) {
                NSInteger section = self.fields.count + index;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
        NSLog(@"");
    } else if ([key isEqualToString:Key_Endorsements]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_Turns]) {
        if (object) {
            [self performSelector:@selector(turnsChanged:) withObject:object afterDelay:0.1];
        }
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        // Date Coding fields names
        if ([key isEqualToString:@"dateTime"]) {
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
            }
        } else {
            if (object) {
                [self.values setObject:object forKey:key];
            }
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
    }  else if ([key isEqualToString:TestSignatureDriver]) {
        self.driverSignature = (UIImage*)object;
    } else if ([key isEqualToString:TestSignatureEvaluator]) {
        self.evaluatorSignature = (UIImage*)object;
    } else if ([key isEqualToString:TestSignatureCompanyRep]) {
        self.compRepSignature = (UIImage*)object;
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
            if (self.instructor.userId) {
                [self.values setObject:self.instructor.userId forKey:@"instructorEmployeeId"];
            }
            
            if ([self.instructor.userId length]) {
                [Settings setSetting:self.instructor.userId forKey:CSD_PREV_INSTRUCTOR_ID];
                [Settings save];
            }
        }
    } else if ([key isEqualToString:Key_Student]) {
        if ([object isKindOfClass:[User class]]) {
            [self resetStudentsFields];
            self.student = (User*)object;
            
            if ([self.student.userId length]) {
                [Settings setSetting:self.student.userId forKey:CSD_PREV_STUDENT_ID];
                [Settings save];
            } else if ([self.student.userId length]) {
                [Settings setSetting:self.student.userId forKey:CSD_PREV_STUDENT_ID];
                [Settings save];
            }
            
            // populate the student coding fields
            if (self.student.userId) {
                [self.values setObject:self.student.userId forKey:@"employeeId"];
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
        }
    }
    if (key && ![key isEqualToString:Key_Preview] && ![key isEqualToString:Key_Turns] && ![key isEqualToString:Key_CurrentSection]) {
        [self enableSaving];
    }
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([key isEqualToString:Key_Preview]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
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
    self.needsToSave = YES;
    [self.saveBtn setEnabled:YES];
}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
}

- (void) contentDownloadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate{
    if ([aggregate isKindOfClass:[SignatureDetailAggregate class]]) {
        [self loadSignatures];
        [self.tableView reloadData];
    }
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:RD_G_R_U_X_F] && [aggregate isKindOfClass:[NotesAggregate class]] ) {
        [self loadNotes];
    } else if ([message isEqualToString:TDH] ) {
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            //[self.addDelegate didAddObject:self.detail forKey:self.addDelegateKey];
            //[self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
            [self.addDelegate didAddObject:self.header forKey:self.addDelegateKey];
        }
        [self.progressHUD hide:YES];
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:TDH] ) {
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            //[self.addDelegate didAddObject:self.detail forKey:self.addDelegateKey];
            [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
        }
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

    NSDate *startDateTime = nil;
    NSDate *endDateTime = nil;
    NSDate *stopDateTime = nil;
    BOOL shouldLoadHeader = YES;
    
    if (self.isDrivingSchool) {
        [self loadPrevInstructor];
        [self loadPrevStudent];
    }

    if (parentMobileRecordId.length) {
        NSNumber *isDrivingSchool = [Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL];
        if (![isDrivingSchool boolValue]) {
            startDateTime = [Settings getSettingAsDate:CSD_TEST_INFO_START_DATE];
            endDateTime = [Settings getSettingAsDate:CSD_TEST_INFO_END_DATE];
            stopDateTime = [Settings getSettingAsDate:CSD_TEST_INFO_STOP_DATE];
        }

        NSLog(@"");
        if (self.header) {
            if([self.header.rcoObjectParentId isEqualToString:parentMobileRecordId]) {
                // is the same test info header
                NSLog(@"");
                shouldLoadHeader = NO;
            } else {
                // is a new header and we should reset the start stop buttonsa
                NSLog(@"");
                [self loadPrevTestHeader];
            }
        } else {
            [self loadPrevTestHeader];
        }

        if (shouldLoadHeader && (self.header || [isDrivingSchool boolValue])) {
            if ([isDrivingSchool boolValue]) {
                startDateTime = self.header.startDateTime;
                endDateTime = self.header.endDateTime;
            }
            [self loadObject];
            [self syncNotes];
            [self loadCriticalItems];
            [self loadNotes];
            
            [self syncSignatures];
            [self loadSignatures];
        } else {
            NSLog(@"\n\nthe new header was not createdddd");
        }
        
        if (!self.header && self.isDrivingSchool) {
            [self addStartButton];
        }
        
        if ([self.formNumber isEqualToString:TestProd] || [self.formNumber isEqualToString:TestVRT]) {
            if (!self.equipmentUsed) {
                [self loadEquipmentUsed];
            }
        }
        
        if (startDateTime) {
            [self.values setObject:startDateTime forKey:KeyStartDateTime];
        } else {
            [self.values removeObjectForKey:KeyStartDateTime];
        }

        if (endDateTime) {
            [self.values setObject:endDateTime forKey:KeyEndDateTime];
        } else {
            [self.values removeObjectForKey:KeyEndDateTime];
        }
        
    } else {
        self.header = nil;
        self.details = [NSMutableArray array];
        self.detailsNames = [NSMutableArray array];
        [self.values removeObjectForKey:KeyStartDateTime];
        [self.values removeObjectForKey:KeyEndDateTime];
    }
    
    [self customizeBottomToolbar];
    [self.progressHUD hide:YES];
    [self.tableView reloadData];
}

-(void)CSDInfoDidSavedObject:(NSString *)parentMobileRecordId {
    NSLog(@"");
}

-(BOOL)CSDInfoCanSelectScreen {
    NSDate *endDateTime = [Settings getSettingAsDate:CSD_TEST_INFO_STOP_DATE];
    if (!self.isDrivingSchool && endDateTime && self.header) {
        return NO;
    }
    return !self.needsToSave;
}

-(BOOL)CSDNeedsToSign {
    if ([self.formNumber isEqualToString:TestPreTrip]) {
        NSLog(@"");
    }
    
    TestDataHeader *tdh = self.header;
    UIImage *driverSignatureImage = self.driverSignature;
    UIImage *evaluatorSignatureImage = self.evaluatorSignature;
    
    if (!tdh) {
        NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
        if (parentMobileRecordId.length) {
            TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[self aggregate];
            tdh = [agg getStartedTestDataHeaderForTestInfo:parentMobileRecordId andFormNumber:self.formNumber];
        }
        
        if (tdh) {
            driverSignatureImage = [self getSignatureImageForTestHeader:tdh andType:TestSignatureDriver];
            evaluatorSignatureImage = [self getSignatureImageForTestHeader:tdh andType:TestSignatureEvaluator];
        }
    }
    
    // we should force the user to sign the forms when they end it .....
    return tdh && (!driverSignatureImage || !evaluatorSignatureImage);
}

-(NSString*)CSDInfoScreenTitle {
    if ([self.formNumber isEqualToString:TestBTW]) {
        return @"Behind the Wheel";
    }
    if ([self.formNumber isEqualToString:TestPreTrip]) {
        return @"Pre Trip";
    }
    if ([self.formNumber isEqualToString:TestBusEval]) {
        return @"Passenger";
    }
    if ([self.formNumber isEqualToString:TestSWP]) {
        return @"Safe Work Practice";
    }
    if ([self.formNumber isEqualToString:TestProd]) {
        return @"Production";
    }
    if ([self.formNumber isEqualToString:TestVRT]) {
        return @"VRT";
    }
    return nil;
}

-(void)CSDSaveRecordOnServer:(BOOL)onServer {
    NSLog(@"");
    if (!self.isDrivingSchool) {
        // 16.03.2020 if we created the record automatically and the record and the record does not need to be saved ( we didn't do any changes to the record)
        if (!self.needsToSave && self.isNewCreated) {
            // 23.01.2020 we should delete it ...
            NSLog(@"");
            
            if ([self.header existsOnServerNew]) {
                NSLog(@"");
            }
            
            self.details = [NSMutableArray array];
            self.detailsNames = [NSMutableArray array];
            self.values = [NSMutableDictionary dictionary];
            [[self aggregate] destroyObj:self.header];
            self.header = nil;
        }
    }
    self.saveOnServer = onServer;
    self.saveSignature = YES;
    
    NSDate *endDateTime = [Settings getSettingAsDate:CSD_TEST_INFO_STOP_DATE];
    if (endDateTime && !self.isDrivingSchool) {
        if (!self.header) {
            NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
            if (parentMobileRecordId.length) {
                TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[self aggregate];
                self.header = [agg getStartedTestDataHeaderForTestInfo:parentMobileRecordId andFormNumber:self.formNumber];
            }
            if (self.header) {
                // 30.01.2020 load the details
                [self loadObject];
                self.saveScores = YES;
            }
        }
        // 29.01.2020 TODO: we need a solution for creating scores for don driving schools
        if (!self.header.endDateTime) {
            self.saveScores = YES;
        }
        self.header.endDateTime = endDateTime;
        // 30.01.2020 we should force a "normal" save
        /*
        [[self aggregate] createNewRecord:self.header];
         */
    }
    
    /*
     30.01.2020 we should simulate a normal save with the "existing" save button
    // 10.12.2019 we should simulate an auto save ....
    [self saveButtonPressed:self.autoSaveTimer];
     */
    if (endDateTime) {
        self.needsToSave = YES;
        [self saveButtonPressed:self.saveBtn];
    } else {
        [self saveButtonPressed:self.autoSaveTimer];
    }
}

@end
