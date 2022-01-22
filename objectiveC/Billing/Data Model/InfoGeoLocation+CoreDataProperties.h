//
//  InfoGeoLocation+CoreDataProperties.h
//  
//
//  Created by .D. .D. on 5/9/18.
//
//

#import "InfoGeoLocation.h"


NS_ASSUME_NONNULL_BEGIN

@interface InfoGeoLocation (CoreDataProperties)

+ (NSFetchRequest<InfoGeoLocation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *latitude;
@property (nullable, nonatomic, copy) NSString *longitude;

@end

NS_ASSUME_NONNULL_END
