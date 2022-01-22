//
//  HelperUtility.h
//  CSD
//
//  Created by TOxIC on 24/09/2020.
//  Copyright © 2020 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelperUtility : NSObject

+(HelperUtility *) helperSharedManager;

- (BOOL)isCheckNotNULL:(id)parameter;


@end

extern HelperUtility *helperSharedManager;

#define HelperSharedManager (helperSharedManager? helperSharedManager:[HelperUtility helperSharedManager])

NS_ASSUME_NONNULL_END

