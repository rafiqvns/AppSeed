//
//  OptionEditorDelegate.h
//  MobileOffice
//
//  Created by .D. .D. on 4/22/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OptionEditorDelegate <NSObject>
- (void) selectedStringValue:(NSString*)value forKey:(NSString*)key;
@end
