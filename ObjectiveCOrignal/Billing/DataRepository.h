//
//  DataRepository.h
//  TabBarBilling
//
//  Singleton for access to data entities
//
//  Created by Herman on 2011-04-04.
//  Copyright 2011 Tuvalu Software. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "AFNetworkReachabilityManager.h"

#import "DatabaseControlDelegate.h"
#import "UserAggregate.h"

#import <CoreLocation/CoreLocation.h>
#import "HelperUtility.h"


#define TAG_SYNC_FINISHED -7766

#define S_S @"S_S"
#define S_C_L @"S_C_L"
#define S_C_R @"S_C_R"
#define S_G_I @"S_G_I"
#define S_G_U_I @"S_G_U_I"

#define KAdminToken @"admin/login/token/"

#define US @"US"
#define US_C_P @"US_C_P"
#define US_G_F_G_M @"US_G_F_G_M"
#define US_G_F_G_MA @"US_G_F_G_MA"

#define M_S @"MS"
#define T_S @"TM"
#define A_S @"AS"

#define M_G_D_I @"DI"

#define kObjectsSynced @"key_objectsSynced"
#define kObjectsFailed @"key_objectsFailed"
#define kObjectsToSync @"key_objectsToSync"
#define kTotalObjects @"key_totalObjects"

#define kObjectsToUpload @"key_objectsToUpload"
#define kObjectsUploaded @"key_ObjectsUploaded"
#define kObjectsUploadedFailed @"key_ObjectsUploadedFailed"
#define kTotalObjectsToUpload @"key_totalObjectsToUpload"

#define kFilesSynced @"key_filesSynced"
#define kFilesFailed @"key_filesFailed"
#define kFilesToSync @"key_filesToSync"
#define kSyncStatus @"key_syncStatus"
#define kSyncProgress @"key_syncProgress"
#define kSyncNetworkStatus @"key_syncNetworkStatus"
#define kSyncStatus_None @"Not yet synchronized."
#define kSyncStatus_CodingRequestStarted @"Requesting updates..."
#define kSyncStatus_CodingRequestComplete @"Received updates."
#define kSyncStatus_CodingStarted @"Updating records..."
#define kSyncStatus_CodingComplete @"All records updated."
#define kSyncStatus_ContentStarted @"Downloading files..."
#define kSyncStatus_ContentComplete @"All records and files updated."
#define kSyncTimeStart @"startSyncDate"
#define kSyncTimeEnd @"endSyncDate"

#define kUploadTimeStart @"startUploadDate"
#define kUploadTimeEnd @"endUploadDate"


#define kDatabasePrimaryKeyCodingField @"Item Primary Key Coding Field"
#define kDatabaseSyncCheckForDeletions @"SyncCheckForDeletions"
#define kDatabaseItemPrimaryKeyTitle @"Item Primary Key Title"

#define kUpdateLatitudeLongtitude @"UpdateLatitudeLongitude"


#define kOrgPrefix @"OrgPrefix"

#define kKeySyncLogging @"SyncLogging"

#define WorkOffline @"WorkOffline"

#define NotificationStartOfflineMove @"NotificationStartOfflineMove"
#define NotificationSynchronizationFinised @"NotificationSynchronizationFinised"
#define NotificationShowLoginScreen @"NotificationShowLoginScreen"


#define CSD_TEST_PAUSED_DATE @"CSD_TEST_PAUSED_DATE"


#define SMS_GROUP @"SMS_GROUP"

#define SyncMessageStart @"Synchronization started, while synchronizing application might become unresponsive, please wait..."
#define SyncMessageEnd @"Synchronization finished!"

enum _SYNC_STATUS {SYNC_STATUS_PAUSED = -1,
    SYNC_STATUS_NONE = 0,
    SYNC_STATUS_USER_ID,
    SYNC_STATUS_USER_CODING,
    SYNC_STATUS_USER_RIGHTS,
    SYNC_STATUS_USER_FUNCTIONAL_MEMBERS,
    SYNC_STATUS_USER_FUNCTIONAL_MAP,
    SYNC_STATUS_USER_DEVICE_ID,
    SYNC_STATUS_USER_COMPLETE,
    SYNC_STATUS_REQUEST,
    SYNC_STATUS_REQUEST_COMPLETE,
    SYNC_STATUS_CODING,
    SYNC_STATUS_CODING_COMPLETE,
    SYNC_STATUS_CONTENT,
    SYNC_STATUS_COMPLETE};

typedef int SYNC_STATUS;
#define SYNC_STATUS_CONTENT_COMPLETE SYNC_STATUS_COMPLETE


@class PhotosAggregate;


@interface DataRepository : NSObject  <HTTPClientDelegate, HTTPClientOperationDelegate, RCODataDelegate, CLLocationManagerDelegate> {

        // set in settings
    NSString* m_userName;
    NSString* m_userPassword;
    NSString* m_server;
    
    // info about the user retrieved from server
    NSString *m_userId;
    NSString *m_userRecordId;
    NSString *m_userFirstName;
    NSString *m_userLastName;
    NSArray *m_userRights;
    BOOL m_isLoggedIn;

    SYNC_STATUS m_syncStatus;
    NSMutableDictionary *m_statusDict;
    
    NSString *currentStoreNumber;
    
    
	@private
    NSOperationQueue* _opQueue;
    NSMutableArray * m_aggregates;
    PhotosAggregate *_photosAggregate;
    
    AFNetworkReachabilityStatus m_networkStatus;
    AFNetworkReachabilityManager *m_internetReach;
    AFNetworkReachabilityManager *m_hostReach;
    NSMutableDictionary *m_syncOptions;

    NSDictionary *m_networkOptions;
    CLLocationManager *_locationManager;
    
    double _lat;
    double _long;
    double _speed;
    
    BOOL _scannerDetected;
    
    BOOL _loginFailed;
    
    NSManagedObjectContext *_masterSaveContext;
    NSManagedObjectContext *_mainThreadContext;
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong, readonly) NSManagedObjectContext *masterSaveContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainThreadContex;

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) CLLocationManager *locationManager;

// cloud data
@property (readonly, strong) NSString* server;

// current truck info
@property (readonly, strong) NSString* currentTruckId;
@property (readonly, strong) NSString* currentTruckObjectType;

// current user info
@property (readonly, strong) NSString* userName;
@property (readonly, strong) NSString* userPassword;
@property (readonly, strong) NSString* userRecordId;
@property (readonly, strong) NSString* userId;
@property (readonly, strong) NSString* userFirstName;
@property (readonly, strong) NSString* userLastName;
@property (readonly, strong) NSString* userType;

@property (readonly, strong) NSNumber* sendGPSLocation;
@property (readonly, strong) NSArray* userRights;
@property (readonly, strong) NSDictionary* functionalRecordTypeMap;

@property (assign) BOOL isLoggedIn;

//@property (readwrite, retain) NSDictionary* syncOptions;
@property (readwrite, strong) NSMutableDictionary* syncOptions;

@property (readwrite, strong) NSDictionary* networkOptions;
@property (readwrite) AFNetworkReachabilityStatus networkStatus;
@property (nonatomic, strong) AFNetworkReachabilityManager *internetReach;
@property (nonatomic, strong) AFNetworkReachabilityManager *hostReach;

@property (readwrite, nonatomic, strong) NSString *currentStoreNumber;
//@property (nonatomic, readonly, retain) ASINetworkQueue* asiQueue;
@property (nonatomic, readonly, retain) NSOperationQueue* opQueue;
@property (nonatomic, readonly, strong) NSMutableArray * aggregates;
@property (nonatomic, readwrite, strong) NSMutableDictionary * statusDict;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

// local data
@property (readonly, strong) PhotosAggregate *photosAggregate;


@property (readwrite) SYNC_STATUS syncStatus;
@property (weak, readonly) NSString *syncStatusDescription;

// scanner properties

@property (nonatomic, strong) User *loggedUser;


+(DataRepository*) sharedInstance;

+(BOOL)isIphonePlus;

// login information
- (Boolean) testConnection: (NSString *) server 
              withUserName: (NSString *) uName 
               andPassword: (NSString *) uPassword 
                callBackTo: (id<HTTPClientOperationDelegate>) delegate;

- (Boolean) emailPassword: (NSString *) uName;

- (void)changePasswordForUser:(NSString*)uName 
                  oldPassword:(NSString*)oldPsswd 
                       userId:(NSString*)usrId 
                  newPassword:(NSString*)newPsswd
                   callBackTo:(id<HTTPClientOperationDelegate>) delegate;

- (void) initUser;
- (void) setUser: (NSString*) userName withPassword: (NSString*) password andServer: (NSString *) server;
- (void) getFunctionalGroupMembers;

- (NSString *)getLoggedUserRecordId;
- (NSString*)getLoggedUserLastName;
- (NSString*)getLoggedUserFirstName;
- (NSString*)getLoggedUserLogin;

- (NSString *)getLoggedUserEmployeeId;

- (NSArray*)getUserRoles;

- (NSString*)deviceId;
- (NSString*)orgNumber;

- (NSString*)orgName;
- (BOOL)fullSyncInProgress;

- (void)setDeviceId:(NSString*)did;

- (void)setWorkOffline:(BOOL)online;
- (void) startUnloadingUserAggregates: (id<DatabaseControlDelegate>) caller returnMsg: (NSString *) msg;
- (void) finishUnloadingUserAggregates: (NSDictionary *) callerDict;

- (id ) uploadObjectContentForObjectId: (NSString *)objId objectType:(NSString*)objectType filePath: (NSString *) filePath;

- (id ) askTheCloudFor: (NSString *) urlString
                            withMsg: (NSString *) msg 
                         andObject: (NSString *) objId
                         callBackTo: (id<HTTPClientOperationDelegate>) delegate;

- (id ) askTheCloudFor: (NSString *) msgClass 
                            withMsg: (NSString *) msg 
                         withParams: (NSString *) params 
                          andObject: (NSString *) objId
                         callBackTo: (id<HTTPClientOperationDelegate>) delegate;
- (id ) askTheCloudFor: (NSString *) urlString
               withMsg: (NSString *) msg
             andObject: (NSString *) objId
            callBackTo: (id<HTTPClientDelegate, HTTPClientOperationDelegate>) delegate
              withInfo:(NSString*)info;

- (id ) askTheCloudFor: (NSString *) msgClass 
                   withMsg: (NSString *) msg 
                withParams: (NSString *) params 
                 andObject: (NSString *) objId
                    saveTo: (NSString *) downloadPath
           showingProgress: (BOOL) showProgress
                         callBackTo: (id<HTTPClientOperationDelegate>) delegate
                   withHighPriority: (BOOL) highPriority; 


- (id ) tellTheCloud: (NSString *) msgClass 
                 withMsg: (NSString *) msg 
              withParams: (NSString *) params 
                withData: (NSData *) data
                withFile: (NSString *) filePath
               andObject: (NSString *) objId 
              callBackTo: (id<HTTPClientDelegate>) delegate;

- (id ) tellTheCloud: (NSString *) msgClass
                          withMsg: (NSString *) msg
                       withParams: (NSString *) params
                         withData: (NSData *) data
                         withFile: (NSString *) filePath
                        andObject: (NSString *) objId
                       callBackTo: (id<HTTPClientDelegate>) delegate
                        extraInfo:(NSDictionary*)extraInfo;

-(void)getCityLocatorForCurrentLocation;
-(void)getCityLocatorForLocation:(NSString*)latitude andLongitude:(NSString*)longitude andRecordId:(NSString*)recordId;
-(NSString*)getRecentCityLocator;
-(NSString*)getRecentCityLocatorForRecord:(NSString*)recordId;

// handling synch to cloud for current user
- (void) getUserInfoWithSyncOverride;
- (void) getUserInfo;
- (void) syncStart;
- (void) fullSyncStart;
- (void) syncContinue: (Aggregate *) synchedAggregate;
- (void) syncStop;
- (void) syncPause;
- (NSString *) descriptionForSyncStatus: (SYNC_STATUS) ss;
- (void) resetDBForNewUser: (Boolean) usePackagedDatabase;
- (void) getDeviceId;

- (void) getFileFromLocalWebServer: (NSDictionary*)callParams;
- (void) getTruckSensorsNow: (NSDictionary*)callParams;

-(void)sendAlertMessage:(NSString*)message withTitle:(NSString*)title;

// reachability
- (BOOL)isNetworkReachable;
- (BOOL)isNetworkReachableViaWWAN;
- (BOOL)isNetworkReachableViaWifi;

// RCO Data Delegate: callbacks from aggregates: status
- (void) objectSyncComplete: (Aggregate *) fromAggregate;
- (void) contentSyncComplete: (Aggregate *) fromAggregate;
- (void) calculateSyncProgress;
- (void) resetStatus;
- (void) resetAggregates;
- (void) updateObjectCountForAggregate:  (NSDictionary *) msgDict;

// sync with server
// call backs from the connection object
- (void)requestStarted:(id )request;
- (void)requestFinished:(id )request;
- (void)requestFailed:(id )request;

- (Aggregate *) getAggregateForClass: (NSString *) rcoClass;
- (Aggregate *) getAggregateForClass: (NSString *) rcoClass andRecordType:(NSString *)rcoRecordType;
- (Aggregate *) getAggregateForRecordType:(NSString *)rcoRecordType;

- (Aggregate *) getHeaderAggregateForAggregate:(Aggregate*)aggregate;

- (NSURL *) dataDir;
- (void) mergeMocChangesToBackgroundThreads: (NSNotification *) notification;
- (void) mergeMocChangesFromBackgroundThread: (NSNotification *) notification;


-(void)saveChanges;

-(void)getDatabaseNodeInfo;

-(void)getDatabaseSettings:(NSString*)objectId forObjectType:(NSString*)objectType;

-(NSString*)getLibraryItemSearchCodingField;

-(NSString*)getBoxItemSearchCodingField;


-(NSString*)getPrimaryKeyTitle;

-(NSString*)getPrimaryKeyField;

-(NSString*)getAddCustomerAndStore;

-(BOOL)getSyncCheckForDeletions;

-(NSString*)getOrgPrefix;

-(NSString*)getSyncLogging;


-(NSNumber*)getCurrentLatitude;
-(NSNumber*)getCurrentLongitude;

-(NSString*)loggedUserRecordId;
-(NSString*)loggedUserUserType;
-(BOOL)currentUserIsDriver;

-(NSString*)getResponseStringFromRequest:(id)request;
-(NSString*)getErrorFromRequestResponse:(id)request;
-(NSString*)getCallURLFromRequestResponse:(id)request;

-(NSDictionary*)getMsgDictFromRequestResponse:(id)request;
-(NSInteger)getStatusCodeFromRequestResponse:(id)request;
-(NSDictionary*)JSONDictionaryFromRequestResponse:(id)request error:(NSError**)error;
-(NSArray*)JSONArrayFromRequestResponse:(id)request error:(NSError**)error;
-(NSError*)getErrorObjFromRequestResponse:(id)request;
-(BOOL)displayFillCommandSimple;

-(BOOL)workOffline;
-(BOOL)forcedSync;

-(void)setLoginCallFailed;

//logged User Helpers
-(UserAggregate*)getUserAggregateAvailable;
-(UserAggregate*)getUserAggregateAvailablePlus;
-(NSArray*)DEBUG_getUserAggregateAvailableInfos;
-(User*)getUserLoggedIn;
-(void)setNewUserRecordId:(NSString *)userRecordId;
-(BOOL)isRightAvailable:(NSString*)right;

-(void)sendSMS:(NSString*)sms toFunctionalGroup:(NSString*)functionalGroupName;
    

-(BOOL)isNewSyncImplementation;
-(BOOL)useNewSyncJustAtBeggining;
-(BOOL)isTheSameUserLogged;

-(BOOL)hideSyncMessages;
    
#pragma Mark Training
-(void)resetTrainingTestInfo;
-(NSArray*)getTrainingTestInfoLog;
-(BOOL)isTrainingInfoPaused;
-(void)setTrainingTestInfoPaused:(NSInteger)paused;
-(double)getAccelerationForAxis:(NSString*)axis;
-(void)setRights:(NSArray*)rights;
@end


