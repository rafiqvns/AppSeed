//
//  InfoUser+CoreDataProperties.h
//  
//
//  Created by .D. .D. on 12/5/18.
//
//

#import "InfoUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface InfoUser (CoreDataProperties)

+ (NSFetchRequest<InfoUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, copy) NSString *userRecordId;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *zip;
@property (nullable, nonatomic, copy) NSString *address1;

@end

NS_ASSUME_NONNULL_END
