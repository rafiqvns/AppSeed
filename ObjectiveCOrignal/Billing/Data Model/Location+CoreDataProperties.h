//
//  Location+CoreDataProperties.h
//  
//
//  Created by .D. .D. on 4/17/18.
//
//

#import "Location+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address1;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *country;
@property (nullable, nonatomic, copy) NSString *number;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *zipcode;

@end

NS_ASSUME_NONNULL_END
