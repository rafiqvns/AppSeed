//
//  Aggregate.h
//  Billing2
//
//  Created by .R.H. on 8/18/11.
//  Copyright 2011 RCO All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Timestamp.h"
#import "NSObject+SBJson.h"
#import "RCOObject+RCOObject_Imp.h"
#import "HTTPClient.h"
#import "HttpClientOperation.h"

#define RD_S @"recordservice"
#define F_S @"formsservice"

#define kSkipGetRecordCoding @"skipGetRecordCoding"

#define kDeletedEntity @"Deleted"

#define RD_G_I @"RD_G_I"
#define RD_G_I_U @"RD_G_I"

#define RD_G_I_B @"RD_G_I_B"
#define RD_G_I_B_U @"RD_G_I_B_U"

#define RD_G_B_T_U @"RD_G_B_T_U"

#define RD_G_R_U_F @"RD_G_R_U_F"
#define RD_G_U_C @"RD_G_U_C"

#define RD_G_R_U_X_F @"RD_G_R_U_X_F"
#define RD_G_R_U_X_F_C @"RD_G_R_U_X_F_C"

#define MAX_RECORDS 1000
#define BATCH_SIZE 100

#define SearchItemKey @"SearchItem"

#define RD_G_I_PREFIX @"RD_G_I_PREFIX"

#define R_G_C_1 @"R_G_C_1"
#define R_S_C_1 @"R_S_C_1"
#define R_G_C @"R_G_C"
#define R_S_C_1 @"R_S_C_1"

#define NotifyLinkedRecords @"notifyLinkedRecords"

#define B_S @"B_S"
#define ERROR_CODE @"errorCode"
#define ERROR_MESSAGE @"errorMessage"
#define ERROR_EXCEPTION @"errorException"
#define ERROR_CSV_FILE_PATH @"csvDataFilePath"
#define ERROR_CSV_ROW @"iCsvRow"

#define CALL_SYNC @"callSYNC"
#define CALL_EXTRA_INFO @"callExtraInfo"

#define kUninitializedRecordTimestamp -1

#define kRequestSucceededForMessage @"requestSucceededForMessage:fromAggregate:"
#define kRequestFailedForMessage @"requestFailedForMessage:fromAggregate:"
#define kRequestFinishWithData @"requestFinishedWithData:fromAggregate:"

#define kObjectSyncRequestStartedMsg @"objectSyncRequestStarted:fromAggregate:"
#define kObjectSyncRequestCompletedMsg @"objectSyncRequestCompleted:fromAggregate:"

#define kObjectSyncStartedMsg @"objectSyncStarted:fromAggregate:"
#define kObjectSyncCompleteMsg @"objectSyncComplete:"

#define kObjectsUploadStartedMsg @"objectsUploadStarted:fromAggregate:"
#define kObjectUploadCompleteMsg @"objectUploadComplete:"

#define kObjectsChangedMsg @"objectsChanged:"

#define kObjectDownloadComplete @"objectDownloadComplete:fromAggregate:"
#define kObjectsDownloadComplete @"objectsDownloadComplete:fromAggregate:"
#define kObjectDownloadFailed @"objectDownloadFailed:fromAggregate:"
#define kObjectUploadStarted @"objectUploadStarted:fromAggregate:"
#define kObjectUploadComplete @"objectUploadComplete:fromAggregate:"
#define kObjectContentUploadComplete @"objectContentUploadComplete:fromAggregate:"
#define kObjectUploadCompleteWithMessage @"objectUploadCompleteWithMessage:fromAggregate:"
#define kObjectUploadFailed @"objectUploadFailed:fromAggregate:"
#define kObjectIdIsUpdated @"objectIdIsUpdated:fromAggregate:"

#define kContentSyncStartedMsg @"contentSyncStarted:fromAggregate:"
#define kContentSyncCompleteMsg @"contentSyncComplete:"
#define kContentChangedMsg @"contentChanged:"
#define kContentDownloadComplete @"contentDownloadComplete:fromAggregate:"
#define kContentDownloadCompleteWithInfo @"contentDownloadCompleteWithInfo:fromAggregate:"
#define kContentDownloadFailed @"contentDownloadFailed:fromAggregate:"

#define kCreateRecordTreeId @"treeId"
#define kCreateRecordItemType @"recordItemType"
#define kCreateRecordName @"recordDisplayName"

#define kImageSizeForUpload @"-2"
#define kImageFullSizeDownloaded @"-1"
#define kImageSizeThumbnailSize @"320"

#define kFetchBatchSize 50
#define kFetchLimit 50

#define kCalls @"calls"

#define kCallDelay 3

#define kNumberOfTries 3

#define kCSVData @"CSV"
#define kMessageResponseKey @"messageResponse"

#define kCreateDetails @"createDetails"
#define kCreateDetailsKeyRecordType @"createDetailsKeyRecordType"
#define kCreateDetailsKeyNumberOfItems @"createDetailsKeyNumberOfItems"
#define kCreateDetailsNewItemCreated @"createDetailsNewItemCreated"

// Training Rights
#define kTrainingTestRight @"Mobile-DisplayTrainingSafeDrivingEvaluation"
#define kTrainingRight @"Mobile-DisplayTrainingCommand"
#define kTrainingClassC @"Mobile-DisplayTrainingClassCEvaluation"
#define kTrainingBus @"Mobile-DisplayTrainingBus"
#define kTrainingAccident @"Mobile-DisplayTrainingAccident"
#define kTrainingPreTrip @"Mobile-DisplayTrainingPreTrip"
#define kTrainingEyeMovements @"Mobile-DisplayTrainingEyeMovements"
#define kTrainingStudentsRight @"Mobile-DisplayTrainingStudents"
#define kTrainingInstructorsRight @"Mobile-DisplayTrainingInstructors"
#define kTrainingCompanySetup @"Mobile-DisplayTrainingCompanySetup"
#define kTrainingMap @"Mobile-DisplayTrainingMaps"

#define kDisplayUsersRight @"Mobile-DisplayUsers"
#define kDisplayUsersGroupsRight @"Mobile-DisplayGroups"

#define kFormsRight @"Mobile-DisplayForms"

#define kAlwaysLoadRight @"load"

#define kInventoryGroup @"Inventory"
#define kPeopleGroup    @"People"
#define kInvoiceGroup   @"Invoicing"
#define kTimecardGroup  @"Timecards"
#define kDocumentsGroup  @"Documents"
#define kShippingGroup  @"Shipping & Receiving"
#define kLibraryGroup   @"Library"
#define kJobsGroup      @"Jobs"
#define kMoveGroup      @"Move Operations"
#define kCalendarGroup      @"Calendar"
#define kBillsGroup      @"Bills & Expenses"

#define kMapCodingInfoKey @"mapCodingInfo"

#define kRecordContentExtension @"png"
#define kRecordContentExtensionJPG @"jpg"

#define RESPONSE_INTERNAL_ERROR @"internalError"

#define RMS_KEY_ObjectId @"objectId"
#define RMS_KEY_ObjectType @"objectType"
#define RMS_KEY_TreeId @"treeId"

#define AGG_OBJECT_CLASS @"rcoObjectClass"

#define BytesRead @"BytesRead"
#define BytesTotalyRead @"BytesTotalyRead"
#define BytesTotalyExpectedToRead @"BytesTotalyExpectedToRead"

#define KEY_Filter @"filterKey"


typedef enum  {
    SyncTypeUnknown=0,
    SyncTypeFull,
    SyncTypeUpdate,
} SyncType;


@class Aggregate;
@protocol RCODataDelegate <NSObject>
@optional

// generic call back
- (void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate: (Aggregate *) aggregate;
- (void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate: (Aggregate *) aggregate;
- (void)requestFinishedWithData:(NSData*)data fromAggregate: (Aggregate *) aggregate;

// object list messages
- (void) objectSyncRequestStarted: (NSNumber *)numObjectsToUpdate : (Aggregate *) aggregate;
- (void) objectSyncRequestCompleted: (NSNumber *)numObjectsToUpdate fromAggregate: (Aggregate *) aggregate;
- (void) objectSyncStarted: (NSNumber *)numObjectsToUpdate fromAggregate: (Aggregate *) aggregate;
- (void) objectSyncComplete: (Aggregate *) fromAggregate;
- (void) objectsChanged: (Aggregate *) fromAggregate;

// individual object messages
- (void) objectDownloadComplete: (NSString *)objectId fromAggregate: (Aggregate *) aggregate;
- (void) objectDownloadFailed: (NSString *)objectId fromAggregate: (Aggregate *) aggregate;

- (void) objectUploadStarted: (NSString *) objectId fromAggregate: (Aggregate *) aggregate;
- (void) objectUploadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate;
- (void) objectUploadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate withMessage:(NSDictionary*)messageInfo;
- (void) objectUploadFailed:(NSString *) objectId fromAggregate: (Aggregate *) aggregate;
- (void) objectIdIsUpdated: (NSString *) localId toServerId: (NSString *) assignedId fromAggregate: (Aggregate *) aggregate;

// content list messages
- (void) contentSyncStarted: (NSNumber *)numFilesToUpdate fromAggregate: (Aggregate *) aggregate;
- (void) contentSyncComplete: (Aggregate *) aggregate;
- (void) contentChanged: (Aggregate *) aggregate;
- (void)getNewContentDataForObject:(NSString*)objectId;

// individual content messages
- (void) contentDownloadComplete: (NSString *) objectId fromAggregate: (Aggregate *) aggregate;
- (void) contentDownloadFailed: (NSString *) objectId fromAggregate: (Aggregate *) aggregate;

- (void)getPhotosForObject:(RCOObject*)object withParent:(NSString*)parentRecordId;

// various utility calls
- (void)getChildrenDirectoryIds:(RCOObject*)object childrenType:(NSString*)type;
- (void)getChildrenDirectoryIdsByRecordId:(NSString*)recordId childrenType:(NSString*)type;
- (void)getChildrenByTreeId: (NSString *) treeId  childrenType:(NSString*)type;
- (void)getFileFolders;
- (void)getFilterCategoryPaths;
- (void)getContainerPaths: (NSString *) recordType;
- (void)getNodeInfo: (NSString*) objectId withRecordId: (NSString *) rcoRecordId ;
- (void)getLatLonByRecordType: (NSString *) recordType;

@end

#define kListReady @"listReady:forCategories:hasSubdirectories:fromAggregate:"
#define kListFailed @"listFailed:"

@protocol RCONestedListDelegate <NSObject>
@required
- (void) listReady: (NSDictionary *) list forCategories: (NSArray *) catNames hasSubdirectories:(NSNumber *) hasSubdirectories fromAggregate: (Aggregate *) aggregate;
- (void) listFailed: (Aggregate *) fromAggregate;
@end

@interface Aggregate : NSObject <HTTPClientDelegate, RCODataDelegate, HTTPClientOperationDelegate> {
    // what does RCO call this object class? (ie service, client, timecard
    // This is different than RCO's object type, which is more like a number
    NSString* rcoObjectClass;
    NSString* rcoObjectParentClass;
    NSString *rcoObjectType;
    NSString *m_rcoRecordType;
    
    // what is the class name in the data store
    NSString* localObjectClass;
    
    // are we synching?
    int m_syncStatus;
    
        // accessible by downstream thread ONLY
    // the last synch timestamp
    NSNumber*  m_synchingTimeStamp;
    NSNumber*  m_synchedTimeStamp;

    // how many objects are we waiting for to synch? (downstream)
    NSMutableDictionary *m_recordsThatFailedToDownloadDict;
    NSMutableArray *m_objectsToDownload;
    
    NSMutableArray* listeners;
    
    // downloadable images
    Boolean m_frontloadImages;
    Boolean m_contentSynching;
   // NSMutableDictionary *m_contentToDownload;
    //NSMutableDictionary *m_contentCurrentlyDownloading;
    NSMutableArray *m_contentThatFailedToDownload;
    NSArray *m_defaultImageSizes;
    
    BOOL _showErrorMessage;
    BOOL _sendErrorMessage;
    
    NSMutableDictionary *_callsInfo;
    
    BOOL _skipUpdatingAllDetailCodingFields;
    
    // used to skip syncing records
    BOOL skipSyncRecords;
    
    // used to get the most recent content
    BOOL getMostRecentContent;

    NSInteger _batchSize;
    SyncType syncType;
    
    @private
    
    NSMutableArray *m_detailAggregates;
}

@property (nonatomic, assign) BOOL countCallDone;

@property (nonatomic, strong) NSString* rcoObjectClass;
@property (nonatomic, strong) NSString* rcoObjectParentClass;
@property (nonatomic, strong) NSString* rcoObjectType;
@property (nonatomic, strong) NSString* rcoRecordType;
@property (nonatomic, strong) NSString* localObjectClass;
@property (nonatomic, strong) NSString* recordGroup;

@property (nonatomic, readonly) BOOL skipSyncRecords;
@property (nonatomic, readonly) BOOL getMostRecentContent;

@property (nonatomic, readonly) NSInteger batchSize;


//@property (nonatomic, retain) NSMutableArray *m_messagesForUploadThread;

// sync process
@property (atomic) int syncStatus;
@property (weak, readonly) NSString *syncStatusDescription;


// record (coding) sync
@property (nonatomic, strong) NSArray * fieldsToSync;

@property (nonatomic, strong) NSMutableDictionary* recordsThatFailedToDownloadDict;
@property (nonatomic, strong) NSMutableDictionary* recordsAwaitingDownload;
@property (nonatomic, strong) NSMutableArray * objectsToDownload;

@property (nonatomic, strong) NSMutableDictionary* recordsThatFailedToUploadDict;
@property (nonatomic, strong) NSMutableDictionary* recordsAwaitingUpload;
@property (nonatomic, strong) NSMutableArray * objectsToUpload;

#define kErrorMessagesToLog 10
@property (nonatomic, strong) NSMutableArray * firstErrorMessages;
@property (nonatomic, strong) NSMutableArray * lastErrorMessages;

// timestamps
@property (nonatomic, strong) NSNumber*  synchingTimeStamp;
@property (nonatomic, strong) NSNumber*  synchedTimeStamp;
@property (nonatomic, strong) NSNumber*  synchedMinErrorTimeStamp;

// content sync
@property (atomic) Boolean contentSynching;
@property (nonatomic) Boolean frontLoadImages;
@property (nonatomic, strong) NSArray *defaultImageSizes;
//@property (nonatomic, retain) NSMutableDictionary *contentToDownload;
//@property (nonatomic, retain) NSMutableDictionary* contentCurrentlyDownloading;
@property (nonatomic, strong) NSMutableArray* contentThatFailedToDownload;
@property (nonatomic, assign) BOOL contentSucceded;

@property (nonatomic, strong) NSManagedObjectContext* moc;
@property (nonatomic, strong) NSMutableArray* listeners;
@property (nonatomic, strong) NSMutableArray *detailAggregates;

// we will use this to update records that are linked 
@property (nonatomic, strong) NSArray *linkedRecords;
@property (nonatomic, strong) NSArray *linkedRecordsField;


// rights
@property (nonatomic, strong) NSString *aggregateRight;
@property (nonatomic, strong) NSArray *aggregateRights;


// cache
@property (nonatomic, strong) NSArray *allItems;

@property (nonatomic, strong) NSMutableDictionary *recentItems;

@property (nonatomic, assign) BOOL skipUploadCheck;

@property (nonatomic, strong) NSArray *codingFieldsToSkipWhenUpdating;

- (id) initAggregateWithRights:(NSArray*)rights;
- (void) prepareData;
- (Boolean) isAvailableToUser: (NSArray *) userRights;
- (Aggregate *) getHeaderAggregate;

- (NSString *) uniqueName;
- (NSString*)getAggExtraInfo;

// calls for handling interface with RMS server.  These are primarily used by subclasses
- (Boolean) requestSyncStartInitialize;
- (void) requestSyncStart;
- (void) requestSyncStop;
- (void) requestSyncPause;
- (void) syncStep;
- (void)setSyncType;
- (void)resetSyncType;
- (BOOL)isFullSync;
- (BOOL)switchedToOldSync;
- (BOOL)resetExistingRecordsWhenLoggingWithDifferentUser;

- (NSString*)getTimestampParameter;
- (void)resetTimestampParameter;
- (Boolean) requestSync;
- (Boolean) requestSyncRecords;
- (Boolean) requestSyncRecordTypes;
- (Boolean) requestSyncRecordTypesAll;
- (Boolean) requestSyncIds;
- (Boolean) requestSyncIdsAll;
- (Boolean) requestSyncRecordLibraryItems;
- (void)getUpdatedRecordsCount;

// handle synchronization of details
- (Boolean)requestIdsForDetailsOfObject: (NSString *) parentId andType: (NSString *) objType;
- (Boolean)requestIdsForObjectsWithParentId: (NSString *) parentId andType: (NSString *) objType;

- (void) startObjectDownload;
- (void) downloadNextObject;

- (Boolean) requestContentTransferStart;
- (void) requestContentDownloadStop;
- (void) transferNextContent;
- (RCOObject *) getNextContentObjToDownload;
- (void) jumpstartDataDownloadForced: (NSString *) objectId;
- (void) contentRequestFinishedForObject: (NSString *) objId withSize: (NSString *) pels withSuccess: (Boolean) success;

- (void) reset;
- (void) checkForSyncDoneWithSuccess: (Boolean) isSuccess;
- (void) finishSyncWithSuccess: (Boolean) isSuccess;
- (void) uploadingRecordsFinished;

- (void) addSync;
- (void) subtractSync;

- (NSDictionary *) fieldValuesDictionaryFromArray: (NSArray *) fieldValuesArray;

- (RCOObject*) syncObjectWithId: (NSString *) objId
                        andType: (NSString *) objType
             toValuesDictionary: (NSDictionary *) valuesDictionary;

-(BOOL)overwriteRecord:(RCOObject*)obj;
-(BOOL)isMobileRecordId:(NSString*)objId;
-(BOOL)resetLocalFields;

// implement to do a force insert when doing the initial sync
- (RCOObject*) syncObjectWithId: (NSString *) objId
                        andType: (NSString *) objType
             toValuesDictionary:(NSDictionary *)valuesDictionary
                    forceInsert:(BOOL)forceInsert;

-(void) syncObject: (RCOObject*)object
     withFieldName: (NSString *) fieldName 
      toFieldValue: (NSString *) fieldValue;

- (void)  geocodeAddress: (NSString *) address
                  inCity: (NSString *) city 
                 inState: (NSString *) state 
                 withZip:  (NSString *) zip 
                  forObj:(NSString *) objId;

-(NSArray*)createRecordInNodeDirectory:(RCOObject*)obj fromParams:(NSDictionary*)paramsDict;

- (void)requestStarted:(id)request;
- (void)requestFinished:(id)request;
- (void)requestFailed:(id )request;


- (void) requestFinished_Bkgd:(id )request;
- (void) requestFinished_RecordGetIds: (NSArray *) fieldValues;
- (void) requestFinished_RecordGetRecords: (NSArray *) fieldValues;

- (void) requestFinished_RecordGetCoding: (NSString *) objId
                                withType: (NSString *) objType
                          andValuesArray: (NSArray *) fieldValuesArray
                      orValuesDictionary: (NSDictionary *) fieldValuesDictionary
                         downloadNextObject: (Boolean) doDownloadNextObject;
// implement to do a force insert when doing the initial sync
- (void) requestFinished_RecordGetCoding: (NSString *) objId
                                withType: (NSString *) objType
                          andValuesArray: (NSArray *)fieldValuesArray
                      orValuesDictionary: (NSDictionary *)fieldValuesDictionary
                      downloadNextObject: (Boolean) doDownloadNextObject
                             forceInsert: (BOOL)forceInsert;


- (void) requestFinished_RecordSetCoding: (RCOObject *) obj withMsg:(NSString *) msg andResponse:(NSString *) response;

- (void) requestFailed_Bkgd:(id )request;
- (void) requestFailed_RecordSetCoding:(id )request;

- (RCOObject *) createNewObject;
- (void) destroyObj: (RCOObject *) obj;
- (NSArray*)getRecordsToDelete;
- (RCOObject *) createObjectWithId: (NSString *) objId andType: (NSString *)objType;
- (void) warnUserEditedObjectDeleted: (RCOObject *) deletingObj;
- (void) warnUserEditedObjectOverwritten: (RCOObject *) editedObj;
- (void) warnUser: (NSString *) aMessage;

- (BOOL) uploadRecordContent:(RCOObject*)object;
- (BOOL) uploadRecordContent:(RCOObject*)object andSize:(NSString*)fileSize;
- (NSArray *) getObjectsToUpload;
- (NSInteger) getObjectsToUploadCount;

- (BOOL) uploadObject: (RCOObject *) obj;
- (id) createNewRecord: (RCOObject *) obj;
- (id) createNewRecord: (RCOObject *) obj forced:(NSNumber*)forced;
- (id) createNewRecords: (NSArray *) objects;
- (id) createNewRecord: (RCOObject *) obj withNumberOfDetails:(NSNumber*)numberOfDetails;
- (id) createNewRecord: (RCOObject *) obj withDetails:(NSArray*)details;

- (id) createNewRecordFromCSVString: (NSString *) objCSVString forObject:(RCOObject*)obj;

- (BOOL)shouldUpdateRecords;
- (BOOL)shouldUpdateRecordsAndUploadRecords;
- (void)updateRecords;

- (NSString*)getSetCallStringForObjiect:(RCOObject*)object;

- (void) destroyRecord: (RCOObject *) obj;
- (void) destroyRecord:(NSString*)objectId andObjectType:(NSString*)objectType;
- (id ) uploadObjectContent: (RCOObject *) obj size: (NSString *) pels;
- (id ) uploadObjectContent: (RCOObject *) obj filePath: (NSString *) filePath;
- (id ) uploadObjectContent: (NSDictionary *) objDict;
- (id ) appendObjectContent: (RCOObject *) obj data: (NSData *) dataToAppend;
- (id ) appendObjectContent: (RCOObject *) obj dataString: (NSString *) stringToAppend;
- (id ) appendObjectContent: (RCOObject *) obj dataString: (NSString *) stringToAppend fileExtension:(NSString*)extension;
- (NSData*)getTempContent;


- (id ) uploadObjectCoding: (RCOObject *) obj;

-(void)updateObject:(RCOObject *)object andSkipGetRecordCoding:(BOOL)skipGetRecordCoding;
-(void)uploadScanLog:(RCOObject*)object withParams:(NSDictionary*)params;
-(void)uploadScanLogFomParams:(NSDictionary*)params;
-(void)uploadScanLogFor7Days:(NSDictionary*)params;

- (void) updateObjectWithId:(NSString*)objectId andObjectType:(NSString*)objectType withValues:(NSDictionary*)values;

- (NSString *) getObjectCodingForUpload: (RCOObject *) obj;
- (NSString *) addCodingField: (NSString *) field withValue: (NSString *) value toData: (NSString *) data;

-(void)createObject:(RCOObject*)object inTree:(NSString*)treeId withName:(NSString*)name andType:(NSString*)type;

// methods that are used for updating or getting coding fields about records that are not synced!
- (void)updateRecordFromString:(NSString*)updateString;
- (void)updateRecordFromString:(NSString*)updateString delegate:(id<HTTPClientOperationDelegate>)delegate;
- (NSArray*)getRecordCodingFields:(NSString*)objectId andObjectType:(NSString*)objType;
- (void)getRecordCodingFields:(NSString*)objectId andObjectType:(NSString*)objType andDelegate:(id)delegate;

- (RCOObjectEditLayer *) getObjectEditLayerWithId: (NSString *) objectId;

- (NSString *) rcoDateToString: (NSDate *) aDate;
- (NSDate *) rcoStringToDateYYYYMMDD: (NSString *) aDateStr;
- (NSString *) rcoDateRMSToString: (NSDate *) aDate;
- (NSString *) rcoDateRMSToString2: (NSDate *) aDate;

- (NSDate *) rcoStringRMSToDate: (NSString *) dateStr;
- (NSString *) rcoDateToString: (NSDate *) aDate withSepatrator:(NSString*)separator;
- (NSString *) rcoDateTimeToString: (NSDate *) aDate withSepatrator:(NSString*)separator;
- (NSString *) rcoDateAndTimeToString: (NSDate *) aDate;
- (NSString *) rcoDateAndTimeToStringNoSeconds: (NSDate *) aDate;
- (NSString *) rcoTimeToString: (NSDate *) aTime;
- (NSString *) rcoTimeHHmmssToString: (NSDate *) aTime;
- (NSDate *) rcoStringToDate: (NSString *) aDateStr;
- (NSDate *) rcoStringToTime: (NSString *) aTimeStr;
- (NSDate *) rcoStringToDateTime: (NSString *) aDateStr;
- (NSString *) RCOFilterDateTimeRMSToString: (NSDate *)aDate;
- (NSString *) rcoDateTimeRMSToString: (NSDate *) aDate;
- (NSDate *) MMDDYYYYStringToDate: (NSString *) aDateStr;
- (NSDate *) yyMMddStringToDate: (NSString *) aDateStr;
- (NSDate *) yyyyMMddStringToDate: (NSString *) aDateStr;

- (NSArray *) getAll;
- (NSArray *) getAllRecords;
- (void)clearAllLocally;
- (NSArray*) getAllIds;
- (NSArray *) getAllSortedBy: (NSArray*) sortKeys;
- (NSArray *) getAllNarrowedBy: (NSString *) keyName withValue: (NSString *) keyValue sortedBy:(NSArray*) sortKeys;
- (NSArray *) getAllNarrowedBy: (NSPredicate *) pred andSortedBy: (NSArray *) sorters;

- (NSArray *) getSomeNarrowedBy: (NSPredicate *) pred sortedBy:(NSArray*) sorters limitedTo: (NSInteger) maxToReturn;
- (NSArray *) getSomeNarrowedBy: (NSPredicate *) pred sortedBy:(NSArray*) sorters limitedTo: (NSInteger) maxToReturn offset:(NSInteger)offset;

- (NSPredicate *) subsetPredicate;
- (NSArray *) getAllForSearchTerm: (NSString *) searchTerm withSearchKeys: (NSArray *) searchKeys andSortKeys: (NSArray *) sortKeys;
- (RCOObject *) getObjectWithId: (NSString *) objectId;
- (RCOObject *) getObjectWithIdForDelete: (NSString *) objectId;

- (RCOObject *) getObjectWithRecordId: (NSString *) recordId;
- (RCOObject *) getObjectWithUserId: (NSString *) userId;
- (NSArray*) getObjectsWithRecordId: (NSString *) recordId;
- (NSArray*)getObjectsFromFunctionalGroupWithName:(NSString*)groupName andNumber:(NSString*)groupNumber;

- (RCOObject *) getRCOObjectWithRecordId: (NSString *) recordId;
- (RCOObject *) getObjectMobileRecordId: (NSString *) mobileRecordId;
- (RCOObject *) getObjectWithBarcode: (NSString *) barcode;
- (RCOObject*) getObjectWithMobileRecordId: (NSString *) mobileRecordId;
- (RCOObject*) getObjectWithEmail: (NSString *) email;
- (RCOObject *) getObjectForCodingField:(NSString*)codingField andValue: (NSString *) value;
- (void)objectUploadedWithMobileRecordId:(NSString*)mobileRecordId andUpdateToRCORecordId:(NSString*)rcoRecordId;

- (NSUInteger) countObjects: (NSPredicate *) pred;
- (NSUInteger) countObjectsToSync;
- (NSUInteger) countFilesToSync;
- (void) removeDeletedObjects: (NSArray *) currentIds;
- (void) removeObjectsNotInList:(NSArray *)currentIds fromGroup: (NSArray *) validObjects;

- (NSArray*)getObjectIdSortDescriptor:(BOOL)acending;

// detail retrieval
- (NSArray*) getObjectsWithParentId: (NSString *) parentId;
- (NSArray*) getObjectsThatNeedsToUpload;
- (NSArray*) getObjectsWithMobileRecordId: (NSString *) mobileRecordId;
- (NSArray*) getObjectsWithMasterBarcode: (NSString *) barcode;
- (NSArray*) getObjectsWithBarcode: (NSString *) barcode;
- (RCOObject *) getObjectDetailWithId:  (NSString *) objectDetailId andClass:  (NSString *) objectClass;

- (NSArray *) getObjectDetails: (NSString *) objectId;
- (NSArray *) getRCOObjectDetails: (RCOObject*) obj;
- (NSArray *) getObjectDetails: (NSString *) objectId forDetailAggregate:(Aggregate*)detailAgg;

- (NSArray *) getObjectDetailsForBarcode: (NSString *) barcode andDetailAggregate:(Aggregate*)detailAgg;
- (NSArray *) getObjectDetailsForMasterBarcode: (NSString *) masterBarcode;
- (NSArray *) getObjectDetailsForObjectId: (NSString *) objectId;

- (NSNumber*) getNumberOfDetails:(NSString*)parentId;
- (NSNumber*) getNumberOfDetailsWithBarcode:(NSString*)parentBarcode;

// image handling.  These are kept as files in the doc directory.
- (UIImage *) getImageForObject: (NSString *) objectId;
- (UIImage *) getObjectImage: (RCOObject*) object;
- (UIImage *) getImageForObject: (NSString *) objectId size: (int) pels;
- (NSData *) getDataForObject: (NSString *) objectId size: (NSString *) pels;
- (NSData *) getDataForObject: (NSString *) objectId size: (NSString *) pels skipDownload:(BOOL)skipDownload;

- (void) appendDataForObject: (NSString *) objectId data: (NSString *) dataStr fileExtension:(NSString*)fileExtension;
- (void) appendDataForObject: (NSString *) objectId data: (NSString *) dataStr size:(NSString*)pels;
- (void) appendDataForObject: (NSString *) objectId data: (NSString *) dataStr;
- (NSString*)getDataContentForObject:(NSString*)objectId;

- (void) downloadDataForObject: (NSString *) objectId size: (NSString *) pels;

- (NSURL*) getDirPathForObjectImages;
- (NSURL*) getFilePathForObjectImage:(NSString*)objectId size: (NSString *) pels;

- (NSString*) getFileStubForObjectImage:(NSString*)objectId size: (NSString *) pels;
- (NSURL*)getSaveFilePathForObjectImage:(NSString *)objectId size: (NSString *) pels;

- (void)saveImage:(NSData*)imageData forObjectId:(NSString*)objectId;
- (NSURL*)saveImage:(NSData*)imageData forObjectId:(NSString*)objectId andSize:(NSString*)fileSize;
- (void)saveImage:(NSData*)imageData forRecordId:(NSString*)recordId;

-(void)deleteLocalContentForObject:(NSString*)objectId;

- (void)renameImage:(NSString*)mobileRecordId forObjectId:(NSString*)objectId;

- (void)saveRecordContent:(NSData*)contentData forObjectId:(NSString*)objectId;
- (NSURL*)saveRecordContentNew:(NSData*)contentData forObjectId:(NSString*)objectId;

- (void) requestDataForObject: (RCOObject *) obj withSize: (NSString *) pels;

- (BOOL) isDataDownloaded: (NSString *) objectId size: (NSString *) pels;
- (BOOL) isDataDownloading: (NSString *) objectId size: (NSString *) pels;
- (BOOL) isDataFailed: (NSString *) objectId size: (NSString *) pels;

- (void) save;

- (void) dispatchToTheListeners: (NSString *) msg;
- (void) dispatchToTheListeners: (NSString *) msg withObjectId:(NSString *) objId;
- (void) dispatchToTheListeners: (NSString *) msg withMessageInfo:(NSDictionary *) messageInfo;
- (void) dispatchToTheListeners: (NSString *) msg 
                       withArg1: (NSObject *) arg1 
                       withArg2: (NSObject *) arg2;
- (void) tellTheListeners: (NSArray *) arguments;

- (void) registerForCallback: (id<RCODataDelegate>) callbackObject;
- (void) registerDetailForCallback: (id<RCODataDelegate>) callbackObject;
- (void) unRegisterForCallback: (id<RCODataDelegate>) callbackObject;
- (void) unRegisterDetailForCallback: (id<RCODataDelegate>) callbackObject;

// threading
- (NSThread *) threadForDownload;
- (NSThread *) threadForUpload;
- (void)runBackgroundRequests: (NSNumber *) priority;
- (void) mergeMocChangesToOtherThreads: (NSNotification *) notification;
- (void) mergeMocChangesFromOtherThread: (NSNotification *) notification;
- (void) shutdownThreads: (NSDictionary *) callerDict;

- (void)createRecordInDateBranch:(NSDictionary*)recordInfo;

- (NSDate*)dateFrom:(NSString*)dateStr andTime:(NSString*)timeStr;

- (NSString*)unescapeString:(NSString*)text;

// according to the _sendErrorFlag displays a message or it send it to the server
- (void)showMessage:(NSString*)message;
- (void)showAlert:(NSString*)message;

// shows a simple message
- (void)showAlertMessage:(NSString*)message;

- (void)addObjectToCach:(RCOObject*)obj;

- (BOOL)isResponseValid:(NSData*)responseData;
- (NSString*)responseError:(NSString*)response;
- (void)sendError:(NSString*)errorString synchronous:(BOOL)isSyncCall;
- (void)sendSyncMessage:(NSString*)syncString synchronous:(BOOL)isSyncCall;
- (NSString*)getErrorFileName:(NSDictionary*)objDict;
- (void)deleteDetailsForObject:(RCOObject*)object existingDetails:(BOOL)existingDetails;
- (NSString*)parseSetRequest:(id)request;
- (NSString*)parseSetRequest:(id)request isForDetail:(NSNumber*)forDetail;
- (RCOObject*)createObjectAndDetailsFromDict:(NSDictionary*)dict;
- (void)updateCodingFieldsForObject:(RCOObject*)object;
- (void)destroyObjectJustFromLocalDB:(RCOObject*)obj;
- (void)setUploadingCallInfoForObject:(RCOObject*)obj;
- (BOOL)checkExistingItemBeforeInsertWhenDoingInitialSync;

- (void)setShowErrorMessages:(BOOL)showErrorMessage;
- (void)loadCaching;

- (NSString *) manualSyncSettingsKey;
- (Boolean) shouldSyncManually;
- (NSString *) displayableName;
- (BOOL) saveImageContentAsPNG;

- (NSArray*)getRecordCodingByRecordId:(NSString*)recordId;
- (NSArray*)getRecordCodingByMobileRecordId:(NSString*)mobileRecordId;
- (NSDictionary*)getRecordInfoByRecordId:(NSString*)recordId;
- (NSDictionary*)getRecordInfoByMobileRecordId:(NSString*)mobileRecordId;

-(NSString*)getDateFolder:(NSDate*)date;
-(NSString*)getScanFolderForItem:(RCOObject*)item;

-(BOOL)isObjectIdValid:(NSString*)objId;

-(void)reloadObjectDetailsFromRMS:(NSString*)objectBarcode;
-(void)reloadObjectFromRMS:(NSString*)objectBarcode;

-(NSArray*)JSONArrayFromRequestResponse:(id)request error:(NSError**)error;
-(NSDictionary*)JSONDictionaryFromRequestResponse:(id)request error:(NSError**)error;
-(NSDictionary*)getMsgDictFromRequestResponse:(id)request;
-(NSString*)getResponseStringFromRequest:(id)request;
-(NSString*)getCallURLFromRequestResponse:(id)request;
-(NSString*)getErrorFromRequestResponse:(id)request;
-(NSError*)getErrorObjFromRequestResponse:(id)request;

- (NSString*) entityName;

- (NSString*) savingPathForPDF:(RCOObject*)obj;
- (NSPredicate*)getDateTimePredicateForField:(NSString*)field andDate:(NSDate*)date;

- (NSNumber*)getNumberOfRecords;
- (BOOL)FFFilter;

- (NSString*)filterCodingFielValue;
- (NSString*)filterCodingFieldName;

@end

