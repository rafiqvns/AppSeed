//
//  InvoiceActionDetailViewController.m
//  MobileOffice
//
//  Created by Dragos Dragos on 7/20/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "InvoiceActionDetailViewController.h"
#import "DataRepository.h"
#import "RCOLog.h"
#import "ItemDetailFullTextViewController.h"
#import "InvoiceReceivingCell.h"

#import "PurchaseOrderDetail.h"
#import "RMACDetail.h"
#import "RMAVDetail.h"

#import "PurchaseOrderHeader.h"
#import "RMACHeader.h"
#import "RMAVHeader.h"

#import "PurchaseOrderDetailAggregate.h"
#import "ReturnCustomerDetailAggregate.h"
#import "ReturnVendorDetailAggregate.h"

#import "Settings.h"

#import <QuartzCore/QuartzCore.h>

#define kCellIndexRow 0
#define kCellIndexLabeled 1
#define kCellIndexTrack 2
#define kCellIndexItem 3
#define kCellIndexLocation 4
#define kCellIndexRecvd 5
#define kCellIndexQty 6
#define kCellIndexRecordId 7
#define kCellIndexDesc 8

#define kKeyboardLandscapePageValue 5
#define kKeyboardPortraitPageValue 8


@interface InvoiceActionDetailViewController ()
-(void)loadLeadInfo;
@end

@implementation InvoiceActionDetailViewController

@synthesize landscapeView;
@synthesize portraitView;

@synthesize currentItem;
@synthesize activityIndicator;

@synthesize tableView;
@synthesize tableHeaderView;
@synthesize headerView;

@synthesize masterDelegate;
@synthesize currentSelection;

@synthesize deviceInfo;
@synthesize scanApiTimer;
@synthesize scanApiHelper;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.scanApiHelper = [[[ScanApiHelper alloc] init] autorelease];
        [self.scanApiHelper setDelegate:self];
        [self.scanApiHelper open];
        _numericKeyboard = [[NumericKeyboard alloc] initWithNibName:@"NumericKeyboard" bundle:nil];
        _numericKeyboard.keyboardDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped:)];
    self.navigationItem.rightBarButtonItem = editBtn;
    [editBtn release];
    self.tableView.allowsMultipleSelection = NO;
    
    UIImageView *tableViewFooter = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 2)];
    tableViewFooter.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = tableViewFooter;
    [tableViewFooter release];
    
    tableViewFooter = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableHeaderView.frame.size.width, 2)];
    tableViewFooter.backgroundColor = [UIColor blackColor];
    self.tableHeaderView.tableFooterView = tableViewFooter;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self loadPortraitViews];
    } else  if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self loadLandscapeViews];
    }
    CGRect frame = self.tableView.frame;
    frame.size.height = 44*[_itemDetails count] + 2;
    self.tableView.frame = frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    
    self.tableHeaderView.layer.borderColor = [[UIColor colorWithRed:177.0/255 green:181.0/255 blue:186.0/255 alpha:1.0] CGColor];
    self.tableHeaderView.layer.borderWidth = 1;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    // unregister for keyboard notifications while not visible.
    //[self.aggregate unRegisterForCallback:self];
    [self stopScanner];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if (DEVICE_IS_IPAD) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frame = self.view.frame;
            frame.size.height = 960;
            self.view.frame = frame;
        } else  if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGRect frame = self.view.frame;
            frame.size.height = 704;
            self.view.frame = frame;
        } 
        [self.view layoutSubviews];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)loadPortraitViews {

    if (DEVICE_IS_IPHONE) {
        // we don't need to rotate if is Iphone
        return;
    }
    
    CGRect frame = self.view.frame;
    
    if (DEVICE_IS_IPAD) {
        frame.size.height = 960;
        self.view.frame = frame;
        [self.view layoutSubviews];
    }
    
    NSArray *subviews = self.view.subviews;
        
    double delta = frame.size.width / self.portraitView.frame.size.width;
    
    for (int i = 0; i < [subviews count]; i++) {
        UIView *subView = [subviews objectAtIndex:i];
        UIView *portraitViewTmp = [self.portraitView viewWithTag:subView.tag];
        
        CGRect newFrame = portraitViewTmp.frame;
        newFrame.size.width *= delta;
        newFrame.origin.x *=delta;
        
        subView.frame = newFrame;
        
        if (subView.tag == 100) {
            // this is the backgound
            UIImageView *bg = (UIImageView*)subView;
            bg.image = [UIImage imageNamed:@"iPad_background_wood_portrait.png"];
            bg.contentMode = UIViewContentModeScaleToFill;
        }
        
        if (subView.tag == 104) {
            // this is the frame
            UIImageView *bg = (UIImageView*)subView;
            bg.image = [UIImage imageNamed:@"iPad_border_portrait.png"];
            bg.contentMode = UIViewContentModeScaleToFill;
        }
    }
    [self reloadTable];

}

-(void)loadLandscapeViews {
    
    if (DEVICE_IS_IPHONE) {
        // we don't need to rotate if is Iphone
        return;
    }
    
    CGRect frame = self.view.frame;
    
    if (DEVICE_IS_IPAD) {
        frame.size.height = 704;
        self.view.frame = frame;
        [self.view layoutSubviews];
    }
    
    NSArray *subviews = self.view.subviews;
    
    double delta = frame.size.width / self.landscapeView.frame.size.width;

    //frame = self.landscapeView.frame;
    
    for (int i = 0; i < [subviews count]; i++) {
        UIView *subView = [subviews objectAtIndex:i];
        UIView *landscapeViewTmo = [self.landscapeView viewWithTag:subView.tag];
        
        CGRect newFrame = landscapeViewTmo.frame;
        newFrame.size.width *= delta;
        newFrame.origin.x *=delta;
        
        subView.frame = newFrame;        
        if (subView.tag == 100) {
            // this is the backgound
            UIImageView *bg = (UIImageView*)subView;
            bg.image = [UIImage imageNamed:@"iPad_background_wood_landscape.png"];
            bg.contentMode = UIViewContentModeScaleToFill;
        }
        
        if (subView.tag == 104) {
            // this is the frame
            UIImageView *bg = (UIImageView*)subView;
            bg.image = [UIImage imageNamed:@"iPad_border_landscape.png"];
            bg.contentMode = UIViewContentModeScaleToFill;
        }
    }
    [self reloadTable];

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || 
        (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        if (DEVICE_IS_IPAD) {
            [self loadPortraitViews];
        }
    } else {
        if (DEVICE_IS_IPAD) {
            [self loadLandscapeViews];
        }
    }
}

-(IBAction)actionPressed:(id)sender {
    
}

-(void)editTapped:(id)sender {
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savedTapped:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    [saveBtn release];
    _isEditing = YES;
    self.tableView.allowsMultipleSelection = YES;
    //[self reloadTable];
    if (!self.currentSelection) {
        if ([_itemDetails count] > 0) {
            NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
            self.currentSelection = firstRow;
            _currentCellIndex = kCellIndexItem;
            [self selectRow:0 focus:YES];
        }
    }
    if (!TARGET_IPHONE_SIMULATOR) {
        [self startScanning];
    }
}

-(void)savedTapped:(id)sender {
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped:)];
    self.navigationItem.rightBarButtonItem = editBtn;
    [editBtn release];
    _isEditing = NO;
    self.tableView.allowsMultipleSelection = NO;
    [self saveItem];
    [self reloadTable];
    
    if (!TARGET_IPHONE_SIMULATOR) {
        [self stopTimer];
    }
}

-(void)reloadTable {
    [self.tableView reloadData];

    [self calculateTableViewFrame];
    
    if ([_itemDetails count] > 0) {
        NSIndexPath *bottomRow = [NSIndexPath indexPathForRow:([_itemDetails count] - 1) inSection:0];

        [self.tableView scrollToRowAtIndexPath:bottomRow atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)calculateTableViewFrame {
    CGRect tableViewFrame = self.tableView.frame;
    double tableHeight = 0;
    
    if ((tableViewFrame.origin.y + tableViewFrame.size.height) < self.view.frame.size.height) {
        NSInteger nrOfRows = 0;
        if (_isEditing) {
            nrOfRows = [_itemDetails count];
        } else {
            nrOfRows = [_itemDetails count];
        }
        tableHeight = nrOfRows *44 + 2;
        //self.tableView.bounces = NO;
    } else {
        tableHeight = self.view.frame.size.height - tableViewFrame.origin.y;
        //self.tableView.bounces = YES;
    }
    
    tableViewFrame.size.height = tableHeight;
    self.tableView.frame = tableViewFrame;
}

-(void)saveItem {
    
    if (_currentReceivingType == ReceivingType_PO) {
        
        PurchaseOrderDetailAggregate *agg = [[[DataRepository sharedInstance].purchaseOrderHeaderAggregate detailAggregates] objectAtIndex:0];
        [agg save];
        [self savePurchaseOrder];
        
    } else if (_currentReceivingType == ReceivingType_RMAC) {
        
        ReturnCustomerDetailAggregate *agg = [[[DataRepository sharedInstance].returnCustomerAggregate detailAggregates] objectAtIndex:0];
        [agg save];
        [self saveRMAC];
        
    } else if (_currentReceivingType == ReceivingType_RMAV){
        
        ReturnVendorDetailAggregate *agg = [[[DataRepository sharedInstance].returnVendorAggregate detailAggregates] objectAtIndex:0];
        [agg save];
        [self saveRMAV];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    if (theTableView == self.tableHeaderView) {
        return 2;
    }
    if (_isEditing) {
        return [_itemDetails count];
    } else {
        return [_itemDetails count];
    }
}

- (UITableViewCell *)configureHeaderTableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellTableIdentifierInvItem = @"InvoiceReceivingCell";
    
    InvoiceReceivingCell* cell=nil;
    
    cell = (InvoiceReceivingCell*)[theTableView dequeueReusableCellWithIdentifier:cellTableIdentifierInvItem];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InvoiceReceivingCell"
                                                     owner:self
                                                   options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (indexPath.row == 0) {
        // this is the number of column
        cell.rowIndex.text = @"";
        cell.rowIndex.backgroundColor = [UIColor lightGrayColor];
        [cell.rowIndex setEnabled:YES];
        cell.rowIndex.tag = 99999;
        cell.labeled.text = @"A";
        cell.track.text = @"B";
        cell.item.text = @"C";
        cell.location.text = @"D";
        cell.quantity.text = @"E";
        cell.recvd.text = @"F";
        cell.recordId.text = @"G";
        cell.itemDescription.text = @"H";

    } else {
        cell.rowIndex.text = @"Nr";
        cell.labeled.text = @"Labeled";
        cell.track.text = @"Track";
        cell.recordId.text = @"RecordId";
        cell.quantity.text = @"Qty";
        cell.recvd.text = @"Received";
        cell.item.text = @"Item";
        cell.location.text = @"Location";
        cell.itemDescription.text = @"Description";
        
        [self changeBgForCell:cell from:-1 to:-9 with:@"gridRowColHeadingInteriorYellow"];
    }
    
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.backgroundView.backgroundColor = [UIColor lightGrayColor];
    
    [cell configureCell];
    cell.selectDelegate = self;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (theTableView == self.tableHeaderView) {
        return [self configureHeaderTableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        static NSString *cellTableIdentifierInvItem = @"InvoiceReceivingCell";
        
        InvoiceReceivingCell* cell=nil;
        
        cell = (InvoiceReceivingCell*)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifierInvItem];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InvoiceReceivingCell"
                                                         owner:self
                                                       options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.labeled.tag = kCellIndexLabeled + indexPath.row *1000;
        [cell.labeled setEnabled:YES];
        cell.labeled.delegate = self;
        
        cell.track.tag = kCellIndexTrack  + indexPath.row *1000;
        [cell.track setEnabled:YES];
        cell.track.delegate = self;
        
        cell.recordId.tag = kCellIndexRecordId + indexPath.row *1000;
        cell.recordId.delegate = self;
        [cell.recordId setEnabled:YES];
        [cell.recordId addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        cell.quantity.tag = kCellIndexQty + indexPath.row *1000;
        cell.quantity.delegate = self;
        [cell.quantity setEnabled:YES];
        [cell.quantity addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        cell.recvd.tag = kCellIndexRecvd + indexPath.row *1000;
        cell.recvd.delegate = self;
        [cell.recvd setEnabled:YES];
        [cell.recvd addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        cell.item.tag = kCellIndexItem + indexPath.row *1000;
        cell.item.delegate = self;
        [cell.item setEnabled:YES];
        [cell.item addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        cell.location.tag = kCellIndexLocation + indexPath.row *1000;
        cell.location.delegate = self;
        [cell.location setEnabled:YES];
        [cell.location addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        cell.itemDescription.tag = kCellIndexDesc + indexPath.row *1000;
        cell.itemDescription.delegate = self;
        [cell.itemDescription setEnabled:YES];
        
        if (indexPath.row < [_itemDetails count]) {
            RCOObject *detail = [_itemDetails objectAtIndex:indexPath.row];
            if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
                PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
                cell.labeled.text = detailObj.podLabeled;
                cell.track.text = detailObj.podTrack;
                cell.location.text = detailObj.podLocation;
                cell.recordId.text = detailObj.rcoRecordId;
                cell.itemDescription.text = detailObj.podDescription;
                cell.item.text = detailObj.podItemNumber;
                cell.quantity.text = detailObj.podQuantity;
                cell.recvd.text = detailObj.podQuantityReceived;
            } else if ([detail isKindOfClass:[RMACDetail class]]) {
                RMACDetail *detailObj = (RMACDetail*)detail;
                cell.labeled.text = detailObj.rmacdLabeled;
                cell.track.text = detailObj.rmacdTrack;
                cell.location.text = detailObj.rmacdLocation;
                cell.recordId.text = detailObj.rcoRecordId;
                cell.itemDescription.text = detailObj.rmacdDescription;
                cell.item.text = detailObj.rmacdItemNumber;
                cell.quantity.text = detailObj.rmacdQtyToReturn;
                cell.recvd.text = detailObj.rmacdQtyReturned;
            } else {
                RMAVDetail *detailObj = (RMAVDetail*)detail;
                cell.labeled.text = detailObj.rmavdLabeled;
                cell.track.text = detailObj.rmavdTrack;
                cell.location.text = detailObj.rmavdLocation;
                cell.recordId.text = detailObj.rcoRecordId;
                cell.itemDescription.text = detailObj.rmavdDescription;
                cell.item.text = detailObj.rmavdItemNumber;
                cell.quantity.text = detailObj.rmavdQuantity;
                cell.recvd.text = detailObj.rmavdQuantityReturned;
            }
        } else {
            cell.labeled.text = nil;
            cell.track.text = nil;
            cell.location.text = nil;
            cell.recordId.text = nil;
            cell.itemDescription.text = nil;
            cell.item.text = nil;
            cell.quantity.text = nil;
            cell.recvd.text = nil;

        }
        cell.rowIndex.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
        cell.rowIndex.tag = kCellIndexRow + indexPath.row *1000;
        [cell.rowIndex setEnabled:YES];

        [cell configureCell];
        cell.selectDelegate = self;
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        if ((indexPath.row == self.currentSelection.row) && (_currentCellIndex == kCellIndexLabeled)) {
            UIImageView * bg = (UIImageView*)[cell viewWithTag:(0 - 100)];
            bg.highlighted = YES;
            bg = (UIImageView*)[cell viewWithTag:(0 - 1)];
            bg.highlighted = YES;
            cell.labeled.layer.borderColor = [[UIColor blackColor] CGColor];
            cell.labeled.layer.borderWidth = 2;
        }
        
        //make the background white
        [self changeBgForCell:cell from:-2 to:-9 with:@"gridRowColHeadingInteriorWhite"];
        
        return cell;
    }
}

-(void)changeBgForCell:(InvoiceReceivingCell*)cell from:(NSInteger)start to:(NSInteger)end with:(NSString*)bgImageName {
    
    UIImage *image = [UIImage imageNamed:bgImageName];

    for (int i = end; i <= start; i++) {
        UIImageView *bgImage = (UIImageView*)[cell viewWithTag:i];
        bgImage.image = image;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

-(void)selectColumnHeader:(BOOL)selected {
    // select the corresponding column and row
    if (!_isEditing) {
        return;
    }
    
    InvoiceReceivingCell *cell = (InvoiceReceivingCell*)[self.tableHeaderView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    NSInteger index = (0 - _currentCellIndex - 1);
    UIImageView *bg = (UIImageView*)[cell viewWithTag:index];
    bg.highlighted = selected;
    
    UIImageView *leftBorder = (UIImageView*)[cell viewWithTag:((index + 1)*100)];
    leftBorder.highlighted = selected;
    
    UIImageView *rightBorder = (UIImageView*)[cell viewWithTag:(index*100)];
    rightBorder.highlighted = selected;

    cell = (InvoiceReceivingCell*)[self.tableView cellForRowAtIndexPath:self.currentSelection];
    
    bg = (UIImageView*)[cell viewWithTag:(-1)];
    bg.highlighted = selected;

    bg = (UIImageView*)[cell viewWithTag:(-100)];
    bg.highlighted = selected;
    
    [self.tableView scrollToRowAtIndexPath:self.currentSelection atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

-(void)selectRow:(NSInteger)index focus:(BOOL)shouldFocus{
    
    if (!_isEditing) {
        return;
    }
    
    if (_allSelected) {
        [self selectAllRows];
    }
    
    self.tableView.allowsMultipleSelection = NO;

    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
    
    self.currentSelection = indexpath;
    
    InvoiceReceivingCell *cell = (InvoiceReceivingCell*)[self.tableView cellForRowAtIndexPath:self.currentSelection];
    
    if (cell == nil) {
        // the cell was not visible
        [self.tableView scrollToRowAtIndexPath:self.currentSelection atScrollPosition:UITableViewScrollPositionTop animated:NO];
        cell = (InvoiceReceivingCell*)[self.tableView cellForRowAtIndexPath:self.currentSelection];
    }
    
    UIView *selectedView = nil;
    if (_currentCellIndex == kCellIndexRow) {
        selectedView = cell.rowIndex;
    } else if (_currentCellIndex == kCellIndexLabeled) {
        selectedView = cell.labeled;
        //_numericKeyboard.textField = (UITextField*)selectedView;
        // we set the textfield for keyboard to nil in order to diaseble the input
        _numericKeyboard.textField = nil;

        ((UITextField*)selectedView).inputView = _numericKeyboard.view;
        if (shouldFocus) {
            [(UITextField*)selectedView becomeFirstResponder];
        }
    } else if (_currentCellIndex == kCellIndexTrack) {
        selectedView = cell.track;
    } else if (_currentCellIndex == kCellIndexRecordId) {
        selectedView = cell.recordId;
    } else if (_currentCellIndex == kCellIndexQty) {
        selectedView = cell.quantity;
    } else if (_currentCellIndex == kCellIndexRecvd) {
        selectedView = cell.recvd;
        _numericKeyboard.textField = (UITextField*)selectedView;
        ((UITextField*)selectedView).inputView = _numericKeyboard.view;
        if (shouldFocus) {
            [(UITextField*)selectedView becomeFirstResponder];
        }
    } else if (_currentCellIndex == kCellIndexLocation) {
        selectedView = cell.location;
        _numericKeyboard.textField = (UITextField*)selectedView;
        ((UITextField*)selectedView).inputView = _numericKeyboard.view;
        if (shouldFocus) {
            [(UITextField*)selectedView becomeFirstResponder];
        }
    } else if (_currentCellIndex == kCellIndexItem) {
        selectedView = cell.item;
        _numericKeyboard.textField = (UITextField*)selectedView;
        ((UITextField*)selectedView).inputView = _numericKeyboard.view;
        if (shouldFocus) {
            [(UITextField*)selectedView becomeFirstResponder];
        }
    } else if (_currentCellIndex == kCellIndexDesc) {
        selectedView = cell.itemDescription;
    }
    if (_isEditing) {
        selectedView.layer.borderColor = [[UIColor blackColor] CGColor];
        selectedView.layer.borderWidth = 2;
    } else {
    }
    
    [self selectColumnHeader:YES];
    
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)deselectCell{
    
    if (!_isEditing) {
        return;
    }
    
    InvoiceReceivingCell *cell = (InvoiceReceivingCell*)[self.tableView cellForRowAtIndexPath:self.currentSelection];
    
    cell.rowIndex.layer.borderWidth = 0;
    cell.labeled.layer.borderWidth = 0;
    cell.track.layer.borderWidth = 0;
    cell.item.layer.borderWidth = 0;
    cell.itemDescription.layer.borderWidth = 0;
    cell.recordId.layer.borderWidth = 0;
    cell.recvd.layer.borderWidth = 0;
    cell.quantity.layer.borderWidth = 0;
    cell.location.layer.borderWidth = 0;
    
    [self selectColumnHeader:NO];
}

-(void)setLabeled:(NSString*)value forIndex:(NSInteger)index {
    // we force select the value
    RCOObject *detail = [_itemDetails objectAtIndex:index];
    if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
        PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
        detailObj.podLabeled = value;
    } else if ([detail isKindOfClass:[RMACDetail class]]) {
        RMACDetail *detailObj = (RMACDetail*)detail;
        detailObj.rmacdLabeled = value;
    } else {
        RMAVDetail *detailObj = (RMAVDetail*)detail;
        detailObj.rmavdLabeled = value;
    }
    
    InvoiceReceivingCell *cell = (InvoiceReceivingCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.labeled.text = value;

}

-(void)setLabeledForIndex:(NSInteger)index {
    // we enable / disable the current value
    RCOObject *detail = [_itemDetails objectAtIndex:index];
    InvoiceReceivingCell *cell = (InvoiceReceivingCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
        PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
        if (detailObj.podLabeled == nil) {
            detailObj.podLabeled = @"X";
            cell.labeled.text = @"X";
        } else {
            detailObj.podLabeled = nil;
            cell.labeled.text = nil;
        }
    } else if ([detail isKindOfClass:[RMACDetail class]]) {
        RMACDetail *detailObj = (RMACDetail*)detail;
        if (detailObj.rmacdLabeled == nil) {
            detailObj.rmacdLabeled = @"X";
            cell.labeled.text = @"X";
        } else {
            detailObj.rmacdLabeled = nil;
            cell.labeled.text = nil;
        }
    } else {
        RMAVDetail *detailObj = (RMAVDetail*)detail;
        if (detailObj.rmavdLabeled == nil) {
            detailObj.rmavdLabeled = @"X";
            cell.labeled.text = @"X";
        } else {
            detailObj.rmavdLabeled = nil;
            cell.labeled.text = nil;
        }
    }
    //[self.tableView reloadData];
}

-(void)setTrackForIndex:(NSInteger)index {
    RCOObject *detail = [_itemDetails objectAtIndex:index];
    if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
        PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
        if (detailObj.podTrack == nil) {
            detailObj.podTrack = @"yes";
        } else {
            detailObj.podTrack = nil;
        }
    } else if ([detail isKindOfClass:[RMACDetail class]]) {
        RMACDetail *detailObj = (RMACDetail*)detail;
        if (detailObj.rmacdTrack == nil) {
            detailObj.rmacdTrack = @"yes";
        } else {
            detailObj.rmacdTrack = nil;
        }
    } else {
        RMAVDetail *detailObj = (RMAVDetail*)detail;
        if (detailObj.rmavdTrack == nil) {
            detailObj.rmavdTrack = @"yes";
        } else {
            detailObj.rmavdTrack = nil;
        }
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Actions

- (IBAction)printLabelPressed:(id)sender
{
    PrintLabelPreview *ctrl = [[PrintLabelPreview alloc] initWithNibName:@"PrintLabelPreview" bundle:nil items:_itemDetails];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [ctrl.navigationController.navigationBar setHidden:NO];
//        [self.navigationController.navigationBar setHidden:NO];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ctrl];
        
        // You can even set the style of stuff before you show it
        navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        [self.navigationController presentModalViewController:navigationController animated:YES];
        [navigationController release];
        
        //                [ctrl.navigationController.navigationBar setHidden:true];
        //                [self.navigationController pushViewController:ctrl animated:YES];
        //                [self.navigationController.navigationBar setHidden:true];
        
        [ctrl release];
        
    }
//    else {
//        [self launchChildController: ctrl];
//        [ctrl release];
//    }

}

- (IBAction)labelPaperPressed:(id)sender {
    
}

-(void)selectAllRows {
    
    if (_isEditing) {
        self.tableView.allowsMultipleSelection = YES;
        for (int i = 0 ; i < [_itemDetails count]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            if (!_allSelected) {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
        _allSelected = !_allSelected;
    }

}

-(IBAction)tapOnRowIndex:(id)sender {
    UITapGestureRecognizer *tapgesture = (UITapGestureRecognizer*)sender;
    
    if (tapgesture.view.tag == 99999) {
        [self selectAllRows];
        return;
    }
    
    [self deselectCell];
    NSInteger row = tapgesture.view.tag / 1000;
    _currentCellIndex = tapgesture.view.tag - row*1000;
    
    [self selectRow:row focus:YES];
}

-(IBAction)tapOnLabeled:(id)sender {
        
    [self deselectCell];
    NSInteger row = 0;
    
    if (sender) {
        // this is the case when the user taps on the labeled cell
        UITapGestureRecognizer *tapgesture = (UITapGestureRecognizer*)sender;
        row = tapgesture.view.tag / 1000;
        _currentCellIndex = tapgesture.view.tag - row*1000;
    } else {
        // this is the case when the user taps on X key from keyboard, and wants to mark / unmark the labeled
        row = self.currentSelection.row;
        _currentCellIndex = kCellIndexLabeled;
    }
    
    if (_isEditing) {
        if (_allSelected) {
            self.tableView.allowsMultipleSelection = YES;
            InvoiceReceivingCell *cell = (InvoiceReceivingCell*)[self.tableView cellForRowAtIndexPath:self.currentSelection];
            NSString *value = cell.labeled.text;
            if (value) {
                value = nil;
            } else {
                value = @"X";
            }
            for (int i = 0; i < [_itemDetails count]; i++) {
                [self setLabeled:value forIndex:i];
            }
            //[self.tableView reloadData];
            _allSelected = NO;
        } else {
            [self setLabeledForIndex:row];
        }
    }
    [self selectRow:row focus:NO];
}

-(IBAction)tapOnTrack:(id)sender {
    return;
    UITapGestureRecognizer *tapgesture = (UITapGestureRecognizer*)sender;
    
    [self deselectCell];
    NSInteger row = tapgesture.view.tag / 1000;
    _currentCellIndex = tapgesture.view.tag - row*1000;
    
    //[self setTrackForIndex:row];
    [self selectRow:row focus:YES];
}

#pragma mark - 
#pragma mark RCOSpliterSelectionDelegate 


-(void)RCOSpliterSelectedObject:(RCOObject*)object {
    
    self.currentItem = object;
    [_itemDetails removeAllObjects];
    [_itemDetails release];
    NSArray *itemdetails = [[self aggregate] getObjectsWithMasterBarcode:object.rcoBarcode];
    _itemDetails = [[NSMutableArray alloc] initWithArray:itemdetails];
    
    if ([self.currentItem isKindOfClass:[PurchaseOrderHeader class]]) {
        self.title = @" Purchase Order";
    } else if ([self.currentItem isKindOfClass:[RMACHeader class]]) {
        self.title = @" Customer Return";
    } else if ([self.currentItem isKindOfClass:[RMAVHeader class]]) {
        self.title = @" Vendor Return";
    }

    [self.tableView reloadData];
    [self.tableHeaderView reloadData];
    [self reloadTable];
    
    if ([_itemDetails count] > 0) {
        self.currentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
        _currentCellIndex = kCellIndexItem;
    }
}

-(void)RCOSpliterReceiveMessageFromMaster:(NSString*)message {
    UIView *statusView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    
    if ([message isEqualToString:@"START_SCANNING"]) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.center = CGPointMake(15, 22);
        [statusView addSubview:spinner];
        [spinner startAnimating];

        UIImage *img = [UIImage imageNamed:@"scannerOff50x37"];
        UIImageView *scannerImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 3, 50, 37)];
        scannerImage.image = img;
        [statusView addSubview:scannerImage];
        [scannerImage release];
    } else {
        UIImage *img = [UIImage imageNamed:@"scanner50x37"];
        UIImageView *scannerImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 3, 50, 37)];
        scannerImage.image = img;
        [statusView addSubview:scannerImage];
        [scannerImage release];
    }
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:statusView];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
}

-(void)loadItemInfo {

}

-(void)dealloc {
    self.landscapeView = nil;
    self.portraitView = nil;
    self.currentItem = nil;
    self.mapView = nil;
    self.activityIndicator = nil;
    
    self.tableView = nil;
    self.tableHeaderView = nil;
    self.headerView = nil;
    self.currentSelection = nil;
    
    [_itemDetails release], _itemDetails = nil;
    [_numericKeyboard release], _numericKeyboard = nil;
    
    [super dealloc];
}

-(void)addNewItem:(Part*)part {
    
    if (_currentReceivingType == ReceivingType_PO) {
        
        PurchaseOrderDetailAggregate *agg = [[[DataRepository sharedInstance].purchaseOrderHeaderAggregate detailAggregates] objectAtIndex:0];
        
        PurchaseOrderHeader *poh = (PurchaseOrderHeader*)self.currentItem;
        PurchaseOrderDetail *pod = (PurchaseOrderDetail*)[agg createNewObject];
        pod.rcoBarcodeParent = poh.rcoBarcode;
        pod.podItemNumber = part.partNumber;
        [_itemDetails addObject:pod];
        
    } else if (_currentReceivingType == ReceivingType_RMAC) {
        
        ReturnCustomerDetailAggregate *agg = [[[DataRepository sharedInstance].returnCustomerAggregate detailAggregates] objectAtIndex:0];
        
        RMACHeader *rmach = (RMACHeader*)self.currentItem;
        RMACDetail *rmacd = (RMACDetail*)[agg createNewObject];
        rmacd.rcoBarcodeParent = rmach.rcoBarcode;
        rmacd.rmacdItemNumber = part.partNumber;
        [_itemDetails addObject:rmacd];
    } else if (_currentReceivingType == ReceivingType_RMAV){
        
        ReturnVendorDetailAggregate *agg = [[[DataRepository sharedInstance].returnVendorAggregate detailAggregates] objectAtIndex:0];
        
        RMAVHeader *rmavh = (RMAVHeader*)self.currentItem;
        RMAVDetail *rmavd = (RMAVDetail*)[agg createNewObject];
        rmavd.rcoBarcodeParent = rmavh.rcoBarcode;
        rmavd.rmavdItemNumber = part.partNumber;
        [_itemDetails addObject:rmavd];
    }
    
    [self reloadTable];
}

-(void)searchForItem:(NSString*)itemNumber forRow:(NSInteger)row selectNextCell:(BOOL)selectNextCell{
    Part *part = [[DataRepository sharedInstance].partsAggregate getPartWithNumber:itemNumber forStore:PART_LIBRARY_STORENUM];
    NSLog(@"Part desc = %@  item number = %@  Record Id = %@  Tracking = %@", part.partDescription, part.partNumber, part.rcoRecordId, part.partTracking);
    NSString *partTracking = nil;
    if ([part.partTracking boolValue]) {
        partTracking= @"yes";
    } else {
        partTracking= @"no";
    }
    
    if (row >= [_itemDetails count]) {
        [self addNewItem:part];
    }
    
    if (part) {
        RCOObject *item = [_itemDetails objectAtIndex:row];
        if ([item isKindOfClass:[PurchaseOrderDetail class]]) {
            PurchaseOrderDetail *pod = (PurchaseOrderDetail*)item;
            pod.podTrack = partTracking;
            pod.podDescription = part.partDescription;
            pod.podItemNumber = itemNumber;
        } else if ([item isKindOfClass:[RMAVDetail class]]) {
            RMAVDetail *rmavd = (RMAVDetail*)item;
            rmavd.rmavdTrack = partTracking;
            rmavd.rmavdDescription = part.partDescription;
            rmavd.rmavdItemNumber = itemNumber;
        } else if ([item isKindOfClass:[RMACDetail class]]) {
            RMACDetail *rmacd = (RMACDetail*)item;
            rmacd.rmacdTrack = partTracking;
            rmacd.rmacdDescription = part.partDescription;
            rmacd.rmacdItemNumber = itemNumber;
        }
    
        //[self.tableView reloadData];
        if (selectNextCell) {
            [self deselectCell];
            _currentCellIndex = kCellIndexLocation;
            [self selectRow:self.currentSelection.row focus:YES];
        }
        
    } else {
        NSString *message = [NSString stringWithFormat:@"Item :\n %@ \n Was not found!", itemNumber];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        //[alert show];
        [alert release];
    }

}

-(void)searchLocation:(NSString*)location forRow:(NSInteger)row selectNextCell:(BOOL)selectNextCel{

    if ([location length] > 0) {
        // location is valid
        RCOObject *item = [_itemDetails objectAtIndex:row];
        if ([item isKindOfClass:[PurchaseOrderDetail class]]) {
            PurchaseOrderDetail *pod = (PurchaseOrderDetail*)item;
            pod.podLocation = location;
        } else if ([item isKindOfClass:[RMAVDetail class]]) {
            RMAVDetail *rmavd = (RMAVDetail*)item;
            rmavd.rmavdLocation = location;
        } else if ([item isKindOfClass:[RMACDetail class]]) {
            RMACDetail *rmacd = (RMACDetail*)item;
            rmacd.rmacdLocation = location;
        }
        
        //[self.tableView reloadData];
        if (selectNextCel) {
            [self deselectCell];
            _currentCellIndex = kCellIndexRecvd;
            [self selectRow:self.currentSelection.row focus:YES];
        }
        
    } else {
        NSString *message = [NSString stringWithFormat:@"Location :\n %@ \n Was not found!", location];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        //[alert show];
        [alert release];
    }
}

-(void)setReceived:(NSString*)received forRow:(NSInteger)row selectNextCell:(BOOL)selectNextCel{
    
    if ([received doubleValue] > 0) {
        // location is valid
        RCOObject *item = [_itemDetails objectAtIndex:row];
        if ([item isKindOfClass:[PurchaseOrderDetail class]]) {
            PurchaseOrderDetail *pod = (PurchaseOrderDetail*)item;
            pod.podQuantityReceived = received;
        } else if ([item isKindOfClass:[RMAVDetail class]]) {
            RMAVDetail *rmavd = (RMAVDetail*)item;
            rmavd.rmavdQuantityReturned = received;
        } else if ([item isKindOfClass:[RMACDetail class]]) {
            RMACDetail *rmacd = (RMACDetail*)item;
            rmacd.rmacdQtyReturned = received;
        }
        
        //[self.tableView reloadData];
        NSInteger nextRow = self.currentSelection.row + 1;
        if (nextRow < [_itemDetails count]) {
            
        } else {
            nextRow = 0;
        }
        if (selectNextCel) {
            [self deselectCell];
            _currentCellIndex = kCellIndexItem;
            [self selectRow:nextRow focus:YES];
        }
        
    } else {
        NSString *message = [NSString stringWithFormat:@"Please set a valid value for received. \n %@ \n is not a valid value", received];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        //[alert show];
        [alert release];
    }
}

- (void) contentDownloadComplete: (NSString *) objectId fromAggregate: (Aggregate *) aggregate
{
    if (!objectId) {
        // if objectId is nil the we return
        NSLog(@"Object Id is nil!!!");
        return;
    }
}

- (IBAction)filterSelectionChanged:(id)sender {
    
    UISegmentedControl *receiveType = (UISegmentedControl*)sender;
    
    if (_isEditing) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:@"Please save the receiving first!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [receiveType setSelectedSegmentIndex:_currentReceivingType];
        return;
    }
    
    _currentReceivingType = receiveType.selectedSegmentIndex;
    
    NSString *msg = [NSString stringWithFormat:@"%d", receiveType.selectedSegmentIndex];
    [_itemDetails removeAllObjects];
    if ([self.masterDelegate respondsToSelector:@selector(RCOSpliterMasterReceiveMessageFromDetail:)]) {
        [self.masterDelegate RCOSpliterMasterReceiveMessageFromDetail:msg];
    }
    [self.tableView reloadData];
    [self.tableHeaderView reloadData];
    
}

#pragma mark -
#pragma mark RCODataViewController

- (Aggregate *) aggregate {
    
    NSArray * detailsAgg = nil;
    if ([self.currentItem isKindOfClass:[PurchaseOrderHeader class]]) {
        detailsAgg = [[[DataRepository sharedInstance] purchaseOrderHeaderAggregate] detailAggregates];
    } else if ([self.currentItem isKindOfClass:[RMACHeader class]]) {
        detailsAgg = [[[DataRepository sharedInstance] returnCustomerAggregate] detailAggregates];
    } else if ([self.currentItem isKindOfClass:[RMAVHeader class]]) {
        detailsAgg = [[[DataRepository sharedInstance] returnVendorAggregate] detailAggregates];
    }

    if ([detailsAgg count] > 0) {
        return [detailsAgg objectAtIndex:0];
    } else {
        return nil;
    }
}

-(void)setItem:(NSString*)text {
    
    RCOObject *detail = [_itemDetails objectAtIndex:self.currentSelection.row];
    if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
        PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
        detailObj.podItemNumber = text;
    } else if ([detail isKindOfClass:[RMACDetail class]]) {
        RMACDetail *detailObj = (RMACDetail*)detail;
        detailObj.rmacdItemNumber = text;
    } else {
        RMAVDetail *detailObj = (RMAVDetail*)detail;
        detailObj.rmavdItemNumber = text;
    }
}

-(void)setLocation:(NSString*)text {
    RCOObject *detail = [_itemDetails objectAtIndex:self.currentSelection.row];
    if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
        PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
        detailObj.podLocation = text;
    } else if ([detail isKindOfClass:[RMACDetail class]]) {
        RMACDetail *detailObj = (RMACDetail*)detail;
        detailObj.rmacdLocation = text;
    } else {
        RMAVDetail *detailObj = (RMAVDetail*)detail;
        detailObj.rmavdLocation = text;
    }
}

-(void)setQuantity:(NSString*)text {
    RCOObject *detail = [_itemDetails objectAtIndex:self.currentSelection.row];
    if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
        PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
        detailObj.podQuantity = text;
    } else if ([detail isKindOfClass:[RMACDetail class]]) {
        RMACDetail *detailObj = (RMACDetail*)detail;
        detailObj.rmacdQtyToReturn = text;
    } else {
        RMAVDetail *detailObj = (RMAVDetail*)detail;
        detailObj.rmavdQuantity = text;
    }
}

-(void)setReceived:(NSString*)text {
    RCOObject *detail = [_itemDetails objectAtIndex:self.currentSelection.row];
    if ([detail isKindOfClass:[PurchaseOrderDetail class]]) {
        PurchaseOrderDetail *detailObj = (PurchaseOrderDetail*)detail;
        detailObj.podQuantityReceived = text;
    } else if ([detail isKindOfClass:[RMACDetail class]]) {
        RMACDetail *detailObj = (RMACDetail*)detail;
        detailObj.rmacdQtyReturned = text;
    } else {
        RMAVDetail *detailObj = (RMAVDetail*)detail;
        detailObj.rmavdQuantityReturned = text;
    }
}

-(void)savePurchaseOrder {
    
    PurchaseOrderDetailAggregate *agg = [[[DataRepository sharedInstance].purchaseOrderHeaderAggregate detailAggregates] objectAtIndex:0];
    for (int i = 0; i < [_itemDetails count]; i++) {
        PurchaseOrderDetail *pod = (PurchaseOrderDetail*)[_itemDetails objectAtIndex:i];
        [agg updateObject:pod];
    }
}

-(void)saveRMAC {
    
    ReturnCustomerDetailAggregate *agg = [[[DataRepository sharedInstance].returnCustomerAggregate detailAggregates] objectAtIndex:0];
    for (int i = 0; i < [_itemDetails count]; i++) {
        RMACDetail *rmacd = (RMACDetail*)[_itemDetails objectAtIndex:i];
        [agg updateObject:rmacd];
    }
}

-(void)saveRMAV {
    
    ReturnVendorDetailAggregate *agg = [[[DataRepository sharedInstance].returnVendorAggregate detailAggregates] objectAtIndex:0];
    for (int i = 0; i < [_itemDetails count]; i++) {
        RMAVDetail *rmavd = (RMAVDetail*)[_itemDetails objectAtIndex:i];
        [agg updateObject:rmavd];
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (!_isEditing) {
        return NO;
    }
    
    if (textField.tag == 99999) {
        [self.view endEditing:YES];
        return NO;
    }
    
    NSInteger row = textField.tag / 1000;
    NSInteger cell =  textField.tag - row*1000;
    
    if (cell == kCellIndexLabeled) {
        if (_currentCellIndex != cell) {
            _currentCellIndex = cell;
            [self selectRow:row focus:YES];
        } else {
            _currentCellIndex = cell;
            [self selectRow:row focus:NO];
        }
        _numericKeyboard.textField = nil;
        return YES;
    }
    
    if (!(/*cell == kCellIndexItem ||*/
        cell == kCellIndexRecvd ||
        cell == kCellIndexLocation)) {
    
        [self.view endEditing:YES];
        return NO;
    }
    
    [self deselectCell];

    if ((_currentCellIndex != cell) || (self.currentSelection.row != row)) {
        _currentCellIndex = cell;
        [self selectRow:row focus:YES];
    } else {
        _currentCellIndex = cell;
        [self selectRow:row focus:NO];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    //return;
    NSInteger row = textField.tag / 1000;
    NSInteger cell = textField.tag - row*1000;
    
    /*if ((cell != _currentCellIndex) || (row != self.currentSelection.row)) */{
    
        //_currentCellIndex = cell;
        
        /*if (cell == kCellIndexItem) {
            [self searchForItem:textField.text forRow:row selectNextCell:NO];
        } else */if (cell == kCellIndexLocation) {
            [self searchLocation:textField.text forRow:row selectNextCell:NO];
        } else if (cell == kCellIndexRecvd) {
            [self setReceived:textField.text forRow:row selectNextCell:NO];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

-(void)valueChanged:(UITextField*)textField {
    return;
    NSInteger row = textField.tag / 1000;
    _currentCellIndex = textField.tag - row*1000;
    if (row < [_itemDetails count]) {
        self.currentSelection = [NSIndexPath indexPathForRow:row inSection:0];

        switch (_currentCellIndex) {
            case kCellIndexItem:
                [self setItem:textField.text];
                break;
            case kCellIndexQty:
                [self setQuantity:textField.text];
                break;
            case kCellIndexRecvd:
                [self setReceived:textField.text];
                break;
            case kCellIndexLocation:
                [self setLocation:textField.text];
                break;
            default:
                break;
        }
    } else {
        NSLog(@"is a new item !!! = %@", textField.text);
    }
}

-(void)textField:(UITextField*)textField keyPressed:(KeyboardKey)key {

    switch (key) {
        case KeyboardKey_Down: {
            [self deselectCell];
            NSLog(@"KeyboardKey_Down");
                NSInteger currentRow = self.currentSelection.row;
                if (currentRow < ([_itemDetails count] - 1) ) {
                    currentRow++;
                } else {
                    currentRow = 0;
                }
            [self selectRow:currentRow focus:YES];
        }
            break;
        case KeyboardKey_Up: {
            [self deselectCell];
            NSLog(@"KeyboardKey_Up");
            NSInteger currentRow = self.currentSelection.row;
            if (currentRow > 0 ) {
                currentRow--;
            } else {
                currentRow = [_itemDetails count] - 1;
            }
            [self selectRow:currentRow focus:YES];
        }
            break;
        case KeyboardKey_Right: {
           [self deselectCell];
            NSLog(@"KeyboardKey_Right");
            NSInteger currentRow = self.currentSelection.row;

            if (_currentCellIndex == /*kCellIndexItem*/kCellIndexLabeled) {
                _currentCellIndex = kCellIndexLocation;
            } else if (_currentCellIndex == kCellIndexLocation) {
                _currentCellIndex = kCellIndexRecvd;
            } else if (_currentCellIndex == kCellIndexRecvd) {
                //_currentCellIndex = kCellIndexItem;
                _currentCellIndex = kCellIndexLabeled;
                
                if (currentRow < ([_itemDetails count] -1)) {
                    currentRow++;
                } else {
                    currentRow = 0;
                }
            } else if (_currentCellIndex > kCellIndexRecvd) {
                //_currentCellIndex = kCellIndexItem;
                _currentCellIndex = kCellIndexLabeled;
                if (currentRow < ([_itemDetails count] -1)) {
                    currentRow++;
                } else {
                    currentRow = 0;
                }
            } else {
                // _curentIndex < ItemIndex
                _currentCellIndex = kCellIndexRecvd;
                
            }
            [self selectRow:currentRow focus:YES];
            }
            break;
        case KeyboardKey_Left: {
            [self deselectCell];
            NSLog(@"KeyboardKey_Left");
            NSInteger currentRow = self.currentSelection.row;
            
            if (_currentCellIndex == kCellIndexRecvd) {
                _currentCellIndex = kCellIndexLocation;
            } else if (_currentCellIndex == kCellIndexLocation) {
                //_currentCellIndex = kCellIndexItem;
                _currentCellIndex = kCellIndexLabeled;
            } else if (_currentCellIndex == kCellIndexItem) {
                _currentCellIndex = kCellIndexRecvd;
                if (currentRow > 0) {
                    currentRow--;
                } else {
                    currentRow = [_itemDetails count] - 1;
                }
            } else if (_currentCellIndex < kCellIndexRecvd) {
                _currentCellIndex = kCellIndexRecvd;
                if (currentRow > 0) {
                    currentRow--;
                } else {
                    currentRow = [_itemDetails count] - 1;
                }
            } else {
                // _curentIndex < ItemIndex
                //_currentCellIndex = kCellIndexItem;
                _currentCellIndex = kCellIndexLabeled;
            }
            [self selectRow:currentRow focus:YES];
        }
            break;
        case KeyboardKey_Home:
            [self deselectCell];
            NSLog(@"KeyboardKey_Home");
            _currentCellIndex = kCellIndexLabeled;
            [self selectRow:0 focus:YES];
            break;
        case KeyboardKey_End:
            [self deselectCell];
            _currentCellIndex = kCellIndexRecvd;
            [self selectRow:([_itemDetails count] - 1) focus:YES];
            break;
        case KeyboardKey_PageDown:
            [self deselectCell];
            NSLog(@"KeyboardKey_PageDown");
            NSInteger pageValue = 0;
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                pageValue = kKeyboardLandscapePageValue;
            } else {
                pageValue = kKeyboardPortraitPageValue;
            }
            
            NSInteger nextRow = self.currentSelection.row + pageValue;
            if (nextRow >= [_itemDetails count]) {
                nextRow = [_itemDetails count] - 1;
            }
            [self selectRow:nextRow focus:YES];
            break;
        case KeyboardKey_PageUp: {
            [self deselectCell];
            NSLog(@"KeyboardKey_PageUp");
            NSInteger pageValue = 0;
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                pageValue = kKeyboardLandscapePageValue;
            } else {
                pageValue = kKeyboardPortraitPageValue;
            }
            
            NSInteger nextRow = self.currentSelection.row - pageValue;
            if (nextRow < 0) {
                nextRow = 0;
            }
            [self selectRow:nextRow focus:YES];
        }
            break;
        case KeyboardKey_X:
            [self tapOnLabeled:nil];
            break;
        case KeyboardKey_Done:
            [self deselectCell];
            NSLog(@"KeyboardKey_Done");
            [self.view endEditing:YES];
            break;
        default:
            break;
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notif {
    
    [self calculateTableViewFrame];
}

- (void)keyboardWillShow:(NSNotification *)notif{
    
    double keyBoardHeight = 0;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        keyBoardHeight = 352;
    } else {
        keyBoardHeight = 264;
    }
    
    CGRect tableViewFrame = self.tableView.frame;
    double tableHeight = 0;
    
    double visibleScreenHeight = self.view.frame.size.height - keyBoardHeight;
    
    NSInteger nrOfRows = [_itemDetails count];
    
    tableHeight = nrOfRows *44;

    if ((tableViewFrame.origin.y + tableHeight) < visibleScreenHeight) {
        // do nothing, the height is ok
    } else {
        tableHeight = visibleScreenHeight - tableViewFrame.origin.y;
    }
    
    tableViewFrame.size.height = tableHeight;
    self.tableView.frame = tableViewFrame;
    [self.tableView scrollToRowAtIndexPath:self.currentSelection atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark Scan DelegateMethods

-(void)stopScanner {
    [self.scanApiTimer invalidate];
    self.scanApiTimer = nil;
    
    [self.scanApiHelper close];
    self.scanApiHelper = nil;
}

-(void)onTimer:(id)sender {
    NSLog(@"scan  %@", self.scanApiHelper);
    [self.scanApiHelper doScanApiReceive];
}

-(void)startScanning {
    self.scanApiTimer = [NSTimer scheduledTimerWithTimeInterval:.2
                                                         target:self
                                                       selector:@selector(onTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
    
    if (self.scanApiHelper != nil) {
        [self.scanApiHelper postSetTriggerDevice:self.deviceInfo
                                          Action:kSktScanTriggerStart
                                          Target:self
                                        Response:@selector(onSetTrigger:)];
    }
}

-(void)stopTimer {
    [self.scanApiTimer invalidate];
    self.scanApiTimer = nil;
}

-(void)onDeviceArrival:(SKTRESULT)result Device:(DeviceInfo*)theDeviceInfo{
    // create a device info object to display the device main
    // information in the table view
    
    NSLog(@"onDeviceArrival Device Info = %@ -- %@", theDeviceInfo, [theDeviceInfo getTypeString]);
    
    if (SKTSUCCESS(result)) {
        
        if ([[theDeviceInfo getTypeString] isEqualToString:@"SoftScan"] == YES) {
            
            return;
        } else {
            NSString *msg = [NSString stringWithFormat:@"DEVICE: %@ was detected", [theDeviceInfo getTypeString]];
            
            UIAlertView *alert=[[UIAlertView alloc]
                                initWithTitle:@"Notification"
                                message:msg
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
            [alert show];
            [alert release];
            self.deviceInfo = theDeviceInfo;
            
            [Settings setSetting:[NSNumber numberWithBool:YES] forKey:kBluetootheScannerDetected];
            //[self.activityIndicator stopAnimating];
            //self.scannerImageView.image = [UIImage imageNamed:@"scanner50x37"];
        }
	}
	else {
		UIAlertView *alert=[[UIAlertView alloc]
							initWithTitle:@"Error"
							message:@"Unable to open the scanner"
							delegate:self
							cancelButtonTitle:@"OK"
							otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

-(void) onDeviceRemoval:(DeviceInfo*) deviceRemoved{
    NSLog(@"onDeviceRemoval");
    
    [Settings setSetting:[NSNumber numberWithBool:NO] forKey:kBluetootheScannerDetected];
    
    NSString *msg = [NSString stringWithFormat:@"DEVICE: %@ was removed", [deviceRemoved getTypeString]];
    
    UIAlertView *alert=[[UIAlertView alloc]
                        initWithTitle:@"Notification"
                        message:msg
                        delegate:nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void) onError:(SKTRESULT) result {
    NSLog(@"onError %ld", result);
    UIAlertView *alert=[[UIAlertView alloc]
                        initWithTitle:@"Notification"
                        message:@"Scanner detection failed! Please restart the application"
                        delegate:nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void) onDecodedData:(DeviceInfo*) device DecodedData:(id<ISktScanDecodedData>) decodedData{
    
    NSString *barcode = [NSString stringWithUTF8String:(const char *) [decodedData getData]];
    
    NSLog(@" onDecodedData text = %@", barcode);
   
    if (_currentCellIndex == kCellIndexItem) {
        [self searchForItem:barcode forRow:self.currentSelection.row selectNextCell:YES];
    } else if (_currentCellIndex == kCellIndexLocation) {
        [self searchLocation:barcode forRow:self.currentSelection.row selectNextCell:YES];
    } else if (_currentCellIndex == kCellIndexRecvd) {
        [self setReceived:barcode forRow:self.currentSelection.row selectNextCell:YES];
    }
}

-(void) onScanApiInitializeComplete:(SKTRESULT) result{
    
    NSLog(@"onScanApiInitializeComplete %@", self.scanApiHelper);
}

-(void)onSetOverlayView:(id<ISktScanObject>)scanObject{
    SKTRESULT result=[[scanObject Msg]Result];
    
    NSLog(@"  onSetOverlayView");
    if (!SKTSUCCESS(result)) {
        NSLog(@" Unable to set Overlay View");
    }
}

-(SKTRESULT)onSetProperty:(id<ISktScanObject>)scanObject{
    SKTRESULT result=ESKT_NOERROR;
    if(self.deviceInfo!=nil){
        result=[[scanObject Msg]Result];
        if(!SKTSUCCESS(result)){
            [self.deviceInfo setPropertyError:[[scanObject Property]getID] Error:result];
        }
    }
    return result;
}

-(SKTRESULT)onSetSoftScanProperty:(id<ISktScanObject>)scanObject{
    SKTRESULT result=[[scanObject Msg]Result];
    
    NSLog(@"  onSetSoftScanProperty");
    if (!SKTSUCCESS(result)) {
        NSLog(@" Unable to set Soft Scan");
    } else {
        NSLog(@"Set Soft Scan successfully ");
    }
    
    return result;
}

-(SKTRESULT)onSetSoftScan:(id<ISktScanObject>)scanObject{
    SKTRESULT result=[[scanObject Msg]Result];
    
    NSLog(@"Set Soft scan");
    if (!SKTSUCCESS(result)) {
        NSLog(@" Unable to set SoftScan");
    } else {
        NSLog(@" Set SoftScan successfully");
    }
    
    return result;
}

-(void)onSetTrigger:(id<ISktScanObject>)scanObject{
    SKTRESULT result=[[scanObject Msg]Result];
    
    if (!SKTSUCCESS(result)) {
        NSLog(@" Unable to trigger the soft scan scanner");
    } else {
        NSLog(@" Trigger soft scan scanner successfully");
    }
}

-(void)onSetSymbology:(id<ISktScanObject>)scanObject{
    SKTRESULT result=[[scanObject Msg]Result];
    
    if (!SKTSUCCESS(result)) {
        NSLog(@" Unable to set symbology to the SoftScan scanner");
    }
}

-(void)onsetDecodeAction:(id<ISktScanObject>)scanObject{
    SKTRESULT result=[[scanObject Msg]Result];
    
    if (!SKTSUCCESS(result)) {
        NSLog(@" Unable to set decoded action to the SoftScan scanner");
    }
}

/**
 * called when ScanAPI has been terminated. This will be
 * the last message received from ScanAPI
 */

-(void) onScanApiTerminated {
    
}

/**
 * called when an error occurs during the retrieval
 * of a ScanObject from ScanAPI.
 * @param result contains the retrieval error code
 */
-(void) onErrorRetrievingScanObject:(SKTRESULT) result {
    
}

@end
