//
//  PickerSelectionProtocol.h
//  MobileOffice
//
//  Created by .D. .D. on 12/28/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PickerSelectionProtocol <NSObject>
-(void)pickerSelected:(NSString*)value forOption:(NSInteger)option;
@end
