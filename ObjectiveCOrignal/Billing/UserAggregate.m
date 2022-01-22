//
//  UserAggregate.m
//  Billing2
//
//  Created by .R.H. on 8/21/11.
//  Copyright 2011 RCO All rights reserved.
//

#import "DataRepository.h"
#import "UIUtility.h"
#import "UserAggregate.h"
#import "NSManagedObjectContext+Timing.h"
#import "BillingAppDelegate.h"
#import "Settings.h"
#import "ServerManager.h"

@interface Aggregate ()
@property (nonatomic, assign) BOOL isSyncingTimestampReset;
@end

@implementation UserSection 

@synthesize sectionHeader, usersArray;

-(id)initWithHeader:(NSString*)header andUsers:(NSArray*)userList{
	if ((self = [super init]) != nil){
		sectionHeader = header;
		usersArray = userList;
	}
	return self;
}


@end

@interface UserAggregate ()
@property (nonatomic, strong) NSMutableDictionary *usersDict;
@end

@implementation UserAggregate

- (id) init
{
    if ((self = [super init]) != nil){
		
        self.rcoObjectClass = @"User";
        self.localObjectClass = @"User";
        self.rcoRecordType = @"User";
        self.recordGroup = kPeopleGroup;
        //self.defaultImageSizes = [[NSArray alloc  ] initWithObjects:@"50", @"324", nil];
        self.defaultImageSizes = [NSArray arrayWithObjects:@"100", nil];
        _callsInfo = [NSMutableDictionary dictionary];
	}

	return self;
}

-(BOOL)overwriteRecord:(RCOObject*)obj {
    // local record is more important
    return NO;
}

- (BOOL)checkExistingItemBeforeInsertWhenDoingInitialSync {
    // 29.05.2017 we had issues when syncing Vendors ... so we need to check the item even when we do the initial full sync when the records should not be in the DB
    return YES;
}

-(void)moveUserToGroup:(NSString*)userId groupName:(NSString*)name {

 [[DataRepository sharedInstance] askTheCloudFor: US
                                         withMsg: MOVE_USER_TO_GROUP
                                      withParams: [NSString stringWithFormat:@"%@/%@/%@", userId, @"User", name]
                                       andObject: userId
                                      callBackTo:self];
}

-(void)createNewUser:(NSDictionary*)info {
    
    NSString *firstName = [info objectForKey:@"firstName"];
    NSString *lastName = [info objectForKey:@"lastName"];
    
   [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: CREATE_USER
                                         withParams: [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@/%@",
                                                      [info objectForKey:@"userGroupName"],
                                                      [info objectForKey:@"directoryName"],
                                                      lastName,
                                                      firstName,
                                                      [info objectForKey:@"loginClient"],
                                                      [info objectForKey:@"passwordClient"],
                                                      [info objectForKey:@"Role"]]
                                          andObject: [info objectForKey:@"objId"]
                                         callBackTo: self];
    
}


- (id ) createNewRecord: (RCOObject *) obj {
    User *user = (User*)obj;
    
    if (!obj) {
        [self showAlertMessage:@"User is invalid, please create new one. If the problem persists please contact RCO"];
        return nil;
    }

    NSString *CSVString = [user CSVFormat];
    if (!CSVString) {
        // if CSV string is nil we should delete the user, this is usually when the user was not saved, and we are trying to upload a user that was not saved. We should delete it
        [self destroyObj:user];
        [self save];
        return nil;
    } else {
        CSVString = [NSString stringWithFormat:@"\"%@\"", CSVString];
    }
    
    NSLog(@"User CSV format = %@", CSVString);
    NSData *data = [CSVString dataUsingEncoding:NSUTF8StringEncoding];

    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
//    return  [[DataRepository sharedInstance] tellTheCloud:US
//                                                  withMsg:SET_USERS
//                                               withParams:nil
//                                                 withData:data
//                                                 withFile:nil
//                                                andObject:obj.rcoObjectId
//                                               callBackTo:self];
}

- (id ) createNewRecordFromCSVString: (NSString *) objCSVString forObject:(RCOObject*)obj {
    NSString *CSVChanged = [NSString stringWithFormat:@"%@", objCSVString];
    
    CSVChanged = [CSVChanged stringByReplacingOccurrencesOfString:@"MobileRecordId" withString:obj.rcoMobileRecordId];
    
    NSData *data = [CSVChanged dataUsingEncoding:NSUTF8StringEncoding];
    
    return  [[DataRepository sharedInstance] tellTheCloud:US
                                                  withMsg:SET_USERS
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

#pragma mark -
#pragma mark Update Records

- (BOOL)shouldUpdateRecords {
    // we are not creating records we are just updating them, default value is NO
    // this overwrites the upload of records :(
    return YES;
}

- (BOOL)shouldUpdateRecordsAndUploadRecords {
    // this enables also uploading records, we should make the diddefence based on the record id
    return YES;
}

- (void)updateRecords {
    // this call is used to upload more than one record at once
    NSArray *uploadObjects = [self getObjectsToUpload];
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *recordIds = [NSMutableArray array];
    
    for (User *user in uploadObjects) {
        if ([user.rcoRecordId length] == 0) {
            /*
             23.07.2018 we should leave this package there, we will upload using SET call
             */
            NSLog(@"Upload %@ using SET call", user.rcoObjectId);
            continue;
        }
        NSString *updateString = [self getObjectCodingForUpload:user];
        if (!updateString) {
            continue;
        }
        [objects addObject:updateString];
        [recordIds addObject:user.rcoRecordId];
    }
    
    [self save];
    
    if ([objects count] == 0) {
        NSLog(@">>>>>>>No User Updates ");
        return;
    }
    
    NSString *updateStr = [objects componentsJoinedByString:@"\n"];
    
    NSLog(@">>>>>>>User Update stringggg = %@", updateStr);
    
    NSData *data = [updateStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[DataRepository sharedInstance] tellTheCloud:RD_S
                                          withMsg:R_S_C_1
                                       withParams:nil
                                         withData:data
                                         withFile:nil
                                        andObject:[recordIds componentsJoinedByString:@","]
                                       callBackTo:self];
}

-(void)updateObject:(RCOObject *)object {
    
    NSString *infoStr = [self getObjectCodingForUpload:object];
    [self updateObject:object withData:infoStr];
}

-(void)finalizeCreateNewObject:(RCOObject*)object {
    
    User *user = (User*)object;
    NSString *dataStr = [NSString stringWithFormat:@"ItemType,%@", user.itemType];
    [self updateObject:object withData:dataStr];
}


-(void)updateObject:(RCOObject *)object withData:(NSString*)dataStr {
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    if (object.rcoRecordId) {
        [self removeUserFromCaching:object.rcoRecordId];
        NSDictionary *userDict = [self getUserDictFromUserObject:(User*)object];
        [self addUserToCaching:userDict];
    }
    
    if ([object.rcoRecordId length]) {
        [object setNeedsUploading:YES];
        [self save];
        [[DataRepository sharedInstance] tellTheCloud:RD_S
                                              withMsg:R_S_C_1
                                           withParams:nil
                                             withData:data
                                             withFile:nil
                                            andObject:object.rcoObjectId
                                           callBackTo:self];
    } else {
        [[DataRepository sharedInstance] tellTheCloud:RD_S
                                              withMsg:R_S_C_1
                                           withParams:nil
                                             withData:data
                                             withFile:nil
                                            andObject:object.rcoObjectId
                                           callBackTo:self];
    }
}

- (void)getUpdatedRecordsCount {
    
    [self resetSyncType];
    NSString *params = [NSString stringWithFormat:@"%@/%d/%lld/+/+/+/ItemType/,/%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self.synchingTimeStamp longLongValue], self.rcoObjectClass];
    // 08.05.2019 use the new format for the timestamp
    params = [NSString stringWithFormat:@"%@/%d/%@/+/+/+/ItemType/,/%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self getTimestampParameter], self.rcoObjectClass];
    
    // 21.10.2019
    if ([self FFFilter]) {
        NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
        if (![[DataRepository sharedInstance] isTheSameUserLogged]) {
            // 21.10.2019 we should resetthe timestamp to get the new users filtered by Company
            if (!self.isSyncingTimestampReset) {
                [self resetTimestampParameter];
            }
        }
        params = [NSString stringWithFormat:@"%@/%d/%@/+/+/+/ItemType,Company/,/%@,%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self getTimestampParameter], self.rcoObjectClass, userCompany];
    } else {
        params = [NSString stringWithFormat:@"%@/%d/%@/+/+/+/ItemType/,/%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self getTimestampParameter], self.rcoObjectClass];
    }

    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F_C
                                         withParams: params
                                          andObject: nil
                                         callBackTo: self];
}

- (void)getChildrenDirectoryIdsForGroupId:(NSString*)groupId andType:(NSString*)type {
}

-(void)updateCurrentUserPosition {
    
    NSString *currentUserRecordId = [[DataRepository sharedInstance] getLoggedUserRecordId];
    if (!currentUserRecordId.length) {
        return;
    }
    
    NSMutableArray *fields = [NSMutableArray array];

    [fields addObject:[NSString stringWithFormat:@"Object ID"]];
    [fields addObject:[NSString stringWithFormat:@"%@", currentUserRecordId]];
    
    [fields addObject:[NSString stringWithFormat:@"Object Type"]];
    [fields addObject:[NSString stringWithFormat:@"%@", @"[[recordid]]"]];
    
    [fields addObject:@"Latitude"];
    [fields addObject:[NSString stringWithFormat:@"%f", [[[DataRepository sharedInstance] getCurrentLatitude] doubleValue]]];
        
    [fields addObject:@"Longitude"];
    [fields addObject:[NSString stringWithFormat:@"%f",[[[DataRepository sharedInstance] getCurrentLongitude] doubleValue]]];
    
    NSString *objData = [NSString stringWithFormat:@"\"%@\"", [fields componentsJoinedByString:@"\",\""]];
    
    NSLog(@"Latitude Longitude stringg = %@", objData);
    
    [[DataRepository sharedInstance] tellTheCloud:RD_S
                                          withMsg:R_S_C_1
                                       withParams: nil
                                         withData: [objData dataUsingEncoding:NSUTF8StringEncoding]
                                         withFile:nil
                                        andObject:currentUserRecordId
                                       callBackTo:nil];
}


- (Boolean) requestSyncRecords {
    if (!self.countCallDone) {
        [self getUpdatedRecordsCount];
    } else {
        
        [self setSyncType];

        NSString *params = [NSString stringWithFormat:@"%@/%d/%lld/+/+/+/ItemType/,/%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self.synchingTimeStamp longLongValue], self.rcoObjectClass];
        // 08.05.2019 use the new format for the timestamp
        params = [NSString stringWithFormat:@"%@/%d/%@/+/+/+/ItemType/,/%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self getTimestampParameter], self.rcoObjectClass];

        // 21.10.2019
        if ([self FFFilter]) {
            NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
            if (![[DataRepository sharedInstance] isTheSameUserLogged]) {
                // 21.10.2019 we should resetthe timestamp to get the new users filtered by Company
                if (!self.isSyncingTimestampReset) {
                    [self resetTimestampParameter];
                }
            }
            params = [NSString stringWithFormat:@"%@/%d/%@/+/+/+/ItemType,Company/,/%@,%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self getTimestampParameter], self.rcoObjectClass, userCompany];
        } else {
            params = [NSString stringWithFormat:@"%@/%d/%@/+/+/+/ItemType/,/%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, [self getTimestampParameter], self.rcoObjectClass];
        }
        [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                                withMsg: RD_G_R_U_X_F
                                             withParams: params
                                              andObject: nil
                                             callBackTo: self];
    }
    return YES;
}

- (Boolean) requestSync
{
    if ([[DataRepository sharedInstance] isNewSyncImplementation]) {
        if (![self isFullSync] && [[DataRepository sharedInstance] useNewSyncJustAtBeggining] && !self.countCallDone) {
            return [self requestSyncIds];
        }
        return [self requestSyncRecords];
    } else {
        return [self requestSyncIds];
    }
}

-(NSString *) getObjectCodingForUpload:(RCOObject*)object {
    
    return nil;
}


- (RCOObject*) syncObjectWithId: (NSString *) objId  andType: (NSString *) objType toValuesDictionary:(NSDictionary *)valuesDictionary
{
    User* user = (User *) [super syncObjectWithId: objId  andType: objType toValuesDictionary: valuesDictionary];
    
    user.rcoObjectClass = rcoObjectClass;
    return (RCOObject*) user;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue
{
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    
    User *user = (User *) object;
    
    if ([fieldName isEqualToString:@"First Name"]){
        user.firstname = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Last Name"]){
        user.surname = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Address1"]){
        user.address1 = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Address2"]){
        user.address2 = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Company"]){
        user.company = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"State"]){
        user.state = fieldValue;
    } 
    else if ([fieldName isEqualToString:@"ZipCode"]){
        user.zip = fieldValue;
    } 
    else if ([fieldName isEqualToString:@"City"]){
        user.city = fieldValue;
    } 
    else if ([fieldName isEqualToString:@"Telephone"]){
        user.phone = fieldValue;
    } 
    else if ([fieldName isEqualToString:@"MobilePhone"]){
        user.cell = fieldValue;
    } 
    else if ([fieldName isEqualToString:@"Sales Tax Rate RecordId"]){
        user.salesTaxRateRecordId = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Latitude"]){
        user.latitude = [NSNumber numberWithDouble: [fieldValue doubleValue]];
    }
    else if ([fieldName isEqualToString:@"Longitude"]){
        user.longitude =[NSNumber numberWithDouble: [fieldValue doubleValue]];
    }
    else if ([fieldName isEqualToString:@"ItemType"]){
        user.itemType = fieldValue;
    }    
    else if ([fieldName isEqualToString:@"Email"]){
        if ([fieldValue length] > 0) {
            user.email = fieldValue;
        }
    }
    else if ([fieldName isEqualToString:@"Lead Source"]){
        user.leadSource = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Referal"]){
        user.referal = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Growth"]){
        user.growth = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Followup"]){
        //user.followup = fieldValue;
    }    
    else if ([fieldName isEqualToString:@"Notes1"]){
        user.userNotes1 = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Notes2"]){
        user.userNotes2 = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Value"]){
        user.value = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Budget"]){
         }
    else if ([fieldName isEqualToString:@"Competitors"]){
        //user.competitors = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Approvers"]){
        //user.approvers = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Evaluators"]){
        //user.evaluators = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Job Type"]){
        user.jobType = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Chart Reference"]){
        user.chartRef = fieldValue;
    }
    else if ([fieldName isEqualToString:@"GPSLocationServices"]){
        user.sendGPSLocation = [NSNumber numberWithBool:[fieldValue boolValue]];
    }
    else if ([fieldName isEqualToString:@"Metric System"]){
        user.metricSystem = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Mailcode"]){
        user.mailcode = fieldValue;
    }
    else if ([fieldName isEqualToString:@"UserType"]){
        user.userType = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Title"]){
        user.title = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Driver License Number"]){
        user.driverLicenseNumber = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Driver License State"]){
        user.driverLicenseState = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Location"]){
        user.location = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Customer Number"]){
        
        BOOL sendDriverAlerts = NO;
        if ([user needsUploading]) {
            if ([user.customerNumber isEqualToString:fieldValue]) {
                // is the same value so we don't need to do anything
                NSLog(@">>> Customer number is the same value!!!");
                
                if (sendDriverAlerts) {
                    NSString*msg = [NSString stringWithFormat:@"Local Value Equal Customer number saved locally-%@ vs the new value-%@", user.customerNumber, fieldValue];
                    
                    [[DataRepository sharedInstance] sendAlertMessage:msg withTitle:[NSString stringWithFormat:@"!!!! Sync-3-%@-%@-%@", self.rcoObjectClass,  [[DataRepository sharedInstance] getLoggedUserRecordId], [[DataRepository sharedInstance] getLoggedUserLastName]]];
                }

            } else {
                
                NSInteger localCustomerNumber = [user.customerNumber integerValue];
                NSInteger newCustomerNumber = [fieldValue integerValue];
                
                if (localCustomerNumber > newCustomerNumber) {
                    NSLog(@">>> Customer number saved locally:%@ vs the new value:%@", user.customerNumber, fieldValue);
                    if (sendDriverAlerts) {
                        NSString*msg = [NSString stringWithFormat:@"Local Value Greater Customer number saved locally-%@ vs the new value-%@", user.customerNumber, fieldValue];
                        
                        [[DataRepository sharedInstance] sendAlertMessage:msg withTitle:[NSString stringWithFormat:@"!!! Sync-1-%@-%@-%@", self.rcoObjectClass,  [[DataRepository sharedInstance] getLoggedUserRecordId], [[DataRepository sharedInstance] getLoggedUserLastName]]];
                    }

                } else {
                    // the value that we get is greater, and we should use this one!
                    if (sendDriverAlerts) {
                        NSString*msg = [NSString stringWithFormat:@"Local Value Less Customer number saved locally-%@ vs the new value-%@", user.customerNumber, fieldValue];
                        
                        [[DataRepository sharedInstance] sendAlertMessage:msg withTitle:[NSString stringWithFormat:@"!!! Sync-2-%@-%@-%@", self.rcoObjectClass,  [[DataRepository sharedInstance] getLoggedUserRecordId], [[DataRepository sharedInstance] getLoggedUserLastName]]];
                    }
                }
            }
        } else {
            if (sendDriverAlerts) {
                NSString*msg = [NSString stringWithFormat:@"SaveCustomerNumber-%@-PrevValue-%@", fieldValue, user.customerNumber];
                
                [[DataRepository sharedInstance] sendAlertMessage:msg withTitle:[NSString stringWithFormat:@"Sync-%@-%@-%@", self.rcoObjectClass, [[DataRepository sharedInstance] getLoggedUserRecordId], [[DataRepository sharedInstance] getLoggedUserLastName]]];
            }

            user.customerNumber = fieldValue;
        }
    }
    else if ([fieldName isEqualToString:@"Employee Id"]){
        user.employeeNumber = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Status"]){
        user.status = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Client Name"]){
        user.clientName = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Client Number"]){
        user.clientNumber = fieldValue;
    }
    else if ([fieldName isEqualToString:@"UserIdent"]){
        user.userIdent = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Current User Identification"]){
        user.currentUserIdent = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Exempt Driver Status"]){
        user.driverELDExempt = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Driver Duty Status"]){
        user.driverDutyStatus = fieldValue;
        [user addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"IsActive"]){
        user.isActive = [NSNumber numberWithBool:[fieldValue boolValue]];
    }
    else if ([fieldName isEqualToString:@"Sex"]){
        user.sex = fieldValue;
    }
    else if ([fieldName isEqualToString:@"National Identifier"]){
        user.nationalIdentifier = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Driver License Class"]){
        user.driverLicenseClass = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Contact Name"]){
        user.contactName = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Middle Name"]){
        user.middleName = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Endorsements"]){
        user.endorsements = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Driver License Expiration Date"]){
        user.driverLicenseExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if ([fieldName isEqualToString:@"DOT Expiration Date"]){
        user.dOTExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Corrective Lens Required"]){
        user.correctiveLensRequired = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category1 Name"]){
        user.category1Name = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category1 Value"]){
        user.category1Value = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category2 Name"]){
        user.category2Name = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category2 Value"]){
        user.category2Value = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category3 Name"]){
        user.category3Name = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category3 Value"]){
        user.category3Value = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category4 Name"]){
        user.category4Name = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category4 Value"]){
        user.category4Value = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category5 Name"]){
        user.category5Name = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category5 Value"]){
        user.category5Value = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category6 Name"]){
        user.category6Name = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Category6 Value"]){
        user.category6Value = fieldValue;
    }
    
    
}

-(NSArray *) getAll
{
    return [self getAllUsers];
}

-(NSArray*)getAllTypesOfUsers {

    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    return array;
}

-(NSArray*)getAllUsers
{
    return [self getAllNarrowedBy: @"rcoObjectClass" withValue: self.rcoObjectClass sortedBy: nil];
}

- (NSPredicate *) subsetPredicate
{
    NSPredicate *includeClass = [NSPredicate predicateWithFormat: @"(rcoObjectClass = %@)", self.rcoObjectClass];
    NSPredicate *superPredicate = [super subsetPredicate];
    NSArray *subPredicates = [NSArray arrayWithObjects: includeClass, superPredicate, nil];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}


/*!
 Get the user for a given user number, or nil if not found
 */
-(User*)getUserForNumber:(NSString*)userNum
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(userNumber = %@)", userNum];
    
    // set up the sortkeys
    NSArray *array = [self getSomeNarrowedBy:predicate sortedBy: nil limitedTo:1];
    
    if( [array count] > 0)
    {
        return (User *) [array objectAtIndex:0];
    }
    return nil;
    
}

/*!
 Get the user for a given user number, or nil if not found
 */
-(UIImage*)getImageForUser:(NSString*)userNum size: (int) pels
{
    User* user=[self getUserForNumber: userNum];
    
    return [self getImageForObject:[user rcoObjectId] size: pels];
    
}

/*!
 Get the user for specified objectId, or nil if not found
 */
-(User*)getUserForId:(NSString*)userId
{
    
    if ([userId length] == 0) {
        return nil;
    }
    
    NSArray *array = [self getUsersMatchingId: userId];
    
    if( array && [array count] > 0)
    {
        return (User *) [array objectAtIndex:0];
    }
    return nil;
}

-(User*)getUserForRecordId:(NSString*)userRecordId
{
    
    if ([userRecordId length] == 0) {
        return nil;
    }
    
    //NSArray *array = [self getUsersMatchingId: userRecordId];
    NSArray *array = [self getUsersMatchingRecordId: userRecordId];
    
    if( array && [array count] > 0)
    {
        return (User *) [array objectAtIndex:0];
    }
    return nil;
}
-(User*)getUserWithEmployeeId:(NSString*)employeeId {

    if ([employeeId length] == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(employeeNumber = %@ AND rcoObjectClass = %@)", employeeId, self.rcoObjectClass];
    NSArray *res = [self getAllNarrowedBy: predicate andSortedBy: nil];

    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}

-(User*)getUserWithdDriverLicenseNumber:(NSString*)number andState:(NSString*)state {
    
    
    if ([number length] == 0) {
        return nil;
    }

    if ([state length] == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(driverLicenseState = %@ AND driverLicenseNumber = %@ AND rcoObjectClass = %@)", state, number, self.rcoObjectClass];
    NSArray *res = [self getAllNarrowedBy: predicate andSortedBy: nil];

    if (res.count > 0) {
        return [res objectAtIndex:0];
    }
    return nil;
}


/*!
 Get the users matching the specified userId, or nil if not found
 */
-(NSArray*)getUsersMatchingId:(NSString*)userId
{
    
    
    if ([userId length] == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(rcoObjectId = %@ AND rcoObjectClass = %@)", userId, self.rcoObjectClass];
    
    // set up the sortkeys
    // NSMutableArray *sortDescriptors = nil;
    
    return [self getAllNarrowedBy: predicate andSortedBy: nil];
    
}

-(NSArray*)getUsersMatchingRecordId:(NSString*)recordId
{
    
    if ([recordId length] == 0) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(rcoRecordId = %@ AND rcoObjectClass = %@)", recordId, self.rcoObjectClass];
    
    // set up the sortkeys
    // NSMutableArray *sortDescriptors = nil;
    
    return [self getAllNarrowedBy: predicate andSortedBy: nil];
    
}

-(NSArray*)getUsersForCompany:(NSString*)company {
    
    
    if ([company length] == 0) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(company = %@ AND rcoObjectClass = %@)", company, self.rcoObjectClass];
    
    return [self getAllNarrowedBy: predicate andSortedBy: nil];

}

-(NSArray*)getAllUsersGroupedAlphabetically{
	NSArray* userList = [self getAllUsers];
	
	NSMutableArray* result = [NSMutableArray array];
	
	UserSection* section = nil;
	NSMutableArray* currentUserList = nil;
	
	for (User* user in userList) {
		unichar firstChar = [user.surname characterAtIndex:0];
		if ((section==nil)||(firstChar != [section.sectionHeader characterAtIndex:0])) {
			//new section
			currentUserList = [NSMutableArray array];
			section = [[UserSection alloc] initWithHeader:[NSString stringWithFormat:@"%c", firstChar] andUsers:currentUserList];
			[result addObject:section];
		}
		[currentUserList addObject:user];
	}
	
	return result;
}


-(NSArray*)getUsersMatchingName:(NSString*)name {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rcoObjectClass = %@ AND (firstname contains[cd] %@) OR (surname contains[cd] %@))", self.rcoObjectClass, name, name];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"rcoObjectId" ascending:YES];
	
	
    NSArray *array= [self getAllNarrowedBy: predicate andSortedBy: [NSArray arrayWithObject:sortDescriptor]];
    // make sure that we sort objects by rcoObjectId
    array = [array sortedArrayUsingDescriptors:[self getObjectIdSortDescriptor:YES]];
    
    return array;
}

-(NSArray*)getUsersMatchingFullName:(NSString*)name {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rcoObjectClass = %@ AND (firstname contains[cd] %@) OR (surname contains[cd] %@))", self.rcoObjectClass, name, name];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"rcoObjectId" ascending:YES];
	
	
    NSArray *array= [self getAllNarrowedBy: predicate andSortedBy: [NSArray arrayWithObject:sortDescriptor]];
    // make sure that we sort objects by rcoObjectId
    array = [array sortedArrayUsingDescriptors:[self getObjectIdSortDescriptor:YES]];
    
    return array;
}

- (User *) getAnyUserWithRecordId: (NSString *) recordId {
    
    if ([recordId length] == 0) {
        return nil;
    }
    __block NSArray *array = nil;
    
    [self.moc performBlockAndWait:^{
    
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        // this method searches through all users for the recordId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"rcoRecordId", recordId];

        [request setEntity:entityDescription];
        [request setPredicate:predicate];
    
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (User *) getAnyUserWithEmployeeId: (NSString *) employeeNumber {
    
    if ([employeeNumber length] == 0) {
        return nil;
    }
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        // this method searches through all users for the recordId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"employeeNumber", employeeNumber];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}


- (User *) getAnyUserWithObjectId: (NSString *) recordId {
    
    if ([recordId length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        // this method searches through all users for the recordId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"rcoObjectId", recordId];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (User *) getAnyUserWithNumber: (NSString *) customerNumber {
    
    if ([customerNumber length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [self.moc performBlockAndWait:^{
        // this method searches through all users for the recordId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"customerNumber", customerNumber];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];

    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}


- (User *) getAnyUserWithCompanyName: (NSString *) companyName {
    
    if ([companyName length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    [[self moc] performBlockAndWait:^{
        // this method searches through all users for the recordId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"company", companyName];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (User *) getAnyUserWithFirstName: (NSString *) firstName andType:(NSString*)userType {
    
    
    if ([firstName length] == 0) {
        return nil;
    }
    
    if ([userType length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K ==[c] %@) and (%K ==[c] %@) ", @"firstname", firstName,  @"userType", userType];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (User *) getAnyUserWithFirstName: (NSString *) firstName lastName:(NSString*)lastName andType:(NSString*)userType {
    
    
    if ([firstName length] == 0) {
        return nil;
    }
    
    if ([lastName length] == 0) {
        return nil;
    }

    if ([userType length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K ==[c] %@) and (%K ==[c] %@) and (%K ==[c] %@) ", @"surname", lastName,  @"firstname", firstName,  @"userType", userType];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (User *) getAnyUserWithFirstName: (NSString *) firstName andLastName:(NSString*)lastName {
    
    
    if ([firstName length] == 0) {
        return nil;
    }

    if ([lastName length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K ==[c] %@) and (%K ==[c] %@)", @"surname", lastName,  @"firstname", firstName];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (User *) getAnyUserWithDriverLicenseNumber: (NSString *) number andDriverLicenseState:(NSString*)state {
    
    
    if ([number length] == 0) {
        return nil;
    }

    if ([state length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"driverLicenseNumber=%@ and driverLicenseState=%@", number, state];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}


- (User *) getAnyUserWithLastName: (NSString *) lastName {
    
    if ([lastName length] == 0) {
        return nil;
    }
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        // this method searches through all users for the lastname
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"surname", lastName];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (User *) getAnyUserWithFirstName: (NSString *) firstName {
    
    if ([firstName length] == 0) {
        return nil;
    }
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        // this method searches through all users for the recordId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"firstname", firstName];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray *) getAnyUsersWithEmails: (NSArray *) emails {
    if ([emails count] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K IN %@)", @"email", emails];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    return array;
}

- (User *) getAnyUserWithEmail: (NSString *) email {
    
    if ([email length] == 0) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        // this method searches through all users for the recordId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K = %@)", @"email", email];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [self.moc executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
    }];
    
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

-(NSArray*)getAllUsersWithIds:(NSArray*)ids  {
    if (!ids.count ) {
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[self moc] performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(%K IN %@ )", @"rcoObjectId", ids];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[self moc]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setRelationshipKeyPathsForPrefetching:@[@"rcoObjectId"]];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        array = [[self moc] executeFetchRequest:request error:&error DATABASE_ACCESS_TIMING_ARGS ];
        if (error) {
            NSLog(@"ERROR = %@", error);
        }
    }];
    
    return array;
}

#pragma mark

- (void) syncStep
{
    if (false && self.syncStatus == SYNC_STATUS_CODING_COMPLETE)
    {
        NSArray *users = [self getAll];
        for( User *user in users) {
            if( [user.latitude floatValue] == 0.0 && [user.longitude  floatValue] == 0.0 ) {
                [self geocodeAddress:user.address1
                              inCity:user.city
                             inState:user.state
                             withZip:user.zip
                              forObj:user.rcoObjectId];

            }
        }
        
    }
    
    [super syncStep];
}

#pragma mark - ASI Request callbacks

- (void)requestFinished:(id )request
{
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSInteger responseStatusCode = [[self getErrorFromRequestResponse:request] integerValue];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString:GET_USER_GROUP_MEMBERS]) {
        NSLog(@"");
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        id respObject = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
    } else if ([msg isEqualToString:DELETE_USER_FROM_FUNCTIONAL_GROUP]) {
        NSLog(@"");
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        id respObject = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
    } else if ([msg isEqualToString:ADD_USER_TO_FUNCTIONAL_GROUP]) {
        NSLog(@"");
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        id respObject = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];

    } else if ([msg isEqualToString:GET_FUNCTIONAL_GROUP_MEMBERS]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        id respObject = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        NSLog(@"");
    } else if ([msg isEqualToString:CREATE_FUNCTIONAL_GROUP]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        id respObject = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        NSLog(@"");
    } else if ([msg isEqualToString:CREATE_USER_GROUP]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        id respObject = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];

     } else if ([msg isEqualToString: RD_G_R_U_X_F]) {

        NSString *objId = [msgDict objectForKey:@"objId"];

        if ([objId isEqualToString:UserFunctionalGroupRecords] || [objId isEqualToString:UserGroupRecords] || [objId isEqualToString:UserWithDriverLicenseNumberAnState]) {
            id respObject = nil;
            
            NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];

            if ([request isKindOfClass:[NSDictionary class]]) {
                respObject = [request objectForKey:RESPONSE_OBJ];
            }
            
            if (respObject) {
                [result setObject:respObject forKey:RESPONSE_OBJ];
            }
            
            [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        } else {
            return [super requestFinished:request];
        }
    
    } else if ([msg isEqualToString: MOVE_USER_TO_GROUP]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        id respObject = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
    }
    else if ([msg isEqualToString:SET_USERS]) {
        
        NSString *rcoObjectId = [self parseSetRequest:request];

        if ([self isObjectIdValid:rcoObjectId]) {
            
            [[self moc] performBlockAndWait:^{
                RCOObject *user = [self getObjectWithId:rcoObjectId];
                
                // we should upload the image of the user also
                if ([user.fileNeedsUploading boolValue]) {
                    [self uploadRecordContent:user];
                }

                [self save];
            
                NSString *orgPrefix = [[DataRepository sharedInstance] getOrgPrefix];
            
                if (![[orgPrefix lowercaseString] hasPrefix:@"wp"] )  {
                    [self updateObject:user];
                } else {
                    NSLog(@"Is westpak");
                }
            }];

            NSMutableDictionary *respDict = [NSMutableDictionary dictionary];
            [respDict addEntriesFromDictionary:msgDict];
            
            [respDict setObject:rcoObjectId forKey:@"objId"];
            
            [self dispatchToTheListeners:kObjectUploadComplete withObjectId:rcoObjectId];
            
            [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:respDict withArg2:nil];
        } else if ([rcoObjectId isEqualToString:RESPONSE_INTERNAL_ERROR]){
            [self dispatchToTheListeners:kRequestFailedForMessage withArg1:msgDict withArg2:nil];
        }
        
        return;
    }
    else if ([msg isEqualToString:CREATE_USER]) {
        
        NSArray* respArray = [request objectForKey:RESPONSE_OBJ];
        
        NSMutableDictionary *respDict = [NSMutableDictionary dictionary];
        [respDict addEntriesFromDictionary:msgDict];
        
        RCOObject *user= [self getObjectWithId: [msgDict objectForKey:@"objId"]];
        
        NSLog(@" message dict = %@", msgDict);
        
        if (![respArray isKindOfClass:[NSArray class]] || (responseStatusCode == 500)) {
            
            NSLog(@" Response = %@", respArray);
            
            NSString *message = [NSString stringWithFormat:@"Failed to create user with email address: %@  . Please make sure that this email address is not already in use", ((User*)user).email];
            
            [self performSelectorOnMainThread:@selector(showMessage:) withObject:message waitUntilDone:NO];
            
            return;
        }
        
        if (respArray != nil) {
            NSDictionary *respDict = [respArray objectAtIndex:0];
            
            if (respDict) {
                user.rcoObjectId = [[respDict objectForKey:@"objectId"] stringValue];
                user.rcoObjectType = [respDict objectForKey:@"objectType"];
                
                [self save];
                [self updateObject:user];
            }
        }
        
        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:user.rcoObjectId];

        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:respDict withArg2:nil];

    } else if ([msg isEqualToString:R_S_C_1]) {
        NSMutableDictionary *respDict = nil;
        NSString *objId = nil;
        if ([request isKindOfClass:[NSDictionary class]]) {
            respDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)request];
            NSArray *objects = [respDict objectForKey:@"responseObj"];
            
            for (NSDictionary *dict in objects) {
                NSDictionary *mapCodingInfo = [dict objectForKey:@"mapCodingInfo"];
                NSString *recordId = [mapCodingInfo objectForKey:@"RecordId"];
                NSString *status = [mapCodingInfo objectForKey:@"Status"];
                NSLog(@">>>>>Status:%@", status);
                [[self moc] performBlockAndWait:^{
                    User *user = (User*)[self getObjectWithRecordId:recordId];
                    [user setNeedsUploading:NO];
                }];
            }
            [self save];
            objId = [[respDict objectForKey:@"responseUserInfo"] objectForKey:@"objId"];
        }
        
        [respDict addEntriesFromDictionary:msgDict];

        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:objId];
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:respDict withArg2:nil];
    } else {
        [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request
{
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    // only respond to user messages here
    if( ![[msgDict objectForKey:@"messageClass"] isEqualToString: US]) {
        [super requestFailed:request];
        return;
    }
    
    [self dispatchToTheListeners:kRequestFailedForMessage withArg1:msgDict withArg2:nil];
    
    if ([msg isEqualToString:DELETE_USER_FROM_FUNCTIONAL_GROUP]) {
        NSLog(@"");
    } else if ([msg isEqualToString:ADD_USER_TO_FUNCTIONAL_GROUP]) {
        NSLog(@"");
    } else if ([msg isEqualToString:GET_FUNCTIONAL_GROUP_MEMBERS]) {
        NSLog(@"");
    } else if ([msg isEqualToString:CREATE_FUNCTIONAL_GROUP]) {
        NSLog(@"");
    } else if ([msg isEqualToString:CREATE_USER_GROUP]) {
        NSLog(@"");
    } else if ([msg isEqualToString:R_S_C_1]) {
        NSLog(@"");
    } else if([msg isEqualToString: MOVE_USER_TO_GROUP] ) {
        NSLog(@"MOVE USER TO GROUP FAILED   response: %@ ",[request responseString]);
    }
    else {
        [super requestFailed:request];
    }
}

#pragma mark Caching 

-(void)loadUsersToCaching {
    
    NSLog(@"Load all users (%@) ", self.rcoObjectClass);

    __block NSMutableDictionary *usersDictTmp = [NSMutableDictionary dictionary];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPersistentStoreCoordinator *coordinator = [[DataRepository sharedInstance] persistentStoreCoordinator];
    
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    
    if (coordinator != nil) {
        
        NSManagedObjectContext *context = [threadDict objectForKey:kMobileOfficeKey_MOC];
       if( context == nil ) {
            context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
           
           [context performBlockAndWait:^{
               NSManagedObjectContext *parentContext = [DataRepository sharedInstance].masterSaveContext;
               [context setParentContext:parentContext];
               [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
           }];

           if (![NSThread isMainThread]) {
               /*
                21.03.2016, we should not set if is the main thread, it can invalidate the context
                */
               [threadDict setObject:context forKey:kMobileOfficeKey_MOC];
           }
        }
       else {
       }
        
        [context performBlockAndWait:^{
            // Edit the entity name as appropriate.
            NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setIncludesSubentities:NO];
            [fetchRequest setResultType:NSDictionaryResultType];
            
            NSMutableArray *allFields = [NSMutableArray array];
            
            [allFields addObject:@"rcoRecordId"];
            [allFields addObject:@"rcoObjectId"];
            [allFields addObject:@"rcoObjectType"];
            
            [allFields addObject:@"address1"];
            [allFields addObject:@"address2"];
            [allFields addObject:@"city"];
            [allFields addObject:@"company"];
            [allFields addObject:@"email"];
            [allFields addObject:@"state"];
            [allFields addObject:@"zip"];
            [allFields addObject:@"firstname"];
            [allFields addObject:@"surname"];
            
            fetchRequest.propertiesToFetch = [NSArray arrayWithArray:allFields];
            
            NSArray *sortDescriptors = [self sortDescriptors];
            
            if (nil != sortDescriptors) {
                [fetchRequest setSortDescriptors:sortDescriptors];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                        managedObjectContext:context
                                                                                                          sectionNameKeyPath:[self sectionNameKeyPath]
                                                                                                                   cacheName:nil];
            NSError *error = nil;
            
            NSPredicate *finalPredicate = [NSPredicate predicateWithFormat:@"itemType ==[c] %@", self.rcoObjectClass];
            
            finalPredicate = nil;
            
            if (finalPredicate) {
                [aFetchedResultsController.fetchRequest setPredicate:finalPredicate];
            }
            
            NSLog(@"fetch get all users --- start: %@--%@", self, [NSThread currentThread]);
            
            [aFetchedResultsController performFetch:&error DATABASE_ACCESS_TIMING_ARGS];
            
            NSArray *fetchedObjects = aFetchedResultsController.fetchedObjects;
            
            NSLog(@"found %d ---  ", (int)fetchedObjects.count);
            
            for (NSDictionary *userDict in fetchedObjects) {
                
                NSString *rcoRecordId = [userDict objectForKey:@"rcoRecordId"];
                
                if (rcoRecordId) {
                    [usersDictTmp setObject:userDict forKey:rcoRecordId];
                }
            }
            
            NSLog(@"fetch get all items --- end");
            NSLog(@"Record ids = %d", (int)[[usersDictTmp allKeys] count]);
            
            NSLog(@"Users (%@) = %d", self.rcoObjectClass, (int)[fetchedObjects count]);
        }];
    }
    
    [self performSelectorOnMainThread:@selector(setUsersDict:)
                           withObject:usersDictTmp
                        waitUntilDone:NO];
}

-(NSDictionary*)getUserDictFromUserObject:(User*)userObject {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (userObject.rcoRecordId) {
        [dict setObject:userObject.rcoRecordId forKey:@"rcoRecordId"];
    }
    if (userObject.rcoObjectId) {
        [dict setObject:userObject.rcoObjectId forKey:@"rcoObjectId"];
    }
    if (userObject.rcoObjectType) {
        [dict setObject:userObject.rcoObjectType forKey:@"rcoObjectType"];
    }
    if (userObject.address1) {
        [dict setObject:userObject.address1 forKey:@"address1"];
    }
    if (userObject.address2) {
        [dict setObject:userObject.address2 forKey:@"address2"];
    }
    if (userObject.city) {
        [dict setObject:userObject.city forKey:@"city"];
    }
    if (userObject.company) {
        [dict setObject:userObject.company forKey:@"company"];
    }
    if (userObject.email) {
        [dict setObject:userObject.email forKey:@"email"];
    }
    if (userObject.state) {
        [dict setObject:userObject.state forKey:@"state"];
    }
    if (userObject.zip) {
        [dict setObject:userObject.zip forKey:@"zip"];
    }
    if (userObject.firstname) {
        [dict setObject:userObject.firstname forKey:@"firstname"];
    }
    if (userObject.surname) {
        [dict setObject:userObject.surname forKey:@"surname"];
    }

    return dict;
}

-(NSDictionary*)getUserDictForRecordId:(NSString*)userRecordId {
    
    
    if ([userRecordId length] == 0) {
        return nil;
    }
    return [self.usersDict objectForKey:userRecordId];
}

-(void)removeUserFromCaching:(NSString*)userRecordId {
    if (userRecordId) {
        [self.usersDict removeObjectForKey:userRecordId];
    }
}

-(void)addUserToCaching:(NSDictionary*)userDict {
    NSString *userRecordId = [userDict objectForKey:@"rcoRecordId"];
    if (userRecordId) {
        [self.usersDict setObject:userDict forKey:userRecordId];
    }
}

- (NSArray*) sortDescriptors
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rcoObjectId" ascending:YES];
    
    return [NSArray arrayWithObjects:sortDescriptor, nil];
}

- (NSString*) sectionNameKeyPath;
{
    return @"rcoObjectId";
}

- (NSString*) entityName
{
    return @"User";
}

#pragma mark Helping Methods

// custom designed

-(NSString*)getUpdateAddress1:(NSString*)address1 forRecordId:(NSString*)recordId {
    
    NSMutableArray *fields = [NSMutableArray array];
    
    if (recordId) {
        [fields addObject:[NSString stringWithFormat:@"Object ID"]];
        [fields addObject:[NSString stringWithFormat:@"%@", recordId]];
    }
    
    [fields addObject:[NSString stringWithFormat:@"Object Type"]];
    [fields addObject:[NSString stringWithFormat:@"%@", @"[[recordid]]"]];
    
    if (address1) {
        [fields addObject:[NSString stringWithFormat:@"Address1"]];
        [fields addObject:[NSString stringWithFormat:@"%@", address1]];
    }
    
    NSString *userString = [fields componentsJoinedByString:@"\",\""];
    userString = [NSString stringWithFormat:@"\"%@\"", userString];
    
    NSLog(@" UESR UPDATE Address STRING : %@", userString);
    
    return userString;
}

#pragma mark FunctionalGroup Methods

-(void)getFunctionalGroupsforCompany:(NSString*)companyName {
    NSString *params = nil;
    
    if (companyName.length) {
        params = [NSString stringWithFormat:@"%@/-10000/%d/+/+/+/Company/,/%@/,/+/+", @"Functional Group", (int)0, companyName];
    } else {
        params = [NSString stringWithFormat:@"%@/-10000/%d/+/+/+/+/,/+/,/+/+", @"Functional Group", (int)0];
    }
    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: UserFunctionalGroupRecords
                                         callBackTo: self];
}

-(void)getRMSUserWithDriverLicenseNumber:(NSString*)driverLicenseNumber andState:(NSString*)driverLicenseState {
        
    NSString *params = [NSString stringWithFormat:@"%@/%d/%@/+/+/+/Driver License Number,Driver License State/,/%@,%@/,/+/+", self.rcoRecordType, -BATCH_SIZE, @"0", driverLicenseNumber, driverLicenseState];
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: UserWithDriverLicenseNumberAnState
                                         callBackTo: self];
    
    
}


-(void)createFunctionalGroup:(NSString*)groupName forCompany:(NSString*)company {
    
    
    if (!groupName.length) {
        return;
    }
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *params = nil;
    if (company.length) {
        params = [NSString stringWithFormat:@"%@/%@/", groupName, company];
    } else {
        params = [NSString stringWithFormat:@"%@/%@/", groupName, organizationName];
    }
    
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: CREATE_FUNCTIONAL_GROUP
                                         withParams: params
                                          andObject: groupName
                                         callBackTo: self];
}

-(void)getFunctionalGroupMembers:(NSString*)groupName {
    
    
    if (!groupName.length) {
        return;
    }
  /*
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *params = [NSString stringWithFormat:@"%@/%@/", groupName, organizationName];
*/
    
    NSString *params = [NSString stringWithFormat:@"%@/+/", groupName];

    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: GET_FUNCTIONAL_GROUP_MEMBERS
                                         withParams: params
                                          andObject: groupName
                                         callBackTo: self];
}

-(void)getUserGroupMembers:(NSString*)groupName {
    
    
    if (!groupName.length) {
        return;
    }
    
    NSString *params = [NSString stringWithFormat:@"%@/+/", groupName];
    
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: GET_USER_GROUP_MEMBERS
                                         withParams: params
                                          andObject: groupName
                                         callBackTo: self];
}



-(void)addUser:(NSString*)userRecordId toFunctionalGroup:(NSString*)groupName {
    
    
    if (!userRecordId.length || !groupName.length) {
        return;
    }
    // parameter 2 is the userObjectId ... maybe is better to use the recordId. We will change if necessary
    NSString *params = [NSString stringWithFormat:@"%@/%@/%@/", groupName, @"+", userRecordId];
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: ADD_USER_TO_FUNCTIONAL_GROUP
                                         withParams: params
                                          andObject: userRecordId
                                         callBackTo: self];
}

-(void)deleteUser:(NSString*)userRecordId fromFunctionalGroup:(NSString*)groupName {
    
    
    if (!userRecordId.length || !groupName.length) {
        return;
    }
    // parameter 2 is the userObjectId ... maybe is better to use the recordId. We will change if necessary
    NSString *params = [NSString stringWithFormat:@"%@/%@/%@/", groupName, @"+", userRecordId];
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: DELETE_USER_FROM_FUNCTIONAL_GROUP
                                         withParams: params
                                          andObject: userRecordId
                                         callBackTo: self];
}

#pragma mark UserGroupMethods

-(void)getUserGroupsForCompany:(NSString*)company {
    NSString *organizationNumber = [Settings getSetting:CLIENT_ORGANIZATION_ID];
    NSString *params = nil;
    
    if (company.length) {
        params = [NSString stringWithFormat:@"%@/-10000/%d/+/+/+/Organization Number,Company/,/%@,%@/,/+/+", @"User Group", (int)0, organizationNumber, company];
    } else {
        params = [NSString stringWithFormat:@"%@/-10000/%d/+/+/+/Organization Number/,/%@/,/+/+", @"User Group", (int)0, organizationNumber];

    }
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: UserGroupRecords
                                         callBackTo: self];
}

-(void)createNewUserGroup:(NSString*)groupName forCompany:(NSString*)company{
    if (!groupName.length) {
        return;
    }
    if (!company.length) {
        company = @"+";
    }
    [[DataRepository sharedInstance] askTheCloudFor: US
                                            withMsg: CREATE_USER_GROUP
                                         withParams: [NSString stringWithFormat:@"%@/+/+/%@", groupName, company]
                                          andObject: groupName
                                         callBackTo: self];
}


@end
