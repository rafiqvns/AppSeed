//
//  RCOFilterSelectionDelegate.h
//  MobileOffice
//
//  Created by .D. .D. on 6/22/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCOObject;

@protocol RCOFilterSelectionDelegate <NSObject>
@optional
-(void)filterSelectionChanged:(NSInteger)index;
-(void)filterSelectionChanged:(NSInteger)invoiceStatus dateIndex:(NSInteger)dateIndex;
-(void)filterSelectionChanged:(NSInteger)index forObject:(RCOObject *)object;
-(void)filterSelectionChangedWithOptions:(NSArray*)options;

@end
