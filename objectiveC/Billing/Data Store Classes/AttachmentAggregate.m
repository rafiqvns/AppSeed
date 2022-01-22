//
//  AttachmentAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 8/2/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import "AttachmentAggregate.h"
#import "DataRepository.h"
#import "RCOObject+RCOObject_Imp.h"
#import "Attachment+CoreDataClass.h"

@implementation AttachmentAggregate

- (id) init
{
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"Attachment";
        self.rcoObjectClass = @"Attachment";
        self.rcoRecordType = @"Attachment";
        self.frontLoadImages = false;
        self.aggregateRight = nil;
        self.aggregateRights = [[NSArray alloc] initWithObjects:kTrainingMap, nil];
        skipSyncRecords = YES;
    }
    
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue
{
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    
    Attachment *photo = (Attachment *) object;
    
    if ([fieldName isEqualToString:@"Description"]) {
        photo.title = fieldValue;
    } else if ([fieldName isEqualToString:@"Name"]) {
        photo.name = fieldValue;
    } else if ([fieldName isEqualToString:@"ParentObjectId"]) {
        photo.parentObjectId = fieldValue;
    } else if ([fieldName isEqualToString:@"ParentObjectType"]) {
        photo.parentObjectType = fieldValue;
    } else if( [fieldName isEqualToString:@"DateTime"] ) {
        photo.dateTime = [self rcoStringToDateTime:fieldValue];
    } else if ([fieldName isEqualToString:@"ParentRecordId"]) {
        photo.parentBarcode = fieldValue;
    }
}

- (void)getAttachmentsForParent:(NSString*)parentRecordId {
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_F
                                         withParams: [NSString stringWithFormat:@"%@/10000/%d/ParentRecordId/%@", self.rcoRecordType, 0, parentRecordId]
                                          andObject: nil
                                         callBackTo: self];
    
}
- (void)getAttachmentsForSudentDriverLicenseNumber:(NSString*)driverLicenseNumber andState:(NSString*)state {
    if (!driverLicenseNumber.length || !state.length) {
        return;
    }
    NSString *timestamp = @"1";

    NSString *params = [NSString stringWithFormat:@"%@/-%d/%@/+/+/+/%@,%@/,/%@,%@/,/+/+", self.rcoRecordType, BATCH_SIZE, timestamp, @"Driver License Number", @"Driver License State",  driverLicenseNumber, state];
    
    NSString *callId = [NSString stringWithFormat:@"%@_%@", driverLicenseNumber, state];
    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: callId
                                         callBackTo: self];

    
}

-(NSArray*)getAttachmentsForObject:(NSString*)objRecordId {
    
    if (objRecordId.length == 0) {
        return nil;
    }
    
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:  @"(parentBarcode = %@)", objRecordId];
    
    NSArray *array = [self getAllNarrowedBy: predicate andSortedBy: nil];
    
    return array;
}

-(NSArray*)getAttachmentsForStudentWithDriverLicenseNumber:(NSString*)licenseNumber andState:(NSString*)state {
    
    if ((licenseNumber.length == 0) || (state.length == 0)) {
        return nil;
    }
    
    NSPredicate *predicate = nil;
    NSString *title = [NSString stringWithFormat:@"%@_%@", licenseNumber, state];
    predicate = [NSPredicate predicateWithFormat:@"(title = %@)", title];
    
    NSArray *array = [self getAllNarrowedBy:predicate andSortedBy: nil];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey: @"DateTime" ascending:YES];
    
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
}

- (id ) createNewRecord: (RCOObject *) obj {
    Attachment *att = (Attachment *) obj;
    
    if (!obj) {
        return nil;
    }
    
    [self addSync];
    
    NSString *noteInfo = [att CSVFormat];
    
    NSLog(@"Create Attachement CSV: %@", noteInfo);
    
    NSData *data = [noteInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    [obj setNeedsUploading:YES];
    [self save];

    if ([att.parentObjectId integerValue] == 0) {
        if (att.parentObjectType) {
            Aggregate *parentAgg = [[DataRepository sharedInstance] getAggregateForClass:att.parentObjectType];
            RCOObject *obj = [parentAgg getObjectMobileRecordId:att.parentObjectId];
            
            if ([obj existsOnServerNew]) {
                att.parentObjectId = obj.rcoObjectId;
                att.parentObjectType = obj.rcoObjectType;
                att.parentBarcode = obj.rcoBarcode;
                [self save];
                noteInfo = [att CSVFormat];
                data = [noteInfo dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                return nil;
            }
        }
    }
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];

    return  [[DataRepository sharedInstance] tellTheCloud:RD_S
                                                  withMsg:SA
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}


- (void)requestFinished:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString:RD_G_R_U_X_F]) {
        [super requestFinished:request];
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:msgDict withArg2:nil];
    } else if ([msg isEqualToString:RD_G_R_U_F]) {
        
        NSError *error = nil;
        NSArray* fieldValues = [self JSONArrayFromRequestResponse:request error:&error];
        
        NSMutableArray *photosObjects = [NSMutableArray array];
        
        NSString *parentTreeId = nil;
        
        for (NSDictionary *attDict in fieldValues) {
                        
            if (![attDict isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            id objId = [attDict objectForKey:@"objectId"];
            if (!objId) {
                objId = [attDict objectForKey:@"LobjectId"];
            }
            
            NSString *objectId = [NSString stringWithFormat:@"%@", objId];
            
            NSString *objectType = [attDict objectForKey:@"objectType"];
            NSString *mobileRecordId = [attDict objectForKey:@"mobileRecordId"];
            
            RCOObject *obj = [self getObjectWithId:objectId];
            
            if (!obj) {
                obj = [self createNewObject];
                obj.rcoObjectId = objectId;
                obj.rcoObjectType = objectType;
                obj.rcoMobileRecordId = mobileRecordId;
            }
            
            NSDictionary *mapCodingInfo = [attDict objectForKey:@"mapCodingInfo"];
            NSArray *keys = mapCodingInfo.allKeys;
            
            for (NSString *key in keys) {
                NSString *val = [mapCodingInfo objectForKey:key];
                [self syncObject:obj withFieldName:key toFieldValue:val];
            }
            
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
        
    } else if([msg isEqualToString: SA] ) {
        NSString *rcoObjectId = [self parseSetRequest:request];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        RCOObject *obj = [self getObjectWithId:rcoObjectId];
        
        if (rcoObjectId) {
            [result setObject:rcoObjectId forKey:@"objId"];
        }
        
        if ([obj.fileNeedsUploading boolValue]) {
            //[self uploadRecordContent:photo andSize:kImageSizeForUpload];
            [self uploadRecordContent:obj andSize:kImageSizeForUpload];
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
    if([msg isEqualToString: SA] ) {
        NSLog(@"");
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    } else if ([msg isEqualToString:RD_G_R_U_F]) {
        
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:msgDict withArg2:nil];
    }
    return [super requestFailed:request];
}

-(NSString*)fileNameForObject:(Attachment*)obj  {
    return [NSString stringWithFormat:@"%@_%@", obj.name, [self rcoDateToString:obj.dateTime withSepatrator:@"_"]];
}

-(NSString*) getFileStubForObjectImage:(NSString *)objectId size: (NSString *) pels {
    NSString *fileStub = [super getFileStubForObjectImage:objectId size:pels];
    
    NSString *extension = @"csv";
    fileStub = [fileStub stringByDeletingPathExtension];
    fileStub = [fileStub stringByAppendingPathExtension:extension];
    
    return fileStub;
}


@end
