//
//  SignatureDetail+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 5/16/16.
//  Copyright © 2016 RCO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SignatureDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignatureDetail (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *documentDate;
@property (nullable, nonatomic, retain) NSString *documentTitle;
@property (nullable, nonatomic, retain) NSString *documentType;
@property (nullable, nonatomic, retain) NSDate *expirationDate;
@property (nullable, nonatomic, retain) NSString *issuingAuthority;
@property (nullable, nonatomic, retain) NSString *itemType;
@property (nullable, nonatomic, retain) NSString *recordDescription;
@property (nullable, nonatomic, retain) NSString *reviewedBy;
@property (nullable, nonatomic, retain) NSDate *reviewedDate;
@property (nullable, nonatomic, retain) NSDate *signatureDate;
@property (nullable, nonatomic, retain) NSString *signatureName;
@property (nullable, nonatomic, retain) NSString *parentObjectId;
@property (nullable, nonatomic, retain) NSString *parentObjectType;

@end

NS_ASSUME_NONNULL_END
