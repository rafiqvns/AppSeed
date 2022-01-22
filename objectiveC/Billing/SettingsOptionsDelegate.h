//
//  SettingsOptionsDelegate.h
//  MobileOffice
//
//  Created by .D. .D. on 5/10/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kCreditsRow,
    kSyncRow,
    kDrivingRuleRow,
    kFilesRow,
    kInfoRow,
    kLegalRow,
    kLicenseRow,
    kLoginRow,
#ifdef RCOLOGGING
    kLogRow,
#endif
    kNetworkRow,
    kPartNonTrackedRow,
    kPaymentRow,
    kServicesRow,
    kPartTrackedRow,
    kWallpaperRow,
    kNumSettingsRows
} ;

@protocol SettingsOptionsDelegate <NSObject>

-(void)selectionChanged:(NSInteger)index;

@end
