//
//  RCOObject+CoreDataProperties.h
//  
//
//  Created by .D. .D. on 5/9/18.
//
//

#import "RCOObject.h"


NS_ASSUME_NONNULL_BEGIN

@interface RCOObject (CoreDataProperties)

+ (NSFetchRequest<RCOObject *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *active;
@property (nullable, nonatomic, copy) NSString *cat1;
@property (nullable, nonatomic, copy) NSString *creatorRecordId;
@property (nullable, nonatomic, copy) NSString *companyName;
@property (nullable, nonatomic, copy) NSString *companyId;
@property (nullable, nonatomic, copy) NSDate *dateTime;
@property (nullable, nonatomic, copy) NSString *deviceId;
@property (nullable, nonatomic, copy) NSNumber *fileIsDownloading;
@property (nullable, nonatomic, copy) NSNumber *fileIsUploading;
@property (nullable, nonatomic, copy) NSString *fileLog;
@property (nullable, nonatomic, copy) NSNumber *fileNeedsDownloading;
@property (nullable, nonatomic, copy) NSNumber *fileNeedsUploading;
@property (nullable, nonatomic, copy) NSString *functionalGroupName;
@property (nullable, nonatomic, copy) NSString *functionalGroupObjectId;
@property (nullable, nonatomic, copy) NSString *itemType;
@property (nullable, nonatomic, copy) NSString *objectDescription;
@property (nullable, nonatomic, copy) NSNumber *objectIsDownloading;
@property (nullable, nonatomic, copy) NSNumber *objectIsUploading;
@property (nullable, nonatomic, copy) NSString *objectLog;
@property (nullable, nonatomic, copy) NSNumber *objectNeedsDeleting;
@property (nullable, nonatomic, copy) NSNumber *objectNeedsDownloading;
@property (nullable, nonatomic, copy) NSNumber *objectNeedsUploading;
@property (nullable, nonatomic, copy) NSString *processed;
@property (nullable, nonatomic, copy) NSString *rcoBarcode;
@property (nullable, nonatomic, copy) NSString *rcoBarcodeParent;
@property (nullable, nonatomic, copy) NSNumber *rcoFileSize;
@property (nullable, nonatomic, copy) NSNumber *rcoFileTimestamp;
@property (nullable, nonatomic, copy) NSString *rcoFileType;
@property (nullable, nonatomic, copy) NSString *rcoMobileRecordId;
@property (nullable, nonatomic, copy) NSString *rcoObjectClass;
@property (nullable, nonatomic, copy) NSString *rcoObjectId;
@property (nullable, nonatomic, copy) NSString *rcoObjectParentId;
@property (nullable, nonatomic, copy) NSString *rcoObjectSearchString;
@property (nullable, nonatomic, copy) NSNumber *rcoObjectTimestamp;
@property (nullable, nonatomic, copy) NSString *rcoObjectType;
@property (nullable, nonatomic, copy) NSString *rcoRecordId;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *number;
@property (nullable, nonatomic, copy) NSString *notes;

@end

NS_ASSUME_NONNULL_END
