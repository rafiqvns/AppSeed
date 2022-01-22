//
//  SignatureDetail.h
//  MobileOffice
//
//  Created by .D. .D. on 5/10/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignatureDetail : RCOObject

// Insert code here to declare functionality of your managed object subclass

-(NSString*)CSVFormat;

@end

NS_ASSUME_NONNULL_END

#import "SignatureDetail+CoreDataProperties.h"
