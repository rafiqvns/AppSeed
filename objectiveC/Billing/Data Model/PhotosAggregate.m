//
//  PhotosAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 11/15/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "PhotosAggregate.h"
#import "DataRepository.h"
#import "RCOObject+RCOObject_Imp.h"
#import "Photo+Photo_Imp.h"

@implementation PhotosAggregate

- (id) init
{
    if ((self = [super init]) != nil){
		
        self.localObjectClass = @"Photo";
        self.rcoObjectClass = @"photo";
        self.rcoRecordType = @"Photo";
        self.frontLoadImages = false;
        self.aggregateRight = kTrainingRight;
    }
    
    return self;
}

#pragma mark - Synchronization

- (Boolean) requestSync {
    return [self requestSyncRecordTypes];
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue
{
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    
    Photo *photo = (Photo *) object;
    
    if ([fieldName isEqualToString:@"Title"]) {
        photo.title = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Location"]) {
        photo.name = fieldValue;
    }
    else if ([fieldName isEqualToString:@"HeaderObjectId"]) {
        photo.parentObjectId = fieldValue;
    }
    else if ([fieldName isEqualToString:@"HeaderObjectType"]) {
        photo.parentObjectType = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Notes"]) {
        photo.notes = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Latitude"]) {
        photo.latitude = fieldValue;
    }
    else if ([fieldName isEqualToString:@"Longitude"]) {
        photo.longitude = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DateTime"] ) {
        photo.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if ([fieldName isEqualToString:@"Category"]) {
        photo.category = fieldValue;
    }
    else if ([fieldName isEqualToString:@"HeaderBarcode"]) {
        photo.parentBarcode = fieldValue;
    }
    else if( [fieldName isEqualToString: @"UserRecordId"] )
    {
        // 18.03.2020 for Training Photos we need the UserRecordId so we are saving this in the CreatorRecordId; this is a workarond not to change the record because is used in many places...
        object.creatorRecordId = fieldValue;
    }
    else if( [fieldName isEqualToString: @"CreatorRecordId"] )
    {
        NSLog(@"");
    }
}

- (void)getChildrenDirectoryIds:(RCOObject*)object childrenType:(NSString*)type {
}

- (void)getChildrenDirectoryIdsByRecordId:(NSString*)recordId childrenType:(NSString*)type {
}

- (void)getPhotosForMasterBarcode:(NSString*)masterBarcode {
    
    //10.01.2019 NSString *params = [NSString stringWithFormat:@"%@/10000/%d/HeaderBarcode/%@", self.rcoRecordType, /*[self.synchingTimeStamp longLongValue]*/ 0, masterBarcode];
    NSString *params = [NSString stringWithFormat:@"%@/-10000/%d/+/+/+/HeaderBarcode/,/%@/,/+/+", self.rcoRecordType, 0, masterBarcode];

    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: /* 10.01.2019 RD_G_R_U_F*/RD_G_R_U_X_F
                                         withParams: params
                                          andObject: masterBarcode
                                         callBackTo: self];

}

-(NSString *) getObjectCodingForCreate: (Photo *)obj {
    return [obj  CSVFormat];
}

-(NSInteger)getPhotosCountToUpload {
    NSPredicate *pred = [NSPredicate predicateWithFormat: @"((objectNeedsUploading == YES) AND (fileIsUploading == NO OR fileIsUploading == nil))"];
    return [self countObjects:pred];
}

-(NSArray*)getPhotosToUpload {
    NSPredicate *pred = [NSPredicate predicateWithFormat: @"((objectNeedsUploading == YES) AND (fileIsUploading == NO OR fileIsUploading == nil))"];
    return [self getAllNarrowedBy:pred andSortedBy:nil];
}

- (BOOL) saveImageContentAsPNG {
    return NO;
}

-(NSString*) getFileStubForObjectImage:(NSString *)objectId size: (NSString *) pels
{
    NSString* stub = [NSString  stringWithFormat:@"%@-%@-%@.%@",objectId,pels,self.rcoObjectClass, kRecordContentExtensionJPG];
    
    return stub;
}

- (id ) createNewRecord: (RCOObject *) obj forced:(NSNumber*)forced{
    Photo *photo = (Photo *) obj;
    
    if (!obj) {
        [self showAlertMessage:@"Photo is invalid, please create new one. If the problem persists please contact RCO"];
        return nil;
    }
    
    [self addSync];
    
    NSString *photoInfo = [self getObjectCodingForCreate:photo];
    
    NSLog(@"Create photos CSV: %@", photoInfo);
    
    NSData *data = [photoInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [obj setNeedsUploading:YES];
    [self save];
    
    if ([photo.parentObjectId integerValue] == 0) {
        // the parent was not saved in the system. we should search and update the record
        if (photo.parentObjectType) {
            Aggregate *parentAgg = [[DataRepository sharedInstance] getAggregateForClass:photo.parentObjectType];
            
            NSArray *allNotes = [parentAgg getAll];
            
            for (RCOObject *obj in allNotes) {
                NSLog(@">>>>>OBJ = %@ -->%@", obj.rcoMobileRecordId, obj.rcoObjectId);
            }
            
            RCOObject *obj = [parentAgg getObjectMobileRecordId:photo.parentObjectId];
            
            if ([obj existsOnServerNew]) {
                photo.parentObjectId = obj.rcoObjectId;
                photo.parentObjectType = obj.rcoObjectType;
                photo.parentBarcode = obj.rcoBarcode;
                [self save];
                photoInfo = [photo CSVFormat];
                data = [photoInfo dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                // the parent was not saved yet on RMS
                return nil;
            }
        }
    }
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:forced forKey:@"forced"];

    return  [[DataRepository sharedInstance] tellTheCloud:B_S
                                                  withMsg:SET_PHOTOS
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self
                                                extraInfo:extraInfo];
}

- (id ) createNewRecord: (RCOObject *) obj {
    Photo *photo = (Photo *) obj;
    
    if (!obj) {
        [self showAlertMessage:@"Photo is invalid, please create new one. If the problem persists please contact RCO"];
        return nil;
    }

    [self addSync];
    
    NSString *photoInfo = [self getObjectCodingForCreate:photo];
    
    NSLog(@"Create photos CSV: %@", photoInfo);

    NSData *data = [photoInfo dataUsingEncoding:NSUTF8StringEncoding];

    
    [obj setNeedsUploading:YES];
    [self save];
    
    if ([photo.parentObjectId integerValue] == 0) {
        // the parent was not saved in the system. we should search and update the record
        if (photo.parentObjectType) {
            Aggregate *parentAgg = [[DataRepository sharedInstance] getAggregateForClass:photo.parentObjectType];
            
            NSArray *allNotes = [parentAgg getAll];
            
            for (RCOObject *obj in allNotes) {
                NSLog(@">>>>>OBJ = %@ -->%@", obj.rcoMobileRecordId, obj.rcoObjectId);
            }
            
            RCOObject *obj = [parentAgg getObjectMobileRecordId:photo.parentObjectId];
            
            if ([obj existsOnServerNew]) {
                photo.parentObjectId = obj.rcoObjectId;
                photo.parentObjectType = obj.rcoObjectType;
                photo.parentBarcode = obj.rcoBarcode;
                [self save];
                photoInfo = [photo CSVFormat];
                data = [photoInfo dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                // the parent was not saved yet on RMS
                return nil;
            }
        }
    }

    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];

    return  [[DataRepository sharedInstance] tellTheCloud:B_S
                                                  withMsg:SET_PHOTOS
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}


- (void) downloadDataForObject: (NSString *) objectId size: (NSString *) pels {
    RCOObject *obj = [self getObjectWithId:objectId];
    
    // NSLog(@"downloadDataForObject %@ %@ %@ ", path, [obj rcoType], obj);
    if( ![obj contentIsDownloading] )
    {
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
        [self save];
        
        // get the request going
        NSURL *fp = [self getFilePathForObjectImage:objectId size: (NSString *) pels];
        
        [[DataRepository sharedInstance] askTheCloudFor:RD_S
                                                withMsg:R_G_C
                                             withParams:[NSString stringWithFormat: @"%@/%@/%@",objectId, obj.rcoObjectType, pels]
                                              andObject:objectId
                                                 saveTo:[fp path]
                                        showingProgress:[self.localObjectClass isEqualToString:@"Document"]
                                             callBackTo: self
                                       withHighPriority:NO];

        /*
         12.03.2018 we should download the size according to the pels
        [[DataRepository sharedInstance] askTheCloudFor:RD_S
                                                withMsg:R_G_C
                                             withParams:[NSString stringWithFormat: @"%@/%@/%@",objectId, obj.rcoObjectType, @"-1"]
                                              andObject: objectId
                                                 saveTo:[fp path]
                                        showingProgress:[self.localObjectClass isEqualToString:@"Document"]
                                             callBackTo: self
                                       withHighPriority:NO];
        */
    }
}


- (id ) uploadObjectContent: (RCOObject *) obj fromURL:(NSURL*)fileURL {
    
    NSString *rcoObjId = nil;
    NSString *rcoObjType = nil;
    
    if ([obj.rcoObjectType length]) {
        // old way of uploading
        rcoObjId = obj.rcoObjectId;
        rcoObjType = obj.rcoObjectType;
        NSLog(@">>>> NEW Upload Content using ObjId and ObjType %@ -- %@", rcoObjId, rcoObjType);
    } else {
        rcoObjId = obj.rcoRecordId;
        rcoObjType = RCO_OBJECT_TYPE_RECORD_ID;
        NSLog(@">>>> NEW Upload Content using RecordId and ObjType %@ -- %@", rcoObjId, rcoObjType);
    }
    
    if ([obj.fileLog length]) {
        NSLog(@"we should upload the thumbnail!");
    }
    
    NSLog(@"Content URL!!! = %@", fileURL);
    //19.03.2018 objectId/objectType/key/mode/version
    
    return [[DataRepository sharedInstance] tellTheCloud:RD_S
                                                 withMsg:R_S_C_1
                                              withParams:[NSString stringWithFormat:@"%@/%@/%@/%@/%@", rcoObjId, rcoObjType, @"+", @"+", @"-2"]
                                                withData:nil
                                                withFile:[fileURL path]
                                               andObject:rcoObjId
                                              callBackTo:self];
}

- (void)requestFinished:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    NSString *objId = [msgDict objectForKey:@"objId"];

    if ([msg isEqualToString:RD_G_R_U_X_F] && (objId.length == 0)) {
        //07.05.2019 is the normal sync super should handle this ...
        return [super requestFinished:request];
    } else if ([msg isEqualToString:RD_G_R_U_F] || [msg isEqualToString:RD_G_R_U_X_F]) {
        NSString *params = (NSString *)[msgDict objectForKey:@"params"];
        
        NSArray *comp = [params componentsSeparatedByString: @"/"];
        
        NSError *error = nil;
        NSArray* fieldValues = [self JSONArrayFromRequestResponse:request error:&error];
        
        NSMutableArray *photosObjects = [NSMutableArray array];
        
        NSString *parentTreeId = nil;
        
        for (NSDictionary *photoDict in fieldValues) {
        
            NSLog(@" photo dict = %@", photoDict);
            
            if (![photoDict isKindOfClass:[NSDictionary class]]) {
                return;
            }

            id objId = [photoDict objectForKey:@"objectId"];
            if (!objId) {
                objId = [photoDict objectForKey:@"LobjectId"];
            }
            
            NSString *objectId = [NSString stringWithFormat:@"%@", objId];
            
            NSString *objectType = [photoDict objectForKey:@"objectType"];
            NSString *name = [photoDict objectForKey:@"name"];
            parentTreeId = [photoDict objectForKey:@"parentTreeId"];
            
            NSDictionary *mapCodingInfo = [photoDict objectForKey:@"mapCodingInfo"];
            
            RCOObject *obj = [self getObjectWithId:objectId];
            
            BOOL downloadContent = NO;
            
            if (!obj) {
                obj = [self createNewObject];
                obj.rcoObjectId = objectId;
                obj.rcoObjectType = objectType;
                
                if (comp.count >= 2) {
                    
                    /*
                    NSString *parentObjectId = [comp objectAtIndex:0];
                    NSString *parentObjectType = [comp objectAtIndex:1];
                    */
                    
                    Photo *photo = (Photo*)obj;
                    //photo.parentObjectId = parentObjectId;
                    //photo.parentObjectType = parentObjectType;
                    photo.name = name;
                    downloadContent = YES;
                }
                
                for (NSString *key in mapCodingInfo.allKeys) {
                    id val = [mapCodingInfo objectForKey:key];
                    [self syncObject:obj withFieldName:key toFieldValue:val];
                }
                
                [self save];
            }
            
            [photosObjects addObject:obj.rcoObjectId];
            
            if (downloadContent) {
                NSData *photoData = [self getDataForObject:obj.rcoObjectId size:@"-1" skipDownload:YES];
                
                if (!photoData) {
                    [self downloadDataForObject:obj.rcoObjectId size:@"-1"];
                }
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

    } else if ([msg isEqualToString:SET_PHOTOS]) {
        
        NSError *error = nil;
        NSArray* fieldValues = [self JSONArrayFromRequestResponse:request error:&error];
        
        if ([fieldValues count] == 0) {
            [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:msgDict withArg2:nil];
            return;
        }
        
        NSDictionary *headerDict = [fieldValues objectAtIndex:0];
        
        NSNumber * objectId = [headerDict objectForKey:@"LobjectId"];
        NSString *objectType = [headerDict objectForKey:@"objectType"];
        NSArray *arCodingInfo = [headerDict objectForKey:@"arCodingInfo"];
        
        [[self moc] performBlockAndWait:^{
            Photo *photo = (Photo*)[self getObjectWithId:[msgDict objectForKey:@"objId"]];
            
            for (NSDictionary *arCodingDict in arCodingInfo) {
                NSString *fieldName = [arCodingDict objectForKey:@"displayName"];
                NSString *fieldValue = [arCodingDict objectForKey:@"value"];
                [self syncObject:photo withFieldName:fieldName toFieldValue:fieldValue];
            }
            
            photo.rcoObjectId = [NSString stringWithFormat:@"%ld", [objectId longValue]];
            photo.rcoObjectType = objectType;
            [photo setNeedsUploading:NO];
            
            [self save];
            
            if ([photo.fileNeedsUploading boolValue]) {
                //[self uploadRecordContent:photo andSize:kImageSizeForUpload];
                [self uploadRecordContent:photo andSize:kImageSizeThumbnailSize];
            }
            
            [self dispatchToTheListeners:kObjectUploadComplete withObjectId:photo.rcoObjectId];
        }];
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:msgDict withArg2:nil];
        
    } else if( [msg isEqualToString: R_S_C_1]) {
        
        NSString *objId = [msgDict objectForKey:@"objId"];
        
        [self performSelectorOnMainThread:@selector(updateUploadingFlagForObject:) withObject:objId waitUntilDone:YES];
        
        NSURL *fp = [self getFilePathForObjectImage:objId size:kImageSizeForUpload];

        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        [fm removeItemAtURL:fp error:&error];
        if (error) {
            NSLog(@"Failed to remove Image for upload");
        }

        [[self moc] performBlockAndWait:^{
            RCOObject *obj = [self getObjectWithId:objId];
            
            if ([obj.fileLog length] == 0) {
                //19.03.2018 we need to upload the thumbnail because the photo was newly created
                [obj setFileNeedsUploading:[NSNumber numberWithBool:YES]];
                [obj setFileIsUploading:[NSNumber numberWithBool:NO]];
                obj.fileLog = kImageSizeThumbnailSize;
                obj.fileLog = kImageSizeForUpload;
                [self save];
                //[self uploadRecordContent:obj andSize:kImageSizeThumbnailSize];
                [self uploadRecordContent:obj andSize:kImageSizeForUpload];
            }
        }];
        
        [self dispatchToTheListeners:kObjectContentUploadComplete withArg1:msgDict withArg2:nil];
    } else {
        [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    // the super should report
    [super requestFailed:request];
    
    if ([msg isEqualToString:RD_G_R_U_F] || [msg isEqualToString:RD_G_R_U_X_F]) {
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:msgDict withArg2:nil];
    } else if ([msg isEqualToString:SET_PHOTOS]) {
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:msgDict withArg2:nil];
    }
}

-(NSArray*)getPhotosForObject:(RCOObject*)obj {
    
    NSPredicate *predicate = nil;
    
    if ([obj.rcoObjectId length]) {
        // old way of getting photos
        if ([obj existsOnServerNew]) {
            predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@) and (parentObjectType = %@)", obj.rcoObjectId, obj.rcoObjectType];
        } else {
            predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@) and (parentObjectType = %@)", obj.rcoObjectId, obj.rcoObjectClass];
        }
    } else if ([obj.rcoRecordId length]){
        // this is the new way of getting the photos
        predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@)", obj.rcoRecordId];
    } else {
        return nil;
    }
    
    NSArray *array = [self getAllNarrowedBy: predicate andSortedBy: nil];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:YES];
    
    array = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return array;
}

-(NSArray*)getPhotosForObjectRecordId:(NSString*)recordId {
    
    NSPredicate *predicate = nil;
    
     if ([recordId length]){
        // this is the new way of getting the photos
        predicate = [NSPredicate predicateWithFormat:  @"(parentObjectId = %@)", recordId];
    } else {
        return nil;
    }
    
    NSArray *array = [self getAllNarrowedBy: predicate andSortedBy: nil];
    
    return array;
}


- (BOOL) isDataDownloaded: (NSString *) objectId size: (NSString *) pels
{
    NSString *filename =  [self getObjectFileName:objectId size: (NSString *) pels];
    if (!filename) {
        return NO;
    }
    
    NSURL *fp = [NSURL fileURLWithPath:filename];
    
    BOOL isDir = YES;
    BOOL isDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir];
    
    return isDownloaded;
}

-(NSString*)getObjectFileName:(NSString*)objectId size:(NSString*)pels {
    
    //14.08.2018 we should use this method because we don't know the extension of the file
    NSURL *fp =  [self getFilePathForObjectImage:objectId size: (NSString *) pels];
    
    NSString *path = [[fp relativePath] stringByDeletingLastPathComponent];
    
    NSString *fileName = [[[fp relativePath] lastPathComponent] stringByDeletingPathExtension];
    
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", fileName];
    NSArray *result = [dirFiles filteredArrayUsingPredicate:predicate];
    
    if (result.count) {
        // we have a downloaded file with this name, we don't know the extension
        return [path stringByAppendingPathComponent:[result objectAtIndex:0]];
    }
    return nil;
}

/*
-(NSString*) getFileStubForObjectImage:(NSString *)objectId size: (NSString *) pels
{
    NSString* stub = [NSString  stringWithFormat:@"%@-%@-%@.png",objectId,pels,self.rcoObjectClass];
    
    return stub;
}
*/

-(NSURL*) getFilePathForObjectImage:(NSString *)objectId size: (NSString *) pels
{
    if (!pels) {
        return nil;
    }
    //14.08.2018 we should use this method because we don't know the extension of the file
    NSURL *fp =  [super getFilePathForObjectImage:objectId size: (NSString *) pels];
    
    NSString *path = [[fp relativePath] stringByDeletingLastPathComponent];
    
    NSString *fileName = [[[fp relativePath] lastPathComponent] stringByDeletingPathExtension];
    
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", fileName];
    NSArray *result = [dirFiles filteredArrayUsingPredicate:predicate];
    
    NSString *pathToReturn = [fp relativePath];
    
    if (result.count) {
        // we have a downloaded file with this name, we don't know the extension
        pathToReturn =  [path stringByAppendingPathComponent:[result objectAtIndex:0]];
    }
    
    return [NSURL fileURLWithPath:pathToReturn];
}


@end
