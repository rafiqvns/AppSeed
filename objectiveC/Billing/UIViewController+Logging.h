//
//  UIViewController+Logging.h
//  MobileOffice
//
//  Created by .D. .D. on 12/2/14.
//  Copyright (c) 2014 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kEmailSubject @"emailSubject"
#define kEmailFilePath @"emailPath"
#define kEmailBody @"emailBody"
#define kEmailMimeType @"emailMimeType"
#define kEmailBodyIsPlain @"emailBodyIsPlain"

@interface UIViewController (Logging)
-(void)log:(NSString*)stringToLog toFile:(NSString*)fileName;
-(void)emailFile:(NSDictionary*)emailInfo;
@end
