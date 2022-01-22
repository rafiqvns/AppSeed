//
//  TestFormAggregate.m
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TestFormAggregate.h"
#import "TestForm+CoreDataClass.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSManagedObjectContext+Timing.h"

@implementation TestFormAggregate

- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TestForm";
        self.rcoObjectClass = @"TestForm";
        self.rcoRecordType = @"Test Form";
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TestForm *op = (TestForm *) object;
    
    if( [fieldName isEqualToString:@"Test Name"] )
    {
        op.name = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Test Number"] )
    {
        op.number = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Section Name"] )
    {
        op.sectionName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Section Number"] )
    {
        op.sectionNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Item Number"] )
    {
        op.itemNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Item Name"] )
    {
        op.itemName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Points Possible"] )
    {
        op.pointsPossible = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Teaching String"] )
    {
        op.testTeachingString = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category1 Name"] )
    {
        op.categName1 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category2 Name"] )
    {
        op.categName2 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category3 Name"] )
    {
        op.categName3 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category4 Name"] )
    {
        op.categName4 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category5 Name"] )
    {
        op.categName5 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category6 Name"] )
    {
        op.categName6 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category7 Name"] )
    {
        op.categName7 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category8 Name"] )
    {
        op.categName8 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category9 Name"] )
    {
        op.categName9 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category10 Name"] )
    {
        op.categName10 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category11 Name"] )
    {
        op.categName11 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category12 Name"] )
    {
        op.categName12 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category13 Name"] )
    {
        op.categName13 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category14 Name"] )
    {
        op.categName14 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category15 Name"] )
    {
        op.categName15 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category16 Name"] )
    {
        op.categName16 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category17 Name"] )
    {
        op.categName17 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category1 Value"] )
    {
        op.categValue1 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category2 Value"] )
    {
        op.categValue2 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category3 Value"] )
    {
        op.categValue3 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category4 Value"] )
    {
        op.categValue4 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category5 Value"] )
    {
        op.categValue5 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category6 Value"] )
    {
        op.categValue6 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category7 Value"] )
    {
        op.categValue7 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category8 Value"] )
    {
        op.categValue8 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category9 Value"] )
    {
        op.categValue9 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category10 Value"] )
    {
        op.categValue10 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category11 Value"] )
    {
        op.categValue11 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category12 Value"] )
    {
        op.categValue12 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category13 Value"] )
    {
        op.categValue13 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category14 Value"] )
    {
        op.categValue14 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category15 Value"] )
    {
        op.categValue15 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category16 Value"] )
    {
        op.categValue16 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Category17 Value"] )
    {
        op.categValue17 = fieldValue;
    }
}

-(NSArray*)getTestsNames {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:localObjectClass inManagedObjectContext:self.moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // set this to NO for fixing the bug when query the InvoiceHeader we received also RefundHeader
    [request setIncludesSubentities:NO];

    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = [NSArray arrayWithObject:[[entityDescription propertiesByName] objectForKey:@"name"]];
    request.returnsDistinctResults = YES;
    NSError *error = nil;
    
    NSArray *array = [self.moc executeFetchRequest:request error:&error  DATABASE_ACCESS_TIMING_ARGS];
    NSMutableArray *res = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        [res addObject:[dict objectForKey:@"name"]];
    }
    return res;
}

-(NSArray*)getTestForSections:(NSArray*)sections {
    if (sections.count == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionNumber in %@", sections];
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNumber" ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES];

    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    res = [res sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];
    return res;
}

-(NSArray*)getTestItems:(NSString*)testNumber {
    if ([testNumber integerValue] == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number=%@", testNumber];
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNumber" ascending:YES];
    //NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES];
    
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"itemNumber"
                                                         ascending:YES
                                                        comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *str1 = (NSString*)obj1;
        NSString *str2 = (NSString*)obj2;
        if (str1.length < str2.length) {
            return NSOrderedAscending;
        } else if (str1.length == str2.length) {
            return [str1 compare:str2];
        } else {
            return NSOrderedDescending;
        }
    }];

    
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    res = [res sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];
    return res;
}

@end
