//
//  ShippingViewController.m
//  MobileOffice
//
//  Created by Rosalind Hartigan on 12/1/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "ShippingViewController.h"
#import "DataRepository.h"
#import "PartsAggregate.h"
#import "Part.h"
#import "Signature+Signature_Imp.h"
#import "ShippingDetail+ShippingDetail_Imp.h"

// sub editors
#import "PartsViewController.h"
#import "StoreViewController.h"
#import "SignatureViewController.h"
#import "TimecardhoursViewController_iPhone.h"
#import "CalendarViewController_iPad.h"

@implementation ShippingViewController


// for different signature boxes: perhaps an array would be best
#define STORE_VIEW_OFFSET 100
#define SHIPINFO_VIEW_OFFSET 200
#define SIGNATURE_VIEW_OFFSET 300

@synthesize tableInv, customInvCell;
@synthesize tableInvItem, customInvItemCell;

@synthesize shippingHeaders=m_shippingHeaders;
@synthesize shippingDetails=m_shippingDetails;
@synthesize activeField=m_activeField;
@synthesize unlockButton=m_unlockButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    [tableInv release];
    [customInvCell release];
    [tableInvItem release];
    [customInvItemCell release];
        
    [m_shippingHeaders release];
    [m_shippingDetails release];
    [m_activeField release];
    [m_unlockButton release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    // Add our custom add button as the nav bar's custom right view   
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                                                                target:self 
                                                                                action:@selector(startObjectEditing)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [editButton release];
    
    self.title = @"Shipping";
    
   
     
    [self objectSyncComplete:self.aggregate];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    

    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil
    
    self.tableInv=nil;
    self.customInvCell=nil;
    self.tableInvItem=nil;
    self.customInvItemCell=nil;
        
    self.shippingHeaders=nil;
    self.shippingDetails=nil;
    self.activeField=nil;
    self.unlockButton=nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( tableView == tableInv )
    {
        return [self.shippingHeaders count];
    }
    else if( tableView == tableInvItem )
    {
        return [self.shippingDetails count] + tableView.editing;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell=nil;
    
    if( tableView == tableInv )
    {
        static NSString *cellTableIdentifierInv = @"CustomShippingListCell";
        cell = [tableView dequeueReusableCellWithIdentifier:
                cellTableIdentifierInv];
        
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"CustomShippingListCell_iPad" owner:self options:nil];
            cell = self.customInvCell;
            self.customInvCell=nil;
        }
        
        // Configure the cell...
        ShippingHeader *sh = [self.shippingHeaders objectAtIndex: indexPath.row];
        
        UILabel *formNumberLabel = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
        UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
        UILabel *itemsLabel = (UILabel *)[cell.contentView viewWithTag:4];
        
        [formNumberLabel setText:sh.formNumber];
        
        Store *store = [[DataRepository sharedInstance].storeAggregate getStoreWithNumber:sh.shipToStoreNumber];
        [nameLabel setText:store.storeName];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //[dateFormat setDateFormat:@"mm-dd-yyyy"];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        [dateFormat setTimeStyle:NSDateFormatterNoStyle];
        
        [dateLabel setText:[dateFormat stringFromDate:(NSDate *) sh.dateShip]];
        [dateFormat release];
        
        NSArray *sds = [[self.aggregate shippingDetailAggregate] getObjectsWithParentId:sh.rcoObjectId];
        
        [itemsLabel setText: [NSString stringWithFormat:@"%i items", [sds count]]];
                
        // how many items
    }
    else if( tableView == tableInvItem )
    {
        static NSString *cellTableIdentifierInvItem = @"CustomShippingItemCell";
        cell = [tableView dequeueReusableCellWithIdentifier:
                cellTableIdentifierInvItem];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"CustomShippingItemCell_iPad" owner:self options:nil];
            cell = self.customInvItemCell;
            self.customInvItemCell=nil;
        }
        
        UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:3];
        UILabel *partNumLabel = (UILabel *)[cell.contentView viewWithTag:2];
        UITextField *quantityTextView = (UITextField *)[cell.contentView viewWithTag:1];
        UILabel *muLabel = (UILabel *)[cell.contentView viewWithTag:4];
        UILabel *boLabel = (UILabel *)[cell.contentView viewWithTag:5];
        UILabel *storeLabel = (UILabel *)[cell.contentView viewWithTag:6];
        
        if (indexPath.row < [self.shippingDetails count]) {
        
            ShippingDetail *sd = [self.shippingDetails objectAtIndex: indexPath.row];
            Store *store = [[DataRepository sharedInstance].storeAggregate getStoreWithNumber:sd.storeNumber];
            Part *part = [[DataRepository sharedInstance].partsAggregate getPartWithNumber:sd.itemNumber forStore:PART_LIBRARY_STORENUM];
            NSString *theKey = [self buildKeyForDetailObj:sd andKey:SHIPPINGDETAIL_QUANTITY];
            NSNumber *theVal = [self.objDict valueForKey:theKey];
            [self linkControl:(UIControl *)quantityTextView toKey:theKey];
            quantityTextView.userInteractionEnabled=tableView.editing;
            [quantityTextView setText:[theVal description]];
            
            [partNumLabel setText:sd.itemNumber];
            partNumLabel.enabled=true;
            
            [descLabel setText:part.partDescription];
            [muLabel setText:part.um];
            if( [sd.backOrder boolValue] )
                [boLabel setText:@"yes"];
            else
                [boLabel setText:@"no"];
            
            [storeLabel setText:store.storeName];
            
            if( tableView.editing )
            {
                quantityTextView.borderStyle = UITextBorderStyleBezel;
            }
            else
            {
                quantityTextView.borderStyle = UITextBorderStyleNone;
            }
        }
        else
        {
            partNumLabel.text = @"Add new part...";
            partNumLabel.enabled=false;
            
            quantityTextView.text=@"";
            quantityTextView.userInteractionEnabled=false;
            
            descLabel.text=@"";
            muLabel.text=@"";
            boLabel.text=@"";
            storeLabel.text=@"";
        }
        
        //        float total = [[invoiceItem valueForKey: INVITEM_QUANT] intValue] * ([[invoiceItem valueForKey: INVITEM_PARTPRICE] floatValue]);
        //        float tax = [[invoiceItem valueForKey: INVITEM_QUANT] intValue] * ([[invoiceItem valueForKey: INVITEM_PARTPRICE] floatValue] * 0.06);
        
        //        [totalLabel setText:[NSString stringWithFormat:@"$%.2f",total ]];
        //        [taxLabel setText:[NSString stringWithFormat:@"$%.2f",tax ]];
        
  
    }
    
    
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( tableView == tableInv )
    {
        
        ShippingHeader *sh = [self.shippingHeaders objectAtIndex: indexPath.row];
        [self setShippingHeader:sh];
        
    }
    else if( tableView == tableInvItem )
    {
        CGRect r = [tableView rectForRowAtIndexPath:indexPath];
        r.size.width=20;
        [self openPartsListFromRect: r inView:tableView];
    }
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ShippingDetail *sd = [self.shippingDetails objectAtIndex:indexPath.row];
        
        [self.shippingDetails removeObjectAtIndex:indexPath.row];
        [[self.aggregate shippingDetailAggregate] destroyObj:sd];
        
        [tableView reloadData];
    }  
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self openPartsListFromRect:[tableView rectForRowAtIndexPath:indexPath] inView:tableView];
    }  
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tableInv)
        return UITableViewCellEditingStyleNone;
    
    if(indexPath.row >= [self.shippingDetails count] )
        return UITableViewCellEditingStyleInsert;
    
    return UITableViewCellEditingStyleDelete;    
}
                         


#pragma mark -
#pragma mark Popover Controller delegate
/*- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
 {
 NSString *sn = [DataRepository sharedInstance].currentStoreNumber;
 if( [sn length] )
 {
 self.title = [NSString stringWithFormat: @"Parts for Store %@", sn];        
 }
 else
 {
 self.title = @"Parts";
 }
 
 [self objectSyncComplete:[self aggregate]];
 
 
 }
 */



#pragma mark - Editing
- (IBAction) addShippingHeader: (id) sender
{
    ShippingHeader *sh = (ShippingHeader *) [[self aggregate] createNewObject];
    
    sh.dateShip = [NSDate date];
    
    int formNumber = 1000 + [self.shippingHeaders count]*2;
    
    sh.formNumber = [NSString stringWithFormat:@"%i", formNumber];
    
    [self objectSyncComplete:self.aggregate];
    
    [self setShippingHeader:sh];
    
    [self startObjectEditing];
    
}

- (IBAction) deleteShippingHeader: (id) sender
{
    [self.aggregate destroyObj: self.obj];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray: self.shippingHeaders ];
    
    NSString *nextobjId=nil;
    int idx = [array indexOfObject:self.obj];
    
    if( idx > 0 )
    {
        idx--;
        RCOObject *nextObj = [array objectAtIndex:idx];
        nextobjId = nextObj.rcoObjectId;
    }
    [array removeObject:self.obj];
    
    self.shippingHeaders = array; 

    [self.tableInv reloadData];
    [self startDelayedSelection:nextobjId];

}


- (void) setShippingHeader: (ShippingHeader *) sh
{
    // this updates many of the linked controls
    self.title = [NSString stringWithFormat:@"Shipping Form #%@", sh.formNumber];
    
    // set up the linked text fields
    // form number
    self.linkedControls = [[NSMutableDictionary alloc] init ];
    UIView * tv = [self.view viewWithTag:10];
    [self.linkedControls setValue:tv forKey:SHIPPING_FORMNUMBER];
    
    // ship date
    tv = [self.view viewWithTag:11];
    [self.linkedControls setValue:tv forKey:SHIPPING_SHIPDATE];
    
    // store address info: from
    tv = [self.view viewWithTag:STORE_VIEW_OFFSET];
    [self.linkedControls setValue:[tv viewWithTag:1] forKey:SHIPPING_SHIPFROMSTORENUMBER];
    // to
    tv = [self.view viewWithTag:STORE_VIEW_OFFSET +1];
    [self.linkedControls setValue:[tv viewWithTag:1] forKey:SHIPPING_SHIPTOSTORENUMBER];
    
    
    // shipping info
    NSArray *shipInfoArray = [NSArray arrayWithObjects:SHIPPING_REFNUMBER ,SHIPPING_VIA, SHIPPING_TRACKINGNUMBER, nil];
    for (NSUInteger idxInfo=0; idxInfo < [shipInfoArray count]; idxInfo++) {
        tv = [self.view viewWithTag:SHIPINFO_VIEW_OFFSET + idxInfo];
        [self.linkedControls setValue:[tv viewWithTag:1] forKey:[shipInfoArray objectAtIndex:idxInfo]];
    }
    
    // detail items

    // signature names and titles
    NSArray *signatures = [[self.aggregate signatureAggregate] getObjectsWithParentId:sh.rcoObjectId];
    
    NSArray *array = [NSArray arrayWithObjects:SHIPPING_INITIATING_DESCRIPTION, SHIPPING_APPROVING_DESCRIPTION, SHIPPING_RELEASING_DESCRIPTION, nil];
    int idx = SIGNATURE_VIEW_OFFSET;
    for (NSString *authType in array) {
        
        tv = [self.view viewWithTag:idx];
        
        UITextField *nameField = (UITextField *)[tv viewWithTag:1];
        [nameField setText:@"" ];
        
        UITextField *titleField = (UITextField *)[tv viewWithTag:2];
        [titleField setText:@"" ];
        
        UIImageView *sigView = (UIImageView *)[tv viewWithTag:3];
        [sigView setImage:nil ];
        

        for (Signature *sig in signatures )
        {
             if( [sig.signerDescription isEqualToString:authType] )
            {
                [self.linkedControls setValue:nameField forKey:[self buildKeyForDetailObj:sig andKey:SIGNATURE_NAME]];
                [self.linkedControls setValue:titleField forKey:[self buildKeyForDetailObj:sig andKey:SIGNATURE_TITLE]];
                [self.linkedControls setValue:sigView forKey:[self buildKeyForDetailObj:sig andKey:KEY_CONTENT]];                
            }
        }
        
        idx++;
    }    
    
    
    // actually set the object data
    [self setObj:sh];
    
    // update content data for signatures
    int sigCount = 0;
    for (Signature *sig in signatures )
    {
        NSData * data= [[self.aggregate signatureAggregate] getDataForObject:sig.rcoObjectId size:@"-1"];
        if( data != nil ) 
        {
            [self setObjectValue:data forKey:[self buildKeyForDetailObj:sig andKey:KEY_CONTENT ] fromControl:nil];
            sigCount++;
        }
    }
  
    self.unlockButton.enabled = ( sigCount == 3 );
    
    // and set up invoice table
    self.shippingDetails = [NSMutableArray arrayWithArray: [[self.aggregate shippingDetailAggregate] getObjectsWithParentId:sh.rcoObjectId]];
    [tableInvItem reloadData];
    

/*    for(NSString *k in [self.linkedControls allKeys])
    {
        UIView *v = [self.linkedControls valueForKey:k];
        NSLog(@"%@: %@ %i %i %i",k, [v class], [v tag], [[v superview] tag], [[v subviews] count]);
        
    }
*/
     
}

- (void) openPartsListFromRect: (CGRect) aRect inView: (UIView *) aView
{
    if( ! self.isEditingObject )
        return;

    // use popover to match iphone
    PartsViewController *pVC = [[PartsViewController alloc] initWithNibName:@"PartsViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pVC];
    pVC.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    pVC.popoverController=aPopover; 
    [pVC release];
    
    aPopover.delegate = self;
    [aPopover presentPopoverFromRect: aRect inView:aView 
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [aPopover release];
    
}

- (void) addPart: (Part *) aPart
{
    // if the part is already there... up the quantity
    for( ShippingDetail *sd in self.shippingDetails )
    {
        if( [sd.itemNumber isEqualToString: aPart.partName] )
        {
            NSString *theKey = [self buildKeyForDetailObj:sd andKey:SHIPPINGDETAIL_QUANTITY];
            NSNumber *theVal = [self.objDict valueForKey:theKey];
            theVal = [NSNumber numberWithInt:1 + [theVal intValue]];
            [self setObjectValue:theVal forKey:theKey];
            [tableInvItem reloadData];
            return;
        }
    }
    
    [self newShippingDetail: aPart];
}

- (void) newShippingDetail: (Part *) aPart
{
    ShippingDetail *sd = (ShippingDetail *) [[self.aggregate shippingDetailAggregate] createNewObject];
    sd.rcoObjectParentId = self.obj.rcoObjectId;
    sd.itemNumber = aPart.partNumber;
    sd.storeNumber =[DataRepository sharedInstance].currentStoreNumber;
    sd.backOrder = [NSNumber numberWithBool:false];
    sd.quantity = [NSNumber numberWithInt:0];
    
    [self.shippingDetails addObject:sd];
    
    // add the linked controls

    
    // set the object fields
    NSString *theKey = [self buildKeyForDetailObj:sd andKey:SHIPPINGDETAIL_QUANTITY];
    [self setObjectValue:[NSNumber numberWithInt:1] forKey:theKey];

    [tableInvItem reloadData];
}

- (void) deleteShippingDetail:(NSIndexPath *) ip;
{
    
}

- (IBAction) openStoresList:(id)sender
{
    
    if( ! self.isEditingObject )
        return;
        
    StoreViewController *sVC = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sVC];
    sVC.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    if( [[(UIButton *) sender superview] tag] == STORE_VIEW_OFFSET )
    {
        [sVC setEditorDelegate:self withValue:[self.objDict valueForKey:SHIPPING_SHIPFROMSTORENUMBER] forKey:SHIPPING_SHIPFROMSTORENUMBER]; 
        
    }
    else
    {
        [sVC setEditorDelegate:self withValue:[self.objDict valueForKey:SHIPPING_SHIPTOSTORENUMBER] forKey:SHIPPING_SHIPTOSTORENUMBER]; 
        
    }
    //sVC.contentSizeForViewInPopover = sVC.view.frame.size;
    
    UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    sVC.popoverController=aPopover; 
    [sVC release];
    
    aPopover.delegate = self;
    [aPopover presentPopoverFromRect:[sender bounds] inView:sender 
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [aPopover release];
    
}

- (IBAction) openSignatureEditor:(id)sender
{
    if( ! self.isEditingObject )
        return;

    SignatureViewController *sVC = [[SignatureViewController alloc] initWithNibName:@"SignatureViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sVC];
    sVC.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // which view we clicked on will determine the suffix
    NSArray *array = [NSArray arrayWithObjects:SHIPPING_INITIATING_DESCRIPTION, SHIPPING_APPROVING_DESCRIPTION, SHIPPING_RELEASING_DESCRIPTION, nil];
    UIView *pv = [(UIButton *) sender superview];
    int sigIdx = [pv tag] - SIGNATURE_VIEW_OFFSET;
    if( sigIdx < 0 || sigIdx >= [array count])
        return;
    
    NSString *sigType = [array objectAtIndex:sigIdx];
    
    NSArray *signatures = [[self.aggregate signatureAggregate] getObjectsWithParentId:self.obj.rcoObjectId];
    Signature *chosenSignature=nil;
    for (Signature *sig in signatures )
    {
        if( [sig.signerDescription isEqualToString:sigType] )
        {
            chosenSignature=sig;
            break;
        }
    }
    if( chosenSignature == nil )
    {
        chosenSignature = (Signature *) [[self.aggregate signatureAggregate] createNewObject];
        chosenSignature.rcoObjectParentId = self.obj.rcoObjectId;
        chosenSignature.signerDescription = sigType;
        
        
        // add the linked controls
        
        [self.linkedControls setValue:[pv viewWithTag:1] forKey:[self buildKeyForDetailObj:chosenSignature andKey:SIGNATURE_NAME]];
        [self.linkedControls setValue:[pv viewWithTag:2] forKey:[self buildKeyForDetailObj:chosenSignature andKey:SIGNATURE_TITLE]];
        [self.linkedControls setValue:[pv viewWithTag:3] forKey:[self buildKeyForDetailObj:chosenSignature andKey:KEY_CONTENT]];                
        

        // set the object fields
        [self setDetailObj:chosenSignature];
        
        // including content
        [self setObjectValue:nil forKey:[self buildKeyForDetailObj:chosenSignature andKey:KEY_CONTENT]];
        
        

    }
    // now build the keys from the prefixes
    array = [NSArray arrayWithObjects:SIGNATURE_NAME, SIGNATURE_TITLE, KEY_CONTENT, nil];
    for( NSString *theField in array )
    {
        NSString *theKey = [self buildKeyForDetailObj:chosenSignature andKey:theField];
/*
        id val = [self.objDict valueForKey:theKey];
        
        NSArray *sortedArray =
        [[self.objDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSLog(@"%@ %i %@", theKey, [sortedArray indexOfObject:theKey], sortedArray);
        if( ![theField isEqualToString:KEY_CONTENT] )
        {
            NSLog(@"%@", val);
        }
*/        
        [sVC setEditorDelegate:self withValue:[self.objDict valueForKey:theKey] forKey:theKey]; 
    }
            
    sVC.contentSizeForViewInPopover = sVC.view.frame.size;
    
    UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    sVC.popoverController=aPopover; 
    [sVC release];
    
    aPopover.delegate = self;
    [aPopover presentPopoverFromRect:[sender bounds] inView:sender 
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [aPopover release];
    
    
}

// choose ship date
- (IBAction) openCalendar: (id) sender
{
    if( ! self.isEditingObject )
        return;
    
    if( DEVICE_IS_IPHONE ) {
        
        NSLog(@"is an iPhone");
        TimecardhoursViewController_iPhone *setDateVC = [[TimecardhoursViewController_iPhone alloc] initWithNibName:@"TimecardhoursViewController_iPhone" bundle:nil];
        
        [self.navigationController pushViewController:setDateVC animated:YES];
        
        [setDateVC setEditorDelegate:self withValue:[self.objDict valueForKey:SHIPPING_SHIPDATE] forKey:SHIPPING_SHIPDATE]; 
        
        [setDateVC release];
    }
    else {
        CalendarViewController_iPad *setDateVC = [[CalendarViewController_iPad alloc] initWithNibName:@"CalendarViewController_iPad" bundle:nil];
        
        [setDateVC setEditorDelegate:self withValue:[self.objDict valueForKey:SHIPPING_SHIPDATE] forKey:SHIPPING_SHIPDATE];
        
        [self.navigationController pushViewController:setDateVC animated:YES];
        [setDateVC release];
    }
}

#pragma mark - RCOObjectEditorView override
// the editing object value has changed - refresh the associated linked control
- (void) refreshedLinkedControl: (NSString *) theKey
{
    NSObject *theValue = [self.objDict valueForKey:theKey];
 
#if 0
    if( ![theKey hasSuffix:KEY_CONTENT] )
        NSLog(@"refreshedLinkedControl %@ %@ %@", theKey, theValue, [[self.linkedControls valueForKey:theKey] class]);  
    else
        NSLog(@"refreshedLinkedControl %@ %@", theKey, [[self.linkedControls valueForKey:theKey] class]);
#endif

    if( [theKey isEqualToString:SHIPPING_SHIPFROMSTORENUMBER] || [theKey isEqualToString:SHIPPING_SHIPTOSTORENUMBER] )
    {
        Store *theStore = [[DataRepository sharedInstance].storeAggregate getStoreWithNumber:(NSString *) theValue];
        UITextView *tv = [self.linkedControls valueForKey:theKey];
        if(theStore != nil && tv != nil)
        {
            tv.text = [theStore constructedNameAndAddress];
        }
        else
        {
            tv.text = @"";
        }
    }
    else if( [theKey hasSuffix:KEY_CONTENT] )
    {
        UIImageView *imgView = [self.linkedControls valueForKey:theKey];
        if(imgView != nil)
        {
            imgView.image = [UIImage imageWithData:(NSData *) theValue];
        }
        
        
    }
    else if( [theKey isEqualToString:SHIPPING_SHIPDATE] )
    {
        // set up date & form number sstring
        NSString* dateStr= @"";
        if( theValue != nil )
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            //[dateFormat setDateFormat:@"MMM d, yyyy"];
            [dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [dateFormat setTimeStyle:NSDateFormatterNoStyle];
            dateStr = [dateFormat stringFromDate:(NSDate *) theValue];
            [dateFormat release];
        }       
        
        UIButton * bt = [self.linkedControls valueForKey:theKey];
        if( bt != nil )
        {
            [bt setTitle:[NSString stringWithFormat:@"Ship Date: %@", dateStr] forState:UIControlStateNormal];
        }
        
    }
    else {
        [super refreshedLinkedControl:theKey];
    }
    
}

- (void) startObjectEditing
{
    
    // Add our custom add button as the nav bar's custom right view   
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                target:self 
                                                                                action:@selector(saveObjectEdits)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [saveButton release];
    
    [tableInvItem setEditing:true];
    [tableInvItem reloadData];
    [super startObjectEditing];
    
}

- (void) endObjectEditing
{
    // turn save button into editing button  
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                                                                target:self 
                                                                                action:@selector(startObjectEditing)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    [editButton release];

    [tableInvItem setEditing:false];
   
    
    int sigCount = 0;
    NSArray *details = [[self.aggregate signatureAggregate] getObjectsWithParentId:self.obj.rcoObjectId];
    for (Signature *sig in details)
    {
        if( [[self.aggregate signatureAggregate] isDataDownloaded:sig.rcoObjectId size:@"-1"] )
        {
            sigCount ++;
        }
    }
    
    self.unlockButton.enabled = ( sigCount == 3 );
    
    [super endObjectEditing];
    
    [tableInvItem reloadData];
    [tableInv reloadData];
}


#pragma mark - RCODataViewController
- (ShippingAggregate *) aggregate
{
    return [[DataRepository sharedInstance] shippingAggregate];
}

- (void) finishDelayedSelection:(NSString *) objId
{
    if( [ self.shippingHeaders count] == 0 )
        return;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    if(  objId != nil )
    {
        RCOObject *obj = [self.aggregate getObjectWithId:objId];
        ip = [NSIndexPath indexPathForRow:[self.shippingHeaders indexOfObject:obj] inSection:0];
    }
    
    [self.tableInv selectRowAtIndexPath:ip 
                               animated:YES 
                         scrollPosition:UITableViewScrollPositionMiddle]; 
    
    [self tableView:self.tableInv didSelectRowAtIndexPath:ip];

}

#pragma mark - RCO data view delegate
- (void)objectSyncComplete: (Aggregate *) fromAggregate
{
    NSString *objId = nil;
    if( self.obj )
        objId = self.obj.rcoObjectId;
    
    self.shippingHeaders = [[NSArray alloc] initWithArray:[ [self aggregate] getAll] ]; 
    [self.tableInv reloadData];
    
    self.shippingDetails = [[NSMutableArray alloc] init ];
    [self.tableInvItem reloadData];
    
    
    [self startDelayedSelection:objId];
    
   // [[(ShippingAggregate *) self.aggregate signatureAggregate] getObjectsWithParentId:sh.rcoObjectId];
    
}


- (void)objectsChanged: (Aggregate *) fromAggregate
{
    [super objectsChanged:fromAggregate];
    self.shippingHeaders = [[NSArray alloc] init ];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    if( self.view.frame.origin.y >= 0 )
        [self setViewMovedUp:YES];

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField == self.activeField && ( self.view.frame.origin.y < 0 )){
        [self setViewMovedUp:NO];

    }
    self.activeField = nil;
}

- (void)keyboardWillHide:(NSNotification *)notif {
    return;
    if( self.view.frame.origin.y < 0 )
        [self setViewMovedUp:NO];
}


- (void)keyboardWillShow:(NSNotification *)notif{
    return;
    if( self.activeField != nil )
        [self setViewMovedUp:YES];
}

-(void)setViewMovedUp:(BOOL)movedUp
{
#define kOFFSET_FOR_KEYBOARD 350
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        
        if (rect.origin.y == 0 ) {
            rect.origin.y -= kOFFSET_FOR_KEYBOARD;
            //rect.size.height += kOFFSET_FOR_KEYBOARD;
        }
        
    }
    else
    {
        //if (self.activeField == nil) {
            rect.origin.y += kOFFSET_FOR_KEYBOARD;
            //rect.size.height -= kOFFSET_FOR_KEYBOARD;
        //}
    }
    self.view.frame = rect; 
    [UIView commitAnimations];
}


@end
