//
//  SelectOptionProtocol.h
//  MobileOffice
//
//  Created by .D. .D. on 1/25/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SelectOptionProtocol <NSObject>
@optional
-(void)didSelectObject:(NSObject*)object forKey:(NSString*)key;
-(void)didSelectObjects:(NSArray*)objects forKeys:(NSArray*)keys;
@end
