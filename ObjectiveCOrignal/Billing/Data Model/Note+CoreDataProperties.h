//
//  Note+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 1/4/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import "Note+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Note (CoreDataProperties)

+ (NSFetchRequest<Note *> *)fetchRequest;


@end

NS_ASSUME_NONNULL_END
