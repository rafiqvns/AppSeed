//
//  CSDTestViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/16/2019.
//  Copyright (c) 2019 RCO. All rights reserved.
//
#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "CSDTestSelectObject.h"
#import "ServerManager.h"
#import "HelperUtility.h"

@class TestDataHeader;

@interface CSDTestViewController : HomeBaseViewController <AddObject, UITextFieldDelegate, UIDocumentBrowserViewControllerDelegate, CSDSelectObject, UITextViewDelegate> {
    
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TestDataHeader *header;
@property (nonatomic, strong) NSArray *fieldsNA;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *playBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *possRecvBtn;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *currentSectionBtn;

@property (nonatomic, strong) NSString *formNumber;
@property (nonatomic, assign) BOOL addParentMobileRecordId;

@property (nonatomic, assign) id<CSDSelectObject> CSDDelegate;

-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)notesButtonPressed:(id)sender;
-(IBAction)signatureButtonPressed:(id)sender;
-(IBAction)startButtonPressed:(id)sender;
-(IBAction)stopButtonPressed:(id)sender;
-(IBAction)possibleReceivedButtonPressed:(id)sender;
-(IBAction)turnsChanged:(id)sender;
-(IBAction)currentSectionButtonPressed:(id)sender;



@end
