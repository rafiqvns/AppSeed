//
//  SignatureDetailAggregate.h
//  MobileOffice
//
//  Created by .D. .D. on 5/16/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import "Aggregate.h"

#define SS @"SS"

@class SignatureDetail;

@interface SignatureDetailAggregate : Aggregate

@property (nonatomic, strong) NSString *itemType;

-(SignatureDetail*)getDetailForParentObjectId:(NSString*)parentId andType:(NSString*)documentTitle;
-(NSArray*)getDetailsForParentObjectId:(NSString*)parentId;

-(SignatureDetail*)getDetailForParentId:(NSString*)parentId andType:(NSString*)documentTitle;
-(SignatureDetail*)getDetailForParentBarcode:(NSString*)parentBarcode andType:(NSString*)documentTitle;
-(void)getSignaturesForMasterBarcode:(NSString*)masterBarcode;

@end
