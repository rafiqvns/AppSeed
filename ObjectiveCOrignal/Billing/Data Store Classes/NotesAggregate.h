//
//  NotesAggregate.h
//  MobileOffice
//
//  Created by .D. .D. on 1/4/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import "Aggregate.h"
#define SN @"SN"

@interface NotesAggregate : Aggregate

-(NSArray*)getNotesForObject:(RCOObject*)obj;
-(NSArray*)getNotesForObjectId:(NSString*)objId;
-(NSArray*)getNotesForObject:(RCOObject*)obj andCategory:(NSString*)category;
-(NSArray*)getNotesForObject:(RCOObject*)obj andDate:(NSDate*)date;
-(void)getNotesForMasterBarcode:(NSString*)masterBarcode;
-(NSArray*)getAllNotes;

@end
