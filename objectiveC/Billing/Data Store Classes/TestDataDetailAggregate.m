//
//  TestDataDetailAggregate.m
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TestDataDetailAggregate.h"
#import "RCOObject+RCOObject_Imp.h"
#import "TestDataDetail+CoreDataClass.h"
#import "Settings.h"

@implementation TestDataDetailAggregate

- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TestDataDetail";
        self.rcoObjectClass = @"TestDataDetail";
        self.rcoRecordType = @"Test Data Detail";
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TestDataDetail *op = (TestDataDetail *) object;
    
    if( [fieldName isEqualToString:@"Test Name"] )
    {
        op.testName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Test Number"] )
    {
        op.testNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Section Name"] )
    {
        op.testSectionName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Section Number"] )
    {
        op.testSectionNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Item Number"] )
    {
        op.testItemNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Item Name"] )
    {
        op.testItemName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Score"] )
    {
        op.score = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Company"] )
    {
        op.company = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Student First Name"] )
    {
        op.studentFirstName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Student Last Name"] )
    {
        op.studentLastName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Employee Id"] )
    {
        op.employeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor First Name"] )
    {
        op.instructorFirstName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Last Name"] )
    {
        op.instructorLastName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Employee Id"] )
    {
        op.instructorEmployeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Notes"] )
    {
        op.notes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Teaching String"] )
    {
        op.testTeachingString = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DateTime"] ) {
        op.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Location"] )
    {
        op.location = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Trailer Number"] )
    {
        op.trailerNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Odometer"] )
    {
        op.odometer = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Leg"] )
    {
        op.leg = fieldValue;
    }
    else if( [fieldName isEqualToString:@"EquipmentMobileRecordId"] )
    {
        op.equipmentUsedMobileRecordId = fieldValue;
    }
}

-(TestDataDetail*)getTestDetailForHeaderParentId:(NSString*)parentId forItemNumber:(NSString*)itemNumber andsectionNumber:(NSString*)sectionNumber {
    
    if (!parentId.length || !itemNumber.length || !sectionNumber.length) {
        return nil;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"rcoObjectParentId=%@ and testItemNumber=%@ and testSectionNumber=%@", parentId, itemNumber, sectionNumber];
    NSArray *res = [self getAllNarrowedBy:pred andSortedBy:nil];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
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

-(BOOL)overwriteRecord:(RCOObject*)obj {
    return NO;
}

@end
