//
//  TestDataHeaderAggregate.m
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TestDataHeaderAggregate.h"
#import "TestDataHeader+CoreDataClass.h"
#import "TestDataDetail+CoreDataClass.h"
#import "TestDataDetailAggregate.h"
#import "SignatureDetailAggregate.h"
#import "DataRepository.h"
#import "SignatureDetail.h"
#import "NotesAggregate.h"
#import "Note+CoreDataClass.h"
#import "Settings.h"

@implementation TestDataHeaderAggregate

- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TestDataHeader";
        self.rcoObjectClass = @"TestDataHeader";
        self.rcoRecordType = @"Test Data Header";
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id) initAggregateWithRights:(NSArray *)rights
{
    if ((self = [super initAggregateWithRights:rights]) != nil){
        Aggregate *detailAggregate = [[TestDataDetailAggregate alloc] initAggregateWithRights:rights];
        
        [detailAggregate registerForCallback:self];
        
        SignatureDetailAggregate *signatureDetailAggregate = nil;
        
         signatureDetailAggregate = [[SignatureDetailAggregate alloc] initAggregateWithRights:rights];
         signatureDetailAggregate.itemType = TestSignatureItemType;
         NSMutableArray *signatureRights = [NSMutableArray arrayWithObject:signatureDetailAggregate.aggregateRight];
         [signatureRights addObjectsFromArray:self.aggregateRights];
         signatureDetailAggregate.aggregateRights = signatureRights;

        self.detailAggregates = [[NSMutableArray alloc] initWithObjects:detailAggregate, signatureDetailAggregate, nil];
    }
    
    return self;
}


-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TestDataHeader *op = (TestDataHeader *) object;
    
    if( [fieldName isEqualToString:@"Test Name"] )
    {
        op.name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Test Number"] )
    {
        op.number = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DateTime"] ) {
        op.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Company"] )
    {
        op.company = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Student First Name"] )
    {
        op.studentFirstName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Student Last Name"] )
    {
        op.studentLastName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Employee Id"] )
    {
        op.employeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor First Name"] )
    {
        op.instructorFirstName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Instructor Last Name"] )
    {
        op.instructorLastName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Instructor Employee Id"] )
    {
        op.instructorEmployeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License Expiration Date"] )
    {
        op.driverLicenseExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Class"] )
    {
        op.driverLicenseClass = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Endorsements"] )
    {
        op.endorsements = fieldValue;
    }
    else if( [fieldName isEqualToString:@"StartDateTime"] )
    {
        op.startDateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"EndDateTime"] )
    {
        op.endDateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"DOT Expiration Date"] )
    {
        op.dotExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver History Reviewed"] )
    {
        op.driverHistoryReviewed = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License Number"] )
    {
        op.driverLicenseNumber = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License State"] )
    {
        op.driverLicenseState= fieldValue;
    }
    else if( [fieldName isEqualToString:@"Power Unit"] )
    {
        op.powerUnit = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Corrective Lens Required"] )
    {
        op.correctiveLensRequired = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Power Unit"] )
    {
        op.powerUnit = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Location"] )
    {
        op.location = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DOT Number"] )
    {
        op.dotNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Points Possible"] )
    {
        op.pointsPossible = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Points Received"] )
    {
        op.pointsReceived = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Name"] )
    {
        op.name = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Number"] )
    {
        op.number = fieldValue;
    }
    else if( [fieldName isEqualToString:@"MasterMobileRecordId"] )
    {
        op.rcoObjectParentId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Restrictions"] )
    {
        op.restrictions = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Department"] )
    {
        op.department = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Route Number"] )
    {
        op.routeNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"On Time"] )
    {
        op.onTime = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Keys Ready"] )
    {
        op.keysReady = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Timecard System Ready"] )
    {
        op.timecardSystemReady = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Equipment Ready"] )
    {
        op.equipmentReady = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Equipment Clean"] )
    {
        op.equipmentClean = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Start Odometer"] )
    {
        op.startOdometer = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Finish Odometer"] )
    {
        op.finishOdometer = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Miles"] )
    {
        op.miles = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Elapsed Time"] )
    {
        op.elapsedTime = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Pause DateTimes"] )
    {
        op.pauseDateTimes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Result"] )
    {
        op.testResult = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Remarks"] )
    {
        op.testRemarks = fieldValue;
    }
    else if( [fieldName isEqualToString:@"QualifiedYesNo"] )
    {
        op.qualifiedYesNo = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Disqualified Remarks"] )
    {
        op.disqualifiedRemarks = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Date"] )
    {
        op.testDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Test Miles"] )
    {
        op.testMiles = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Medical Card Expiration Date"] )
    {
        op.medicalCardExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Test State"] )
    {
        op.testState = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Trailer Length"] )
    {
        op.trailerLength = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Number of Trailers"] )
    {
        op.numberofTrailers = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Evaluator Name"] )
    {
        op.evaluatorName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Evaluator Title"] )
    {
        op.evaluatorTitle = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Observer First Name"] )
    {
        op.observerFirstName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Observer Last Name"] )
    {
        op.observerLastName = fieldValue;
    }
}

- (id) createNewRecord: (RCOObject *) obj {
    TestDataHeader *form = (TestDataHeader*)obj;
    
    if (!obj) {
        return nil;
    }
    
    NSMutableArray *res = [NSMutableArray array];
    
    NSArray *details = nil;
    
    if ([obj.rcoBarcode length]) {
        details = [self getObjectDetailsForMasterBarcode:obj.rcoBarcode];
    } else {
        details = [self getObjectDetails:obj.rcoObjectId];
    }
    
    Aggregate *detailAgg = [self.detailAggregates objectAtIndex:0];
    
    for (TestDataDetail *detail in details) {
        if (![detail isKindOfClass:[TestDataDetail class]]) {
            // we have the signatures and we should skip them ....
            continue;
        }
        NSString *detailCSVFormat = [detail CSVFormat];
        if (detailCSVFormat) {
            [res addObject:detailCSVFormat];
        }
    }
    
    [detailAgg save];
    
    [self save];
    
    NSString *formCSVFormat = [form CSVFormat];
    
    if ([res count] > 0) {
        [res insertObject:formCSVFormat atIndex:0];
    } else {
        [res addObject:formCSVFormat];
    }
    
    NSString *dataPlain = [res componentsJoinedByString:@"\n"];
    
    NSData *data = [dataPlain dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:T_S
                                                  withMsg:TDH
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: TDH]) {
        NSString *rcoObjectId = [self parseSetRequest:request];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        NSString *initialObjectId = [result objectForKey:@"objId"];
        
        if (rcoObjectId) {
            [result setObject:rcoObjectId forKey:@"objId"];
        }
        
        if ([self isObjectIdValid:rcoObjectId]) {
            RCOObject *testDatHeader = [self getObjectWithId:rcoObjectId];
            if (testDatHeader) {
                SignatureDetailAggregate *signatureDetailAgg = [self.detailAggregates objectAtIndex:1];
                
                NSArray *details = [signatureDetailAgg getObjectsThatNeedsToUpload];
                for (SignatureDetail *sd in details) {
                    
                    if ([sd.rcoObjectParentId isEqualToString:initialObjectId]) {
                        sd.parentObjectId = testDatHeader.rcoObjectId;
                        sd.parentObjectType = testDatHeader.rcoObjectType;
                        [signatureDetailAgg createNewRecord:sd];
                    }

                }
            }
            NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
            NSArray *notes = [agg getNotesForObjectId:initialObjectId];
            for (Note *note in notes) {
                note.parentBarcode = testDatHeader.rcoBarcode;
                note.parentObjectId = testDatHeader.rcoObjectId;
                note.parentObjectType = testDatHeader.rcoObjectType;
                [agg createNewRecord:note];
            }
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:rcoObjectId];
    } else {
        return [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: TDH]) {
        NSLog(@"");
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

-(TestDataHeader*)getStartedTestDataHeaderForTestInfo:(NSString*)testInfoMobileRecordId andFormNumber:(NSString*)formNumber{
    if (!testInfoMobileRecordId.length || !formNumber.length) {
        return nil;
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"rcoObjectParentId = %@ and number=%@", testInfoMobileRecordId, formNumber];
    NSArray *res = [self getAllNarrowedBy:p andSortedBy:nil];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:YES];
    if (res.count > 1) {
        NSLog(@"");
    }
    if (res.count) {
        TestDataHeader *header = [[res sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]] lastObject];
        if (header.endDateTime) {
            return nil;
        } else {
            return header;
        }
    }
    return nil;
}

-(NSString*)fileNameForObject:(TestDataHeader*)obj  {

    if ([obj.number isEqualToString:@"01"]) {
        return [NSString stringWithFormat:@"BehindWheel-%@ %@-%@", obj.studentLastName, obj.studentFirstName, obj.employeeId];
    } else if ([obj.number isEqualToString:@"02"]) {
        return [NSString stringWithFormat:@"Pretrip-%@ %@-%@", obj.studentLastName, obj.studentFirstName, obj.employeeId];
    } else if ([obj.number isEqualToString:@"03"]) {
        return [NSString stringWithFormat:@"BusEval-%@ %@-%@", obj.studentLastName, obj.studentFirstName, obj.employeeId];
    }
    return [NSString stringWithFormat:@"%@_%@_%@", obj.studentLastName, obj.studentFirstName, [self rcoDateToString:obj.dateTime withSepatrator:@"_"]];
}

-(NSString*) getFileStubForObjectImage:(NSString *)objectId size: (NSString *) pels {
    NSString *fileStub = [super getFileStubForObjectImage:objectId size:pels];
    
    NSString *extension = @"pdf";
    fileStub = [fileStub stringByDeletingPathExtension];
    fileStub = [fileStub stringByAppendingPathExtension:extension];
    
    return fileStub;
}

-(BOOL)FFFilter {
    
    return NO;
    
    return YES;
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    if (![[organizationName lowercaseString] isEqualToString:[userCompany lowercaseString]]) {
        return YES;
    }
    return NO;
}

- (NSString*)filterCodingFielValue {
    NSString *employeeId = [Settings getSetting:CLIENT_USER_EMPLOYEEID_KEY];
    return [NSString stringWithFormat:@"%@,%@", employeeId, @"no"];
    return employeeId;
}

- (NSString*)filterCodingFieldName {
    return @"Instructor Employee Id,Is Complete";
    return @"Instructor Employee Id";
}

-(void)getRecordAnalyticsAndGroupByCodingFields:(NSArray*)groupCodingFields
                           addCodingFieldsNames:(NSArray*)addCodingFieldNames
                                 withOperations:(NSArray*)operations
                                       fromDate:(NSDate*)fromDate
                                         toDate:(NSDate*)toDate
                                 dateRangeField:(NSString*)dateRangeField
                                   filterFields:(NSArray*)filterFields
                                   filterValues:(NSArray*)filterValues
                                  filterCompOps:(NSString*)filterCompOps
                                 namesDelimiter:(NSArray*)namesDelimiter
                                valuesDelimiter:(NSArray*)valuesDelimiter
                                  forRecordType:(NSString*)recordTypeParam
                                andAnaliticType:(NSString*)analyticType{
    
    if ((!fromDate || !toDate) && (!recordTypeParam.length)) {
        return;
    }
    
    NSString *groupCodingFieldsStr = [groupCodingFields componentsJoinedByString:@","];
    
    NSString *addCodingFieldNamesStr = [addCodingFieldNames componentsJoinedByString:@","];
    NSString *operationsStr = @"+";
    if (operations.count) {
        operationsStr = [operations componentsJoinedByString:@","];
    }
    NSString *filterFieldsStr = @"+";
    if (filterFields.count) {
        filterFieldsStr = [filterFields componentsJoinedByString:@","];
    }
    NSString *filterValuesStr = @"+";
    if (filterValues.count) {
        filterValuesStr = [filterValues componentsJoinedByString:@","];
    }
    NSString *namesDelimiterStr = [namesDelimiter componentsJoinedByString:@","];
    if (!namesDelimiter.count) {
        namesDelimiterStr = @"+";
    }
    NSString *valuesDelimiterStr = [valuesDelimiter componentsJoinedByString:@","];
    if (!valuesDelimiter.count) {
        valuesDelimiterStr = @"+";
    }
    if (!dateRangeField.length) {
        if (!recordTypeParam.length) {
            dateRangeField = @"DateTime";
        } else {
            dateRangeField = @"+";
        }
    }
    
    if (!filterCompOps.length) {
        filterCompOps = @"+";
    }
    
    if (!recordTypeParam.length) {
        recordTypeParam = [NSString stringWithFormat:@"%@", self.rcoRecordType];
    }
    
    NSString *fromDateStr = @"+";
    if (fromDate) {
        fromDateStr = [self rcoDateToString:fromDate];
    }

    NSString *toDateStr = @"+";
    if (toDate) {
        toDateStr = [self rcoDateToString:toDate];
    }

    NSString *parameters = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@", recordTypeParam, groupCodingFieldsStr, addCodingFieldNamesStr, operationsStr, fromDateStr,  toDateStr, dateRangeField, filterFieldsStr, filterValuesStr, filterCompOps, namesDelimiterStr, valuesDelimiterStr];
    
}

-(BOOL)overwriteRecord:(RCOObject*)obj {
    // local record is more important
    return NO;
}

@end
