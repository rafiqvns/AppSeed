//
//  CSDNotesViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDNotesViewController.h"
#import "InputCell.h"
#import "InputCellWithId.h"
#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"
#import "RCOValuesListViewController.h"
#import "NSDate+TKCategory.h"
#import "TrainingStudent+CoreDataClass.h"
#import "TrainingCompany+CoreDataClass.h"
#import "Settings.h"
#import "TrainingCompanyAggregate.h"
#import "NotesAggregate.h"
#import "Note+CoreDataClass.h"
#import "TrainingTestInfo+CoreDataClass.h"

#import <ImagePicker/ImagePicker-Swift.h>
#import "MobileOffice-Swift.h"
#import "UIImage+Resize.h"
#import "Photo+Photo_Imp.h"
#import "PhotosAggregate.h"
#import "TextViewCell.h"
#import "WebViewViewController.h"
#import "NSDate+Misc.h"

#define Key_Company @"company"
#define Key_Student @"employeeId"
#define Key_Instructor @"instructorEmployeeId"
#define Key_Photos @"photos"
#define Key_NewNote @"newNote"
#define Key_Preview @"preview"

@interface CSDNotesViewController ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *fieldsNames;
@property (nonatomic, strong) NSMutableArray *categoryFields;
@property (nonatomic, strong) NSMutableArray *categoryFieldsNames;

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *disabledFields;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *percentageFields;
@property (nonatomic, strong) NSArray *numericFields;

@property (nonatomic, strong) NSArray *datePickerFieldsNames;

@property (nonatomic, strong) NSDate *dateTime;

@property (nonatomic, strong) TrainingCompany *company;
@property (nonatomic, strong) User *student;
@property (nonatomic, strong) User *instructor;
@property (nonatomic, strong) TrainingTestInfo *testInfo;

@property (nonatomic, assign) BOOL isSaveEnabled;

@property (nonatomic, strong) UIAlertController *al;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *reloadBtn;
@property (nonatomic, strong) UIBarButtonItem *previewBtn;
@property (nonatomic, strong) NSMutableArray *notesRecords;
@property (nonatomic, strong) NSMutableArray *notesStrings;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableDictionary *photosRecords;
@property (nonatomic, strong) NSString *category;

// Photos ....
@property (nonatomic, strong) NSMutableDictionary *photos;
@property (nonatomic, strong) NSMutableDictionary *thumbs;
@property (nonatomic, strong) NSMutableArray *photosToSave;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSMutableDictionary *photosInfo;
@property (nonatomic, strong) MWPhotoBrowserPlus *browser;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSString *currentKey;

@end

@implementation CSDNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveButtonPressed:)];
    [self.saveBtn setEnabled:NO];
    
    self.previewBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Preview", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(previewButtonPressed:)];
    
    self.reloadBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                   target:self
                                                                   action:@selector(reloadButtonPressed:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, self.reloadBtn, nil];


    NSNumber *isDrivingSchool = [Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL];
    if ([isDrivingSchool boolValue]) {
        // 09.12.2019 remove reload button
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, self.saveBtn, nil];
    } else {
        // 12.12.2019 remove save button
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.previewBtn, nil];
    }
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.values = [NSMutableDictionary dictionary];


    [self loadPrevStudent];
    [self loadPrevInstructor];
    [self loadPreviusSavedTest];

    [self loadCodingFields];
    
    self.pickerFields = [NSArray arrayWithObjects:@"company", @"instructorEmployeeId", @"employeeId",  nil];

    [self loadObject];
    [self loadNotes];
    
    self.title = @"Notes";
}
-(void)loadPreviusSavedTest {
    
    NSString *prevTestInfoMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!prevTestInfoMobileRecordId.length) {
        return;
    }
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingTestInfo"];
    self.testInfo = (TrainingTestInfo*)[agg getObjectWithMobileRecordId:prevTestInfoMobileRecordId];
    
    if (!self.testInfo) {
        // this is strange somehow the previus test was deleted
        return;
    }
    [self syncNotes];
}

-(void)loadPrevInstructor{
    NSString *prevInstructor = [Settings getSetting:CSD_PREV_INSTRUCTOR];
    if (prevInstructor.length == 0) {
        return;
    }
    UserAggregate *instrAgg = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];

    self.instructor = (User*)[instrAgg getObjectWithRecordId:prevInstructor];
    
    if (self.instructor.employeeNumber) {
        [self.values setObject:self.instructor.employeeNumber forKey:@"instructorEmployeeId"];
    }
}

-(void)loadPrevStudent{
    NSString *prevStudent = [Settings getSetting:CSD_PREV_STUDENT];
    if (prevStudent.length == 0) {
        return;
    }
    UserAggregate *studentAggregate = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];

    if ([prevStudent longLongValue]) {
        self.student = (User*)[studentAggregate getObjectWithRecordId:prevStudent];
    } else {
        self.student = (User*)[studentAggregate getObjectWithMobileRecordId:prevStudent];
    }
    
    if (self.student.employeeNumber) {
        [self.values setObject:self.student.employeeNumber forKey:@"employeeId"];
    }
    if (self.student.driverLicenseState) {
        [self.values setObject:self.student.driverLicenseState forKey:@"studentDriverLicenseState"];
    }
    if (self.student.driverLicenseNumber) {
        [self.values setObject:self.student.driverLicenseNumber forKey:@"studentDriverLicenseNumber"];
    }

    if (self.student.company) {
        [self.values setObject:self.student.company forKey:@"company"];
        [self loadCompanyWithName:self.student.company];
    }
}

-(void)syncNotes {
    if (!self.testInfo || (self.testInfo.rcoBarcode.length == 0)) {
        return;
    }
    NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
    [agg getNotesForMasterBarcode:self.testInfo.rcoBarcode];
}

-(void)loadPhotosForNote:(Note*)note {
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;

    NSArray *photos = [agg getPhotosForObject:note];
    
    if (!self.photosRecords) {
        self.photosRecords = [NSMutableDictionary dictionary];
    }
    for (Photo *photo in photos) {
        NSString *category = note.rcoMobileRecordId;
        if (!category.length) {
            continue;
        }
        NSMutableArray *items = [self.photosRecords objectForKey:category];
        if (!items) {
            items = [NSMutableArray array];
        }
        if (![items containsObject:photo]) {
            [items addObject:photo];
        }
        [self.photosRecords setObject:items forKey:category];
    }
    NSLog(@"");
    [self.tableView reloadData];
}

-(void)loadNotes {
    if (!self.testInfo) {
        return;
    }
    
    NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
    NSArray *items = [agg getNotesForObject:self.testInfo];
    self.notesRecords = [NSMutableArray arrayWithArray:items];

    for (NSInteger i = 0; i < self.notesRecords.count; i++) {
        //NSString *section = [NSString stringWithFormat:@"%@%d", @"Notes", (int)(i+1)];
/*
        26.11.2019 we should mobile record id
        NSString *section = [NSString stringWithFormat:@"%d", (int)(i+1)];
        Note *note = [self getNoteForSection:section];
*/
        Note *note = [self.notesRecords objectAtIndex:i];
        
        if (note.notes.length) {
            NSString *str = [note.notes stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
            //26.11.2019 [self.values setObject:str forKey:section];
            [self.values setObject:str forKey:note.rcoMobileRecordId];

            if (!self.notesStrings) {
                self.notesStrings = [NSMutableArray array];
            }
            [self.notesStrings addObject:@""];
            //25.11.2019 we should sync the photois for the note
            [self loadPhotosForNote:note];
        }
    }
}

-(Note*)getNoteForSection:(NSString*)sectionName {
    if (sectionName.length == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category=%@", sectionName];
    NSArray *res = [self.notesRecords filteredArrayUsingPredicate:predicate];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}



-(void)loadCodingFields {
    self.fields = [NSArray arrayWithObjects:@"company", @"instructorEmployeeId", @"employeeId", nil];
    self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"Instructor", @"Student", nil];
    
    [self.tableView reloadData];
    self.index = self.notesRecords.count;
    [self.countBtn setTitle:[NSString stringWithFormat:@"%d", (int)self.index]];
    [self.prevBtn setEnabled:NO];
    [self.nextBtn setEnabled:NO];
    if (self.index > 0) {
        [self.prevBtn setEnabled:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"Note"] registerForCallback:self];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"Note"] unRegisterForCallback:self];
    [[[DataRepository sharedInstance] getAggregateForClass:@"TrainingEquipment"] unRegisterForCallback:self];
}


-(void)loadObject {
    for (NSString *field in self.fields) {
        NSString *value = nil;
        value = [self.testInfo valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }
    [self.tableView reloadData];
}

-(IBAction)infoButtonPressed:(id)sender {
    NSString *msg = @"1. To Add a new Note please tap on the Add button from bottom toolbar.\n\n2. To Add a Photo to a note please Save first (tap on the Save button) and after that tap on the 'Photo' button correponding to that Note.";
    [self showSimpleMessage:msg];
}

-(IBAction)previewButtonPressed:(id)sender {
    NSURL *fileURL = nil;
    NSString *tile = nil;
    
    NSMutableArray *notes = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];

    for (Note *note in self.notesRecords) {
        if (note.notes.length) {
            [notes addObject:note];
        } else {
            [notes addObject:@" "];
        }
        
        UIImage *img = [self getImageForNote:note];
        if (img) {
            [images addObject:img];
        } else {
            [images addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    fileURL = [[NSBundle mainBundle] URLForResource:@"notes" withExtension:@"html"];
    tile = @"Notes";
    WebViewViewController *controller = [[WebViewViewController alloc] initWithNibName:@"WebViewViewController"
                                                                                bundle:nil
                                                                               fileURL:fileURL];
    controller.htmlName = tile;
    controller.addDelegate = self;
    controller.addDelegateKey = Key_Preview;
    controller.params = nil;
    controller.object = nil;
    controller.details = nil;
    controller.showEmailButton = YES;
    controller.aggregate = [self aggregate];
    controller.notes = notes;
    controller.notesImages = images;
    controller.loadAsTestHTML = YES;
    
    self.currentKey = Key_Preview;
    
    NSMutableDictionary *extraParameters = [NSMutableDictionary dictionary];

    if (self.company) {
        [extraParameters setObject:self.company.name forKey:@"company"];
    }

    if (self.student) {
        [extraParameters setObject:[self.student Name] forKey:@"driverName"];
    }

    if (self.instructor) {
        [extraParameters setObject:[self.instructor Name] forKey:@"note_instructor"];
    }

    if (!self.testInfo) {
        [self loadPreviusSavedTest];
    }
    
    if (self.testInfo) {
        NSDate *date = self.testInfo.dateTime;
        if (date) {
            [extraParameters setObject:[NSDate rcoDateDateToString:date] forKey:@"note_date"];
        }
    }
    
    controller.htmlExtraKeys = extraParameters;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
}

-(IBAction)cancelButtonPressed:(id)sender {
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)reloadButtonPressed:(id)sender {

    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:@"Reload the most recent Test Info?"
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        
        [self loadPrevStudent];
        [self loadPrevInstructor];

        [self loadCodingFields];

        [self loadObject];
        [self loadNotes];
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                        }];

    [al addAction:cancelAction];
    [al addAction:yesAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(IBAction)saveButtonPressed:(id)sender {
    if (self.addParentMobileRecordId) {
        NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
        if (!parentMobileRecordId.length) {
            [self showSimpleMessage:@"Please add test info first!"];
            return;
        }
    }

    NSString *message = [self validateInputs];
    
    if (message) {
        [self showSimpleMessage:message];
        return;
    }
    
    if (sender) {
        self.progressHUD.labelText = @"Saving notes...";
        [self.view addSubview:self.progressHUD];
        [self.progressHUD show:YES];
        [self performSelector:@selector(createOrUpdateRecord) withObject:nil afterDelay:0.1];
    } else {
        [self createOrUpdateRecord];
    }
}

-(void)savePhotos {
    /*
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    NotesAggregate *notesAgg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
    for (NSString *category in self.photosOld.allKeys) {
        NSArray *photos = [self.photosOld objectForKey:category];
        //25.11.2019 we should add the photos to a note and not to the "Test Info" Record
        Note *note = [self getNoteForSection:category];
        for (NSDictionary *imageDict in photos) {
            
            UIImage *image = [imageDict objectForKey:@"image"];
            
            Photo *newPhoto = (Photo*)[agg createNewObject];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
            
            newPhoto.name = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            newPhoto.title = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            newPhoto.category = category;
            newPhoto.dateTime = [NSDate date];
            newPhoto.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
            newPhoto.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
            newPhoto.itemType = ItemTypePhoto;
            
            if ([note existsOnServerNew]) {
                newPhoto.parentObjectId = note.rcoObjectId;
                newPhoto.parentObjectType = note.rcoObjectType;
                newPhoto.parentBarcode = note.rcoBarcode;
            } else {
                newPhoto.parentObjectId = note.rcoObjectId;
                newPhoto.parentObjectType = note.rcoObjectClass;
                newPhoto.parentBarcode = nil;
                // add the link of the new photo to the photo parent record
                [note addLinkedObject:newPhoto.rcoMobileRecordId];
                [notesAgg save];
            }
            
            [newPhoto setContentNeedsUploading:YES];
            [newPhoto setFileNeedsUploading:[NSNumber numberWithBool:YES]];
            
            [agg save];
            [agg registerForCallback:self];
            if ([note existsOnServerNew]) {
                [agg createNewRecord:newPhoto];
            }
            
            double compression = 0.5;
            
            NSData *imageData = UIImageJPEGRepresentation(image, compression);
            NSURL *fileURL = [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeForUpload];
            NSLog(@"Image path = %@", fileURL);
            
            BOOL saveThumbnail = YES;
            if (saveThumbnail) {
                CGSize size = CGSizeMake([kImageSizeThumbnailSize integerValue], [kImageSizeThumbnailSize integerValue]);
                UIImage *imageResized = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
                NSData *imageData = UIImageJPEGRepresentation(imageResized, compression);
                [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeThumbnailSize];
            }
        }
    }
    */
}

-(IBAction)addButtonPressed:(id)sender {
    if (self.notesStrings.count > self.notesRecords.count) {
        [self showSimpleMessage:@"Please save notes first!"];
        return;
    }
    [self loadPreviusSavedTest];
    
    if (!self.notesStrings) {
        self.notesStrings = [NSMutableArray array];
    }
    [self.notesStrings addObject:@""];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:(self.fields.count + self.notesStrings.count -1)];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    /*
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[InputCellWithId class]]) {
        InputCellWithId *inputCell = (InputCellWithId*)cell;
        [inputCell.inputTextField becomeFirstResponder];
    } else if ([cell isKindOfClass:[TextViewCell class]]) {
        TextViewCell *textViewCell = (TextViewCell*)cell;
        [textViewCell.textView becomeFirstResponder];
    }
    */
    [self.saveBtn setEnabled:YES];
}

-(IBAction)prevButtonPressed:(id)sender {
    
}

-(IBAction)nextButtonPressed:(id)sender {
}

-(IBAction)photosButtonPressedOld:(UIButton*)sender {
    /*
    NSLog(@"BTN = %@", sender);
    //self.category = [NSString stringWithFormat:@"Notes%d", (int)sender.tag];
    self.category = [NSString stringWithFormat:@"%d", (int)sender.tag];
    [self showImagePicker];
     */
}

-(IBAction)photosButtonPressed:(UIButton*)sender {
    Note *note = nil;
    
    if (sender.tag < self.notesRecords.count) {
        note = [self.notesRecords objectAtIndex:sender.tag];
    }
            
    if (!note) {
        NSString *noteStr = [self.values objectForKey:Key_NewNote];
        if (!noteStr.length) {
            [self showSimpleMessage:@"Please add Note first!"];
        } else {
            [self showSimpleMessage:@"Please save Note first!"];
        }
        return;
    }
    
    self.category = note.rcoMobileRecordId;

    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    NSArray *photos = [self.photosRecords objectForKey:self.category];

    self.photos = [NSMutableDictionary dictionary];
    self.thumbs = [NSMutableDictionary dictionary];
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
            
            NSMutableArray *tmp = [self.photos objectForKey:self.category];
            if (!tmp) {
                tmp = [NSMutableArray array];
            }
            
            [tmp addObject:photoObject];
            [self.photos setObject:tmp forKey:self.category];
            [self.selections addObject:[NSNumber numberWithBool:NO]];
            
            // we should get the url for thumbnail
            str = [photo getImageURL:NO];
            NSMutableArray *thumbs = [self.thumbs objectForKey:self.category];
            if (!thumbs) {
                thumbs = [NSMutableArray array];
            }
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:str]]];
            [self.thumbs setObject:thumbs forKey:self.category];
        } else {
            // we should load from local DB
            UIImage *img = [agg getImageForObject:photo.rcoMobileRecordId];
            photoObject = [MWPhoto photoWithImage:img];
            [photoObject setCaption:@"Locally"];
            
            NSMutableArray *tmp = [self.photos objectForKey:self.category];
            if (!tmp) {
                tmp = [NSMutableArray array];
            }
            
            [tmp addObject:photoObject];
            [self.photos setObject:tmp forKey:self.category];
            [self.selections addObject:[NSNumber numberWithBool:NO]];
            NSMutableArray *thumbs = [self.thumbs objectForKey:self.category];
            if (!thumbs) {
                thumbs = [NSMutableArray array];
            }
            [thumbs addObject:[MWPhoto photoWithImage:img]];
            [self.thumbs setObject:thumbs forKey:self.category];
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

-(UIImage*)getImageForNote:(Note*)note {
    if (!note.rcoMobileRecordId.length) {
        return nil;
    }
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    NSArray *photos = [self.photosRecords objectForKey:note.rcoMobileRecordId];
    if (!photos.count) {
        return nil;
    }
    Photo *photo = [photos objectAtIndex:0];
    UIImage *img = [agg getImageForObject:photo.rcoMobileRecordId];
    return img;
}

-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)createOrUpdateRecord {
    for (NSString *key in self.values.allKeys) {
        if (!([key isEqualToString:Key_NewNote] || [key hasPrefix:@"Note-"])) {
            continue;
        }
        NSString *note = [self.values objectForKey:key];
        
        if (note.length) {
            [self addNote:note forCategory:key];
        }
    }
    
    [self savePhotos];
    
    [self.saveBtn setEnabled:NO];
    [self.progressHUD hide:YES];
}

-(void)addNote:(NSString*)noteStr forCategory:(NSString*)category{
    NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
    Note *note = nil;
    BOOL isNewNote = NO;

    if ([category isEqualToString:Key_NewNote]) {
        // we should create a new note
    } else {
        note = (Note*)[agg getObjectMobileRecordId:category];
    }
    if (!note) {
        // is a new note...
        note = (Note*)[agg createNewObject];
        note.dateTime = [NSDate date];
        isNewNote = YES;
    }
    
    note.notes = noteStr;
    NSString *noteTitle = [NSString stringWithFormat:@"%@", noteStr];
    if (noteTitle.length > 20) {
        noteTitle = [noteTitle substringToIndex:20];
        noteTitle = [NSString stringWithFormat:@"%@...", noteTitle];
    }
    note.title = noteTitle;
    note.category = category;
    note.parentBarcode = self.testInfo.rcoBarcode;
    note.parentObjectId = self.testInfo.rcoObjectId;
    note.parentObjectType = self.testInfo.rcoObjectType;
    
    // 18.03.2020 we need the student record id
    note.creatorRecordId = self.student.rcoRecordId;
    
    [agg save];
    if (isNewNote) {
        [self.notesRecords addObject:note];
        [self.values removeObjectForKey:Key_NewNote];
        [self.values setObject:noteStr forKey:note.rcoMobileRecordId];
    }
    if ([self.testInfo existsOnServerNew]) {
        [agg createNewRecord:note];
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fields.count + self.notesStrings.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < self.fields.count) {
        NSString *title = [self.fieldsNames objectAtIndex:section];
        return title;
    } else {
        NSInteger count = section - self.fields.count;
        if (count < self.notesRecords.count) {
            Note *note = [self.notesRecords objectAtIndex:count];
            
            NSArray *photos = [self.photosRecords objectForKey:note.rcoMobileRecordId];
            if (photos.count) {
                return [NSString stringWithFormat:@"Note %d(%d)", (int)(count+1), (int)photos.count];
            } else {
                return [NSString stringWithFormat:@"Note %d", (int)(count+1)];
            }
        } else {
            return [NSString stringWithFormat:@"Note %d", (int)(count+1)];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor yellowColor];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [TrainingTestInfo lightColor];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return @"Notes";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        return 40;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.fields.count) {
        return 100;
    } else {
        return 44;
    }
}

- (UITableViewCell *)configureTextViewInputCellForTableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forValue:(NSString*)value key:(NSString*)key andTitle:(NSString*)title isRequire:(BOOL)requiredField placeholder:(NSString*)placeholder{
    // we have textView cell
    
    TextViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TextViewCell"
                                                     owner:self
                                                   options:nil];
        cell = (TextViewCell *)[nib objectAtIndex:0];
    }
    
    NSInteger index = indexPath.section - self.fields.count;
    Note *note = nil;
    if (index < self.notesRecords.count) {
        note = [self.notesRecords objectAtIndex:index];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textView.delegate = self;
    cell.textView.layer.borderColor = [UIColor blackColor].CGColor;
    cell.textView.layer.borderWidth = 1;
    cell.textView.inputAccessoryView = self.keyboardToolbar;
    if (note.rcoMobileRecordId.length) {
        cell.textView.text = [self.values objectForKey:note.rcoMobileRecordId];
    } else {
        cell.textView.text = [self.values objectForKey:Key_NewNote];
    }
    cell.textView.tag = index;
    UITextInputAssistantItem* item = [cell.textView inputAssistantItem];
    item.leadingBarButtonGroups = @[];
    item.trailingBarButtonGroups = @[];
    cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
        
    UIButton *photosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photosBtn setFrame:CGRectMake(0, 0, 100, 100)];
    
    if (@available(iOS 13,*)) {
        [photosBtn setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    } else {
        [photosBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    }

    [photosBtn setTitle:@"Photo" forState:UIControlStateNormal];
    photosBtn.tag = index;
    [photosBtn addTarget:self
                  action:@selector(photosButtonPressed:)
        forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *photosForNote = nil;
    
    if (note.rcoMobileRecordId.length) {
        photosForNote = [self.photosRecords objectForKey:note.rcoMobileRecordId];
    }

    if (photosForNote.count) {
        UIImage *img = [self getImageForNote:note];
        [photosBtn setBackgroundImage:img forState:UIControlStateNormal];
        [photosBtn setContentMode:UIViewContentModeScaleAspectFit];
        [photosBtn setTitle:@"" forState:UIControlStateNormal];
        cell.accessoryView = photosBtn;
    } else {
        [photosBtn setTitle:@"No Photos" forState:UIControlStateNormal];
        cell.accessoryView = photosBtn;
    }
                                   
    return cell;
    /*
    InputCellWithId *inputCell = nil;
    
    inputCell = (InputCellWithId*)[theTableView dequeueReusableCellWithIdentifier:@"InputCellWithId"];
    
    if (inputCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InputCellWithIdNew"
                                                     owner:self
                                                   options:nil];
        inputCell = (InputCellWithId *)[nib objectAtIndex:0];
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [NSString stringWithFormat:@"%@", value];
    }
    
    //configure input
    CGRect frame = inputCell.titleLabel.frame;
    // hide title label
    frame.size.width = 0;
    inputCell.titleLabel.frame = frame;
    //resize input field
    frame = inputCell.inputTextField.frame;
    // we should maximize the width
    
    frame.origin.x = 10;
    frame.size.width = inputCell.frame.size.width - 20;
    inputCell.inputTextField.frame = frame;
    [inputCell.requiredLabel setHidden:!requiredField];
    inputCell.inputTextField.delegate = self;
    
    [inputCell.inputTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    inputCell.inputTextField.tag = indexPath.section;
    inputCell.inputTextField.font = [UIFont boldSystemFontOfSize:19];
    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    inputCell.inputTextField.text = value;
    inputCell.inputTextField.placeholder = placeholder;
    inputCell.inputTextField.fieldId = key;
    inputCell.titleLabel.text = title;
    [inputCell.titleLabel setNumberOfLines:2];
    [inputCell.titleLabel setFont:[UIFont systemFontOfSize:13]];
    inputCell.inputTextField.inputAccessoryView = self.keyboardToolbar;
    if ([self.numericFields containsObject:key]) {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    } else {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDefault;
    }
    
    //inputCell.inputTextField.enabled = NO;
    inputCell.inputTextField.font = [UIFont systemFontOfSize:15];
    
    if ([self.percentageFields containsObject:key]) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        lbl.text = @"%";
        inputCell.accessoryView = lbl;
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDecimalPad;
    } else {
        inputCell.accessoryView = nil;
    }
    
    UIButton *photosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photosBtn setFrame:CGRectMake(0, 0, 76, 35)];
    
    if (@available(iOS 13,*)) {
        [photosBtn setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    } else {
        [photosBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    }

    [photosBtn setTitle:@"Photo" forState:UIControlStateNormal];
    photosBtn.tag = indexPath.section;
    
    [photosBtn addTarget:self
                  action:@selector(photosButtonPressed:)
        forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *photosForNote = [self.photos objectForKey:key];
    if (photosForNote.count) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        NSDictionary *dict = [photosForNote objectAtIndex:0];
        UIImage *img = [dict objectForKey:@"image"];
        imgView.image = img;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
        [view addSubview:imgView];
        [photosBtn setFrame:CGRectMake(44, 0, 76, 35)];
        [view addSubview:photosBtn];
        inputCell.accessoryView = view;
    } else {
        inputCell.accessoryView = photosBtn;
    }
                                   
    return inputCell;
     */
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section >= self.fields.count) {
        //NSString *noteKey = [NSString stringWithFormat:@"%@%d", @"Notes", (int)(indexPath.section - self.fields.count + 1)];
        NSString *noteKey = [NSString stringWithFormat:@"%d", (int)(indexPath.section - self.fields.count + 1)];

        NSString *val = [self.values objectForKey:noteKey];
        
        return [self configureTextViewInputCellForTableView:theTableView
                                      cellForRowAtIndexPath:indexPath
                                                   forValue:val
                                                        key:noteKey
                                                   andTitle:nil
                                                  isRequire:NO
                                                placeholder:@"Notes"];
    }
    
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

        UISwitch *sw = [[UISwitch alloc] init];
        
        sw.tag = keyIndex;
        sw.on = [value boolValue];

        [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PickerCell"];
        }
        
        if ([key isEqualToString:Key_Student]) {
            if (self.student) {
                value = [NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname];
                cell.textLabel.text = value;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.student.driverLicenseState, self.student.driverLicenseNumber];
            } else {
                cell.textLabel.text = nil;
                cell.detailTextLabel.text = nil;
            }
        } else if ([key isEqualToString:Key_Instructor]) {
            if (self.instructor) {
                value = [NSString stringWithFormat:@"%@ %@", self.instructor.surname, self.instructor.firstname];
                cell.textLabel.text = value;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.instructor.employeeNumber];
            } else {
                cell.textLabel.text = nil;
                cell.detailTextLabel.text = nil;
            }
        } else {
            cell.textLabel.text = value;
            cell.detailTextLabel.text = nil;
        }
        
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
        [inputCell.inputTextField setTextColor:[UIColor darkTextColor]];
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
     if ([key isEqualToString:Key_Company]) {
        [self showCompanyPickerFromView:cell];
    }else if ([key isEqualToString:Key_Student]) {
        if (!self.company) {
            [self showSimpleMessage:@"Please select company first!"];
            return;
        }
        [self showUserPickerFromView:cell forKey:key];
    } else if ([key isEqualToString:Key_Instructor]) {
        [self showUserPickerFromView:cell forKey:key];
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        [self showDatePickerFromView:cell andKey:key];
    }
}

-(void)switchValueChanged:(UISwitch*)aSwitch {
    NSInteger keyIndex = aSwitch.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    [self.values setObject:[NSNumber numberWithBool:aSwitch.on] forKey:key];
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

- (void)showUserPickerFromView:(UIView*)fromView forKey:(NSString*)key{
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    id selectedObject = nil;
    
    if ([key isEqualToString:Key_Student]) {
        aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
        title = @"Students";
        fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
        detailFields = [NSArray arrayWithObjects:@"driverLicenseState", @"driverLicenseNumber", @"employeeNumber", nil];
        sortKey = @"surname";
        selectedObject = self.student;
        predicate = [NSPredicate predicateWithFormat:@"company=%@", self.company.name];
    } else {
        title = @"Instructors";
        aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];
        fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
        detailFields = [NSArray arrayWithObjects:@"employeeNumber", nil];
        sortKey = @"surname";
        selectedObject = self.instructor;
    }
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:key
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = key;
    listController.title = title;
    listController.selectedItem = selectedObject;

    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showCompanyPickerFromView:(UIView*)fromView{
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    title = @"Students";
    fields = [NSArray arrayWithObjects:@"name", @"number", nil];
    detailFields = nil;
    sortKey = @"name";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:Key_Company
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = Key_Company;
    listController.title = title;
    listController.selectedItem = self.company;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}



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

-(void)resetEquipmentFields {
    [self.values removeObjectForKey:@"equipmentType"];
    [self.values removeObjectForKey:@"notes"];
    [self.values removeObjectForKey:@"vehicleNumber"];
    [self.values removeObjectForKey:@"trailer1Number"];
    [self.values removeObjectForKey:@"dolly1Number"];
    [self.values removeObjectForKey:@"trailer2Number"];
    [self.values removeObjectForKey:@"dolly2Number"];
    [self.values removeObjectForKey:@"trailer3Number"];

}

-(void)loadCompanyWithName:(NSString*)name {
    TrainingCompanyAggregate *agg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    self.company = [agg getTrainingCompanyWithName:name];
}

#pragma mark -
#pragma mark UItextFieldDelegate Methods

- (IBAction)textFieldChanged:(UITextField*) textField {
    NSString *value = textField.text;
    NSString *key = nil;
    
    if ([textField isKindOfClass:[TextField class]]) {
        key = ((TextField*)textField).fieldId;
    } else {
        key = [self.fields objectAtIndex:textField.tag];
    }
    [self.values setObject:[value stringByReplacingOccurrencesOfString:@"\n" withString:@" "] forKey:key];
    [self enableSaveBtn];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([object isKindOfClass:[NSDate class]]) {
        [self.values setObject:object forKey:key];
    } else if ([key isEqualToString:Key_Company]) {
           if ([object isKindOfClass:[TrainingCompany class]]) {
               self.company = (TrainingCompany*)object;
               if (self.company.name) {
                   // 22.10.2019 we should check if the "company name" is the same as "student company name" if not then we should reset the student
                   if (self.student) {
                       if (![[self.student.company lowercaseString] isEqualToString:[self.company.name lowercaseString]]) {
                           [self resetEquipmentFields];
                           self.student = nil;
                       }
                   }
                   [self.values setObject:self.company.name forKey:key];
               }
           }
    } else if ([key isEqualToString:Key_Instructor]) {
        if ([object isKindOfClass:[User class]]) {
            self.instructor = (User*)object;
            if (self.instructor.employeeNumber) {
                [self.values setObject:self.instructor.employeeNumber forKey:@"instructorEmployeeId"];
            }
            
            if ([self.instructor.rcoRecordId length]) {
                [Settings setSetting:self.instructor.rcoRecordId forKey:CSD_PREV_INSTRUCTOR];
                [Settings save];
            }
        }
    } else if ([key isEqualToString:Key_Student]) {
        if ([object isKindOfClass:[User class]]) {
            [self resetEquipmentFields];
            self.student = (User*)object;
            
            if ([self.student.rcoRecordId length]) {
                [Settings setSetting:self.student.rcoRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            } else if ([self.student.rcoMobileRecordId length]) {
                [Settings setSetting:self.student.rcoMobileRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            }
            
            // populate the student coding fields
            if (self.student.employeeNumber) {
                [self.values setObject:self.student.employeeNumber forKey:@"employeeId"];
            }
            if (self.student.driverLicenseNumber) {
                [self.values setObject:self.student.driverLicenseNumber forKey:@"studentDriverLicenseNumber"];
            }
            if (self.student.driverLicenseState) {
                [self.values setObject:self.student.driverLicenseState forKey:@"studentDriverLicenseState"];
            }

            if (self.student.company) {
                [self.values setObject:self.student.company forKey:@"company"];

                if (!self.company) {
                    [self loadCompanyWithName:self.student.company];
                }
            }
        }
    } else if (key && [self.pickerFields containsObject:key]) {
        if (object) {
            [self.values setObject:object forKey:key];
        }
    }
    
    if (key && ![key isEqualToString:Key_Preview]) {
        [self enableSaveBtn];
    }
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([key isEqualToString:Key_Preview] || [self.currentKey isEqualToString:Key_Preview]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            self.currentKey = nil;
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

    [self.tableView reloadData];
}

-(void)enableSaveBtn {
    [self.saveBtn setEnabled:YES];
}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"Note"];
}

-(void)showImagePicker {
    ImagePickerControllerPlus *controller = [[ImagePickerControllerPlus alloc] init];
    controller.delegate = self;
    [controller setImageLimitWithNumber:1];
    
    [self presentViewController:controller
                       animated:YES
                     completion:^{
                         NSLog(@"presented completed");
                     }];

}


-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:RD_G_R_U_X_F] && [aggregate isKindOfClass:[NotesAggregate class]] ) {
        [self loadNotes];
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    //NSString *errorMessage = [messageInfo objectForKey:@"errorMessage"];
    NSString *message = [messageInfo objectForKey:@"message"];
   
    /*
    if ([message isEqualToString:SET_EQUIPMENT_REVIEWED] || [message isEqualToString:EQU]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
    }
    */
}

#pragma mark Keyboard Methods

- (void)keyboardWillHide:(NSNotification *)notif {
    self.currentIndexPath = nil;
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
    if (self.currentIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma Mark CSD Selection Protocol

-(void)CSDInfoDidSelectObject:(NSString *)parentMobileRecordId {
    NSLog(@"%@", parentMobileRecordId);
    [self loadPrevStudent];
    [self loadPrevInstructor];
    [self loadPreviusSavedTest];

    [self loadCodingFields];

    self.testInfo = nil;
    [self loadObject];
    [self loadNotes];
    [self.tableView reloadData];
}

-(void)CSDInfoDidSavedObject:(NSString *)parentMobileRecordId {
    NSLog(@"");
}

-(BOOL)CSDInfoCanSelectScreen {
    return !(self.saveBtn.enabled);
}
-(NSString*)CSDInfoScreenTitle {
    return @"Notes";
}

-(void)CSDSaveRecordOnServer:(BOOL)onServer {
    NSLog(@"");
    [self saveButtonPressed:nil];
}

#pragma mark ImagePickerDelegate

-(void)wrapperDidPress:(ImagePickerControllerPlus *)imagePicker images:(NSArray<UIImage *> *)images {
    NSLog(@"Images = %@", images);
}

-(void)doneButtonDidPress:(ImagePickerControllerPlus *)imagePicker images:(NSArray<UIImage *> *)images {
    NSLog(@"Images = %@", images);
    /*
    UIImage *img = nil;
    if (images.count) {
        img = [images objectAtIndex:0];
    }
    if (img) {
        NSMutableArray *images = [self.photosOld objectForKey:self.category];
        if (!images) {
            images = [NSMutableArray array];
        }
        NSMutableDictionary *imgDict = [NSMutableDictionary dictionary];
        [imgDict setObject:img forKey:@"image"];
        
        // 25.11.2019 we should add just one image per note
        if (images.count) {
            [images replaceObjectAtIndex:0 withObject:imgDict];
        } else {
            [images addObject:imgDict];
        }
        if (!self.photosOld) {
            self.photosOld = [NSMutableDictionary dictionary];
        }
        [self.photosOld setObject:images forKey:self.category];
        [self.tableView reloadData];
    }
    [self.saveBtn setEnabled:YES];
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
    */
}

-(void)cancelButtonDidPress:(ImagePickerControllerPlus *)imagePicker {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

#pragma mark UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.currentIndexPath = nil;
    if ([[[textView superview] superview] isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*)[[textView superview] superview];
        self.currentIndexPath = [self.tableView indexPathForCell:cell];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textView = %@", textView);
    NSString *noteKey = nil;
    if (textView.tag < self.notesRecords.count) {
        Note *note = [self.notesRecords objectAtIndex:textView.tag];
        noteKey = note.rcoMobileRecordId;
    } else {
        noteKey = Key_NewNote;
    }

    if (!textView.text) {
        [self.values removeObjectForKey:noteKey];
    } else {
        [self.values setObject:textView.text forKey:noteKey];
    }
    [self enableSaveBtn];
}

#pragma mark - MWPhotoBrowserDelegate
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deleteCurrentPhoto:(NSInteger)photoIndex {
    NSLog(@"");
    NSString *msg = nil;
    
    msg = @"Removing current photo!";
    
    NSMutableArray *photos = [self.photos objectForKey:self.category];
    
    [self showSimpleMessageAndHide:msg];
    
    MWPhoto *photo = [photos objectAtIndex:photoIndex];
    [self deleteRCOPhotoObjectForPhoto:photo atIndex:photoIndex];
    [photos removeObjectAtIndex:photoIndex];
    NSMutableArray *thumbs = [self.thumbs objectForKey:self.category];
    [thumbs removeObjectAtIndex:photoIndex];
    [self.thumbs setObject:thumbs forKey:self.category];
    
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
    
    NSMutableArray *photos = [self.photos objectForKey:self.category];
    MWPhoto *photo = [photos objectAtIndex:photoIndex];
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
        // self.category should be the mobileRecordId of the note
        Note *note = (Note*)[[self aggregate] getObjectMobileRecordId:self.category];
        RCOObject *parentObj = note;

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
            
            newPhoto.category = self.category;
            
            // 18.03.2020 we need the student record id
            newPhoto.creatorRecordId = self.student.rcoRecordId;
            
            newPhoto.dateTime = [NSDate date];
            newPhoto.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
            newPhoto.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
            
            newPhoto.itemType = ItemTypePhoto;
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
            
            NSMutableArray *photos = [self.photosRecords objectForKey:self.category];
            if (!photos) {
                photos = [NSMutableArray array];
            }
            [photos addObject:newPhoto];
            
            if (!self.photosRecords) {
                self.photosRecords = [NSMutableDictionary dictionary];
            }
            
            [self.photosRecords setObject:photos forKey:self.category];
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
        
        NSMutableArray *photos = [self.photos objectForKey:self.category];
        if (!photos) {
            photos = [NSMutableArray array];
        }
        [photos addObject:photoObject];
        
        [self.photos setObject:photos forKey:self.category];
        
        [self.selections addObject:[NSNumber numberWithBool:NO]];
        NSMutableArray *thumbs = [self.thumbs objectForKey:self.category];
        if (!thumbs) {
            thumbs = [NSMutableArray array];
        }
        [thumbs addObject:[MWPhoto photoWithImage:image]];
        [self.thumbs setObject:thumbs forKey:self.category];
        
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
        NSString *key = [NSString stringWithFormat:@"%d", (int)(photos.count -1)];
        [self.photosInfo setObject:photoObject forKey:key];
    }
    [photoBrowser reloadData];
    if (self.photos.count) {
        [photoBrowser setCurrentPhotoIndex:(self.photos.count - 1)];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    NSArray *photos = [self.photos objectForKey:self.category];
    return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSArray *photos = [self.photos objectForKey:self.category];
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    NSArray *thumbs = [self.thumbs objectForKey:self.category];
    if (index < thumbs.count)
        return [thumbs objectAtIndex:index];
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
