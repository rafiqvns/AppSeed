//
//  CSDTestSelectObject.h
//  CSD
//
//  Created by .D. .D. on 11/13/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#ifndef CSDTestSelectObject_h
#define CSDTestSelectObject_h


@protocol CSDSelectObject <NSObject>
-(void)CSDInfoDidSelectObject:(NSString*)parentMobileRecordId;
-(void)CSDInfoDidSavedObject:(NSString*)parentMobileRecordId;
-(BOOL)CSDInfoCanSelectScreen;
-(NSString*)CSDInfoScreenTitle;
-(void)CSDSaveRecordOnServer:(BOOL)onServer;
-(BOOL)CSDNeedsToSign;
@end

#endif /* CSDTestSelectObject_h */
