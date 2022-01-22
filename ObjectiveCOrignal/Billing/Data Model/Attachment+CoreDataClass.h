//
//  Attachment+CoreDataClass.h
//  
//
//  Created by .D. .D. on 8/2/18.
//
//

#import <Foundation/Foundation.h>
#import "Photo+Photo_Imp.h"

NS_ASSUME_NONNULL_BEGIN

@interface Attachment : Photo
- (NSString*)CSVFormat;
- (NSString*)parentRecordId;
@end

NS_ASSUME_NONNULL_END

#import "Attachment+CoreDataProperties.h"
