 //
//  DataRepository.m
//  Billing
//
//  Created by Herman on 2011-04-04.
//  Copyright 2011 RCO Software. All rights reserved.
//

#import "DataRepository.h"
#import "UIUtility.h"
#import "BillingAppDelegate.h"
#import "Settings.h"

#import "StaffAggregate.h"

#import "PhotosAggregate.h"

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "NSManagedObjectContext+Timing.h"
#import "Aggregate.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"
#import "NSDate+TKCategory.h"

#import "HTTPClient.h"
#import "HttpClientOperation.h"

#import <CoreMotion/CoreMotion.h>

#import "NotesAggregate.h"
#import "AttachmentAggregate.h"



#import "TestDataHeaderAggregate.h"
#import "TestDataDetailAggregate.h"
#import "TestFormAggregate.h"
#import "TestSetupAggregate.h"
#import "TrainingDriverStudentAggregate.h"
#import "TrainingDriverInstructorAggregate.h"
#import "DriverTurnsAggregate.h"
#import "SignatureDetailAggregate.h"
#import "EyeMovementAggregate.h"
#ifdef APP_CSD
#import "CSDVehicleAccidentReportAggregate.h"
#import "CSDAccidentVehicleAggregate.h"
#import "CSDAccidentTrailerDollieAggregate.h"
#import "CSDAccidentWitnessAggregate.h"
#import "TrainingCompanyAggregate.h"
#ifndef APP_CSD_ACCIDENT
#import "TrainingBreakLocationAggregate.h"
#import "TrainingEquipmentAggregate.h"
#import "TrainingEquipmentReviewedAggregate.h"
#import "TrainingTestInfoAggregate.h"
#import "TrainingScoreAggregate.h"
#import "DriverMedicalFormAggregate.h"
#endif
#endif

//Static reference to return Singleton instance
static DataRepository *_sharedRepository = nil;

#define IDLE_TIME_MAX 60

#define TAG_IDLE_MESSAGE -77888
#define TAG_MALFUNCTION_MESSAGE -77889
#define TAG_DEVICE_CONNECTED -77890

#define WorkOffLineNotSet -1

@interface DataRepository() 

+(id)hiddenAlloc;

-(void) initUser:(BOOL)sameUser;
-(void) finishInit;

// syncing local data with cloud for current user
@property (readwrite, strong) NSString* userNameRCO;
@property (readwrite, strong) NSString* userPasswordRCO;
@property (readwrite, strong) NSString* userIdRCO;
@property (readwrite, strong) NSString* userTypeRCO;
@property (readwrite, strong) NSString* userRecordIdRCO;
@property (readwrite, strong) NSString* userEmployeeIdRCO;
@property (readwrite, strong) NSString* userFirstNameRCO;
@property (readwrite, strong) NSString* userLastNameRCO;
@property (readwrite, assign) NSInteger workOfflineRCO;
@property (readwrite, strong) NSString *mobileDeviceIDRCO;
@property (readwrite, strong) NSString *orgNumberRCO;
@property (readwrite, strong) NSString *orgNameRCO;
@property (readwrite, assign) BOOL isSameUser;

@property (readwrite, strong) NSNumber* sendGPSLocation;
@property (readwrite, strong) NSURL* dataDirRCO;

@property (readwrite, strong) NSString* serverRCO;

@property (readwrite, strong) NSArray* userRightsRCO;

@property (nonatomic, readwrite, strong) NSMutableArray * aggregates;

@property (readwrite, strong) PhotosAggregate *photosAggregate;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) UIAlertView *alert;

@property (assign) Boolean usePackagedDatabase;

@property (nonatomic, assign) BOOL isFullSync;
@property (nonatomic, assign) BOOL isOneSyncFinished;
@property (nonatomic, assign) BOOL isOverrideSyncOptions;

// user to update records
@property (nonatomic, strong) NSTimer *updateRecordsTimer;
@property (nonatomic, strong) NSTimer *updateTruckGPSPositionTimer;
@property (nonatomic, strong) NSTimer *autoSyncTimer;
// background Mode

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, retain) NSTimer *backgroundTimer;

@property (nonatomic, assign) BOOL useBackgroundTask;


@property (nonatomic, strong) NSMutableDictionary *locationInfo;
@property (nonatomic, assign) NSInteger prevRecordingTime;


@property (nonatomic, assign) NSInteger previousState;

@property (nonatomic, assign) BOOL messageShown;

// work offline flow

@property (nonatomic, assign) BOOL isForcedSync;
@property (nonatomic, assign) BOOL isAutoSync;
@property (nonatomic, assign) BOOL isAutoSyncAlert;

@property (nonatomic, strong) NSMutableArray *TEST_LatLon;

@property (nonatomic, assign) BOOL isTesting;


@property (nonatomic, assign) NSInteger trainingInfo;
@property (nonatomic, assign) NSInteger trainingInfoStatus;
@property (nonatomic, strong) NSMutableArray *trainingInfoPositions;

@end

#define kAPIFormatStringNoParams @"%@/CSD/WEB/API/%@/%@/%@/%@"
#define kAPIFormatString         @"%@/CSD/WEB/API/%@/%@/%@/%@/%@"



@implementation DataRepository

// OBD2
#ifdef APP_CSD
NSArray *pids;
#else
#ifdef WATER
NSArray *pids;
#else
NSArray<COBDParameter*> *pids;
#endif
#endif
NSMutableArray<NSNumber*> *values;
uint64_t uses;
//

@synthesize managedObjectContext;
@synthesize managedObjectModel=m_managedObjectModel;
@synthesize persistentStoreCoordinator=m_persistentStoreCoordinator;

@synthesize aggregates=m_aggregates;


@synthesize userName, userPassword;
@synthesize userId = m_userId, server = m_server, userType, userRecordId, sendGPSLocation, userFirstName = m_userFirstName, userLastName = m_userLastName;
@synthesize functionalRecordTypeMap;
@synthesize userRights = m_userRights;

@synthesize isLoggedIn=m_isLoggedIn;
@synthesize syncOptions=m_syncOptions;
@synthesize networkOptions =m_networkOptions;
@synthesize networkStatus=m_networkStatus;

@synthesize syncStatus=m_syncStatus;
@synthesize syncStatusDescription;
@synthesize statusDict =m_statusDict;
@synthesize internetReach=m_internetReach;
@synthesize hostReach=m_hostReach;
@synthesize currentStoreNumber;

@synthesize latitude = _lat;
@synthesize longitude = _long;

@synthesize masterSaveContext = _masterSaveContext;
@synthesize mainThreadContex = _mainThreadContex;

#pragma mark Singleton Methods

+ (DataRepository *)sharedInstance {
	@synchronized(self) {
        if (_sharedRepository == nil) {
			_sharedRepository = [[DataRepository hiddenAlloc] init];
            
            [_sharedRepository finishInit];
            _sharedRepository.backgroundTask = UIBackgroundTaskInvalid;
            _sharedRepository.useBackgroundTask = YES;
            _sharedRepository.workOfflineRCO = -1;
        
            if (_sharedRepository.useBackgroundTask) {
                [[NSNotificationCenter defaultCenter] addObserver:_sharedRepository
                                                         selector:@selector(reinstateBackgroundTask)
                                                             name:UIApplicationDidEnterBackgroundNotification
                                                           object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:_sharedRepository
                                                         selector:@selector(endBackgroundTask)
                                                             name:UIApplicationDidBecomeActiveNotification
                                                           object:nil];
                
            }
            
            _sharedRepository.isTesting = YES;
            _sharedRepository.trainingInfo = -1;
            [Settings save];
        }
    }

    return _sharedRepository;
}

+(BOOL)isIphonePlus {
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
            case 1920:
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                return YES;
                break;
            case 2436:
                printf("iPhone X, Xs");
                return YES;
                break;
            case 2688:
                printf("iPhone Xs Max");
                return YES;
            case 1792:
                printf("iPhone Xr");
                return YES;
            default:
                printf("unknown");
        }
    }
    return NO;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
}


#pragma mark Background Methods

-(void)stopBackgroundTimer {
    [self.backgroundTimer invalidate];
}

-(void)reinstateBackgroundTask {
    if (!self.useBackgroundTask) {
        return;
    }
    
    if /*((self.backgroundTimer != nil) && */(self.backgroundTask == UIBackgroundTaskInvalid)/*)*/ {
        [self registerBackgroundTask];
    }
}

-(void)registerBackgroundTask {
}


-(void)endBackgroundTask {
}

#pragma mark End Background Methods


// Overidden Methods to prevent multiple instances from being created
+ (id)hiddenAlloc {
	return [super allocWithZone:NULL];
}

+ (id)alloc {
	if (_sharedRepository != nil) {	
	}
	return nil;	
}

+ (id)new {
	if (_sharedRepository != nil) {	
	}
	return [self alloc];
}

+ (id)allocWithZone:(NSZone *)zone {
	return [self alloc];
}

+ (id)copyWithZone:(NSZone *)zone {
	return self;
}

-(void)dealloc {
    [self unsubscribeFromNetworkReachabilityNotifications];
    currentStoreNumber = nil;
    self.functionalRecordTypeMap = nil;
}

#pragma mark -
#pragma mark Data Initialization


- (void) finishInit
{    
    [self registerForNetworkReachabilityNotifications];
    
    [self resetStatus];
    
    self.syncStatus = SYNC_STATUS_NONE;
    
    self.currentStoreNumber = [Settings getSetting:DEFAULT_STORE];
    self.usePackagedDatabase = true;
}

-(void)initLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.headingFilter = kCLHeadingFilterNone;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
        [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
}


-(BOOL)isRightAvailable:(NSString*)right {
    if ([self.userRights containsObject:right]) {
        return YES;
    }
    return NO;
}

- (void)loadUserAggregates {
            
    [self initLocationManager];
    
    if ([self.aggregates count] == 0 ){
        [self managedObjectContext];
        
        NSMutableArray *aggArray = [NSMutableArray array];
        
        self.aggregates = [NSMutableArray array];
        
        NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
        
        if ([targetName isEqualToString:@"CSD"] || [targetName isEqualToString:@"Accident Form"]) {
                        
            StaffAggregate *staffAggregate = [[StaffAggregate alloc] initAggregateWithRights:self.userRights];
            if ([staffAggregate isAvailableToUser: self.userRights]) {
                [staffAggregate setShowErrorMessages:YES];
                [aggArray addObject:staffAggregate];
            }
                        
            TestDataHeaderAggregate *testAgg = [[TestDataHeaderAggregate alloc] initAggregateWithRights:self.userRights];
            if ([testAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:testAgg];
            }

            TestFormAggregate *testFormAgg = [[TestFormAggregate alloc] initAggregateWithRights:self.userRights];
            if ([testFormAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:testFormAgg];
            }
            
            TestSetupAggregate *testSetupAgg = [[TestSetupAggregate alloc] initAggregateWithRights:self.userRights];
            if ([testSetupAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:testSetupAgg];
            }

            NotesAggregate *notesAgg = [[NotesAggregate alloc] initAggregateWithRights:self.userRights];
            if ([notesAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:notesAgg];
            }

            TrainingDriverStudentAggregate *tdsAgg = [[TrainingDriverStudentAggregate alloc] initAggregateWithRights:self.userRights];
            if ([tdsAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:tdsAgg];
            }

            TrainingDriverInstructorAggregate *tdiAgg = [[TrainingDriverInstructorAggregate alloc] initAggregateWithRights:self.userRights];
            if ([tdiAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:tdiAgg];
            }

            DriverTurnsAggregate *dtAgg = [[DriverTurnsAggregate alloc] initAggregateWithRights:self.userRights];
            if ([dtAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:dtAgg];
            }
            
            EyeMovementAggregate *emAgg = [[EyeMovementAggregate alloc] initAggregateWithRights:self.userRights];
            if ([emAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:emAgg];
            }
            
            AttachmentAggregate *attAgg = [[AttachmentAggregate alloc] initAggregateWithRights:self.userRights];
            if ([attAgg isAvailableToUser:self.userRights]) {
                [aggArray addObject:attAgg];
            }
            
#ifdef APP_CSD
#ifndef APP_CSD_ACCIDENT
            DriverMedicalFormAggregate *dmfAgg = [[DriverMedicalFormAggregate alloc] initAggregateWithRights:self.userRights];
            if ([dmfAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:dmfAgg];
            }
#endif
#endif
                
            self.photosAggregate = [[PhotosAggregate alloc] initAggregateWithRights:self.userRights];
            [aggArray addObject:self.photosAggregate];
            
#ifdef APP_CSD
            CSDVehicleAccidentReportAggregate *var = [[CSDVehicleAccidentReportAggregate alloc] initAggregateWithRights:self.userRights];
            if ([var isAvailableToUser: self.userRights]) {
                [aggArray addObject:var];
            }
            
            CSDAccidentVehicleAggregate *avAgg = [[CSDAccidentVehicleAggregate alloc] initAggregateWithRights:self.userRights];
            if ([avAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:avAgg];
            }

            CSDAccidentTrailerDollieAggregate *tdAgg = [[CSDAccidentTrailerDollieAggregate alloc] initAggregateWithRights:self.userRights];
            if ([tdAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:tdAgg];
            }
            
            CSDAccidentWitnessAggregate *wtaAgg = [[CSDAccidentWitnessAggregate alloc] initAggregateWithRights:self.userRights];
            if ([wtaAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:wtaAgg];
            }

            TrainingCompanyAggregate *tcAgg = [[TrainingCompanyAggregate alloc] initAggregateWithRights:self.userRights];
            if ([tcAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:tcAgg];
            }
#ifndef APP_CSD_ACCIDENT
            TrainingBreakLocationAggregate *tblAgg = [[TrainingBreakLocationAggregate alloc] initAggregateWithRights:self.userRights];
            if ([tblAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:tblAgg];
            }

#endif
#ifndef APP_CSD_ACCIDENT
            TrainingEquipmentAggregate *teAgg = [[TrainingEquipmentAggregate alloc] initAggregateWithRights:self.userRights];
            if ([teAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:teAgg];
            }
            
            TrainingEquipmentReviewedAggregate *terAgg = [[TrainingEquipmentReviewedAggregate alloc] initAggregateWithRights:self.userRights];
            if ([terAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:terAgg];
            }
            
            TrainingTestInfoAggregate *ttiAgg = [[TrainingTestInfoAggregate alloc] initAggregateWithRights:self.userRights];
            if ([ttiAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:ttiAgg];
            }
            TrainingScoreAggregate *tsAgg = [[TrainingScoreAggregate alloc] initAggregateWithRights:self.userRights];
            if ([tsAgg isAvailableToUser: self.userRights]) {
                [aggArray addObject:tsAgg];
            }
#endif
#endif
        }
        
        NSInteger index = 0;
        for( Aggregate *agg in aggArray ) {
            
            if ([self skipAggSync:agg]) {
                continue;
            }
            
            for(Aggregate *detail in agg.detailAggregates) {
                [self.aggregates addObject:detail];
                [detail registerForCallback:self];
                for (Aggregate *detailOfDetail in detail.detailAggregates) {
                    [self.aggregates addObject:detailOfDetail];
                    [detailOfDetail registerForCallback:self];
                }
            }
            [self.aggregates addObject:agg];
            [agg registerForCallback:self];
            
            index++;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationLoaded" object:nil];
    }
    
    [self syncStart];
    
}

-(BOOL)currentUserIsDriver {
    return [[self loggedUserUserType] isEqualToString:kUserTypeDriver];
}

-(NSString*)loggedUserRecordId {
    return self.loggedUser.rcoRecordId;
}

-(NSString*)loggedUserUserType {
    NSString *itemType = nil;
    if ([[NSThread currentThread] isMainThread]) {
        itemType = self.loggedUser.itemType;
    }
    
    if ([itemType length] == 0) {
        itemType = [Settings getSetting:USER_TYPE];
    }
    
    return itemType;
}



- (void) startUnloadingUserAggregates: (id<DatabaseControlDelegate>) caller returnMsg: (NSString *) msg {
    
    NSDictionary *callerDict = [NSDictionary dictionaryWithObjectsAndKeys:caller, @"caller", msg, @"returnMsg", nil];
                          
    // remove previous added delegates
    if ([self.aggregates count] > 0 ){
        // first kill any requests
        [self syncPause];
        
        for(  Aggregate *agg in self.aggregates ) {
            for(Aggregate *detail in agg.detailAggregates) {
                [detail unRegisterForCallback:self];
            }
            [agg unRegisterForCallback:self];
        }
        Aggregate *agg = [self.aggregates objectAtIndex:0];
        
        [agg performSelectorInBackground:@selector(shutdownThreads:) withObject:callerDict];
        
    }
    else {
        [self finishUnloadingUserAggregates: callerDict];
    }
}

- (void) finishUnloadingUserAggregates: (NSDictionary *) callerDict {
    
    [self.aggregates removeAllObjects];
    
    self.photosAggregate = nil;
    self.managedObjectContext = nil;
    m_persistentStoreCoordinator = nil;
    
    id<DatabaseControlDelegate> caller = [callerDict objectForKey:@"caller"];
    
    [caller finishedUnloadingUserAggregates: [callerDict objectForKey:@"returnMsg"]];
}


-(void) initSameUser {

}

-(User*)getUserLoggedIn {
    if ([self.loggedUser.rcoObjectId length]) {
        return self.loggedUser;
    } else {
        [self loadCurrentLoggedUser];
    }
    
    return self.loggedUser;
}

-(UserAggregate*)getUserAggregateAvailable {
    for (Aggregate *agg in self.aggregates) {
        if ([agg isKindOfClass:[UserAggregate class]]) {
            return (UserAggregate*)agg;
        }
    }
    return nil;
}

-(UserAggregate*)getUserAggregateAvailablePlus {
    // 10.04.2018 added this for trying to fix the issue regarding the user that was null
    for (Aggregate *agg in self.aggregates) {
        if ([agg isKindOfClass:[UserAggregate class]]) {
            return (UserAggregate*)agg;
        }
    }
    return nil;
}

-(NSArray*)DEBUG_getUserAggregateAvailableInfos {
    NSMutableArray *res = [NSMutableArray array];
    
    for (Aggregate *agg in self.aggregates) {
        if ([agg isKindOfClass:[UserAggregate class]]) {
            if (agg.rcoObjectClass) {
                [res addObject:agg.rcoObjectClass];
            }
        }
    }
    return res;
}

-(void)loadCurrentLoggedUser {
    
    UserAggregate *agg = [self getUserAggregateAvailable];
    
    if ([self.userRecordId length]) {
        self.loggedUser = [agg getAnyUserWithRecordId:self.userRecordId];
        if (!self.loggedUser) {
            agg = [self getUserAggregateAvailablePlus];
            self.loggedUser = [agg getAnyUserWithRecordId:self.userRecordId];
        }
    } else if ([self.userId length]) {
        self.loggedUser = [agg getAnyUserWithObjectId:self.userId];
    }
}

-(void) initUser:(BOOL)sameUser
{
    self.networkOptions = [Settings getSettingAsDictionary:kUserNetworkSyncOptionsKey];
    self.syncOptions = [NSMutableDictionary dictionaryWithDictionary:[Settings getSettingAsDictionary:kDataSyncOptionsKey]];
    
    self.isOverrideSyncOptions = false;
    
    [self loadDataDir];
    
    if ([[self.syncOptions valueForKey:kDataSyncManuallyKey] boolValue] && sameUser) {
        // if is manually sync then we should skip the get user rights, functional group, group map, device id...
        self.syncStatus = SYNC_STATUS_USER_COMPLETE;
        [self loadUserAggregates];
    } else {
        // set up the user info
        if (([self workOffline] || ![self isNetworkReachable]) && !self.isForcedSync && sameUser) {
            self.syncStatus = SYNC_STATUS_USER_COMPLETE;
            [self loadUserAggregates];
        } else {
            [self getUserInfo];
        }
    }
}

-(void)resetHistoryFields {
    //2020.02.06 reset the "history" related to the previous logged in user
    [Settings resetKey:CSD_PREV_STUDENT];
    [Settings resetKey:CSD_PREV_INSTRUCTOR];
    [Settings resetKey:CSD_TEST_PAUSED_DATE];
    [Settings resetKey:CSD_TEST_INFO_START_DATE];
    [Settings resetKey:CSD_TEST_INFO_STOP_DATE];
    [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
    [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID_DATE];
    [Settings resetKey:CSD_TEST_INFO_ENDORSEMENTS];
    [Settings resetKey:CSD_TEST_INFO_LOCATION];
    [Settings resetKey:CSD_TEST_INFO_POWER_UNIT];
    [Settings resetKey:CSD_TEST_INFO_DOT_EXPIRATION_DATE];
    [Settings resetKey:CSD_TEST_INFO_HISTORY_REVIEWED];
    [Settings resetKey:CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED];
    [Settings resetKey:CSD_TEST_INFO_LICENSE_CLASS];
    [Settings resetKey:CSD_TEST_INFO_START_DATE];
    [Settings resetKey:CSD_TEST_INFO_STOP_DATE];
    [Settings resetKey:CSD_TEST_INFO_END_DATE];
    [Settings resetKey:CSD_TEST_GROUP_MEMBERS];
    [Settings resetKey:CSD_TEST_GROUP_NAME];
    [Settings resetKey:CSD_TEST_GROUP_RECORDID];
    [Settings resetKey:CSD_TEST_INFO_PAUSE_DATE];
    [Settings resetKey:CSD_TEST_INFO_PAUSE_DATE];
    [Settings save];
}

-(void) setUser: (NSString*) newUserName withPassword: (NSString*) newPassword andServer: (NSString *) newServer
{
    self.isSameUser = YES;
    
    if(! ([newUserName isEqualToString: self.userName] &&
          [newPassword isEqualToString:self.userPassword] && 
          [newServer isEqualToString:self.server]))
    {
        self.mobileDeviceIDRCO = nil;
        [Settings switchToUser:newUserName withPassword:newPassword andServer:newServer];
        self.isSameUser = NO;
    }
    
    // reset
    [self setUserName:newUserName];
    [self setUserPassword:newPassword];
    [self setServer:newServer];
    
    if (!self.isSameUser) {
        //30.10.2018 reset variables from memory ...
        self.userRightsRCO = nil;
        self.userIdRCO = nil;
        self.userTypeRCO = nil;
        self.userRecordIdRCO = nil;
        self.userEmployeeIdRCO = nil;
        self.userFirstNameRCO = nil;
        self.userLastNameRCO = nil;
        self.userLastNameRCO = nil;
        [self resetHistoryFields];
    }
    
    self.isLoggedIn = YES;
    [self syncStop];
    
    // set up the user info
    [self initUser:self.isSameUser];
}

-(void)setCurrentStoreNumber:(NSString *)newStoreNumber {
    [Settings setSetting:newStoreNumber forKey:DEFAULT_STORE];
    [Settings save];
    currentStoreNumber = newStoreNumber;
}

#pragma mark -
#pragma mark Login

// user information
- (void) getUserInfoWithSyncOverride {
    
    self.isOverrideSyncOptions = true;
    [self getUserInfo];
}
// user information
- (void) getUserInfo {

    [self getDatabaseNodeInfo];
    
    [self getAccountingSetupNodeInfo];
    
    self.syncStatus = SYNC_STATUS_USER_ID;
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: S_G_U_I
                                         withParams: nil
                                          andObject: nil
                                         callBackTo: self];
    return;
}


-(void)sendSMS:(NSString*)sms toFunctionalGroup:(NSString*)functionalGroupName {
}
-(NSString*)getRecentCityLocator {
    return nil;
}


// record Coding
- (void) getUserRecordCoding:(NSString*)objectId  objectType:(NSString*)objectType

{
    if( self.syncStatus != SYNC_STATUS_USER_CODING-1 )
        return;
    
    self.syncStatus++;
    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: R_G_C_1
                                         withParams:[NSString stringWithFormat: @"%@/%@",objectId, objectType]
                                          andObject: objectId
                                         callBackTo: self];
    
    return;
}

-(void)getUserRights
{
    if( self.syncStatus != SYNC_STATUS_USER_RIGHTS-1 )
        return;
    
    self.syncStatus++;
    
    [self askTheCloudFor: S_S
                 withMsg: S_C_R
              withParams: @""
               andObject: nil
              callBackTo:self];
    
}


- (void) getFunctionalGroupMembers {
    
    if( self.syncStatus != SYNC_STATUS_USER_FUNCTIONAL_MEMBERS-1 )
        return;
    
    self.syncStatus++;
    
        [self getFunctionalGroupMap];
    
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: US_G_F_G_M
                                         withParams: nil
                                          andObject: nil
                                         callBackTo: self];
}

- (void) getFunctionalGroupMap {
    if( self.syncStatus != SYNC_STATUS_USER_FUNCTIONAL_MAP-1 )
        return;
    
    self.syncStatus++;
    
    BOOL shouldGetDeviceId = YES;
    
    if( ! (shouldGetDeviceId ) ) {
        [self getDeviceId];
        return;
    }
    
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: US_G_F_G_MA
                                         withParams: nil
                                          andObject: nil
                                         callBackTo: self];
    
}

- (void) getDeviceId {
    if( self.syncStatus != SYNC_STATUS_USER_DEVICE_ID-1 )
        return;
    
    self.syncStatus++;
    
    BOOL shouldGetDeviceId = YES;

    shouldGetDeviceId = YES;
    
    if( ! /*([self.userRights containsObject:kInvoicesRight])*/shouldGetDeviceId ) {
        self.syncStatus = SYNC_STATUS_USER_COMPLETE;
        [self loadUserAggregates];
        return;
    }
    
    NSString *deviceId = [self deviceId];

    if (deviceId.length == 0) {
        [self askTheCloudFor: M_S
                     withMsg: M_G_D_I
                  withParams: @""
                   andObject: nil
                  callBackTo:self];
    } else {
        NSLog(@"deviceId already set to: %@", deviceId);
        
        self.syncStatus = SYNC_STATUS_USER_COMPLETE;
        [self loadUserAggregates];
    }
}


- (Boolean) emailPassword: (NSString *) uName
{
// TODO
    return true;
    
}

#pragma mark - User Info Setter/Getters
- (NSString *) userName
{
    if (!self.userNameRCO.length) {
        self.userNameRCO = [Settings getSetting:CLIENT_LOGIN_KEY];
    }
    return self.userNameRCO;
}

-(NSString *)getLoggedUserRecordId {
    
    if ([self.userRecordIdRCO length]) {
        return self.userRecordIdRCO;
    } else {
        return [Settings getSetting:CLIENT_USER_RECORDID_KEY];
    }
}

-(NSString*)getLoggedUserLastName {
    if ([self.userLastNameRCO length]) {
        return self.userLastNameRCO;
    } else {
        return [Settings getSetting:CLIENT_USER_LAST_NAME_KEY];
    }
}

-(NSString*)getLoggedUserFirstName {
    if ([self.userFirstNameRCO length]) {
        return self.userFirstNameRCO;
    } else {
        return [Settings getSetting:CLIENT_USER_FIRST_NAME_KEY];
    }
}

-(NSString*)getLoggedUserLogin {
    return self.userName;
}

-(NSString *)getLoggedUserEmployeeId {
    
    if ([self.userEmployeeIdRCO length]) {
        return self.userEmployeeIdRCO;
    } else {
        return [Settings getSetting:CLIENT_USER_EMPLOYEEID_KEY];
    }
}

- (void) setUserName:  (NSString *) uName
{
    self.userNameRCO = uName;
    [Settings setSetting: uName forKey:CLIENT_LOGIN_KEY];
    [Settings save];
}

- (NSString *) userPassword
{
    if (!self.userPasswordRCO.length) {
        self.userPasswordRCO = [Settings getSetting:CLIENT_PASSWORD_KEY];
    }
    return self.userPasswordRCO;
}

- (void) setUserPassword:  (NSString *) pwd
{
    self.userPasswordRCO = pwd;
    [Settings setSetting: pwd forKey:CLIENT_PASSWORD_KEY];
    [Settings save];
}

- (NSString *) server
{
    if (!self.serverRCO.length) {
        self.serverRCO = [Settings getSetting:SERVER_URL_KEY];
    }
    return self.serverRCO;
}

- (void) setServer:(NSString *)svr
{
    self.serverRCO = svr;
    [Settings setSetting: svr forKey:SERVER_URL_KEY];
    [Settings save];
}

- (NSString *) userId
{
    //return [Settings getSetting:CLIENT_USERID_KEY];
    if (!self.userIdRCO.length) {
        self.userIdRCO = [Settings getSetting:CLIENT_USERID_KEY];
    }
    return self.userIdRCO;
}


- (void) setUserId:  (NSString *) uid
{
    self.userIdRCO = uid;
    [Settings setSetting: uid forKey:CLIENT_USERID_KEY];
    [Settings save];
}

- (NSArray *) userRights
{
    if (!self.userRightsRCO.count) {
        self.userRightsRCO = [Settings getSettingAsArray:CLIENT_RIGHTS_KEY];
    }
    return self.userRightsRCO;
}

- (void) setUserRights: (NSArray *) rights
{
    self.userRightsRCO = rights;
    [Settings setSetting:rights forKey:CLIENT_RIGHTS_KEY];
    [Settings save];
}

- (NSDictionary *) functionalRecordTypeMap
{
    return [Settings getSettingAsDictionary:FUNCTIONALGROUP_RECORD_TYPE_MAP];
}

- (void) setFunctionalRecordTypeMap: (NSDictionary *) theMap
{
    [Settings setSetting:theMap forKey:FUNCTIONALGROUP_RECORD_TYPE_MAP];
    [Settings save];
}



#pragma mark -
#pragma mark US
// login information
- (Boolean) testConnection: (NSString *) aServer
              withUserName: (NSString *) uName
               andPassword: (NSString *) uPassword
                callBackTo: (id<HTTPClientOperationDelegate>) delegate

{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:S_C_L forKey:@"message"];
    
    NSString*  requestStr = [NSString stringWithFormat:kAPIFormatStringNoParams,
                             aServer, S_S, S_C_L, uName, uPassword];
    
    requestStr = [requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"login: %@", requestStr);
    
    HttpClientOperation *clientOp = [[HttpClientOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestStr]]];
    
    [clientOp setQualityOfService:NSQualityOfServiceUserInteractive];
    
    clientOp.userInfo = params;
    clientOp.delegate = delegate;
    
    __weak HttpClientOperation *weakClientOp = clientOp;
    
    [weakClientOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            obj = responseObject;
        }
        
        if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFinished:)]) {
            [weakClientOp.delegate HTTPClientOperation:weakClientOp didFinished:obj];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSNumber *statusCode = [NSNumber numberWithInteger:operation.response.statusCode];
        NSDictionary *errorInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:operation.userInfo, RESPONSE_USER_INFO, error, ERROR_KEY, operation.responseString, RESPONSE_STR, [NSString stringWithFormat:@"%@", statusCode], ERROR_STATUS_CODE, nil];
        
        if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFailWithError:)]) {
            [weakClientOp.delegate HTTPClientOperation:weakClientOp didFailWithError:errorInfoDict];
        }
    }];
    
    [clientOp start];

    return true;
    
    
    
    /*
    HTTPClient *client = nil;

    client = [[HTTPClient alloc] initWithBaseURL:[NSURL URLWithString:requestStr] plainResponse:YES];
    client.delegate = delegate;
    client.userInfo = params;

    [client GET:requestStr parameters:nil success: ^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        NSLog(@"(%@)testConnection = %d------>%@", client.delegate, (int)response.statusCode, client.baseURL);
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            responseObject = [[NSString alloc] initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"");
        }
        
        if ([client.delegate respondsToSelector:@selector(HTTPClient:didFinished:)]) {
            [client.delegate HTTPClient:client didFinished:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        NSNumber *statusCode = [NSNumber numberWithInteger:response.statusCode];
        
        NSLog(@"failedddd  testConnection = %@ for %@", statusCode, client.baseURL);
        
        NSDictionary *errorInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", statusCode], ERROR_STATUS_CODE, error, ERROR_KEY, nil];
        
        if ([statusCode integerValue] == 200) {
            // the call response is OK, JSON failed
        } else {
            if ([client.delegate respondsToSelector:@selector(HTTPClient:didFailWithError:)]) {
                [client.delegate HTTPClient:client didFailWithError:errorInfoDict];
            }
        }
    }];
    
    return true;
    
    
    */
    
    
    
    
    
    
    
  /*
    
    NSURL *url = [NSURL URLWithString:requestStr];
    id request = [ASIHTTPRequest requestWithURL:url];
    
    [request setThreadPriority:1.0];
    
    request.userInfo = params;
    
    [request setDelegate:delegate];
    
    [request setValidatesSecureCertificate:NO];
    
    [request setDownloadProgressDelegate:self];
    [request setUploadProgressDelegate:self];
    request.showAccurateProgress = YES;
    
    [self.asiQueue addOperation:request];
	[self.asiQueue go];
    
    return true;
*/
}

-(NSString*)getSimpleServer:(NSString*)serverParam {
    /*
     09.11.2015, we had to modify the server to use https also for OCWD especially, so we need to get the server name simple to use the calls that are being made to the laptop from truck cabin
     */
    NSArray *items = [serverParam componentsSeparatedByString:@"//"];
    if ([items count] == 2) {
        return [items objectAtIndex:1];
    }
    return [self server];
}


- (void)changePasswordForUser:(NSString*)uName 
                  oldPassword:(NSString*)oldPsswd 
                       userId:(NSString*)usrId 
                  newPassword:(NSString*)newPsswd
                   callBackTo:(id<HTTPClientDelegate>) delegate
{
    
}

- (void)createorgani:(NSString*)uName
                  oldPassword:(NSString*)oldPsswd
                       userId:(NSString*)usrId
                  newPassword:(NSString*)newPsswd
                   callBackTo:(id<HTTPClientOperationDelegate>) delegate
{
    return;
}

#pragma mark - Cloud


-(NSOperationQueue*)opQueue {
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc] init];
        [_opQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    return _opQueue;
}
- (id ) askTheCloudFor: (NSString *) urlString
               withMsg: (NSString *) msg
             andObject: (NSString *) objId
            callBackTo: (id<HTTPClientDelegate, HTTPClientOperationDelegate>) delegate
              withInfo:(NSString*)info
{
    
    HttpClientOperation *clientOp = nil;
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10*60];
    
    clientOp = [[HttpClientOperation alloc] initWithRequest:urlRequest];
    
    [clientOp setQualityOfService:NSQualityOfServiceUtility];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     msg,@"messageClass",msg,@"message",objId,@"objId", [NSNumber numberWithBool:YES], @"highPriority", nil];
    
    
    if (info) {
        [userInfo setObject:info forKey:@"info"];
    }
    
    NSLog(@"Simple Request Sent = %@", urlString);
    
    if ([self isNetworkReachable]) {
        
        __weak HttpClientOperation *weakClientOp = clientOp;
        
        weakClientOp.userInfo = userInfo;
        weakClientOp.delegate = delegate;
        
        [weakClientOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Simple Request Response Succeded = %@", operation.response.URL);
            
            NSError *error = nil;
            id obj = nil;
            
            if (responseObject) {
                obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            }
            if (error) {
                obj = responseObject;
            }
            
            if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFinished:)]) {
                [weakClientOp.delegate HTTPClientOperation:weakClientOp didFinished:obj];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Simple Request Response Failed = %@", operation.response.URL);
            
            NSDictionary *errorInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:operation.userInfo, RESPONSE_USER_INFO, error, ERROR_KEY, nil];
            
            if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFailWithError:)]) {
                [weakClientOp.delegate HTTPClientOperation:weakClientOp didFailWithError:errorInfoDict];
            }
        }];
    } else {
        if (delegate) {
            Aggregate *agg = (Aggregate*)delegate;
            [agg performSelectorOnMainThread:@selector(requestFailed:) withObject:userInfo waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(requestFailed:) withObject:userInfo waitUntilDone:NO];
        }
    }
    
    [self.opQueue addOperation:clientOp];
    [clientOp start];
    
    return nil;
}

- (id ) askTheCloudFor: (NSString *) urlString
               withMsg: (NSString *) msg
             andObject: (NSString *) objId
            callBackTo: (id<HTTPClientDelegate, HTTPClientOperationDelegate>) delegate
{

    HttpClientOperation *clientOp = nil;

    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10*60];
    
    clientOp = [[HttpClientOperation alloc] initWithRequest:urlRequest];
    
    [clientOp setQualityOfService:NSQualityOfServiceUtility];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              msg,@"messageClass",msg,@"message",objId,@"objId", [NSNumber numberWithBool:YES], @"highPriority", nil];

    
    NSLog(@"Simple Request Sent = %@", urlString);
    
    if ([self isNetworkReachable]) {
        
        __weak HttpClientOperation *weakClientOp = clientOp;

        weakClientOp.userInfo = userInfo;
        weakClientOp.delegate = delegate;
        
        [weakClientOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Simple Request Response Succeded = %@", operation.response.URL);

            NSError *error = nil;
            id obj = nil;
            
            if (responseObject) {
                obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            }
            if (error) {
                obj = responseObject;
            }
            
            if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFinished:)]) {
                [weakClientOp.delegate HTTPClientOperation:weakClientOp didFinished:obj];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Simple Request Response Failed = %@", operation.response.URL);
            
            NSDictionary *errorInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:operation.userInfo, RESPONSE_USER_INFO, error, ERROR_KEY, nil];
            
            if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFailWithError:)]) {
                [weakClientOp.delegate HTTPClientOperation:weakClientOp didFailWithError:errorInfoDict];
            }
        }];
    } else {
        if (delegate) {
            Aggregate *agg = (Aggregate*)delegate;
            [agg performSelectorOnMainThread:@selector(requestFailed:) withObject:userInfo waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(requestFailed:) withObject:userInfo waitUntilDone:NO];
        }
    }
    
    [self.opQueue addOperation:clientOp];
    [clientOp start];

    return nil;
}

// rco server requests
- (id ) askTheCloudFor: (NSString *) msgClass withMsg: (NSString *) msg withParams: (NSString *) params 
                 andObject: (NSString *) objId 
                callBackTo: (id<HTTPClientOperationDelegate>) delegate
{
    return [self askTheCloudFor:msgClass withMsg:msg withParams:params andObject:objId saveTo:nil showingProgress:NO callBackTo:delegate withHighPriority:false];
   
}

- (id ) askTheCloudFor: (NSString *) msgClass 
                            withMsg: (NSString *) msg 
                         withParams: (NSString *) params 
                          andObject: (NSString *) objId
                             saveTo: (NSString *) downloadPath 
                    showingProgress: (BOOL) showProgress
                         callBackTo: (id<HTTPClientOperationDelegate>) delegate
                   withHighPriority: (BOOL) highPriority
{
   
    {
        [self askTheCloudFor_ARC:msgClass
                      withMsg:msg
                   withParams:params
                    andObject:objId
                       saveTo:downloadPath
              showingProgress:showProgress
                   callBackTo:delegate
             withHighPriority:highPriority];
        
        return nil;
    }
}

- (void) askTheCloudFor_ARC: (NSString *) msgClass
                            withMsg: (NSString *) msg
                         withParams: (NSString *) params
                          andObject: (NSString *) objId
                             saveTo: (NSString *) downloadPath
                    showingProgress: (BOOL) showProgress
                         callBackTo: (id<HTTPClientOperationDelegate>) delegate
                   withHighPriority: (BOOL) highPriority
{
    NSLog(@"askTheCloudFor_ARC");
    
    NSString* requestStr = nil;
    
    if ( [msgClass length] == 0 ) {
        requestStr = [NSString stringWithFormat:@"https://%@%@", self.server, msg];
    }
    else if( params != nil ) {
        requestStr = [NSString stringWithFormat:kAPIFormatString,
                      self.server, msgClass, msg, self.userName, self.userPassword, params];
    }
    else
    {
        requestStr = [NSString stringWithFormat:kAPIFormatStringNoParams,
                      self.server, msgClass, msg, self.userName, self.userPassword];
    }
    requestStr = [requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:requestStr];
        
    HTTPClient *client = nil;
    
    HttpClientOperation *clientOp = nil;
    
    if ([msg isEqualToString:M_G_D_I] || ([msg isEqualToString:R_G_C])) {
        // we should receive in the plain format
        client = [[HTTPClient alloc] initWithBaseURL:url plainResponse:YES];
    } else {
        client = [[HTTPClient alloc] initWithBaseURL:url];
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10*60];
    
    clientOp = [[HttpClientOperation alloc] initWithRequest:urlRequest];
    
    [clientOp setQualityOfService:NSQualityOfServiceUtility];
    
    if ([msg isEqualToString:S_G_U_I]) {
        [client.requestSerializer setTimeoutInterval:20];
    } else {
        [client.requestSerializer setTimeoutInterval:TIMEOUT_SECONDS];
    }
    
    client.delegate = delegate;
    
    NSDictionary *userInfo = nil;
    
    if( objId != nil )
    {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               msgClass,@"messageClass",msg,@"message",objId,@"objId",params,@"params",[NSNumber numberWithBool:highPriority], @"highPriority",nil];
    }
    else
    {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               msgClass,@"messageClass",msg,@"message",params,@"params",[NSNumber numberWithBool:highPriority], @"highPriority", nil];
    }

    client.userInfo = userInfo;
    BOOL useOperation = YES;
    
    if (useOperation) {
        clientOp.userInfo = userInfo;
        clientOp.delegate = delegate;
        __weak HttpClientOperation *weakClientOp = clientOp;
        if (downloadPath) {
            [weakClientOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                NSMutableDictionary *msgDict = [NSMutableDictionary dictionaryWithObject:weakClientOp.userInfo forKey:RESPONSE_USER_INFO];
                
                if ([weakClientOp.delegate respondsToSelector:@selector(request:didReceivedBytes:)]) {
                    NSMutableDictionary *bytesInfo = [NSMutableDictionary dictionary];
                    
                    [bytesInfo setObject:[NSNumber numberWithLongLong:bytesRead] forKey:BytesRead];
                    [bytesInfo setObject:[NSNumber numberWithLongLong:totalBytesRead] forKey:BytesTotalyRead];
                    [bytesInfo setObject:[NSNumber numberWithLongLong:totalBytesExpectedToRead] forKey:BytesTotalyExpectedToRead];
                    
                    [weakClientOp.delegate request:msgDict didReceivedBytes:bytesInfo];
                    
                } else if ([weakClientOp.delegate respondsToSelector:@selector(request:didReceiveBytes:)]) {
                    [weakClientOp.delegate request:msgDict didReceiveBytes:bytesRead];
                }
            }];
        }
        [weakClientOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            id obj = nil;
            if (responseObject) {
                obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            }
            if (error) {
                obj = responseObject;
            }
            if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFinished:)]) {
                [weakClientOp.delegate HTTPClientOperation:weakClientOp didFinished:obj];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
            NSDictionary *errorInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:operation.userInfo, RESPONSE_USER_INFO, error, ERROR_KEY, nil];
            if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFailWithError:)]) {
                [weakClientOp.delegate HTTPClientOperation:weakClientOp didFailWithError:errorInfoDict];
            }
        }];
        
        BOOL continueWithTheCall = YES;
        
        if ([self workOffline] && !self.isForcedSync) {
            continueWithTheCall = NO;
        }

        if (continueWithTheCall) {
            [self.opQueue addOperation:clientOp];
            [clientOp start];
        } else {
            if ([weakClientOp.delegate respondsToSelector:@selector(HTTPClientOperation:didFinished:)]) {
                [weakClientOp.delegate HTTPClientOperationDidFinishedForced:weakClientOp];
            }
        }
    } else {
        [client GET:url.absoluteString parameters:nil success: ^(NSURLSessionDataTask *task, id responseObject) {
            
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            if ([responseObject isKindOfClass:[NSData class]]) {
                NSLog(@"");
            }
            if ([client.delegate respondsToSelector:@selector(HTTPClient:didFinished:)]) {
                [client.delegate HTTPClient:client didFinished:responseObject];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSNumber *statusCode = [NSNumber numberWithInteger:response.statusCode];
            NSDictionary *errorInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:statusCode, ERROR_STATUS_CODE, error, ERROR_KEY, nil];
            if ([statusCode integerValue] == 200) {
            } else {
                if ([client.delegate respondsToSelector:@selector(HTTPClient:didFailWithError:)]) {
                    [client.delegate HTTPClient:client didFailWithError:errorInfoDict];
                }
            }
        }];
    }
}


- (id ) uploadObjectContentForObjectId: (NSString *)objId objectType:(NSString*)objectType filePath: (NSString *) filePath
{
    return [self tellTheCloud:RD_S
                      withMsg:R_S_C_1
                   withParams: [NSString stringWithFormat:@"%@/%@", objId, objectType]
                     withData:nil
                     withFile:filePath
                    andObject:objId
                   callBackTo:nil];
}
- (id ) tellTheCloud: (NSString *) msgClass
                          withMsg: (NSString *) msg
                       withParams: (NSString *) params
                         withData: (NSData *) data
                         withFile: (NSString *) filePath
                        andObject: (NSString *) objId
                       callBackTo: (id<HTTPClientOperationDelegate, HTTPClientDelegate>) delegate
{
    return [self tellTheCloud:msgClass
                      withMsg:msg
                   withParams:params
                     withData:data
                     withFile:filePath
                    andObject:objId
                   callBackTo:delegate
                    extraInfo:nil];
}
- (id ) tellTheCloud: (NSString *) msgClass
                          withMsg: (NSString *) msg
                       withParams: (NSString *) params
                        withData : (NSData *) data
                         withFile: (NSString *) fp
                        andObject: (NSString *) objId
                       callBackTo: (id<HTTPClientOperationDelegate, HTTPClientDelegate>) delegate
                        extraInfo:(NSDictionary*)extraInfo
{
     [self tellTheCloud_ARC:msgClass
                withMsg:msg
             withParams:params
               withData:data
               withFile:fp
              andObject:objId
             callBackTo:delegate
              extraInfo:extraInfo];
    
    return nil;
}

- (id ) tellTheCloud_ARC: (NSString *) msgClass
                          withMsg: (NSString *) msg
                       withParams: (NSString *) params
                        withData : (NSData *) data
                         withFile: (NSString *) fp
                        andObject: (NSString *) objId
                       callBackTo: (id<HTTPClientDelegate, HTTPClientOperationDelegate>) delegate
                        extraInfo:(NSDictionary*)extraInfo
{
    
    NSString* requestStr = nil;
    static int callNr = 0;
    
    callNr++;
    
    NSString *message = [NSString stringWithFormat:@"%@", msg];
    
    if( params != nil ) {
        requestStr = [NSString stringWithFormat:kAPIFormatString,
                      self.server, msgClass, message, self.userName, self.userPassword, params];
    }
    else
    {
        requestStr = [NSString stringWithFormat:kAPIFormatStringNoParams,
                      self.server, msgClass, message, self.userName, self.userPassword];
    }
        
    NSURL *url = [NSURL URLWithString:requestStr];
    
    NSString *uploadFileName = nil;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    if( data != nil ) {
        
        NSString *deviceId = [self deviceId];
        
        NSString *objIdFormatted = [NSString stringWithFormat:@"%@", objId];
        objIdFormatted = [objIdFormatted stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        NSString *rcoObjDesc = nil;
        
        if (extraInfo) {
            rcoObjDesc = [extraInfo objectForKey:kRCOObjectShortDescription];
            rcoObjDesc = [rcoObjDesc stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        }
        
        NSNumber *skipGetRecordCoding = [extraInfo objectForKey:kSkipGetRecordCoding];
        
        if (skipGetRecordCoding) {
            [userInfo setObject:skipGetRecordCoding forKey:kSkipGetRecordCoding];
        }
        NSString *uploadFileNameFormatted = nil;
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
        
        NSString *date_time_str =[f stringFromDate:[NSDate date]];
        NSString *fileExtension = @"txt";
        NSString *sync = @"SYNC";
        if (delegate) {
            sync = @"ASYNC";
        }
        
        if (rcoObjDesc) {
            uploadFileNameFormatted = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%@_%lu_%@.%@",deviceId, appVersion, message, sync , rcoObjDesc, objIdFormatted, (unsigned long)data.length, date_time_str, fileExtension];
        } else {
            uploadFileNameFormatted = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%lu_%@.%@",deviceId, appVersion, message, sync, objIdFormatted, (unsigned long)data.length, date_time_str, fileExtension];
        }
        
        [userInfo setObject:uploadFileNameFormatted forKey:@"fileName"];
        
        uploadFileName = [NSString stringWithFormat:@"%@", uploadFileNameFormatted];
        
    } else if( fp != nil ) {
        
        NSString *deviceId = [self deviceId];
        
        NSString *objIdFormatted = [NSString stringWithFormat:@"%@", objId];
      
        objIdFormatted = [objIdFormatted stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
        
    if (msgClass) {
        [userInfo setObject:msgClass forKey:@"messageClass"];
    }
    
    if (msg) {
        [userInfo setObject:msg forKey:@"message"];
    }
    
    if (objId) {
        [userInfo setObject:objId forKey:@"objId"];
    }
    
    if (params) {
        [userInfo setObject:params forKey:@"params"];
    }
    
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"highPriority"];
    
    if (extraInfo) {
        [userInfo setObject:extraInfo forKey:CALL_EXTRA_INFO];
    }
    
    if ([self isNetworkReachable]) {
        
        HTTPClient *sessionManager = nil;
        if ([msg isEqualToString:R_S_C_1])
        {
            // this is for not trying to parse the response from the server as a JSON format but as plain string
            sessionManager = [[HTTPClient alloc] initWithBaseURL:url plainResponse:YES];
        } else {
            sessionManager = [[HTTPClient alloc] initWithBaseURL:url];
        }
        sessionManager.delegate = delegate;
        
        sessionManager.userInfo = userInfo;

        [sessionManager.requestSerializer setTimeoutInterval:TIMEOUT_SECONDS];
        
        BOOL continueWithTheCall = YES;
        continueWithTheCall = NO;
        
        if (continueWithTheCall) {
        } else {
            if ([sessionManager.delegate respondsToSelector:@selector(HTTPClient:didFinished:)]) {
                [sessionManager.delegate HTTPClientDidFinishedForced:sessionManager];
            }
            
            return nil;
        }
    } else {
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        BOOL *progressBlockCalled = context;
        *progressBlockCalled = YES;
    }
}

#pragma mark -
#pragma mark Connection Callbacks
// call backs from the connection object
- (void)requestStarted:(id )request
{
}
- (void)requestFinished:(id )request
{
    NSDictionary *msgDict = nil;
    NSString *msg = nil;
    NSString *requestResponse = nil;
    
    NSString *resp = nil;
    
    id respObj = nil;
    
    BOOL isNewParsing = NO;
    
    if ([request isKindOfClass:[NSDictionary class]]) {
        // new flow
        NSDictionary *respDict = (NSDictionary*)request;
        requestResponse = [respDict objectForKey:RESPONSE_STR];
        msgDict = [respDict objectForKey:RESPONSE_USER_INFO];
        respObj = [respDict objectForKey:RESPONSE_OBJ];
        
        isNewParsing = YES;
        resp = requestResponse;
    }

    msg = [msgDict objectForKey:@"message"];
    
    NSString *response = nil;
    {
        if ([request isKindOfClass:[NSDictionary class]]) {
            NSDictionary *respDict = (NSDictionary*)request;
            response = [respDict objectForKey:RESPONSE_STR];
        }
    }

    NSError *error = nil;
    NSArray* fieldValues = nil;
    
    if (isNewParsing) {
        fieldValues = (NSArray*)respObj;
    } else {
        if ([request responseData]) {
            fieldValues = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:&error];
        }
    }
    if ([msg isEqualToString:S_G_U_I]) {
        NSError *error = nil;
        NSDictionary *result = nil;
        
        if (isNewParsing) {
            result = (NSDictionary*)respObj;
        } else {
            if ([request responseData]) {
                result = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:&error];
            }
        }

        NSString *uid = [result objectForKey:@"userId"];
        
        NSString *objectId = [result objectForKey:@"LobjectId"];
        NSString *objectType = [result objectForKey:@"objectType"];
        
        NSArray * fields = [result objectForKey:@"arCodingInfo"];
        
        uid = objectId;
        
        for (NSDictionary *d in fields) {
            
            NSString *desc = [d objectForKey:@"displayName"];
            
            if( [desc isEqualToString:@"Company"]) {
                NSString *companyName = [d objectForKey:@"value"];
                if (companyName) {
                    [Settings setSetting:companyName forKey:CLIENT_COMPANY_NAME];
                }
            }
            else if( [desc isEqualToString:@"RMS User Id"]) {
            }
            else if([desc isEqualToString:@"Organization Name"]) {
                self.orgNameRCO = [d objectForKey:@"value"];
                [Settings setSetting:[d objectForKey:@"value"] forKey:CLIENT_ORGANIZATION_NAME];
            }
            else if([desc isEqualToString:@"Organization Number"]) {
                self.orgNumberRCO = [d objectForKey:@"value"];
                [Settings setSetting:[d objectForKey:@"value"] forKey:CLIENT_ORGANIZATION_ID];
            }
            
            else if([desc isEqualToString:@"ItemType"]) {
                [Settings setSetting:[d objectForKey:@"value"]forKey:USER_TYPE];
                self.userTypeRCO = [d objectForKey:@"value"];
            }
            else if([desc isEqualToString:@"UserType"]) {
                [Settings setSetting:[d objectForKey:@"value"]forKey:USER_SUB_TYPE];
            }
            else if([desc isEqualToString:@"GPSLocationServices"]) {
                self.sendGPSLocation = [NSNumber numberWithBool:[[d objectForKey:@"value"] boolValue]];
            }
            else if ([desc isEqualToString:@"RecordId"]) {
                self.userRecordIdRCO = [d objectForKey:@"value"];
                [Settings setSetting:self.userRecordIdRCO forKey:CLIENT_USER_RECORDID_KEY];
            }
            else if ([desc isEqualToString:@"Last Name"]) {
                self.userLastNameRCO = [d objectForKey:@"value"];
                [Settings setSetting:self.userLastNameRCO forKey:CLIENT_USER_LAST_NAME_KEY];
            }
            else if ([desc isEqualToString:@"First Name"]) {
                self.userFirstNameRCO = [d objectForKey:@"value"];
                [Settings setSetting:self.userFirstNameRCO forKey:CLIENT_USER_FIRST_NAME_KEY];
            }
            else if ([desc isEqualToString:@"Employee Id"]) {
                self.userEmployeeIdRCO = [d objectForKey:@"value"];
                [Settings setSetting:self.userEmployeeIdRCO forKey:CLIENT_USER_EMPLOYEEID_KEY];
            }
        }
        NSArray *roles = [result objectForKey:@"roles"];
        if( [roles count] ) {
             [Settings setSetting:roles forKey:USER_ROLES];
        }
    
        if( objectId != nil && objectType != nil && uid != nil) {
            if ([uid isKindOfClass:[NSNumber class]]) {
                self.userId = [NSString stringWithFormat:@"%d", [uid intValue]];
            } else {
                self.userId = uid;
            }
            
            NSString *objIdAndType = [NSString stringWithFormat: @"%@/%@",[result objectForKey:@"objectId"], [result objectForKey:@"objectType"]];
            
            [Settings setSetting:objIdAndType forKey:CLIENT_OBJIDTYPE_KEY];
            [Settings save];
            
            // skip the record coding
            self.syncStatus = SYNC_STATUS_USER_CODING;
            [self getUserRights];
            if ([self.orgNumberRCO isEqualToString:@"26"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loadBackground" object:nil];
            }
        }
        else {
                // if we work offline then we should not show this message
            if ([self workOffline]) {
                NSLog(@"working offline 1");
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationLoaded" object:nil];
        }
        
    } else if ([msg isEqualToString:R_G_C_1]) {
        NSString *organizationName = nil;
        NSString *organizationId = nil;
        NSString *usrType = nil;
        
        if ([fieldValues isKindOfClass:[NSArray class]]) {
            for (int i = 0; i < [fieldValues count]; i++) {
                NSDictionary *field = [fieldValues objectAtIndex:i];
                if ([[field objectForKey:@"displayName"] isEqualToString:@"Organization Name"]) {
                    organizationName = [field objectForKey:@"value"];
                }
                if ([[field objectForKey:@"displayName"] isEqualToString:@"Organization Number"]) {
                    organizationId = [field objectForKey:@"value"];
                }
                if ([[field objectForKey:@"displayName"] isEqualToString:@"ItemType"]) {
                    usrType = [field objectForKey:@"value"];
                }
            }
        }
        
        if (organizationId != nil && organizationName != nil) {
            [Settings setSetting:organizationName forKey:CLIENT_ORGANIZATION_NAME];
            self.orgNameRCO = organizationName;
            [Settings setSetting:organizationId forKey:CLIENT_ORGANIZATION_ID];
            self.orgNumberRCO = organizationId;
            [Settings setSetting:usrType forKey:USER_TYPE];
            [Settings save];
        }
        
        [self getUserRights];
    }
    else if([msg isEqualToString:S_C_R] &&  fieldValues != nil)
    {
        self.userRights = fieldValues;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMenuItems" object:[NSNumber numberWithBool:YES]];

        [self getFunctionalGroupMembers];
        
    } else if ([msg isEqualToString:US_G_F_G_M]) {

        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *functionGroupInfo in fieldValues) {
            if ([[functionGroupInfo objectForKey:@"userObjectId"] isEqualToString:self.userId]) {
                [arr addObject:functionGroupInfo];
            }
        }
        [Settings setSetting:arr forKey:FUNCTIONALGROUP_IDS];
        [Settings save];
                
        [self getFunctionalGroupMap];
        
    } else if ([msg isEqualToString:US_G_F_G_MA]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSDictionary *functionGroupInfo in fieldValues) {
            [dict setObject:[functionGroupInfo objectForKey:@"functionalGroupName"] forKey: [functionGroupInfo objectForKey:@"recordType"]];
        }
        self.functionalRecordTypeMap = [NSDictionary dictionaryWithDictionary:dict];
        [self getDeviceId];
        
    } else if ([msg isEqualToString:M_G_D_I]) {
        
        NSString *deviceId = [response  stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if( deviceId ) {
            self.mobileDeviceIDRCO = nil;
            [Settings setSetting:deviceId forKey:MOBILE_DEVICE_ID];
            [Settings save];
        }
        if( [deviceId length] && self.syncStatus == SYNC_STATUS_USER_DEVICE_ID) {
            self.syncStatus = SYNC_STATUS_USER_COMPLETE;
            [self loadUserAggregates];
        }
    }
}

-(BOOL)loadAggregate {
    
    return YES;
}

- (void)requestFailed:(id )request
{
    NSString *response = [self getResponseStringFromRequest:request];
    NSString *url = [self getCallURLFromRequestResponse:request];
    NSString *errorMsg = [self getErrorFromRequestResponse:request];
    NSInteger statusCode = [self getStatusCodeFromRequestResponse:request];
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString:S_G_U_I]) {
        
        NSString *objIdAndType = [Settings getSetting:CLIENT_OBJIDTYPE_KEY];
        
        NSArray *comps = [objIdAndType componentsSeparatedByString:@"/"];
        
        if( [comps count] > 0 && [self.userId length]) {
            [self getUserRecordCoding:[comps objectAtIndex:0] objectType:[comps objectAtIndex:1]];
        }
    } else if ([msg isEqualToString:R_G_C_1]) {
        NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
        NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];

        if (organizationId != nil && organizationName != nil) {
            [self getUserRights];
        }
        
        
    } else if([msg isEqualToString:S_C_R]) {
        // just use what we got
        if( [self.userRights count] ) {
            [self getFunctionalGroupMembers];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMenuItems" object:[NSNumber numberWithBool:YES]];
        
    } else if ([msg isEqualToString:US_G_F_G_M]) {
        
        NSArray *arr = [Settings getSettingAsArray:FUNCTIONALGROUP_IDS];

        [self getFunctionalGroupMap];
        
        
    } else if ([msg isEqualToString:US_G_F_G_MA]) {
        [self getDeviceId];

    }
    else if ([msg isEqualToString:M_G_D_I]) {
        
        NSString *deviceId = [self deviceId];
        
        if( self.syncStatus == SYNC_STATUS_USER_DEVICE_ID ) {
            self.syncStatus = SYNC_STATUS_USER_COMPLETE;
            if( [deviceId length] ) {
                [self loadUserAggregates];
            }
            
        }
    }    
}

#pragma mark - Aggregate Callbacks
- (void) objectSyncRequestStarted:(NSNumber *)numObjectsToUpdate fromAggregate: (Aggregate *) aggregate
{
    NSLog(@"<<<>>>Sync started for Record %@-%@-%@", aggregate, aggregate.rcoRecordType, numObjectsToUpdate);
    
    if ([self isNewSyncImplementation] && ![aggregate switchedToOldSync]) {
        NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
        NSNumber *prevNumber = [statusDictEntry objectForKey:kObjectsToSync];
        if ([prevNumber integerValue] == 0) {
            
            [statusDictEntry setObject:kSyncStatus_CodingRequestStarted forKey:kSyncStatus];
            
            NSNumber *total = [statusDictEntry objectForKey:kTotalObjects];
            if( total == nil ) {
                total = [NSNumber numberWithUnsignedInteger:[aggregate countObjects:nil]];
            }

            [statusDictEntry setObject:total forKey:kTotalObjects];
            [statusDictEntry setObject:numObjectsToUpdate forKey:kObjectsToSync];
            [statusDictEntry setObject:[NSNumber numberWithUnsignedInt:0] forKey:kObjectsSynced];
            [statusDictEntry setObject:[NSDate date] forKey:kSyncTimeStart];
        } else {
        }
    } else {
        NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
        [statusDictEntry setObject:kSyncStatus_CodingRequestStarted forKey:kSyncStatus];
        
        NSNumber *total = [statusDictEntry objectForKey:kTotalObjects];
        if( total == nil ) {
            total = [NSNumber numberWithUnsignedInteger:[aggregate countObjects:nil]];
        }
        [statusDictEntry setObject:total forKey:kTotalObjects];
        
        [statusDictEntry setObject:numObjectsToUpdate forKey:kObjectsToSync];
        [statusDictEntry setObject:[NSNumber numberWithUnsignedInt:0] forKey:kObjectsSynced];
        [statusDictEntry setObject:[NSDate date] forKey:kSyncTimeStart];
    }
    
    [self calculateSyncProgress];
}

- (void) objectSyncRequestCompleted: (NSNumber *)numObjectsToUpdate fromAggregate: (Aggregate *) aggregate;
{
    NSString *aggUniqueName = [aggregate uniqueName];
    
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:aggUniqueName];
    [statusDictEntry setObject:kSyncStatus_CodingRequestComplete forKey:kSyncStatus];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:[aggregate countObjects:nil]] 
                        forKey:kTotalObjects];
    
    [statusDictEntry setObject:numObjectsToUpdate forKey:kObjectsToSync];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInt:0] forKey:kObjectsSynced];
    [statusDictEntry setObject:[NSDate date] forKey:kSyncTimeStart];
    
    if ([self isNewSyncImplementation] && ![aggregate switchedToOldSync]) {
        // do nothing here ...
        if (abs([numObjectsToUpdate intValue]) < abs (BATCH_SIZE)) {
            [self syncContinue: aggregate];
        } else {
            if ((abs([numObjectsToUpdate intValue]) == aggregate.batchSize) && (aggregate.batchSize == 1)) {
                [self syncContinue: aggregate];
            }
        }
    } else {
            [self syncContinue: aggregate];
    }
    
    [self calculateSyncProgress];
    }

- (void) objectSyncComplete: (Aggregate *) fromAggregate
{
    NSMutableDictionary *statusDictEntry = nil;
    NSNumber *objectsToSync = nil;
    
    @synchronized (self.statusDict) {
        
        statusDictEntry = [self.statusDict objectForKey:[fromAggregate uniqueName]];
        [statusDictEntry setObject:kSyncStatus_CodingComplete forKey:kSyncStatus];
        [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:[fromAggregate countObjects:nil]]
                            forKey:kTotalObjects];
        // set these to be the same although there might have been errors
        objectsToSync = [statusDictEntry objectForKey:kObjectsToSync];
        [statusDictEntry setObject:[objectsToSync copy] forKey:kObjectsSynced];
        [statusDictEntry setObject:[NSDate date] forKey:kSyncTimeEnd];
    }
    
    BOOL syncLogging = YES;
    
    if (syncLogging) {
        // if SyncLogging flag is set to yes then we should log the sync messages
        NSDate *startDate = [statusDictEntry objectForKey:kSyncTimeStart];
        NSDate *endDate = [NSDate date];
        
        double seconds = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
        
        NSString *deviceId = [self deviceId];
        NSString *message = [NSString stringWithFormat:@"--%@--SyncFor--%@--Items--%@--Duration--%d--\n",deviceId, [fromAggregate uniqueName], objectsToSync, (int)seconds];
        
        message = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        message = [message stringByReplacingOccurrencesOfString:@"/" withString:@"--"];
        if (syncLogging) {
            [fromAggregate sendSyncMessage:message synchronous:NO];
        }
        
        long totalItemsToUpdate = 0;
        long totalDuration = 0;
        BOOL syncFinished = YES;
        
        for (NSString *aggKey in self.statusDict.allKeys) {
            NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:aggKey];
            
            if ([statusDictEntry isKindOfClass:[NSDictionary class]]) {
                NSNumber *itemsToSync = [statusDictEntry objectForKey:kObjectsToSync];
                NSNumber *itemsSynced = [statusDictEntry objectForKey:kObjectsSynced];
                
                if ([itemsToSync integerValue] != [itemsSynced integerValue]) {
                    syncFinished = NO;
                    break;
                }
                totalItemsToUpdate += [itemsSynced integerValue];
                NSDate *startDate = [statusDictEntry objectForKey:kSyncTimeStart];
                NSDate *endDate = [statusDictEntry objectForKey:kSyncTimeEnd];
                
                if (!endDate) {
                    syncFinished = NO;
                    break;
                }
                
                long duration = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
                
                totalDuration += duration;
            }
        }
        
        if (syncFinished) {
            NSLog(@"");
        }
                
        if (syncFinished && self.isFullSync) {
            NSString *deviceId = [self deviceId];
            NSString *message = [NSString stringWithFormat:@"--%@--TotalItems--%ld--TotalDuration--%ld--\n",deviceId, totalItemsToUpdate, totalDuration];
            
            message = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            message = [message stringByReplacingOccurrencesOfString:@"/" withString:@"--"];
            if (syncLogging) {
                [fromAggregate sendSyncMessage:message synchronous:NO];
            }
            [self performSelectorOnMainThread:@selector(showFinishSyncMessage) withObject:nil waitUntilDone:YES];
            
            // we should post a notification
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSynchronizationFinised object:nil];
        }
    }
    
    [self syncContinue: fromAggregate];
    
    [self calculateSyncProgress];
}

-(void)showFinishSyncMessage {
    
    [self.alert dismissWithClickedButtonIndex:0 animated:NO];
    self.alert = nil;
    
    BOOL displayFinishMessage = self.isFullSync;
    
    if (self.isAutoSync) {
        displayFinishMessage = [self displayAutoSyncMessage];
    }
    
    if (displayFinishMessage && ![self hideSyncMessages]) {
        [self showSyncAlert:NSLocalizedString(SyncMessageEnd, nil)];
    }
    
    self.isFullSync = NO;
    self.isOneSyncFinished = YES;
    self.isForcedSync = NO;
    self.isAutoSync = YES;
}

-(BOOL)fullSyncInProgress {
    return self.isFullSync;
}

-(BOOL)displayAutoSyncMessage {
    BOOL displayMessage = YES;
    
    NSString *displayMessageStr = [Settings getSetting:kAutoSyncDisplayMessage];
    if (![displayMessageStr boolValue]) {
        displayMessage = NO;
    }
    
    return displayMessage;
}

- (void) contentSyncComplete:(Aggregate *)fromAggregate
{
    
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[fromAggregate uniqueName]];
    [statusDictEntry setObject:kSyncStatus_ContentComplete forKey:kSyncStatus];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:[fromAggregate countObjects:nil]]
                        forKey:kTotalObjects];
    
    [self syncContinue: fromAggregate];
    
    [self calculateSyncProgress];
}

- (void) objectsUploadStarted:(NSNumber *)numObjectsToUpdate fromAggregate:(Aggregate *)aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0] forKey:kObjectsUploaded];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0] forKey:kObjectUploadFailed];
    [statusDictEntry setObject:numObjectsToUpdate forKey:kObjectsToUpload];

    [statusDictEntry setObject:[NSDate date] forKey:kUploadTimeStart];
    [self calculateSyncProgress];
}

-(void)objectUploadComplete:(NSString *)objectId fromAggregate:(Aggregate *)aggregate {
    
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    NSNumber *objectsUploaded = (NSNumber *)[statusDictEntry objectForKey:kObjectsUploaded];
    
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:1 + [objectsUploaded unsignedIntegerValue]]
                        forKey:kObjectsUploaded];
    [self calculateSyncProgress];
}

- (void) objectSyncStarted:(NSNumber *)numObjectsToUpdate fromAggregate:(Aggregate *)aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    [statusDictEntry setObject:kSyncStatus_CodingStarted forKey:kSyncStatus];
    
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0] forKey:kObjectsSynced];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0] forKey:kObjectsFailed];
    [statusDictEntry setObject:numObjectsToUpdate forKey:kObjectsToSync];
    NSUInteger totalObjects = [aggregate countObjects:nil];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:totalObjects]
                        forKey:kTotalObjects];
    [statusDictEntry setObject:[NSDate date] forKey:kSyncTimeStart];
    [self calculateSyncProgress];
    
}

- (void) contentSyncStarted:(NSNumber *)numObjectsToUpdate fromAggregate:(Aggregate *)aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    [statusDictEntry setObject:kSyncStatus_ContentStarted forKey:kSyncStatus];
    [statusDictEntry setObject:numObjectsToUpdate forKey:kFilesToSync];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0] forKey:kFilesSynced];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0] forKey:kFilesFailed];

    [self calculateSyncProgress];
}


- (void) contentDownloadComplete: (NSString *) objectId fromAggregate: (Aggregate *) aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    NSNumber *filesUpdated = (NSNumber *) [statusDictEntry objectForKey:kFilesSynced];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:1 + [filesUpdated unsignedIntegerValue]]
                        forKey:kFilesSynced];
    
    
    [self calculateSyncProgress];
}

- (void) contentDownloadFailed: (NSString *) objectId fromAggregate: (Aggregate *) aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    NSNumber *filesFailed= (NSNumber *) [statusDictEntry objectForKey:kFilesFailed];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:1 + [filesFailed unsignedIntegerValue]]
                        forKey:kFilesFailed];
    [self calculateSyncProgress];
}

- (void) objectDownloadComplete: (NSString *) objectId  fromAggregate: (Aggregate *) aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    
    if (aggregate.syncStatus == SYNC_STATUS_CODING) {
        NSNumber *objectsUpdated = (NSNumber *) [statusDictEntry objectForKey:kObjectsSynced];
        [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:1 + [objectsUpdated unsignedIntegerValue]]
                            forKey:kObjectsSynced];        
    }
    [self calculateSyncProgress];
    
}

- (void) objectsDownloadComplete: (NSArray *) objects  fromAggregate: (Aggregate *) aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    NSNumber *objectsUpdated = nil;
    
    if (aggregate.syncStatus == SYNC_STATUS_CODING) {
        objectsUpdated = (NSNumber *) [statusDictEntry objectForKey:kObjectsSynced];
        [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0 + [objectsUpdated unsignedIntegerValue]]
                            forKey:kObjectsSynced];

    }
    [self calculateSyncProgress];
}

- (void) objectDownloadFailed: (NSString *) objectId  fromAggregate: (Aggregate *) aggregate
{
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[aggregate uniqueName]];
    if (aggregate.syncStatus == SYNC_STATUS_CODING) {
        NSNumber *objectsFailed = (NSNumber *) [statusDictEntry objectForKey:kObjectsFailed];
        [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:1 + [objectsFailed unsignedIntegerValue]]
                        forKey:kObjectsFailed];
    }
    [self calculateSyncProgress];
}

- (void) calculateSyncProgress {
    
    int requestsToComplete = 0;
    int requestsCompleted = 0;
    NSUInteger objectsToUpdate = 0, objectsUpdated = 0, objectsFailed = 0;
    NSUInteger filesToUpdate = 0, filesUpdated = 0, filesFailed = 0;
    NSUInteger recordsToUpdate = 0, recordsUpdated = 0, recordsFailed = 0;

    for( Aggregate *agg in self.aggregates )
    {
        if (agg.skipSyncRecords) {
            // we should not sync this record;
            agg.syncStatus = SYNC_STATUS_COMPLETE;
            continue;
        }
        NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[agg uniqueName]];
        
        // download records
        NSNumber *ou = (NSNumber *) [statusDictEntry objectForKey:kObjectsSynced];
        NSNumber *of = (NSNumber *) [statusDictEntry objectForKey:kObjectsFailed];
        NSNumber *otu = (NSNumber *) [statusDictEntry objectForKey:kObjectsToSync];
        
        // files sync
        NSNumber *fu = (NSNumber *) [statusDictEntry objectForKey:kFilesSynced];
        NSNumber *ff = (NSNumber *) [statusDictEntry objectForKey:kFilesFailed];
        NSNumber *ftu = (NSNumber *) [statusDictEntry objectForKey:kFilesToSync];

        // upload records
        NSNumber *ru = (NSNumber *) [statusDictEntry objectForKey:kObjectsUploaded];
        NSNumber *rf = (NSNumber *) [statusDictEntry objectForKey:kObjectUploadFailed];
        NSNumber *rtu = (NSNumber *) [statusDictEntry objectForKey:kObjectsToUpload];

        requestsToComplete += 2;
        
        NSString *status = [statusDictEntry objectForKey:kSyncStatus];
        
        if( [status isEqualToString:kSyncStatus_None]) {
            
        }
        else if ([status isEqualToString:kSyncStatus_CodingRequestStarted])
        {
            requestsCompleted ++;
        }
        else {
            requestsCompleted += 2;
        }
        
        objectsToUpdate += [otu unsignedIntValue];
        objectsUpdated += [ou unsignedIntValue];
        objectsFailed = [of unsignedIntValue];
        
        filesToUpdate += [ftu unsignedIntValue];
        filesUpdated += [fu unsignedIntValue];
        filesFailed = [ff unsignedIntValue];
        
        recordsToUpdate += [rtu unsignedIntValue];
        recordsUpdated += [ru unsignedIntValue];
        recordsFailed += [rf unsignedIntValue];
    }
    float percentRequests = 0.05;
    
    if( requestsToComplete > requestsCompleted ) {
        float tr = percentRequests * ((float)requestsCompleted)/((float)requestsToComplete);
        [self.statusDict setObject:[NSNumber numberWithFloat:tr] forKey:kSyncProgress];
    }
    else if( objectsToUpdate + filesToUpdate ) {
        float tu = percentRequests + (1.0-percentRequests) * ((float) (objectsUpdated + filesUpdated + objectsFailed + filesFailed))/((float) (objectsToUpdate + filesToUpdate) );
        [self.statusDict setObject:[NSNumber numberWithFloat:tu] forKey:kSyncProgress];
    }
    else {
        [self.statusDict setObject:[NSNumber numberWithFloat:1.0] forKey:kSyncProgress];
    }
    
    [self.statusDict setObject:[NSNumber numberWithUnsignedInteger: objectsUpdated] forKey:kObjectsSynced];
    [self.statusDict setObject:[NSNumber numberWithUnsignedInteger: objectsFailed] forKey:kObjectsFailed];
    [self.statusDict setObject:[NSNumber numberWithUnsignedInteger: objectsToUpdate] forKey:kObjectsToSync];
    
    [self.statusDict setObject:[NSNumber numberWithUnsignedInteger: filesUpdated] forKey:kFilesSynced];
    [self.statusDict setObject:[NSNumber numberWithUnsignedInteger: filesFailed] forKey:kFilesFailed];
    [self.statusDict setObject:[NSNumber numberWithUnsignedInteger: filesToUpdate] forKey:kFilesToSync];
}

- (NSString *) syncStatusDescription
{
    return [self descriptionForSyncStatus:self.syncStatus];
}

- (NSString *) descriptionForSyncStatus:(SYNC_STATUS) ss
{
    NSString *desc = [NSString stringWithFormat:@"Status: %d", ss];

    switch (ss) {
        case SYNC_STATUS_PAUSED:
            desc = @"Synchronizing is paused.";
            break;
            
        case SYNC_STATUS_NONE:
            desc = @"Not synchronizing.";
            break;
            
        case SYNC_STATUS_USER_ID:
            desc = @"Verifying user identity.";
            break;
            
        case SYNC_STATUS_USER_CODING:
            desc = @"Retrieving user details.";
            break;
            
        case SYNC_STATUS_USER_RIGHTS:
            desc = @"Retrieving user security information.";
            break;
            
        case SYNC_STATUS_USER_FUNCTIONAL_MEMBERS:
            desc = @"Retrieving user functional groups.";
            break;
            
        case SYNC_STATUS_USER_FUNCTIONAL_MAP:
            desc = @"Retrieving user functional maps.";
            break;
            
        case SYNC_STATUS_USER_DEVICE_ID:
            desc = @"Retrieving user device id.";
            break;
            
        case SYNC_STATUS_USER_COMPLETE:
            desc = @"All user information retrieved.";
            break;
                       
        case SYNC_STATUS_REQUEST:
            desc = @"Requesting update information";
            break;
            
        case SYNC_STATUS_REQUEST_COMPLETE:
            desc = @"Received update information";
            break;
            
        case SYNC_STATUS_CODING:
            desc = @"Transferring records...";
            break;
            
        case SYNC_STATUS_CODING_COMPLETE:
            desc = @"All records transferred.";
            break;
            
        case SYNC_STATUS_CONTENT:
            desc = @"Transferring files...";
            break;
            
        case SYNC_STATUS_COMPLETE:
            desc = @"All records and files synchronized.";
            break;
            
                  
    }
    
    return desc;
}

- (void) resetStatus
{
    [self.statusDict setObject:[NSNumber numberWithFloat:0.0] forKey:kSyncProgress];
    [self.statusDict setObject:[NSNumber numberWithInt:self.networkStatus] forKey:kSyncNetworkStatus];
    
    for( Aggregate *agg in self.aggregates )
    {
        [self resetStatusForAggregate: agg];
    }
}

-(void)resetAggregates {
    self.aggregates = nil;
    self.isOneSyncFinished = NO;
    self.isForcedSync = NO;
    self.isFullSync = NO;
}

- (void) resetStatusForAggregate: (Aggregate *) agg
{
        
    if (agg.skipSyncRecords) {
        agg.syncStatus = SYNC_STATUS_COMPLETE;
        return;
    }
    
    NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:[agg uniqueName]];
    
    if( statusDictEntry == nil ) {
        statusDictEntry = [NSMutableDictionary dictionary];
        [self.statusDict setObject:statusDictEntry forKey:[agg uniqueName]]; 
        [agg registerForCallback:self];
    }
    [statusDictEntry setObject:kSyncStatus_None
                        forKey:kSyncStatus];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:[agg countObjects:nil]] 
                        forKey:kTotalObjects];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:[agg countObjectsToSync]]
                        forKey:kObjectsToSync];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0]
                        forKey:kObjectsSynced];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0]
                        forKey:kObjectsFailed];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:[agg countFilesToSync]]
                        forKey:kFilesToSync];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0]
                        forKey:kFilesSynced];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0]
                        forKey:kFilesFailed];
    // for uploading ....
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:[agg getObjectsToUploadCount]]
                        forKey:kObjectsToUpload];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0]
                        forKey:kObjectsUploaded];
    [statusDictEntry setObject:[NSNumber numberWithUnsignedInteger:0]
                        forKey:kObjectsUploadedFailed];

}

- (void) updateObjectCountForAggregate: (NSDictionary *) msgDict
{
    for( NSString *aggName in [msgDict allKeys]) {
        NSMutableDictionary *statusDictEntry = [self.statusDict objectForKey:aggName];
    
        NSNumber *total = [msgDict objectForKey:aggName];
        [statusDictEntry setObject:total forKey:kTotalObjects];
    }
}

#pragma mark -
#pragma mark Server Sync

- (void) syncStart {
    
    if ([self workOffline] && !self.isForcedSync) {
        return;
    }
    
    if (self.isOneSyncFinished && [self currentUserIsDriver]) {
        return;
    }
    
    self.networkOptions = [Settings getSettingAsDictionary:kUserNetworkSyncOptionsKey];
    if( [[self.networkOptions objectForKey:kNetworkSyncKey] boolValue] == FALSE)
        return;
    if(![self isNetworkReachable]||
       ! (([self isNetworkReachableViaWWAN] ) ||
          ([self isNetworkReachableViaWifi] && [[self.networkOptions objectForKey:kWIFICodingKey] boolValue] )) )   {
           self.syncStatus = SYNC_STATUS_COMPLETE;
           for( Aggregate *agg in self.aggregates )
           {
               agg.syncStatus=SYNC_STATUS_COMPLETE;
           }
           return;
       }
    
    NSMutableArray *aggregatesToAutoSync = nil;
    if( [[self.syncOptions valueForKey:kDataSyncManuallyKey] boolValue] == YES && self.isOverrideSyncOptions == NO ) {
        
        aggregatesToAutoSync = [NSMutableArray array];
        
        for( Aggregate *aggToAutoSync in self.aggregates ) {
            if( [aggToAutoSync shouldSyncManually] == NO ) {
                [aggregatesToAutoSync addObject:aggToAutoSync];
            }
        }
        if( [aggregatesToAutoSync count] == 0 )
            return;
    }

    self.isOverrideSyncOptions = NO;
    
    // don't do anything if we don't have a valid username/password combo
    if( [self.userName length] == 0 || [self.userPassword length] == 0 )
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStart" object:nil];
  
    self.isFullSync = YES;
    
    for (NSString *aggKey in self.statusDict.allKeys) {
        NSMutableDictionary *aggStatusDict = [self.statusDict objectForKey:aggKey];
        if ([aggStatusDict isKindOfClass:[NSDictionary class]]) {
            [aggStatusDict removeObjectForKey:kSyncTimeStart];
            [aggStatusDict removeObjectForKey:kSyncTimeEnd];

            [aggStatusDict removeObjectForKey:kUploadTimeStart];
            [aggStatusDict removeObjectForKey:kUploadTimeEnd];
        }
    }
    

    self.syncStatus = SYNC_STATUS_USER_COMPLETE;
    
    [self resetStatus];
    NSString *orgPrefix = [self getOrgPrefix];

    self.syncStatus = SYNC_STATUS_REQUEST;
    
    [self resetStatus];
    
    NSInteger recordsToSync = 0;
    
    for (Aggregate *agg in self.aggregates ) {
        
        if ([self skipAggSync:agg]) {
            agg.syncStatus = SYNC_STATUS_COMPLETE;
            continue;
        }
        
        NSMutableDictionary *sd = [self.statusDict objectForKey:[agg uniqueName]];
        
        if( aggregatesToAutoSync == nil || [aggregatesToAutoSync containsObject:agg] ) {
            [sd setObject:kSyncStatus_CodingRequestStarted forKey:kSyncStatus];
            
                if (!agg.skipSyncRecords) {
                    agg.countCallDone = NO;
                    [agg requestSyncStart];
                    recordsToSync ++;
                } else {
                    agg.syncStatus = SYNC_STATUS_COMPLETE;
                }
        }
        else {
            agg.syncStatus = SYNC_STATUS_CONTENT_COMPLETE;
            [sd setObject:kSyncStatus_ContentComplete forKey:kSyncStatus];
        }
    }
    
    [self calculateSyncProgress];
    
    if (recordsToSync == 0) {
        [self performSelectorOnMainThread:@selector(showFinishSyncMessage) withObject:nil waitUntilDone:YES];
    }
}

-(BOOL)skipAggSync:(Aggregate*)agg {
    
    return NO;
}

- (void) fullSyncStart
{
    if (self.isFullSync || self.isForcedSync) {
        return;
    }
    
    BOOL displaySyncStartedMessage = YES;

    if (self.isAutoSync) {
        // we should check if the user has set display Sync Started message or not
        displaySyncStartedMessage = [self displayAutoSyncMessage];
    }
    
    BOOL hideSyncMessages = [self hideSyncMessages];
    
    if (displaySyncStartedMessage && !hideSyncMessages) {
        NSString *message = NSLocalizedString(SyncMessageStart, nil);
        
        [self showSyncAlert:message];

    }
    
    self.isForcedSync = YES;
    
    if(![self isNetworkReachable]||
       ! (([self isNetworkReachableViaWWAN] ) ||
          ([self isNetworkReachableViaWifi] && [[self.networkOptions objectForKey:kWIFICodingKey] boolValue] )) )   {
           self.syncStatus = SYNC_STATUS_COMPLETE;
           for( Aggregate *agg in self.aggregates )
           {
               agg.syncStatus=SYNC_STATUS_COMPLETE;
           }
           
           self.isFullSync = NO;
           self.isForcedSync = NO;
           return;
       }
    NSMutableArray *aggregatesToSync = nil;
    if(1) {
        
        aggregatesToSync = [NSMutableArray array];
        
        for (Aggregate *aggToSync in self.aggregates ) {
            if ([self skipAggSync:aggToSync]) {
                continue;
            }
            
            if(/* [aggToAutoSync shouldSyncManually] == NO */1) {
                [aggregatesToSync addObject:aggToSync];
                [aggToSync prepareData];
            }
        }
        if( [aggregatesToSync count] == 0 )
            return;
    }
    
    if( [self.userName length] == 0 || [self.userPassword length] == 0 )
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStart" object:[NSNumber numberWithBool:displaySyncStartedMessage]];
    
    self.isFullSync = YES;
    
    for (NSString *aggKey in self.statusDict.allKeys) {
        NSMutableDictionary *aggStatusDict = [self.statusDict objectForKey:aggKey];
        if ([aggStatusDict isKindOfClass:[NSDictionary class]]) {
            [aggStatusDict removeObjectForKey:kSyncTimeStart];
            [aggStatusDict removeObjectForKey:kSyncTimeEnd];

            [aggStatusDict removeObjectForKey:kUploadTimeEnd];
            [aggStatusDict removeObjectForKey:kUploadTimeStart];

            [aggStatusDict removeObjectForKey:kObjectsToUpload];
            [aggStatusDict removeObjectForKey:kObjectsUploaded];
            [aggStatusDict removeObjectForKey:kObjectsUploadedFailed];
        }
    }
    
    self.syncStatus = SYNC_STATUS_USER_COMPLETE;
    
    [self resetStatus];
    
    self.syncStatus = SYNC_STATUS_REQUEST;
    
    [self resetStatus];
    for( Aggregate *agg in self.aggregates )
    {
        if (agg.skipSyncRecords || [self skipAggSync:agg]) {
            agg.syncStatus = SYNC_STATUS_COMPLETE;
            continue;
        }
        
        NSMutableDictionary *sd = [self.statusDict objectForKey:[agg uniqueName]];
        
        if( aggregatesToSync == nil || [aggregatesToSync containsObject:agg] ) {
            [sd setObject:kSyncStatus_CodingRequestStarted forKey:kSyncStatus];
            
                agg.countCallDone = NO;
                [agg requestSyncStart];
        }
        else {
            agg.syncStatus = SYNC_STATUS_CONTENT_COMPLETE;
            [sd setObject:kSyncStatus_ContentComplete forKey:kSyncStatus];
        }
    }
    
    [self calculateSyncProgress];
}

-(void) syncContinue: (Aggregate *) synchedAggregate
{
    if( self.syncStatus == SYNC_STATUS_PAUSED) {
        return;
    }
    
    if ( ! [synchedAggregate shouldSyncManually]) {
        for( Aggregate *agg in self.aggregates )
        {
            if (agg.skipSyncRecords) {
                agg.syncStatus = SYNC_STATUS_COMPLETE;
                continue;
            }
            if( agg.syncStatus < SYNC_STATUS_COMPLETE &&
               (agg.syncStatus <= self.syncStatus || self.syncStatus == SYNC_STATUS_NONE)) {
                
                
                [agg syncStep];
                return;
            }
        }
    } else {
        for( Aggregate *agg in synchedAggregate.detailAggregates ) {
            if (agg.skipSyncRecords) {
                agg.syncStatus = SYNC_STATUS_COMPLETE;
                continue;
            }
            [agg syncStep];
        }
    }
    
    // we're done! move on
    if( self.syncStatus < SYNC_STATUS_COMPLETE && self.syncStatus > SYNC_STATUS_NONE ) {
        
        self.syncStatus = self.syncStatus+1;
    
        // move to next step
        if( self.syncStatus < SYNC_STATUS_COMPLETE)
        {
            self.syncStatus = self.syncStatus+1;
            for( Aggregate *agg in self.aggregates )
            {
                [agg syncStep];
            }
        }
    } else  {
        if ([synchedAggregate shouldSyncManually]) {
            if (self.syncStatus == SYNC_STATUS_COMPLETE) {
                [synchedAggregate syncStep];
            }
        }
    }
}
-(void) syncStop
{
    self.syncStatus = SYNC_STATUS_NONE;

    for( Aggregate *agg in self.aggregates )
    {
        [agg requestSyncStop];
    }
    
    [self.opQueue cancelAllOperations];
    
}

- (void) syncPause
{
    [self syncStop];
    self.syncStatus = SYNC_STATUS_PAUSED;
    
    for( Aggregate *agg in self.aggregates )
    {
        [agg requestSyncPause];
    }

}
-(void) resetDBForNewUser: (Boolean) usePackagedDatabase;
{
    [[NSFileManager defaultManager] removeItemAtURL:[self dataStoreURL] error:nil];
    
    self.usePackagedDatabase = usePackagedDatabase;
}

#pragma mark - Reachability

- (void)registerForNetworkReachabilityNotifications
{
    
    NSString *host = self.server;
    NSArray * comps = [host componentsSeparatedByString:@"//"];
    
    if( [comps count] != 1) {
        self.internetReach = [AFNetworkReachabilityManager managerForDomain:CSD_SERVER];
        NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    }
    else {
        self.internetReach = [AFNetworkReachabilityManager sharedManager];

    }
    
    [self.internetReach startMonitoring];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingReachabilityDidChangeNotification object:nil];

}


- (void)unsubscribeFromNetworkReachabilityNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}


- (BOOL)isNetworkReachable
{
    return (self.networkStatus != AFNetworkReachabilityStatusNotReachable);
}


- (BOOL)isNetworkReachableViaWWAN
{
	return (self.networkStatus == AFNetworkReachabilityStatusReachableViaWWAN);
}

- (BOOL)isNetworkReachableViaWifi
{
	return (self.networkStatus == AFNetworkReachabilityStatusReachableViaWiFi);
}

-(void)showAlert:(NSString*)message {
    [self performSelectorOnMainThread:@selector(_showAlert:) withObject:message waitUntilDone:YES];
}

-(void)showSyncAlert:(NSString*)message {
    [self performSelectorOnMainThread:@selector(_showSyncAlert:) withObject:message waitUntilDone:YES];
}

-(void)_showSyncAlert:(NSString*)message {
    
    BillingAppDelegate *app = (BillingAppDelegate*) [[UIApplication sharedApplication] delegate];
    [app showSyncAlert:message];
}

-(void)_showAlert:(NSString*)message {
    
    if (![self hideSyncMessages]) {
        return;
    }
    
    BOOL useNewLogic = YES;
    if (useNewLogic) {
        BillingAppDelegate *app = (BillingAppDelegate*) [[UIApplication sharedApplication] delegate];
        [app showAlert:message];
        return;
    }
    
    if (self.alert.visible || self.alert) {
        [self.alert dismissWithClickedButtonIndex:0 animated:NO];
        self.alert = nil;
    }
    
    self.alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                             message:message
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
    
    if ([message isEqualToString:NSLocalizedString(@"Synchronization finished!", nil)]) {
        // we should close the alert after 2 seconds
        self.alert.tag = TAG_SYNC_FINISHED;
        [self performSelector:@selector(closeFinishSyncAlert:) withObject:nil afterDelay:2];
    }
    
    [self.alert show];
}

-(void)showAlertSeparatelly:(NSString*)message {
    [self performSelectorOnMainThread:@selector(_showAlertSeparatelly:) withObject:message waitUntilDone:YES];
}

-(void)_showAlertSeparatelly:(NSString*)message {
    
    if (self.alert.visible) {
        [self.alert dismissWithClickedButtonIndex:0 animated:NO];
    }

    UIAlertView *alertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [alertTmp show];
}

-(void)closeFinishSyncAlert:(id)sender {
    
    if (self.alert.visible) {
        if (self.alert.tag == TAG_SYNC_FINISHED) {
            [self.alert dismissWithClickedButtonIndex:0 animated:NO];
        }
    }
}

- (void)reachabilityChanged:(NSNotification *)note
{
    AFNetworkReachabilityStatus prevStatus = self.networkStatus;
    
    self.networkStatus = self.internetReach.networkReachabilityStatus;
    
    if( prevStatus != AFNetworkReachabilityStatusNotReachable && self.networkStatus == AFNetworkReachabilityStatusNotReachable ) {
        [self syncStop];
        
        if (![self workOffline]) {
            NSString *message = @"No Internet Connection available!";
            [self performSelectorOnMainThread:@selector(showAlert:)
                                   withObject:message
                                waitUntilDone:YES];
        }
    }
    
    [self.statusDict setObject:[NSNumber numberWithFloat:self.networkStatus] forKey:kSyncNetworkStatus];

    if( prevStatus == AFNetworkReachabilityStatusReachableViaWiFi && self.networkStatus == AFNetworkReachabilityStatusReachableViaWWAN   )
        [self syncStop];

    if( prevStatus == AFNetworkReachabilityStatusNotReachable && self.networkStatus != AFNetworkReachabilityStatusNotReachable && self.isLoggedIn) {
        [self getUserInfo];
        if (![self workOffline]) {
            NSString *message = @"Internet Connection available!";
            [self performSelectorOnMainThread:@selector(showAlert:)
                                   withObject:message
                                waitUntilDone:YES];
        }
    }
    
    if( prevStatus == AFNetworkReachabilityStatusReachableViaWWAN && self.networkStatus == AFNetworkReachabilityStatusReachableViaWiFi  && self.syncStatus == SYNC_STATUS_NONE  && self.isLoggedIn)
        [self getUserInfo];
    
    if ( prevStatus == AFNetworkReachabilityStatusNotReachable && self.networkStatus != AFNetworkReachabilityStatusNotReachable) {
    }
}

#pragma mark -  Local Data

- (Aggregate *) getAggregateForClass:(NSString *)rcoClass
{
    for (Aggregate *agg in [DataRepository sharedInstance].aggregates )
    {
        if( [[agg.rcoObjectClass lowercaseString] isEqualToString:[rcoClass lowercaseString] ] )
            return agg;
        
        for (Aggregate *detailAgg in agg.detailAggregates )
        {
            if( [[detailAgg.rcoObjectClass lowercaseString] isEqualToString:[rcoClass lowercaseString]] )
                return detailAgg;
        }
    }
    
    return nil;
}

- (Aggregate *) getAggregateForClass: (NSString *) rcoClass andRecordType:(NSString *)rcoRecordType
{
    for (Aggregate *agg in [DataRepository sharedInstance].aggregates )
    {
        if([agg.rcoRecordType isEqualToString:rcoRecordType] &&
           [agg.rcoObjectClass isEqualToString:rcoClass])
            return agg;
        
        for (Aggregate *detailAgg in agg.detailAggregates )
        {
            if([detailAgg.rcoRecordType isEqualToString:rcoRecordType] &&
               [detailAgg.rcoObjectClass isEqualToString:rcoClass] )
                return detailAgg;
        }
    }
    
    return nil;
}

- (Aggregate *) getAggregateForRecordType:(NSString *)rcoRecordType
{
    for (Aggregate *agg in [DataRepository sharedInstance].aggregates )
    {
        if([agg.rcoRecordType isEqualToString:rcoRecordType])
            return agg;
        
        for (Aggregate *detailAgg in agg.detailAggregates )
        {
            if([detailAgg.rcoRecordType isEqualToString:rcoRecordType])
                return detailAgg;
        }
    }
    
    return nil;
}

-(Aggregate*)getHeaderAggregateForAggregate:(Aggregate*)aggregate {
    
    for (Aggregate *agg in self.aggregates) {
        if ([agg.localObjectClass isEqualToString:agg.localObjectClass]) {
            return agg;
        }
        for (Aggregate *detailAgg in agg.detailAggregates) {
            if ([detailAgg.localObjectClass isEqualToString:agg.localObjectClass]) {
                return agg;
            }
        }
    }
    return nil;
}

#pragma mark - Core Data stack

-(void)saveChanges{
    __block NSError *error = nil;
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    [moc performBlock:^{
        if ((moc != nil) && [moc hasChanges] ) {
            
#if DATABASE_SAVE_TIMING
            CFTimeInterval startTime = CACurrentMediaTime();
#endif
            if (![moc save:&error]) {
                
                NSArray* detailedErrors = nil;
                NSDictionary *userInfo = [error userInfo];
                if( userInfo != nil && [userInfo count]) {
                    detailedErrors = [userInfo objectForKey:NSDetailedErrorsKey];
                }
            }
            
            if (moc.parentContext) {
                [moc.parentContext performBlock:^{
                    NSError *error = nil;
                    if (![moc.parentContext save:&error]) {
                    }
                }];
            }
#if DATABASE_SAVE_TIMING
            CFTimeInterval fetchDuration =CACurrentMediaTime() - startTime;
            NSString *threadName =[NSThread currentThread].name;
            if( [threadName length] == 0 ) {
                if( [NSThread isMainThread] ) {
                    threadName = @"Main thread";
                }
                else {
                    threadName = [NSThread currentThread].description;
                }
            }
#endif
        }

        }];
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *curMoc = nil;
    
    NSMutableDictionary *threadDict = [[NSThread mainThread] threadDictionary];
    
    if (threadDict != nil ) {
        curMoc = [threadDict objectForKey:kMobileOfficeKey_MOC];
        
        if (curMoc==nil){
            
            if (! [NSThread isMainThread] ) {
                [self performSelectorOnMainThread:@selector(managedObjectContext:)
                                       withObject:nil
                                    waitUntilDone:YES];
                curMoc = [threadDict objectForKey:kMobileOfficeKey_MOC];
            }
            else {
                NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
                
                if (coordinator != nil) {
                    _masterSaveContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                    [_masterSaveContext performBlockAndWait:^{
                        [_masterSaveContext setPersistentStoreCoordinator:coordinator];
                        [_masterSaveContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                        [_masterSaveContext setName:@"Master Save Context"];
                    }];
                    
                    _mainThreadContex = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                    [_mainThreadContex setParentContext:_masterSaveContext];
                    [_mainThreadContex setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                    [_mainThreadContex setName:@"Main Thread Context"];
                    
                    curMoc = _mainThreadContex;
                    
                    [self setManagedObjectContext:curMoc];
                }
            }
        }
    }
    
    return curMoc;
}
- (void) setManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (! [NSThread isMainThread] ) {
        [self performSelectorOnMainThread:@selector(setManagedObjectContext:)
                               withObject:moc
                            waitUntilDone:YES];
        return;
    }
    
    NSMutableDictionary *threadDict = [[NSThread mainThread] threadDictionary];
    
    if( threadDict != nil ) {
         
        NSManagedObjectContext *currentMoc = [threadDict objectForKey:kMobileOfficeKey_MOC];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        if( currentMoc != nil ) {
            [nc removeObserver:self
                          name:NSManagedObjectContextDidSaveNotification
                        object:currentMoc];
            [threadDict removeObjectForKey:kMobileOfficeKey_MOC];
        }
        
        if( moc != nil ){
            
            [threadDict setObject:moc forKey:kMobileOfficeKey_MOC];
            [nc addObserver:self
                   selector:@selector(saveMasterContext)
                       name:NSManagedObjectContextDidSaveNotification
                     object:moc];
            
            [nc addObserver:self
                   selector:@selector(handleManagedObjectContextDidSaveNotification:)
                       name:NSManagedObjectContextDidSaveNotification
                     object:nil];

        }
    }    
}

- (void)handleManagedObjectContextDidSaveNotification:(NSNotification *)notification {
    NSManagedObjectContext *context = [notification object];
    if (context == _mainThreadContex) {
        return;
        
    }
     [_mainThreadContex performBlock:^{
         [_mainThreadContex mergeChangesFromContextDidSaveNotification:notification];
     }];

    [self saveMasterContext];
}

- (void)saveMasterContext {
    
    [_masterSaveContext performBlockAndWait:^{
        if ([_masterSaveContext hasChanges]) {
            NSError *error = nil;
            [_masterSaveContext save:&error];
            if (error) {
            }
        }
    }];
}

- (void) mergeMocChangesFromBackgroundThread: (NSNotification *) notification {
    
    if ( ![NSThread isMainThread] ) {
        [self performSelectorOnMainThread:@selector(mergeMocChangesFromBackgroundThread:)
                               withObject:notification
                            waitUntilDone:NO];
        return;
    }
    
#if DATABASE_SAVE_TIMING
    CFTimeInterval startTime = CACurrentMediaTime();
#endif
    
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
    
    
#if DATABASE_SAVE_TIMING
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *info = @"";
    if( userInfo ) {
        for( NSString *theKey in [userInfo allKeys]) {
        
            if ([theKey isEqualToString:@"managedObjectContext"]) {
                continue;
            }
            NSArray *objects = [userInfo objectForKey:theKey];
            info = [NSString stringWithFormat:@"%@%@ %d %@", info,[info length] ? @", " : @"", (int)[objects count], theKey];
        }
    }

    CFTimeInterval fetchDuration = CACurrentMediaTime() - startTime;
#endif
   
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (m_managedObjectModel != nil)
    {
        return m_managedObjectModel;
    }
    NSURL *modelURL = nil;
    
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];

     if ([targetName isEqualToString:@"CSD"] || [targetName isEqualToString:@"Accident Form"]) {
        modelURL = [[NSBundle mainBundle] URLForResource:@"CSDModel" withExtension:@"momd"];
    }
    
    m_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return m_managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (m_persistentStoreCoordinator != nil)
    {
        return m_persistentStoreCoordinator;
    }
    
    [self loadDataDir];
    
    NSURL *storeURL = [self dataStoreURL];
    NSError *error = nil;
    NSPersistentStore *theStore = nil;
    
    m_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *migrationOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES],  NSInferMappingModelAutomaticallyOption,
                                      [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                      nil];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        theStore = [m_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                              configuration:nil
                                                                        URL:storeURL
                                                                    options:migrationOptions
                                                                      error:&error];
    }
    
    if( theStore==nil && self.usePackagedDatabase ) {
        [self decompressCompiledDatabase];
        theStore = [m_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                              configuration:nil
                                                                        URL:storeURL
                                                                    options:migrationOptions
                                                                      error:&error];
    }
    
    self.usePackagedDatabase = true;
    
    if( theStore == nil ) {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        theStore = [m_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                              configuration:nil
                                                                        URL:storeURL
                                                                    options:migrationOptions
                                                                      error:&error];
    }
    
    if ( theStore == nil )
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return m_persistentStoreCoordinator;
}

#pragma mark - Database Naming
- (NSString *) dataPathComponent
{
    NSString *orgId = [self orgNumber];
    NSString *orgName = [self orgName];
    
    NSString *dirName = [NSString stringWithFormat:@"%@%@%@", self.server, orgId, orgName];
    
    return dirName;
}

-(void)loadDataDir {
    NSURL * applicationDocuments = [(BillingAppDelegate *)[UIApplication sharedApplication].delegate applicationDocumentsDirectory];
    
    NSString *dirName = [self dataPathComponent];
    
    if( [dirName length] )
    {
        NSURL *url = [applicationDocuments URLByAppendingPathComponent:dirName isDirectory:TRUE];
        
        NSError* error =nil;
        if( [[NSFileManager defaultManager] createDirectoryAtURL:url  withIntermediateDirectories:YES attributes:nil error:&error] ) {
            self.dataDirRCO = url;
            return;
        }
    }
    
    self.dataDirRCO = applicationDocuments;
}

- (NSURL *) dataDir {
    
    if (!self.dataDirRCO) {
        NSLog(@"");
        [self loadDataDir];
    }
    
    return self.dataDirRCO;
}

- (NSURL *) dataStoreURL
{
     NSURL *storeURL = [[self dataDir] URLByAppendingPathComponent:[self databaseName]];

    return storeURL;
}

- (NSString *) databaseName {
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    if ([targetName isEqualToString:@"CSD"] || [targetName isEqualToString:@"Accident Form"]) {
        return @"CSDModel.sqlite";
    }
    return nil;
}

- (void) decompressCompiledDatabase
{
    {
        NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
        
        NSString *dataPathComponent = [self dataPathComponent];
        dataPathComponent = [dataPathComponent stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        NSString *zipName = @"CSDModel.sqlite.zip";
        
        NSURL *zipFileUrl = [bundleURL URLByAppendingPathComponent:[NSString stringWithFormat:zipName,
                                                                    dataPathComponent,
                                                                    [self databaseName]]];
        
        zipFileUrl = [[NSBundle mainBundle] URLForResource:@"CSDModel.sqlite" withExtension:@"zip"];
        
        NSString* zipFilePath = [zipFileUrl path];
        
        NSString *output = [[self dataDir] path];
        
        ZipArchive* za = [[ZipArchive alloc] init];
        
        if( [za UnzipOpenFile:zipFilePath] ) {
            if( [za UnzipFileTo:output overWrite:YES] != NO ) {
                //unzip data success
                NSLog(@"success");
            }
            [za UnzipCloseFile];
        }        
    }
}

#pragma mark - Database related settings



-(NSString*)getPrimaryKeyTitle {
    return [Settings getSetting:kDatabaseItemPrimaryKeyTitle];
}

-(NSString*)getPrimaryKeyField {
    return [Settings getSetting:kDatabasePrimaryKeyCodingField];
}


-(NSString*)getVendorReturnShippingStore {
    return nil;
}

-(NSString*)getUpdateLocation {
    return [Settings getSetting:kUpdateLatitudeLongtitude];
}

-(NSString*)getNonTrackPartPrefix {
    return nil;
}

-(NSString*)getOrgPrefix {
    return [Settings getSetting:kOrgPrefix];
}

-(NSString*)getNonTrackPartMaxQuantity {
    return nil;
}

-(NSString*)getNonTrackPartDefaultQuantity {
    return nil;
}

-(NSString*)getShowInvoicePhotos {
    return nil;
}

-(NSString*)getShowInvoiceContract {
    return nil;
}

-(NSString*)getShowInvoiceLegal {
    return nil;
}

-(NSString*)getSortType {
    return nil;
}


-(BOOL) getSyncCheckForDeletions {
    NSString *checkForDeletions =[Settings getSetting:kDatabaseSyncCheckForDeletions];
    return [checkForDeletions boolValue];
}


- (NSArray*)getUserRoles {
    return [Settings getSettingAsArray:USER_ROLES];
}


-(void)getDatabaseNodeInfo_ARC {
   
}

-(void)getAccountingSetupNodeInfo {
}

-(void)getDatabaseNodeInfo {
    return [self getDatabaseNodeInfo_ARC];
}

-(void)getDatabaseSettings_ARC:(NSString*)objectId forObjectType:(NSString*)objectType {
    
}

-(void)updateDatabaseSettings_ARC:(NSArray*)fieldValues {
    
}

-(BOOL)laborUseSimpleForm {
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self locationManager:manager updateToLocation:[locations lastObject] fromLocation:nil];
}

- (void)locationManager:(CLLocationManager *)manager updateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    // TODO Check if "GPSLocationServices" is enabled for current user!
    
    CLLocationDegrees latitude = newLocation.coordinate.latitude;
    CLLocationDegrees longitude = newLocation.coordinate.longitude;
        
    _lat  = latitude;
    _long = longitude;
    _speed = manager.location.speed;
        NSTimeInterval delta = [[NSDate date] timeIntervalSince1970] - [self.currentDate timeIntervalSince1970];
    
    if (delta > 1*60) {
        if ([self.userType isEqualToString:kUserTypeTechnician]) {
        }
        
        if ([self.currentTruckId length]) {
            // update truck location
        }
        self.currentDate = [NSDate date];
    }
    
    // we should try to relounch the background task
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [self reinstateBackgroundTask];
    }
}

-(NSNumber*)getCurrentLatitude:(BOOL)removeValue {

        return [self getCurrentLatitude];
}

-(NSNumber*)getCurrentLongitude:(BOOL)removeValue {
    
        return [self getCurrentLongitude];
}


-(NSNumber*)getCurrentLatitudeForELD {
    
}

-(NSNumber*)getCurrentLatitude {
    if (TARGET_IPHONE_SIMULATOR) {
        static int i = 0;
        _lat = 34.034738;
        _lat += i*0.001;
        i++;
    }
    

        return [NSNumber numberWithDouble:_lat];
}


-(NSNumber*)getCurrentLongitude {
    if (TARGET_IPHONE_SIMULATOR) {
        static int i = 0;
        _long = -118.481451;
        _long -= i*0.001;
        i++;
    }
    

        return [NSNumber numberWithDouble:_long];
}

#pragma mark -
#pragma mark Updateting methods

#pragma mark Distance



-(NSNumber*)normalizeValue:(NSNumber*)val {
    if (!val) {
        return [NSNumber numberWithInt:0];
    } else {
        return val;
    }
}


-(BOOL)skipUpdating {
        return YES;
}

-(BOOL)isTrainingTestInfoActive {
    NSString *testInfo = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (testInfo.length) {
        self.trainingInfo = 1;
    }
        
    if (self.trainingInfo == -1) {
        return NO;
    }
    return YES;
}

-(BOOL)isTrainingInfoPaused {
    if (!self.trainingInfoStatus) {
        // this is done at the start of the app
        NSDate *pauseDate = [Settings getSettingAsDate:CSD_TEST_INFO_PAUSE_DATE];
        if (pauseDate) {
            self.trainingInfoStatus = 1;
        } else {
            self.trainingInfoStatus = -1;
        }
    }
    if (self.trainingInfoStatus > 0) {
        return YES;
    } else {
        return NO;
    }
}

-(void)setTrainingTestInfoPaused:(NSInteger)paused {
    self.trainingInfoStatus = paused;
}

-(void)resetTrainingTestInfo {
    self.trainingInfo = -1;
    self.trainingInfoPositions = [NSMutableArray array];
}

-(NSArray*)getTrainingTestInfoLog {
    return self.trainingInfoPositions;
}


-(NSString*)mimeTypeBasedOnFileExtension:(NSString*)fileName {
    return nil;
}

-(void)setNewUserRecordId:(NSString *)usrRecordId {
    self.userRecordIdRCO = usrRecordId;
}

-(void)checkAutoSyncFunctionality {
    
}


-(void)startAutoSync {
}

-(void)sendAlertMessage:(NSString*)message withTitle:(NSString*)title {
}

#pragma mark Scanner Delegate Methods


-(void)onTimer:(id)sender {
}




#pragma mark Register Scanners

-(BOOL)useLocationRecordId {
    // this is set to YES when we have the caching set to: storeName-storeRecordId
    return YES;
}


-(void)setLoginCallFailed {
    _loginFailed = YES;
}

-(BOOL)getLoginCallFailed {
    return  _loginFailed;
}

-(void)resetTruckLog {
}


#pragma mark HTTPClientDelegate Methods

-(void)HTTPClient:(HTTPClient *)client didFinished:(id)resp {
    

    NSString *msg = [client.userInfo objectForKey:@"message"];
    NSString *objDesc = nil;
    
    if ([resp isKindOfClass:[NSData class]]) {
        objDesc = [[NSString alloc] initWithData:(NSData *)resp encoding:NSUTF8StringEncoding];
    } else {
    }
    
    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, resp, RESPONSE_OBJ, client.baseURL, RESPONSE_CALL, objDesc, RESPONSE_STR, nil];
    
    [self requestFinished:respDict];
}

-(void)HTTPClientOperationDidFinishedForced:(HttpClientOperation *)client {
    NSString *msg = [client.userInfo objectForKey:@"message"];
    
    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, nil];
    
    [self requestFinished:respDict];

}
-(void)HTTPClientOperation:(HttpClientOperation *)client didFinished:(id)resp {
    
    NSString *msg = [client.userInfo objectForKey:@"message"];
    
    NSString *objDesc = nil;
    
    if ([resp isKindOfClass:[NSData class]]) {
        objDesc = [[NSString alloc] initWithData:(NSData *)resp encoding:NSUTF8StringEncoding];
    } else {
    }

    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, resp, RESPONSE_OBJ, client.request.URL, RESPONSE_CALL, objDesc, RESPONSE_STR, nil];

    [self requestFinished:respDict];
}

-(void)HTTPClient:(HTTPClient *)client didFailWithError:(NSDictionary *)errorInfoDict {
    NSError *error = [errorInfoDict  objectForKey:ERROR_KEY];
    NSInteger httpErrorCode = [[errorInfoDict objectForKey:ERROR_STATUS_CODE] integerValue];
    NSString *message = [client.userInfo objectForKey:@"message"];
    
    if (httpErrorCode == 200) {
        // we should not forward failed message, because is a json error
        return;
    }
    
    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, client.baseURL, RESPONSE_CALL, nil];

    
    [self requestFailed:respDict];
}

-(void)HTTPClientOperation:(HttpClientOperation *)client didFailWithError:(NSDictionary *)errorInfoDict {
    //NSError *error = [errorInfoDict  objectForKey:ERROR_KEY];
    NSInteger httpErrorCode = [[errorInfoDict objectForKey:ERROR_STATUS_CODE] integerValue];
    NSString *message = [client.userInfo objectForKey:@"message"];
    if (httpErrorCode == 200) {
        // we should not forward failed message, because is a json error
        return;
    }
    
    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, client.request.URL, RESPONSE_CALL, [errorInfoDict objectForKey:ERROR_STATUS_CODE], ERROR_STATUS_CODE, nil];
    
    [self requestFailed:respDict];
}

-(NSString*)getResponseStringFromRequest:(id)request {
    NSString *respStr = nil;
    {
        NSDictionary *respDict = (NSDictionary*)request;
        respStr = [respDict objectForKey:RESPONSE_STR];
    }
    return respStr;

}

-(NSString*)getErrorFromRequestResponse:(id)request {
    NSString *errorStr = nil;
    {
        NSDictionary *respDict = (NSDictionary*)request;
        NSError *error = [respDict objectForKey:ERROR_KEY];
        errorStr = error.description;
    }
    return errorStr;
}

-(NSString*)getCallURLFromRequestResponse:(id)request {
    NSString *callURL = nil;
    {
        NSDictionary *respDict = (NSDictionary*)request;
        callURL = [respDict objectForKey:RESPONSE_CALL];
    }
    
    return callURL;
}

-(NSDictionary*)getMsgDictFromRequestResponse:(id)request {
    NSDictionary *msgDict = nil;
    {
        NSDictionary *respDict = (NSDictionary*)request;
        msgDict = [respDict objectForKey:RESPONSE_USER_INFO];
    }
    
    return msgDict;
}

-(NSInteger)getStatusCodeFromRequestResponse:(id)request {
    NSInteger statusCode = 0;
    {
        NSDictionary *respDict = (NSDictionary*)request;
        statusCode = [[respDict objectForKey:ERROR_STATUS_CODE] integerValue];
    }
    
    return statusCode;
}

-(NSDictionary*)JSONDictionaryFromRequestResponse:(id)request error:(NSError**)error {
    NSDictionary* resDict = nil;
    
    if ([request isKindOfClass:[NSDictionary class]]) {
        NSDictionary *respDict = (NSDictionary*)request;
        
        id respObj = [respDict objectForKey:RESPONSE_OBJ];
        
        if ([respObj isKindOfClass:[NSDictionary class]]) {
            resDict = (NSDictionary*)respObj;
        } else if ([respObj isKindOfClass:[NSData class]]) {
            NSError *error = nil;
            resDict = [NSJSONSerialization JSONObjectWithData:(NSData*)respObj
                                                      options:NSJSONReadingMutableContainers
                                                        error:&error];
        }
    }
    
    return resDict;
}

-(NSArray*)JSONArrayFromRequestResponse:(id)request error:(NSError**)error{
    NSArray* fieldValues = nil;
    
    if ([request isKindOfClass:[NSDictionary class]]) {
        NSDictionary *respDict = (NSDictionary*)request;
        id respObj = [respDict objectForKey:RESPONSE_OBJ];
        
        if ([respObj isKindOfClass:[NSArray class]]) {
            fieldValues = (NSArray*)respObj;
        } else if ([respObj isKindOfClass:[NSData class]]){
            NSError *error = nil;
            fieldValues = [NSJSONSerialization JSONObjectWithData:(NSData*)respObj
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
        }
    }
    
    return fieldValues;
}


-(NSError*)getErrorObjFromRequestResponse:(id)request {
    NSError *error = nil;

     NSDictionary *respDict = (NSDictionary*)request;
     error = [respDict objectForKey:ERROR_KEY];
    
    return error;
}

#pragma mark OBD2 Methods



-(NSString*)deviceId {
    if (self.mobileDeviceIDRCO.length) {
        return self.mobileDeviceIDRCO;
    }
    self.mobileDeviceIDRCO = [Settings getSetting:MOBILE_DEVICE_ID];
    return self.mobileDeviceIDRCO;
}

-(NSString*)orgNumber {
    if (self.orgNumberRCO.length) {
        return self.orgNumberRCO;
    }
    self.orgNumberRCO = [Settings getSetting:CLIENT_ORGANIZATION_ID];
    return self.orgNumberRCO;
}

-(NSString*)orgName {
    if (self.orgNameRCO.length) {
        return self.orgNameRCO;
    }
    self.orgNameRCO = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    return self.orgNameRCO;
}

- (void)setDeviceId:(NSString*)did {
    self.mobileDeviceIDRCO = did;
}

-(BOOL)workOffline {
    if (self.workOfflineRCO == WorkOffLineNotSet) {
        NSString *val = [Settings getSetting:WorkOffline];
        self.workOfflineRCO = [val boolValue];
    }
    return self.workOfflineRCO;
}

- (void)setWorkOffline:(BOOL)offline {
    self.workOfflineRCO = offline;
}

-(BOOL)forcedSync {
    return self.isForcedSync;
}

-(void)setRights:(NSArray*)rights {
    self.userRights = rights;
}


#pragma mark Sync Configurations

-(BOOL)isNewSyncImplementation {
    //return NO;
    return YES;
}

-(BOOL)useNewSyncJustAtBeggining {
    return NO;
    //return YES;
}

-(BOOL)isTheSameUserLogged {
    return self.isSameUser;
}

-(BOOL)hideSyncMessages {
    BOOL hideSyncMessages = NO;
    NSString *hideSyncValue = [Settings getSetting:HIDE_SYNC_MESSAGES];
    
    if (hideSyncValue.length) {
        hideSyncMessages = [hideSyncValue boolValue];
    }
    return hideSyncMessages;
}

@end
