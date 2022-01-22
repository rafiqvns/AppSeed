//
//  SelectObject.h
//  MobileOffice
//
//  Created by .D. .D. on 6/13/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SelectObject <NSObject>
-(void)didSelectObject:(RCOObject*)object;
-(void)didSelectObjectDict:(NSDictionary*)object;

@end
