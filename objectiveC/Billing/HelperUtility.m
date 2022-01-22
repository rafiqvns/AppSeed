//
//  HelperUtility.m
//  CSD
//
//  Created by TOxIC on 24/09/2020.
//  Copyright © 2020 RCO. All rights reserved.
//


#define HelperSharedManager (helperSharedManager? helperSharedManager:[HelperUtility helperSharedManager])

#import "HelperUtility.h"

HelperUtility *helperSharedManager = nil;

@implementation HelperUtility

+ (HelperUtility *) helperSharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // check to see if an instance already exists
        helperSharedManager = [[[self class] alloc] init];
    });
    
    // return the instance of this class
    return helperSharedManager;
}

- (BOOL)isCheckNotNULL:(id)parameter
{
    bool(^checkStringNotNull)(NSString *) = ^bool(NSString * tempString)
    {
        if (![tempString isEqualToString:@""] && ![tempString isEqualToString:@"(null)"] && ![tempString isEqualToString:@"<null>"] && ![tempString isEqualToString:@"null"] && ![tempString isEqualToString:@"none"])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    };
    
    if (![parameter isKindOfClass:[NSNull class]] && parameter != nil && parameter != NULL)
    {
        if ([parameter isKindOfClass:[NSString class]])
        {
            return checkStringNotNull(parameter);
        }
        else if (([parameter isKindOfClass:[NSMutableAttributedString class]]) || ([parameter isKindOfClass:[NSAttributedString class]]))
        {
            return checkStringNotNull([parameter string]);
        }
        else if ([parameter isKindOfClass:[NSArray class]] || [parameter isKindOfClass:[NSDictionary class]])
        {
            if (parameter) // [parameter count]
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}



@end
