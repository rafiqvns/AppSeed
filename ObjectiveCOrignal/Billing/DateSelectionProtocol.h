//
//  DateSelectionProtocol.h
//  MobileOffice
//
//  Created by .D. .D. on 12/28/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DateSelectionProtocol <NSObject>
-(void)dateSelected:(NSDate*)date forOption:(NSInteger)option;
@end
