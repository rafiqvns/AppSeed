//
//  CSDVehicleAccidentViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDVehicleAccidentViewController.h"
#import "InputCell.h"
#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"
#import "RCOValuesListViewController.h"
#import "NSDate+TKCategory.h"
#import "AccidentVehicle+CoreDataClass.h"
#import "AccidentVehicleReport+CoreDataClass.h"
#import "CSDAccidentVehicleAggregate.h"
#import "CSDAccidentTrailerDollieAggregate.h"
#import "CSDAccidentWitnessAggregate.h"
#import "PhotosAggregate.h"
#import "UIImage+Resize.h"
#import "Photo.h"

@interface CSDVehicleAccidentViewController ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *fieldsNames;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *disabledFields;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *percentageFields;
@property (nonatomic, strong) NSArray *numericFields;

@property (nonatomic, strong) NSArray *datePickerFieldsNames;

@property (nonatomic, strong) NSDate *dateTime;

// Photos ....
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *photosToSave;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSMutableDictionary *photosInfo;
@property (nonatomic, strong) MWPhotoBrowserPlus *browser;

#define Key_Photos @"Photos"
#define Key_Class @"driverLicenseClass"

@end

@implementation CSDVehicleAccidentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveTapped:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    if (self.recordType == AccidentRecordTypeVehicle) {
        self.fields = [NSArray arrayWithObjects:@"firstName", @"lastName", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseExpirationDate", @"address1", @"city", @"state", @"zip", @"driverLicenseClass", @"homePhone", @"workPhone", @"mobilePhone", @"vehicleType", @"vehicleMake", @"vehicleModel", @"vin", @"vehicleYear", @"combinationVehicle", @"descriptionOfDamage", @"number",@"insuranceCompany",@"insuranceAgent",@"insurancePhone", @"insurancePolicyNumber", @"insuranceExpirationDate", @"insuranceAddress", @"insuranceCity", @"insuranceState", @"insuranceZipcode", @"insuredByDriver", @"registrationNumber", @"registrationExpirationDate", @"registrationName", @"registrationAddress", @"registrationCity", @"registrationState", @"registrationZipcode", @"registeredByDriver", @"employedBy", @"assignedLocation", @"companyAddress", @"companyCity", @"companyState", @"companyZipcode", @"companyPhone", @"notes", @"dateofBirth", nil];
        
        
        self.fieldsNames = [NSArray arrayWithObjects:@"Driver First Name", @"Driver Last Name", @"Driver License Number", @"Driver License State", @"Driver License Expiration Date", @"Driver Address", @"Driver City", @"Driver State", @"Driver Zipcode", @"Driver License Class", @"Driver Home Phone", @"Driver Work Phone", @"Driver Mobile Phone", @"Vehicle Type", @"Vehicle Make",@"Vehicle Model", @"VIN", @"Vehicle Year",@"Combination Vehicle", @"Description Of Damage", @"License Plate Number", @"Insurance Company",@"Insurance Agent",@"Insurance Phone", @"Insurance Policy Number", @"Insurance Expiration Date", @"Insurance Address", @"Insurance City", @"Insurance State", @"Insurance Zipcode", @"Insured By Driver", @"Registration Number", @"Registration Expiration Date", @"Registration Name", @"Registration Address", @"Registration City", @"Registration State", @"Registration Zipcode", @"Registered by Driver", @"Employed By", @"Assigned Location", @"Company Address", @"Company City", @"Company State", @"Company Zipcode", @"Company Phone", @"Notes", @"Date of Birth", nil];
        
        self.requiredFields = [NSArray arrayWithObjects:@"firstName", @"lastName", @"driverLicenseNumber", @"number", nil];
        self.datePickerFieldsNames = [NSArray arrayWithObjects:@"dateTime", @"driverLicenseExpirationDate", @"insuranceExpirationDate", @"dateofBirth", @"registrationExpirationDate", nil];
        self.switchFields = [NSArray arrayWithObjects:@"insuredByDriver", @"registeredByDriver", @"combinationVehicle", nil];
        self.numericFields = [NSArray arrayWithObjects:@"homePhone", @"mobilePhone", @"workPhone", @"vehicleYear", @"companyPhone", @"companyZipcode", @"zip", nil];
        self.pickerFields = [NSArray arrayWithObjects: Key_Class, nil];

    } else if (self.recordType == AccidentRecordTypeTrailerDollie) {
        self.fields = [NSArray arrayWithObjects:@"inspectionCurrent", @"licensePlateNumber", @"licenseState", @"registrationCurrent", @"trailerSize", @"trailerMake", @"dollyType", @"notes", nil];
        self.fieldsNames = [NSArray arrayWithObjects:@"Inspection Current", @"License Plate Number", @"License State", @"Registration Current", @"Trailer Size", @"Trailer Make", @"Dolly Type", @"Notes",  nil];
        self.requiredFields = [NSArray arrayWithObjects:@"licensePlateNumber", @"dollyType", nil];
        
        self.switchFields = [NSArray arrayWithObjects:@"registrationCurrent", @"inspectionCurrent", nil];

    } else if (self.recordType == AccidentRecordTypeWitness) {
        self.fields = [NSArray arrayWithObjects:@"firstName", @"lastName", @"driverLicenseNumber", @"homePhone", @"workPhone", @"mobilePhone", @"notes", nil];
        self.fieldsNames = [NSArray arrayWithObjects:@"First Name", @"Last Name", @"Driver License Number", @"Home Phone", @"Work Phone", @"Mobile Phone", @"Notes", nil];
        self.requiredFields = [NSArray arrayWithObjects:@"firstName", @"lastName", nil];
        self.numericFields = [NSArray arrayWithObjects:@"homePhone", @"mobilePhone", @"workPhone", nil];
    }
    
    if (self.accidentRecord) {
        //self.disabledFields = [NSArray arrayWithObjects:@"account", @"debit", @"credit", nil];
    }

    self.values = [NSMutableDictionary dictionary];
    
    [self loadObject];
    self.title = [self getScreenTitle];
    
    if (self.recordType == AccidentRecordTypeVehicle) {
        // we need to add photos for vehicles....
        NSMutableArray *items = [NSMutableArray arrayWithArray:[self.bottomToolbar items]];
        UIBarButtonItem *photosBtn = [[UIBarButtonItem alloc] initWithTitle:@"Photos"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(photosButtonPressed:)];
        [items insertObject:photosBtn atIndex:0];
        [self.bottomToolbar setItems:items animated:YES];
        [self getPhotos];
    }
}

-(void)loadNotes {
}

-(NSString*)getScreenTitle {
    if (self.recordType == AccidentRecordTypeVehicle) {
        return @"Vehicle in Accident";
    } else if (self.recordType == AccidentRecordTypeTrailerDollie) {
        return @"Trailer Dollie in Accident";
    } else if (self.recordType == AccidentRecordTypeWitness) {
        return @"Witnesses";
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self aggregate] registerForCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self aggregate] unRegisterForCallback:self];
}

-(void)loadObject {
    for (NSString *field in self.fields) {
        NSString *value = [self.accidentRecord valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }
    [self.tableView reloadData];
}

-(void)getPhotos {
    RCOObject *parentObj = (RCOObject*)self.accidentRecord;
    
    if ([parentObj existsOnServerNew]) {
        PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
        
        [agg getPhotosForMasterBarcode:parentObj.rcoBarcode];
    }
}

#pragma mark Actions
-(IBAction)photosButtonPressed:(id)sender {
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    
    RCOObject *parentObj = (RCOObject*)self.accidentRecord;
    
    NSArray *photos = [agg getPhotosForObject:parentObj];
    
    self.photos = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    self.selections = [NSMutableArray array];
    
    self.photosInfo = [NSMutableDictionary dictionary];
    
    for (RCOObject *photo in photos) {
        MWPhoto *photoObject = nil;
        
        if ([photo existsOnServerNew]) {
            NSString *str = nil;
            
            // we should get the fullImage
            str = [photo getImageURL:YES];
            NSLog(@"LINK = %@", str);
            
            photoObject = [MWPhoto photoWithURL:[NSURL URLWithString:str]];
            [photoObject setCaption:@"RMS"];
            
            [self.photos addObject:photoObject];
            [self.selections addObject:[NSNumber numberWithBool:NO]];
            
            // we should get the url for thumbnail
            str = [photo getImageURL:NO];
            [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:str]]];
        } else {
            // we should load from local DB
            UIImage *img = [agg getImageForObject:photo.rcoMobileRecordId];
            photoObject = [MWPhoto photoWithImage:img];
            [photoObject setCaption:@"Locally"];
            
            [self.photos addObject:photoObject];
            [self.selections addObject:[NSNumber numberWithBool:NO]];
            [self.thumbs addObject:[MWPhoto photoWithImage:img]];
        }
        if (photoObject) {
            [self.photosInfo setObject:photoObject forKey:photo.rcoObjectId];
        }
    }
    
    // Create browser
    self.browser = [[MWPhotoBrowserPlus alloc] initWithDelegate:self];
    // new properties
    self.browser.delegatePlus = self;
    self.browser.displayActionButtonAllTheTime = YES;
    self.browser.displayAddButton = YES;
    self.browser.displaySaveButton = YES;
    
    self.browser.displayActionButton = YES;
    self.browser.displayNavArrows = YES;
    //browser.displaySelectionButtons = YES;
    self.browser.alwaysShowControls = YES;
    self.browser.zoomPhotosToFill = YES;
    self.browser.enableGrid = YES;
    if (photos.count) {
        //09.10.2018 we should show the grid
        self.browser.startOnGrid = YES;
    } else {
        // 09.10.2018 we shoul not start with grid
        NSLog(@"");
    }
    self.browser.enableSwipeToDismiss = NO;
    self.browser.autoPlayOnAppear = YES;
    
    self.browser.addDelegateKey = Key_Photos;
    self.browser.addDelegate = self;
    
    [self.browser setCurrentPhotoIndex:0];
    
    if (DEVICE_IS_IPHONE) {
        [self.navigationController pushViewController:self.browser animated:YES];
    } else {
        [self showPopoverModalForViewController:self.browser];
    }
}

-(IBAction)cancelButtonPressed:(id)sender {
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)saveTapped:(id)sender {
    NSString *message = [self validateInputs];
    
    if (message) {
        [self showSimpleMessage:message];
        return;
    }
    
    if (self.accidentRecord) {
        self.progressHUD.labelText = @"Update record...";
    } else {
        self.progressHUD.labelText = @"Create record...";
    }
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    
    [self performSelector:@selector(createOrUpdateRecord) withObject:nil afterDelay:0.1];
}

-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)createOrUpdateRecord {
    
    RCOObject *v = nil;
    
    if (!self.accidentRecord) {
        v = [[self aggregate] createNewObject];
        v.dateTime = [NSDate date];
    } else {
        // if the item exists the we should update it
        v = (RCOObject*)self.accidentRecord;
    }
    
    for (NSString *field in self.fields) {
        id val = [self.values objectForKey:field];
        if (val) {
            if ([self.switchFields containsObject:field]) {
                [v setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [v setValue:val forKey:field];
            }
        }
    }
    
    v.rcoBarcodeParent = self.accident.rcoBarcode;
    v.active = [NSNumber numberWithBool:YES];
    
    if (!self.accidentRecord) {
        self.accidentRecord = v;
    }
    
    [v setNeedsUploading:YES];
    [[self aggregate] createNewRecord:v];
}

-(IBAction)deleteButtonPressed:(id)sender {
    
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete current Record", nil)
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
                                                            NSLog(@"");
                                                        }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * action) {
                                                          NSLog(@"");
                                                      }];

    [al addAction:yesAction];
    [al addAction:noAction];

    [self presentViewController:al animated:YES completion:nil];
}

-(void)deleteCurrentItem  {
  /*
    [[self aggregate] destroyObj:self.account];
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
*/
}

-(NSString*)validateInputs {
    
    for (NSString *key in self.requiredFields) {
        NSObject *obj = [self.values objectForKey:key];
        if (!obj) {
            //get the coding field name
            NSInteger index = [self.fields indexOfObject:key];
            NSString *fieldName = [self.fieldsNames objectAtIndex:index];
            NSString *message = [NSString stringWithFormat:@"%@ was not set!", fieldName];
            return message;
        }
    }
    return nil;
}

#pragma mark UITableView methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.fields.count) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.fields.count) {
        return YES;
    }
    return NO;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fields.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *key = [self.fields objectAtIndex:section];
    NSString *title = [self.fieldsNames objectAtIndex:section];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *key = nil;
    NSString *value = nil;
    
    key = [self.fields objectAtIndex:indexPath.section];
    value = [self.values objectForKey:[NSString stringWithFormat:@"%@", key]];
    
    BOOL requiredField = [self.requiredFields containsObject:key];
    
    UILabel *requiredLbl = nil;
    if (requiredField) {
        requiredLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        requiredLbl.text = @"*";
        [requiredLbl setTextColor:[UIColor redColor]];
    }
    
    if ([self.switchFields containsObject:key]) {
        
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"switchCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCell"];
        }

        NSInteger keyIndex = [self.switchFields indexOfObject:key];

        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"No", @"Yes", nil]];
        seg.tag = keyIndex;
        seg.selectedSegmentIndex = [value integerValue];
        [seg addTarget:self
                action:@selector(segmentedControllerValueChanged:)
      forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = seg;

        /*
         19.08.2019
        UISwitch *sw = [[UISwitch alloc] init];
        
        sw.tag = keyIndex;
        sw.on = [value boolValue];

        [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
        */
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = key;
        // 27.05.2019 there is no point in displaying extra text for switch
        cell.textLabel.text = nil;
        cell.imageView.image = nil;
        return cell;

    } else if ([self.datePickerFieldsNames containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"dateCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
        }
        
        NSDate *date = [self.values objectForKey:key];
        
        if (date) {
            if ([key isEqualToString:@"dateTime"]) {
                cell.textLabel.text = [[self aggregate] rcoDateAndTimeToString:date];
            } else {
                cell.textLabel.text = [[self aggregate] rcoDateToString:date];
            }
        } else {
            cell.textLabel.text = nil;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = requiredLbl;
        cell.imageView.image = [UIImage imageNamed:@"CALENDAR"];
        return cell;
        
    } else if ([self.pickerFields containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"PickerCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PickerCell"];
        }
        cell.textLabel.text = value;
        
        if (value) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = requiredLbl;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = nil;
        return cell;
    }
    
    // we have input cell
    InputCell *inputCell = nil;
    
    inputCell = (InputCell*)[theTableView dequeueReusableCellWithIdentifier:@"InputCell"];
    
    if (inputCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InputCell"
                                                     owner:self
                                                   options:nil];
        inputCell = (InputCell *)[nib objectAtIndex:0];
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [NSString stringWithFormat:@"%@", value];
    }

    //configure input
    CGRect frame = inputCell.titleLabel.frame;
    // hide title label
    frame.size.width = 0;
    inputCell.titleLabel.frame = frame;
    // resize input field
    frame = inputCell.inputTextField.frame;
    frame.origin.x = 10;
    // we should maximize the width
    frame.size.width = inputCell.frame.size.width - 20;
    
    [inputCell.requiredLabel setHidden:!requiredField];
    
    inputCell.inputTextField.frame = frame;
    
    inputCell.inputTextField.delegate = self;
    
    [inputCell.inputTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    inputCell.inputTextField.tag = indexPath.section;
    
    inputCell.inputTextField.font = [UIFont boldSystemFontOfSize:19];
    
    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    inputCell.inputTextField.text = value;
    inputCell.inputTextField.inputAccessoryView = self.keyboardToolbar;

    if ([self.numericFields containsObject:key]) {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDefault;
    }

    if ([self.disabledFields containsObject:key]) {
        inputCell.inputTextField.enabled = NO;
        [inputCell.inputTextField setTextColor:[UIColor grayColor]];
    } else {
        inputCell.inputTextField.enabled = YES;
        if (@available(iOS 13,*)) {
            [inputCell.inputTextField setTextColor:[UIColor labelColor]];
        } else {
            [inputCell.inputTextField setTextColor:[UIColor darkTextColor]];
        }
    }
    
    inputCell.inputTextField.font = [UIFont systemFontOfSize:15];
    
    if ([self.percentageFields containsObject:key]) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        lbl.text = @"%";
        inputCell.accessoryView = lbl;
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDecimalPad;
    } else {
        inputCell.accessoryView = nil;
    }
    
    return inputCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSString *key = [self.fields objectAtIndex:indexPath.section];
    if ([key isEqualToString:Key_Class]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self showClassPickerFromView:cell];
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self showDatePickerFromView:cell andKey:key];
    }
}

- (void)showClassPickerFromView:(UIView*)fromView {
    
    NSArray *values = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:values
                                                                                                forKey:Key_Class];
    
    listController.selectDelegate = self;
    listController.title = @"Class";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *class = [self.values objectForKey:Key_Class];
    if (class) {
        listController.selectedValue = class;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}


-(void)switchValueChanged:(UISwitch*)aSwitch {
    //19.08.2019 changed from switch to segmented controller TODO:REMOVE
    NSInteger keyIndex = aSwitch.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    [self.values setObject:[NSNumber numberWithBool:aSwitch.on] forKey:key];
}

-(void)segmentedControllerValueChanged:(UISegmentedControl*)segCtrl {
    
    NSInteger keyIndex = segCtrl.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    [self.values setObject:[NSNumber numberWithBool:segCtrl.selectedSegmentIndex] forKey:key];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showDatePickerFromView:(UIView*)fromView andKey:(NSString*)key  {
    DateSelectorViewController *controller = [[DateSelectorViewController alloc] initWithNibName:@"DateSelectorViewController"
                                                                                          bundle:nil
                                                                                        forDates:[NSArray arrayWithObject:key]];
    controller.selectDelegate = self;
    controller.shouldPopUpOnIpad = YES;
    
    NSDate *date = [self.values objectForKey:key];
    
    if (!date) {
        date = [NSDate date];
    }
    
    controller.title = @"Date";
    controller.isSimpleDatePicker = YES;

    NSInteger index = [self.fields indexOfObject:key];
    if (index != NSNotFound) {
        NSString *name = [self.fieldsNames objectAtIndex:index];
        controller.dateNames = [NSArray arrayWithObject:name];
    }
    
    controller.currentDate = date;
    
    if (DEVICE_IS_IPHONE) {
        controller.isCancelNewLogic = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showPopoverForViewController:controller fromView:fromView];
    }
}

#pragma mark -
#pragma mark UItextFieldDelegate Methods

- (IBAction)textFieldChanged:(UITextField*) textField {
    NSString *keyString = [self.fields objectAtIndex:textField.tag];
    NSString *value = textField.text;
    [self.values setObject:[value stringByReplacingOccurrencesOfString:@"\n" withString:@" "] forKey:keyString];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([key isEqualToString:Key_Class]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    } else if ([object isKindOfClass:[NSDate class]]) {
        [self.values setObject:object forKey:key];
    }

    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self.tableView reloadData];
}

-(Aggregate*)aggregate {
    switch (self.recordType) {
        case AccidentRecordTypeVehicle:
            return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentVehicle"];
            break;
        case AccidentRecordTypeWitness:
            return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentWitness"];
            break;
        case AccidentRecordTypeTrailerDollie:
            return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentTrailerDollie"];
            break;
        default:
            break;
    }
    return nil;
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:V_I_A] ||
        [message isEqualToString:DIA] ||
        [message isEqualToString:WIT]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObject:self.accidentRecord forKey:self.addDelegateKey];
        }
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *errorMessage = [messageInfo objectForKey:@"errorMessage"];
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:V_I_A] ||
        [message isEqualToString:DIA] ||
        [message isEqualToString:WIT]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
    }
}

#pragma mark Keyboard Methods

- (void)keyboardWillHide:(NSNotification *)notif {
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

- (void)keyboardWillShow:(NSNotification *)notif{
    self.keyboardInfo = notif.userInfo;
    NSInteger keyBoardHeight = [[self.keyboardInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height;
    UIEdgeInsets contentInset = UIEdgeInsetsMake(0.0, 0.0, keyBoardHeight, 0.0);
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

#pragma mark - MWPhotoBrowserDelegate
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deleteCurrentPhoto:(NSInteger)photoIndex {
    NSLog(@"");
    NSString *msg = nil;
    
    msg = @"Removing current photo!";
    
    [self showSimpleMessageAndHide:msg];
    
    MWPhoto *photo = [self.photos objectAtIndex:photoIndex];
    [self deleteRCOPhotoObjectForPhoto:photo atIndex:photoIndex];
    [self.photos removeObjectAtIndex:photoIndex];
    [self.thumbs removeObjectAtIndex:photoIndex];
    [photoBrowser reloadData];
    
    if (photoIndex < self.photos.count) {
        [photoBrowser setCurrentPhotoIndex:photoIndex];
    } else {
        if (self.photos.count) {
            [photoBrowser setCurrentPhotoIndex:(self.photos.count - 1)];
        }
    }
    
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser resaveCurrentPhoto:(NSInteger)photoIndex {
    NSLog(@"");
    MWPhoto *photo = [self.photos objectAtIndex:photoIndex];
    [self saveRCOPhotoObjectForPhoto:photo];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser resaveAllPhotos:(BOOL)save {
    NSLog(@"");
    //[self syncNow];
}

-(NSString*)getKeyForPhoto:(MWPhoto*)photo {
    if (!photo) {
        return nil;
    }
    NSArray *keys = self.photosInfo.allKeys;
    for (NSString *key in keys) {
        id obj = [self.photosInfo objectForKey:key];
        if (obj == photo) {
            return key;
        }
    }
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser saveNewImages:(BOOL)save {
    NSLog(@"");
    
    NSString *msg = nil;
    
    if (self.photosToSave.count == 1) {
        msg = @"Saving one photo";
    } else if (self.photosToSave.count > 1) {
        msg = [NSString stringWithFormat:@"Saving %d photos", (int)self.photosToSave.count];
    } else {
        msg = @"No photos to save!";
    }
    
    [self showSimpleMessageAndHide:msg];
    
    if (self.photosToSave) {
        PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
        
        for (NSMutableDictionary *imageDict in self.photosToSave) {
            
            UIImage *image = [imageDict objectForKey:@"image"];
            MWPhoto *photo = [imageDict objectForKey:@"object"];
            NSString *key = [self getKeyForPhoto:photo];
            
            if (key) {
                [self.photosInfo removeObjectForKey:key];
            }
            
            Photo *newPhoto = (Photo*)[agg createNewObject];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
            
            newPhoto.name = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            newPhoto.title = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            NSString *category = nil;
            
            newPhoto.category = category;
            
            newPhoto.dateTime = [NSDate date];
            newPhoto.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
            newPhoto.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
            
            newPhoto.itemType = ItemTypePhoto;
            
            RCOObject *parentObj = (RCOObject*)self.accidentRecord;
            
            if ([parentObj existsOnServerNew]) {
                newPhoto.parentObjectId = parentObj.rcoObjectId;
                newPhoto.parentObjectType = parentObj.rcoObjectType;
                newPhoto.parentBarcode = parentObj.rcoBarcode;
            } else {
                newPhoto.parentObjectId = parentObj.rcoObjectId;
                newPhoto.parentObjectType = parentObj.rcoObjectClass;
                newPhoto.parentBarcode = nil;
                // add the link of the new photo to the photo parent record
                [parentObj addLinkedObject:newPhoto.rcoMobileRecordId];
                [[self aggregate] save];
            }
            
            [newPhoto setContentNeedsUploading:YES];
            [newPhoto setFileNeedsUploading:[NSNumber numberWithBool:YES]];
            
            [agg save];
            [agg registerForCallback:self];
            [agg createNewRecord:newPhoto];
            
            /*16.03.2018 we will not resize the image, we will save as jpeg and set compressio ration at half
             NSData *imageData = UIImagePNGRepresentation(image);
             */
            
            // compression is 0(most)..1(least)
            double compression = 0.5;
            
            [imageDict setObject:newPhoto.rcoMobileRecordId forKey:@"objectId"];
            NSData *imageData = UIImageJPEGRepresentation(image, compression);
            NSURL *fileURL = [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeForUpload];
            
            BOOL saveThumbnail = YES;
            if (saveThumbnail) {
                CGSize size = CGSizeMake([kImageSizeThumbnailSize integerValue], [kImageSizeThumbnailSize integerValue]);
                image = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
                NSData *imageData = UIImageJPEGRepresentation(image, compression);
                [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeThumbnailSize];
            }
            
            
            // TODO reload the photos ... to add the new objects
            [self.photosInfo setObject:photo forKey:newPhoto.rcoObjectId];
            [photo setCaption:@"Locally"];
        }
        self.photosToSave = [NSMutableArray array];
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser newImageAdded:(UIImage*)image {
    
    BOOL resizeImage = YES;
    
    // 31.01.2018 taking a photo sometines was returning a image that was not orientated correctly
    image = [image rotateImage:image];
    
    resizeImage = NO;
    
    if (resizeImage) {
        CGSize size = CGSizeMake(640, 640);
        image = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
    }
    
    if (image) {
        MWPhoto *photoObject = [MWPhoto photoWithImage:image];
        [photoObject setCaption:@"Not Saved"];
        
        [self.photos addObject:photoObject];
        [self.selections addObject:[NSNumber numberWithBool:NO]];
        [self.thumbs addObject:[MWPhoto photoWithImage:image]];
        if (!self.photosToSave) {
            self.photosToSave = [NSMutableArray array];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:image forKey:@"image"];
        [dict setObject:photoObject forKey:@"object"];
        [self.photosToSave addObject:dict];
        if (!self.photosInfo) {
            self.photosInfo = [NSMutableDictionary dictionary];
        }
        NSString *key = [NSString stringWithFormat:@"%d*", (int)(self.photos.count -1)];
        [self.photosInfo setObject:photoObject forKey:key];
    }
    [photoBrowser reloadData];
    if (self.photos.count) {
        [photoBrowser setCurrentPhotoIndex:(self.photos.count - 1)];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)deleteRCOPhotoObjectForPhoto:(MWPhoto*)photo atIndex:(NSInteger)photoIndex{
    NSLog(@"");
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    NSArray *keys = [self.photosInfo allKeysForObject:photo];
    
    if (keys.count) {
        NSString *rcoObjectId = [keys objectAtIndex:0];
        RCOObject *photoObj = nil;
        
        if ([rcoObjectId containsString:@"-"]) {
            // we should check if we saved using the mobileRecordId
            photoObj = [agg getObjectMobileRecordId:rcoObjectId];
        } else {
            photoObj = [agg getObjectWithId:rcoObjectId];
        }
        
        if (photoObj) {
            [agg destroyObj:photoObj];
        } else {
            // this is the image from the imaes to save
            for (NSDictionary *photoInfo in self.photosToSave) {
                
                id obj = [photoInfo objectForKey:@"object"];
                if (obj == photo) {
                    [self.photosToSave removeObject:photoInfo];
                    continue;
                }
            }
        }
        [self.photosInfo removeObjectForKey:rcoObjectId];
    }
}

-(void)saveRCOPhotoObjectForPhoto:(MWPhoto*)photo {
    NSLog(@"");
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    NSArray *keys = [self.photosInfo allKeysForObject:photo];
    if (keys.count) {
        NSString *rcoObjectId = [keys objectAtIndex:0];
        RCOObject *photoObj = [agg getObjectWithId:rcoObjectId];
        photoObj.fileIsDownloading = nil;
        photoObj.fileIsUploading = nil;
        photoObj.fileNeedsDownloading = nil;
        photoObj.fileNeedsUploading = [NSNumber numberWithBool:YES];
        
        photoObj.objectIsDownloading = nil;
        photoObj.objectIsUploading = nil;
        photoObj.objectNeedsDownloading = nil;
        photoObj.objectNeedsUploading = [NSNumber numberWithBool:YES];
        
        // we should enable uploading the thumbnail
        photoObj.fileLog = nil;
        [agg save];
        [agg registerForCallback:self];
        [agg createNewRecord:photoObj];
        [self.photosInfo removeObjectForKey:rcoObjectId];
        [self.photosInfo setObject:photo forKey:photoObj.rcoObjectId];
    }
}



@end
