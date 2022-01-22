//
//  CSDAccidentVehicleReportViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDAccidentVehicleReportViewController.h"
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

#import "WebViewViewController.h"

#import "DriverTurn+CoreDataClass.h"
#import "Settings.h"
#import "CSDPhotosViewController.h"

#define Key_Class @"driverLicenseClass"
#define Key_Employee @"employeeId"
#define Key_Instructor @"instructorEmployeeId"
#define Key_Setup @"setup"
#define Key_Preview @"preview"
#define Key_Spill_Size @"spillSize"
#define Key_Fire_Size @"sizeOfFire"
#define Key_Spill_Type @"spillType"
#define Key_Injury_DegreeYour @"injuryDegreeYour"
#define Key_Injury_DegreeOthers @"injuryDegreeOthers"
#define Key_Incident_Type @"accidentIncidentType"
#define Key_Crash_Type @"accidentCrashType"
#define Key_Severity_Level @"accidentSeverityLevel"
#define Key_Chargeble_Determination @"accidentChargeableDetermination"

#define Key_Accident_Degree @"accidentDegree"
#define Key_DriverLicenseState @"driverLicenseState"
#define Key_State @"state"

#import "AccidentVehicleReport+CoreDataClass.h"
#import "CSDVehicleAccidentReportAggregate.h"
#import "PhotosAggregate.h"
#import "UIImage+Resize.h"
#import "CSDAccidentDetailslListViewController.h"
#import "TextEditorViewController.h"


#define Key_Photos @"Photos"
#define Key_Photos_New @"Photos_new"


@interface CSDAccidentVehicleReportViewController ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *notes;
@property (nonatomic, strong) NSMutableDictionary *detailsInfo;

@property (nonatomic, strong) NSMutableArray *detailsNames;
@property (nonatomic, strong) NSMutableDictionary *scores;

@property (nonatomic, strong) NSArray *bottomSection;
@property (nonatomic, strong) NSArray *bottomSectionNames;

@property (nonatomic, strong) NSArray *fieldsNames;
@property (nonatomic, strong) NSArray *fieldsNamesShort;

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *pickerInfoFields;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *percentageFields;
@property (nonatomic, strong) NSArray *numericFields;

@property (nonatomic, strong) NSArray *injuredFields;
@property (nonatomic, strong) NSArray *fireFields;
@property (nonatomic, strong) NSArray *spillFields;
@property (nonatomic, strong) NSMutableArray *disabledFields;
@property (nonatomic, strong) NSMutableDictionary *parentFields;
@property (nonatomic, strong) NSMutableDictionary *parentFieldsNames;
@property (nonatomic, strong) NSArray *sectionFields;
@property (nonatomic, strong) NSArray *sectionFieldsNames;
@property (nonatomic, strong) NSArray *sectionFooterTexts;

@property (nonatomic, strong) NSArray *datePickerFieldsNames;

@property (nonatomic, strong) NSDate *dateTime;
@property (nonatomic, strong) NSDate *driverLicenseExpirationDate;
@property (nonatomic, strong) NSDate *dotExpirationDate;

@property (nonatomic, strong) UIImage *driverSignature;
@property (nonatomic, strong) UIImage *evaluatorSignature;
@property (nonatomic, strong) UIImage *compRepSignature;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *pauseBtn;
@property (nonatomic, strong) UIBarButtonItem *previewBtn;

@property(nonatomic, strong) NSArray *testFormItems;
@property(nonatomic, strong) NSMutableArray *details;
@property(nonatomic, strong) NSArray *typeOfSpill;
@property(nonatomic, strong) NSArray *sizeOfSpill;
@property(nonatomic, strong) NSArray *injuryAccidentDegree;
@property(nonatomic, strong) NSArray *accidentIncidentTypes;
@property(nonatomic, strong) NSArray *accidentCrashTypes;
@property(nonatomic, strong) NSArray *accidentSeverityLevels;
@property(nonatomic, strong) NSArray *accidentChargeableDeterminations;

@property(nonatomic, strong) NSDate *pausedDate;
@property (nonatomic, assign) BOOL sendAlerts;

// Photos ....
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *photosToSave;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSMutableDictionary *photosInfo;
@property (nonatomic, strong) MWPhotoBrowserPlus *browser;

@end

@implementation CSDAccidentVehicleReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 26.06.2019 turn on/off alerts via email
    self.sendAlerts = YES;
    
    self.previewBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Preview", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(emailButtonPressed:)];
    
    self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                 target:self
                                                                 action:@selector(saveButtonPressed:)];
    [self.saveBtn setEnabled:NO];
    
    if (self.header) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, nil];
    } else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveBtn, nil];
    }
    
    BOOL enableEditingEndedTests = YES;

    // should we allow edinting a test that was ended?
    enableEditingEndedTests = NO;
    
    self.pauseBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                 target:self
                                                                 action:@selector(pauseButtonPressed:)];

    self.pausedDate = [Settings getSettingAsDate:CSD_TEST_PAUSED_DATE];
    
    if ([self.header existsOnServerNew] && enableEditingEndedTests) {
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
    
    self.typeOfSpill = [NSArray arrayWithObjects:@"NA", @"Cement", @"Fuel", @"Grain", @"Haz Mat", @"Oil", @"Produce", @"Sand", @"Shipped Product", @"Water", @"Other", nil];
    self.sizeOfSpill = [NSArray arrayWithObjects:@"NA", @"Minor", @"Moderate", @"Major", @"Unknown", nil];
    self.injuryAccidentDegree = [NSArray arrayWithObjects:@"NA", @"Minor", @"Moderate", @"Major", @"Unknown", nil];

    self.accidentIncidentTypes = [NSArray arrayWithObjects:@"Injury", @"Crash", @"Near Miss", nil];
    self.accidentCrashTypes = [NSArray arrayWithObjects:@"Animal", @"Backing", @"Cyclist", @"Entering/Exiting", @"Hazardous Material", @"Hit in Rear", @"Hit Other in Rear", @"Hit Parked Vehicle", @"Hit Stationary Object", @"Hit While Parked", @"Intersection", @"Jacknife", @"Moving Object", @"Parking Lot", @"Rollaway", @"Sideswipe", nil];
    self.accidentSeverityLevels = [NSArray arrayWithObjects:@"NA", @"Minor", @"Moderate", @"Major", @"Unknown", nil];
    self.accidentChargeableDeterminations = [NSArray arrayWithObjects:@"Avoidable", @"Unavoidable", nil];

    self.parentFields = [NSMutableDictionary dictionary];
    self.parentFieldsNames = [NSMutableDictionary dictionary];
    
    self.sectionFields = [NSArray arrayWithObjects:@"dateTime", @"injured",  @"accidentLocationSecured",  @"anyoneElseInjured", @"fatilities", @"Are there emergency Personnel on site?", @"isFire", @"isThereASpill", @"anotherViehicleInvolved", @"vehicleNeedsTowing", @"firstName", @"lastName", @"employeeId", @"driverLicenseExpirationDate", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseClass", @"homePhone", @"workPhone", @"mobilePhone",  @"objectDescription",@"address1", @"city", @"state", @"zip", @"location", @"weatherConditions", @"accidentSiteDescription", @"accidentChargeableDetermination", @"accidentCrashType",  @"accidentIncidentDescription", @"accidentIncidentType", @"accidentInjuryOccurred", @"accidentSeverityLevel", @"rootCause1", @"preventionActivity1ForEmployee", @"preventionActivity1ForWorkforce", @"rootCause2", @"preventionActivity2ForEmployee", @"preventionActivity2ForWorkforce", @"employeeAccidentHistory", @"employmentDate", @"annualSafetyReview", @"safetyReviewDate", @"followUpTraining", @"priorTraining", @"employeeAccidentHistory", @"mentorAssigned", @"workforceNotificationPosted", nil];

    // 05.06.2019
    self.sectionFields = [NSArray arrayWithObjects:@"dateTime", @"injured",  @"accidentLocationSecured",  @"anyoneElseInjured", @"fatilities", @"Are there emergency Personnel on site?", @"isFire", @"isThereASpill", @"anotherViehicleInvolved", @"vehicleNeedsTowing", @"firstName", @"lastName", @"employeeId", @"driverLicenseExpirationDate", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseClass", @"homePhone", @"workPhone", @"mobilePhone" ,@"address1", @"city", @"state", @"zip", @"location", @"objectDescription", @"weatherConditions", @"accidentSiteDescription", nil];

    // 19.08.2019, added accidentDegree
    self.sectionFields = [NSArray arrayWithObjects:@"dateTime", @"injured", @"accidentDegree",  @"accidentLocationSecured",  @"anyoneElseInjured", @"fatilities", @"Are there emergency Personnel on site?", @"isFire", @"isThereASpill", @"anotherViehicleInvolved", @"vehicleNeedsTowing", @"firstName", @"lastName", @"employeeId", @"driverLicenseExpirationDate", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseClass", @"homePhone", @"workPhone", @"mobilePhone" ,@"address1", @"city", @"state", @"zip", @"location", @"objectDescription", @"weatherConditions", @"accidentSiteDescription", nil];

    
    self.sectionFooterTexts = [NSArray arrayWithObjects:@"Call 911 if injury requires immediate attention",  @"Do not place yourself or others in harms way!!!",  @"", @"", @"", @"", @"", @"", @"Be prepare to provide REQUIRED documents ( Insurance, Registration, Phone# License", nil];

    self.sectionFieldsNames = [NSArray arrayWithObjects:@"Date & Time", @"Are you injured?",  @"Is the accident location secured?",  @"Is anyone else injured", @"Are there any fatilities", @"Are there emergency Personnel on site?", @"Is there a fire", @"Is there a spill", @"Is there another Vehicle involved", @" Does your vehicle needs to be towed?", @"Driver First Name", @"Driver Last Name", @"Employee#", @"Driver License Expiration Date", @"Driver License Number", @"Driver License State", @"Driver License Class", @"Home Phone", @"Work Phone", @"Mobile Phone",  @"Crash Description",@"Address", @"City", @"State", @"Zipcode", @"Location", @"Weather Conditions", @"Accident Site Description", @"Accident Chargeable Determination", @"Accident Crash Type",  @"Accident Incident Description", @"Accident Incident Type", @"Accident Injury Occurred", @"Accident Severity Level", @"Accident Root Cause Number One", @"Accident Prevention Activity Number One for Employee", @"Accident Prevention Activity Number One for Workforce", @"Accident Root Cause Number Two", @"Accident Prevention Activity Number Two for Employee", @"Accident Prevention Activity Number Two for Workforce", @"Employee Accident History", @"Employment Date", @"Annual Safety Review", @"Safety Review Date", @"Follow Up Training", @"Prior Training", @"Employees Manager Workgroup Safety History", @"Mentor Assigned", @"Workforce Notification Posted", nil];
    
    // 05.06.2019
    self.sectionFieldsNames = [NSArray arrayWithObjects:@"Date & Time", @"Are you injured?",  @"Is the accident location secured?",  @"Is anyone else injured", @"Are there any fatilities", @"Are there emergency Personnel on site?", @"Is there a fire", @"Is there a spill", @"Is there another Vehicle involved", @" Does your vehicle needs to be towed?", @"Driver First Name", @"Driver Last Name", @"Employee#", @"Driver License Expiration Date", @"Driver License Number", @"Driver License State", @"Driver License Class", @"Home Phone", @"Work Phone", @"Mobile Phone",  @"Address", @"City", @"State", @"Zipcode", @"Location", @"Crash Description", @"Weather Conditions", @"Accident Site Description", nil];

    // 19.08.2019 added @"Accident Degree",
    self.sectionFieldsNames = [NSArray arrayWithObjects:@"Date & Time", @"Are you injured?", @"Accident Degree",  @"Is the accident location secured?",  @"Is anyone else injured", @"Are there any fatilities", @"Are there emergency Personnel on site?", @"Is there a fire", @"Is there a spill", @"Is there another Vehicle involved", @" Does your vehicle needs to be towed?", @"Driver First Name", @"Driver Last Name", @"Employee#", @"Driver License Expiration Date", @"Driver License Number", @"Driver License State", @"Driver License Class", @"Home Phone", @"Work Phone", @"Mobile Phone",  @"Address", @"City", @"State", @"Zipcode", @"Location", @"Crash Description", @"Weather Conditions", @"Accident Site Description", nil];

    
    //  "section" 1
    // 19.08.2019 NSArray *arr = [NSArray arrayWithObjects:@"injured", @"injuryDegreeYour", @"accidentDegree", nil];
    NSArray *arr = [NSArray arrayWithObjects:@"injured", @"injuryDegreeYour", nil];

    [self.parentFields setObject:arr forKey:@"injured"];

    // 19.08.2019 arr = [NSArray arrayWithObjects:@" ", @"Injury Degree", @"Accident Degree", nil];
    arr = [NSArray arrayWithObjects:@" ", @"Injury Degree", nil];

    [self.parentFieldsNames setObject:arr forKey:@"injured"];
    
    // "section" 2
    arr = [NSArray arrayWithObjects:@"anyoneElseInjured", @"numberOfInjuries", @"injuryDegreeOthers", @"transported", @"transportedToLocation", nil];
    [self.parentFields setObject:arr forKey:@"anyoneElseInjured"];
    
    arr = [NSArray arrayWithObjects:@" ", @"Number of injuries", @"Injury Degree", @"Is anyone being transported?", @"Transported to", nil];
    [self.parentFieldsNames setObject:arr forKey:@"anyoneElseInjured"];

    // "section" 3
    arr = [NSArray arrayWithObjects:@"policeOnSite", @"paramedicsOnSite", @"ambulanceOnSite", @"coronerOnSite", nil];
    [self.parentFields setObject:arr forKey:@"Are there emergency Personnel on site?"];

    arr = [NSArray arrayWithObjects:@"Police", @"Paramedics", @"Ambulance", @"Coroner", nil];
    [self.parentFieldsNames setObject:arr forKey:@"Are there emergency Personnel on site?"];

    // "section" 4
    arr = [NSArray arrayWithObjects:@"isFire", @"sizeOfFire", @"fireExtinguisherAvailable", @"fireExtinguisherUsed", nil];
    [self.parentFields setObject:arr forKey:@"isFire"];
    
    arr = [NSArray arrayWithObjects:@" ", @"Size of fire", @"Extinguisher Available", @"Extinguisher Used", nil];
    [self.parentFieldsNames setObject:arr forKey:@"isFire"];

    // "section" 5
    arr = [NSArray arrayWithObjects:@"isThereASpill", @"spillSize", @"spillType", @"spillContained", nil];
    [self.parentFields setObject:arr forKey:@"isThereASpill"];
    
    arr = [NSArray arrayWithObjects:@" ", @"Size", @"Type", @"Contained", nil];
    [self.parentFieldsNames setObject:arr forKey:@"isThereASpill"];

    // "section" 6
    arr = [NSArray arrayWithObjects:@"anotherViehicleInvolved", @"numberOfVehiclesInvolved", nil];
    [self.parentFields setObject:arr forKey:@"anotherViehicleInvolved"];
    
    arr = [NSArray arrayWithObjects:@" ", @"Number of vehicles involved", nil];
    [self.parentFieldsNames setObject:arr forKey:@"anotherViehicleInvolved"];

    // "section" 7
    arr = [NSArray arrayWithObjects:@"vehicleNeedsTowing", @"otherVehicleNeedsTowing", @"numberOfVehiclesTowed", nil];
    [self.parentFields setObject:arr forKey:@"vehicleNeedsTowing"];
    arr = [NSArray arrayWithObjects:@" ", @"Other vehicle needs towing", @"Number of vehicles towed", nil];
    [self.parentFieldsNames setObject:arr forKey:@"vehicleNeedsTowing"];

    //self.numericFields = [NSArray arrayWithObjects:@"homePhone", @"mobilePhone", @"workPhone", @"vehicleYear", @"companyPhone", @"companyZipcode", @"zip", @"numberOfInjuries", @"numberOfVehiclesInvolved", @"numberOfVehiclesTowed", nil];

    // 13.09.2019 add fatilities as a numeric field
    self.numericFields = [NSArray arrayWithObjects:@"homePhone", @"mobilePhone", @"workPhone", @"vehicleYear", @"companyPhone", @"companyZipcode", @"zip", @"numberOfInjuries", @"numberOfVehiclesInvolved", @"numberOfVehiclesTowed", @"fatilities", nil];

    self.disabledFields = [NSMutableArray array];
    
    //self.switchFields = [NSArray arrayWithObjects:@"injured", @"accidentLocationSecured", @"anyoneElseInjured", @"accidentLocationSecured", @"transported", @"fatilities", @"isFire", @"fireExtinguisherAvailable", @"fireExtinguisherUsed", @"isThereASpill", @"policeOnSite", @"paramedicsOnSite", @"ambulanceOnSite", @"coronerOnSite", @"anotherViehicleInvolved", @"vehicleNeedsTowing", @"otherVehicleNeedsTowing", @"accidentInjuryOccurred", @"annualSafetyReview", @"followUpTraining", @"priorTraining", @"mentorAssigned", @"workforceNotificationPosted", nil];

    //13.09.2019 take out fatilities from switch and make it a number input field
    self.switchFields = [NSArray arrayWithObjects:@"injured", @"accidentLocationSecured", @"anyoneElseInjured", @"accidentLocationSecured", @"transported", @"isFire", @"fireExtinguisherAvailable", @"fireExtinguisherUsed", @"isThereASpill", @"policeOnSite", @"paramedicsOnSite", @"ambulanceOnSite", @"coronerOnSite", @"anotherViehicleInvolved", @"vehicleNeedsTowing", @"otherVehicleNeedsTowing", @"accidentInjuryOccurred", @"annualSafetyReview", @"followUpTraining", @"priorTraining", @"mentorAssigned", @"workforceNotificationPosted", nil];

    
    self.fields = [NSArray arrayWithObjects: @"injured",  @"injuryDegreeYour",  @"accidentDegree", @"accidentLocationSecured", @"injured", @"numberOfInjuries", @"injuryDegreeOthers", @"transported", @"fatilities", @"isFire", @"sizeOfFire", @"fireExtinguisherAvailable", @"fireExtinguisherUsed", @"isThereASpill", @"spillSize", @"spillType", @"spillContained", @"firstName", @"lastName", nil];

    self.fieldsNames = [NSArray arrayWithObjects: @"Injured",  @"Injury Degree",  @"Accident Degree", @"Accident Location Secured", @"Injured", @"Number Of Injuries", @"Injury Degree", @"Transported", @"Fatilities", @"Is there Fire", @"Size Of Fire", @"Fire Extinguisher Available", @"Fire Extinguisher Used", @"Is There A Spill", @"Spill Size", @"Spill Type", @"Spill Contained", @"Driver First Name", @"Driver Last Name", nil];

    //self.bottomSection = [NSArray arrayWithObjects:TestSignatureDriver, TestSignatureEvaluator, TestSignatureCompanyRep, nil];
    self.bottomSectionNames = [NSArray arrayWithObjects:@"Driver Signature", @"Evaluator Signature", @"Company Rep. Signature", nil];

    self.values = [NSMutableDictionary dictionary];
    
    //BOOL isOffline = [[DataRepository sharedInstance] workOffline];
    self.datePickerFieldsNames = [NSArray arrayWithObjects:@"dateTime", @"driverLicenseExpirationDate", @"employmentDate", @"safetyReviewDate", nil];
    
    self.pickerFields = [NSArray arrayWithObjects:@"driverLicenseState", @"state",
  @"accidentSiteDescription", @"accidentIncidentDescription", @"objectDescription", @"spillSize", @"spillType", @"injuryDegreeYour", @"injuryDegreeOthers", @"accidentDegree", @"sizeOfFire", @"accidentIncidentType", @"accidentCrashType", @"accidentSeverityLevel", @"accidentChargeableDetermination", Key_Class, nil];
    
    self.pickerInfoFields = [NSArray arrayWithObjects: @"accidentSiteDescription", @"accidentIncidentDescription", @"objectDescription", nil];

    //self.requiredFields = [NSArray arrayWithObjects:@"dateTime", @"employeeLastName", @"employeeId", @"driverLicenseExpirationDate", @"instructorEmployeeId", nil];
    self.requiredFields = [NSArray arrayWithObjects:@"firstName", @"lastName", @"driverLicenseNumber", @"driverLicenseState", @"employeeId", @"accidentIncidentType", @"accidentCrashType", @"accidentSeverityLevel", @"accidentChargeableDetermination", nil];

    // 05.06.2019
    self.requiredFields = [NSArray arrayWithObjects:@"firstName", @"lastName", @"driverLicenseNumber", @"driverLicenseState", @"employeeId", nil];
    self.scores = [NSMutableDictionary dictionary];
    
    [self syncNotes];
    [self loadObject];
    [self loadNotes];
    [self getPhotos];
    [self loadSignatures];
    
    if (!self.header) {
        // if is a new accident for then we sjhould load the previous driver infos
        [self loadPrevDriverInfo];
    }
    
    self.title = [self getScreenTitle];
    if (!self.header) {
        // we want to create a new accident report
        // we should get the location automatically
        [[DataRepository sharedInstance] getCityLocatorForLocation:nil
                                                      andLongitude:nil
                                                       andRecordId:nil];
    }
    
    if (!self.header) {
        //08.7.2019 we should show the disclaimer
        [self performSelector:@selector(showDisclaimer)
                   withObject:nil
                   afterDelay:0.1];
    }
}

-(void)showDisclaimer {
    NSString *msg = @"1. If you or someone else is injured and require medical attention (Call 911 1st)\n\n2. At anytime that you are collecting information on the crash, DO NOT place yourself or anyone else in harm's way.\n\n3. If you are in a remote location and feel uneasy about exiting your vehicle and talking to the other party (Don't) - (If Possible) stay in vehicle with the windows closed and doors locked and dial 911 for instructions.\n\n4. Never admit guilt just discuss the facts - You are only required to provide details to an investigating officials";
    [self showSimpleMessage:msg];
}

-(void)loadPrevDriverInfo {

    NSString *firstName = [[DataRepository sharedInstance] getLoggedUserFirstName];;
    if (firstName.length) {
        [self.values setObject:firstName forKey:@"firstName"];
    }
    
    NSString *lastName = [[DataRepository sharedInstance] getLoggedUserLastName];;
    if (lastName.length) {
        [self.values setObject:lastName forKey:@"lastName"];
    }
    
    NSString *employeeId = [[DataRepository sharedInstance] getLoggedUserEmployeeId];;
    if (employeeId.length) {
        [self.values setObject:employeeId forKey:@"employeeId"];
    }
    
    UserAggregate *agg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    
    User *currentUser = [agg getAnyUserWithEmployeeId:employeeId];
    
    NSString *val = [Settings getSetting:CSD_ACCIDENT_DRIVER_LICENSE_NUMBER];
    if (val.length) {
        [self.values setObject:val forKey:@"driverLicenseNumber"];
    } else {
        if (currentUser.driverLicenseNumber.length) {
            [self.values setObject:currentUser.driverLicenseNumber forKey:@"driverLicenseNumber"];
        }
    }
    val = [Settings getSetting:CSD_ACCIDENT_DRIVER_LICENSE_STATE];
    if (val.length) {
        [self.values setObject:val forKey:@"driverLicenseState"];
    } else {
        if (currentUser.driverLicenseState.length) {
            [self.values setObject:currentUser.driverLicenseState forKey:@"driverLicenseState"];
        }
    }
    NSDate *date = [Settings getSettingAsDate:CSD_ACCIDENT_DRIVER_LICENSE_EXPIRATION_DATE];
    if ([date isKindOfClass:[NSDate class]]) {
        [self.values setObject:date forKey:@"driverLicenseExpirationDate"];
        self.driverLicenseExpirationDate = date;
    } else {
        if (currentUser.driverLicenseExpirationDate) {
            [self.values setObject:currentUser.driverLicenseExpirationDate forKey:@"driverLicenseExpirationDate"];
            self.driverLicenseExpirationDate = currentUser.driverLicenseExpirationDate;
        }
    }
    
    if (currentUser.driverLicenseClass.length) {
        [self.values setObject:currentUser.driverLicenseClass forKey:Key_Class];
    }

    if (currentUser.workPhoneNumber.length) {
        [self.values setObject:currentUser.workPhoneNumber forKey:@"workPhone"];
    }

    if (currentUser.mobilePhoneNumber.length) {
        [self.values setObject:currentUser.mobilePhoneNumber forKey:@"mobilePhone"];
    }

    if (currentUser.homePhoneNumber.length) {
        [self.values setObject:currentUser.homePhoneNumber forKey:@"homePhone"];
    }
    
    val = [Settings getSetting:CSD_ACCIDENT_DRIVER_BIRTH_DATE];
    if (val.length) {
       // [self.values setObject:val forKey:@"driverLicenseState"];
    }
}

-(NSString*)parentField:(NSString*)codingField {

    for (NSString *key in self.parentFields.allKeys) {
        NSArray *arr = [self.parentFields objectForKey:key];
        if ([arr containsObject:codingField]) {
            return key;
        }
    }
    return nil;
}

-(void)syncNotes {
    if (!self.header || (self.header.rcoBarcode.length == 0)) {
        return;
    }
    NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
    [agg getNotesForMasterBarcode:self.header.rcoBarcode];
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

-(void)loadSignatures {
    if (!self.header) {
        return;
    }
/*
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
 */
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
    [agg save];
    if ([self.header existsOnServerNew]) {
        [agg createNewRecord:note];
    }
}

-(NSString*)getScreenTitle {
    if (self.header) {
        return self.header.name;
    } else {
        return @"New";
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"] registerForCallback:self];
    [[self aggregate] registerForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"SignatureDetail"] registerForCallback:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationReceived:) name:@"locationReceived" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"] unRegisterForCallback:self];
    [[self aggregate] unRegisterForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"SignatureDetail"] unRegisterForCallback:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationReceived" object:nil];
}

-(void)locationReceived:(NSNotification*) notification {
    NSLog(@"");
    id obj = notification.object;
    if ([obj isKindOfClass:[NSString class]]) {
        [self.values setObject:obj forKey:@"location"];
        if (!self.header) {
            [self performSelectorOnMainThread:@selector(sendStartAccidentAlert) withObject:nil waitUntilDone:YES];
        }
    }
}

-(void)sendStartAccidentAlert {
    if (!self.sendAlerts) {
        return;
    }
}

-(NSString*)generateAlertMessageForUser:(User*)user {
    NSMutableArray *lines = [NSMutableArray array];
    
    [lines addObject:[NSString stringWithFormat:@"Student: %@", [user Name]]];
    [lines addObject:[NSString stringWithFormat:@"Student ID: %@", [user employeeNumber]]];
    [lines addObject:[NSString stringWithFormat:@"Date&Time: %@", [NSDate rcoDateTimeString:[NSDate date]]]];
    [lines addObject:[NSString stringWithFormat:@"Location: %@", [self.values objectForKey:@"location"]]];
    [lines addObject:[NSString stringWithFormat:@"Latitude, Logitude: %@,%@", [[DataRepository sharedInstance] getCurrentLatitude], [[DataRepository sharedInstance] getCurrentLatitude]]];

    return [lines componentsJoinedByString:@"\n"];
}

-(void)loadObject {
    
    self.values = [NSMutableDictionary dictionary];
    
    self.dateTime = self.header.dateTime;
    if (!self.dateTime) {
        self.dateTime = [NSDate date];
    }
    [self.values setObject:self.dateTime forKey:@"dateTime"];
    /*
    self.dotExpirationDate = self.header.dotExpirationDate;
    if (self.dotExpirationDate) {
        [self.values setObject:self.dotExpirationDate forKey:@"dotExpirationDate"];
    }
    */

    self.driverLicenseExpirationDate = self.header.driverLicenseExpirationDate;
    if (self.driverLicenseExpirationDate) {
        [self.values setObject:self.driverLicenseExpirationDate forKey:@"driverLicenseExpirationDate"];
    }
    
    for (NSString *field in self.fields) {
        NSString *value = [self.header valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }
    for (NSString *field in self.sectionFields) {
        SEL theSel = NSSelectorFromString(field);
        if ([self.header respondsToSelector:theSel]) {
            NSString *value = [self.header valueForKey:field];
            if (value) {
                [self.values setObject:value forKey:field];
            }
        }
    }

    self.detailsInfo = [NSMutableDictionary dictionary];
    self.scores = [NSMutableDictionary dictionary];
    self.detailsNames = [NSMutableArray array];
    
    // 25.03.2019 we should keep all the forms in memroy to be able to access quickly..
    self.testFormItems = nil;
    [self.tableView reloadData];
}

-(NSString*)getTeachingStringsForSection:(NSString*)section {

    if (!section.length) {
        return nil;
    }
    return nil;
}

#pragma mark Actions
-(IBAction)witnessesButtonPressed:(UIBarButtonItem*)sender {
    [self showRecordsList:AccidentRecordTypeWitness fromButton:sender];
}

-(IBAction)trailerButtonPressed:(UIBarButtonItem*)sender {
    [self showRecordsList:AccidentRecordTypeTrailerDollie fromButton:sender];
}

-(IBAction)vehiclesButtonPressed:(UIBarButtonItem*)sender {
    [self showRecordsList:AccidentRecordTypeVehicle fromButton:sender];
}

-(void)showRecordsList:(AccidentRecordType)recordType fromButton:(UIBarButtonItem*)sender {
    if (!self.header) {
        [self showSimpleMessage:@"Please save Accident Record first!"];
        return;
    }

    CSDAccidentDetailslListViewController *controller = [[CSDAccidentDetailslListViewController alloc] initWithNibName:@"CSDAccidentDetailslListViewController" bundle:nil];
    controller.accident = self.header;
    controller.addDelegate = self;
    controller.recordType = recordType;
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:controller fromBarButton:sender];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)getPhotos {
    if ([self.header existsOnServerNew]) {
        PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
        
        [agg getPhotosForMasterBarcode:self.header.rcoBarcode];
    }
}

-(IBAction)photosButtonPressed:(id)sender {
    if (!self.header) {
        [self showSimpleMessage:@"Please save Accident Record first!"];
        return;
    }
    CSDPhotosViewController *controller = [[CSDPhotosViewController alloc] initWithNibName:@"CSDPhotosViewController" bundle:nil];
    controller.header = self.header;
    controller.addDelegate = self;
    controller.addDelegateKey = Key_Photos_New;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:controller fromBarButton:sender];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(IBAction)photosButtonPressedOLD:(id)sender {
    if (!self.header) {
        [self showSimpleMessage:@"Please save Accident Record first!"];
        return;
    }

    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    
    NSArray *photos = [agg getPhotosForObject:self.header];
    
    self.photos = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    self.selections = [NSMutableArray array];
    
    self.photosInfo = [NSMutableDictionary dictionary];
    
    for (RCOObject *photo in photos) {
        MWPhoto *photoObject = nil;
        
        if ([photo existsOnServerNew]) {
            NSString *str = nil;
            
            // we should get the fullImage
            str = [photo getImageURL:YES];
            NSLog(@"LINK = %@", str);
            
            photoObject = [MWPhoto photoWithURL:[NSURL URLWithString:str]];
            [photoObject setCaption:@"RMS"];
            
            [self.photos addObject:photoObject];
            [self.selections addObject:[NSNumber numberWithBool:NO]];
            
            // we should get the url for thumbnail
            str = [photo getImageURL:NO];
            [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:str]]];
        } else {
            // we should load from local DB
            UIImage *img = [agg getImageForObject:photo.rcoMobileRecordId];
            photoObject = [MWPhoto photoWithImage:img];
            [photoObject setCaption:@"Locally"];
            
            [self.photos addObject:photoObject];
            [self.selections addObject:[NSNumber numberWithBool:NO]];
            [self.thumbs addObject:[MWPhoto photoWithImage:img]];
        }
        if (photoObject) {
            [self.photosInfo setObject:photoObject forKey:photo.rcoObjectId];
        }
    }
    
    // Create browser
    self.browser = [[MWPhotoBrowserPlus alloc] initWithDelegate:self];
    // new properties
    self.browser.delegatePlus = self;
    self.browser.displayActionButtonAllTheTime = YES;
    self.browser.displayAddButton = YES;
    self.browser.displaySaveButton = YES;
    
    self.browser.displayActionButton = YES;
    self.browser.displayNavArrows = YES;
    //browser.displaySelectionButtons = YES;
    self.browser.alwaysShowControls = YES;
    self.browser.zoomPhotosToFill = YES;
    self.browser.enableGrid = YES;
    if (photos.count) {
        //09.10.2018 we should show the grid
        self.browser.startOnGrid = YES;
    } else {
        // 09.10.2018 we shoul not start with grid
        NSLog(@"");
    }
    self.browser.enableSwipeToDismiss = NO;
    self.browser.autoPlayOnAppear = YES;
    
    self.browser.addDelegateKey = Key_Photos;
    self.browser.addDelegate = self;
    
    [self.browser setCurrentPhotoIndex:0];
    
    if (DEVICE_IS_IPHONE) {
        [self.navigationController pushViewController:self.browser animated:YES];
    } else {
        [self showPopoverModalForViewController:self.browser];
    }
}

-(void)loadExtraInfos {
    [self.values setObject:[NSString stringWithFormat:@"%@ %@", [self.values objectForKey:@"firstName"], [self.values objectForKey:@"lastName"]] forKey:@"employee_name"];
    NSDate *date = [self.values objectForKey:@"dateTime"];
    
    [self.values setObject:[NSString stringWithFormat:@"%@", [[self aggregate] rcoDateToString:date]] forKey:@"incident_date"];
    [self.values setObject:[NSString stringWithFormat:@"%@", [[self aggregate] rcoTimeToString:date]] forKey:@"incident_time"];
    
    if ([[self.values objectForKey:@"injured"] boolValue]) {
        [self.values setObject:[NSString stringWithFormat:@"%@", @"yes"] forKey:@"injury_classification"];
    } else {
        [self.values setObject:[NSString stringWithFormat:@"%@", @"no"] forKey:@"injury_classification"];
    }
}

-(IBAction)previewButtonPressed:(id)sender {
    
    if (!self.header) {
        [self showSimpleMessage:@"Please save the form first!"];
        return;
    }
    
    [self loadExtraInfos];
    
    NSURL *fileURL = nil;
    NSString *tile = nil;
    
    fileURL = [[NSBundle mainBundle] URLForResource:@"CSDAccident" withExtension:@"html"];
    tile = @"CSDAccident";
    
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
    
    NSMutableDictionary *valuesFormatted = [NSMutableDictionary dictionary];
    
    for (NSString *key in self.values.allKeys) {
        id val = [self.values objectForKey:key];
        
        if ([self.switchFields containsObject:key]) {
            if ([val boolValue]) {
                [valuesFormatted setObject:@"YES" forKey:key];
            } else {
                [valuesFormatted setObject:@"NO" forKey:key];
            }
        } else {
            [valuesFormatted setObject:val forKey:key];
        }
    }
    
    //controller.values = self.values;
    controller.values = valuesFormatted;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
        /*
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
         */
    }
}

-(IBAction)possibleReceivedButtonPressed:(id)sender {
}

-(IBAction)startButtonPressed:(id)sender {
}

-(NSString*)getCurrentTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
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


-(IBAction)pauseButtonPressed:(id)sender {
}

-(IBAction)stopButtonPressed:(id)sender {
}

-(void)showSignatureForOption:(NSString*)option {
    /*
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
    */
}

-(void)addSignatureForKey:(NSString*)key {
    /*
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
    if (index != NSNotFound) {
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
    */
}

-(IBAction)emailButtonPressed:(id)sender {
    NSLog(@"");
    [self previewButtonPressed:nil];
}

-(IBAction)signatureButtonPressed:(id)sender {

}

-(IBAction)editButtonPressed:(id)sender {
    self.isEditing = YES;
    [self.saveBtn setEnabled:NO];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, nil];
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

-(IBAction)saveButtonPressed:(id)sender {
    NSString *message = [self validateInputs];
    if (message) {
        [self showSimpleMessage:message];
        return;
    }
    
    if (self.header) {
        self.progressHUD.labelText = @"Update Form...";
    } else {
        self.progressHUD.labelText = @"Create Form...";
    }
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    
    [self performSelector:@selector(createRecord) withObject:nil afterDelay:0.1];
}

-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)createRecord {
    
    BOOL isNewHeader = NO;
    
    if (!self.header) {
        self.header = (AccidentVehicleReport*)[[self aggregate] createNewObject];
        self.header.dateTime = [NSDate date];
        isNewHeader = YES;
        self.header.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
        self.header.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
    }
    
    for (NSString *field in self.fields) {
        id val = [self.values objectForKey:field];
        if (val) {
            if ([self.switchFields containsObject:field]) {
                [self.header setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [self.header setValue:val forKey:field];
            }
        }
    }

    for (NSString *field in self.sectionFields) {
        id val = [self.values objectForKey:field];
        if ([val isKindOfClass:[NSArray class]]) {
            NSLog(@"");
        } else if (val) {
            if ([self.switchFields containsObject:field]) {
                [self.header setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [self.header setValue:val forKey:field];
            }
        }
    }

    
    /*self.header.instructorLastName = self.instructor.lastName;
    /self.header.instructorFirstName = self.instructor.firstName;
    if (self.instructor.employeeId.length) {
        self.header.instructorEmployeeId = self.instructor.employeeId;
    } else {
        self.header.instructorEmployeeId = self.instructor.instructorId;
    }
    
    self.header.studentLastName = self.student.lastName;
    self.header.studentFirstName = self.student.firstName;
*/
    
    [self saveDriverInfo];
    
    [[self aggregate] save];
    [[self aggregate] createNewRecord:self.header];
    /*
    [self addSignatureForKey:TestSignatureDriver];
    [self addSignatureForKey:TestSignatureEvaluator];
    [self addSignatureForKey:TestSignatureCompanyRep];
    */
    
    [self sendAlert:nil];
}

-(void)sendAlert:(NSString*)binNumber {
    
    if (!self.sendAlerts) {
        return;
    }
    
}

-(void)saveDriverInfo {

    NSString *val = [self.values objectForKey:@"firstName"];
    if (val.length) {
        [Settings setSetting:val forKey:CSD_ACCIDENT_DRIVER_FIRST_NAME];
    } else {
        [Settings resetKey:CSD_ACCIDENT_DRIVER_FIRST_NAME];
    }
    val = [self.values objectForKey:@"lastName"];
    if (val.length) {
        [Settings setSetting:val forKey:CSD_ACCIDENT_DRIVER_LAST_NAME];
    } else {
        [Settings resetKey:CSD_ACCIDENT_DRIVER_LAST_NAME];
    }
    val = [self.values objectForKey:@"employeeId"];
    if (val.length) {
        [Settings setSetting:val forKey:CSD_ACCIDENT_DRIVER_EMPLOYEE_ID];
    } else {
        [Settings resetKey:CSD_ACCIDENT_DRIVER_EMPLOYEE_ID];
    }
    val = [self.values objectForKey:@"driverLicenseNumber"];
    if (val.length) {
        [Settings setSetting:val forKey:CSD_ACCIDENT_DRIVER_LICENSE_NUMBER];
    } else {
        [Settings resetKey:CSD_ACCIDENT_DRIVER_LICENSE_NUMBER];
    }
    val = [self.values objectForKey:@"driverLicenseState"];
    if (val.length) {
        [Settings setSetting:val forKey:CSD_ACCIDENT_DRIVER_LICENSE_STATE];
    } else {
        [Settings resetKey:CSD_ACCIDENT_DRIVER_LICENSE_STATE];
    }
    val = [self.values objectForKey:@"driverLicenseExpirationDate"];
    if ([val isKindOfClass:[NSDate class]]) {
        [Settings setSetting:val forKey:CSD_ACCIDENT_DRIVER_LICENSE_EXPIRATION_DATE];
    } else {
        [Settings resetKey:CSD_ACCIDENT_DRIVER_LICENSE_EXPIRATION_DATE];
    }
    val = [self.values objectForKey:@"firstName"];
    if (val.length) {
        // [self.values setObject:val forKey:@"driverLicenseState"];
    } else {
        [Settings resetKey:CSD_ACCIDENT_DRIVER_BIRTH_DATE];
    }
    [Settings save];
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
    
    for (NSString *key in self.requiredFields) {
        NSObject *obj = [self.values objectForKey:key];
        if (!obj) {
            //get the coding field name
            NSInteger index = [self.fields indexOfObject:key];
            if (index != NSNotFound) {
                NSString *fieldName = [self.fieldsNames objectAtIndex:index];
                NSString *message = [NSString stringWithFormat:@"%@ is not set!", fieldName];
                return message;
            } else {
                index = [self.sectionFields indexOfObject:key];
                if (index != NSNotFound) {
                    NSString *fieldName = [self.sectionFieldsNames objectAtIndex:index];
                    NSString *message = [NSString stringWithFormat:@"%@ is not set!", fieldName];
                    return message;
                }
            }
            return nil;
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
    
    NSString *s = [self.sectionFields objectAtIndex:section];
    
    if ([s containsString:@" "]) {
        // this is a "generic name"
        NSArray *arr = [self.parentFields objectForKey:s];
        return arr.count;
    } else {
        if ([self.datePickerFieldsNames containsObject:s]) {
            return 1;
        }
        NSString *val = [self.values objectForKey:s];
        if (![val boolValue]) {
            return 1;
        }
        
        NSArray *arr = [self.parentFields objectForKey:s];
        if (!arr.count) {
            return 1;
        }
        
        return arr.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionFields.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionFieldsNames objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    
    if (@available(iOS 13,*)) {
        [v.textLabel setTextColor:[UIColor labelColor]];
    } else {
        [v.textLabel setTextColor:[UIColor darkTextColor]];
    }

    [v.textLabel setFont:[UIFont boldSystemFontOfSize:12]];
}

- (UITableViewCell *)configureSignaturesForTableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section - self.fields.count - self.detailsNames.count;

    NSString *key = [self.bottomSection objectAtIndex:section];
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"SignatureCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SignatureCell"];
    }
    
    UIImage *img = nil;
    /*
    if ([key isEqualToString:TestSignatureDriver]) {
        img = self.driverSignature;
    } else if ([key isEqualToString:TestSignatureEvaluator]) {
        img = self.evaluatorSignature;
    } else if ([key isEqualToString:TestSignatureCompanyRep]) {
        img = self.compRepSignature;
    }
    */
    
    cell.imageView.image = img;
    cell.textLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = nil;
    NSString *keyName = nil;
    NSString *value = nil;
    
    key = [self.sectionFields objectAtIndex:indexPath.section];
    
    NSArray *arr = [self.parentFields objectForKey:key];
    NSArray *arrNames = [self.parentFieldsNames objectForKey:key];

    if (!arr) {
        value = [self.values objectForKey:key];
    } else {
        key = [arr objectAtIndex:indexPath.row];
    }

    value = [self.values objectForKey:key];
    keyName = [arrNames objectAtIndex:indexPath.row];

    NSString *title = keyName;
    
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
        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"No", @"Yes", nil]];
        seg.tag = keyIndex;
        seg.selectedSegmentIndex = [value integerValue];
        [seg addTarget:self
                action:@selector(segmentedControllerValueChanged:)
      forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = seg;

        /*
         19.08.2019
        UISwitch *sw = [[UISwitch alloc] init];
        sw.tag = keyIndex;
        sw.on = [value boolValue];
        [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        cell.accessoryView = sw;
         */

        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = keyName;
        [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
        cell.imageView.image = nil;
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
            if ([key isEqualToString:@"dateTime"]) {
                cell.textLabel.text = [[self aggregate] rcoDateAndTimeToString:date];
            } else {
                cell.textLabel.text = [[self aggregate] rcoDateToString:date];
            }
        } else {
            cell.textLabel.text = nil;
        }
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:13]];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = requiredLbl;
        cell.imageView.image = [UIImage imageNamed:@"CALENDAR"];

        return cell;
        
    } else if ([self.pickerFields containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"PickerCell"];
        if (!cell) {
            if ([self.pickerInfoFields containsObject:key]) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PickerCell"];
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PickerCell"];
            }
        }
        
        NSString *detailStr = [self getKeyName:key];
        
        if ([self.pickerInfoFields containsObject:key]) {
            cell.textLabel.text = value;
            cell.detailTextLabel.text = nil;
        } else {
            if ([key isEqualToString:Key_State] || [key isEqualToString:Key_DriverLicenseState]) {
                NSString *abbreviation = value;
                value = [RCOObject getStateNameForAbbreviation:abbreviation andFormatted:YES];
            }
            cell.textLabel.text = detailStr;
            cell.detailTextLabel.text = value;
        }
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:13]];

        if (value) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = requiredLbl;
        }
        if ([self.pickerInfoFields containsObject:key]) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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

-(NSString*)getKeyName:(NSString*)key {
    if ([key isEqualToString:Key_Spill_Type]) {
        return @"Type of Spill";
    } else if ([key isEqualToString:Key_Spill_Size]) {
        return @"Size of Spill";
    } else if ([key isEqualToString:Key_Injury_DegreeYour] || [key isEqualToString:Key_Injury_DegreeOthers]) {
        return @"Injury Degree";
    } else if ([key isEqualToString:Key_Accident_Degree]) {
        /*19.08.2019 we should not display the lael also ....
        return @"Accident Degree";
        */
        return nil;
    } else if ([key isEqualToString:Key_Fire_Size]) {
        return @"Fire Size";
    }
    return nil;
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
    }
    
    BOOL isFatilities = NO;
    
    if ([key isEqualToString:@"fatilities"]) {
        isFatilities = YES;
    }

    if (![self parentField:key] && !isFatilities) {
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
    } else {
        CGRect frame = inputCell.titleLabel.frame;
        // hide title label
        frame.size.width = 108;
        frame.origin.x = 10;
        inputCell.titleLabel.frame = frame;
        //resize input field
        frame = inputCell.inputTextField.frame;
        // we should maximize the width
        frame.origin.x = 10 + 108;
        frame.size.width = inputCell.frame.size.width - 108;
        inputCell.inputTextField.frame = frame;
    }

    [inputCell.requiredLabel setHidden:!requiredField];
    
    inputCell.inputTextField.delegate = self;
    
    [inputCell.inputTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    inputCell.inputTextField.tag = indexPath.section;
    
    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    inputCell.inputTextField.text = value;
    inputCell.inputTextField.placeholder = placeholder;
    inputCell.inputTextField.fieldId = key;
    
    inputCell.titleLabel.text = title;
    
    if (isFatilities) {
        // 13.09.2019 workaround to change fatitities from a switch to an input
        inputCell.titleLabel.text = @"Number of fatilities";
    }

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

/*
- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEnded) {
        if (indexPath.section >= (self.fields.count + self.detailsNames.count)) {
            // for signatures we should enable selecting of a row
            return indexPath;
        }
    }
    
    if (indexPath.section >= self.fields.count) {
        // for the questions we should not enable selectiong of a row
        return nil;
    }
    return indexPath;
}
*/

-(void)showTextEditorForKey:(NSString*)key andCell:(UIView*)fromView{
    TextEditorViewController *editor = [[TextEditorViewController alloc] initWithNibName:@"TextEditorViewController"
                                                                                  bundle:nil
                                                                                withText:[self.values objectForKey:key]
                                                                                  forKey:key];;
    editor.addDelegate = self;
    editor.addDelegateKey = key;
    [editor setEditMode:YES];
    NSInteger index = [self.sectionFields indexOfObject:key];
    if (index != NSNotFound) {
        editor.title = [self.sectionFieldsNames objectAtIndex:index];
    } else {
        editor.title = key;
    }
    editor.ignoreNoteRecord = YES;
    
    if (DEVICE_IS_IPHONE) {
        [self.navigationController pushViewController:editor animated:YES];
    } else {
        [self showPopoverForViewController:editor fromView:fromView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    NSString *sectionKey = [self.sectionFields objectAtIndex:indexPath.section];
    NSArray *rows = [self.parentFields objectForKey:sectionKey];
    if (!rows) {
        NSString *key = sectionKey;
        
        if ([key isEqualToString:Key_Accident_Degree]) {
            [self showAccidentDegreePickerFromView:cell];
        }
        else if ([key isEqualToString:Key_Class]) {
            [self showClassPickerFromView:cell];
        }
        else if ([key isEqualToString:Key_State]) {
            [self showDriverLicenseStatePickerFromView:cell andKey:key];
        }
        else if ([key isEqualToString:Key_DriverLicenseState]) {
            [self showDriverLicenseStatePickerFromView:cell andKey:key];
        }
        else if ([key isEqualToString:Key_Incident_Type]) {
            [self showIncidentTypePickerFromView:cell];
        }
        else if ([key isEqualToString:Key_Crash_Type]) {
            [self showCrashTypePickerFromView:cell];
        }
        else if ([key isEqualToString:Key_Severity_Level]) {
            [self showSeverityLevelPickerFromView:cell];
        }
        else if ([key isEqualToString:Key_Chargeble_Determination]) {
            [self showChargebleDeterminationPickerFromView:cell];
        }
        else  if ([self.datePickerFieldsNames containsObject:key]) {
            [self showDatePickerFromView:cell andKey:key];
        }
        else {
            if ([self.pickerInfoFields containsObject:key]) {
                [self showTextEditorForKey:key andCell:cell];
            }
        }
        return;
        NSLog(@"");
    } else {
        // is a subitem
        NSString *key = [rows objectAtIndex:indexPath.row];
        if ([key isEqualToString:Key_Spill_Type]) {
            [self showSpillTypePickerFromView:cell];
        }
        else if ([key isEqualToString:Key_Spill_Size]) {
            [self showSpillSizePickerFromView:cell];
        }
        else if ([key isEqualToString:Key_Injury_DegreeYour] || [key isEqualToString:Key_Injury_DegreeOthers]) {
            [self showInjuryDegreePickerFromView:cell andKey:key];
        }
        else if ([key isEqualToString:Key_Accident_Degree]) {
            [self showAccidentDegreePickerFromView:cell];
        }
        else if ([key isEqualToString:Key_Fire_Size]) {
            [self showFireSizePickerFromView:cell];
        }
    }
    /*
    NSString *key = [self.fields objectAtIndex:indexPath.section];
    if ([key isEqualToString:Key_Class]) {
        [self showClassPickerFromView:cell];
    } else if ([key isEqualToString:Key_Employee]) {
        [self showUserPickerFromView:cell forKey:key];
    } else if ([key isEqualToString:Key_Instructor]) {
        [self showUserPickerFromView:cell forKey:key];
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        [self showDatePickerFromView:cell andKey:key];
    }
    NSLog(@"");
    */
}

-(IBAction)valueChanged:(UISegmentedControl*)sender {
}

-(void)segmentedControllerValueChanged:(UISegmentedControl*)segCtrl {
    
    NSInteger keyIndex = segCtrl.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    NSArray *childItems = [self.parentFields objectForKey:key];
    
    for (NSString *child in childItems) {
        if (!segCtrl.selectedSegmentIndex) {
            [self.disabledFields addObject:child];
            [self.values removeObjectForKey:child];
        } else {
            [self.disabledFields removeObject:child];
        }
    }
    
    [self.values setObject:[NSNumber numberWithInteger:segCtrl.selectedSegmentIndex] forKey:key];
    
    [self enableSaving];
    [self.tableView reloadData];
}

-(void)switchValueChanged:(UISwitch*)aSwitch {
    
    //19.08.2019 changed from switch to segmented controller TODO:REMOVE


    NSInteger keyIndex = aSwitch.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    NSArray *childItems = [self.parentFields objectForKey:key];
    
    for (NSString *child in childItems) {
        if (!aSwitch.on) {
            [self.disabledFields addObject:child];
            [self.values removeObjectForKey:child];
        } else {
            [self.disabledFields removeObject:child];
        }
    }
    
    [self.values setObject:[NSNumber numberWithBool:aSwitch.on] forKey:key];
    
    [self enableSaving];
    [self.tableView reloadData];
}

-(IBAction)infoButtonPressed:(UIButton*)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDriverLicenseStatePickerFromView:(UIView*)fromView andKey:(NSString*)key{
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

- (void)showChargebleDeterminationPickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.accidentChargeableDeterminations
                                                                                                forKey:Key_Chargeble_Determination];
    listController.selectDelegate = self;
    listController.title = @"Chargeble Determination";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *val = [self.values objectForKey:Key_Chargeble_Determination];
    if (val) {
        listController.selectedValue = val;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showSeverityLevelPickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.accidentSeverityLevels
                                                                                                forKey:Key_Severity_Level];
    listController.selectDelegate = self;
    listController.title = @"Severity Level";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *val = [self.values objectForKey:Key_Severity_Level];
    if (val) {
        listController.selectedValue = val;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showCrashTypePickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.accidentCrashTypes
                                                                                                forKey:Key_Crash_Type];
    
    listController.selectDelegate = self;
    listController.title = @"Crash Type";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *val = [self.values objectForKey:Key_Crash_Type];
    if (val) {
        listController.selectedValue = val;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showIncidentTypePickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.accidentIncidentTypes
                                                                                                forKey:Key_Incident_Type];
    
    listController.selectDelegate = self;
    listController.title = @"Incident Type";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *val = [self.values objectForKey:Key_Incident_Type];
    if (val) {
        listController.selectedValue = val;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}


- (void)showSpillSizePickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.sizeOfSpill
                                                                                                forKey:Key_Spill_Size];
    
    listController.selectDelegate = self;
    listController.title = @"Spill Size";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *spillSize = [self.values objectForKey:Key_Spill_Size];
    if (spillSize) {
        listController.selectedValue = spillSize;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showFireSizePickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.sizeOfSpill
                                                                                                forKey:Key_Fire_Size];
    
    listController.selectDelegate = self;
    listController.title = @"Fire Size";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *spillSize = [self.values objectForKey:Key_Fire_Size];
    if (spillSize) {
        listController.selectedValue = spillSize;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}


- (void)showSpillTypePickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.typeOfSpill
                                                                                                forKey:Key_Spill_Type];
    
    listController.selectDelegate = self;
    listController.title = @"Spill Type";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *spillType = [self.values objectForKey:Key_Spill_Type];
    if (spillType) {
        listController.selectedValue = spillType;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showInjuryDegreePickerFromView:(UIView*)fromView andKey:(NSString*)key{
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.injuryAccidentDegree
                                                                                                forKey:key];
    
    listController.selectDelegate = self;
    listController.title = @"Injury Degree";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *degree = [self.values objectForKey:key];
    if (degree) {
        listController.selectedValue = degree;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showAccidentDegreePickerFromView:(UIView*)fromView {
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.injuryAccidentDegree
                                                                                                forKey:Key_Accident_Degree];
    
    listController.selectDelegate = self;
    listController.title = @"Accident Degree";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *spillType = [self.values objectForKey:Key_Accident_Degree];
    if (spillType) {
        listController.selectedValue = spillType;
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
        controller.dateNames = [NSArray arrayWithObject:@"Date&Time"];
        controller.isSimpleDatePicker = NO;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {

    if ([key isEqualToString:Key_Photos_New]) {

    } else if ([self.pickerInfoFields containsObject:key]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:@"dateTime"]) {
        if (object) {
            self.dateTime = (NSDate*)object;
            [self.values setObject:self.dateTime forKey:@"dateTime"];
        }
    } else if ([key isEqualToString:@"driverLicenseExpirationDate"]) {
        if (object) {
            self.driverLicenseExpirationDate = (NSDate*)object;
            [self.values setObject:self.driverLicenseExpirationDate forKey:@"driverLicenseExpirationDate"];
        }
    } else if ([key isEqualToString:@"dotExpirationDate"]) {
        if (object) {
            self.dotExpirationDate = (NSDate*)object;
            [self.values setObject:self.dotExpirationDate forKey:@"dotExpirationDate"];
        }
    } else/* if ([key isEqualToString:TestSignatureDriver]) {
        self.driverSignature = (UIImage*)object;
    } else if ([key isEqualToString:TestSignatureEvaluator]) {
        self.evaluatorSignature = (UIImage*)object;
    } else if ([key isEqualToString:TestSignatureCompanyRep]) {
        self.compRepSignature = (UIImage*)object;
    } else */if ([key isEqualToString:Key_Class]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_Spill_Type]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_Spill_Size]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_Accident_Degree]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_Injury_DegreeYour] || [key isEqualToString:Key_Injury_DegreeOthers]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([key isEqualToString:Key_Fire_Size]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    }  else if ([key isEqualToString:Key_Incident_Type]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    }  else if ([key isEqualToString:Key_Crash_Type]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    }  else if ([key isEqualToString:Key_Severity_Level]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    }  else if ([key isEqualToString:Key_Chargeble_Determination]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    }  else if ([key isEqualToString:Key_DriverLicenseState] || [key isEqualToString:Key_State]) {
        if (object) {
            NSString *state = [RCOObject getStateAbbreviationFromString:(NSString*)object];
            if (state.length) {
                [self.values setObject:state forKey:key];
            } else {
                [self.values setObject:object forKey:key];
            }
        }
    }
    
    if (key && ![key isEqualToString:Key_Preview]) {
        [self enableSaving];
    }
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tableView reloadData];
}

-(void)enableSaving {
    [self.saveBtn setEnabled:YES];
}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentVehicleReport"];
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
    } else if ([message isEqualToString:ACC] ) {
        
        BOOL popAfterFinish = NO;
        
        if (popAfterFinish) {
            if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                [self.addDelegate didAddObject:self.header forKey:self.addDelegateKey];
            }
        } else {
            [self.saveBtn setEnabled:NO];
        }
        [self.progressHUD hide:YES];
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:ACC] ) {
        
        BOOL popAfterFinish = NO;
        
        if (popAfterFinish) {
            if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
            }
        } else {
            [self.saveBtn setEnabled:NO];
        }
        [self.progressHUD hide:YES];
    }
}

#pragma mark Keyboard Methods

- (void)keyboardWillHide:(NSNotification *)notif {
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
}

#pragma mark - MWPhotoBrowserDelegate
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deleteCurrentPhoto:(NSInteger)photoIndex {
    NSLog(@"");
    NSString *msg = nil;
    
    msg = @"Removing current photo!";
    
    [self showSimpleMessageAndHide:msg];
    
    MWPhoto *photo = [self.photos objectAtIndex:photoIndex];
    [self deleteRCOPhotoObjectForPhoto:photo atIndex:photoIndex];
    [self.photos removeObjectAtIndex:photoIndex];
    [self.thumbs removeObjectAtIndex:photoIndex];
    [photoBrowser reloadData];
    
    if (photoIndex < self.photos.count) {
        [photoBrowser setCurrentPhotoIndex:photoIndex];
    } else {
        if (self.photos.count) {
            [photoBrowser setCurrentPhotoIndex:(self.photos.count - 1)];
        }
    }
    
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser resaveCurrentPhoto:(NSInteger)photoIndex {
    NSLog(@"");
    MWPhoto *photo = [self.photos objectAtIndex:photoIndex];
    [self saveRCOPhotoObjectForPhoto:photo];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser resaveAllPhotos:(BOOL)save {
    NSLog(@"");
    //[self syncNow];
}

-(NSString*)getKeyForPhoto:(MWPhoto*)photo {
    if (!photo) {
        return nil;
    }
    NSArray *keys = self.photosInfo.allKeys;
    for (NSString *key in keys) {
        id obj = [self.photosInfo objectForKey:key];
        if (obj == photo) {
            return key;
        }
    }
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser saveNewImages:(BOOL)save {
    NSLog(@"");
    
    NSString *msg = nil;
    
    if (self.photosToSave.count == 1) {
        msg = @"Saving one photo";
    } else if (self.photosToSave.count > 1) {
        msg = [NSString stringWithFormat:@"Saving %d photos", (int)self.photosToSave.count];
    } else {
        msg = @"No photos to save!";
    }
    
    [self showSimpleMessageAndHide:msg];
    
    if (self.photosToSave) {
        PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
        
        for (NSMutableDictionary *imageDict in self.photosToSave) {
            
            UIImage *image = [imageDict objectForKey:@"image"];
            MWPhoto *photo = [imageDict objectForKey:@"object"];
            NSString *key = [self getKeyForPhoto:photo];
            
            if (key) {
                [self.photosInfo removeObjectForKey:key];
            }
            
            Photo *newPhoto = (Photo*)[agg createNewObject];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
            
            newPhoto.name = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            newPhoto.title = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            NSString *category = nil;
            
            newPhoto.category = category;
            
            newPhoto.dateTime = [NSDate date];
            newPhoto.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
            newPhoto.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
            
            newPhoto.itemType = ItemTypePhoto;
            
            if ([self.header existsOnServerNew]) {
                newPhoto.parentObjectId = self.header.rcoObjectId;
                newPhoto.parentObjectType = self.header.rcoObjectType;
                newPhoto.parentBarcode = self.header.rcoBarcode;
            } else {
                newPhoto.parentObjectId = self.header.rcoObjectId;
                newPhoto.parentObjectType = self.header.rcoObjectClass;
                newPhoto.parentBarcode = nil;
                // add the link of the new photo to the photo parent record
                [self.header addLinkedObject:newPhoto.rcoMobileRecordId];
                [[self aggregate] save];
            }
            
            [newPhoto setContentNeedsUploading:YES];
            [newPhoto setFileNeedsUploading:[NSNumber numberWithBool:YES]];
            
            [agg save];
            [agg registerForCallback:self];
            [agg createNewRecord:newPhoto];
            
            /*16.03.2018 we will not resize the image, we will save as jpeg and set compressio ration at half
             NSData *imageData = UIImagePNGRepresentation(image);
             */
            
            // compression is 0(most)..1(least)
            double compression = 0.5;
            
            [imageDict setObject:newPhoto.rcoMobileRecordId forKey:@"objectId"];
            NSData *imageData = UIImageJPEGRepresentation(image, compression);
            NSURL *fileURL = [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeForUpload];
            
            BOOL saveThumbnail = YES;
            if (saveThumbnail) {
                CGSize size = CGSizeMake([kImageSizeThumbnailSize integerValue], [kImageSizeThumbnailSize integerValue]);
                image = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
                NSData *imageData = UIImageJPEGRepresentation(image, compression);
                [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeThumbnailSize];
            }
            
            
            // TODO reload the photos ... to add the new objects
            [self.photosInfo setObject:photo forKey:newPhoto.rcoObjectId];
            [photo setCaption:@"Locally"];
        }
        self.photosToSave = [NSMutableArray array];
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser newImageAdded:(UIImage*)image {
    
    BOOL resizeImage = YES;
    
    // 31.01.2018 taking a photo sometines was returning a image that was not orientated correctly
    image = [image rotateImage:image];
    
    resizeImage = NO;
    
    if (resizeImage) {
        CGSize size = CGSizeMake(640, 640);
        image = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
    }
    
    if (image) {
        MWPhoto *photoObject = [MWPhoto photoWithImage:image];
        [photoObject setCaption:@"Not Saved"];
        
        [self.photos addObject:photoObject];
        [self.selections addObject:[NSNumber numberWithBool:NO]];
        [self.thumbs addObject:[MWPhoto photoWithImage:image]];
        if (!self.photosToSave) {
            self.photosToSave = [NSMutableArray array];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:image forKey:@"image"];
        [dict setObject:photoObject forKey:@"object"];
        [self.photosToSave addObject:dict];
        if (!self.photosInfo) {
            self.photosInfo = [NSMutableDictionary dictionary];
        }
        NSString *key = [NSString stringWithFormat:@"%d*", (int)(self.photos.count -1)];
        [self.photosInfo setObject:photoObject forKey:key];
    }
    [photoBrowser reloadData];
    if (self.photos.count) {
        [photoBrowser setCurrentPhotoIndex:(self.photos.count - 1)];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)deleteRCOPhotoObjectForPhoto:(MWPhoto*)photo atIndex:(NSInteger)photoIndex{
    NSLog(@"");
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    NSArray *keys = [self.photosInfo allKeysForObject:photo];
    
    if (keys.count) {
        NSString *rcoObjectId = [keys objectAtIndex:0];
        RCOObject *photoObj = nil;
        
        if ([rcoObjectId containsString:@"-"]) {
            // we should check if we saved using the mobileRecordId
            photoObj = [agg getObjectMobileRecordId:rcoObjectId];
        } else {
            photoObj = [agg getObjectWithId:rcoObjectId];
        }
        
        if (photoObj) {
            [agg destroyObj:photoObj];
        } else {
            // this is the image from the imaes to save
            for (NSDictionary *photoInfo in self.photosToSave) {
                
                id obj = [photoInfo objectForKey:@"object"];
                if (obj == photo) {
                    [self.photosToSave removeObject:photoInfo];
                    continue;
                }
            }
        }
        [self.photosInfo removeObjectForKey:rcoObjectId];
    }
}

-(void)saveRCOPhotoObjectForPhoto:(MWPhoto*)photo {
    NSLog(@"");
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    NSArray *keys = [self.photosInfo allKeysForObject:photo];
    if (keys.count) {
        NSString *rcoObjectId = [keys objectAtIndex:0];
        RCOObject *photoObj = [agg getObjectWithId:rcoObjectId];
        photoObj.fileIsDownloading = nil;
        photoObj.fileIsUploading = nil;
        photoObj.fileNeedsDownloading = nil;
        photoObj.fileNeedsUploading = [NSNumber numberWithBool:YES];
        
        photoObj.objectIsDownloading = nil;
        photoObj.objectIsUploading = nil;
        photoObj.objectNeedsDownloading = nil;
        photoObj.objectNeedsUploading = [NSNumber numberWithBool:YES];
        
        // we should enable uploading the thumbnail
        photoObj.fileLog = nil;
        [agg save];
        [agg registerForCallback:self];
        [agg createNewRecord:photoObj];
        [self.photosInfo removeObjectForKey:rcoObjectId];
        [self.photosInfo setObject:photo forKey:photoObj.rcoObjectId];
    }
}


@end

