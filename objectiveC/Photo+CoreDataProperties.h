//
//  Photo+CoreDataProperties.h
//  
//
//  Created by Dragos Dragos on 12/5/18.
//
//

#import "Photo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

+ (NSFetchRequest<Photo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *parentBarcode;
@property (nullable, nonatomic, copy) NSString *parentObjectId;
@property (nullable, nonatomic, copy) NSString *parentObjectType;
@property (nullable, nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
