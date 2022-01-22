//
//  CSDPhotosViewController.m
//  CSD
//
//  Created by .D. .D. on 6/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDPhotosViewController.h"
#import "CSDPhotoCell.h"
#import <QuartzCore/QuartzCore.h>
#import <ImagePicker/ImagePicker-Swift.h>
#import "MobileOffice-Swift.h"
#import "AccidentVehicleReport+CoreDataClass.h"
#import "Photo+Photo_Imp.h"
#import "PhotosAggregate.h"
#import "DataRepository.h"
#import "UIImage+Resize.h"

@interface CSDPhotosViewController ()
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableDictionary *photos;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *editBtn;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;
@property (nonatomic, strong) NSMutableArray *itemsToDelete;

@end

@implementation CSDPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(closeButtonPressed:)];
    self.navigationItem.leftBarButtonItem = closeBtn;

    self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                 target:self
                                                                 action:@selector(saveButtonPressed:)];
    [self.saveBtn setEnabled:NO];

    self.editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                 target:self
                                                                 action:@selector(editButtonPressed:)];
    self.doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                 target:self
                                                                 action:@selector(doneButtonPressed:)];

    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editBtn, self.saveBtn, nil];
    self.title = @"Photos";
    self.sections = [NSArray arrayWithObjects:@"1. Photos of the accident - show point of imapct - Show the position the vehicles end up in if possible before moving", @"2. Take pictures of all the damage to all vehicles", @"3. Take picture of the other vehicle license plate with registration sticker, inside other vehicle", @"4. Take any other picture you feel are need 0 also include video", nil];
    [self loadItems];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"Photo"] registerForCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[DataRepository sharedInstance] getAggregateForClass:@"Photo"] unRegisterForCallback:self];
}

-(IBAction)syncPhotos:(id)sender {
    PhotosAggregate *agg = (PhotosAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Photo"];
    [agg getPhotosForMasterBarcode:self.header.rcoBarcode];
}

-(void)loadItems {
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;

    NSArray *photos = [agg getPhotosForObject:self.header];
    self.photos = [NSMutableDictionary dictionary];
    for (Photo *photo in photos) {
        NSString *category = photo.category;
        if (!category.length) {
            continue;
        }
        NSMutableArray *items = [self.photos objectForKey:photo.category];
        if (!items) {
            items = [NSMutableArray array];
        }
        // image stored locally
        UIImage *content = [agg getImageForObject:photo.rcoMobileRecordId size:[kImageSizeForUpload intValue]];
        if (!content) {
            // synced image
            content = [agg getImageForObject:photo.rcoObjectId size:[kImageFullSizeDownloaded intValue]];
        }

        if (content) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:content forKey:@"image"];
            [dict setObject:photo.rcoMobileRecordId forKey:@"id"];

            [items addObject:dict];
        } else {
            [agg downloadDataForObject:photo.rcoObjectId size:@"-1"];

        }
        [self.photos setObject:items forKey:category];
    }
    NSLog(@"");
    [self.tableView reloadData];
}

-(IBAction)editButtonPressed:(id)sender {
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = self.doneBtn;
    self.itemsToDelete = [NSMutableArray array];
    [self.tableView setEditing:YES];
}

-(IBAction)doneButtonPressed:(id)sender {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editBtn, self.saveBtn, nil];
    NSLog(@"");
    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;
    for (NSDictionary *imageDict in self.itemsToDelete) {
        NSString *mobileRecordId = [imageDict objectForKey:@"id"];
        // TODO delete this one locally
        RCOObject *photo = [agg getObjectWithMobileRecordId:mobileRecordId];
        [agg destroyObjectJustFromLocalDB:photo];
    }
    
    [agg save];
    
    [self.tableView setEditing:NO];
}

-(IBAction)saveButtonPressed:(id)sender {

    PhotosAggregate *agg = [DataRepository sharedInstance].photosAggregate;

    for (NSString *category in self.photos.allKeys) {
        NSArray *photos = [self.photos objectForKey:category];
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
            
            if ([self.header existsOnServerNew]) {
                newPhoto.parentObjectId = self.header.rcoObjectId;
                newPhoto.parentObjectType = self.header.rcoObjectType;
                newPhoto.parentBarcode = self.header.rcoBarcode;
            } else {
                newPhoto.parentObjectId = self.header.rcoObjectId;
                newPhoto.parentObjectType = self.header.rcoObjectClass;
                newPhoto.parentBarcode = nil;
                // add the link of the new photo to the photo parent record
                [self.header addLinkedObject:newPhoto.rcoMobileRecordId];
                [[self aggregate] save];
            }
            
            [newPhoto setContentNeedsUploading:YES];
            [newPhoto setFileNeedsUploading:[NSNumber numberWithBool:YES]];
            
            [agg save];
            [agg registerForCallback:self];
            [agg createNewRecord:newPhoto];
            
            double compression = 0.5;
            
            NSData *imageData = UIImageJPEGRepresentation(image, compression);
            NSURL *fileURL = [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeForUpload];
            
            BOOL saveThumbnail = YES;
            if (saveThumbnail) {
                CGSize size = CGSizeMake([kImageSizeThumbnailSize integerValue], [kImageSizeThumbnailSize integerValue]);
                UIImage *imageResized = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
                NSData *imageData = UIImageJPEGRepresentation(imageResized, compression);
                [agg saveImage:imageData forObjectId:newPhoto.rcoMobileRecordId andSize:kImageSizeThumbnailSize];
            }
        }
    }
    [self.saveBtn setEnabled:NO];
}

#pragma mark UITableViewDataSource

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = [NSString stringWithFormat:@"%d", (int)(indexPath.section + 1)];
    NSArray *items = [self.photos objectForKey:sectionName];
    
    if (indexPath.row >= items.count) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = [NSString stringWithFormat:@"%d", (int)(indexPath.section + 1)];
    NSArray *items = [self.photos objectForKey:sectionName];

    if (indexPath.row < items.count) {
        NSString *msg = [NSString stringWithFormat:@"Delete photo %d?", (int)(indexPath.row +1)];
        return msg;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        NSString *sectionName = [NSString stringWithFormat:@"%d", (int)(indexPath.section + 1)];
        NSMutableArray *items = [self.photos objectForKey:sectionName];

        id itemToDelete = [items objectAtIndex:indexPath.row];
        
        [self.itemsToDelete addObject:itemToDelete];
         
        [items removeObjectAtIndex:indexPath.row];
        
        [self deleteItem:itemToDelete];
        [self.photos setObject:items forKey:sectionName];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
        [tableView reloadData];
        NSLog(@"");
    }
}

-(void)deleteItem:(id)itemToDelete {
    if (!itemToDelete) {
        return;
    }
    /*
     if ([itemToDelete isKindOfClass:[Note class]]) {
     
     Note *note = (Note*)itemToDelete;
     
     NotesAggregate *agg = (NotesAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Note"];
     
     PhotosAggregate *photoAgg = (PhotosAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Photo"];
     NSArray *photos = [photoAgg getPhotosForObject:note];
     
     for (Photo *p in photos) {
     [agg destroyObj:p];
     }
     [agg destroyObj:note];
     }
     */
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionName = [self.sections objectAtIndex:section];
    sectionName = [NSString stringWithFormat:@"%d", (int)(section + 1)];
    NSArray *items = [self.photos objectForKey:sectionName];
   
    return items.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = [self.sections objectAtIndex:indexPath.section];
    sectionName = [NSString stringWithFormat:@"%d", (int)(indexPath.section + 1)];

    NSArray *items = [self.photos objectForKey:sectionName];

    if (indexPath.row < items.count) {
        return 200;
    } else {
        return 44;
    }
}

-(UITableViewCell*)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionName = [self.sections objectAtIndex:indexPath.section];
    sectionName = [NSString stringWithFormat:@"%d", (int)(indexPath.section + 1)];
    NSArray *items = [self.photos objectForKey:sectionName];
    
    if (indexPath.row < items.count) {
        CSDPhotoCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"CSDPhotoCell"];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CSDPhotoCell"
                                                         owner:self
                                                       options:nil];
            cell = (CSDPhotoCell *)[nib objectAtIndex:0];
        }
        
        NSDictionary *imgDict = [items objectAtIndex:indexPath.row];
        UIImage *img = [imgDict objectForKey:@"image"];
        cell.imageView.image = img;
        cell.imageView.layer.borderWidth = 1;
        cell.imageView.layer.borderColor = [UIColor blackColor].CGColor;
        
        return cell;
    } else {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"simpleCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"simpleCell"];
        }
        cell.textLabel.text = @"Add Photo";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionName = [self.sections objectAtIndex:section];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 375, 50)];
    [lbl setNumberOfLines:3];
    lbl.text = sectionName;
    [lbl setFont:[UIFont boldSystemFontOfSize:15]];
    return lbl;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = [self.sections objectAtIndex:indexPath.section];
    NSArray *items = [self.photos objectForKey:sectionName];
    if (indexPath.row < items.count) {

    } else {
        NSLog(@"");
        self.category = [NSString stringWithFormat:@"%d", (int)(indexPath.section + 1)];
        [self showImagePicker];
    }
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

/*
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 40)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btn setFrame:CGRectMake(0, 0, 100, 40)];
    [btn setCenter:footerView.center];
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [footerView addSubview:btn];
    [btn setTitle:@"Add Photo" forState:UIControlStateNormal];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}


-(IBAction)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ImagePickerDelegate

-(void)wrapperDidPress:(ImagePickerControllerPlus *)imagePicker images:(NSArray<UIImage *> *)images {
    NSLog(@"Images = %@", images);
}

-(void)doneButtonDidPress:(ImagePickerControllerPlus *)imagePicker images:(NSArray<UIImage *> *)images {
    NSLog(@"Images = %@", images);
    
    UIImage *img = nil;
    if (images.count) {
        img = [images objectAtIndex:0];
    }
    if (img) {
        NSMutableArray *images = [self.photos objectForKey:self.category];
        if (!images) {
            images = [NSMutableArray array];
        }
        NSMutableDictionary *imgDict = [NSMutableDictionary dictionary];
        [imgDict setObject:img forKey:@"image"];
        
        [images addObject:imgDict];
        if (!self.photos) {
            self.photos = [NSMutableDictionary dictionary];
        }
        [self.photos setObject:images forKey:self.category];
        [self.tableView reloadData];
    }
    [self.saveBtn setEnabled:YES];
    /*
    self.fileImg = img;
    self.shouldSaveImage = YES;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSString *dateStr = [dateFormat stringFromDate:[NSDate date]];
    
    NSString *name = [self.values objectForKey:@"name"];
    if (name.length == 0) {
        name = [NSString stringWithFormat:@"file_%@", dateStr];
    }
    
    if (!self.values) {
        self.values = [NSMutableDictionary dictionary];
    }
    
    [self.values setObject:name forKey:@"name"];
    [self.tableView reloadData];
    
    [self checkRequiredFilds];
    */
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

-(void)cancelButtonDidPress:(ImagePickerControllerPlus *)imagePicker {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

-(PhotosAggregate*)photosAggregate {
    return (PhotosAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"Photo"];
}

- (void) contentDownloadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate {
    
    UIImage *image = [aggregate getImageForObject:objectId];
    
    if (nil == image) {
        return;
    }
    
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:RD_G_R_U_F] || [message isEqualToString:RD_G_I_B_U] || [message isEqualToString:RD_G_R_U_X_F] ) {
        NSLog(@"");
        NSString *objId = [messageInfo objectForKey:@"objId"];
        
        if (aggregate == [self photosAggregate]) {
            // we shuld load the photos
            NSArray *photosIds = [messageInfo objectForKey:@"photosObjects"];
            
            NSMutableArray *photosObjects = [NSMutableArray array];
            NSMutableArray *urls = [NSMutableArray array];
            
            for (NSString *objId in photosIds) {
                Photo *photo = (Photo*)[[self photosAggregate] getObjectWithId:objId];
                if (photo) {
                    [photosObjects addObject:photo];
                    NSString *urlStr = [photo getImageURL:NO];
                    if (urlStr.length) {
                        NSURL *url = [[NSURL alloc] initWithString:urlStr];
                        //SDWebImageSource *source = [[SDWebImageSource alloc] initWithUrl:url placeholder:nil];
                        //[urls addObject:source];
                    }
                }
            }
            /*
            NSMutableArray *existingItems = [NSMutableArray arrayWithArray:self.imageSlider.images];
            [existingItems addObjectsFromArray:urls];
            
            [self.imageSlider setImageInputs:existingItems];
            
            [self.activity stopAnimating];
            [self.activity removeFromSuperview];
            
            self.items = [NSMutableArray arrayWithArray:photosObjects];
            */
            self.photos = [NSMutableArray array];
            [self.progressHUD hide:YES];
        }
        
        NSLog(@"objId = %@", objId);
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:RD_G_R_U_F] || [message isEqualToString:RD_G_I_B_U]) {
        NSString *active = [messageInfo objectForKey:@"objId"];
        
        if (active.length) {
            NSLog(@"");
        }
        
        NSLog(@"activee = %@", active);
        
        if (aggregate == [self photosAggregate]) {
            
            [self showSimpleMessage:@"Failed updating photos from RMS. Photos will be loaded locally!" andTitle:NSLocalizedString(@"Notification", nil)];
            [self.progressHUD hide:YES];
        }
    }
}


@end
