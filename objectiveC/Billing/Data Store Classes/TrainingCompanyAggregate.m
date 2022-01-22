//
//  TrainingCompanyAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 6/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TrainingCompanyAggregate.h"
#import "TrainingCompany+CoreDataClass.h"
#import "DataRepository.h"
#import "Settings.h"
#import "HelperUtility.h"


@implementation TrainingCompanyAggregate
- (id) init {
    
    
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TrainingCompany";
        self.rcoObjectClass = @"TrainingCompany";
        self.rcoRecordType = @"Training Company Setup";
        self.aggregateRight = kTrainingRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    
    
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TrainingCompany *op = (TrainingCompany *) object;
    
    if( [fieldName isEqualToString:@"Company"] ) {
        op.name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Company Id"] ) {
        op.number = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Address"] ) {
        op.address = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"City"] ) {
        op.city = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"State"] ) {
        op.state = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"ZipCode"] ) {
        op.zip = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Phone"] ) {
        op.phone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category1 Name"] )
    {
        op.category1Name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category2 Name"] )
    {
        op.category2Name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category3 Name"] )
    {
        op.category3Name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category4 Name"] )
    {
        op.category4Name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category5 Name"] )
    {
        op.category5Name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category1 Value"] )
    {
        op.category1Value = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category2 Value"] )
    {
        op.category2Value = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category3 Value"] )
    {
        op.category3Value = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category4 Value"] )
    {
        op.category4Value = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Category5 Value"] )
    {
        op.category5Value = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driving School"] )
    {
        op.drivingSchool = fieldValue;
    }
}

-(TrainingCompany*)getTrainingCompanyWithName:(NSString*)name {
    if (!name.length) {
        return nil;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name=%@", name];
    NSArray *res = [self getAllNarrowedBy:pred andSortedBy:nil];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}


-(TrainingCompany*)getCurrentDrivingSchool {
    NSString *loggedInUserCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    TrainingCompany *tc = [self getTrainingCompanyWithName:loggedInUserCompany];
    if ([tc.drivingSchool boolValue]) {
        return tc;
    }
    return nil;
}

-(void)createDefaultCompany {
    
    
    TrainingCompany *tc = (TrainingCompany*)[self createNewObject];
    tc.name = @"Certified Safe Driver";
    tc.number = @"003";
    tc.drivingSchool = @"yes";
    tc.address = @"20803 E. Valley Blvd. Suite 109";
    tc.city = @"Walnut";
    tc.state = @"CA";
    tc.companyId = @"003";
    [self save];
}

-(void)createCompanyWithDict: (NSDictionary *) companyDict {
    
    
    TrainingCompany *tc = (TrainingCompany*)[self createNewObject];
    
    if ([HelperSharedManager isCheckNotNULL: [companyDict valueForKey:@"name"]]) {
        tc.name = [companyDict valueForKey:@"name"];
    }
    
    if ([HelperSharedManager isCheckNotNULL: [companyDict valueForKey:@"id"]]) {
        tc.number = [companyDict valueForKey:@"id"];
        tc.companyId = [companyDict valueForKey:@"id"];
    
    }
    
    tc.drivingSchool = @"yes";
    tc.address = @"";
    tc.city = @"";
    tc.state = @"";
    
    [self save];
}

@end
