//
//  NotesAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 1/4/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import "NotesAggregate.h"
#import "DataRepository.h"
#import "RCOObject+RCOObject_Imp.h"
#import "Note+CoreDataClass.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"
#import "NSManagedObjectContext+Timing.h"
#import "BillingAppDelegate.h"

@implementation NotesAggregate

- (id) init
{
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"Note";
        self.rcoObjectClass = @"Note";
        self.rcoRecordType = @"Note";
        self.frontLoadImages = false;
        self.aggregateRight = kTrainingRight;
        _callsInfo = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Synchronization

- (Boolean) requestSync {
    
    NSString *timestamp = @"99999999999999";
    NSString *params = [NSString stringWithFormat:@"%@/-%d/%@/+/+/+/%@/,/%@/,/+/+", self.rcoRecordType, BATCH_SIZE, timestamp, @"HeaderBarcode", @"1"];
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: nil
                                         callBackTo:self];

    return YES;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue
{
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    
    Note *note = (Note *) object;

    if ([fieldName isEqualToString:@"Location"]) {
        note.name = fieldValue;
        [note addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Title"]) {
        note.title = fieldValue;
        [note addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"HeaderObjectId"]) {
        note.parentObjectId = fieldValue;
    }
    else if ([fieldName isEqualToString:@"HeaderObjectType"]) {
        note.parentObjectType = fieldValue;
    }
    else if ([fieldName isEqualToString:@"HeaderBarcode"]) {
        note.parentBarcode = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Notes"]) {
        note.notes = fieldValue;
        [note addSearchString:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Latitude"]) {
        note.latitude = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Longitude"]) {
        note.longitude = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DateTime"] ) {
        note.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Category"]) {
        note.category = fieldValue;
        [note addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString: @"UserRecordId"] )
    {
        object.creatorRecordId = fieldValue;
    }
    else if( [fieldName isEqualToString: @"CreatorRecordId"] )
    {
        NSLog(@"");
    }
}

- (void)getNotesForMasterBarcode:(NSString*)masterBarcode {
    NSString *params = [NSString stringWithFormat:@"%@/-%d/%lld/+/+/+/%@/,/%@/,/+/+", self.rcoRecordType, BATCH_SIZE,  [self.synchingTimeStamp longLongValue], @"HeaderBarcode", masterBarcode];

    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: masterBarcode
                                         callBackTo: self];
}

- (id ) createNewRecord: (RCOObject *) obj forced:(NSNumber*)forced{
    Note *note = (Note *) obj;
    
    if (!obj) {
        [self showAlertMessage:@"NOTE is invalid, please create new one. If the problem persists please contact RCO"];
        return nil;
    }
    
    [self addSync];
    
    NSString *noteInfo = [note CSVFormat];
    
    NSData *data = [noteInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    if ([note.parentObjectId integerValue] == 0) {
        if (note.parentObjectType) {
            Aggregate *parentAgg = [[DataRepository sharedInstance] getAggregateForClass:note.parentObjectType];
            RCOObject *obj = [parentAgg getObjectMobileRecordId:note.parentObjectId];
            
            if ([obj existsOnServerNew]) {
                note.parentObjectId = obj.rcoObjectId;
                note.parentObjectType = obj.rcoObjectType;
                note.parentBarcode = obj.rcoBarcode;
                [self save];
                noteInfo = [note CSVFormat];
                data = [noteInfo dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                return nil;
            }
        }
    }
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:forced forKey:@"forced"];
    
    return  [[DataRepository sharedInstance] tellTheCloud:B_S
                                                  withMsg:SN
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self
                                                extraInfo:extraInfo];
}

- (id ) createNewRecord: (RCOObject *) obj {
    Note *note = (Note *) obj;
    
    if (!obj) {
        return nil;
    }
    
    [self addSync];
    
    NSString *noteInfo = [note CSVFormat];
    
    NSData *data = [noteInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    [obj setNeedsUploading:YES];
    [self save];

    if ([note.parentObjectId integerValue] == 0) {
        // the parent was not saved in the system. we should search and update the record
        if (note.parentObjectType) {
            Aggregate *parentAgg = [[DataRepository sharedInstance] getAggregateForClass:note.parentObjectType];
            RCOObject *obj = [parentAgg getObjectMobileRecordId:note.parentObjectId];
            
            if ([obj existsOnServerNew]) {
                note.parentObjectId = obj.rcoObjectId;
                note.parentObjectType = obj.rcoObjectType;
                note.parentBarcode = obj.rcoBarcode;
                [self save];
                noteInfo = [note CSVFormat];
                data = [noteInfo dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                // the parent was not saved yet on RMS
                return nil;
            }
        }
    }
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];

    return  [[DataRepository sharedInstance] tellTheCloud:B_S
                                                  withMsg:SN
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

- (void)requestFinished:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    NSString *objId = [msgDict objectForKey:@"objId"];
    
    if ([msg isEqualToString:RD_G_R_U_F] && ([objId length] > 0)) {
        
        NSError *error = nil;
        NSArray* fieldValues = [self JSONArrayFromRequestResponse:request error:&error];
        
        NSMutableArray *photosObjects = [NSMutableArray array];
        
        NSString *parentTreeId = nil;
        
        for (NSDictionary *noteDict in fieldValues) {
            
            if (![noteDict isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            id objId = [noteDict objectForKey:@"objectId"];
            if (!objId) {
                objId = [noteDict objectForKey:@"LobjectId"];
            }
            
            NSString *objectId = [NSString stringWithFormat:@"%@", objId];
            
            NSString *objectType = [noteDict objectForKey:@"objectType"];
            NSString *mobileRecordId = [noteDict objectForKey:@"mobileRecordId"];
            
            RCOObject *obj = [self getObjectWithId:objectId];
            
            if (!obj) {
                obj = [self createNewObject];
                [[self moc] performBlockAndWait:^{
                    [obj setRcoObjectId:objectId];
                    [obj setRcoObjectType:objectType];
                    [obj setRcoMobileRecordId:mobileRecordId];
                }];
            }
            
            NSDictionary *mapCodingInfo = [noteDict objectForKey:@"mapCodingInfo"];
            NSArray *keys = mapCodingInfo.allKeys;
            
            [[self moc] performBlockAndWait:^{
                for (NSString *key in keys) {
                    NSString *val = [mapCodingInfo objectForKey:key];
                    [self syncObject:obj withFieldName:key toFieldValue:val];
                }
            }];
            
            [self save];
            
            if (objId) {
                [photosObjects addObject:objId];
            }
        }
        
        NSMutableDictionary *respDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        if (fieldValues.count) {
            [respDict setObject:fieldValues forKey:@"photos"];
        }
        [respDict setObject:photosObjects forKey:@"photosObjects"];
        
        if (parentTreeId) {
            [respDict setObject:parentTreeId forKey:@"parentTreeId"];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:respDict withArg2:nil];
        
    } else if([msg isEqualToString: SN] ) {
        NSString *rcoObjectId = [self parseSetRequest:request];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        RCOObject *obj = [self getObjectWithId:rcoObjectId];
        
        if (rcoObjectId) {
            [result setObject:rcoObjectId forKey:@"objId"];
        }
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:rcoObjectId];
        
    } else {
        return [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request
{
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    NSString *msg = [msgDict objectForKey:@"message"];
    if([msg isEqualToString: SN] ) {
        NSLog(@"");
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    } else if ([msg isEqualToString:RD_G_R_U_F]) {
        
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:msgDict withArg2:nil];
    }
    return [super requestFailed:request];
}

-(NSArray*)getNotesForObject:(RCOObject*)obj {
    
    
    return [self getNotesForObject:obj andDate:nil];
    
}

-(NSArray*)getNotesForObject:(RCOObject*)obj andCategory:(NSString*)category {
    NSPredicate *predicate = nil;
    
    if (!obj) {
        return nil;
    }
    
    if (category.length == 0) {
        return nil;
    }
    
    if ([obj.rcoObjectId length]) {
        // old way of getting notes
        if ([obj existsOnServerNew]) {
            predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@) and (parentObjectType = %@)", obj.rcoObjectId, obj.rcoObjectType];
        } else {
            predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@) and (parentObjectType = %@)", obj.rcoObjectId, obj.rcoObjectClass];
        }
    } else if ([obj.rcoRecordId length]){
        predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@)", obj.rcoRecordId];
    } else {
        return nil;
    }
    
    
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat: @"category=%@", category];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, datePredicate, nil]];
    
    NSArray *array = [self getAllNarrowedBy: predicate andSortedBy: nil];
    
    return array;
}

-(NSArray*)getNotesForObjectId:(NSString*)objId {
    if ([objId length] == 0) {
        return nil;
    }
    NSPredicate *predicate = nil;
    predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@)", objId];

    NSArray *array = [self getAllNarrowedBy: predicate andSortedBy: nil];
    
    return array;
}

-(NSArray*)getNotesForObject:(RCOObject*)obj andDate:(NSDate*)date {
    
    NSPredicate *predicate = nil;
    
    if ([obj.rcoObjectId length]) {
        // old way of getting notes
        if ([obj existsOnServerNew]) {
            predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@) and (parentObjectType = %@)", obj.rcoObjectId, obj.rcoObjectType];
        } else {
            predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@) and (parentObjectType = %@)", obj.rcoObjectId, obj.rcoObjectClass];
        }
    } else if ([obj.rcoRecordId length]){
        predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@)", obj.rcoRecordId];
    } else {
        return nil;
    }
    
    if (date) {
        NSDate *startDate = [date dateAsDateWithoutTime];
        NSDate *endDate = [startDate dateByAddingDays:1];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat: @"dateTime>=%@ and dateTime<%@", startDate, endDate];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, datePredicate, nil]];
    }
    
    NSArray *array = [self getAllNarrowedBy: predicate andSortedBy: nil];
    
    return array;
}

-(NSArray*)getAllNotes {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPersistentStoreCoordinator *coordinator = [[DataRepository sharedInstance] persistentStoreCoordinator];
    
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    
    __block NSArray *res = nil;
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
                [threadDict setObject:context forKey:kMobileOfficeKey_MOC];
            }
        }
        
        [context performBlockAndWait:^{
            // Edit the entity name as appropriate.
            NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setIncludesSubentities:NO];
            [fetchRequest setResultType:NSDictionaryResultType];
            
            NSMutableArray *allFields = [NSMutableArray array];
            
            [allFields addObject:@"rcoObjectId"];
            [allFields addObject:@"rcoObjectType"];
            [allFields addObject:@"rcoRecordId"];
            [allFields addObject:@"latitude"];
            [allFields addObject:@"longitude"];
            [allFields addObject:@"title"];
            [allFields addObject:@"notes"];
            [allFields addObject:@"parentObjectId"];
            [allFields addObject:@"parentObjectType"];
            [allFields addObject:@"dateTime"];

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
            
            NSPredicate *finalPredicate = nil;
            
            if (finalPredicate) {
                [aFetchedResultsController.fetchRequest setPredicate:finalPredicate];
            }
            
            [aFetchedResultsController performFetch:&error DATABASE_ACCESS_TIMING_ARGS];
            
            NSArray *fetchedObjects = aFetchedResultsController.fetchedObjects;
            
            res = fetchedObjects;

        }];
    }
    
    return res;
}

- (NSArray*) sortDescriptors
{
    NSSortDescriptor *dateTime = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:YES];
    
    return [NSArray arrayWithObjects:dateTime, nil];
}

- (NSString*) sectionNameKeyPath;
{
    return @"dateTime";
}

- (NSString*) entityName
{
    return @"Note";
}



@end
