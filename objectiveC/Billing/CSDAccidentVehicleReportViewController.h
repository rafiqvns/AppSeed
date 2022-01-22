//
//  CSDAccidentVehicleReportViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "MWPhotoBrowserPlus.h"

@class AccidentVehicleReport;

@interface CSDAccidentVehicleReportViewController : HomeBaseViewController <AddObject, UITextFieldDelegate, UIDocumentBrowserViewControllerDelegate, MWPhotoBrowserDelegate, MWPhotoBrowserDelegatePlus> {
    
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AccidentVehicleReport *header;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *playBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *possRecvBtn;

@property (nonatomic, strong) IBOutlet UISegmentedControl *turnsBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *turnsControlBtn;

@property (nonatomic, strong) NSString *formNumber;

-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)notesButtonPressed:(id)sender;

-(IBAction)signatureButtonPressed:(id)sender;

-(IBAction)photosButtonPressed:(id)sender;
-(IBAction)witnessesButtonPressed:(id)sender;
-(IBAction)trailerButtonPressed:(id)sender;
-(IBAction)vehiclesButtonPressed:(id)sender;

-(IBAction)stopButtonPressed:(id)sender;
-(IBAction)possibleReceivedButtonPressed:(id)sender;
-(IBAction)turnsChanged:(id)sender;

@end
