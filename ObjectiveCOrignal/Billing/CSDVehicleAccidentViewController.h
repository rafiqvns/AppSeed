//
//  CSDVehicleAccidentViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "AccidentVehicleReport+CoreDataClass.h"
#import "MWPhotoBrowserPlus.h"

@class AccidentVehicle;

@interface CSDVehicleAccidentViewController : HomeBaseViewController <AddObject, UITextFieldDelegate, MWPhotoBrowserDelegate, MWPhotoBrowserDelegatePlus> {
    
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id accidentRecord;
@property (nonatomic, strong) AccidentVehicleReport *accident;
@property (nonatomic, assign) AccidentRecordType recordType;


-(IBAction)deleteButtonPressed:(id)sender;

@end
