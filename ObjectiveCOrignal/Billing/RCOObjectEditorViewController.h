//
//  RCOObjectEditorViewController.h
//  MobileOffice
//
//  Created by .R.H. on 11/18/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCODataViewController.h"

#define KEY_CONTENT    @"recordContent"

@interface RCOObjectEditorViewController : RCODataViewController
{
    RCOObject *m_obj;
    NSMutableDictionary *m_objDict;
    NSMutableDictionary *m_linkedControls;
    
    Boolean m_isEditingObject;
}

@property (nonatomic, strong) RCOObject *obj;
@property (nonatomic, strong) NSMutableDictionary *objDict;
@property (nonatomic, strong) NSMutableDictionary *linkedControls;
@property (nonatomic, assign) Boolean isEditingObject;
@property (nonatomic, strong) UIAlertView *alertView;


- (void) setObjectValue: (NSObject *) theValue forKey: (NSString *) theKey;
- (void) setObjectValue: (NSObject *) theValue forKey: (NSString *) theKey fromControl:(UIControl *) aControl;

// linked conrols
- (void) refreshedLinkedControl: (NSString *) theKey;
- (void) linkControl: (UIControl *) aControl toKey: (NSString *) theKey;
- (IBAction)textFieldChanged:(id)sender;

// editing state
- (void) endObjectEditing;
- (void) startObjectEditing;
- (Boolean) saveObjectEdits;
- (void) cancelObjectEdits;
- (void) updateLinkedControlsEditingEnabledState: (Boolean) enabled;

- (void) setObj:(RCOObject *)anObj;
- (void) setObj:(RCOObject *)anObj withDetails: (Boolean) includeDetails;
- (Boolean) dirty;

// detail
- (void) setDetailObj: (RCOObject *) detailObj;
- (void) removeDetailObj: (RCOObject *) detailObj;
- (void) addDetail: (RCOObject *) detailObj;
- (void) deleteDetail: (RCOObject *) detailObj;
- (NSString *) buildKeyForDetailObj: (RCOObject *) theObj andKey: (NSString *) theKey;
- (RCOObject *) getObjFromKey: (NSString *) theKey;

- (void)closePopover;

@end
