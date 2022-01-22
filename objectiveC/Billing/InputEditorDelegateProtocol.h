//
//  InputEditorDelegateProtocol.h
//  MobileOffice
//
//  Created by .D. .D. on 1/2/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InputEditorDelegateProtocol <NSObject>
-(void)inputEditor:(NSInteger)editorId didSelectOption:(NSInteger)option;
-(void)inputEditor:(NSInteger)editorId didChangeValue:(NSString*)value forOption:(NSInteger)option;
-(void)inputEditor:(NSInteger)editorId didChangeValue:(NSObject*)value forKey:(NSString*)key;

@end
