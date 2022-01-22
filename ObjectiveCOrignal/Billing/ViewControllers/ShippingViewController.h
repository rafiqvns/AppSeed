//
//  ShippingViewController.h
//  MobileOffice
//
//  Created by Rosalind Hartigan on 12/1/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "RCOObjectEditorViewController.h"
#import "Part.h"
#import "ShippingHeader_Imp.h"
#import "ShippingDetail.h"
#import "ShippingAggregate.h"

@interface ShippingViewController : RCOObjectEditorViewController <UITextFieldDelegate, UIPopoverControllerDelegate> {
    UITableView *tableInv;
    UITableViewCell *customInvCell;
    UITableView *tableInvItem;
    UITableViewCell *customInvItemCell;
    UITextField *m_activeField;
    UIBarButtonItem *m_unlockButton;
    
    NSArray* m_shippingHeaders;
    NSMutableArray* m_shippingDetails;
}

@property (nonatomic, retain) IBOutlet UITableView *tableInv;
@property (nonatomic, retain) IBOutlet UITableViewCell *customInvCell;
@property (nonatomic, retain) IBOutlet UITableView *tableInvItem;
@property (nonatomic, retain) IBOutlet UITableViewCell *customInvItemCell;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *unlockButton;

@property (nonatomic, retain) UITextField *activeField;
@property (nonatomic, retain) NSArray* shippingHeaders;
@property (nonatomic, retain) NSMutableArray* shippingDetails;



- (void) openPartsListFromRect: (CGRect) aRect inView: (UIView *) aView;
- (void) addPart:(Part *) aPart;
- (void) newShippingDetail:(Part *) aPart;
- (void) deleteShippingDetail:(NSIndexPath *) ip;

// sub editors
- (IBAction) openStoresList:(id)sender;
- (IBAction) openSignatureEditor:(id)sender;
- (IBAction) openCalendar: (id) sender;
// object editing and manipulation
- (void) setShippingHeader:(ShippingHeader *)sh;
- (IBAction) addShippingHeader: (id) sender;
- (IBAction) deleteShippingHeader: (id) sender;

// handle moving keyboard
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)keyboardWillHide:(NSNotification *)notif;
- (void)keyboardWillShow:(NSNotification *)notif;
-(void)setViewMovedUp:(BOOL)movedUp;

// RCODataViewController subclass override
- (ShippingAggregate *) aggregate;



@end
