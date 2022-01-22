//
//  AddObject.h
//  MobileOffice
//
//  Created by .D. .D. on 3/14/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectOptionProtocol.h"

@class RCOObject;

@protocol AddObject <SelectOptionProtocol>
// for iPad when using popover
@optional
-(void)didCancelObject:(RCOObject*)object;

-(void)didAddObject:(NSObject*)object forKey:(NSString*)key;
-(void)didAddObjects:(NSArray*)objects forKeys:(NSArray*)keys;

-(void)didSaveObject:(RCOObject*)object;
-(void)didRemoveObject:(RCOObject*)object;
-(void)didRemoveObjects:(NSArray*)objects forKey:(NSString*)key;

-(void)didUpdateObject:(RCOObject*)object;
-(void)didUpdateObject:(RCOObject*)object withInfo:(NSDictionary*)info;
@end
