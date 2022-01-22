//
//  Settings.h
//  Billing
//
//  Created by .R.H. on 7/3/11.
//  Copyright 2011 RCO All rights reserved.
//

#import <Foundation/Foundation.h>

#define TIMEOUT_KEY @"TIMEOUT_KEY"

#define CLIENT_USER_RECORDID_KEY @"RCO_RECORD_KEY"
#define CLIENT_USER_EMPLOYEEID_KEY @"RCO_EMPLOYEEID_KEY"
#define CLIENT_USER_FIRST_NAME_KEY @"CLIENT_USER_FIRST_NAME_KEY"
#define CLIENT_USER_LAST_NAME_KEY @"CLIENT_USER_LAST_NAME_KEY"

#define CLIENT2_USER_RECORDID_KEY @"RCO2_RECORD_KEY"

#define CLIENT_LOGIN_KEY @"CLIENT_LOGIN_KEY"
#define CLIENT2_LOGIN_KEY @"CLIENT2_LOGIN_KEY"

#define CLIENT_PASSWORD_KEY @"CLIENT_PASSWORD_KEY"
#define CLIENT2_PASSWORD_KEY @"CLIENT2_PASSWORD_KEY"

// when having codriver
#define CLIENT_SELECTED @"CLIENT_SELECTED"
#define CLIENT2_SELECTED @"CLIENT2_SELECTED"


#define SERVER_URL_KEY @"SERVER_URL_KEY"
#define CLIENT_USERID_KEY @"RCO222_KEY"
#define CLIENT_REMEMBER_PASSWORD @"rememberPassword"

#define CLIENT_OBJIDTYPE_KEY @"RCO223_KEY"
#define CLIENT_RIGHTS_KEY @"CLIENT_RIGHTS_KEY"

#define CLIENT_ORGANIZATION_NAME @"ORAGANIZATION_NAME"
#define CLIENT_COMPANY_NAME @"CLIENT_COMPANY_NAME"
#define CLIENT_ORGANIZATION_ID @"ORAGANIZATION_ID"
#define USER_ROLES @"USER_ROLES"
#define USER_TYPE @"USER_TYPE"
#define USER_SUB_TYPE @"USER_SUB_TYPE"


#define FUNCTIONALGROUP_IDS @"RMS_FUNCTIONALGROUP_IDS"
#define FUNCTIONALGROUP_RECORD_TYPE_MAP @"RMS_FUNCTIONALGROUP_RECORD_TYPE_MAP"


#define LOG_LEVEL @"LogLevel"

#define DEFAULT_STORE @"defaultStore"
#define DEFAULT_STORE_TO_SYNC_PARTS_FROM @"defaultStoreToSyncPartsFrom"

#define MOBILE_DEVICE_ID @"mobileDeviceId"

// data sync options: dictionary with following keys
#define kDataSyncOptionsKey @"syncDataOptions"
#define kDataSyncManuallyKey @"manuallySyncAllData"
#define kDataSyncManuallyKeyPrefix @"manuallySync"

// network sync options: dictionary with following keys
#define kUserNetworkSyncOptionsKey @"syncNetworkOptions"
#define kNetworkSyncKey @"syncWithNetwork"

#define kWIFIFileKey @"WIFIFile"
#define kWIFIContentKey @"WIFIContent"
#define kWIFICodingKey @"WIFICoding"

#define kJobsSelectionDate @"jobsSelectionDate"

#define CSD_SERVER @"https://certified-safe-driv-19849.botics.co/api/v1/"

#define LocalNotificationEventId @"localNotificationEventId"

#define kTruckGPSServicesKey @"TruckGPSServices"
#define kDeliveryStatusesKey @"DeliveryStatuses"
#define kDeliveryArrivalTimeDelayKey @"Arrival Time Delay"
#define kUpdateTruckPositionTimeKey @"UpdateTruckPositionTime"

// used to start an auto sync
#define kAutoSyncFrequenceInMinutes @"AutoSyncFrequenceInMinutes"
#define kAutoSyncDisplayMessage @"AutoSyncDisplayMessage"

#define SettingsSpeedTrigger @"Speed Trigger"
#define SettingsTemperatureHighTrigger @"Temperature High Trigger"
#define SettingsTemperatureLowTrigger @"Temperature Low Trigger"

#define DisplayFillCommandSimple @"DisplayFillCommandSimple"

#define WorkOffline @"WorkOffline"

#define DeviceAccessToken @"AccessToken"

#define CSD_PREV_INSTRUCTOR @"CSD_PREV_INSTRUCTOR"
#define CSD_PREV_INSTRUCTOR_ID @"CSD_PREV_INSTRUCTOR_ID"
#define CSD_PREV_STUDENT @"CSD_PREV_STUDENT"
#define CSD_PREV_STUDENT_ID @"CSD_PREV_STUDENT_ID"

#define CSD_ACCIDENT_DRIVER_FIRST_NAME @"CSD_ACCIDENT_DRIVER_FIRST_NAME"
#define CSD_ACCIDENT_DRIVER_LAST_NAME @"CSD_ACCIDENT_DRIVER_LAST_NAME"
#define CSD_ACCIDENT_DRIVER_EMPLOYEE_ID @"CSD_ACCIDENT_DRIVER_EMPLOYEE_ID"
#define CSD_ACCIDENT_DRIVER_LICENSE_NUMBER @"CSD_ACCIDENT_DRIVER_LICENSE_NUMBER"
#define CSD_ACCIDENT_DRIVER_LICENSE_EXPIRATION_DATE @"CSD_ACCIDENT_DRIVER_LICENSE_EXPIRATION_DATE"
#define CSD_ACCIDENT_DRIVER_LICENSE_STATE @"CSD_ACCIDENT_DRIVER_LICENSE_STATE"
#define CSD_ACCIDENT_DRIVER_BIRTH_DATE @"CSD_ACCIDENT_DRIVER_LICENSE_STATE"

#define CSD_TEST_INFO_MOBILE_RECORD_ID @"CSD_TEST_INFO_MOBILE_RECORD_ID"
#define CSD_TEST_INFO_MOBILE_RECORD_ID_DATE @"CSD_TEST_INFO_MOBILE_RECORD_ID_DATE"
#define CSD_TEST_INFO_ENDORSEMENTS @"CSD_TEST_INFO_ENDORSEMENTS"
#define CSD_TEST_INFO_LOCATION @"location"

#define CSD_TEST_INFO_POWER_UNIT @"CSD_TEST_INFO_POWER_UNIT"
#define CSD_TEST_INFO_DOT_EXPIRATION_DATE @"CSD_TEST_INFO_DOT_EXPIRATION_DATE"
#define CSD_TEST_INFO_HISTORY_REVIEWED @"CSD_TEST_INFO_HISTORY_REVIEWED"
#define CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED @"CSD_TEST_INFO_CORRECTIVE_LENS_REQUIRED"
#define CSD_TEST_INFO_LICENSE_CLASS @"CSD_TEST_INFO_LICENSE_CLASS"

#define CSD_TEST_INFO_START_DATE @"CSD_TEST_INFO_START_DATE"
#define CSD_TEST_INFO_STOP_DATE @"CSD_TEST_INFO_STOP_DATE"
#define CSD_TEST_INFO_END_DATE @"CSD_TEST_INFO_END_DATE"
#define CSD_TEST_INFO_PAUSE_DATE @"CSD_TEST_INFO_PAUSE_DATE"

#define CSD_TEST_NOTIFICATIONS @"CSD_TEST_NOTIFICATIONS"
#define CSD_COMPANY_DRIVING_SCHOOL @"CSD_COMPANY_DRIVING_SCHOOL"

#define CSD_TEST_GROUP_NAME @"CSD_TEST_GROUP_NAME"
#define CSD_TEST_GROUP_RECORDID @"CSD_TEST_GROUP_RECORDID"
#define CSD_TEST_GROUP_MEMBERS @"CSD_TEST_GROUP_MEMBERS"

#define CSD_TEST_INFO_POSITIONS @"CSD_TEST_INFO_POSITIONS"

#define USERS_PREV @"USERS_PREV"

#define HIDE_SYNC_MESSAGES @"HideSyncMessages"

@interface Settings : NSObject {
}

+ (void) switchToUser: (NSString *) userName withPassword:(NSString *) pwd andServer:(NSString *) serverName;
+ (BOOL) userExists: (NSString *) userName onServer:(NSString *) serverName;
+ (BOOL) userIsValid: (NSString *) userName withPassword:(NSString *) pwd andServer:(NSString *) serverName;

+ (NSString *) getSetting: (NSString *) key;
+ (NSNumber *) getSettingAsNumber: (NSString *) key;
+ (NSArray *) getSettingAsArray: (NSString *) key;
+ (NSDate *) getSettingAsDate: (NSString *) key;
+ (NSDictionary *) getSettingAsDictionary: (NSString *) key;

+ (void)resetKey:(NSString*)key;

+ (void) setSetting : (NSObject*) val forKey:(NSString *)key;

+ (NSString *) getThemeName;
+ (NSString *) getThemeImageNameOfType: (NSString *) imageType 
                   forOrientation: (UIInterfaceOrientation)  interfaceOrientation;

+ (void) initStatics;
+ (void) reset;
+ (void) loadSettings;
+ (void) save;
+ (void) releaseStatics;


@end
