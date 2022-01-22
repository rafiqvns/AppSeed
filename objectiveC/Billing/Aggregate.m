   //
//  Aggregate.m
//  Billing2
//
//  Created by .R.H. on 8/18/11.
//  Copyright 2011 RCO All rights reserved.
//

#import "Aggregate.h"
#import "UIUtility.h"
#import "TimeStamp.h"
#import "DataRepository.h"
#import "Settings.h"
#import "BillingAppDelegate.h"
#import "UIImage+Resize.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSManagedObjectContext+Timing.h"
#import "NSDate+Misc.h"

#import "HttpClientOperation.h"

#define NumberOfRecordsToSaveOnce 10

@interface Aggregate ()
@property (atomic, assign) NSUInteger approximateCount;
@property (atomic, assign) NSInteger numberOfItemsToSync;
@property (nonatomic, strong) NSString *synchedRecordId;
@property (nonatomic, strong) NSString *synchedObjectId;
@property (nonatomic, strong) NSString *synchedObjectType;
@property (nonatomic, assign) BOOL useTheOldSync;
@property (nonatomic, assign) BOOL isSyncingTimestampReset;
@end

@implementation Aggregate

@synthesize rcoObjectClass, localObjectClass, rcoObjectType, rcoObjectParentClass;
@synthesize rcoRecordType=m_rcoRecordType;
@synthesize recordGroup;
@synthesize syncStatus=m_syncStatus;
@synthesize syncStatusDescription;
@synthesize contentSynching=m_contentSynching;
@synthesize synchingTimeStamp=m_synchingTimeStamp,listeners;
@synthesize synchedTimeStamp=m_synchedTimeStamp;
@synthesize detailAggregates=m_detailAggregates;
@synthesize frontLoadImages=m_frontloadImages;

@synthesize contentThatFailedToDownload=m_contentThatFailedToDownload;
@synthesize defaultImageSizes=m_defaultImageSizes;
@synthesize recordsThatFailedToDownloadDict=m_recordsThatFailedToDownloadDict;
@synthesize objectsToDownload=m_objectsToDownload;


@synthesize contentSucceded;

@synthesize aggregateRight;
@synthesize aggregateRights;

@synthesize skipSyncRecords;

@synthesize getMostRecentContent;


#pragma mark - Initialization

- (id) init
{
    if ((self = [super init]) != nil){
        
        self.frontLoadImages = false;
        
        m_detailAggregates = nil;
        
        self.recentItems = [NSMutableDictionary dictionary];
	}
    
	return self;    
}

- (id) initAggregateWithRights:(NSArray*)rights
{
    if ((self = [self init]) != nil){
		
        //self.useTheOldSync = YES;
        
        if( self.aggregateRights == nil && self.aggregateRight != nil) {
            self.aggregateRights = [[NSArray alloc] initWithObjects:self.aggregateRight, nil];
        }
        
        self.objectsToUpload = [NSMutableArray array];
        
        if(self.rcoRecordType == nil )
            self.rcoRecordType = self.rcoObjectClass;
        
        if( self.recordGroup == nil )
            self.recordGroup = self.rcoRecordType;
        
		self.listeners = [[NSMutableArray alloc] init];
        
        if( self.defaultImageSizes == nil )
            self.defaultImageSizes = [[NSArray alloc] initWithObjects:@"-1", nil];
        
        self.contentThatFailedToDownload = [[NSMutableArray alloc] init];
        
        // records
        self.objectsToDownload = [[NSMutableArray alloc] init];
        self.recordsAwaitingDownload  =[[NSMutableDictionary alloc] init];
        self.recordsThatFailedToDownloadDict  =[[NSMutableDictionary alloc] init];
        
        if (![self isAvailableToUser:rights]) {
            skipSyncRecords = YES;
        }
        
        _batchSize = BATCH_SIZE;
        
        if (!skipSyncRecords) {
            [self loadSynchedTimeStamp];
            
            if ([self shouldSyncManually]) {
                [self loadCaching];
            } else {
                // get the objects that needs to be uploaded
                [self prepareData];
            }
        }        
        
        _showErrorMessage = NO;
        _sendErrorMessage = YES;
	}
    
	return self;
}

- (void)setShowErrorMessages:(BOOL)showErrorMessage {
    _showErrorMessage = showErrorMessage;
}
- (void) prepareData
{
    return;
}

- (Boolean) isAvailableToUser: (NSArray *) userRights
{
    BOOL  loadAll = NO;
    
#ifdef DEBUG
    loadAll = YES;
    NSArray *curUserRights = userRights;
    for( NSString *theRight in curUserRights )
    {
        if( [theRight hasPrefix:@"Mobile-"] )
        {
            loadAll = NO;
            break;
        }
    }
#endif

    for( NSString *right in self.aggregateRights) {
        if( [userRights containsObject:right] || [self.aggregateRight isEqualToString:kAlwaysLoadRight]) {
            return TRUE;
        }
    }
    
    return loadAll;
}

-(void)dealloc {
    m_synchedTimeStamp = nil;
}

#pragma mark -  ID / Properties
- (NSString *) uniqueName
{ 
    if ([self.rcoRecordType isEqualToString:self.rcoObjectClass]) {
        return self.rcoObjectClass;
    }

    return ([NSString stringWithFormat:@"%@/%@", self.rcoObjectClass, self.rcoRecordType]);
    
}

- (NSString *) displayableName
{
    NSString *name = self.rcoRecordType;
    if( [name length] == 0 )
        return name;
    
    NSString *firstChar = [[name substringToIndex:1] capitalizedString];
    NSString *theRest = [name substringFromIndex:1];
    
    return [firstChar stringByAppendingString:theRest ];
    
}

- (NSString *) manualSyncSettingsKey
{
    Aggregate *possibleParent = [self getHeaderAggregate];
    if( possibleParent != nil )
        return [possibleParent manualSyncSettingsKey];
    else
        return [NSString stringWithFormat:@"%@-%@", kDataSyncManuallyKeyPrefix, [self uniqueName]];
}

- (Boolean) shouldSyncManually
{
    NSString *settingsKey =[self manualSyncSettingsKey];
    NSNumber *shouldSyncManuallyNumber =[[DataRepository sharedInstance].syncOptions valueForKey:settingsKey];
    
    if( shouldSyncManuallyNumber == nil ) {
        Boolean shouldSyncManually = [[[DataRepository sharedInstance].syncOptions valueForKey:kDataSyncManuallyKey] boolValue];
        
        shouldSyncManuallyNumber = [NSNumber numberWithBool:shouldSyncManually];
        
        [[DataRepository sharedInstance].syncOptions setValue:shouldSyncManuallyNumber forKey:settingsKey];
    }
    return [shouldSyncManuallyNumber boolValue];
}

- (Aggregate *) getHeaderAggregate
{
    for( id listener in self.listeners ) {
        if( [[listener class] isSubclassOfClass:[self class]] ) {
            Aggregate *possibleParent = listener;
            if( [possibleParent.detailAggregates containsObject:self] ) {
                return possibleParent;
            }
        }
    }
    for( Aggregate *possibleParent in [DataRepository sharedInstance].aggregates ) {
        if( [possibleParent.detailAggregates containsObject:self] ) {
            return possibleParent;
        }
    }

    return nil;
}

#pragma mark -  timestamps

-(NSString*)getAggExtraInfo {
    return @"";
}

- (NSString *) synchedTimeStampKey
{
    
    NSString *orgId = [[DataRepository sharedInstance] orgNumber];
    NSString *orgName = [[DataRepository sharedInstance] orgName];

    BOOL useJustOrganizationInfoForKey = YES;
    
    NSString *key = nil;
    
    if (useJustOrganizationInfoForKey) {
        
        key = [NSString stringWithFormat:@"%@timestamp-%@%@%@-%@", [self getAggExtraInfo],[DataRepository sharedInstance].server, orgId, orgName, [self uniqueName]];

    } else {
        key = [NSString stringWithFormat:@"%@-%@-timestamp-%@%@%@-%@", [self getAggExtraInfo], [DataRepository sharedInstance].userId, [DataRepository sharedInstance].server, orgId, orgName, [self uniqueName]];
    }
   
    return key;
}

- (NSNumber *) loadSynchedTimeStamp {
   
    NSDictionary *timeStampObjectInfo = [self getFetchTimeStampObject];
    NSNumber *ts_db = [timeStampObjectInfo objectForKey:@"Timestamp"];
    NSString *recordId_db = [timeStampObjectInfo objectForKey:RCOOBJECT_RECORDID];

    m_synchedTimeStamp = [NSNumber numberWithLongLong:[ts_db longLongValue]];
    self.synchedRecordId = recordId_db;
    self.synchedObjectId = [timeStampObjectInfo objectForKey:RCOOBJECT_OBJECTID];
    self.synchedObjectType = [timeStampObjectInfo objectForKey:RCOOBJECT_OBJECTTYPE];
    
    return m_synchedTimeStamp;
}

- (void) setSynchedTimeStamp: (NSNumber *) ts {
    m_synchedTimeStamp = ts;
    [self setFetchTimeStampObject:ts];
}

- (NSDictionary *) getFetchTimeStampObject {
    
    __block NSMutableDictionary *res = nil;
    NSString *timestampKey = [self synchedTimeStampKey];

    [[self moc] performBlockAndWait:^{
        NSNumber *timestamp = nil;
        res = [NSMutableDictionary dictionary];
        NSEntityDescription *entityDescription = nil;
        
        entityDescription = [NSEntityDescription entityForName:@"Timestamp"
                                        inManagedObjectContext:[self moc]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"((rcoObjectId = %@) AND (rcoObjectClass = %@) AND (cat1 = %@))", timestampKey
                                  , self.rcoObjectClass, self.rcoRecordType];
        [request setPredicate:predicate];
        
        NSError *error = nil;

        NSArray * arrayTmp = [[self moc] executeFetchRequest:request error:&error  DATABASE_ACCESS_TIMING_ARGS ];
        
        Timestamp *timestampObject = nil;

        if ([arrayTmp count] > 0 ) {
            timestampObject = [arrayTmp objectAtIndex: 0];
            timestamp = timestampObject.rcoObjectTimestamp;
        } else {
            Timestamp *timestampObject = nil;

            timestampObject = (Timestamp *)[NSEntityDescription insertNewObjectForEntityForName:@"Timestamp"
                                                                         inManagedObjectContext:[self moc]];
                
            timestampObject.rcoObjectId = [self synchedTimeStampKey];
            timestampObject.rcoObjectClass = self.rcoObjectClass;
            timestampObject.cat1 = self.rcoRecordType;
            timestampObject.rcoObjectTimestamp = [NSNumber numberWithLongLong:0];
                
            timestamp = timestampObject.rcoObjectTimestamp;
            
            NSError *error = nil;
            if ( ! [[self moc] save:&error]) {
            }
        }
        if (timestamp) {
            [res setObject:timestamp forKey:@"Timestamp"];
        }
        
        if (timestampObject.rcoRecordId) {
            [res setObject:timestampObject.rcoRecordId forKey:RCOOBJECT_RECORDID];
        }

        if (timestampObject.rcoObjectParentId) {
            [res setObject:timestampObject.rcoObjectParentId forKey:RCOOBJECT_OBJECTID];
        }
        
        if (timestampObject.rcoObjectType) {
            [res setObject:timestampObject.rcoObjectType forKey:RCOOBJECT_OBJECTTYPE];
        }
    }];
    
    return res;
}

-(void)resetTimestampParameter {
    self.synchedObjectId = nil;
    self.synchedObjectType = nil;
    self.synchingTimeStamp = nil;
    self.isSyncingTimestampReset = YES;
}

-(NSString*)getTimestampParameter {
    NSString *timestampParam = nil;
    
    if (self.synchedObjectId.length && self.synchedObjectType.length) {
        timestampParam = [NSString stringWithFormat:@"%lld,%@,%@", [self.synchingTimeStamp longLongValue], self.synchedObjectId, self.synchedObjectType];
    } else {
        timestampParam = [NSString stringWithFormat:@"%lld", [self.synchingTimeStamp longLongValue]];
    }
    return timestampParam;
}

-(NSString*)getRecordIdForTimeStamp {
    return self.synchedRecordId;
}

-(NSString*)getObjectIdForTimeStamp {
    return self.synchedObjectId;
}

-(NSString*)getObjectTypeForTimeStamp {
    return self.synchedObjectType;
}

- (void) setFetchTimeStampObject:(NSNumber*)timestamp {
    
    NSString *timestampKey = [self synchedTimeStampKey];
    NSString *recordId = [self getRecordIdForTimeStamp];
    NSString *objectId = [self getObjectIdForTimeStamp];
    NSString *objectType = [self getObjectTypeForTimeStamp];

    [[self moc] performBlockAndWait:^{

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Timestamp"
                                                             inManagedObjectContext:[self moc]];
    
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
        [request setEntity:entityDescription];
    
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"((rcoObjectId = %@) AND (rcoObjectClass = %@) AND (cat1 = %@))", timestampKey
                              , self.rcoObjectClass, self.rcoRecordType];
        [request setPredicate:predicate];
    
        Timestamp *timestampObject = nil;
        NSError *error = nil;

        NSArray * arrayTmp = [[self moc] executeFetchRequest:request error:&error  DATABASE_ACCESS_TIMING_ARGS ];
        
        if ([arrayTmp count] > 0 ) {
            timestampObject = [arrayTmp objectAtIndex: 0];
        } else {
            timestampObject = (Timestamp *)[NSEntityDescription
                                                insertNewObjectForEntityForName:@"Timestamp"
                                                inManagedObjectContext:[self moc]];
                
            timestampObject.rcoObjectId = [self synchedTimeStampKey];
            timestampObject.rcoObjectClass = self.rcoObjectClass;
            timestampObject.cat1 = self.rcoRecordType;
        }

        [timestampObject setRcoObjectTimestamp:timestamp];
        timestampObject.rcoRecordId = recordId;
        timestampObject.rcoObjectParentId = objectId;
        timestampObject.rcoObjectType = objectType;

        error = nil;
        
        if (! [[self moc] save:&error]) {
        }

    }];
    
    [self save];
}

#pragma mark - Current Managed Object Context
- (NSManagedObjectContext *) moc
{
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    
    NSManagedObjectContext *theMoc = (NSManagedObjectContext *) [threadDict objectForKey:kMobileOfficeKey_MOC];
        
    return theMoc;
}

- (void) setMoc:(NSManagedObjectContext *)moc
{
    NSLog(@"");
}

#pragma mark -
#pragma mark Record Background Sync
- (NSString *) syncStatusDescription
{
    return [[DataRepository sharedInstance] descriptionForSyncStatus:self.syncStatus];
}

- (void) syncStep
{
    SYNC_STATUS curStatus = self.syncStatus;
    
    if (self.skipSyncRecords) {
        self.syncStatus = SYNC_STATUS_CONTENT_COMPLETE;
        return;
    }
    
    switch (curStatus)
    {
        case SYNC_STATUS_USER_COMPLETE:
            break;
            
        case SYNC_STATUS_REQUEST_COMPLETE:
            self.syncStatus = SYNC_STATUS_CODING;
            [self performSelector:@selector(startObjectDownload) onThread:[self threadForDownload] withObject:nil waitUntilDone:NO];

            break;
            
        case SYNC_STATUS_CODING_COMPLETE:
            self.syncStatus = SYNC_STATUS_CONTENT;
            
            BOOL skipContentTransfer = YES;
            
            
            //03.10.2018 we don't need automatic download
            skipContentTransfer = YES;
            
            if( !skipContentTransfer ) {
                [self performSelector:@selector(requestContentTransferStart)
                             onThread:[self threadForDownload]
                           withObject:nil
                        waitUntilDone:NO];
            }
            else {
                self.contentSucceded = YES;
                [self performSelector:@selector(requestContentDownloadStop)
                             onThread:[self threadForDownload]
                           withObject:nil
                        waitUntilDone:NO];
               
            }


            break;
            
        case SYNC_STATUS_CONTENT_COMPLETE:
            break;
    }
}

- (void) requestSyncStart
{
    if( [self requestSyncStartInitialize] ) {
        [self requestSync];
    }

}

- (Boolean) requestSyncStartInitialize
{
    [self dispatchToTheListeners:kObjectSyncRequestStartedMsg
                        withArg1:[NSNumber numberWithUnsignedInteger:0 ]
                        withArg2:nil];
    
    
    if (!([self isAvailableToUser:[DataRepository sharedInstance].userRights] )) {
        self.syncStatus = SYNC_STATUS_REQUEST_COMPLETE;
        
        [self dispatchToTheListeners:kObjectSyncRequestCompletedMsg
                            withArg1:[NSNumber numberWithUnsignedInteger:0 ]
                            withArg2:nil];
        return false;
        
    }
   
    self.syncStatus = SYNC_STATUS_REQUEST;// kSyncStatus_CodingRequestStarted;
    self.synchingTimeStamp = [NSNumber numberWithLongLong:[[self synchedTimeStamp] longLongValue]];
    
    self.synchedMinErrorTimeStamp = [NSNumber numberWithLongLong:[[self synchedTimeStamp] longLongValue]];
    
    self.recordsAwaitingDownload  =[[NSMutableDictionary alloc] init];
    self.recordsThatFailedToDownloadDict  =[[NSMutableDictionary alloc] init];
    self.firstErrorMessages = [[NSMutableArray alloc] init];
    self.lastErrorMessages = [[NSMutableArray alloc] init];
    return true;

}

- (Boolean) requestSync
{
    return [self requestSyncRecords];
}


-(void)setSyncType {
    long long timestamp = [self.synchingTimeStamp longLongValue];
    
    if (timestamp && [[DataRepository sharedInstance] useNewSyncJustAtBeggining] && !self.countCallDone) {
        syncType = SyncTypeUpdate;
        return;
    }
    
    if (syncType == SyncTypeUnknown) {
        // this is the first call
        if (timestamp == 0) {
            syncType = SyncTypeFull;
        } else {
            syncType = SyncTypeUpdate;
        }
    } else {
        if (syncType == SyncTypeFull) {
        } else {
        }
    }
}

-(void)resetSyncType {
    syncType = SyncTypeUnknown;
}

-(BOOL)isFullSync {
    long long timestamp = [self.synchingTimeStamp longLongValue];

    if (timestamp == 0) {
        return YES;
    }
    return NO;
}

- (Boolean) requestSyncRecords {

    return YES;
}

- (void)getUpdatedRecordsCount {
}

- (Boolean) requestSyncRecordTypes {
    
    return [self requestSyncRecords];
}

- (Boolean) requestSyncRecordLibraryItems {
    
    return true;
}


- (Boolean) requestSyncRecordTypesAll
{
    return true;
}

- (Boolean) requestSyncIds {
    return true;
}
- (Boolean) requestSyncIdsAll {
    return true;
}

- (void)createRecordInDateBranch:(NSDictionary*)recordInfo {
    NSLog(@"this call should be overwritten");
}

- (Boolean)requestIdsForDetailsOfObject: (NSString *) parentId andType: (NSString *) objType
{
    for( Aggregate *agg in self.detailAggregates )
    {
        [agg requestIdsForObjectsWithParentId:parentId andType: objType];
    }
    
    return true;
}

- (Boolean)requestIdsForObjectsWithParentId: (NSString *) parentId andType: (NSString *) objType
{
    // 30.08.2018 this was used to get invoice details for an invoice header and task details for a task header
    return true;
}

- (void) requestSyncStop
{
    self.syncStatus = SYNC_STATUS_NONE;
    
    self.synchingTimeStamp = nil;
    
    self.synchedRecordId = nil;
    
    self.contentSynching = false;
    
    [self.objectsToDownload removeAllObjects];
    
    for( Aggregate *agg in self.detailAggregates )
    {
        [agg requestSyncStop];
    }
}

- (void) requestSyncPause
{
    self.syncStatus = SYNC_STATUS_PAUSED;
   
}

-(BOOL)resetExistingRecordsWhenLoggingWithDifferentUser {
    return YES;
}

- (BOOL) saveImageContentAsPNG {
    return YES;
}

- (void) reset {
    
    [self requestSyncStop];
    
    [self dispatchToTheListeners:kObjectsChangedMsg];

    [self removeDeletedObjects:nil];
    [self setSynchedTimeStamp: [NSNumber numberWithDouble:0.0]];
    
    self.synchedObjectType = nil;
    self.synchedRecordId = nil;
    self.synchedObjectId = nil;
    
    for( Aggregate *detail in self.detailAggregates )
    {
        [detail reset];
    }   
    
	NSURL *fullPath = [self getDirPathForObjectImages];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	BOOL isDir=YES;
	if([fileManager fileExistsAtPath:[fullPath path] isDirectory:&isDir] )
	{
        NSError* error =nil;
        [fileManager removeItemAtPath:[fullPath path]  error:&error];
		if (error !=nil) {
		}
    }
}

- (void) checkForSyncDoneWithSuccess: (Boolean) isSuccess
{
    if( self.syncStatus == SYNC_STATUS_CODING )
    {
        if( [self.recordsAwaitingDownload count] == 0  && [self.objectsToUpload count] == 0 ) {
                
            if( self.synchedMinErrorTimeStamp == nil || [self.synchedMinErrorTimeStamp longLongValue] <= [self.synchedTimeStamp longLongValue]) {
                [self setSynchedTimeStamp:self.synchingTimeStamp];
                [self finishSyncWithSuccess: true];
            }
            else {
                [self setSynchedTimeStamp:self.synchedMinErrorTimeStamp];
                [self finishSyncWithSuccess: false];
            }
        }
        else {
            [[self moc] performBlockAndWait:^{
                [self downloadNextObject];
            }];
        }
    }
}

// If we have synched everything, tell our listeners of the result and save
- (void) finishSyncWithSuccess: (Boolean) isSuccess
{
    NSLog(@"####MOC: %@ Thread: %@", [self moc], [NSThread currentThread]);

    self.syncStatus = SYNC_STATUS_CODING_COMPLETE;

    if ([self.rcoRecordType isEqualToString:@"Field"]) {
        NSLog(@"");
    }
    
    [self save];
    
    [self dispatchToTheListeners:kObjectSyncCompleteMsg];
    
    [self loadCaching];
}

- (void) addSync
{
}

- (void) subtractSync
{
}

- (void) startObjectDownload
{
    self.syncStatus = SYNC_STATUS_CODING;
    
    [self dispatchToTheListeners:kObjectSyncStartedMsg 
                        withArg1:[NSNumber numberWithUnsignedInteger:[self countObjectsToSync]]
                        withArg2:nil];
    
    
    [self checkForSyncDoneWithSuccess:true];
}

- (NSArray *) getObjectsToUpload
{
	
    NSString * statusString = [NSString stringWithFormat: @"(objectNeedsUploading == YES) AND (objectIsUploading == NO OR objectIsUploading == nil)"];
    
    NSArray *array = [self getSomeNarrowedBy:[NSPredicate predicateWithFormat:statusString] sortedBy:nil limitedTo:0];
   
    if( [array count] ) {
        return array;
    }
    return nil;
}

- (NSInteger) getObjectsToUploadCount {

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(objectNeedsUploading == YES) AND (objectIsUploading == NO OR objectIsUploading == nil)"];
    return [self countObjects: pred];
}

- (void) downloadNextObject
{
    
   Boolean bNetworkUnReachable = !(([[DataRepository sharedInstance] isNetworkReachableViaWWAN] ) ||
                                   ([[DataRepository sharedInstance] isNetworkReachableViaWifi] &&
                                    [[[DataRepository sharedInstance].networkOptions objectForKey:kWIFICodingKey] boolValue] ) );
    
    if( bNetworkUnReachable || ([self.objectsToDownload count] == 0 && [self.objectsToUpload count] == 0) )
    {
        [self save];
        if ([self.localObjectClass isEqualToString:@"Photo"]) {
            NSLog(@"");
        }
        return;
    }
    
    NSString *objId=nil;
    NSString *objType = nil;
    
    if( [self.objectsToDownload count] > 0 ) {
        id objIdAndType = [self.objectsToDownload objectAtIndex:0];
        
        if ([objIdAndType isKindOfClass:[NSString class]]) {
            NSArray *comp = [(NSString*)objIdAndType componentsSeparatedByString: @"/"];
            
            if( [comp count] > 1 ) {
                objId = [comp objectAtIndex:0];
                objType = [comp lastObject];
            }
        }
        
        if ([self.objectsToDownload containsObject:objIdAndType]) {
            [self.objectsToDownload removeObject:objIdAndType];
        }
    }
    
    if ([self.localObjectClass isEqualToString:@"Photo"]) {
        NSLog(@"");
    }
    
    if ([self.objectsToUpload count] > 0) {
     
        BOOL shouldUpdateRecords = [self shouldUpdateRecords];
        BOOL shouldUpdateRecordsAndUpload = [self shouldUpdateRecordsAndUploadRecords];
        
        if (shouldUpdateRecords) {
            [self dispatchToTheListeners:kObjectsUploadStartedMsg
                                withArg1:[NSNumber numberWithUnsignedInteger:[self.objectsToUpload count]]
                                withArg2:nil];
            [self updateRecords];
            
            if (shouldUpdateRecordsAndUpload) {
                // the normal flow for uploading objects, one by one using the set calls
                NSArray *uploadObjects = [self getObjectsToUpload];
                
                for(RCOObject *o in uploadObjects) {
                    if ([o.rcoRecordId length] == 0) {
                        [self uploadObject:o];
                    } else {
                        NSLog(@"Updating through the Update and not SET call!");
                    }
                }
            }
        } else {
            NSArray *uploadObjects = [self getObjectsToUpload];
            
            if (uploadObjects.count != self.objectsToUpload.count) {
                
                if ([self.localObjectClass isEqualToString:@"Photo"]) {

                    NSMutableArray *uploadObjectsTmp = [NSMutableArray arrayWithArray:uploadObjects];

                    for (NSString *objId in self.objectsToUpload) {
                        RCOObject *obj = [self getObjectWithId:objId];
                        NSLog(@"OBJ = %@", obj);
                            NSLog(@"");
                            if (obj && ![uploadObjectsTmp containsObject:obj]) {
                                [uploadObjectsTmp addObject:obj];
                            }
                        }
                    uploadObjects = [NSArray arrayWithArray:uploadObjectsTmp];
                }
            }
            
            [self dispatchToTheListeners:kObjectsUploadStartedMsg
                                withArg1:[NSNumber numberWithUnsignedInteger:[uploadObjects count]]
                                withArg2:nil];

            for(RCOObject *o in uploadObjects) {
                [self uploadObject:o];
            }
        }
        self.objectsToUpload = [NSMutableArray array];
        
        [self checkForSyncDoneWithSuccess:true];
           
        [self uploadingRecordsFinished];
    }
    
}

- (void) uploadingRecordsFinished {
    
}

#pragma mark - Content Background Sync
- (void) setFrontLoadImages: (Boolean) fli 
{
    // tell our children to stop as well
    for( Aggregate *detail in self.detailAggregates )
    {
        [detail setFrontLoadImages:fli];
    }   
    
    m_frontloadImages = fli;
}

- (NSArray *) getAllForContentDownload
{
    return [self getAll];
}

-(BOOL)objectHasContent:( RCOObject*)obj {
    __block BOOL hasContent = YES;
    [[self moc] performBlockAndWait:^{
        if( [[obj rcoFileTimestamp] longLongValue] ==  100 ||  [[obj rcoFileTimestamp] longLongValue] == 0)
            obj.rcoFileTimestamp = nil;
        
        hasContent = [obj rcoFileTimestamp] != nil;
    }];
    return hasContent;
}

-(BOOL)contentNeedsDownloading:(RCOObject*)obj {
    __block BOOL needsDownloading = YES;
    [[self moc] performBlockAndWait:^{
        needsDownloading = [self objectHasContent:obj] && [obj.fileNeedsDownloading boolValue];
    }];
    return needsDownloading;
}

-(BOOL)contentNeedsUploading:(RCOObject*)obj {
    
    return [obj fileNeedsUploading];
    
    __block BOOL needsUploading = YES;
    [[self moc] performBlockAndWait:^{
        needsUploading = [obj.fileNeedsUploading boolValue];
    }];
    return needsUploading;
}

- (Boolean) requestContentTransferStart
{
    NSArray *objects =  [self getAllForContentDownload];
    
    self.syncStatus = SYNC_STATUS_CONTENT;
    
    BOOL foundUntransferredContent = false;
    for ( RCOObject *obj in objects )
    {
        if( [self existsOnServer:obj] )
        {
            NSString *pels = @"-1";
            
            if( ![self objectHasContent:obj] )
            {
                if( [obj.fileNeedsDownloading boolValue]) {
                    [obj setContentNeedsDownloading:false];
                }
            }
            else if( [self contentNeedsDownloading:obj] )
            {
                
                foundUntransferredContent = true;
            }
            else if( self.frontLoadImages ) {
                if( ![self isDataDownloaded:obj.rcoObjectId size:pels] ) {
                    
                    [obj setContentNeedsDownloading:true];
                    foundUntransferredContent = true;
                    
                }
            }
            if ([self contentNeedsUploading:obj]) {
                foundUntransferredContent = true;
            }
        }
    }
    
    [self save];
    
    NSInteger numberOfUntransferredFiles = [self countFilesToSync];
    
    [self dispatchToTheListeners:kContentSyncStartedMsg 
                        withArg1:[NSNumber numberWithUnsignedInteger:numberOfUntransferredFiles] 
                        withArg2:nil];
     
    if( foundUntransferredContent ) {
        
        self.contentSynching=true;
        [self transferNextContent];
    }
    else {
        self.contentSucceded = YES;

        [self requestContentDownloadStop];
    }
    
    return true;
}


- (void) requestContentDownloadStop
{
    self.contentSynching=false;
    self.syncStatus = SYNC_STATUS_CONTENT_COMPLETE;

    [self dispatchToTheListeners:kContentSyncCompleteMsg];
}

- (RCOObject *) getNextContentObjToDownload
{
    if (self.skipSyncRecords) {
        return nil;
    }
        
    NSString * statusString = [NSString stringWithFormat: @"((fileNeedsDownloading == YES AND (fileIsDownloading == NO || fileIsDownloading == nil)) || (fileNeedsUploading == YES AND (fileIsUploading == NO || fileIsUploading == nil)))"];

    NSArray *array= [self getSomeNarrowedBy:[NSPredicate predicateWithFormat:statusString] sortedBy:nil limitedTo:1];
    
    if( [array count] )
        return [array objectAtIndex:0];
    
    return nil;
}

- (void) transferNextContent
{
    RCOObject *obj=nil;
    
    if (self.skipSyncRecords) {
        return;
    }
    
    if(! (([[DataRepository sharedInstance] isNetworkReachableViaWWAN] ) ||
          ([[DataRepository sharedInstance] isNetworkReachableViaWifi] && 
           [[[DataRepository sharedInstance].networkOptions objectForKey:kWIFIContentKey] boolValue] ) )  ||
       !self.contentSynching ||
       ((obj = [self getNextContentObjToDownload]) == nil) )
    {
        [self requestContentDownloadStop];
        [self dispatchToTheListeners:kContentSyncCompleteMsg];
        self.contentSucceded = YES;
        return;
    }
    
    if ([obj.fileNeedsUploading boolValue]) {
            [self uploadObjectContent:obj size:kImageSizeForUpload];
    } else {
        [self downloadDataForObject:obj.rcoObjectId size:@"-1"];
    }
}

- (void) contentRequestFinishedForObject: (NSString *) objId withSize: (NSString *) pels withSuccess: (Boolean) success {
    
    [self performSelectorOnMainThread:@selector(updateDownloadFlagsForObject:) withObject:objId waitUntilDone:YES];
    
    [self transferNextContent];
    
    if ([pels integerValue] == -1) {
        [self dispatchToTheListeners:kContentDownloadComplete withObjectId:objId];
    } else {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:objId forKey:RCOOBJECT_OBJECTID];
        [info setObject:pels forKey:RCOOBJECT_CONTENT_SIZE];
        [self dispatchToTheListeners:kContentDownloadCompleteWithInfo withMessageInfo:info];
        [self jumpstartDataDownloadForced:objId];
    }
}

-(void)updateDownloadFlagsForObject:(NSString*)objId {
    [[self moc] performBlockAndWait:^{
        RCOObject *obj = [self getObjectWithId:objId];
        [obj setContentNeedsDownloading:false];
        [obj setContentIsDownloading:false];
        [self save];
    }];
}

- (void) geocodeAddress:(NSString *) address inCity: (NSString *) city inState: (NSString *) state withZip: (NSString *) zip forObj:(NSString *) objId
{

}

- (NSDictionary *) fieldValuesDictionaryFromArray: (NSArray *) fieldValuesArray
{
    NSMutableDictionary * valuesDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary* fieldDictionary in fieldValuesArray) {
        NSString* label = [[fieldDictionary objectForKey:@"displayName"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* value = [fieldDictionary objectForKey:@"value"];
        if(  self.fieldsToSync == nil || [self.fieldsToSync containsObject:label] )
            [valuesDictionary setValue:value forKey:label];
        
    }
    return valuesDictionary;
    
}

- (RCOObject*) syncObjectWithId: (NSString *) objId
                        andType: (NSString *) objType
             toValuesDictionary:(NSDictionary *)valuesDictionary {
    
    return [self syncObjectWithId:objId
                          andType:objType
               toValuesDictionary:valuesDictionary
                      forceInsert:NO];
}

-(BOOL)overwriteRecord:(RCOObject*)obj {

    return YES;
}

-(BOOL)resetLocalFields {
    return YES;
}

- (RCOObject*) syncObjectWithId: (NSString *) objId
                        andType: (NSString *) objType
             toValuesDictionary:(NSDictionary *)valuesDictionary
                    forceInsert:(BOOL)forceInsert

{
    if(! [self.rcoObjectType isEqualToString:objType] ) {
        
        self.rcoObjectType = objType;
    }
    
    RCOObject* obj = nil;
    
    NSNumber *searchItem = [valuesDictionary objectForKey:SearchItemKey];
    
    if (syncType == SyncTypeFull) {
        static BOOL firstLog = YES;
        if (firstLog) {
            NSLog(@">>>FORCE insert for aggregate: %@", self);
            firstLog = NO;
        }
        if (!searchItem) {
            forceInsert = YES;
        } else {
            NSLog(@">>>>search this itemm %@", objId);
            forceInsert = NO;
        }
        
        BOOL checkItem = [self checkExistingItemBeforeInsertWhenDoingInitialSync];
        
        if (checkItem) {
            forceInsert = NO;
        }
        
    } else {
        static BOOL firstLog = YES;
        if (firstLog) {
            NSLog(@">>>SYNC <<< %d aggregate: %@", (int)syncType, self);
            firstLog = NO;
        }
        
        BOOL existItem = [self existObjectWithId:objId];
        if (!existItem) {
            forceInsert = YES;
        }
    }
    
    if (!forceInsert) {
        obj = (RCOObject*) [self getObjectWithId: objId];
    }
    
    if( obj == nil ) {
        obj = [self createObjectWithId: objId andType:objType];
    }
    else if( [obj needsUploading] )
    {
        BOOL bReadyToSync = true;
        NSString* value = [valuesDictionary objectForKey:@"codingTimestamp"];
        if( value == nil ) {
            value = [valuesDictionary objectForKey:@"RMS Coding Timestamp"];
        }
        
        NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
        [nsf setNumberStyle:NSNumberFormatterScientificStyle];
        NSNumber *tsFromServer = [nsf numberFromString: value];
        
        bReadyToSync = [tsFromServer longLongValue] == 0 || [tsFromServer longLongValue] > [[obj rcoObjectTimestamp] longLongValue];
    
        if (!bReadyToSync) {
            NSLog(@" %@ %@ %@ can't be downloaded because it needs to be uploaded.", self.localObjectClass,objId, objType);
            return obj;
        }
        
        if ([tsFromServer longLongValue] == [[obj rcoObjectTimestamp] longLongValue]) {
            return obj;
        }

        if (![self overwriteRecord:obj]) {
            return obj;
        }
        
        [self warnUserEditedObjectOverwritten:obj];
        
        [obj setNeedsUploading:false];
    }
    else if( [obj needsDeleting] )
    {
        return obj;
    }
    
    
    bool bFoundCodingTimeStamp = false;
    obj.rcoObjectSearchString = nil;
    
    //BOOL resetLocalFields = YES;
    BOOL resetLocalFields = [self resetLocalFields];
    
    NSString *recordId = [valuesDictionary objectForKey:@"RecordId"];
    
    if (!recordId) {
        // we need to skip this
        NSLog(@">>>>>>>>>>>>>RecordId is nil");
        resetLocalFields = NO;
    }
    
    NSString *barcode = [valuesDictionary objectForKey:@"BarCode"];
    
    if (!barcode) {
        resetLocalFields = NO;
    }

    
    if (resetLocalFields && [self existsOnServer:obj]) {
        NSEntityDescription *entity = [obj entity];
        
        NSDictionary *attributes = [entity attributesByName];
        NSArray *fieldsToSkipReseting = [NSArray arrayWithObjects:@"fileIsDownloading", @"fileIsUploading", @"fileNeedsDownloading", @"fileNeedsUploading", @"objectIsDownloading", @"objectIsUploading", @"objectNeedsDeleting", @"objectNeedsDownloading", @"objectNeedsUploading", @"rcoBarcode", @"rcoBarcodeParent", @"rcoFileSize", @"rcoFileTimestamp", @"rcoFileType", @"rcoMobileRecordId", @"rcoObjectClass", @"rcoObjectId", @"rcoObjectParentId", @"rcoObjectSearchString", @"rcoObjectTimestamp", @"rcoObjectType", @"rcoRecordId", @"itemType", @"linesToSave", nil];
        
        for (NSString *attribute in attributes) {
            if ([fieldsToSkipReseting containsObject:attribute]) {
                continue;
            }
            [obj setValue:nil forKey:attribute];
        }
    }
    
    for (NSString *theKey in [valuesDictionary allKeys] ) {
        
        if( self.fieldsToSync == nil || [self.fieldsToSync containsObject:theKey] ) {
            [self syncObject: obj withFieldName: theKey toFieldValue: [valuesDictionary objectForKey:theKey ]];
        }
        
        bFoundCodingTimeStamp = bFoundCodingTimeStamp || [theKey isEqualToString: @"codingTimestamp"] || [theKey isEqualToString: @"RMS Coding Timestamp"];
    }
    
    [self addObjectToCach:obj];
    
    if( !bFoundCodingTimeStamp ) {
    }
    if( [obj.rcoObjectTimestamp longLongValue] == kUninitializedRecordTimestamp ) {
        [obj setRcoObjectTimestamp:nil];
    }
    return obj;
}

-(BOOL)existsOnServer:(RCOObject*)obj {
    __block BOOL exist = NO;
    [[self moc] performBlockAndWait:^{
        exist = [obj existsOnServer];
    }];
    return exist;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue
{
    [[self moc] performBlockAndWait:^{
        
    // TODO: move to syncobject ?
    if (object.rcoObjectSearchString == nil) {
        object.rcoObjectSearchString = @"";
    }
    
    if( [fieldName isEqualToString: @"codingTimestamp"] || [fieldName isEqualToString: @"RMS Coding Timestamp"] )
    {
        NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
        [nsf setNumberStyle:NSNumberFormatterDecimalStyle];
        object.rcoObjectTimestamp = [nsf numberFromString: fieldValue];
        
        if( [object.rcoObjectTimestamp longLongValue] >= [self.synchingTimeStamp longLongValue] ) {
            self.synchingTimeStamp = [NSNumber numberWithLongLong:[object.rcoObjectTimestamp longLongValue]];
            if (![self.synchedRecordId isEqualToString:object.rcoRecordId]) {
                //03.05.2019 this is teh case when we synced the recordId before the timestamp
                self.synchedRecordId = object.rcoRecordId;
            }
        }
    }
    else if([fieldName isEqualToString: @"RMS Efile Timestamp"] )
    {
        NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
        [nsf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *ts= [nsf numberFromString: fieldValue];
        long long newTime = [ts longLongValue];
        
        if( newTime > [self.synchingTimeStamp longLongValue] )
            self.synchingTimeStamp = ts;
        
        if(  [object isKindOfClass:[RCOObject class]] )
        {
            if (newTime > [object.rcoFileTimestamp longLongValue] )
            {
                if( self.frontLoadImages )
                    [object setContentNeedsDownloading:true];
                
                object.rcoFileTimestamp = ts;
            }
            else 
            {
                object.rcoFileTimestamp = ts;
            }
        }
    }
    else if([fieldName isEqualToString: @"RMS File Size"] )
    {
        NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
        [nsf setNumberStyle:NSNumberFormatterNoStyle];
        object.rcoFileSize = [nsf numberFromString: fieldValue];
   }
    else if( [fieldName isEqualToString: @"parentObjectId"] )
    {
        object.rcoObjectParentId=fieldValue;
    }
    else if( [fieldName isEqualToString: @"objectType"] )
    {
        object.rcoObjectType = fieldValue;
    }
    else if( [fieldName isEqualToString: @"RecordId"] )
    {
        object.rcoRecordId = fieldValue;
        [object addSearchString:fieldValue];
        
        if ([self.synchingTimeStamp longLongValue] >= [object.rcoObjectTimestamp longLongValue]) {
            //03.05.2019 this is the case when we synced the timestamp before the recordId
            self.synchedRecordId = fieldValue;
        }
    }
    else if( [fieldName isEqualToString: @"BarCode"] )
    {
        object.rcoBarcode = fieldValue;
    } 
    else if( [fieldName isEqualToString: @"Master Barcode"] )
    {
        object.rcoBarcodeParent = fieldValue;
    }
    else if( [fieldName isEqualToString: @"FunctionalGroupName"] )
    {
        object.functionalGroupName = fieldValue;
    }
    else if( [fieldName isEqualToString: @"FunctionalGroupObjectId"] )
    {
        object.functionalGroupObjectId = fieldValue;
    }
    else if( [fieldName isEqualToString: @"MobileRecordId"] )
    {
        object.rcoMobileRecordId = fieldValue;
    }
    else if( [fieldName isEqualToString: @"CreatorRecordId"] )
    {
        object.creatorRecordId = fieldValue;
    }
    else if ([fieldName isEqualToString:@"ItemType"]){
        object.itemType = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Active"]){
        object.active = [NSNumber numberWithBool:[fieldValue boolValue]];
    }
    else if( [fieldName isEqualToString:@"Processed"] )
    {
        object.processed = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DeviceId"] )
    {
        object.deviceId = fieldValue;
    }
    }];
}

#pragma mark - data to server
- (BOOL) uploadObject: (RCOObject *) obj
{
    [self createNewRecord: obj];
    return YES;
}

- (NSString*)getSetCallStringForObjiect:(RCOObject*)object {
    return nil;
}

- (id ) createNewRecordFromCSVString: (NSString *) objCSVString forObject:(RCOObject*)obj {
    NSString *message = [NSString stringWithFormat:@"createNewRecordFromCSVString is not implemented for %@", self];
    [self showAlertMessage:message];
    return nil;
}

- (id ) createNewRecord: (RCOObject *) obj
{
    return nil;
}

- (id) createNewRecord: (RCOObject *) obj forced:(NSNumber*)forced {
    return nil;
}

- (id ) createNewRecords: (NSArray *) objects
{
    // this should be overwritten
    return nil;
}

- (id ) createNewRecord: (RCOObject *) obj withNumberOfDetails:(NSNumber*)numberOfDetails {

    return nil;
}

- (id ) createNewRecord: (RCOObject *) obj withDetails:(NSArray*)details {
    return nil;
}

- (BOOL)shouldUpdateRecords {
    return NO;
}

- (BOOL)shouldUpdateRecordsAndUploadRecords {
    return NO;
}

- (void)updateRecords {
}

-(void)createObject:(RCOObject*)object inTree:(NSString*)treeId withName:(NSString*)name andType:(NSString*)type {
}

- (void) destroyRecord:(NSString*)objectId andObjectType:(NSString*)objectType {
    if ((objectId.length == 0) || (objectType.length == 0)) {
        return;
    }
}

- (void) destroyRecord:(RCOObject *)obj;
{
    if (!obj) {
        return;
    }
}

-(void)removeObjectFromDeletedObjects:(NSString*)objectId {
    RCOObject *obj =  [self getObjectWithIdForDelete: objectId];
    
    if( obj ) {
        [[self moc] deleteObject:obj];
        NSError *error = nil;
        
        [[self moc] save:&error];
        
    } else {
    }
}

- (id ) uploadObjectCoding: (RCOObject *) obj
{
    return nil;
}


- (id ) uploadObjectContent: (RCOObject *) obj objectContent: (NSData *) contentData {

    return nil;
}

- (id ) uploadObjectContent: (RCOObject *) obj filePath: (NSString *) filePath {
    return nil;
}

- (id ) appendObjectContent: (RCOObject *) obj dataString: (NSString *) stringToAppend fileExtension:(NSString*)extension{
    return nil;
}

- (id ) appendObjectContent: (RCOObject *) obj dataString: (NSString *) stringToAppend {
    
    return [self appendObjectContent:obj dataString:stringToAppend fileExtension:nil];
}

- (id ) appendObjectContent: (RCOObject *) obj data: (NSData *) dataToAppend {
    return nil;
}

-(NSData*)getTempContent {
    NSURL *fullPath = [self getDirPathForObjectData];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir=YES;
    if(! [fileManager  fileExistsAtPath: [fullPath path] isDirectory:&isDir] )
    {
        NSError* error =nil;
        [fileManager createDirectoryAtPath:[fullPath path]  withIntermediateDirectories:YES attributes:nil error:&error];
        if (error !=nil) {
        }
    }
    NSString *fileName = [NSString stringWithFormat:@"%@_tempData.csv", self.rcoObjectClass];
    
    fullPath = [fullPath URLByAppendingPathComponent:fileName];
    if ([fileManager  fileExistsAtPath: [fullPath path]]) {
        return [NSData dataWithContentsOfURL:fullPath];
    }
    return nil;
}

- (id ) uploadObjectContent: (RCOObject *) obj fromURL:(NSURL*)fileURL {
    
    [self save];
    
    NSString *rcoObjId = nil;
    NSString *rcoObjType = nil;
    
    if ([obj.rcoObjectType length]) {
        // old way of uploading
        rcoObjId = obj.rcoObjectId;
        rcoObjType = obj.rcoObjectType;
    } else {
        rcoObjId = obj.rcoRecordId;
        rcoObjType = RCO_OBJECT_TYPE_RECORD_ID;
    }
    return [[DataRepository sharedInstance] tellTheCloud:RD_S
                                                 withMsg:R_S_C_1
                                              withParams:[NSString stringWithFormat:@"%@/%@/%@/+", rcoObjId, rcoObjType, @"+"]
                                                withData:nil
                                                withFile:[fileURL path]
                                               andObject:rcoObjId
                                              callBackTo:self];
}

- (id ) uploadObjectContent: (RCOObject *) obj size: (NSString *) pels {
    
    NSURL *fp = nil;
    NSURL *fpObjectIdURL = [self getFilePathForObjectImage: obj.rcoObjectId size:pels];
    NSURL *fpRecordIdURL = [self getFilePathForObjectImage: obj.rcoRecordId size:pels];
    
    NSString *rcoObjId = nil;
    NSString *rcoObjType = nil;
    
    if ([obj.rcoObjectType length]) {
        rcoObjId = obj.rcoObjectId;
        rcoObjType = obj.rcoObjectType;
    } else {
        rcoObjId = obj.rcoRecordId;
        rcoObjType = @"[[recordid]]";
    }

    NSError *err = nil;
    if ([fpObjectIdURL checkResourceIsReachableAndReturnError:&err] == NO) {
        if ([fpRecordIdURL checkResourceIsReachableAndReturnError:&err] == NO) {
            fp = fpObjectIdURL;
        } else {
            fp = fpRecordIdURL;
        }
    } else {
        fp = fpObjectIdURL;
    }
    
    err = nil;
    
    if ([fp checkResourceIsReachableAndReturnError:&err] == NO) {
        
        NSURL *fpMobileRecordId = [self getFilePathForObjectImage: obj.rcoMobileRecordId size:pels];
        NSURL *fpObjectId = [self getFilePathForObjectImage: obj.rcoObjectId size:pels];

        if ([fpMobileRecordId checkResourceIsReachableAndReturnError:&err]) {
            fp = fpMobileRecordId;
        } else if ([fpObjectId checkResourceIsReachableAndReturnError:&err]) {
            fp = fpObjectId;
        }
    }
    
    [self save];
    
    return [[DataRepository sharedInstance] tellTheCloud:RD_S
                                                 withMsg:R_S_C_1
                                              withParams:[NSString stringWithFormat:@"%@/%@/%@/+", rcoObjId, rcoObjType, @"+"]
                                                withData:nil
                                                withFile:[fp path]
                                               andObject:rcoObjId
                                              callBackTo:self];
    
}

- (id ) uploadObjectContent: (NSDictionary *) objDict
{
    NSString *rcoObjectId = [objDict objectForKey:@"rcoObjectId"];
    NSString *objectType = [objDict objectForKey:@"rcoObjectType"];
    NSString *rcoMobileRecordId = [objDict objectForKey:@"rcoMobileRecordId"];
    NSString *pels = [objDict objectForKey:@"pels"];

    NSURL *fp = [self getFilePathForObjectImage: rcoObjectId size:pels];
    
    NSError *err = nil;
    if ([fp checkResourceIsReachableAndReturnError:&err] == NO) {
        fp = [self getFilePathForObjectImage: rcoMobileRecordId size:pels];
    }
    return [[DataRepository sharedInstance] tellTheCloud:RD_S
                                                 withMsg:R_S_C_1
                                              withParams: [NSString stringWithFormat:@"%@/%@/%@/+", rcoObjectId, objectType, @"+"]
                                                withData:nil
                                                withFile:[fp path]
                                               andObject:rcoObjectId
                                              callBackTo:self];
    
}


- (NSString *) getObjectCodingForUpload: (RCOObject *) obj
{
    return @"";
}

- (NSString *) addCodingField: (NSString *) field withValue: (NSString *) value toData: (NSString *) data
{
    NSString  * escapedValue = @"";
    if( [value length] > 0 )
        escapedValue = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                            (CFStringRef) value,
                                                                            CFSTR(""),
                                                                            CFSTR(",\n"),
                                                                            kCFStringEncodingUTF8));
    
    data = [NSString stringWithFormat: @"%@%@,%@\n", data, field, escapedValue];
    if( [value length] > 0 ) {
        CFRelease((__bridge CFTypeRef)(escapedValue));
    }
    
    return data;
}

- (NSDate*)dateFrom:(NSString*)dateStr andTime:(NSString*)timeStr {
    
    if ([dateStr length] == 0) {
        return nil;
    }
    
    NSDate *date = [self rcoStringToDate:dateStr];
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    if (timeStr) {
        NSArray *components = [timeStr componentsSeparatedByString:@":"];
        if ([components count] == 3) {
            timeStamp += [[components objectAtIndex:0] integerValue] *3600;
            timeStamp += [[components objectAtIndex:1] integerValue] *60;
            timeStamp += [[components objectAtIndex:2] integerValue];
        } else if ([components count] == 2) {
            timeStamp += [[components objectAtIndex:0] integerValue] *3600;
            timeStamp += [[components objectAtIndex:1] integerValue] *60;
        }
    }
    
    return [NSDate dateWithTimeIntervalSince1970:timeStamp];
}

-(void) updateObjectWithId:(NSString*)objectId andObjectType:(NSString*)objectType withValues:(NSDictionary*)values {
}

#pragma mark - Data Formatting

- (NSString *) rcoDateToString: (NSDate *) aDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date_str =[dateFormat stringFromDate:aDate];
   
    
    return date_str;
}

- (NSDate *) rcoStringToDateYYYYMMDD: (NSString *) aDateStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date =[dateFormat dateFromString:aDateStr];
    
    
    return date;
}
- (NSString *) rcoDateToString: (NSDate *) aDate withSepatrator:(NSString*)separator
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@dd", separator, separator]];
    
    NSString *date_str =[dateFormat stringFromDate:aDate];
    
    
    return date_str;
}

- (NSString *) rcoDateTimeToString: (NSDate *) aDate withSepatrator:(NSString*)separator
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@dd HH%@mm%@ss", separator, separator, separator, separator]];
    
    NSString *date_str =[dateFormat stringFromDate:aDate];
    
    return date_str;
}


- (NSString *) rcoTimeToString: (NSDate *) aTime
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"hh:mm:ss"];
    
    NSString *time_str =[f stringFromDate:aTime];
    
    
    return time_str;
}

- (NSString *) rcoTimeHHmmssToString: (NSDate *) aTime
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"HH:mm:ss"];
    
    NSString *time_str =[f stringFromDate:aTime];
    
    
    return time_str;
}

- (NSString *) rcoDateAndTimeToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}

- (NSString *) rcoDateAndTimeToStringNoSeconds: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}


- (NSString *) rcoDateRMSToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSString *time_str =[f stringFromDate:aDate];
        
    return time_str;
}

- (NSString *) rcoDateRMSToString2: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yy"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}

- (NSDate *) rcoStringRMSToDate: (NSString *) dateStr
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSDate *date = [f dateFromString:dateStr];
    
    if ([dateStr length] && !date) {
        NSLog(@" 2 wrongggg fromatttttt");
    }

    return date;
}

- (NSDate *) MMDDYYYYStringToDate: (NSString *) aDateStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"MMddyyyy"];
    
    NSDate *theDate =  [f dateFromString:aDateStr];
    
    return theDate;
}

- (NSDate *) yyMMddStringToDate: (NSString *) aDateStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"YYMMdd"];
    
    NSDate *theDate =  [f dateFromString:aDateStr];
    
    return theDate;
}

- (NSDate *) yyyyMMddStringToDate: (NSString *) aDateStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"yyyyMMdd"];
    
    NSDate *theDate =  [f dateFromString:aDateStr];
    
    return theDate;
}


- (NSDate *) rcoStringToDate: (NSString *) aDateStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    
    NSArray *items = [aDateStr componentsSeparatedByString:@"-"];
    if (items.count > 1) {
        [f setDateFormat: @"yyyy-MM-dd HH:mm:ss.SSS"];
    } else {
        [f setDateFormat: @"MM/dd/yyyy"];
    }
    
    NSDate *theDate =  [f dateFromString:aDateStr];
    
    if ([aDateStr length] && !theDate) {
        NSLog(@" 1 wrongggg fromatttttt");
    }

    return theDate;
}



- (NSDate *) rcoStringToDateTime: (NSString *) aDateStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    
    // we need to check date format
    NSArray *items = [aDateStr componentsSeparatedByString:@"-"];
    if (items.count > 1) {
        [f setDateFormat: @"yyyy-MM-dd HH:mm:ss.SSS"];
    } else {
        items = [aDateStr componentsSeparatedByString:@":"];
        if (items.count > 1) {
            [f setDateFormat: @"MM/dd/yyyy HH:mm:ss"];
        } else {
            [f setDateFormat: @"MM/dd/yyyy"];
        }
    }
    
    NSDate *theDate =  [f dateFromString:aDateStr];
    
    if ([aDateStr length] && !theDate) {
        NSLog(@" wrongggg fromatttttt");
        [f setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        theDate =  [f dateFromString:aDateStr];
    }
    
    return theDate;
}

- (NSString *) RCOFilterDateTimeRMSToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}

- (NSString *) rcoDateTimeRMSToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}

- (NSDate *) rcoStringToTime: (NSString *) aTimeStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"HH:mm"];
    
    NSDate *theTime =  [f dateFromString:aTimeStr];
        
    
    return theTime;
}

- (NSString*)unescapeString:(NSString*)text {
    NSString *result = [NSString stringWithFormat:@"%@", text];
    
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUnicodeStringEncoding];
    result = [result stringByReplacingOccurrencesOfString:@"\\u003d" withString:@"="];
    result = [result stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\\r" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\\t" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return result;
}

#pragma mark - Utility Calls
- (void)getPhotosForObject:(RCOObject*)object withParent:(NSString*)parentRecordId {
}

- (void)getChildrenDirectoryIds:(RCOObject*)object childrenType:(NSString*)type {
}

- (void)getChildrenDirectoryIdsByRecordId:(NSString*)recordId childrenType:(NSString*)type {
}

- (void)getChildrenByTreeId: (NSString *) treeId  childrenType:(NSString*)type  {
}

- (void)getFileFolders  {
    
}

- (void)getFilterCategoryPaths  {
}

- (void)getContainerPaths: (NSString *) recordType  {
}

- (void)getNodeInfo: (NSString*) objectId withRecordId: (NSString *) rcoRecordId  {
}

- (void)getLatLonByRecordType: (NSString *) recordType   {
}

#pragma mark - call back to listeners

- (void) registerForCallback: (id<RCODataDelegate>) callbackObject
{
    if( ! [self.listeners containsObject:callbackObject] ) 
    {
        [self.listeners addObject:callbackObject];   
    }
}

- (void) registerDetailForCallback: (id<RCODataDelegate>) callbackObject
{
    for (Aggregate *detailAgg in self.detailAggregates) {
        if( ! [detailAgg.listeners containsObject:callbackObject] )
        {
            [detailAgg.listeners addObject:callbackObject];
        }
    }
}

- (void) unRegisterForCallback:  (id<RCODataDelegate>)  callbackObject
{
    [self.listeners removeObject:callbackObject];   
}

- (void) unRegisterDetailForCallback: (id<RCODataDelegate>) callbackObject
{
    for (Aggregate *detailAgg in self.detailAggregates) {
        [detailAgg.listeners removeObject:callbackObject];
    }
}


// image frontload
#pragma mark - RCO Data Delegate message forwarding
- (void) dispatchToTheListeners: (NSString *) msg
{
    [self dispatchToTheListeners:msg withArg1:nil withArg2:nil];
    
}
- (void) dispatchToTheListeners: (NSString *) msg withMessageInfo:(NSDictionary *) messageInfo
{
    [self dispatchToTheListeners:msg withArg1:messageInfo withArg2:nil];
}

- (void) dispatchToTheListeners: (NSString *) msg withObjectId:(NSString *) objId
{
    [self dispatchToTheListeners:msg withArg1:objId withArg2:nil];
}

- (void) dispatchToTheListeners: (NSString *) msg withObjects:(NSArray *) objects
{
    [self dispatchToTheListeners:msg withArg1:objects withArg2:nil];
}


- (void) dispatchToTheListeners: (NSString *) msg 
                       withArg1: (NSObject *) arg1 
                       withArg2: (NSObject *) arg2 
{
    NSArray *arr = [NSArray arrayWithObjects:msg, arg1, arg2, nil];
                     
   [self performSelectorOnMainThread:@selector(tellTheListeners:) withObject:arr waitUntilDone:false];
    
}

- (void) tellTheListeners: (NSArray *) arguments
{
    if( [[NSThread currentThread] isEqual:[NSThread mainThread]] ) {
        NSString *msgName = [arguments objectAtIndex:0];
        
        SEL theSel = NSSelectorFromString(msgName);
        
        id<RCODataDelegate> listener;
        
        for( listener in self.listeners )
        {
            if( [listener respondsToSelector:theSel] ) 
            {
                //NSLog(@"tellTheListeners: %@ responding to %@", listener, msgName);
                id<RCONestedListDelegate> listListener = (id<RCONestedListDelegate>) listener;
                
                if( [arguments count] > 2 ) {
                    if( [msgName isEqualToString:kListReady] ) {
                        [listListener listReady: [arguments objectAtIndex:1]
                                  forCategories: [arguments objectAtIndex:2]
                              hasSubdirectories: [arguments objectAtIndex:3]
                                  fromAggregate: self];
                    }
                }
                else if( [arguments count] == 2 ) {
                    [listener performSelector:theSel withObject:[arguments objectAtIndex:1] withObject:self];
                }
                else {
                    NSArray *numberOfArguments = [msgName componentsSeparatedByString:@":"];
                    
                    if ([numberOfArguments count] == 2) {
                        // we have just one parameter
                        [listener performSelector:theSel withObject:self];
                    }
                }
            }
            else {
            }
        }
    }
    else {
        [self performSelectorOnMainThread:@selector(tellTheListeners:) withObject:arguments waitUntilDone:false];
    }
}



#pragma mark -
#pragma mark call back from server

// call back from the connection object that a request has failed.
- (void)requestStarted:(id )request
{
}

- (void)requestFinished:(id )request
{
    NSDictionary *msgDict = nil;
    NSString *msgCall = nil;
    NSInteger responseStatusCode = -1;
     {
        NSDictionary *respDict = (NSDictionary*)request;
        msgDict = [respDict objectForKey:RESPONSE_USER_INFO];
        msgCall = [respDict objectForKey:RESPONSE_CALL];
    }
    
    NSNumber *highPriority =  (NSNumber *)[msgDict objectForKey:@"highPriority"];

    
    if( self.syncStatus != SYNC_STATUS_PAUSED ) {
        if( [highPriority boolValue] ) {
            [self performSelector:@selector(requestFinished_Bkgd:) onThread:[self threadForUpload] withObject:request waitUntilDone:NO];
        }
        else {
            [self performSelector:@selector(requestFinished_Bkgd:) onThread:[self threadForDownload] withObject:request waitUntilDone:NO];
        }
    }
}

- (void)requestFailed:(id )request
{
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSError *error = [self getErrorObjFromRequestResponse:request];
    NSString *url = [self getCallURLFromRequestResponse:request];
    NSString *errorStr = [self getErrorFromRequestResponse:request];
    
    NSString *errString = [self getErrorFromRequestResponse:request];
    
    if( error ) {
        errString = [error description];
    } else {
        errString = errorStr;
    }
    
    if( errString ) {
        if( [self.firstErrorMessages count] < kErrorMessagesToLog ) {
            [self.firstErrorMessages addObject:errString];
        }
        else
        {
            if( [self.lastErrorMessages count] >= kErrorMessagesToLog ) {
                [self.lastErrorMessages removeObjectAtIndex:0];
            }
            [self.lastErrorMessages addObject:errString];
        }
    }
    
    NSNumber *highPriority =  (NSNumber *)[msgDict objectForKey:@"highPriority"];
    
    if( self.syncStatus != SYNC_STATUS_PAUSED ) {
        if( [highPriority boolValue] ) {
            [self performSelector:@selector(requestFailed_Bkgd:) onThread:[self threadForUpload] withObject:request waitUntilDone:NO];
        }
        else {
            [self performSelector:@selector(requestFailed_Bkgd:) onThread:[self threadForDownload] withObject:request waitUntilDone:NO];
            
        }
    }
}

- (void)requestFailed_Bkgd:(id )request
{
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSInteger responseStatusCode = [[self getErrorFromRequestResponse:request] integerValue];

    NSString *msg = [msgDict objectForKey:@"message"];
   
    if ([msg hasPrefix: RD_G_U_C] || [msg hasPrefix: RD_G_R_U_X_F_C]) {
        self.countCallDone = NO;
        [self resetSyncType];
    } else if(  [msg hasPrefix: RD_G_I_PREFIX] || [msg isEqualToString:RD_G_B_T_U])
    {
        [self subtractSync];
        [self checkForSyncDoneWithSuccess:false];
        
        if( self.syncStatus == SYNC_STATUS_REQUEST ) {
            
            self.syncStatus = SYNC_STATUS_REQUEST_COMPLETE;
            [self dispatchToTheListeners:kObjectSyncRequestCompletedMsg
                                withArg1:[NSNumber numberWithUnsignedInteger:[self countObjectsToSync] ]
                                withArg2:nil];

        }
    }
    else if([msg isEqualToString: R_S_C_1])
    {
        [self requestFailed_RecordSetCoding:request];
    }
    else if([msg isEqualToString: R_G_C_1])
    {
        [self requestFailed_RecordGetCoding:request];
    }
    else if([msg isEqualToString: R_G_C])
    {
        NSString *objId =(NSString *)[msgDict objectForKey:@"objId"];
        NSString *params = (NSString *)[msgDict objectForKey:@"params"];
        NSArray *comp = [params componentsSeparatedByString: @"/"];
        NSError *error = [self getErrorObjFromRequestResponse:request];
        
        NSURL *fp = [self getFilePathForObjectImage:objId size:[comp lastObject]];
        RCOObject *obj = [self getObjectWithId:objId];
        
        if(((error.code >= NSPropertyListErrorMinimum && error.code <= NSPropertyListErrorMaximum && [error.domain isEqualToString:NSCocoaErrorDomain])
            || responseStatusCode == 0) &&
           self.syncStatus != SYNC_STATUS_PAUSED ) {
            [self.contentThatFailedToDownload performSelector:@selector(addObject:) onThread:[self threadForDownload] withObject:fp waitUntilDone:false];
            
            // don't try to download this again
            [[self moc] performBlockAndWait:^{
                [obj setHasNoContent];
            }];
        }
        
        // if the file doensn;t exist, don't try to keep downloading it.
        NSDictionary *responseDict = [msgDict objectForKey:@"responseDict"];
        NSString *response = [responseDict objectForKey:@"response"];
        NSRange aRange = [response rangeOfString:@"No EFile version found"];
        if( aRange.location == NSNotFound ) {
            aRange = [response rangeOfString:@"java.io.FileNotFoundException"];
        }
        NSString *comment = (aRange.location != NSNotFound) ? [response substringWithRange:aRange] : response;
        
        if( [comment length] ) {
        }
        else{
        }
        
        if(aRange.location != NSNotFound) {
            [[self moc] performBlockAndWait:^{
                [obj setHasNoContent];
                [obj setContentNeedsDownloading:false];
                [obj setContentIsDownloading:false];
            }];
            [self save];
        }
        
        // ??? set fileLog if we are setting the object as having no content?
        [[self moc] performBlockAndWait:^{
            obj.fileLog = comment;
        }];

        [self contentRequestFinishedForObject:objId withSize: [comp lastObject] withSuccess:false];
    }
}

- (void) requestFailed_RecordSetCoding:(id )request
{
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *errorMsg = [self getErrorFromRequestResponse:request];
    NSError *error = [self getErrorObjFromRequestResponse:request];
    //NSString *msg = [msgDict objectForKey:@"message"];

    RCOObject *obj = [self getObjectWithId:[msgDict objectForKey:@"objId"]];
    [obj setIsUploading:false];
    [obj setNeedsUploading:true];
    
    if (error) {
        obj.objectLog = [error description];
    } else {
        obj.objectLog = errorMsg;
    }

    NSString *objId =(NSString *)[msgDict objectForKey:@"objId"];
    [self save];
    [self dispatchToTheListeners:kObjectUploadFailed withObjectId:objId];
    
    [self checkForSyncDoneWithSuccess:true];
}

- (void) requestFailed_RecordGetCoding:(id )request
{
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    NSString *objId =(NSString *)[msgDict objectForKey:@"objId"];
    
    
    NSString *objTypeAndId = (NSString *)[msgDict objectForKey:@"params"];
    NSString *ts = [self.recordsAwaitingDownload objectForKey:objTypeAndId];
    NSNumber *tsFromServer = nil;
    
    // turn the string into a number
    NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
    [nsf setNumberStyle:NSNumberFormatterScientificStyle];
    if( ts == nil ) {
        
        tsFromServer = [NSNumber numberWithLongLong:[self.synchedTimeStamp longLongValue]];
        
        if( [self.recordsAwaitingDownload count] > 0 ) {
            NSArray *waitingTimestamps =[self.recordsAwaitingDownload allValues];
            NSArray *sortedTimestamps = [waitingTimestamps sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                long long n1 = [[nsf numberFromString: obj1] longLongValue];
                long long n2 = [[nsf numberFromString: obj2] longLongValue];
                
                if (n1 > n2) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if (n1 < n2) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;

            }];
            
            tsFromServer = [nsf numberFromString: [sortedTimestamps lastObject]];
        }
    }
    else {
        tsFromServer = [nsf numberFromString: ts];
    }
    
    if( [tsFromServer longLongValue] < [self.synchedTimeStamp longLongValue] ) {
        tsFromServer = [NSNumber numberWithLongLong:[self.synchedTimeStamp longLongValue]];
    }

    if( objTypeAndId != nil ) {
        if( [self.recordsThatFailedToDownloadDict objectForKey:objTypeAndId] == nil ) {
            if (!tsFromServer) {
                tsFromServer = [NSNumber numberWithDouble:0];
            }
            [self.recordsThatFailedToDownloadDict setObject:tsFromServer forKey:objTypeAndId];
            [self.objectsToDownload addObject:objTypeAndId];
        }
        else {
            [self.recordsAwaitingDownload removeObjectForKey:objTypeAndId];
            [self dispatchToTheListeners:kObjectDownloadFailed withObjectId:objId];
            
            if( [tsFromServer longLongValue] > 0 &&
               (self.synchedMinErrorTimeStamp == nil ||
                [self.synchedMinErrorTimeStamp longLongValue] > [tsFromServer longLongValue]) )
            {
                self.synchedMinErrorTimeStamp = [NSNumber numberWithLongLong:[tsFromServer longLongValue]-1];
            }
            else if ( [tsFromServer longLongValue] == 0 ) {
                self.synchedMinErrorTimeStamp = [NSNumber numberWithLongLong:self.synchedTimeStamp];
            }
        }
    }
    else {
        self.synchedMinErrorTimeStamp = [NSNumber numberWithLongLong:tsFromServer];
    }
    
    [self checkForSyncDoneWithSuccess:true];
    
}

-(void)updateUploadingFlagForObject:(NSString*)objectId {
    
    RCOObject *obj = nil;
    
    if ([self isMobileRecordId:objectId]) {
        obj = [self getObjectMobileRecordId:objectId];
    } else {
        obj =  [self getObjectWithId:objectId];
    }
    
    obj.fileIsUploading = [NSNumber numberWithBool:NO];
    obj.fileNeedsUploading = [NSNumber numberWithBool:NO];
    
    [self save];
}

-(BOOL)isMobileRecordId:(NSString*)objId {
    NSRange range = [objId rangeOfString:@"-"];
    
    if (range.location != NSNotFound) {
        return NO;
    }
    return YES;
}

- (void)requestFinished_Bkgd:(id )request {
    NSString *response = nil;
    NSDictionary *msgDict = nil;
    NSString *msg = nil;
    NSString *responseString = [self getResponseStringFromRequest:request];
    NSInteger responseStatusCode = [[self getErrorFromRequestResponse:request] integerValue];

    NSDictionary *respDict = (NSDictionary*)request;
    response = [respDict objectForKey:RESPONSE_STR];
    msgDict = [respDict objectForKey:RESPONSE_USER_INFO];

    msg = [msgDict objectForKey:@"message"];
    
    if( [msg isEqualToString: R_S_C_1]) {
        RCOObject *obj = [self getObjectWithId: [msgDict objectForKey:@"objId"]];
        if (obj) {
            NSNumber *skipGetRecordCoding = [msgDict objectForKey:kSkipGetRecordCoding];
            
            if ([skipGetRecordCoding boolValue]) {
                [self requestFinished_RecordSetCoding: obj withMsg:msg andResponse:response skipGetRecordCoding:YES];
            } else {
                [self requestFinished_RecordSetCoding: obj withMsg:msg andResponse:response ];
            }
        }
    }
    else if( [msg isEqualToString: R_S_C_1]) {
        
        NSString *objId = [msgDict objectForKey:@"objId"];

        [self performSelectorOnMainThread:@selector(updateUploadingFlagForObject:) withObject:objId waitUntilDone:YES];

        NSURL *fp = [self getFilePathForObjectImage:objId size:kImageSizeForUpload];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        [fm removeItemAtURL:fp error:&error];

        [self dispatchToTheListeners:kObjectContentUploadComplete withArg1:msgDict withArg2:nil];        
    }
        
    NSArray* fieldValues = nil;
    
    respDict = (NSDictionary*)request;
    
    id obj = [respDict objectForKey:RESPONSE_OBJ];
    if ([obj isKindOfClass:[NSData class]]) {
        // if is a data response then we should not do anything
    } else if ([obj isKindOfClass:[NSArray class]]){
        fieldValues = (NSArray*)obj;
    }
    
    NSInteger fieldsCount = [fieldValues count];
    
    if ([msg isEqualToString:RD_G_R_U_F] || [msg isEqualToString:RD_G_R_U_X_F]) {
        fieldsCount = 1;
    }
    
    if( fieldValues != nil && fieldsCount > 0) {
        NSString* objId=nil;
        if ([msg isEqualToString:RD_G_U_C] || [msg isEqualToString:RD_G_R_U_X_F_C]) {
            if (fieldValues.count) {
                
                self.countCallDone = YES;
                NSString *numberOfRecordsToUpdate = [fieldValues objectAtIndex:0];
                
                self.numberOfItemsToSync = [numberOfRecordsToUpdate integerValue];
                self.syncStatus = SYNC_STATUS_REQUEST_COMPLETE;
                
                [self dispatchToTheListeners:kObjectSyncRequestCompletedMsg
                                    withArg1:[NSNumber numberWithUnsignedInteger:[numberOfRecordsToUpdate integerValue]]
                                    withArg2:nil];
                
                self.syncStatus = SYNC_STATUS_CODING;
                [self dispatchToTheListeners:kObjectSyncStartedMsg
                                    withArg1:[NSNumber numberWithUnsignedInteger:[numberOfRecordsToUpdate integerValue]]
                                    withArg2:nil];
                
                if (!self.numberOfItemsToSync) {
                    // 08.05.2019 if the number if records to update is zero then we should not make the call to get the records updated filtered
                    [self checkForSyncDoneWithSuccess:true];
                    Boolean bCheckForDeletions = [self.synchingTimeStamp longLongValue] == 0;
                    if (bCheckForDeletions) {
                        [self requestSyncRecords];
                    }
                } else {
                    [self requestSyncRecords];
                }
            }
        } else if( [msg isEqualToString:RD_G_I] || [msg isEqualToString:RD_G_I_B] ) {
            // kick out the jams
            [self removeDeletedObjects:fieldValues];
            
            if( self.syncStatus < SYNC_STATUS_REQUEST_COMPLETE ) {
                NSLog(@"               : %lu total %@ objects",(unsigned long)[fieldValues count], [self uniqueName] );
                if ([msg isEqualToString:RD_G_I] || [fieldValues count] > MAX_RECORDS) {
                    [self requestFinished_RecordGetIds: fieldValues];
                } else {
                    [self requestFinished_RecordGetRecords: fieldValues];
                }
            }
        }
        else if ([msg isEqualToString:RD_G_I_U] ||
                 [msg isEqualToString:RD_G_I_B_U] ||
                 [msg isEqualToString:RD_G_R_U_F])
        {
            Boolean bCheckForDeletions = [self.synchingTimeStamp longLongValue] == 0;
            NSString *objId = [msgDict objectForKey:@"objId"];
            
            BOOL isFilteringCall = NO;
            
            if ([objId length] && ([objId integerValue] == 0)) {
                NSLog(@"");
                // Tis is not a full SYNC!
                bCheckForDeletions = NO;
                isFilteringCall = YES;
            }
            
            if ([self.localObjectClass isEqualToString:@"Note"] && bCheckForDeletions) {
                bCheckForDeletions = NO;
            }
            
            if( bCheckForDeletions ) {
                [self removeDeletedObjects:fieldValues];
            }
            
            NSString *objIdORBarcode = [msgDict objectForKey:@"objId"];
            
            if ([objIdORBarcode length]) {
                [self performSelectorOnMainThread:@selector(requestFinished_RecordGetIds_1:) withObject:fieldValues waitUntilDone:YES];
                [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:msgDict withArg2:nil];
            } else {
                // old logic, this is the logic for the sync
                [self requestFinished_RecordGetIds:fieldValues];
            }

            NSLog(@"               : %lu updated %@ objects, synchedTimeStamp = %@, synchingTimeStamp = %@, self(aggregate) = %@", (unsigned long)[fieldValues count], [self uniqueName], self.synchedTimeStamp, self.synchingTimeStamp, self);
        }
        else if ([msg isEqualToString:RD_G_B_T_U] ||
                 [msg isEqualToString:RD_G_R_U_X_F])
        {
            Boolean bCheckForDeletions = [self.synchingTimeStamp longLongValue] == 0;
            if( bCheckForDeletions ) {
                if ([self resetExistingRecordsWhenLoggingWithDifferentUser]) {
                    [self removeDeletedObjects:fieldValues];
                }
            }
            
            if ([[DataRepository sharedInstance] isNewSyncImplementation]) {
                
                if ([[DataRepository sharedInstance] useNewSyncJustAtBeggining] && (syncType != SyncTypeFull)) {
                    // this is the ols sync
                    if( [fieldValues count] <= MAX_RECORDS ) {
                        [self requestFinished_RecordGetRecords: fieldValues];
                    } else {
                        [self requestFinished_RecordGetIds:fieldValues];
                    }
                    return;
                }
                BOOL isSyncDone = YES;
                if (([fieldValues count] >= BATCH_SIZE)/*([fieldValues count] == BATCH_SIZE)*/ || ([fieldValues count] == self.batchSize)) {
                    isSyncDone = NO;
                }
                
                if (syncType == SyncTypeFull) {
                    [self requestFinished_RecordGetRecordsNew: fieldValues syncDone:isSyncDone fullSync:YES];
                } else {
                    [self requestFinished_RecordGetRecordsNew: fieldValues syncDone:isSyncDone];
                }
                if (!isSyncDone) {
                    [self performSelector:@selector(requestSync) withObject:nil afterDelay:0.1];
                } else {
                    syncType = SyncTypeUnknown;
                    [self checkForSyncDoneWithSuccess:true];
                }
            } else {
                if( [fieldValues count] <= MAX_RECORDS )
                    [self requestFinished_RecordGetRecords: fieldValues];
                else
                    [self requestFinished_RecordGetIds: fieldValues];
            }
        }
        else if( [msg isEqualToString: R_G_C_1])
        {
            objId =(NSString *)[msgDict objectForKey:@"objId"];
            NSString *params = (NSString *)[msgDict objectForKey:@"params"];
            
            NSArray *comp = [params componentsSeparatedByString: @"/"];
            
            NSString *objType = [comp lastObject];
            
            [self requestFinished_RecordGetCoding:objId withType:objType andValuesArray:fieldValues orValuesDictionary:nil downloadNextObject:true];
        }
        else if( [msg isEqualToString: R_G_C])
        {
            if ((responseStatusCode != 200) && (responseStatusCode != 0)) {
                // response is nil, we should parse it as request failed
                [self requestFailed_Bkgd:request];
                return;
            }
            
            NSDictionary *responseDict = [msgDict objectForKey:RESPONSEDICT_KEY];
            
            if (!objId) {
                responseDict = msgDict;
                objId = [responseDict objectForKey:@"objId"];
            }
            
            if( response == nil ) {
                response = [responseDict objectForKey:@"response"];
            }
            
            NSString *params = (NSString *)[msgDict objectForKey:@"params"];
            
            NSArray *comp = [params componentsSeparatedByString: @"/"];
            NSString *pels = [comp lastObject];
            
            // create thumb?
            if( [pels isEqualToString:@"-1"] && [self.defaultImageSizes count] > 1)
            {
                NSData *theData = [self getDataForObject:objId size:pels];
                
                for( NSString *theSize in self.defaultImageSizes )
                {
                    NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
                    [nsf setNumberStyle:NSNumberFormatterNoStyle];
                    
                    if( ![theSize isEqualToString:@"-1"] && theData != nil) {
                        
                        NSNumber *nn = [nsf numberFromString: theSize];
                        
                        UIImage *imageFullsize = [[UIImage alloc] initWithData:theData];
                        
                        UIImage *imageScaled = [imageFullsize thumbnailImage:[nn intValue] transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
                        
                        NSData *scaledData = nil;
                        if ([self saveImageContentAsPNG]) {
                            scaledData = UIImagePNGRepresentation(imageScaled);
                        } else {
                            scaledData = UIImageJPEGRepresentation(imageScaled, 1);
                        }
                        
                        NSURL *path = [self getFilePathForObjectImage:objId size:theSize];
                        
                        if( [scaledData writeToURL:path atomically:NO] ) {
                            NSLog(@"Successfully wrote thumb %@", path);
                        }
                    }
                }
            }
            Boolean bFailed = NO;
            __block RCOObject* obj = nil;
            [[self moc] performBlockAndWait:^{
                
                obj = [self getObjectWithId:objId];
                if( obj != nil ) {
                    obj.rcoFileType = [responseDict objectForKey:@"fileName"];
                }

            }];
            
            
            if( bFailed)
            {
                NSRange aRange = [response rangeOfString:@"No EFile version found"];
                if( aRange.location == NSNotFound ) {
                    aRange = [response rangeOfString:@"java.io.FileNotFoundException"];
                }
                NSString *comment = (aRange.location != NSNotFound) ? [response substringWithRange:aRange] : response;
                
                NSURL *path=[self getFilePathForObjectImage:objId size:pels];
                [self.contentThatFailedToDownload addObject:path];
                
                if(aRange.location!=NSNotFound) {
                    [[self moc] performBlockAndWait:^{
                        [obj setHasNoContent];
                        [obj setContentNeedsDownloading:false];
                        [obj setContentIsDownloading:false];
                    }];
                }
                
                // ??? set fileLog if we are setting the object as having no content?
                [[self moc] performBlockAndWait:^{
                    obj.fileLog = comment;
                }];
            }
            
            if( [pels isEqualToString:@"-1"] ) {
                [self contentRequestFinishedForObject:objId withSize:pels withSuccess:!bFailed];
            } else {
                NSLog(@"");
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setObject:objId forKey:RCOOBJECT_OBJECTID];
                [info setObject:pels forKey:RCOOBJECT_CONTENT_SIZE];
                [self dispatchToTheListeners:kContentDownloadCompleteWithInfo withMessageInfo:info];
                
                [[self moc] performBlockAndWait:^{
                    [obj setContentIsDownloading:false];
                }];
                [self save];
                [self jumpstartDataDownloadForced:objId];
            }
        }
        
    }
    else
    {
        NSString *objId =(NSString *)[msgDict objectForKey:@"objId"];
        
        // if there was an error...
        if( [msg isEqualToString: R_G_C_1])
        {
            [self requestFailed_RecordGetCoding:request];
        }
        
        else if( [msg hasPrefix: RD_G_I_PREFIX] )
        {
            Boolean bSuccess = ([response isEqualToString:@"No record found."] || 
                                [response isEqualToString:@"\"No record found.\""] || fieldValues != nil);
            
            if( bSuccess ) {
                 [self setSynchedTimeStamp:self.synchingTimeStamp];
                  if ([self.synchingTimeStamp longLongValue] == 0) {
                      // we did a full sync and there are no records, we should send the objectChanges message back, this is mainly used for full sync functionality
                    [self dispatchToTheListeners:kObjectsChangedMsg];
                }
            }
            self.syncStatus = SYNC_STATUS_REQUEST_COMPLETE;
            [self dispatchToTheListeners:kObjectSyncRequestCompletedMsg 
                                withArg1:[NSNumber numberWithUnsignedInteger:[self countObjectsToSync] ]
                                withArg2:nil];            
        }
        
        else if( [msg isEqualToString: R_G_C])
        {
            if (responseStatusCode != 200) {
                // response is nil, we should parse it as request failed
                [self requestFailed_Bkgd:request];
                return;
            }
            
            NSDictionary *responseDict = [msgDict objectForKey:RESPONSEDICT_KEY];
            
            if( response == nil ) {
                response = [responseDict objectForKey:@"response"];
            }
            
            NSString *params = (NSString *)[msgDict objectForKey:@"params"];
            
            NSArray *comp = [params componentsSeparatedByString: @"/"];
            NSString *pels = [comp lastObject];
            
            // create thumb?
            if( [pels isEqualToString:@"-1"] && [self.defaultImageSizes count] > 1)
            {
                NSData *theData = [self getDataForObject:objId size:pels];
                
                for( NSString *theSize in self.defaultImageSizes )
                {
                    NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
                    [nsf setNumberStyle:NSNumberFormatterNoStyle];
                    
                    if( ![theSize isEqualToString:@"-1"] && theData != nil) {
                       
                        NSNumber *nn = [nsf numberFromString: theSize];
                        
                        UIImage *imageFullsize = [[UIImage alloc] initWithData:theData];
                        
                        UIImage *imageScaled = [imageFullsize thumbnailImage:[nn intValue] transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
                        
                        NSData *scaledData = nil;
                        if ([self saveImageContentAsPNG]) {
                            scaledData = UIImagePNGRepresentation(imageScaled);
                        } else {
                            //compression is 0(most)..1(least)
                            // the image was already compressed ....
                            scaledData = UIImageJPEGRepresentation(imageScaled, 1);
                        }
                        
                        NSURL *path = [self getFilePathForObjectImage:objId size:theSize];
                        
                        if( [scaledData writeToURL:path atomically:NO] ) {
                        }
                    }
                }
            }
            Boolean bFailed = [response length] > 0;

            RCOObject* obj = [self getObjectWithId:objId];
            
            if( obj != nil ) {
                obj.rcoFileType = [responseDict objectForKey:@"fileName"];
            }

            if( bFailed) {
                
                NSRange aRange = [response rangeOfString:@"No EFile version found"];
                if( aRange.location == NSNotFound ) {
                    aRange = [response rangeOfString:@"java.io.FileNotFoundException"];
                }
                NSString *comment = (aRange.location != NSNotFound) ? [response substringWithRange:aRange] : response;
                
                NSURL *path=[self getFilePathForObjectImage:objId size:pels];
                [self.contentThatFailedToDownload addObject:path];

                if(aRange.location!=NSNotFound) {
                    [obj setHasNoContent];
                    [obj setContentNeedsDownloading:false];
                    [obj setContentIsDownloading:false];
               }
                
                // ??? set fileLog if we are setting the object as having no content?
                obj.fileLog = comment;
            }

            if( [pels isEqualToString:@"-1"] ) {
                [self contentRequestFinishedForObject:objId withSize:pels withSuccess:!bFailed];
            } else {
                NSLog(@"");
            }
        }
    }
}

- (void) requestFinished_RecordGetIds: (NSArray *) fieldValues
{
    @autoreleasepool {
        [self save];

        [[self moc] performBlockAndWait:^{
            [[[self moc] undoManager] disableUndoRegistration];
        }];

        // dont bother with the fancy logic if we have nothing in the db
        self.approximateCount = [self countObjects:nil];
        NSUInteger existingCount = self.approximateCount;
        
        NSUInteger checkedCount = 0;
        NSUInteger checkGranularity = 100;
        
        NSUInteger updatedCount = 0;
        long long lastUpdateTime = [self.synchedTimeStamp longLongValue];
        long long maxUpdateTime = 0;
        NSNumberFormatter *nsf = [[NSNumberFormatter alloc] init];
        [nsf setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSUInteger granularity = 1;
        BOOL bShowNetworkIndicator = [fieldValues count] > 200;
        if( bShowNetworkIndicator ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startNetworkActivityIndicator" object:nil];

            if([fieldValues count] > 500 )
                granularity = 25;
            else if([fieldValues count] > 500 )
                granularity = 10;
            else
                granularity = 5;
        }
        NSMutableDictionary *objectsDict = [NSMutableDictionary dictionary];
        __block  NSArray *arrayOfObjDicts = nil;
        
        if( existingCount ) {
            NSMutableArray *objectids = [NSMutableArray array];
            for (NSDictionary *dict in fieldValues)
            {
                id objectId = [dict objectForKey:@"objectId"];
                
                if (!objectId) {
                    objectId = [dict objectForKey:@"LobjectId"];
                }
                
                NSString *objId = [NSString stringWithFormat:@"%@",objectId];
                if( objId ) {
                    [objectids addObject:objId];
                }
            }
            
            [[self moc] performBlockAndWait:^{

                NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:[self moc]];
                [request setEntity:entityDescription];
                [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
            
                NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K IN %@ )", @"rcoObjectId", objectids];
                [request setPredicate:predicate];
            
                [request setIncludesSubentities:NO];
                [request setResultType:NSDictionaryResultType];
            
                request.propertiesToFetch = [NSArray arrayWithObjects: @"rcoObjectId", @"rcoObjectTimestamp", @"rcoFileTimestamp", nil];
            
                NSError *error = nil;
                arrayOfObjDicts = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
            }];
            
            for (NSDictionary *dict in arrayOfObjDicts) {
                [objectsDict setObject:dict forKey:[dict objectForKey:@"rcoObjectId"]];
            }
        }
        
        NSArray *deletedIds = [self getAllIdsForEntity:kDeletedEntity];
        
        for (NSDictionary *dict in fieldValues)
         {
             NSString *objType = [dict objectForKey:@"objectType"];
             id objectId = [dict objectForKey:@"objectId"];
             if (!objectId) {
                 objectId = [dict objectForKey:@"LobjectId"];

             }
             NSString *objId = [NSString stringWithFormat:@"%@",objectId];
             
             if( [deletedIds containsObject:objId] ) {
                 continue;
             }
             
             NSDictionary *objDict = [objectsDict objectForKey:objId];
             
             if( objDict && self.frontLoadImages) {
                 NSString *fs =   [NSString stringWithFormat:@"%@",[dict objectForKey:@"contentTimeStamp"]];
                 if( fs != nil)
                 {
                     NSNumber* fsFromServer = [NSNumber numberWithLongLong:[[nsf numberFromString: fs] longLongValue]];
                     long long newFileTime = [fsFromServer longLongValue];
                     
                     
                     if( newFileTime ) {
                         NSNumber *fsFromObject =[objDict objectForKey: @"rcoFileTimestamp"];
                     }
                 }
             }
             
             NSString *ts = [NSString stringWithFormat:@"%@",[dict objectForKey:@"codingTimeStamp"]];
             if( objDict ) {
                 if( ++checkedCount % checkGranularity == 0 ) {
                 }
                 
                 if( ts != nil)
                 {
                     NSNumber* tsFromServer = [NSNumber numberWithLongLong:[[nsf numberFromString: ts] longLongValue]];
                     long long newTime = [tsFromServer longLongValue];
                     if( newTime ) {
                         if( newTime <= lastUpdateTime  ) {
                             continue;
                         }
                         
                         NSNumber *tsFromObject =[objDict objectForKey: @"rcoObjectTimestamp"];
                         
                         if (newTime <= [tsFromObject longLongValue])
                         {
                             maxUpdateTime = MAX(maxUpdateTime, [tsFromObject longLongValue]);
                             
                             continue;
                         }
                     }
                 }
             }            
                     
            [self.objectsToDownload addObject:[NSString stringWithFormat:@"%@/%@",objId, objType]];
             
             if( ts == nil ) ts = @"";
             [self.recordsAwaitingDownload setObject: ts forKey:[NSString stringWithFormat:@"%@/%@",objId, objType]];
             
             updatedCount++;
             if( updatedCount % granularity == 0 ) {
                 [self dispatchToTheListeners:kObjectSyncRequestStartedMsg
                                     withArg1:[NSNumber numberWithUnsignedInteger:updatedCount ]
                                     withArg2:nil];
             }
             
             if( [[NSThread currentThread] isCancelled]) {
                 break;
             }
         }
        
        [self subtractSync];
        
        if( updatedCount == 0 && maxUpdateTime > [self.synchingTimeStamp longLongValue]) {
            self.synchingTimeStamp = [NSNumber numberWithLongLong:maxUpdateTime];
        }
        
        updatedCount = [self countObjectsToSync];
        NSUInteger newUpdatedCount = [self.recordsAwaitingDownload count];
        
        [self setSynchedTimeStamp:self.synchingTimeStamp];
        
        [self save];
        [[self moc] performBlockAndWait:^{
            [[[self moc] undoManager] enableUndoRegistration];
        }];

        if( bShowNetworkIndicator ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopNetworkActivityIndicator" object:nil];
        }
        
        self.syncStatus = SYNC_STATUS_REQUEST_COMPLETE;
        [self dispatchToTheListeners:kObjectSyncRequestCompletedMsg 
                            withArg1:[NSNumber numberWithUnsignedInteger:newUpdatedCount]
                            withArg2:nil];
     
    }
}

- (void) requestFinished_RecordGetIds_1: (NSArray *) fieldValues
{
    for (NSDictionary *itemDict in fieldValues) {
        
        NSNumber * objectIdDetail = [itemDict objectForKey:@"LobjectId"];
        NSString *objectTypeDetail = [itemDict objectForKey:@"objectType"];
        
        NSArray *arCodingInfoDetail = [itemDict objectForKey:@"arCodingInfo"];
        NSDictionary *mapCodingInfo = [itemDict objectForKey:@"mapCodingInfo"];
        NSString *mobileRecordId = [itemDict objectForKey:@"mobileRecordId"];
        
        NSArray *classItems = [mobileRecordId componentsSeparatedByString:@"-"];
        
        NSString *objectClass = nil;
        
        if (classItems.count) {
            objectClass = [classItems objectAtIndex:0];
        }
        
        RCOObject *detail = nil;
        
        if ([mobileRecordId length] > 0) {
            
            NSArray *objects = [self getObjectsWithMobileRecordId:mobileRecordId];
            
            if ([objects count] > 0) {
                detail = [objects objectAtIndex:0];
            }
        } else {
            detail = [self getObjectWithId:[objectIdDetail stringValue]];
        }
        
        if (!detail) {
            detail = [self createNewObject];
        }
        
        detail.rcoObjectSearchString = nil;
        
        if ([arCodingInfoDetail count]) {

        } else {
            NSArray *codingFields = [mapCodingInfo allKeys];
            
            for (NSString *codingField in codingFields) {
                NSString *value = [mapCodingInfo objectForKey:codingField];
                [self syncObject:detail withFieldName:codingField toFieldValue:value];
            }
        }
        
        detail.rcoObjectId = [NSString stringWithFormat:@"%@", objectIdDetail];
        detail.rcoObjectType = objectTypeDetail;
        [detail setNeedsUploading:NO];
        [self updateCodingFieldsForObject:detail];
    }
    
    [self save];
}

- (void) requestFinished_RecordGetRecordsNew: (NSArray *) fieldValues syncDone:(BOOL)syncDone {
    return [self requestFinished_RecordGetRecordsNew:fieldValues
                                            syncDone:syncDone
                                            fullSync:NO];
}

- (void) requestFinished_RecordGetRecordsNew: (NSArray *) fieldValues syncDone:(BOOL)syncDone fullSync:(BOOL)initialSync {
    
    NSUInteger cnt = 0;
    cnt = [self countObjectsToSync];
    self.syncStatus = SYNC_STATUS_CODING;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"startNetworkActivityIndicator" object:nil];
    
    [self save];
    [[self moc] performBlockAndWait:^{
        [[[self moc] undoManager] disableUndoRegistration];
    }];
    
    unsigned long reportFrequency = [fieldValues count] / 100;
    if (reportFrequency < 1 )
        reportFrequency = 1;
    
    [self.recordsAwaitingDownload setObject: @"" forKey:@"Nothing could possibly have this key"];
    
    NSInteger idx = 0;
    
    for (NSInteger i = 0; i < fieldValues.count; i++) {
        
        NSDictionary *dict = [fieldValues objectAtIndex:i];
        
        NSString *objType = [dict objectForKey:@"objectType"];
        
        NSString *objId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"LobjectId"]];
        
        BOOL forceInsert = initialSync;
        
        NSArray *arCodingInfo = [dict objectForKey:@"arCodingInfo"];
        NSMutableDictionary *mapCodingInfo = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"mapCodingInfo"]];
        
        NSString *newTimestamp = [mapCodingInfo objectForKey:@"RMS Coding Timestamp"];
        
        BOOL isSameTimestamp = [self isTheSameTimestamp:newTimestamp];
        
        
        if (initialSync && isSameTimestamp) {
            forceInsert = NO;
            [mapCodingInfo setObject:[NSNumber numberWithBool:YES] forKey:SearchItemKey];
        }
        
        self.synchedObjectType = objType;
        self.synchedObjectId = objId;
        
        [self requestFinished_RecordGetCoding: objId
                                     withType: objType
                               andValuesArray: arCodingInfo
                           orValuesDictionary: mapCodingInfo
                           downloadNextObject: false
                                  forceInsert: forceInsert];
        if( [[NSThread currentThread] isCancelled]) {
            break;
        }
    }
    
    self.recordsAwaitingDownload = [[NSMutableDictionary alloc] init];
    
    [self subtractSync];
    [self setSynchedTimeStamp:self.synchingTimeStamp];
    [self save];
    [[self moc] performBlockAndWait:^{
        [[[self moc] undoManager] enableUndoRegistration];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopNetworkActivityIndicator" object:nil];
}

-(BOOL)isTheSameTimestamp:(NSString*)timestamp {
    long long syncTimestamp = [self.synchingTimeStamp longLongValue];
    long long newTimestamp = [timestamp longLongValue];
    if (syncTimestamp == newTimestamp) {
        return YES;
    } else {
        return NO;
    }
}

- (void) requestFinished_RecordGetRecords: (NSArray *) fieldValues
{
    // just ball park the count here
    NSUInteger cnt = 0;
    cnt = [self countObjectsToSync];
    
    self.syncStatus = SYNC_STATUS_REQUEST_COMPLETE;

    [self dispatchToTheListeners:kObjectSyncRequestCompletedMsg
                        withArg1:[NSNumber numberWithUnsignedInteger:cnt + [fieldValues count] ]
                        withArg2:nil];
    
    self.syncStatus = SYNC_STATUS_CODING;
    [self dispatchToTheListeners:kObjectSyncStartedMsg
                        withArg1:[NSNumber numberWithUnsignedInteger:cnt + [fieldValues count] ]
                        withArg2:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startNetworkActivityIndicator" object:nil];
    
    [self save];
    [[[self moc] undoManager] disableUndoRegistration];

    int idx = 0;
    unsigned long reportFrequency = [fieldValues count] / 100;
    if (reportFrequency < 1 )
        reportFrequency = 1;
    
    [self.recordsAwaitingDownload setObject: @"" forKey:@"Nothing could possibly have this key"];
    
    for (NSDictionary *dict in fieldValues)
    {
        NSString *objType = [dict objectForKey:@"objectType"];
        NSString *objId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"LobjectId"]];
        
        [self requestFinished_RecordGetCoding:objId
                                     withType: objType
                               andValuesArray: [dict objectForKey:@"arCodingInfo"]
                           orValuesDictionary:[dict objectForKey:@"mapCodingInfo"]
                              downloadNextObject: false];
        
        if( ++idx % NumberOfRecordsToSaveOnce == 0 ) {
            [self save];
        }
        if( [[NSThread currentThread] isCancelled]) {
            break;
        }
    }
    
    self.recordsAwaitingDownload = [[NSMutableDictionary alloc] init];
    
    [self subtractSync];
    [self setSynchedTimeStamp:self.synchingTimeStamp];
    [self save];
    [[[self moc] undoManager] enableUndoRegistration];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopNetworkActivityIndicator" object:nil];
    
    [self checkForSyncDoneWithSuccess:true];
}

- (void) requestFinished_RecordGetCoding: (NSString *) objId
                                withType: (NSString *) objType
                          andValuesArray: (NSArray *)fieldValuesArray
                      orValuesDictionary: (NSDictionary *)fieldValuesDictionary
                      downloadNextObject: (Boolean) doDownloadNextObject{
    return [self requestFinished_RecordGetCoding:objId
                                        withType:objType
                                  andValuesArray:fieldValuesArray
                              orValuesDictionary:fieldValuesDictionary
                              downloadNextObject:doDownloadNextObject
                                     forceInsert:NO];
}


- (void) requestFinished_RecordGetCoding: (NSString *) objId
                                withType: (NSString *) objType
                          andValuesArray: (NSArray *)fieldValuesArray
                      orValuesDictionary: (NSDictionary *)fieldValuesDictionary
                      downloadNextObject: (Boolean) doDownloadNextObject
                             forceInsert: (BOOL)forceInsert

{
    @autoreleasepool {
    
        if( fieldValuesDictionary == nil ) {
            fieldValuesDictionary = [self fieldValuesDictionaryFromArray:fieldValuesArray];
        }
        
        [[self moc] performBlockAndWait:^{
            [self syncObjectWithId: objId
                           andType: objType
                toValuesDictionary:fieldValuesDictionary
                       forceInsert:forceInsert];
        }];
        
        
        [self.recordsAwaitingDownload removeObjectForKey:[NSString stringWithFormat:@"%@/%@", objId, objType]];
        
        if( [self.recordsAwaitingDownload count] == 0 || [self.recordsAwaitingDownload count] % NumberOfRecordsToSaveOnce == 0 ) {
            [self save];
        }
        if( self.syncStatus == SYNC_STATUS_CODING )
        {
            [self requestIdsForDetailsOfObject:objId andType:objType];
            if(doDownloadNextObject /*&& ![ASIHTTPRequest isNetworkQueueMaxed]*/) {
                [self downloadNextObject];
            }
            if (doDownloadNextObject)
                [self checkForSyncDoneWithSuccess:true];
        }
    }
}

- (void) requestFinished_RecordSetCoding: (RCOObject *) obj withMsg:(NSString *) msg andResponse:(NSString *) response skipGetRecordCoding:(BOOL)skipGetRecordCoding
{
    NSLog(@"                %@: %@",msg, response);
    
    [obj setIsUploading:false];
    
    [self save];
    [self subtractSync];
    
    Boolean bSuccess = true;
    NSRange aRange = [response rangeOfString:@"error"];
    
    if( [response length] > 0 && aRange.location != NSNotFound )
    {
        obj.objectLog = response;
        
        [self dispatchToTheListeners:kObjectUploadFailed withObjectId:obj.rcoObjectId];
        bSuccess = false;
    }
    else
    {
        [obj setNeedsUploading:false];
        
        if (!skipGetRecordCoding) {
        } else {
            // we should do an update of the object, and skip the coding fields that should not be udated when we skipGetRecordCoding fields
            NSArray *responseJSONArray = [self arrayFromJSONResponse:response];
            if ([responseJSONArray count]) {
                NSDictionary *itemDict = [responseJSONArray objectAtIndex:0];
                BOOL isAnyChanged = [[itemDict objectForKey:@"isAnyChanged"] boolValue];
                if (isAnyChanged) {
                    // we should get mapCodingFields
                    NSDictionary *mapCodingInfoFields = [itemDict objectForKey:kMapCodingInfoKey];
                    NSString *objectType = [itemDict objectForKey:@"objectType"];
                    NSString *objId = [NSString stringWithFormat:@"%@", [itemDict objectForKey:@"LobjectId"]];
                    
                    if (mapCodingInfoFields) {
                        NSMutableDictionary *mapCodingInfoFieldsNew = [NSMutableDictionary dictionaryWithDictionary:mapCodingInfoFields];
                        for (NSString *codingFieldToSkip in self.codingFieldsToSkipWhenUpdating) {
                            [mapCodingInfoFieldsNew removeObjectForKey:codingFieldToSkip];
                        }
                        [self syncObjectWithId:objId andType:objectType toValuesDictionary:mapCodingInfoFieldsNew];
                        [self save];
                        NSLog(@"");
                    }
                }
            }
        }

        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:obj.rcoObjectId];
    }
    
    [self checkForSyncDoneWithSuccess:bSuccess];
}

-(void)reloadObjectFromRMS:(NSString*)objectBarcode {
    
}

-(void)reloadObjectDetailsFromRMS:(NSString*)objectBarcode {
}

- (void) requestFinished_RecordSetCoding: (RCOObject *) obj withMsg:(NSString *) msg andResponse:(NSString *) response
{
    [self requestFinished_RecordSetCoding:obj withMsg:msg andResponse:response skipGetRecordCoding:NO];
}


#pragma mark - Download progress

- (void)request:(id )request didReceivedBytes:(NSDictionary*)bytesInfo {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    SEL msg = @selector(bytesAvailable:forObject:);
    SEL msg2 = @selector(bytesInfoAvailable:forObjectId:);
    
    NSString *objId = (NSString *)[msgDict objectForKey:@"objId"];
    
    RCOObject *obj = nil;
    
    for( id listener in self.listeners )
    {
        if ([listener respondsToSelector:msg2]) {
            [listener performSelector:msg2 withObject:bytesInfo withObject:objId];
        } else if( [listener respondsToSelector:msg] ) {
            
            if (!obj) {
                return;
            }
            
            [listener performSelector:msg withObject:[bytesInfo objectForKey:BytesRead] withObject:obj];
        }
    }
}

- (void)request:(id )request didReceiveBytes:(long long)bytes {
     
     NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];

     SEL msg = @selector(bytesAvailable:forObject:);
     SEL msg2 = @selector(bytesInfoAvailable:forObjectId:);
     
     NSString *objId = (NSString *)[msgDict objectForKey:@"objId"];
     
     RCOObject *obj = nil;
     
     for( id listener in self.listeners )
     {
         if ([listener respondsToSelector:msg2]) {
             [listener performSelector:msg2 withObject:[NSNumber numberWithLongLong:bytes] withObject:objId];
         } else if( [listener respondsToSelector:msg] ) {
             
             if (!obj) {
                 return;
             }

             [listener performSelector:msg withObject:[NSNumber numberWithLongLong:bytes] withObject:obj];
         }
     }
 }
 
 - (void)request:(id )request incrementDownloadSizeBy:(long long)newLength {
     
     NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];

     NSString *objId =(NSString *)[msgDict objectForKey:@"objId"];
     
     RCOObject *obj = [self getObjectWithId:objId];
     obj.rcoFileSize = [NSNumber numberWithLongLong:newLength];
     [self save];
 }
 
 - (void)request:(id )request didSendBytes:(long long)bytes {
 
 }
 
 - (void)request:(id )request incrementUploadSizeBy:(long long)newLength {
 }
 

#pragma mark -
#pragma mark data from local

- (RCOObject *) createNewObject
{
    NSString *deviceId = [[DataRepository sharedInstance] deviceId];

    if (deviceId.length == 0) {
        deviceId = @"NoDeviceId";
    }
    
    NSString *username = [DataRepository sharedInstance].userName;
    username = [username stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    BOOL isOffline = [[DataRepository sharedInstance] workOffline];
    
    NSString *offline = @"ON";
    
    DataRepository *dr = [DataRepository sharedInstance];
    
    if (![dr isNetworkReachable]) {
        offline = @"X";
    } else if (isOffline) {
        offline = @"O";
    }
    
    __block RCOObject* obj = nil;
    [[self moc] performBlockAndWait:^{
        obj = (RCOObject*)[NSEntityDescription insertNewObjectForEntityForName:self.localObjectClass
                                                                   inManagedObjectContext:[self moc]];
        
        NSString *localObjectId = [NSString stringWithFormat:@"%@-%@-%@-%@-%f", self.rcoObjectClass, deviceId, username, offline, [[NSDate date] timeIntervalSince1970]];
        obj.rcoObjectId = localObjectId;
        obj.rcoMobileRecordId = localObjectId;
        obj.rcoObjectClass = self.rcoObjectClass;

    }];
    
    return obj;
}

- (RCOObject *) createObjectWithId: (NSString *) objId andType: (NSString *)objType;
{
    if( objId == nil ) {
        return nil;
    }
    __block RCOObject* obj = nil;
    
    [[self moc] performBlockAndWait:^{
        obj = [self createNewObject];
        obj.rcoObjectId=objId;
        obj.rcoObjectType=objType;
        
        obj.rcoObjectTimestamp = [NSNumber numberWithLongLong:kUninitializedRecordTimestamp];
    }];
    
    return obj;
}

-(NSArray*)getRecordsToDelete {
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{

        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@ )", @"rcoObjectClass", self.rcoObjectClass];
    
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kDeletedEntity inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
    
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
    
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS];
    }];
    
    return array;
}

-(void) destroyObj: (RCOObject *) obj
{
    if (!obj) {
        return;
    }
    
    [self destroyDetailsForObject:obj];

    if ([obj existsOnServer]) {
        RCOObject* deletedObj = (RCOObject*)[NSEntityDescription
                                      insertNewObjectForEntityForName:kDeletedEntity
                                      inManagedObjectContext:[self moc]];
        
        deletedObj.rcoObjectId      = obj.rcoObjectId;
        deletedObj.rcoMobileRecordId = obj.rcoMobileRecordId;
        deletedObj.rcoObjectClass   = obj.rcoObjectClass;
        deletedObj.rcoObjectType    = obj.rcoObjectType;
        
        [self destroyRecord:obj];
    }
    
    [self deleteLocalContentForObject:obj.rcoObjectId];
    [self deleteLocalContentForObject:obj.rcoMobileRecordId];
    
    [[self moc] deleteObject:obj];
    
    [self save];
}

-(void)destroyDetailsForObject:(RCOObject*)obj {
    
    if (!obj) {
        return;
    }

    NSString *objClassName = [[obj entity] name];
    
    Aggregate *objAgg = [[DataRepository sharedInstance] getAggregateForClass:objClassName];
    for (Aggregate *detailAgg in objAgg.detailAggregates) {
        NSArray *details = nil;
        if ([obj.rcoBarcode length]) {
            details = [detailAgg getObjectsWithMasterBarcode:obj.rcoBarcode];
        } else {
            details = [detailAgg getObjectsWithParentId:obj.rcoObjectId];
        }
        
        for (RCOObject *detailObj in details) {
            [detailAgg destroyObj:detailObj];
        }
    }
}

-(void)destroyObjectJustFromLocalDB:(RCOObject*)obj {
    if (!obj) {
        return;
    }
    
    for (Aggregate *detailAgg in self.detailAggregates) {
        NSArray *details = nil;
        if ([obj.rcoBarcode length]) {
            details = [detailAgg getObjectsWithMasterBarcode:obj.rcoBarcode];
        } else {
            details = [detailAgg getObjectsWithParentId:obj.rcoObjectId];
        }
        
        for (RCOObject *detailObj in details) {
            [detailAgg destroyObjectJustFromLocalDB:detailObj];
        }
        
        [detailAgg save];
    }
    
    [[self moc] deleteObject:obj];
    [self save];
}

- (NSArray *) getAll
{
    return [self getAllSortedBy:nil];
}

- (NSArray *) getAllRecords
{
    return [self getAllNarrowedBy: @"itemType" withValue: [self.rcoRecordType lowercaseString] sortedBy: nil];
}

- (void)clearAllLocally {
    NSArray *allItems = [self getAll];
    for (RCOObject *obj in allItems) {
        [self destroyObjectJustFromLocalDB:obj];
    }
    [self save];
}

// return just an array of ids
-(NSArray*) getAllIds {
    return [self getAllIdsForEntity:localObjectClass];
}

// return just an array of ids
-(NSArray*) getAllIdsForEntity: (NSString *) entity {
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
    
        [request setIncludesSubentities:NO];
        [request setResultType:NSDictionaryResultType];
    
        request.propertiesToFetch = [NSArray arrayWithObject:[[entityDescription propertiesByName] objectForKey:@"rcoObjectId"]];
    
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    NSMutableArray *builtArray = [NSMutableArray array];
    for (NSDictionary *dict in array ) {
        NSString *rcoObjectId = [dict objectForKey:@"rcoObjectId"];
        if( rcoObjectId ) {
            [builtArray addObject:rcoObjectId];
        }
    }
    
    return builtArray;
}


- (NSArray *) getAllSortedBy: (NSArray *) sortKeys {

    
    NSMutableArray *sortDescriptors=nil;
    if( sortKeys != nil ) {
        sortDescriptors = [NSMutableArray array];

        NSString *sortkey;
        NSEnumerator *e = [sortKeys objectEnumerator];
        while( (sortkey = [e nextObject]) != nil ) {
            
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:sortkey ascending:YES];
            [sortDescriptors addObject: sd];
        }
	}
 
    return [self getAllNarrowedBy:nil andSortedBy:sortDescriptors];
}

- (NSArray *) getAllNarrowedBy: (NSString *) keyName withValue: (NSString *) keyValue sortedBy:(NSArray*) sortKeys {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@ )", keyName, keyValue];
     
    // set up the sortkeys
    NSMutableArray *sortDescriptors = nil;
    
    if( sortKeys != nil ) {
        sortDescriptors = [NSMutableArray array];

        NSString *sortkey;
        NSEnumerator *e = [sortKeys objectEnumerator];
        while( (sortkey = [e nextObject]) != nil )
        {   
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:sortkey ascending:YES];
            [sortDescriptors addObject: sd];
        }
        
 	}
    return [self getAllNarrowedBy:predicate andSortedBy:sortDescriptors];
    
}

- (NSArray *) getAllNarrowedBy: (NSPredicate *) pred andSortedBy:(NSArray*) sorters {
    
    return [self getSomeNarrowedBy:pred sortedBy:sorters limitedTo:0];
}

- (NSPredicate *) subsetPredicate {
    return nil;
}

- (NSArray *) getSomeNarrowedBy: (NSPredicate *) pred sortedBy:(NSArray*) sorters limitedTo: (NSInteger) maxToReturn {
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
        [request setIncludesSubentities:NO];
	    
        NSPredicate *finalPredicate = nil;
        NSPredicate *excluded = [self subsetPredicate];
    
        if( excluded == nil ) {
            finalPredicate = pred;
        } else if( pred != nil ) {
        
            NSArray *subPredicates = [NSArray arrayWithObjects:pred, excluded, nil];
        
            finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        } else {
            finalPredicate = excluded;
        }
        
        if( finalPredicate ) {
            [request setPredicate:finalPredicate];
        }
        if( sorters != nil ) {
            [request setSortDescriptors:sorters];
        }
    
        if( maxToReturn ) {
            [request setFetchLimit:maxToReturn];
        }

        NSError *error = nil;
        
        array = [[self moc] executeFetchRequest:request error:&error  DATABASE_ACCESS_TIMING_ARGS ];
        
    }];
	
    return array;
}

- (NSArray *) getSomeNarrowedBy: (NSPredicate *) pred sortedBy:(NSArray*) sorters limitedTo: (NSInteger) maxToReturn offset:(NSInteger)offset
{
    __block NSArray *array = nil;
    [[self moc] performBlockAndWait:^{

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:[self moc]];
    
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
    
        [request setIncludesSubentities:NO];
    
        NSPredicate *finalPredicate = nil;
        NSPredicate *excluded = [self subsetPredicate];
    
        if( excluded == nil ) {
            finalPredicate = pred;
        }
        else if( pred != nil ) {
        
            NSArray *subPredicates = [NSArray arrayWithObjects:pred, excluded, nil];
        
            finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        }
        else {
            finalPredicate = excluded;
        }
        if( finalPredicate ) {
            [request setPredicate:finalPredicate];
        }
        if( sorters != nil ) {
            [request setSortDescriptors:sorters];
        }
    
        if (offset >= 0) {
            [request setFetchOffset:offset];
        }
    
        [request setResultType:NSDictionaryResultType];
    
        if( maxToReturn ) {
            [request setFetchLimit:maxToReturn];
        }
    
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    return array;
}

- (NSUInteger) countObjectsToSync
{
    return [self.objectsToUpload count] + [self.objectsToDownload count];
}

- (NSUInteger) countFilesToSync
{
    if (self.skipSyncRecords) {
        return 0;
    }
    
    NSPredicate * pred = [NSPredicate predicateWithFormat:
                          @"((fileNeedsUploading == YES) AND (fileIsUploading == NO OR fileIsUploading == nil))  " ];
    if ([self.rcoRecordType isEqualToString:@"Field"]) {
        NSLog(@"");
    }
               
    return [self countObjects: pred];
}

- (NSUInteger) countObjects: (NSPredicate *) pred
{
    __block NSUInteger count = 0;
    
    [[self moc] performBlockAndWait:^{

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
    
        [request setIncludesSubentities:NO];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
	
        NSPredicate *finalPredicate = nil;
        NSPredicate *excluded = [self subsetPredicate];
    
        if( excluded == nil ) {
            finalPredicate = pred;
        }
        else if( pred != nil ) {
        
            NSArray *subPredicates = [NSArray arrayWithObjects:pred, excluded, nil];
        
            finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        }
        else {
            finalPredicate = excluded;
        }
        if( finalPredicate ) {
            [request setPredicate:finalPredicate];
        }
    
        NSError *error = nil;
        count = [[self moc] countForFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS];
        if (error) {
        }
    }];
	
    return count;
}

- (NSArray *) getAllForSearchTerm: (NSString *) searchTerm withSearchKeys: (NSArray *) searchKeys andSortKeys: (NSArray *) sortKeys {
    
    NSString *searchString = @"";
    for (NSString *sk in searchKeys)
    {
        if( [searchString length] > 1 )
        {
            searchString = [NSString stringWithFormat: @" OR %@", searchString];
        }
        searchString = [NSString stringWithFormat: @"%@ (%@ contains[cd] \"%@\")", searchString, sk, searchTerm];        
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:searchString];
    
    NSMutableArray *sortDescriptors = nil;
	if( sortKeys != nil ) {
        sortDescriptors = [NSMutableArray array];

        for( NSString *sortKey in sortKeys )
        {   
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES];
            [sortDescriptors addObject: sd];
        }
        
 	}
    
	
    NSArray *array= [self getAllNarrowedBy: predicate andSortedBy: sortDescriptors];
    return array;
}

- (RCOObject *) getObjectWithIdOLD: (NSString *) objectId
{ 
    NSArray *array = [self getAllNarrowedBy: @"rcoObjectId" withValue: objectId sortedBy:nil];
    RCOObject *theObject = nil;
    
    if( array != nil )
    {
        if( [array count] > 0 ) {
            theObject= [array objectAtIndex:0];
        }
    }
    
    return theObject;
    
}

- (BOOL)checkExistingItemBeforeInsertWhenDoingInitialSync {
    return NO;
}

- (BOOL) existObjectWithId:(NSString *) objectId {

    if ([objectId length] == 0) {
        return NO;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
    
        [request setResultType:NSDictionaryResultType];
        [request setIncludesSubentities:NO];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@ )", @"rcoObjectId", objectId];
    
        [request setPredicate:predicate];
    
        [request setFetchLimit:1];
    
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
        if (error) {
            NSLog(@"ERROR = %@", error);
        }
    }];
    
    if ([array count]) {
        return YES;
    }
    return NO;
}

- (RCOObject *) getObjectWithId: (NSString *) objectId {
    
    RCOObject *theObject = nil;
    __block NSArray *array = nil;
    
    if( [NSThread isMainThread]) {
        if (theObject) {
            return theObject;
        }   
    }
    
    if ([objectId length] == 0) {
        return nil;
    }
    
    [[self moc] performBlockAndWait:^{

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass
                                                             inManagedObjectContext:[self moc]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
    
        [request setIncludesSubentities:NO];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@ )", @"rcoObjectId", objectId];
        [request setPredicate:predicate];
    
        [request setFetchLimit:1];
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
        if (error) {
            NSLog(@"ERROR = %@", error);
        }
    }];
    
    if( array != nil ) {
        if( [array count] > 0 ) {
            theObject = [array objectAtIndex:0];
        }
    }
    
    return theObject;
}

- (RCOObject *) getObjectMobileRecordId: (NSString *) mobileRecordId {
    
    RCOObject *theObject = nil;
    
    if( [NSThread isMainThread]) {
        
        if (theObject) {
            return theObject;
        }
    }
    
    if ([mobileRecordId length] == 0) {
        return nil;
    }

    __block NSArray *array = nil;

    [[self moc] performBlockAndWait:^{
        NSError *error = nil;

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoMobileRecordId"]];
    
        [request setIncludesSubentities:NO];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@ )", @"rcoMobileRecordId", mobileRecordId];
    
        [request setPredicate:predicate];
    
        [request setFetchLimit:1];
    
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
        if (error) {
            NSLog(@"ERROR = %@", error);
        }

    }];
    
    if( array != nil ){
        if( [array count] > 0 ) {
            theObject = [array objectAtIndex:0];
        }
    }
    
    return theObject;
}

- (NSArray *) getObjectsWithIds: (NSArray *) objectIds
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K IN %@ )", @"rcoObjectId", objectIds];
    
    NSArray *array = [self getAllNarrowedBy: predicate andSortedBy:nil];
    
    return array;
}

-(NSArray*)getObjectsFromFunctionalGroupWithName:(NSString*)groupName andNumber:(NSString*)groupNumber {
    if (!groupName.length && !groupNumber.length) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        
        NSMutableArray *predicates = [NSMutableArray array];
        if (groupName.length) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"functionalGroupName=%@", groupName]];
        }
        if (groupNumber.length) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"functionalGroupObjectId=%@", groupNumber]];
        }

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[self moc]];

        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
        if (error) {
        }
    }];
    
    return array;
}

- (RCOObject *) getObjectWithIdForDelete: (NSString *) objectId {
    if ([objectId length] == 0) {
        return nil;
    }
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{

        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@ )", @"rcoObjectId", objectId];
    
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kDeletedEntity inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
    
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
    
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
        if (error) {
        }
    }];
    
    if ([array count] > 0) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray*) getObjectsWithRecordId: (NSString *) recordId
{
    if ([recordId length] == 0) {
        return nil;
    }
    
    NSArray *array = [self getAllNarrowedBy: @"rcoRecordId" withValue: recordId sortedBy:nil];
    
    return array;
}

- (RCOObject *) getObjectWithRecordId: (NSString *) recordId
{
    if ([recordId length] == 0) {
        return nil;
    }
    
    NSArray *array = [self getAllNarrowedBy: @"rcoRecordId" withValue: recordId sortedBy:nil];
    RCOObject *theObject = nil;
    
    if( array != nil )
    {
        if( [array count] > 0 ) {
            theObject= [array objectAtIndex:0];
        }
    }
    
    return theObject;
}


- (RCOObject *) getObjectWithBarcode: (NSString *) barcode
{
    if ([barcode length] == 0) {
        return nil;
    }
    
    NSArray *array = [self getAllNarrowedBy: @"rcoBarcode" withValue: barcode sortedBy:nil];
    RCOObject *theObject = nil;
    
    if( array != nil )
    {
        if( [array count] > 0 ) {
            theObject= [array objectAtIndex:0];
        }
    }
    
    return theObject;
}

- (RCOObject *) getObjectForCodingField:(NSString*)codingField andValue: (NSString *) value {
    if ([codingField length] == 0) {
        return nil;
    }

    if ([value length] == 0) {
        return nil;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@", codingField, value];
    
    NSArray *array = [self getAllNarrowedBy:predicate andSortedBy:nil];
    RCOObject *theObject = nil;
    
    if( array != nil )
    {
        if( [array count] > 0 ) {
            theObject= [array objectAtIndex:0];
        }
    }
    
    return theObject;
}


- (RCOObject *) getRCOObjectWithRecordId: (NSString *) recordId {
    
    if ([recordId length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{

        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@ )", @"rcoRecordId", recordId];
    
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BoxItem" inManagedObjectContext:[self moc]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoRecordId"]];
    
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
    
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
        if (error) {
            NSLog(@"ERROR = %@", error);
        }
    }];
    
    if ([array count] > 0) {
        [array objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray*) getObjectsWithParentId: (NSString *) parentId
{
    if ([parentId length] == 0) {
        return nil;
    }
    
    return [self getAllNarrowedBy: @"rcoObjectParentId" withValue:parentId sortedBy:[NSArray arrayWithObject:@"rcoObjectId"]];
}

- (NSArray*) getObjectsThatNeedsToUpload
{
    return [NSArray array];
    
}

- (NSArray*) getObjectsWithMobileRecordId: (NSString *) mobileRecordId
{
    if ([mobileRecordId length] == 0) {
        return nil;
    }
    return [self getAllNarrowedBy: @"rcoMobileRecordId" withValue:mobileRecordId sortedBy:nil];
}

- (RCOObject*) getObjectWithMobileRecordId: (NSString *) mobileRecordId
{
    if ([mobileRecordId length] == 0) {
        return nil;
    }
    NSArray *res = [self getAllNarrowedBy: @"rcoMobileRecordId" withValue:mobileRecordId sortedBy:nil];;
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}


- (NSArray*) getObjectsWithMasterBarcode: (NSString *) barcode {
    if ([barcode length] == 0) {
        return nil;
    }
    
    return [self getAllNarrowedBy: @"rcoBarcodeParent" withValue:barcode sortedBy:[NSArray arrayWithObject:@"rcoObjectId"]];
}

- (NSArray*) getObjectsWithBarcode: (NSString *) barcode {
    if ([barcode length] == 0) {
        return nil;
    }
    return [self getAllNarrowedBy: @"rcoBarcode" withValue:barcode sortedBy:nil];
}

- (RCOObject *) getObjectDetailWithId:  (NSString *) objectDetailId andClass:  (NSString *) objectClass
{
    if ([objectDetailId length] == 0) {
        return nil;
    }
    
    for( Aggregate *detailAggregate in self.detailAggregates )
    {
        if([objectClass isEqualToString:detailAggregate.rcoObjectClass])
        {
            return [detailAggregate getObjectWithId:objectDetailId];
        }
    }
    return nil;
}

- (NSNumber*)getNumberOfDetails:(NSString*)parentId {
    return [NSNumber numberWithLong:0];
}

-(NSNumber*)getNumberOfDetailsWithBarcode:(NSString*)parentBarcode {
    
    NSPredicate * pred = [NSPredicate predicateWithFormat:
                          @"(rcoBarcodeParent == %@)", parentBarcode];
    
    
    long nrOfItems = [self countObjects: pred];
    
    return [NSNumber numberWithLong:nrOfItems];
}

- (NSNumber*)getNumberOfRecords {
    
    NSInteger itemsCount = [self countObjects:nil];
    return [NSNumber numberWithInteger:itemsCount];
}

- (NSArray *) getRCOObjectDetails: (RCOObject*) obj
{
    if (!obj) {
        return nil;
    }
    
    NSArray * details = nil;
    
    for( Aggregate *detailAggregate in self.detailAggregates ) {
        if ([obj.rcoBarcode  length]) {
            details = [self getObjectDetailsForMasterBarcode:obj.rcoBarcode];
        } else if ([obj.rcoObjectId length]) {
            details = [detailAggregate getObjectsWithParentId:obj.rcoObjectId];
        }
    }
    return details;
}

- (NSArray *) getObjectDetails: (NSString *) objectId
{

    NSMutableArray * arr = [NSMutableArray array];
    
    if ([objectId length] == 0) {
        return arr;
    }
    
    for( Aggregate *detailAggregate in self.detailAggregates ) {
        NSArray *details = nil;
        if (objectId) {
            details = [detailAggregate getObjectsWithParentId:objectId];
        }
        if ([details count]) {
            [arr addObjectsFromArray: details];
        } else {
            // double check
            RCOObject *obj = [self getObjectWithId:objectId];
            if (obj.rcoBarcode) {
                details = [self getObjectDetailsForMasterBarcode:obj.rcoBarcode];
            }
            
            for (RCOObject *detailObj in details) {
                if ([arr containsObject:detailObj]) {
                } else {
                    [arr addObject:detailObj];
                }
            }
        }
    }
    return arr;
}

- (NSArray *) getObjectDetails: (NSString *) objectId forDetailAggregate:(Aggregate*)detailAgg
{
    
    NSMutableArray * arr = [NSMutableArray array];
    
    if ([objectId length] == 0) {
        return arr;
    }
    
    NSArray *details = nil;
    if (objectId) {
        details = [detailAgg getObjectsWithParentId:objectId];
    }
    if ([details count]) {
        [arr addObjectsFromArray: details];
    } else {
        RCOObject *obj = [self getObjectWithId:objectId];
        if (obj.rcoBarcode) {
            details = [self getObjectDetailsForMasterBarcode:obj.rcoBarcode];
        }
        
        for (RCOObject *detailObj in details) {
            if ([arr containsObject:detailObj]) {
            } else {
                [arr addObject:detailObj];
            }
        }
    }
    return arr;
}

- (NSArray *) getObjectDetailsForBarcode: (NSString *) barcode andDetailAggregate:(Aggregate*)detailAgg {
    NSMutableArray * arr = [NSMutableArray array];
    
    if ([barcode length] == 0) {
        return arr;
    }
    
    NSArray *details = nil;
    if (barcode) {
        details = [detailAgg getObjectsWithMasterBarcode:barcode];
    }
    
    if ([details count]) {
        [arr addObjectsFromArray: details];
    }
    
    return arr;
}

- (NSArray *) getObjectDetailsForMasterBarcode: (NSString *) masterBarcode
{
    if ([masterBarcode length] == 0) {
        return nil;
    }
    
    NSMutableArray * arr = [NSMutableArray array];
    
    for( Aggregate *detailAggregate in self.detailAggregates )
    {
        NSArray *details = [detailAggregate getObjectsWithMasterBarcode:masterBarcode];
        if (details) {
            [arr addObjectsFromArray: details];
        }
    }
    return arr;
}

- (NSArray *) getObjectDetailsForObjectId: (NSString *) objectId
{
    if ([objectId length] == 0) {
        return nil;
    }
    
    NSMutableArray * arr = [NSMutableArray array];
    
    for( Aggregate *detailAggregate in self.detailAggregates )
    {
        NSArray *details = [detailAggregate getObjectsWithParentId:objectId];
        if (details) {
            [arr addObjectsFromArray: details];
        }
    }
    return arr;
}


- (void) removeDeletedObjects:(NSArray *)currentIds
{
    NSArray *objects = [[NSArray alloc] initWithArray: [self getAll]];
    
    [self removeObjectsNotInList:currentIds fromGroup:objects];
    
}

- (void) removeObjectsNotInList:(NSArray *)currentIds fromGroup: (NSArray *) validObjects
{
    NSMutableArray *objects = [[NSMutableArray alloc] initWithArray: validObjects];

    [[self moc] performBlockAndWait:^{

    for (NSDictionary *dict in currentIds) {
        NSString *objId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"objectId"]];
        NSString *objType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"objectType"]];
        for ( RCOObject *obj in objects )
        {
            __block BOOL shouldBreak = NO;
                if( [objId isEqualToString:obj.rcoObjectId] && [objType isEqualToString:obj.rcoObjectType])
                {
                    [objects removeObject:obj];
                    shouldBreak = YES;;
                }
            if (shouldBreak) {
                break;
            }
        }
    }
    }];
    
    [[self moc] performBlockAndWait:^{
        for( RCOObject *deletingObj in objects )
        {
            if( [deletingObj existsOnServer] && [deletingObj needsUploadingIncludingDetails] && currentIds != nil)
            {
                [self warnUserEditedObjectDeleted: deletingObj];
            }
            if( [deletingObj existsOnServer] || [deletingObj needsDeleting] || currentIds == nil)
            {
                NSArray *details = [self getObjectDetails: deletingObj.rcoObjectId];
                for( RCOObject *detail in details )
                    [[self moc] deleteObject:detail];
                
                NSLog (@"\n\nDeleting %@ %@\n\n", self.rcoObjectClass, deletingObj.rcoObjectId);
                [[self moc] deleteObject:deletingObj];
            }
        }
    }];
    
    [self save];
    
    [self dispatchToTheListeners:kObjectsChangedMsg];

}

-(NSArray*)getObjectIdSortDescriptor:(BOOL)acending {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rcoObjectId"
                                                                     ascending:acending
                                                                    comparator:^(id obj1, id obj2) { return [obj1 compare:obj2 options:NSNumericSearch]; }];
    return [NSArray arrayWithObject:sortDescriptor];
}

#pragma mark - Object Editing
- (RCOObjectEditLayer *) getObjectEditLayerWithId: (NSString *) objectId
{
    RCOObject *theObject = [self getObjectWithId:objectId];
    
    if( theObject == nil )
        return nil;
    
    RCOObjectEditLayer *objEditLayer = [[RCOObjectEditLayer alloc] init];
    [objEditLayer setRcoObj:theObject];
    
    
    
    return objEditLayer;
}


#pragma  mark - Editing Conflicts
- (void) warnUserEditedObjectDeleted: (RCOObject *) deletingObj
{
    NSString *msg = [NSString stringWithFormat: @"Changes to '%@' have not been saved because this record was deleted from the server",
                     [deletingObj displayableName]];
    
    [self performSelectorOnMainThread:@selector(warnUser:) withObject:msg waitUntilDone:NO];
}

- (void) warnUserEditedObjectOverwritten: (RCOObject *) editedObj {
    
    NSString *msg = [NSString stringWithFormat: @"Local changes to '%@(%@)' have been lost because newer data was retrieved from the server. The object was updated from a different device!", [editedObj displayableName], editedObj.rcoRecordId];
    [self performSelectorOnMainThread:@selector(warnUser:) withObject:msg waitUntilDone:NO];
}

- (void) warnUser: (NSString *) aMessage
{
}

#pragma mark -
#pragma mark Images

- (UIImage *) getObjectImage: (RCOObject*) object {
    
    if (!object) {
        return nil;
    }
    
    if ([object.rcoObjectId length] == 0) {
        return nil;
    }
    
    NSData* objectIdData = [self getDataForObject:object.rcoObjectId size:kImageFullSizeDownloaded skipDownload:YES];

    if (objectIdData) {
        return [UIImage imageWithData:objectIdData];
    }

    NSData* mobileRecordIdData = [self getDataForObject:object.rcoMobileRecordId size:kImageSizeForUpload skipDownload:YES];

    if (mobileRecordIdData) {
        return [UIImage imageWithData:mobileRecordIdData];
    }
    
    [self getDataForObject:object.rcoObjectId size:kImageFullSizeDownloaded skipDownload:NO];
    
    return nil;
}

- (UIImage *) getImageForObject: (NSString *) objectId
{
    return [self getImageForObject:objectId size: -1];
}

#import "UIImage+Resize.h"
- (UIImage *) getImageForObject: (NSString *) objectId size: (int) pels
{
    UIImage* image=nil;
    
    NSData* theData = [self getDataForObject:objectId size: [NSString stringWithFormat:@"%i", pels]];
    
    if( theData )
    {
        image = [[UIImage alloc] initWithData:theData];
        return image;
    }
    
    // should do this in the background...
    if( pels != -1 && [self isDataDownloaded:objectId size:@"-1"])
    {   
        theData = [self getDataForObject:objectId size: @"-1"];
        
        UIImage *imageFullsize = [[UIImage alloc] initWithData:theData];
                
        UIImage *imageScaled = [imageFullsize thumbnailImage:pels transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
        
        NSData *scaledData = nil;
        if ([self saveImageContentAsPNG]) {
            scaledData = UIImagePNGRepresentation(imageScaled);
        } else {
            scaledData = UIImageJPEGRepresentation(imageScaled, 1);
        }

        NSURL *path = [self getFilePathForObjectImage:objectId size:[NSString stringWithFormat:@"%i", pels]];
        
        [scaledData writeToURL:path atomically:NO];
        return imageScaled;
    }
        
    return nil;
}

- (void) jumpstartDataDownload: (NSString *) objectId
{
    NSString *pels = @"-1";
    
    RCOObject* obj = [self getObjectWithId:objectId];
    
    if (![self existsOnServer:obj]) {
        return;
    }
    
    if( [self isDataFailed: objectId size: pels] ) {
        [[self moc] performBlockAndWait:^{
            if( [obj hasContent] ) {
                [obj setHasNoContent];
                [obj setContentNeedsDownloading:false];
                [obj setContentIsDownloading:false];
                [self save];
            }
        }];
        return;
    }
    
    if ( ([self contentNeedsDownloading:obj] && (obj != nil)) || ![self isDataDownloaded:objectId size:pels] || self.getMostRecentContent) {
        
        [self downloadDataForObject: objectId size: (NSString *) pels];
    }

}

- (void) jumpstartDataDownloadForced: (NSString *) objectId
{
    NSString *pels = @"-1";
    
    RCOObject* obj = [self getObjectWithId:objectId];
    
    if (![obj existsOnServer]) {
        return;
    }
    
    if( [self isDataFailed: objectId size: pels] ) {
        if( [obj hasContent] ) {
            [obj setHasNoContent];
            [obj setContentNeedsDownloading:false];
            [obj setContentIsDownloading:false];
            [self save];
        }
        return;
    }
    
    if ([obj contentIsDownloading]) {
        return;
    }

    [self requestDataForObject:obj withSize:pels];

}

- (NSData *) getDataForObject: (NSString *) objectId size: (NSString *) pels skipDownload:(BOOL)skipDownload {

    if( objectId == nil ) {
        return nil;
    }
    
    NSURL* path =  [self getFilePathForObjectImage:objectId size: pels];
        
    NSData* theData = [[NSData alloc] initWithContentsOfURL:path];
    
    if ([objectId integerValue] == 0) {
        return theData;
    }
    
    if( [pels isEqualToString:@"-1"] && self.syncStatus != SYNC_STATUS_PAUSED && !skipDownload ) {
        
        [self performSelector:@selector(jumpstartDataDownload:) onThread:[self threadForDownload] withObject:objectId waitUntilDone:false];
    }
    
    return theData;
}

-(void)getNewContentDataForObject:(NSString*)objectId {

    [self performSelector:@selector(jumpstartDataDownloadForced:) onThread:[self threadForDownload] withObject:objectId waitUntilDone:false];
}

- (NSData *) getDataForObject: (NSString *) objectId size: (NSString *) pels
{
    return [self getDataForObject:objectId size:pels skipDownload:NO];

}

- (void) appendDataForObject: (NSString *) objectId data: (NSString *) dataStr {
    return [self appendDataForObject:objectId data:dataStr size:@"-1"];
}

-(NSString*)getDataContentForObject:(NSString*)objectId {
    if( [objectId length] == 0) {
        return nil;
    }
    NSURL* path =  [self getFilePathForObjectImage:objectId size: @"-1"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    
    NSString *fileDirectoryPath = [path relativePath];
    fileDirectoryPath = [fileDirectoryPath stringByDeletingLastPathComponent];
    
    if([fileManager fileExistsAtPath:fileDirectoryPath  isDirectory:&isDir] ) {
        NSMutableData* theData = [[NSMutableData alloc] initWithContentsOfURL:path];
        return [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

- (void) appendDataForObject: (NSString *) objectId data: (NSString *) dataStr size:(NSString*)pels {
    
    if( objectId == nil ) {
        return;
    }
    
    NSURL* path =  [self getFilePathForObjectImage:objectId size: pels];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    
    NSError *error = nil;
    
    NSString *fileDirectoryPath = [path relativePath];
    fileDirectoryPath = [fileDirectoryPath stringByDeletingLastPathComponent];
    
    if(![fileManager fileExistsAtPath:fileDirectoryPath  isDirectory:&isDir] ) {
        BOOL res = [fileManager createDirectoryAtPath:fileDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!res) {
            NSLog(@"");
        }
    }
    
    NSMutableData* theData = [[NSMutableData alloc] initWithContentsOfURL:path];
    
    NSData *dataToAdd = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!theData) {
        theData = [NSMutableData dataWithData:dataToAdd];
    } else {
        [theData appendData:dataToAdd];
    }
    
    error = nil;
    
    BOOL didSaved = [theData writeToFile:[path relativePath] atomically:YES];
    
    if (!didSaved) {
    }
}

- (void) appendDataForObject: (NSString *) objectId data: (NSString *) dataStr fileExtension:(NSString*)fileExtension {
    
    if( objectId == nil ) {
        return;
    }
    
    NSURL *path =  [self getFilePathForObject:objectId extension:fileExtension];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    
    NSError *error = nil;
    
    NSString *fileDirectoryPath = [path relativePath];
    fileDirectoryPath = [fileDirectoryPath stringByDeletingLastPathComponent];
    
    if(![fileManager fileExistsAtPath:fileDirectoryPath  isDirectory:&isDir] ) {
        BOOL res = [fileManager createDirectoryAtPath:fileDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!res) {
            NSLog(@"");
        }
    }
    
    NSMutableData* theData = [[NSMutableData alloc] initWithContentsOfURL:path];
    
    NSData *dataToAdd = [dataStr dataUsingEncoding:NSUTF8StringEncoding];

    if (!theData) {
        theData = [NSMutableData dataWithData:dataToAdd];
    } else {
        [theData appendData:dataToAdd];
    }
    
    error = nil;
    
    BOOL didSaved = [theData writeToFile:[path relativePath] atomically:YES];

    if (!didSaved) {
    }
    
}
-(BOOL)contentIsDownloading:( RCOObject*)obj {
    __block BOOL contentIsDownloading = YES;
    [[self moc] performBlockAndWait:^{
        contentIsDownloading = [obj.fileIsDownloading boolValue];
    }];
    return contentIsDownloading;
}


- (void) downloadDataForObject: (NSString *) objectId size: (NSString *) pels
{
    RCOObject *obj = [self getObjectWithId:objectId];
    __block NSString *objectType = nil;
    
    if( ![self contentIsDownloading:obj] || self.getMostRecentContent)
    {
        [[self moc] performBlockAndWait:^{
            [obj setContentIsDownloading:true];
            [obj setContentNeedsDownloading:false];
            
            if( obj.rcoObjectType == nil ) {
                if( self.rcoObjectType != nil ) {
                    obj.rcoObjectType = self.rcoObjectType;
                }
                else {
                    return;
                }
            }
            objectType = obj.rcoObjectType;
        }];
        
        [self save];
        [self requestDataForObject:objectId andObjectType:objectType withSize:pels];
    }
}

- (void) requestDataForObject: (NSString *)objId andObjectType:(NSString*)objectType withSize: (NSString *) pels {
}

- (void) requestDataForObject: (RCOObject *) obj withSize: (NSString *) pels
{
}

- (BOOL) isDataDownloaded: (NSString *) objectId size: (NSString *) pels
{
    NSURL* fp =  [self getFilePathForObjectImage:objectId size: (NSString *) pels];
    
    BOOL isDir=YES;
	BOOL isDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir];
	
    return isDownloaded;
}

- (BOOL) isDataDownloading: (NSString *) objectId size: (NSString *) pels
{
    RCOObject *obj = [self getObjectWithId:objectId];
    return [obj contentIsDownloading];
}

- (BOOL) isDataFailed: (NSString *) objectId size: (NSString *) pels
{
    NSURL *path=[self getFilePathForObjectImage:objectId size: (NSString *) pels];
    return [self.contentThatFailedToDownload containsObject:path];
}

- (NSURL*) getDirPathForObjectImages
{
	NSURL *fullPath =  [[DataRepository sharedInstance] dataDir];
	fullPath = [fullPath URLByAppendingPathComponent:@"pictures"];
	fullPath = [fullPath URLByAppendingPathComponent:self.localObjectClass];
    return fullPath;
    
}

- (NSURL*) getDirPathForObjectData
{
    NSURL *fullPath =  [[DataRepository sharedInstance] dataDir];
    fullPath = [fullPath URLByAppendingPathComponent:@"data"];
    fullPath = [fullPath URLByAppendingPathComponent:self.localObjectClass];
    return fullPath;
}

-(NSURL*) getFilePathForObjectImage:(NSString *)objectId size: (NSString *) pels
{	
    if (!pels) {
        return nil;
    }
    
    NSString* filename = [self getFileStubForObjectImage:objectId size: (NSString *) pels];
	
    if( filename == nil ) {
        return nil;
    }
    
	NSURL *fullPath = [self getDirPathForObjectImages];
	 
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	BOOL isDir=YES;
	if(! [fileManager  fileExistsAtPath: [fullPath path] isDirectory:&isDir] )
	{
        NSError* error =nil;
        [fileManager createDirectoryAtPath:[fullPath path]  withIntermediateDirectories:YES attributes:nil error:&error];
		if (error !=nil) {
		}
    }
	
	fullPath = [fullPath URLByAppendingPathComponent:filename];
	
	return fullPath;
}

-(NSURL*) getFilePathForObject:(NSString *)objectId
{
    
    return [self getFilePathForObject:objectId andSize:nil];
}

-(NSURL*) getFilePathForObject:(NSString *)objectId andSize:(NSString*)size
{
    NSString* filename = nil;
    if (size) {
        filename = [self getFileStubForObjectImage:objectId size: size];
    } else {
        filename = [self getFileStubForObjectImage:objectId size: @"-1"];
    }
    
    if( filename == nil ) {
        return nil;
    }
    NSURL *fullPath = [self getDirPathForObjectImages];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir=YES;
    if(! [fileManager  fileExistsAtPath: [fullPath path] isDirectory:&isDir] )
    {
        NSError* error =nil;
        [fileManager createDirectoryAtPath:[fullPath path]  withIntermediateDirectories:YES attributes:nil error:&error];
        if (error !=nil) {
        }
    }
    
    fullPath = [fullPath URLByAppendingPathComponent:filename];
    
    return fullPath;
}



-(NSURL*) getFilePathForObject:(NSString *)objectId extension: (NSString *) extension {
    
    NSString* filename = [self getFileStubForObjectData:objectId withExtension:extension];
    
    if( filename == nil ) {
        return nil;
    }
    
    NSURL *fullPath = [self getDirPathForObjectData];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir=YES;
    if(! [fileManager  fileExistsAtPath: [fullPath path] isDirectory:&isDir] )
    {
        NSError* error =nil;
        [fileManager createDirectoryAtPath:[fullPath path]  withIntermediateDirectories:YES attributes:nil error:&error];
        if (error !=nil) {
        }
    }
    
    fullPath = [fullPath URLByAppendingPathComponent:filename];
    
    return fullPath;
}

-(NSURL*)getSaveFilePathForObject:(NSString *)objectId size: (NSString *) pels {
    
    NSURL *fp = nil;
    NSError *error = nil;
    
    // get the full path for downloaded object
    fp = [self getFilePathForObjectImage:objectId size:kImageFullSizeDownloaded];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[fp path] isDirectory:NO]) {
        [[NSFileManager defaultManager] removeItemAtURL:fp error:&error];
        if (error) {
        }
    } else {
    }
    return fp;
}


-(NSURL*)getSaveFilePathForObjectImage:(NSString *)objectId size: (NSString *) pels {

    NSURL *fp = nil;
    NSError *error = nil;
    
    if (pels) {
        fp = [self getFilePathForObjectImage:objectId size:pels];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:[fp path] isDirectory:NO]) {
            [[NSFileManager defaultManager] removeItemAtURL:fp error:&error];
            if (error) {
            }
        }
        if (fp) {
            return fp;
        }
    }
    
    fp = [self getFilePathForObjectImage:objectId size:kImageFullSizeDownloaded];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:[fp path] isDirectory:NO]) {
        [[NSFileManager defaultManager] removeItemAtURL:fp error:&error];
        if (error) {
        }
    }
    fp = [self getFilePathForObjectImage:objectId size:kImageSizeForUpload];

    fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[fp path] isDirectory:NO]) {
        [[NSFileManager defaultManager] removeItemAtURL:fp error:&error];
        if (error) {
        }
    }
    
    return fp;
}

-(NSString*) getFileStubForObjectImage:(NSString *)objectId size: (NSString *) pels
{
    NSString* stub = [NSString  stringWithFormat:@"%@-%@-%@.%@",objectId,pels,self.rcoObjectClass, kRecordContentExtension];
    
    return stub;
}

-(NSString*) getFileStubForObjectData:(NSString *)objectId withExtension:(NSString*)fileExtension
{
    NSString* stub = [NSString  stringWithFormat:@"%@-%@.%@",objectId,self.rcoObjectClass, fileExtension];
    return stub;
}


- (void)saveObjectContent:(NSData*)contentData forObjectId:(NSString*)objectId {
}

- (void)renameImage:(NSString*)mobileRecordId forObjectId:(NSString*)objectId {
    
    NSURL *fp = [self getFilePathForObject:mobileRecordId];
    NSURL * fpNew = [self getFilePathForObjectImage:objectId size:kImageFullSizeDownloaded];;

    BOOL isDir;
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:[fpNew path] isDirectory:&isDir] ){
        return;
    } else {
    }

    if( [[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir] ){
        
        NSData* imageData = [[NSData alloc] initWithContentsOfURL:fp];
        
        BOOL res = [imageData writeToURL:fpNew atomically:YES];
    } else {
    }
}

- (NSURL*)saveImage:(NSData*)imageData forObjectId:(NSString*)objectId andSize:(NSString*)fileSize{
    
    RCOObject *object = [self getObjectWithId:objectId];
    
    NSURL * oldPicture = [self getFilePathForObjectImage:objectId size: @"225"];
    
    NSError *deleteError;
    [[NSFileManager defaultManager] removeItemAtURL:oldPicture error:&deleteError];
    
    NSURL * fpOldFullImage = [self getFilePathForObjectImage:objectId size: @"-1"];
    
    deleteError = nil;
    if (!fileSize) {
        [[NSFileManager defaultManager] removeItemAtURL:fpOldFullImage error:&deleteError];
    }
    
    NSURL * fpOldThumbImage = [self getFilePathForObjectImage:objectId size: @"50"];
    
    deleteError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fpOldThumbImage error:&deleteError];

    fpOldThumbImage = nil;
    
    if (fileSize) {
        fpOldThumbImage = [self getFilePathForObjectImage:objectId size:fileSize];
    }
    deleteError = nil;
    
    if (fpOldThumbImage) {
        [[NSFileManager defaultManager] removeItemAtURL:fpOldThumbImage error:&deleteError];
    }

    NSURL * fp = nil;
    if (fileSize) {
        fp = [self getSaveFilePathForObjectImage:objectId size:fileSize];
    } else {
        fp = [self getSaveFilePathForObjectImage:objectId size:kImageSizeForUpload];
    }
    
    BOOL isDir;
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir] ){
        
        [imageData writeToURL:fp atomically:YES];
        [imageData writeToURL:fpOldFullImage atomically:YES];
        
        if( [object existsOnServer] ) {
            if ([fileSize length]) {
                [self uploadObjectContent:object size:fileSize];
            } else {
                [self uploadObjectContent:object size:kImageSizeForUpload];
            }
        }
        return fp;
    }
    return nil;
}

-(void)deleteLocalContentForObject:(NSString*)objectId {
    
    NSURL *path = [self getFilePathForObjectImage:objectId size: @"225"];
    
    NSError *deleteError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:path error:&deleteError];
    
    if (deleteError) {
    }
    
    path = nil;
    deleteError = nil;
    path = [self getFilePathForObjectImage:objectId size: @"-1"];
    
    [[NSFileManager defaultManager] removeItemAtURL:path error:&deleteError];
    
    if (deleteError) {
    }

    path = nil;
    deleteError = nil;
    path = [self getFilePathForObjectImage:objectId size: @"50"];
    
    [[NSFileManager defaultManager] removeItemAtURL:path error:&deleteError];
    if (deleteError) {
    }
    
    path = nil;
    deleteError = nil;
    path = [self getFilePathForObjectImage:objectId size:kImageSizeForUpload];
    
    [[NSFileManager defaultManager] removeItemAtURL:path error:&deleteError];
    
    if (deleteError) {
    }

    path = nil;
    deleteError = nil;
    path = [self getFilePathForObjectImage:objectId size:kImageSizeThumbnailSize];
    
    [[NSFileManager defaultManager] removeItemAtURL:path error:&deleteError];
    
    if (deleteError) {
    }
}

- (void)saveImage:(NSData*)imageData forObjectId:(NSString*)objectId {
    
    [self saveImage:imageData forObjectId:objectId andSize:nil];
}

- (void)saveImage:(NSData*)imageData forRecordId:(NSString*)recordId {
    
    RCOObject *object = [self getObjectWithRecordId:recordId];
    
    NSURL * oldPicture = [self getFilePathForObjectImage:recordId size: @"225"];
    
    NSError *deleteError;
    [[NSFileManager defaultManager] removeItemAtURL:oldPicture error:&deleteError];
    
    NSURL * fpOldFullImage = [self getFilePathForObjectImage:recordId size: @"-1"];
    
    deleteError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fpOldFullImage error:&deleteError];
    
    NSURL * fpOldThumbImage = [self getFilePathForObjectImage:recordId size: @"50"];
    
    deleteError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fpOldThumbImage error:&deleteError];
    
    NSURL * fp = [self getSaveFilePathForObjectImage:recordId size:kImageSizeForUpload];
    
    BOOL isDir;
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir] ){
        
        [imageData writeToURL:fp atomically:YES];
        [imageData writeToURL:fpOldFullImage atomically:YES];
        
        if( [object existsOnServerNew] ) {
            if ([object existsOnServer]) {
                [self uploadObjectContent:object size:kImageSizeForUpload];
            } else {
            }
        }
    }
}

-(BOOL)uploadRecordContent:(RCOObject*)object andSize:(NSString*)fileSize {
    
    NSURL *contentPath = nil;
    
    if ([fileSize length]) {
        contentPath = [self getFilePathForObjectImage:object.rcoObjectId size:fileSize];
    } else {
        contentPath = [self getFilePathForObject:object.rcoObjectId];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL contentExists = NO;
    
    if ([fileManager fileExistsAtPath:[contentPath path] isDirectory:NO]) {
        contentExists = YES;
    } else {
        if (fileSize) {
            contentPath = [self getFilePathForObject:object.rcoMobileRecordId andSize:fileSize];
        } else {
            contentPath = [self getFilePathForObject:object.rcoMobileRecordId];
        }
        
        if ([fileManager fileExistsAtPath:[contentPath path] isDirectory:NO]) {
            contentExists = YES;
        } else {
            
            contentPath = [self getAvailableContentForObject:object.rcoMobileRecordId andSize:fileSize];
            
            if ([fileManager fileExistsAtPath:[contentPath path] isDirectory:NO]) {
                contentExists = YES;
            }
        }
    }
    
    if ([object existsOnServer] && contentExists) {
        [self uploadObjectContent:object fromURL:contentPath];
    }
    return contentExists;
}

-(NSURL*)getAvailableContentForObject:(NSString*)mobileRecordId andSize:(NSString*)fileSize{
    
    if (mobileRecordId.length == 0) {
        return nil;
    }
    
    NSURL *directoryPath = [self getDirPathForObjectImages];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *contentOfDirectory = [fileManager contentsOfDirectoryAtURL:directoryPath
                                             includingPropertiesForKeys:nil
                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                  error:&error];
    NSMutableArray *res = [NSMutableArray array];
    
    for (NSURL *path in contentOfDirectory) {
        if ([path.absoluteString containsString:mobileRecordId]) {
            [res addObject:path];
        }
    }

    
    NSURL * fp = nil;
    
    fp = [self getSaveFilePathForObjectImage:mobileRecordId size:kImageSizeForUpload];

    if ([res containsObject:fp]) {
        return fp;
    } else if (res.count) {
        return [res objectAtIndex:0];
    }
    
    return nil;
}

-(BOOL)uploadRecordContent:(RCOObject*)object {
    
    return [self uploadRecordContent:object andSize:nil];
}

- (NSURL*)saveRecordContentNew:(NSData*)contentData forObjectId:(NSString*)objectId {
    
    RCOObject *object = [self getObjectWithId:objectId];
    
    NSURL * oldContent = [self getFilePathForObject:objectId];
    
    NSError *deleteError;
    [[NSFileManager defaultManager] removeItemAtURL:oldContent error:&deleteError];
    
    NSURL * fp = [self getSaveFilePathForObject:objectId size:kImageSizeForUpload];
    
    BOOL isDir;
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir] ){
        
        BOOL didSaved = [contentData writeToURL:fp atomically:YES];
        
        if( [object existsOnServer] ) {
            [self uploadObjectContent:object fromURL:fp];
        }
    }
    return fp;
}


- (void)saveRecordContent:(NSData*)contentData forObjectId:(NSString*)objectId {
    
    RCOObject *object = [self getObjectWithId:objectId];
    
    NSURL * oldContent = [self getFilePathForObject:objectId];
    
    NSError *deleteError;
    [[NSFileManager defaultManager] removeItemAtURL:oldContent error:&deleteError];

    NSURL * fp = [self getSaveFilePathForObject:objectId size:kImageSizeForUpload];
    
    BOOL isDir;
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir] ){
        
        BOOL didSaved = [contentData writeToURL:fp atomically:YES];
        
        
        if( [object existsOnServer] ) {
            [self uploadObjectContent:object size:kImageFullSizeDownloaded];
        }
    }
    
    fp = [self getSaveFilePathForObject:objectId size:kImageFullSizeDownloaded];

    if( ![[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir] ){
        
        BOOL didSaved = [contentData writeToURL:fp atomically:YES];
    }
}

-(void)save {

    [[self moc] performBlockAndWait:^{
        
        if ([[self moc] hasChanges]) {
#if DATABASE_SAVE_TIMING
            CFTimeInterval startTime = CACurrentMediaTime();
#endif
            NSError *error = nil;
            if ( ! [[self moc] save:&error]) {
                NSDictionary *userInfo = [error userInfo];
                    
                if( userInfo != nil && [userInfo count]) {
                    NSArray* detailedErrors = nil;
                    detailedErrors = [userInfo objectForKey:NSDetailedErrorsKey];
                    if(detailedErrors != nil && [detailedErrors count] > 0)
                    {
                        for(NSError* detailedError in detailedErrors)
                        {
                            NSLog(@"Error %@", detailedError);
                        }
                    }
                    else {
                    }
                }
            } else {
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

#pragma mark - Threading

static NSThread *sAggregateDownloadThread;

- (NSThread *)threadForDownload
{
    if (!sAggregateDownloadThread && self.syncStatus != SYNC_STATUS_PAUSED ) {
        
		sAggregateDownloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(runBackgroundRequests:) object:[NSNumber numberWithDouble:0.5]];

        sAggregateDownloadThread.name = @"Data Download";
        
		[sAggregateDownloadThread start];
	}
	return sAggregateDownloadThread;
}

static NSThread *sAggregateUploadThread;

- (NSThread *)threadForUpload
{
	if (!sAggregateUploadThread && self.syncStatus != SYNC_STATUS_PAUSED ) {
		sAggregateUploadThread = [[NSThread alloc] initWithTarget:self selector:@selector(runBackgroundRequests:) object:[NSNumber numberWithDouble:0.5]];
		
        sAggregateUploadThread.name = @"Data Upload";
        
        [sAggregateUploadThread start];
	}
	return sAggregateUploadThread;
}

- (void)runBackgroundRequests: (NSNumber *) priority
{
	CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
	CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    [[NSThread currentThread] setThreadPriority:[priority doubleValue]];
    
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSManagedObjectContext *threadMoc = nil;
    
    BOOL is90 = YES;
    
    if( threadDict != nil ) {
        
        NSPersistentStoreCoordinator *coordinator = [[DataRepository sharedInstance] persistentStoreCoordinator];
        
        if (coordinator != nil) {
            if (!is90) {
                threadMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
                [threadMoc setPersistentStoreCoordinator:coordinator];
                [threadMoc setMergePolicy:NSOverwriteMergePolicy];
            } else {
                threadMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                [threadMoc performBlockAndWait:^{
                    NSManagedObjectContext *parentContext = [DataRepository sharedInstance].masterSaveContext;
                    [threadMoc setParentContext:parentContext];
                    [threadMoc setName:[NSThread currentThread].name];
                    [threadMoc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                }];
            }
            [threadDict setObject:threadMoc forKey:kMobileOfficeKey_MOC];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(mergeMocChangesToOtherThreads:)
                       name:NSManagedObjectContextDidSaveNotification
                     object:threadMoc];
        }
    }
   
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSDate *futureDate = [NSDate distantFuture];
    
    BOOL stillRunning = YES;
	while (! [[NSThread currentThread] isCancelled] && stillRunning) {
		@autoreleasepool {
		
        stillRunning = [runLoop runMode:NSDefaultRunLoopMode beforeDate:futureDate];
            
		}
	}
    
    [self save];
    
    
    threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict removeObjectForKey:kMobileOfficeKey_MOC];
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
	CFRelease(source);
}

- (void) waitForThreadToEnd {
    
    [[NSThread currentThread] cancel];
    
    if( [NSThread currentThread] == sAggregateUploadThread ) {
        sAggregateUploadThread = nil;
    }
    if( [NSThread currentThread] == sAggregateDownloadThread ) {
        sAggregateDownloadThread = nil;
    }
}

- (void) shutdownThreads: (NSDictionary *) callerDict {
    if( sAggregateUploadThread != nil )
        [self performSelector:@selector(waitForThreadToEnd) onThread:sAggregateUploadThread withObject:nil waitUntilDone:true];
    
    if( sAggregateDownloadThread != nil )
        [self performSelector:@selector(waitForThreadToEnd) onThread:sAggregateDownloadThread withObject:nil waitUntilDone:true];
        [[DataRepository sharedInstance].opQueue cancelAllOperations];
    [[DataRepository sharedInstance].opQueue waitUntilAllOperationsAreFinished];
    
    [[DataRepository sharedInstance] performSelectorOnMainThread:@selector(finishUnloadingUserAggregates:) withObject:callerDict waitUntilDone:false];    
}

// merge the changes from our background thread into the main moc
- (void) mergeMocChangesToOtherThreads: (NSNotification *) notification
{
    if ([[NSThread currentThread] isCancelled]) {
        return;
    }
        
    [[DataRepository sharedInstance] performSelectorOnMainThread:@selector(mergeMocChangesFromBackgroundThread:)
                                                      withObject:notification
                                                   waitUntilDone:YES];
    
    NSDictionary *userInfo = [notification userInfo];
    
    if( userInfo ) {
        for( NSString* actionKey in [userInfo allKeys]) {
            
            if ([actionKey isEqualToString:@"managedObjectContext"]) {
                continue;
            }

            NSArray *changedObjects = [userInfo objectForKey:actionKey];
            NSMutableArray *messagedAggregates = [NSMutableArray array];
            Boolean bCountChanged = [actionKey isEqualToString:@"inserted"] || [actionKey isEqualToString:@"deleted"];
            
            for( RCOObject *obj in changedObjects ) {
                
                if (![obj isKindOfClass:[RCOObject class]]) {
                    continue;
                }
                Aggregate *agg = nil;
                
                NSString *entityName = [[obj entity] name];
                if ([entityName isEqualToString:kDeletedEntity]) {
                } else {
                    agg = [obj aggregate];
                }
                
                [agg dispatchToTheListeners:kObjectDownloadComplete withObjectId:obj.rcoObjectId];
                
                if( agg && bCountChanged ) {
                    if( [actionKey isEqualToString:@"inserted"] ) {
                        agg.approximateCount++;
                    }
                    else {
                        agg.approximateCount--;
                    }
                    if( ![messagedAggregates containsObject:agg]) {
                        [messagedAggregates addObject:agg];
                    }
                }
            }
            
            if( bCountChanged ) {
                for( Aggregate *agg in messagedAggregates ) {
                    NSDictionary *msgDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:agg.approximateCount] forKey:[agg uniqueName]];
                    
                    [[DataRepository sharedInstance] performSelectorOnMainThread:@selector(updateObjectCountForAggregate:)
                                                                      withObject:msgDict
                                                                   waitUntilDone:NO];
                }
            }
        }
    }
    
    // merge changes into other background thread
    if( [NSThread currentThread] != sAggregateDownloadThread ) {
        [self performSelector:@selector(mergeMocChangesFromOtherThread:)
                     onThread:sAggregateDownloadThread
                   withObject:notification
                waitUntilDone:NO];
        
    }
    
    if( [NSThread currentThread] != sAggregateUploadThread ) {
        [self performSelector:@selector(mergeMocChangesFromOtherThread:)
                     onThread:sAggregateUploadThread
                   withObject:notification
                waitUntilDone:NO];
   }
}

- (void) mergeMocChangesFromOtherThread: (NSNotification *) notification {
    
#if DATABASE_SAVE_TIMING
    CFTimeInterval startTime = CACurrentMediaTime();
#endif
    
    [[self moc] performBlockAndWait:^{
        [[self moc] performSelector:@selector(mergeChangesFromContextDidSaveNotification:)
                         withObject:notification];
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
            info = [NSString stringWithFormat:@"%@%@ %ld %@", info,[info length] ? @", " : @"", (long)[objects count], theKey];
            
        }
    }
    
    CFTimeInterval fetchDuration = CACurrentMediaTime() - startTime;
#endif

    
}

-(void)showAlert:(NSString*)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                             message:message
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
    
    [alert show];
}

-(void)showMessage:(NSString*)message {
   
    if (_showErrorMessage) {
        if (message) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else if (_sendErrorMessage) {
        [self sendError:message synchronous:YES];
    }
}

-(void)showAlertMessage:(NSString*)message {
    [self performSelectorOnMainThread:@selector(_showAlertMessage:) withObject:message waitUntilDone:NO];
}

-(void)_showAlertMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Error Methods
- (BOOL)isResponseValid:(NSData*)responseData {
    if (!responseData) {
        return NO;
    }
    
    NSError *error = nil;
    NSObject *obj = [NSJSONSerialization JSONObjectWithData:responseData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
    if (obj) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString*)responseError:(NSString*)responseString {
    
    NSArray *errorArray = [responseString componentsSeparatedByString:@"rror. "];
    
    if (errorArray.count) {
        return [errorArray objectAtIndex:0];
    }
    
    errorArray = [responseString componentsSeparatedByString:@"lang.Exception"];
    
    if (errorArray.count) {
        return [errorArray objectAtIndex:0];
    }
    
    errorArray = [responseString componentsSeparatedByString:@"at com.rco."];
    
    if (errorArray.count) {
        return [errorArray objectAtIndex:0];
    }
    
    return nil;
}

- (void)sendSyncMessage:(NSString*)syncString synchronous:(BOOL)isSyncCall {
    
    if ([syncString length]) {
        
        Aggregate *delegate = nil;
        
        if (!isSyncCall) {
            delegate = self;
        }
    }
}

- (void)sendError:(NSString*)errorString synchronous:(BOOL)isSyncCall;
{
}

-(NSString*)getErrorFileName:(NSDictionary*)objDict {
    
    NSString *filePath = [objDict objectForKey:ERROR_CSV_FILE_PATH];
    NSNumber *csvRow = [objDict objectForKey:ERROR_CSV_ROW];
    NSString *errorCode = [objDict objectForKey:ERROR_CODE];
    
    if ([errorCode length]) {
        return [NSString stringWithFormat:@"%@-%@", filePath, csvRow];
    }
    
    return nil;
}

-(NSArray*)createRecordInNodeDirectory:(RCOObject*)obj fromParams:(NSDictionary*)paramsDict {
    NSArray *result = nil;
        
    return result;
}

#pragma mark - Synchronous Set/Get
-(void)updateRecordFromString:(NSString*)updateString {
    [self updateRecordFromString:updateString delegate:nil];
}

-(void)updateRecordFromString:(NSString*)updateString delegate:(id<HTTPClientDelegate, HTTPClientOperationDelegate>)delegate {
}

- (NSArray*)getRecordCodingByRecordId:(NSString*)recordId {
    
    NSArray *result = nil;
    return result;
}

- (NSArray*)getRecordCodingByMobileRecordId:(NSString*)mobileRecordId {

    NSArray *result = nil;
    return result;

}
-(void)getRecordCodingFields:(NSString*)objectId andObjectType:(NSString*)objType andDelegate:(id)delegate{
}

-(NSArray*)getRecordCodingFields:(NSString*)objectId andObjectType:(NSString*)objType {
    
    NSArray *result = nil;
    
    return result;
}

- (NSDictionary*)getRecordInfoByRecordId:(NSString*)recordId {
    return nil;
}

- (NSDictionary*)getRecordInfoByMobileRecordId:(NSString*)mobileRecordId {
    return nil;
}

-(void)setUploadingCallInfoForObject:(RCOObject*)obj {
    if (obj) {
        NSMutableDictionary *callParameters = [NSMutableDictionary dictionary];
        
        if (![_callsInfo objectForKey:obj.rcoObjectId]) {
            [callParameters setObject:[NSNumber numberWithInteger:kNumberOfTries] forKey:kCalls];
        } else {
            NSDictionary *dict = [_callsInfo objectForKey:obj.rcoObjectId];
            
            NSInteger numberOfCalls = [[dict objectForKey:kCalls] integerValue];
            
            [callParameters setObject:[NSNumber numberWithInteger:(numberOfCalls - 1)] forKey:kCalls];
        }
        if (obj.rcoObjectId) {
            [_callsInfo setObject:callParameters forKey:obj.rcoObjectId];
        }
    }
}

-(NSString*)parseSetRequest:(id)request isForDetail:(NSNumber*)forDetail{

    __block NSString *res = nil;
    
    [[self moc] performBlockAndWait:^{
        res = [self _parseSetRequest:request isForDetail:forDetail];
    }];

    return res;
}

-(NSString*)_parseSetRequest:(id)request isForDetail:(NSNumber*)forDetail{

        NSDictionary *msgInfo = [self getMsgDictFromRequestResponse:request];
        NSString *responseString = [self getResponseStringFromRequest:request];
        
        NSString *headerObjId = [msgInfo objectForKey:@"objId"];
        
        Aggregate *headerAgg = self;
        
        if ([forDetail boolValue]) {
            headerAgg = [[DataRepository sharedInstance] getAggregateForClass:self.rcoObjectParentClass];
        }
        
        RCOObject *header = nil;
        
        if ([headerObjId hasPrefix:self.rcoObjectClass]) {
            header = [headerAgg getObjectWithMobileRecordId:headerObjId];
        } else {
            header = [headerAgg getObjectWithId:headerObjId];
        }
        
        if (!header) {
            // if the header is nil then we should not continue
            return nil;
        }
        
        Aggregate *detailAgg = nil;
        
        if ([forDetail boolValue]) {
            detailAgg = self;
        } else {
            if ([self.detailAggregates count]) {
                detailAgg = [self.detailAggregates objectAtIndex:0];
            }
        }
        
        NSInteger responseStatusCode = [[self getErrorFromRequestResponse:request] integerValue];
        
        if (responseStatusCode == 500) {
            NSString *fileName = [msgInfo objectForKey:@"fileName"];
            
            if ([forDetail boolValue]) {
                [detailAgg sendError:fileName synchronous:YES];

                return RESPONSE_INTERNAL_ERROR;
            }
            
            [header setNeedsUploading:NO];
            
            if ([header existsOnServer]) {
                // do nothing.. should we delete details that does not exist on the server?
                [headerAgg deleteDetailsForObject:header existingDetails:NO];
            } else {
                // we should remove the header and also details
                [headerAgg deleteDetailsForObject:header existingDetails:YES];
                [headerAgg destroyObj:header];
            }
            
            [headerAgg save];
            [headerAgg sendError:fileName synchronous:YES];
            
            return RESPONSE_INTERNAL_ERROR;
        }
        
        NSError *error = nil;
        
        NSArray* fieldValues = [self JSONArrayFromRequestResponse:request error:&error];
        
        if (!fieldValues) {
            if ([[DataRepository sharedInstance] workOffline] && ![[DataRepository sharedInstance] forcedSync]) {
                // if is working offline and if is not forced sync then we should not try to upload
                return headerObjId;
            }
        }
        
        if (fieldValues.count == 0) {
            // this should happen in the case when we receive no file attached exception
            if (header) {
                
                NSDictionary *callParameters = [_callsInfo objectForKey:header.rcoObjectId];
                
                NSNumber *callNumber = [callParameters objectForKey:kCalls];
                
                if ([callNumber integerValue] > 0) {
                    // we should make the second attempt tpo make the call after delay seconds
                    if ([forDetail boolValue]) {
                        [detailAgg performSelector:@selector(createNewRecord:) withObject:header afterDelay:kCallDelay];
                    } else {
                        [headerAgg performSelector:@selector(createNewRecord:) withObject:header afterDelay:kCallDelay];
                    }
                    
                } else {
                    NSString *responseString = [self getResponseStringFromRequest:request];
                    NSString *errorString = [self getErrorFromRequestResponse:request];
                    NSDictionary *userInfo = [self getMsgDictFromRequestResponse:request];
                    
                    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                    
                    if (responseString) {
                        [resultDict setObject:responseString forKey:kMessageResponseKey];
                    } else {
                        NSString *message = nil;
                        if ([forDetail boolValue]) {
                            message = [NSString stringWithFormat:@"%@: %@", detailAgg.rcoRecordType, errorString];
                        } else {
                            message = [NSString stringWithFormat:@"%@: %@", headerAgg.rcoRecordType, errorString];
                        }
                        [resultDict setObject:message forKey:kMessageResponseKey];
                    }
                    
                    if (header.rcoObjectId) {
                        [_callsInfo removeObjectForKey:header.rcoObjectId];
                    }
                    
                    if ([forDetail boolValue]) {
                        [detailAgg dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
                    } else {
                        [headerAgg dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
                    }
                    
                    NSString *message = nil;
                    
                    if (_showErrorMessage) {
                        message = responseString;
                    } else if (_sendErrorMessage) {
                        message = [NSString stringWithFormat:@"%@-%d", [userInfo objectForKey:@"fileName"], kNumberOfTries] ;
                    }
                    
                    [headerAgg performSelectorOnMainThread:@selector(showMessage:)
                                                withObject:message
                                             waitUntilDone:NO];
                }
            }
            
            return nil;
        }
        
        if ([header rcoObjectId]) {
            [_callsInfo removeObjectForKey:[header rcoObjectId]];
        }
        
        NSDictionary *headerDict = [fieldValues objectAtIndex:0];
        
        NSString *fileErrorName = [self getErrorFileName:headerDict];
        
        if ([fileErrorName length]) {
            
            if ([forDetail boolValue]) {
                /*
                 we should not delete the header if the call for creating extra details fails
                 */
                [header setNeedsUploading:NO];
                [headerAgg save];
                return nil;
            }
            
            [header setNeedsUploading:NO];
            
            if ([header existsOnServer]) {
                [headerAgg deleteDetailsForObject:header existingDetails:NO];
            } else {
                [headerAgg deleteDetailsForObject:header existingDetails:YES];
                [headerAgg destroyObj:header];
            }
            
            [headerAgg save];
            return nil;
        }
        
        NSNumber * objectId = [headerDict objectForKey:@"LobjectId"];
        
        if (!objectId || ([objectId doubleValue] == 0)) {
            NSString *message = [NSString stringWithFormat:@"Bad response:\n\n%@", responseString];
            [headerAgg performSelectorOnMainThread:@selector(showMessage:)
                                        withObject:message
                                     waitUntilDone:NO];
        }
        
        NSString *objectType = [headerDict objectForKey:@"objectType"];
        
        NSArray *arCodingInfo = [headerDict objectForKey:@"arCodingInfo"];
        
        NSDictionary *mapCodingInfo = [headerDict objectForKey:@"mapCodingInfo"];
        
        NSArray *arDetailRecordData = [headerDict objectForKey:@"arDetailRecordData"];
        
        NSArray *arDetailRecordDataMapped = [headerDict objectForKey:@"arDetailRecordDataMapped"];
        
        header.rcoObjectType = objectType;
        header.rcoObjectId = [NSString stringWithFormat:@"%@", objectId];
        header.rcoObjectSearchString = nil;
        
        if ([arCodingInfo count]) {
            for (NSDictionary *arCodingDict in arCodingInfo) {
                NSString *fieldName = [arCodingDict objectForKey:@"displayName"];
                NSString *fieldValue = [arCodingDict objectForKey:@"value"];
                [headerAgg syncObject:header withFieldName:fieldName toFieldValue:fieldValue];
            }
        } else {
            NSArray *codingFields = [mapCodingInfo allKeys];
            for (NSString *codingField in codingFields) {
                NSString *fieldValue = [mapCodingInfo objectForKey:codingField];
                [headerAgg syncObject:header withFieldName:codingField toFieldValue:fieldValue];
            }
        }
        
        NSArray *details = nil;
        
        if ([arDetailRecordData count]) {
            details = arDetailRecordData;
        } else {
            details = arDetailRecordDataMapped;
        }
        
        for (NSDictionary *arDetailDict in /*arDetailRecordData*/ details) {
            
            NSNumber * objectIdDetail = [arDetailDict objectForKey:@"LobjectId"];
            NSString *objectTypeDetail = [arDetailDict objectForKey:@"objectType"];
            
            NSArray *arCodingInfoDetail = [arDetailDict objectForKey:@"arCodingInfo"];
            NSDictionary *mapCodingInfo = [arDetailDict objectForKey:@"mapCodingInfo"];
            
            NSString *mobileRecordId = [arDetailDict objectForKey:@"mobileRecordId"];
            
            NSArray *classItems = [mobileRecordId componentsSeparatedByString:@"-"];
            
            NSString *objectClass = nil;
            
            if (classItems.count) {
                objectClass = [classItems objectAtIndex:0];
            }
            if (![detailAgg.rcoObjectClass isEqualToString:objectClass] && [objectClass length]) {
                continue;
            }
            
            RCOObject *detail = nil;
            
            if ([mobileRecordId length] > 0) {
                
                NSArray *objects = [detailAgg getObjectsWithMobileRecordId:mobileRecordId];
                
                if ([objects count] > 0) {
                    detail = [objects objectAtIndex:0];
                }
            } else {
                detail = [detailAgg getObjectWithId:[objectIdDetail stringValue]];
            }
            
            NSString *barcode = nil;
            NSString *timestamp = nil;
            
            NSString *fileErrorName = [headerAgg getErrorFileName:arDetailDict];
            
            if ([fileErrorName length]) {
                
                [headerAgg sendError:fileErrorName synchronous:YES];
                if (![detail existsOnServer]) {
                    if (detail) {
                        [detailAgg destroyObj:detail];
                    }
                }
                continue;
            }
            
            detail.rcoObjectSearchString = nil;
            
            if ([arCodingInfoDetail count]) {
                // old way ..
                for (NSDictionary *arCodingDict in arCodingInfoDetail) {
                    
                    NSString *fieldName = [arCodingDict objectForKey:@"displayName"];
                    NSString *fieldValue = [arCodingDict objectForKey:@"value"];
                    
                    if ([fieldName isEqualToString:@"RMS Coding Timestamp"]) {
                        timestamp = fieldValue;
                    }
                    
                    if ([fieldName isEqualToString:@"MobileRecordId"]) {
                        mobileRecordId = fieldValue;
                        NSLog(@"MOBILE RECORDID = %@", mobileRecordId);
                        if (![mobileRecordId hasPrefix:detailAgg.rcoObjectClass]) {
                            break;
                        }
                    }
                    if ([fieldName isEqualToString:@"BarCode"]) {
                        barcode = fieldValue;
                    }
                }
            } else {
                NSArray *codingFields = [mapCodingInfo allKeys];
                
                if (_skipUpdatingAllDetailCodingFields) {
                    timestamp = [mapCodingInfo objectForKey:@"RMS Coding Timestamp"];
                    mobileRecordId = [mapCodingInfo objectForKey:@"MobileRecordId"];
                    barcode = [mapCodingInfo objectForKey:@"BarCode"];
                    for (NSString *codingField in codingFields) {
                        NSString *value = [mapCodingInfo objectForKey:codingField];
                        if ([codingField isEqualToString:@"Master Barcode"] || [codingField isEqualToString:@"RecordId"]) {
                            [detailAgg syncObject:detail withFieldName:codingField toFieldValue:value];
                        }
                    }
                    
                } else {
                    for (NSString *codingField in codingFields) {
                        NSString *value = [mapCodingInfo objectForKey:codingField];
                        [detailAgg syncObject:detail withFieldName:codingField toFieldValue:value];
                    }
                }
            }
            
            detail.rcoObjectId = [NSString stringWithFormat:@"%@", objectIdDetail];
            detail.rcoObjectType = objectTypeDetail;
            detail.rcoBarcodeParent = header.rcoBarcode;
            detail.rcoObjectParentId = header.rcoObjectId;
            detail.rcoBarcode = barcode;
            [detail setNeedsUploading:NO];
            [detailAgg updateCodingFieldsForObject:detail];
            [detailAgg objectUploadedWithMobileRecordId:detail.rcoMobileRecordId andUpdateToRCORecordId:detail.rcoRecordId];
        }
        
        [detailAgg save];
        [header setNeedsUploading:NO];
        [header setIsUploading:NO];
        [headerAgg save];
        
        [self objectUploadedWithMobileRecordId:header.rcoMobileRecordId andUpdateToRCORecordId:header.rcoRecordId];
        
        [self checkLinkedRecords:header];
        return header.rcoObjectId;
    
}

-(void)checkLinkedRecords:(RCOObject*)obj {
    
    if (![obj isKindOfClass:[RCOObject class]]) {
        return;
    }
    
    if (![obj existsOnServerNew]) {
        return;
    }
    if ([obj.fileLog length] == 0) {
        return;
    }
    NSArray *linkedRecords = [obj.fileLog componentsSeparatedByString:@","];
    
    if (linkedRecords.count == 0) {
        return;
    }
    
    NSLog(@"linked records = %@", linkedRecords);
    
    for (NSString *mobileRecordId in linkedRecords) {
        // smth linke "Note-NoId-rcog-1520408669.928691";
        NSString *objectClass = [self getObjectClassFromMobileRecordId:mobileRecordId];
        if (objectClass.length == 0) {
            continue;
        }
        Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:objectClass];
        RCOObject *linkedObject = [agg getObjectMobileRecordId:mobileRecordId];
        
        if ([linkedObject existsOnServerNew]) {
            continue;
        }

        if ([linkedObject respondsToSelector:@selector(parentObjectId)]) {
            [linkedObject setValue:obj.rcoObjectId forKey:@"parentObjectId"];
        }
        
        if ([linkedObject respondsToSelector:@selector(parentObjectType)]) {
            [linkedObject setValue:obj.rcoObjectType forKey:@"parentObjectType"];
        }
        
        if ([linkedObject respondsToSelector:@selector(parentBarcode)]) {
            [linkedObject setValue:obj.rcoBarcode forKey:@"parentBarcode"];
        }

        [agg save];
        [agg createNewRecord:linkedObject forced:[NSNumber numberWithBool:YES]];
    }
}

-(NSString*)getObjectClassFromMobileRecordId:(NSString*)mobileRecordId {
    if (mobileRecordId.length == 0) {
        return nil;
    }
    NSArray *comp = [mobileRecordId componentsSeparatedByString:@"-"];
    if (comp.count == 0) {
        return nil;
    }
    return [comp objectAtIndex:0];
}

- (void)objectUploadedWithMobileRecordId:(NSString*)mobileRecordId andUpdateToRCORecordId:(NSString*)rcoRecordId {
    
}

-(RCOObject*)getLinkedObjectForObject:(RCOObject*)obj {
    
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:obj.rcoObjectClass];
    if (!agg) {
        return nil;
    }
    
    RCOObject *linkedRecord = nil;
    Aggregate *linkedRecordAggregate = nil;
    
    if ([agg.linkedRecords count]) {
        for (NSInteger i = 0; i < agg.linkedRecords.count; i++) {
            NSString *localObjClass = [agg.linkedRecords objectAtIndex:i];
            NSString *codingField = nil;
            
            if (i < agg.linkedRecordsField.count) {
                codingField = [agg.linkedRecordsField objectAtIndex:i];
            } else {
                continue;
            }
            
            linkedRecordAggregate = [[DataRepository sharedInstance] getAggregateForClass:localObjClass];
            if (linkedRecordAggregate) {
                
                NSString *recordId = [obj valueForKey:codingField];
                
                if ([recordId hasPrefix:localObjClass]) {
                    // is mobile record id
                    linkedRecord = [linkedRecordAggregate getObjectWithMobileRecordId:recordId];
                } else {
                    // is a normal record id
                    linkedRecord = [linkedRecordAggregate getObjectWithRecordId:recordId];
                }
                
                /*
                linkedRecord = [linkedRecordAggregate getObjectForCodingField:codingField
                                                                     andValue:obj.rcoMobileRecordId];
                */
                if (linkedRecord) {
                    // we have a record that should be updated
                    [obj setValue:linkedRecord.rcoRecordId forKey:codingField];
                }
            }
        }
    }
    return linkedRecord;
}


-(NSString*)parseSetRequest:(id)request {
    return [self parseSetRequest:request isForDetail:[NSNumber numberWithBool:NO]];
}

-(void)deleteDetailsForObject:(RCOObject*)object existingDetails:(BOOL)existingDetails {
    
    Aggregate *detailAgg = [self.detailAggregates objectAtIndex:0];
    
    NSArray *details = [self getObjectDetails:object.rcoObjectId];
    
    for (RCOObject *detail in details) {
        if (existingDetails) {
            [detailAgg destroyObj:detail];
        } else {
            if (![detail existsOnServer]) {
                [detailAgg destroyObj:detail];
            }
        }
    }
    [detailAgg save];
}


-(void)updateCodingFieldsForObject:(RCOObject*)object {
}

-(void)updateObject:(RCOObject *)object andSkipGetRecordCoding:(BOOL)skipGetRecordCoding {
}

#pragma mark caching

- (void)loadCaching {
}

- (void)addObjectToCach:(RCOObject*)obj {
    
}

#pragma mark Scan Log

-(void)uploadScanLog:(RCOObject*)object withParams:(NSDictionary*)params {
}

-(void)uploadScanLogFomParams:(NSDictionary*)params {
}

-(void)uploadScanLogFor7Days:(NSDictionary*)params {
}

#pragma mark Scan Log Utilities

-(NSString*)getDateFolder:(NSDate*)date {
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date_str =[f stringFromDate:date];
    
    return date_str;
}

-(NSString*)getScanFolderForItem:(RCOObject*)item {
    return nil;
}

-(NSArray*)arrayFromJSONResponse:(NSString*)JSONResponseString {
    NSError *error = nil;
    NSArray* fieldValues = nil;
    
    NSData *JSONResponseData =  [JSONResponseString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (JSONResponseData) {
        fieldValues = [NSJSONSerialization JSONObjectWithData:JSONResponseData options:NSJSONReadingMutableContainers error:&error];
    }
    return fieldValues;
}

-(NSDictionary*)getMapCodingInfo:(NSDictionary*)dict {
    return [dict objectForKey:kMapCodingInfoKey];
}

#pragma mark - Utilities

-(BOOL)isObjectIdValid:(NSString*)objId {
    if (!objId) {
        return NO;
    }
    if ([objId isEqualToString:RESPONSE_INTERNAL_ERROR]) {
        return NO;
    }
    return YES;
}

- (RCOObject*)createObjectAndDetailsFromDict:(NSDictionary*)objDict {
    
    NSString *originalId = [objDict objectForKey:@"objId"];
    
    NSString *objId = nil;
    
    NSString *fileErrorName = [self getErrorFileName:objDict];
    
    if ([originalId length]) {
        objId = originalId;
    } else {
        NSNumber * objectId = [objDict objectForKey:@"LobjectId"];
        objId = [NSString stringWithFormat:@"%@", objectId];
    }
    
    RCOObject *object = [self getObjectWithId:objId];
    
    
    if ([fileErrorName length]) {
        
        [object setNeedsUploading:NO];
        
        if ([object existsOnServer]) {
            [self deleteDetailsForObject:object existingDetails:NO];
        } else {
            [self deleteDetailsForObject:object existingDetails:YES];
            [self destroyObj:object];
        }
        
        [self save];
        return nil;
    }
    
    if (!object) {
        object = [self createNewObject];
    }
    
    NSString *objectType = [objDict objectForKey:@"objectType"];
    
    NSDictionary *mapCodingInfo = [objDict objectForKey:@"mapCodingInfo"];
    
    NSArray *arDetailRecordDataMapped = [objDict objectForKey:@"arDetailRecordDataMapped"];
    
    object.rcoObjectType = objectType;
    object.rcoObjectId = objId;
    object.rcoObjectSearchString = nil;
    [object setNeedsUploading:NO];

    NSArray *codingFields = [mapCodingInfo allKeys];
    for (NSString *codingField in codingFields) {
        NSString *fieldValue = [mapCodingInfo objectForKey:codingField];
        [self syncObject:object withFieldName:codingField toFieldValue:fieldValue];
    }
    
    Aggregate *detailAgg = [self.detailAggregates objectAtIndex:0];
    
    for (NSDictionary *dict in arDetailRecordDataMapped) {
        [detailAgg createObjectAndDetailsFromDict:dict];
    }
    
    [self save];
    
    return object;
}

- (RCOObject*)createObjectAndDetailsFromDict_OLD:(NSDictionary*)headerDict {
        
    NSString *fileErrorName = [self getErrorFileName:headerDict];
    
    Aggregate *detailAgg = [self.detailAggregates objectAtIndex:0];
    
    NSNumber * objectId = [headerDict objectForKey:@"LobjectId"];
    
    NSString *objId = [NSString stringWithFormat:@"%@", objectId];
    
    RCOObject *header = [self getObjectWithId:objId];
    
    if (!header) {
        header = [self createNewObject];
    }
    
    if ([fileErrorName length]) {
        
        [header setNeedsUploading:NO];
        
        if ([header existsOnServer]) {
            [self deleteDetailsForObject:header existingDetails:NO];
        } else {
            [self deleteDetailsForObject:header existingDetails:YES];
            [self destroyObj:header];
        }
        
        [self save];
        return nil;
    }
    
    NSString *objectType = [headerDict objectForKey:@"objectType"];
    
    NSArray *arCodingInfo = [headerDict objectForKey:@"arCodingInfo"];
    
    NSDictionary *mapCodingInfo = [headerDict objectForKey:@"mapCodingInfo"];
    
    NSArray *arDetailRecordData = [headerDict objectForKey:@"arDetailRecordData"];
    
    NSArray *arDetailRecordDataMapped = [headerDict objectForKey:@"arDetailRecordDataMapped"];
    
    header.rcoObjectType = objectType;
    header.rcoObjectId = [NSString stringWithFormat:@"%@", objectId];
    header.rcoObjectSearchString = nil;
    
    if ([arCodingInfo count]) {
        for (NSDictionary *arCodingDict in arCodingInfo) {
            NSString *fieldName = [arCodingDict objectForKey:@"displayName"];
            NSString *fieldValue = [arCodingDict objectForKey:@"value"];
            [self syncObject:header withFieldName:fieldName toFieldValue:fieldValue];
        }
    } else {
        NSArray *codingFields = [mapCodingInfo allKeys];
        for (NSString *codingField in codingFields) {
            NSString *fieldValue = [mapCodingInfo objectForKey:codingField];
            [self syncObject:header withFieldName:codingField toFieldValue:fieldValue];
        }
    }
    
    NSArray *details = nil;
    
    if ([arDetailRecordData count]) {
        details = arDetailRecordData;
    } else {
        details = arDetailRecordDataMapped;
    }
    
    for (NSDictionary *arDetailDict in /*arDetailRecordData*/ details) {
        
        NSNumber * objectIdDetail = [arDetailDict objectForKey:@"LobjectId"];
        NSString *objectTypeDetail = [arDetailDict objectForKey:@"objectType"];
        
        NSArray *arCodingInfoDetail = [arDetailDict objectForKey:@"arCodingInfo"];
        NSDictionary *mapCodingInfo = [arDetailDict objectForKey:@"mapCodingInfo"];
        
        NSString *mobileRecordId = [arDetailDict objectForKey:@"mobileRecordId"];
        
        NSArray *classItems = [mobileRecordId componentsSeparatedByString:@"-"];
        
        NSString *objectClass = nil;
        
        if (classItems.count) {
            objectClass = [classItems objectAtIndex:0];
        }
        
        if (![detailAgg.rcoObjectClass isEqualToString:objectClass]) {
            continue;
        }
        
        RCOObject *detail = nil;
        
        if ([mobileRecordId length] > 0) {
            
            NSArray *objects = [detailAgg getObjectsWithMobileRecordId:mobileRecordId];
            
            if ([objects count] > 0) {
                detail = [objects objectAtIndex:0];
            }
        } else {
            detail = [detailAgg getObjectWithId:[objectIdDetail stringValue]];
        }
        
        if (!detail) {
            detail = [detailAgg createNewObject];
        }
        
        NSString *barcode = nil;
        NSString *timestamp = nil;
        
        NSString *fileErrorName = [self getErrorFileName:arDetailDict];
        
        if ([fileErrorName length]) {
            
            [self sendError:fileErrorName synchronous:YES];
            if (![detail existsOnServer]) {
                // we shuld delete the detail from local DB!
                if (detail) {
                    [detailAgg destroyObj:detail];
                }
            }
            continue;
        }
        
        detail.rcoObjectSearchString = nil;
        
        if ([arCodingInfoDetail count]) {
            // old way ..
            for (NSDictionary *arCodingDict in arCodingInfoDetail) {
                
                NSString *fieldName = [arCodingDict objectForKey:@"displayName"];
                NSString *fieldValue = [arCodingDict objectForKey:@"value"];
                
                if ([fieldName isEqualToString:@"RMS Coding Timestamp"]) {
                    timestamp = fieldValue;
                }
                
                if ([fieldName isEqualToString:@"MobileRecordId"]) {
                    mobileRecordId = fieldValue;
                    NSLog(@"MOBILE RECORDID = %@", mobileRecordId);
                    if (![mobileRecordId hasPrefix:detailAgg.rcoObjectClass]) {
                        break;
                    }
                }
                if ([fieldName isEqualToString:@"BarCode"]) {
                    barcode = fieldValue;
                }
            }
        } else {
            NSArray *codingFields = [mapCodingInfo allKeys];
            
            if (_skipUpdatingAllDetailCodingFields) {
                // for some objects we don't want to update all coding fields like RMAs, ...
                timestamp = [mapCodingInfo objectForKey:@"RMS Coding Timestamp"];
                mobileRecordId = [mapCodingInfo objectForKey:@"MobileRecordId"];
                barcode = [mapCodingInfo objectForKey:@"BarCode"];
                for (NSString *codingField in codingFields) {
                    NSString *value = [mapCodingInfo objectForKey:codingField];
                    if ([codingField isEqualToString:@"Master Barcode"]) {
                        [detailAgg syncObject:detail withFieldName:codingField toFieldValue:value];
                    }
                }
                
            } else {
                for (NSString *codingField in codingFields) {
                    NSString *value = [mapCodingInfo objectForKey:codingField];
                    [detailAgg syncObject:detail withFieldName:codingField toFieldValue:value];
                }
            }
            
        }
        
        detail.rcoObjectId = [NSString stringWithFormat:@"%@", objectIdDetail];
        detail.rcoObjectType = objectTypeDetail;
        detail.rcoBarcodeParent = header.rcoBarcode;
        detail.rcoObjectParentId = header.rcoObjectId;
        detail.rcoBarcode = barcode;
        [detail setNeedsUploading:NO];
        [detailAgg updateCodingFieldsForObject:detail];
    }
    
    [detailAgg save];
    [header setNeedsUploading:NO];
    [self save];
    
    return header;
}

#pragma mark HTTPClientDelegate Methods

//ARC

-(void)HTTPClientDidFinishedForced:(HTTPClient *)client {
    NSMutableDictionary *respDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, nil];
    [respDict setObject:[NSNumber numberWithBool:YES] forKey:RESPONSE_FORCED];
    NSLog(@">>>Request finished Forced for: %@<<", client.baseURL);
    
    [self requestFinished:respDict];
}

-(void)HTTPClient:(HTTPClient *)client didFinished:(id)resp {
    
    NSString *msg = [client.userInfo objectForKey:@"message"];
    NSString *objDesc = nil;
    
    if ([resp isKindOfClass:[NSData class]]) {
        objDesc = [[NSString alloc] initWithData:(NSData*)resp encoding:NSUTF8StringEncoding];

    } else {
        if (![msg isEqualToString:@"appendRecordContent"]) {
        }
    }
    
    if ([msg isEqualToString:R_S_C_1]) {
        NSLog(@"");
    }
    
    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, resp, RESPONSE_OBJ, client.baseURL, RESPONSE_CALL, objDesc, RESPONSE_STR, nil];
        
    [self requestFinished:respDict];
}

- (void)HTTPClientOperationDidFinishedForced:(HttpClientOperation *)client {
    
    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, nil];
        
    [self requestFinished:respDict];
}
-(void)HTTPClientOperation:(HttpClientOperation *)client didFinished:(id)resp {

    NSString *msg = [client.userInfo objectForKey:@"message"];
    
    
    NSDictionary *respDict = [NSDictionary dictionaryWithObjectsAndKeys:client.userInfo, RESPONSE_USER_INFO, resp, RESPONSE_OBJ, client.request.URL, RESPONSE_CALL, client.responseString, RESPONSE_STR, nil];
    
    NSLog(@"OP: request finished for %@", client.request.URL);
    
    [self requestFinished:respDict];
}

-(void)HTTPClient:(HTTPClient *)client didFailWithError:(NSDictionary *)errorInfoDict {
    NSError *error = [errorInfoDict  objectForKey:ERROR_KEY];
    NSInteger httpErrorCode = [[errorInfoDict objectForKey:ERROR_STATUS_CODE] integerValue];
    NSString *message = [client.userInfo objectForKey:@"message"];
    
    NSString *errorDesc = [errorInfoDict objectForKey:RESPONSE_STR];
    if ([errorDesc length] == 0) {
        errorDesc = error.description;
    }
    
    NSLog(@"Aggregate HTTPClient FAILEDDDD ---->>>>, %d ---+++%@ \n\n%@",  (int)httpErrorCode,  errorDesc, client.baseURL);

    if (httpErrorCode == 200) {
        return;
    }
    
    NSMutableDictionary *usrInfo = [NSMutableDictionary dictionaryWithDictionary:client.userInfo];
    
    if ([errorInfoDict objectForKey:ERROR_STATUS_CODE]) {
        [usrInfo setObject:[errorInfoDict objectForKey:ERROR_STATUS_CODE] forKey:ERROR_STATUS_CODE];
    }
    
    NSMutableDictionary *respDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:usrInfo, RESPONSE_USER_INFO, client.baseURL, RESPONSE_CALL, errorDesc, RESPONSE_STR, nil];
    
    [respDict setObject:[NSNumber numberWithInteger:httpErrorCode] forKey:RESPONSE_STATUS_CODE];
    
    [self requestFailed:respDict];
}


-(void)HTTPClientOperation:(HttpClientOperation *)client didFailWithError:(NSDictionary *)errorInfoDict {
    NSError *error = [errorInfoDict  objectForKey:ERROR_KEY];
    NSInteger httpErrorCode = [[errorInfoDict objectForKey:ERROR_STATUS_CODE] integerValue];
    NSString *message = [client.userInfo objectForKey:@"message"];
    
    if (httpErrorCode == 200) {
        return;
    }
    
    NSMutableDictionary *respDict = [NSMutableDictionary dictionaryWithDictionary:errorInfoDict];
    [respDict setObject:client.userInfo forKey:RESPONSE_USER_INFO];
    [respDict setObject:client.request.URL forKey:RESPONSE_CALL];
    
    [self requestFailed:respDict];

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

-(NSString*)getCallURLFromRequestResponse:(id)request {
    NSString *callURL = nil;
   
    NSDictionary *respDict = (NSDictionary*)request;
    callURL = [respDict objectForKey:RESPONSE_CALL];
    
    return callURL;
}


-(NSDictionary*)getMsgDictFromRequestResponse:(id)request {
    NSDictionary *msgDict = nil;
    
    NSDictionary *respDict = (NSDictionary*)request;
    msgDict = [respDict objectForKey:RESPONSE_USER_INFO];
    
    NSNumber *statusCode = [respDict objectForKey:RESPONSE_STATUS_CODE];
    if (statusCode) {
        NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [res setObject:statusCode forKey:RESPONSE_STATUS_CODE];
        return res;
    } else {
        return msgDict;
    }
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

-(NSError*)getErrorObjFromRequestResponse:(id)request {
    NSError *error = nil;
    {
        NSDictionary *respDict = (NSDictionary*)request;
        error = [respDict objectForKey:ERROR_KEY];
    }
    return error;
}

- (NSString*) entityName {
   return self.localObjectClass;
}

- (NSString*) savingPathForPDF:(RCOObject*)obj {
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString *fileName = [self fileNameForObject:obj];
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    documentDirectory = [documentDirectory stringByAppendingPathComponent:self.rcoObjectClass];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory = YES;
    
    if (![fileManager fileExistsAtPath:documentDirectory isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileFullName = [NSString stringWithFormat:@"%@.pdf", fileName];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:fileFullName];
    return documentDirectoryFilename;

}

-(NSString*)fileNameForObject:(RCOObject*)obj {
    return nil;
}

-(NSPredicate*)getDateTimePredicateForField:(NSString*)field andDate:(NSDate*)date {
    
    NSDate *startDate = [date firstHourOfDayByAdding:0];
    NSDate *endDate = [date firstHourOfDayByAdding:1];
    
    return [NSPredicate predicateWithFormat:@"%K>=%@ and %K<%@", field, startDate, field, endDate];
}

-(BOOL)switchedToOldSync {
    return  (![self isFullSync] && [[DataRepository sharedInstance] useNewSyncJustAtBeggining] && !self.countCallDone);
}

-(BOOL)FFFilter {
    return NO;
}

- (NSString*)filterCodingFielValue {
    return nil;
}

- (NSString*)filterCodingFieldName {
    return nil;
}

@end
