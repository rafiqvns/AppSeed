//
//  Attachment+CoreDataProperties.h
//  
//
//  Created by .D. .D. on 8/2/18.
//
//

#import "Attachment+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Attachment (CoreDataProperties)

+ (NSFetchRequest<Attachment *> *)fetchRequest;


@end

NS_ASSUME_NONNULL_END
