//
//  TestForm+CoreDataClass.m
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TestForm+CoreDataClass.h"

@implementation TestForm
-(NSArray*)getTestCategorieNames {
    NSInteger numberofCategories = 17;
    NSMutableArray *res = [NSMutableArray array];
    for (NSInteger i = 1; i <= numberofCategories; i++) {
        // 04.03.2020 NSString *catName = [NSString stringWithFormat:@"categoryName%d", (int)i];
        NSString *catName = [NSString stringWithFormat:@"categName%d", (int)i];

        SEL sel = NSSelectorFromString(catName);
        if ([self respondsToSelector:sel]) {
            id val = [self valueForKey:catName];
            if (val) {
                [res addObject:val];
            } else {
                [res addObject:@""];
            }
        }
    }
    return res;
}

-(NSArray*)getTestCategorieValues {
    NSInteger numberofCategories = 17;
    NSMutableArray *res = [NSMutableArray array];
    for (NSInteger i = 1; i <= numberofCategories; i++) {
        // 04.03.2020 NSString *catName = [NSString stringWithFormat:@"categoryValue%d", (int)i];
        NSString *catValue = [NSString stringWithFormat:@"categValue%d", (int)i];

        SEL sel = NSSelectorFromString(catValue);
        if ([self respondsToSelector:sel]) {
            id val = [self valueForKey:catValue];
            if (val) {
                [res addObject:val];
            } else {
                [res addObject:@"0"];
            }
        }
    }
    return res;
}
@end
