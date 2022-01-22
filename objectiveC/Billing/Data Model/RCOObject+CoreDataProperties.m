//
//  RCOObject+CoreDataProperties.m
//  
//
//  Created by .D. .D. on 5/9/18.
//
//

#import "RCOObject+CoreDataProperties.h"

@implementation RCOObject (CoreDataProperties)

+ (NSFetchRequest<RCOObject *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RCOObject"];
}

@dynamic active;
@dynamic cat1;
@dynamic creatorRecordId;
@dynamic companyName;
@dynamic companyId;
@dynamic dateTime;
@dynamic deviceId;
@dynamic fileIsDownloading;
@dynamic fileIsUploading;
@dynamic fileLog;
@dynamic fileNeedsDownloading;
@dynamic fileNeedsUploading;
@dynamic functionalGroupName;
@dynamic functionalGroupObjectId;
@dynamic itemType;
@dynamic objectDescription;
@dynamic objectIsDownloading;
@dynamic objectIsUploading;
@dynamic objectLog;
@dynamic objectNeedsDeleting;
@dynamic objectNeedsDownloading;
@dynamic objectNeedsUploading;
@dynamic processed;
@dynamic rcoBarcode;
@dynamic rcoBarcodeParent;
@dynamic rcoFileSize;
@dynamic rcoFileTimestamp;
@dynamic rcoFileType;
@dynamic rcoMobileRecordId;
@dynamic rcoObjectClass;
@dynamic rcoObjectId;
@dynamic rcoObjectParentId;
@dynamic rcoObjectSearchString;
@dynamic rcoObjectTimestamp;
@dynamic rcoObjectType;
@dynamic rcoRecordId;
@dynamic status;
@dynamic name;
@dynamic number;
@dynamic notes;

@end
