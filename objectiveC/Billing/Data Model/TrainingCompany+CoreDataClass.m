//
//  TrainingCompany+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 6/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingCompany+CoreDataClass.h"

@implementation TrainingCompany

-(NSString*)getValFromField:(NSString*)field {
    if (!field) {
        return @"";
    }
    return field;
}
-(NSDictionary*)getCategoriesInfo {
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    if (self.category1Name.length/* && self.category1Value.length*/) {
        //[res setObject:[self getValFromField:self.category1Value] forKey:self.category1Name];
        [res setObject:[self getValFromField:self.category1Name] forKey:@"Category1 Name"];

    }
    if (self.category2Name.length/* && self.category2Value.length*/) {
        //[res setObject:[self getValFromField:self.category2Value] forKey:self.category2Name];
        [res setObject:[self getValFromField:self.category2Name] forKey:@"Category2 Name"];
    }
    if (self.category3Name.length/* && self.category3Value.length*/) {
        //[res setObject:[self getValFromField:self.category3Value] forKey:self.category3Name];
        [res setObject:[self getValFromField:self.category3Name] forKey:@"Category3 Name"];
    }
    if (self.category4Name.length/* && self.category4Value.length*/) {
        //[res setObject:[self getValFromField:self.category4Value] forKey:self.category4Name];
        [res setObject:[self getValFromField:self.category4Name] forKey:@"Category4 Name"];
    }
    if (self.category5Name.length/* && self.category5Value.length*/) {
        //[res setObject:[self getValFromField:self.category5Value] forKey:self.category5Name];
        [res setObject:[self getValFromField:self.category5Name] forKey:@"Category5 Name"];
    }
    return res;
}

@end
