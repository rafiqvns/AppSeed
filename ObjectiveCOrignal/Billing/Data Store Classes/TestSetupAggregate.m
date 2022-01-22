//
//  TestSetupAggregate.m
//  Quality
//
//  Created by .D. .D. on 1/29/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TestSetupAggregate.h"
#import "RCOObject+RCOObject_Imp.h"
#import "TestSetup+CoreDataClass.h"


@implementation TestSetupAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TestSetup";
        self.rcoObjectClass = @"TestSetup";
        self.rcoRecordType = @"Test Setup";
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TestSetup *op = (TestSetup *) object;
    
    if( [fieldName isEqualToString:@"Test Name"] )
    {
        op.name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Test Number"] )
    {
        op.number = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test number of sections"] )
    {
        op.numberOfSections = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test possible points form"] )
    {
        op.possiblePoints = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test possible points sections"] )
    {
        op.possibleSections = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Section Titles"] )
    {
        op.sectionTitles = fieldValue;
    }
}


@end
